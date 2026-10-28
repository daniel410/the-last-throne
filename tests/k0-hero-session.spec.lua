-- Actual HeroSessionService with deterministic identity/life fixtures.
-- Run: lua tests/k0-hero-session.spec.lua. Native rigs/UI remain separate QA.
if game ~= nil then return {} end
local clock = 0
local savedClock = os.clock
os.clock = function() return clock end
local function signal()
	local event = { listeners = {} }
	function event:Connect(fn)
		local item = { fn = fn, active = true }
		table.insert(self.listeners, item)
		return { Disconnect = function() item.active = false end }
	end
	function event:Fire(...)
		for _, item in ipairs(self.listeners) do if item.active then item.fn(...) end end
	end
	return event
end
local vector = {}
vector.__index = function(v, key)
	if key == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) end
end
Vector3 = { new = function(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, vector) end }
vector.__sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
vector.__div = function(a, b) return Vector3.new(a.X / b, a.Y / b, a.Z / b) end
local function container(kind)
	local result = { kind = kind, children = {} }
	function result:IsA(name) return self.kind == name end
	function result:FindFirstChild(name)
		for _, child in ipairs(self.children) do if child.Name == name then return child end end
	end
	return setmetatable(result, { __newindex = function(t, key, value)
		rawset(t, key, value)
		if key == "Parent" and value and value.children then table.insert(value.children, t) end
	end })
end
Instance = { new = function(kind)
	local result = container(kind)
	if kind == "RemoteEvent" then
		result.OnServerEvent = signal()
		function result:FireClient(player, value, requestId, errorCode)
			player.response = { snapshot = value, requestId = requestId, errorCode = errorCode }
		end
	end
	return result
end }
workspace = {}
local players = { PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function players:GetPlayers() return self.list end
local replicated = container("ReplicatedStorage")
local runService = { Heartbeat = signal() }
local guid = 0
local http = {}
function http:GenerateGUID() guid = guid + 1; return "server-hero-" .. guid end
game = { GetService = function(_, name)
	return ({ Players = players, ReplicatedStorage = replicated, HttpService = http, RunService = runService })[name]
end }
local function player(name)
	local result = { Name = name, Parent = players, attributes = {} }
	function result:SetAttribute(key, value) self.attributes[key] = value end
	return result
end
local function character(position)
	local human = { Health = 100 }
	local root = { Position = position }
	function root:IsA(name) return name == "BasePart" end
	local result = { attributes = {}, signals = {} }
	function result:SetAttribute(key, value)
		self.attributes[key] = value
		if self.signals[key] then self.signals[key]:Fire() end
	end
	function result:GetAttribute(key) return self.attributes[key] end
	function result:GetAttributeChangedSignal(key)
		self.signals[key] = self.signals[key] or signal()
		return self.signals[key]
	end
	function result:IsDescendantOf(parent) return parent == workspace end
	function result:FindFirstChild(name) return name == "HumanoidRootPart" and root or nil end
	function result:FindFirstChildOfClass(name) return name == "Humanoid" and human or nil end
	return result
end
local first, other = player("First"), player("Other")
players.list = { first, other }
local lobbySpawn, tutorialSpawn = {}, {}
local spawnRequests = {}
local spawnAvailable = true
local Service = dofile("src/server/Lobby/HeroSessionService.luau")
Service.start({
	lobbySpawn = lobbySpawn, tutorialSpawn = tutorialSpawn,
	lobbyBounds = { center = Vector3.new(0, 96, 512), size = Vector3.new(160, 40, 160) },
	requestSpawn = function(person, destination, requestId)
		table.insert(spawnRequests, { player = person, destination = destination, id = requestId })
		return spawnAvailable
	end,
})
local remote = replicated:FindFirstChild("Remotes"):FindFirstChild("K0HeroRequest")
local checks = 0
local function check(value, message) checks = checks + 1; assert(value, message) end
local requestCounter = 0
local function request(person, action, argument, requestId, ...)
	clock = clock + 0.3
	requestCounter = requestCounter + 1
	remote.OnServerEvent:Fire(person, action, requestId or "test-" .. requestCounter, argument, ...)
	return person.response.snapshot, person.response.errorCode
end
local function ready(person, requestId, generation, position)
	local actor = character(position or Vector3.new(0, 99, 536))
	person.Character = actor
	Service.onLifeStarted(person, actor, generation, requestId)
	actor:SetAttribute("K0SpawnReady", true)
	Service.onReady(person, actor, generation, requestId)
	return actor
end
local value = request(first, "GetState")
check(value.phase == "LoadingLobby" and #value.heroes == 0 and value.sessionOnly, "join starts in empty session lobby")
check(Service.getActiveHero(first) == nil and Service.getCombatContext(first, nil) == nil, "no automatic Knight or combat context")
local initial = ready(first, 0, 1)
ready(other, 0, 1)
local _, errorCode = request(other, "StartTutorial")
check(errorCode == "SelectHeroFirst", "selection is required before tutorial")
local heroes = {}
for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
	value, errorCode = request(first, "CreateHero", classId, "create-" .. classId)
	check(errorCode == nil and #value.heroes <= 4, classId .. " hero creation succeeds")
	local hero = value.heroes[#value.heroes]
	heroes[classId] = hero.heroId
	check(hero.classId == classId and Service.getActiveHero(first).classId == classId, "class is attached to server hero identity")
end
value, errorCode = request(first, "CreateHero", "knight", "create-knight")
check(errorCode == nil and #value.heroes == 4 and guid == 4, "duplicate request replays successful result without fifth hero")
_, errorCode = request(first, "CreateHero", "mage", "create-knight")
check(errorCode == "RequestConflict", "changed duplicate request is rejected")
_, errorCode = request(first, "CreateHero", "knight")
check(errorCode == "ClassAlreadyCreated" and guid == 4, "new request cannot duplicate a class")
_, errorCode = request(other, "SelectHero", heroes.knight)
check(errorCode == "HeroNotOwned", "another player's hero cannot be selected")
_, errorCode = request(first, "CreateHero", { classId = "priest" })
check(errorCode == "InvalidRequest", "table and unsupported class claims are rejected")
_, errorCode = request(first, "CreateHero", "priest")
check(errorCode == "InvalidRequest", "non-player class is rejected")
_, errorCode = request(first, "StartTutorial", nil, nil, "forged")
check(errorCode == "InvalidRequest", "extra payload fields are rejected")
initial:FindFirstChild("HumanoidRootPart").Position = Vector3.new(78, 99, 440)
_, errorCode = request(first, "SelectHero", heroes.knight)
check(errorCode == nil, "hero management works away from spawn across the lobby platform")
initial:FindFirstChild("HumanoidRootPart").Position = Vector3.new(81, 99, 512)
_, errorCode = request(first, "StartTutorial")
check(errorCode == "ReturnToPlatform" and #spawnRequests == 0, "outside platform cannot start tutorial")
initial:FindFirstChild("HumanoidRootPart").Position = Vector3.new(0, 130, 512)
_, errorCode = request(first, "SelectHero", heroes.mage)
check(errorCode == "ReturnToPlatform", "vertical out-of-bounds is rejected")
initial:FindFirstChild("HumanoidRootPart").Position = Vector3.new(0 / 0, 99, 512)
_, errorCode = request(first, "CreateHero", "mage")
check(errorCode == "ReturnToPlatform", "nonfinite position cannot manage heroes")
initial:FindFirstChild("HumanoidRootPart").Position = Vector3.new(0, 99, 536)

local previousContext
local generation = 1
for classIndex, classId in ipairs({ "knight", "dwarf", "mage", "elf" }) do
	value, errorCode = request(first, "SelectHero", heroes[classId])
	check(errorCode == nil and Service.getCombatContext(first, first.Character) == nil, "lobby selection never enables combat")
	local selectedCopy = Service.getActiveHero(first)
	selectedCopy.classId = "forged"
	check(Service.getActiveHero(first).classId == classId, "snapshot mutation cannot change immutable class")
	value, errorCode = request(first, "StartTutorial")
	check(errorCode == nil and value.phase == "LoadingTutorial" and Service.getCombatContext(first, first.Character) == nil, "tutorial closes old life before async load")
	local load = spawnRequests[#spawnRequests]
	check(load.destination == tutorialSpawn, "tutorial uses server destination")
	generation = generation + 1
	local actor = ready(first, load.id, generation, Vector3.new(-20, 4, 56))
	local context = Service.getCombatContext(first, actor)
	check(context and context.heroId == heroes[classId] and context.baseClassId == classId and context.characterGeneration == generation, "same player can play " .. classId .. " using its own identity")
	check(not previousContext or context.epoch > previousContext.epoch, "hero life epoch increases")
	previousContext = context
	_, errorCode = request(first, "SelectHero", heroes.mage)
	check(errorCode == "WaitForLobby" and Service.getCombatContext(first, actor).baseClassId == classId, "in-combat selection cannot change class")
	actor:FindFirstChild("HumanoidRootPart").Position = Vector3.new(-12, 4, 56)
	runService.Heartbeat:Fire(0.2)
	actor:SetAttribute("K0AttackSeq", 1)
	actor:SetAttribute("K0State", "Dodge")
	value = request(first, "GetState")
	local practiced
	for _, hero in ipairs(value.heroes) do if hero.heroId == heroes[classId] then practiced = hero.practice end end
	check(practiced.moved and practiced.attacked and practiced.dodged, "tutorial observes server movement and accepted combat actions")
	value = request(first, "ReturnLobby", nil, "return-" .. classId)
	check(Service.getCombatContext(first, actor) == nil and value.phase == "ReturningLobby", "return revokes combat synchronously")
	local returnRequest = spawnRequests[#spawnRequests]
	check(returnRequest.destination == lobbySpawn, "return uses server lobby destination")
	Service.onReady(first, actor, generation, load.id)
	check(Service.getCombatContext(first, actor) == nil, "late old ready callback cannot reactivate tutorial")
	generation = generation + 1
	ready(first, returnRequest.id, generation)
	value, errorCode = request(first, "ReturnLobby", nil, "return-" .. classId)
	check(errorCode == nil and value.phase == "Lobby", "replayed return does not create another life")
end

request(first, "SelectHero", heroes.knight)
request(first, "StartTutorial")
local load = spawnRequests[#spawnRequests]
generation = generation + 1
local life = ready(first, load.id, generation, Vector3.new(-20, 4, 56))
local beforeDeath = Service.getCombatContext(first, life)
Service.onLifeEnded(first, life, generation, load.id, "Died")
check(Service.getCombatContext(first, life) == nil, "death immediately revokes old context")
generation = generation + 1
local respawned = ready(first, load.id, generation, Vector3.new(-20, 4, 56))
local afterDeath = Service.getCombatContext(first, respawned)
check(afterDeath.epoch > beforeDeath.epoch and afterDeath.characterGeneration > beforeDeath.characterGeneration, "respawn is a distinct context")
Service.onLifeEnded(first, life, generation - 1, load.id, "Removing")
check(Service.getCombatContext(first, respawned) ~= nil, "late old removal cannot revoke current life")
request(first, "ReturnLobby")
local returnLoad = spawnRequests[#spawnRequests]
generation = generation + 1
ready(first, returnLoad.id, generation)
spawnAvailable = false
value, errorCode = request(first, "StartTutorial")
check(errorCode == "SpawnUnavailable" and value.phase == "SpawnFailed" and Service.getCombatContext(first, first.Character) == nil, "failed spawn never enables old life")
spawnAvailable = true
request(first, "ReturnLobby")
local recovery = spawnRequests[#spawnRequests]
generation = generation + 1
ready(first, recovery.id, generation)
check(first.response.snapshot.phase == "Lobby", "failed transition can recover to lobby")
for index = 1, 30 do remote.OnServerEvent:Fire(first, "CreateHero", "spam-" .. index, "knight") end
check(first.response.errorCode == "TooFast" and guid == 4, "burst requests are bounded without extra heroes")
players.PlayerRemoving:Fire(first)
first.Parent = nil
check(Service.getActiveHero(first) == nil and Service.getCombatContext(first, first.Character) == nil, "leaving discards prototype roster and context")
os.clock = savedClock
print("Hero session: " .. checks .. " identity, ownership, transitions, four-class, stale-life and boundary checks passed")
