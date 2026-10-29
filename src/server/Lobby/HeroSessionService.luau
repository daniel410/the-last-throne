-- Owns playable life eligibility. Optional RPG account inventory persists roster
-- identity, hero growth, advancement and loadouts. Control practice is session-only.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Advanced=ReplicatedStorage.Shared and require(ReplicatedStorage.Shared.AdvancedSkills) or dofile("src/shared/AdvancedSkills.luau")
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
	local inventoryReady = settings.inventory == nil or settings.inventory.available(state.player)
	local heroes = {}
	for _, hero in ipairs(state.heroes) do
		table.insert(heroes, {
			heroId = hero.heroId, classId = hero.baseClassId,
			skillSlots = { table.unpack(hero.skillSlots) }, practiceAdvanced = hero.practiceAdvanced,
			practice = { moved = hero.practice.moved, attacked = hero.practice.attacked, dodged = hero.practice.dodged },
		})
	end
	return {
		revision = state.revision, phase = state.phase, heroes = heroes,
		selectedHeroId = state.selectedHeroId, activeHeroId = state.mode == "Tutorial" and state.selectedHeroId or nil,
		canManage = state.phase == "Lobby" and state.ready and state.profileReady and inventoryReady,
		canStart = state.phase == "Lobby" and state.ready and state.profileReady and inventoryReady and selectedHero(state) ~= nil,
		maxHeroes = MAX_HEROES, sessionOnly = true,
		inventoryMode = settings.inventory and state.player:GetAttribute("TLTInventoryMode") or nil,
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
	if not state.profileReady or settings.inventory and not settings.inventory.ready(state.player) then return false, "InventoryUnavailable" end
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
	if action == "SetSkillSlot" then return type(argument) == "string" and argument:match("^[1-5]:[0-3]$") ~= nil end
	if action == "PracticeAdvance" then return argument == nil end
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
			skillSlots = {1, 2, 3, 0, 0}, practiceAdvanced = false, skillReadyAt = {},
		}
		if settings.inventory then
			local errorCode = settings.inventory.createHero(state.player, hero.heroId, argument)
			if errorCode then return errorCode == "ClassAlreadyCreated" and errorCode or "InventoryUnavailable" end
		end
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
	elseif action == "SetSkillSlot" then
		if settings.inventory then return "UseHeroPanel" end
		local hero = selectedHero(state)
		if not hero then return "SelectHeroFirst" end
		local slot, skill = argument:match("^(%d):(%d)$")
		slot, skill = tonumber(slot), tonumber(skill)
		if slot > (hero.practiceAdvanced and 5 or 3) then return "InvalidRequest" end
		if skill > 0 then
			for index, equipped in ipairs(hero.skillSlots) do
				if index ~= slot and equipped == skill then hero.skillSlots[index] = hero.skillSlots[slot] end
			end
		end
		hero.skillSlots[slot] = skill
		changed(state)
	elseif action == "PracticeAdvance" then
		if settings.inventory then return "AdvancementRequired" end
		local hero = selectedHero(state)
		if not hero then return "SelectHeroFirst" end
		hero.practiceAdvanced = not hero.practiceAdvanced
		if not hero.practiceAdvanced then hero.skillSlots[4] = 0; hero.skillSlots[5] = 0 end
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
	if state.busy or settings.inventory and (not settings.inventory.available(player) or settings.inventory.busy(player)) then
		publish(state, requestId, "InventoryUnavailable"); return
	end
	state.busy = true
	local errorCode = execute(state, action, argument)
	state.busy = false
	-- A durable hero creation may yield; the per-player gate serializes it with
	-- inventory transfers and life changes. Repeated IDs replay the result.
	state.requests[requestId] = { action = action, argument = argument, errorCode = errorCode }
	table.insert(state.requestOrder, requestId)
	if #state.requestOrder > 32 then state.requests[table.remove(state.requestOrder, 1)] = nil end
	publish(state, requestId, errorCode)
end

local function bindPlayer(player)
	if sessions[player] or player.Parent ~= Players then return end
	local state = {
		player = player, heroes = {}, byId = {}, byClass = {}, mode = "Lobby", phase = "LoadingLobby",
		profileReady = settings.inventory == nil, busy = false,
		epoch = 0, generation = 0, transitionId = 0, ready = false, revision = 0,
		tokens = REQUEST_BURST, lastRefill = os.clock(), requests = {}, requestOrder = {}, lifeConnections = {},
	}
	sessions[player] = state
	player:SetAttribute("K0SessionPhase", state.phase)
	if settings.inventory then
		task.spawn(function()
			local roster, errorCode = settings.inventory.open(player)
			if not connected(state) then return end
			if roster then
				for id, stored in pairs(roster) do
					local hero = {heroId = id, baseClassId = stored.baseClassId, practice = {moved=false, attacked=false, dodged=false},
						skillSlots = {1,2,3,0,0}, practiceAdvanced = false, skillReadyAt = {}}
					state.byId[id], state.byClass[hero.baseClassId] = hero, hero
					table.insert(state.heroes, hero)
				end
				table.sort(state.heroes, function(a,b) return a.heroId < b.heroId end)
				state.selectedHeroId = state.heroes[1] and state.heroes[1].heroId
				state.profileReady = true
			end
			changed(state)
			if errorCode then publish(state, nil, "InventoryUnavailable") end
		end)
	end
end

local function unbindPlayer(player)
	local state = sessions[player]
	if not state then return end
	invalidateLife(state)
	if settings.inventory then settings.inventory.close(player) end
	sessions[player] = nil
end

function HeroSessionService.refresh(player)
	local state=sessions[player]
	if state then changed(state) end
end

function HeroSessionService.isBusy(player)
	local state = sessions[player]
	return state == nil or state.busy
end

function HeroSessionService.getInventoryContext(player)
	local state = sessions[player]
	local hero = state and selectedHero(state)
	if not state or not hero or not state.ready or not validLife(state, state.character) then return nil end
	local human = state.character:FindFirstChildOfClass("Humanoid")
	local root = state.character:FindFirstChild("HumanoidRootPart")
	if not human or human.Health <= 0 or not root then return nil end
	local delta = root.Position - settings.lobbyBounds.center
	local half = settings.lobbyBounds.size / 2
	local atHub = state.phase == "Lobby" and state.mode == "Lobby" and finite(delta.X) and finite(delta.Y) and finite(delta.Z)
		and math.abs(delta.X) <= half.X and math.abs(delta.Y) <= half.Y and math.abs(delta.Z) <= half.Z
	return {heroId = hero.heroId, classId = hero.baseClassId, generation = state.generation, atHub = atHub}
end

-- Server bootstrap dependency. Snapshot tables are copies, never mutable roster
-- entries. Combat must use getCombatContext rather than replicated Attributes.
function HeroSessionService.getActiveHero(player)
	local state = sessions[player]
	local hero = state and selectedHero(state)
	if not hero or not connected(state) then return nil end
	return { heroId = hero.heroId, classId = hero.baseClassId,
			skillSlots = { table.unpack(hero.skillSlots) }, practiceAdvanced = hero.practiceAdvanced, epoch = state.epoch }
end

function HeroSessionService.getCombatContext(player, character)
	local state = sessions[player]
	if not state or state.mode ~= "Tutorial" or state.phase ~= "Tutorial" or not validLife(state, character) then return nil end
	local hero = selectedHero(state)
	local human = character:FindFirstChildOfClass("Humanoid")
	if not hero or not human or human.Health <= 0 then return nil end
	if settings.inventory and not settings.inventory.available(player) then return nil end
	local growth = settings.inventory and settings.inventory.growth(player,hero.heroId)
	local ready = {}
	for id, time in pairs(hero.skillReadyAt) do ready[id] = time end
	local equipment = settings.inventory and settings.inventory.stats(player, hero.heroId)
	local itemCounts, itemSlots
	if settings.inventory then itemCounts, itemSlots = settings.inventory.counts(player, hero.heroId) end
	return { heroId = hero.heroId, baseClassId = hero.baseClassId, epoch = state.epoch, characterGeneration = state.generation,
		growth = growth, equipment = equipment, itemCounts = itemCounts, itemSlots = itemSlots, inventoryManaged = settings.inventory ~= nil,
		inventoryLocked = settings.inventory and settings.inventory.busy(player) or false,
		skillSlots = { table.unpack(growth and growth.skillSlots or hero.skillSlots) }, slotCount = growth and Advanced.slotCount(growth) or (hero.practiceAdvanced and 5 or 3), skillReadyAt = ready,
		setSkillReadyAt = function(id, time) hero.skillReadyAt[id] = time end }
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
