-- Isolated prototype roster. This module owns hero identity, immutable class and
-- life eligibility in server memory; it never reads or writes a DataStore.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local HeroSessionService = {}
local CLASS_IDS = { knight = true, elf = true, dwarf = true, mage = true }
local MAX_HEROES = 4
local REQUEST_BURST = 10
local REQUEST_REFILL = 4
local sessions = {}
local settings
local stateRemote
local started = false

local function finite(value)
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function disconnectLife(state)
	for _, connection in ipairs(state.lifeConnections) do connection:Disconnect() end
	state.lifeConnections = {}
end

local function connected(state)
	return sessions[state.player] == state and state.player.Parent == Players
end

local function selectedHero(state)
	return state.selectedHeroId and state.byId[state.selectedHeroId] or nil
end

local function snapshot(state)
	local heroes = {}
	for _, hero in ipairs(state.heroes) do
		table.insert(heroes, {
			heroId = hero.heroId, classId = hero.baseClassId,
			practice = { moved = hero.practice.moved, attacked = hero.practice.attacked, dodged = hero.practice.dodged },
		})
	end
	return {
		revision = state.revision, phase = state.phase, heroes = heroes,
		selectedHeroId = state.selectedHeroId, activeHeroId = state.mode == "Tutorial" and state.selectedHeroId or nil,
		canManage = state.phase == "Lobby" and state.ready,
		canStart = state.phase == "Lobby" and state.ready and selectedHero(state) ~= nil,
		maxHeroes = MAX_HEROES, sessionOnly = true,
	}
end

local function publish(state, requestId, errorCode)
	if connected(state) and stateRemote then
		stateRemote:FireClient(state.player, snapshot(state), requestId, errorCode)
	end
end

local function changed(state)
	state.revision = state.revision + 1
	state.player:SetAttribute("K0SessionPhase", state.phase)
	publish(state)
end

local function validLife(state, character)
	return character ~= nil and connected(state) and state.character == character and state.player.Character == character
		and character:IsDescendantOf(workspace) and state.ready
		and character:GetAttribute("K0SpawnReady") == true
end

local function atLobby(state)
	if state.phase ~= "Lobby" or state.mode ~= "Lobby" or not state.character or not validLife(state, state.character) then
		return false, "WaitForLobby"
	end
	local human = state.character:FindFirstChildOfClass("Humanoid")
	local root = state.character:FindFirstChild("HumanoidRootPart")
	if not human or human.Health <= 0 or not root or not root:IsA("BasePart") then return false, "WaitForLobby" end
	local delta = root.Position - settings.lobbyBounds.center
	local half = settings.lobbyBounds.size / 2
	if not finite(delta.X) or not finite(delta.Y) or not finite(delta.Z)
		or math.abs(delta.X) > half.X or math.abs(delta.Y) > half.Y or math.abs(delta.Z) > half.Z then
		return false, "ReturnToPlatform"
	end
	return true
end

local function invalidateLife(state)
	state.ready = false
	state.epoch = state.epoch + 1
	disconnectLife(state)
	if state.character then state.character:SetAttribute("K0SpawnReady", false) end
end

local function transition(state, mode)
	-- Revoke combat before starting any asynchronous Character replacement.
	invalidateLife(state)
	state.mode = mode
	state.phase = mode == "Tutorial" and "LoadingTutorial" or "ReturningLobby"
	state.transitionId = state.transitionId + 1
	changed(state)
	local destination = mode == "Tutorial" and settings.tutorialSpawn or settings.lobbySpawn
	local ok = settings.requestSpawn(state.player, destination, state.transitionId)
	if not ok then
		-- Keep the old life ineligible. The user can safely retry the same route.
		state.phase = "SpawnFailed"
		changed(state)
		return "SpawnUnavailable"
	end
	return nil
end

local function validateRequest(action, requestId, argument, extraCount)
	if extraCount ~= 0 or type(action) ~= "string" or #action > 24
		or type(requestId) ~= "string" or #requestId < 1 or #requestId > 48
		or not requestId:match("^[%w_-]+$") then return false end
	if action == "CreateHero" then return type(argument) == "string" and CLASS_IDS[argument] == true end
	if action == "SelectHero" then return type(argument) == "string" and #argument > 0 and #argument <= 64 end
	return (action == "GetState" or action == "StartTutorial" or action == "ReturnLobby") and argument == nil
end

local function consumeToken(state)
	local current = os.clock()
	state.tokens = math.min(REQUEST_BURST, state.tokens + math.max(0, current - state.lastRefill) * REQUEST_REFILL)
	state.lastRefill = current
	if state.tokens < 1 then return false end
	state.tokens = state.tokens - 1
	return true
end

local function execute(state, action, argument)
	if action == "GetState" then return nil end
	if action == "ReturnLobby" then
		if state.phase == "Lobby" then return nil end
		if state.mode ~= "Tutorial" and state.phase ~= "SpawnFailed" then return "Busy" end
		return transition(state, "Lobby")
	end
	local safe, reason = atLobby(state)
	if not safe then return reason end
	if action == "CreateHero" then
		if state.byClass[argument] then return "ClassAlreadyCreated" end
		if #state.heroes >= MAX_HEROES then return "RosterFull" end
		local hero = {
			heroId = HttpService:GenerateGUID(false), baseClassId = argument,
			practice = { moved = false, attacked = false, dodged = false },
		}
		state.byId[hero.heroId] = hero
		state.byClass[argument] = hero
		table.insert(state.heroes, hero)
		state.selectedHeroId = hero.heroId
		changed(state)
	elseif action == "SelectHero" then
		if not state.byId[argument] then return "HeroNotOwned" end
		if state.selectedHeroId ~= argument then state.epoch = state.epoch + 1 end
		state.selectedHeroId = argument
		changed(state)
	elseif action == "StartTutorial" then
		if not selectedHero(state) then return "SelectHeroFirst" end
		return transition(state, "Tutorial")
	end
	return nil
end

local function handleRequest(player, action, requestId, argument, ...)
	local state = sessions[player]
	if not state or not connected(state) then return end
	if not consumeToken(state) then
		local current = os.clock()
		if current - (state.lastThrottleResponse or -math.huge) >= 0.5 then
			state.lastThrottleResponse = current
			publish(state, nil, "TooFast")
		end
		return
	end
	if not validateRequest(action, requestId, argument, select("#", ...)) then
		publish(state, nil, "InvalidRequest")
		return
	end
	local previous = state.requests[requestId]
	if previous then
		local errorCode = previous.errorCode
		if previous.action ~= action or previous.argument ~= argument then errorCode = "RequestConflict" end
		publish(state, requestId, errorCode)
		return
	end
	local errorCode = execute(state, action, argument)
	-- This bounded response cache makes double taps replay a result instead of
	-- creating another hero or another life. All mutations above are non-yielding.
	state.requests[requestId] = { action = action, argument = argument, errorCode = errorCode }
	table.insert(state.requestOrder, requestId)
	if #state.requestOrder > 32 then state.requests[table.remove(state.requestOrder, 1)] = nil end
	publish(state, requestId, errorCode)
end

local function bindPlayer(player)
	if sessions[player] or player.Parent ~= Players then return end
	local state = {
		player = player, heroes = {}, byId = {}, byClass = {}, mode = "Lobby", phase = "LoadingLobby",
		epoch = 0, generation = 0, transitionId = 0, ready = false, revision = 0,
		tokens = REQUEST_BURST, lastRefill = os.clock(), requests = {}, requestOrder = {}, lifeConnections = {},
	}
	sessions[player] = state
	player:SetAttribute("K0SessionPhase", state.phase)
end

local function unbindPlayer(player)
	local state = sessions[player]
	if not state then return end
	invalidateLife(state)
	sessions[player] = nil
end

-- Server bootstrap dependency. Snapshot tables are copies, never mutable roster
-- entries. Combat must use getCombatContext rather than replicated Attributes.
function HeroSessionService.getActiveHero(player)
	local state = sessions[player]
	local hero = state and selectedHero(state)
	if not hero or not connected(state) then return nil end
	return { heroId = hero.heroId, classId = hero.baseClassId, epoch = state.epoch }
end

function HeroSessionService.getCombatContext(player, character)
	local state = sessions[player]
	if not state or state.mode ~= "Tutorial" or state.phase ~= "Tutorial" or not validLife(state, character) then return nil end
	local hero = selectedHero(state)
	local human = character:FindFirstChildOfClass("Humanoid")
	if not hero or not human or human.Health <= 0 then return nil end
	return { heroId = hero.heroId, baseClassId = hero.baseClassId, epoch = state.epoch, characterGeneration = state.generation }
end

function HeroSessionService.onLifeStarted(player, character, generation, requestId)
	local state = sessions[player]
	if not state or not connected(state) or state.transitionId ~= requestId or player.Character ~= character then return end
	invalidateLife(state)
	state.character, state.generation = character, generation
	state.phase = state.mode == "Tutorial" and "LoadingTutorial" or "LoadingLobby"
	local hero = state.mode == "Tutorial" and selectedHero(state) or nil
	character:SetAttribute("K0HeroId", hero and hero.heroId or nil)
	character:SetAttribute("K0HeroEpoch", state.epoch)
	character:SetAttribute("K0CharacterGeneration", generation)
	character:SetAttribute("K0ClassId", hero and hero.baseClassId or nil)
	changed(state)
end

function HeroSessionService.onLifeEnded(player, character, generation, requestId)
	local state = sessions[player]
	if not state or state.character ~= character or state.generation ~= generation or state.transitionId ~= requestId then return end
	invalidateLife(state)
	state.phase = state.mode == "Tutorial" and "LoadingTutorial" or "LoadingLobby"
	changed(state)
end

function HeroSessionService.onReady(player, character, generation, requestId)
	local state = sessions[player]
	if not state or not connected(state) or state.transitionId ~= requestId or state.character ~= character
		or state.generation ~= generation or player.Character ~= character
		or not character:IsDescendantOf(workspace) or character:GetAttribute("K0SpawnReady") ~= true then return end
	local human = character:FindFirstChildOfClass("Humanoid")
	if not human or human.Health <= 0 or state.ready then return end
	state.ready = true
	state.phase = state.mode
	local root = character:FindFirstChild("HumanoidRootPart")
	state.practiceOrigin = root and root.Position or nil
	local hero = state.mode == "Tutorial" and selectedHero(state) or nil
	if hero then
		local function observe()
			if not HeroSessionService.getCombatContext(player, character) then return end
			local updated = false
			if not hero.practice.attacked and (character:GetAttribute("K0AttackSeq") or 0) > 0 then
				hero.practice.attacked, updated = true, true
			end
			if not hero.practice.dodged and character:GetAttribute("K0State") == "Dodge" then
				hero.practice.dodged, updated = true, true
			end
			if updated then changed(state) end
		end
		table.insert(state.lifeConnections, character:GetAttributeChangedSignal("K0AttackSeq"):Connect(observe))
		table.insert(state.lifeConnections, character:GetAttributeChangedSignal("K0State"):Connect(observe))
	end
	changed(state)
end

function HeroSessionService.start(options)
	assert(not started, "Hero session service already started")
	assert(type(options) == "table" and type(options.requestSpawn) == "function", "Hero session needs a server spawn requester")
	assert(options.lobbySpawn and options.tutorialSpawn and options.lobbyBounds, "Hero session needs lobby and tutorial destinations")
	settings, started = options, true
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then remotes = Instance.new("Folder"); remotes.Name = "Remotes"; remotes.Parent = ReplicatedStorage end
	assert(remotes:IsA("Folder"), "Remotes must be a Folder")
	local function remote(name)
		local result = remotes:FindFirstChild(name)
		if not result then result = Instance.new("RemoteEvent"); result.Name = name; result.Parent = remotes end
		assert(result:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
		return result
	end
	stateRemote = remote("K0HeroState")
	remote("K0HeroRequest").OnServerEvent:Connect(handleRequest)
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(unbindPlayer)
	for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
	local elapsed = 0
	RunService.Heartbeat:Connect(function(delta)
		elapsed = elapsed + delta
		if elapsed < 0.15 then return end
		elapsed = 0
		for player, state in pairs(sessions) do
			local hero = selectedHero(state)
			local character = state.character
			if hero and not hero.practice.moved and state.practiceOrigin and HeroSessionService.getCombatContext(player, character) then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root and (root.Position - state.practiceOrigin).Magnitude >= 6 then
					hero.practice.moved = true
					changed(state)
				end
			end
		end
	end)
end

return HeroSessionService
