-- Deterministic lifecycle simulation. Run: lua tests/k0-spawn.spec.lua
-- Roblox engine placement, physics and networking still require Studio tests.
if game ~= nil then
	-- The test is not a runtime module; keep accidental Studio require inert.
	return {}
end
local tick = 0
local queue = {}
local originalClock = os.clock
os.clock = function() return tick end

local function schedule(delay, fn, ...)
	local args = { ... }
	local thread = coroutine.create(function() fn(table.unpack(args)) end)
	table.insert(queue, { at = tick + delay, thread = thread })
end

task = {}
function task.spawn(fn, ...) schedule(0, fn, ...) end
function task.delay(seconds, fn, ...) schedule(seconds, fn, ...) end
function task.wait(seconds) return coroutine.yield(seconds or 0.01) end

local function runFor(seconds)
	local untilTime = tick + seconds
	while true do
		local nextIndex, nextTime
		for index, item in ipairs(queue) do
			if item.at <= untilTime and (not nextTime or item.at < nextTime) then
				nextIndex, nextTime = index, item.at
			end
		end
		if not nextIndex then break end
		local item = table.remove(queue, nextIndex)
		tick = nextTime
		local ok, delay = coroutine.resume(item.thread)
		assert(ok, tostring(delay))
		if coroutine.status(item.thread) ~= "dead" then
			table.insert(queue, { at = tick + math.max(delay or 0, 0.001), thread = item.thread })
		end
	end
	tick = untilTime
end

local function signal()
	local event = { listeners = {} }
	function event:Connect(fn)
		local listener = { fn = fn, active = true }
		table.insert(self.listeners, listener)
		return { Disconnect = function() listener.active = false end }
	end
	function event:Fire(...)
		for _, listener in ipairs(self.listeners) do
			if listener.active then task.spawn(listener.fn, ...) end
		end
	end
	function event:Wait() return task.wait(1 / 60) end
	return event
end

local vector = {}
vector.__index = function(value, key)
	if key == "Magnitude" then return math.sqrt(value.X ^ 2 + value.Y ^ 2 + value.Z ^ 2) end
end
vector.__add = function(a, b) return setmetatable({ X = a.X + b.X, Y = a.Y + b.Y, Z = a.Z + b.Z }, vector) end
vector.__sub = function(a, b) return setmetatable({ X = a.X - b.X, Y = a.Y - b.Y, Z = a.Z - b.Z }, vector) end
Vector3 = { new = function(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, vector) end }
Vector3.zero = Vector3.new(0, 0, 0)

local workspace = {}
local players = { CharacterAutoLoads = false, PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function players:GetPlayers() return self.list end
local runService = { Heartbeat = signal() }
game = {}
function game:GetService(name)
	return ({ Players = players, Workspace = workspace, RunService = runService })[name]
end
warn = function() end
local spawn = { Position = Vector3.new(-20, 0.1, 56), Size = Vector3.new(8, 0.2, 8), Enabled = true }
function spawn:IsA(name) return name == "SpawnLocation" end
function spawn:IsDescendantOf(parent) return parent == workspace end

local function humanoid()
	local result = { Health = 100, HipHeight = 2, Died = signal() }
	function result:IsA(name) return name == "Humanoid" end
	return result
end

local function character(humanDelay)
	local root = { Position = Vector3.new(0, 3, 0), Size = Vector3.new(2, 2, 1), Parent = true }
	function root:IsA(name) return name == "BasePart" end
	function root:SetNetworkOwner() end
	function root:SetNetworkOwnershipAuto() end
	local result = { root = root, ChildAdded = signal(), attributes = {} }
	function result:FindFirstChild(name) return name == "HumanoidRootPart" and self.root or nil end
	function result:FindFirstChildOfClass(name) return name == "Humanoid" and self.human or nil end
	function result:SetAttribute(name, value) self.attributes[name] = value end
	function result:GetAttribute(name) return self.attributes[name] end
	function result:IsDescendantOf(parent) return self.Parent == parent end
	function result:GetPivot() return self.root.Position end
	function result:PivotTo(position) self.root.Position = position end
	if humanDelay then
		task.delay(humanDelay, function()
			result.human = humanoid()
			result.ChildAdded:Fire(result.human)
		end)
	else
		result.human = humanoid()
	end
	return result
end

local function player(name, options)
	options = options or {}
	local result = {
		Name = name, Parent = players, CharacterAdded = signal(), CharacterRemoving = signal(),
		CharacterAppearanceLoaded = signal(), attributes = {}, loads = 0, failures = options.failures or 0,
		lateHuman = options.lateHuman, noPlacement = options.noPlacement,
		loadDelay = options.loadDelay or 0.20, appearanceDelay = options.appearanceDelay or 0.10,
	}
	function result:SetAttribute(key, value) self.attributes[key] = value end
	function result:HasAppearanceLoaded() return true end
	function result:LoadCharacterAsync()
		self.loads = self.loads + 1
		if self.failures > 0 then self.failures = self.failures - 1 error("injected load failure") end
		if self.Character then self.CharacterRemoving:Fire(self.Character) end
		local newCharacter = character(self.lateHuman)
		self.Character = newCharacter
		self.CharacterAdded:Fire(newCharacter)
		task.delay(self.appearanceDelay, function() self.CharacterAppearanceLoaded:Fire(newCharacter) end)
		task.delay(0.15, function()
			newCharacter.Parent = workspace
			if not self.noPlacement then newCharacter.root.Position = spawn.Position + Vector3.new(0, 3, 0) end
		end)
		task.wait(self.loadDelay)
	end
	return result
end

local function check(condition, message)
	assert(condition, message)
end
local first = player("First")
local second = player("Second", { lateHuman = 0.8 })
local third = player("Third", { failures = 1 })
local fourth = player("Fourth", { noPlacement = true })
players.list = { first, second, third, fourth }
local SpawnService = dofile("src/server/Spawn/SpawnService.luau")
local readyEvents = {}
local endEvents = {}
SpawnService.start(spawn, {
	onReady = function(person, actor, generation, requestId)
		table.insert(readyEvents, { player = person, actor = actor, generation = generation, requestId = requestId })
	end,
	onLifeEnded = function(person, actor, generation, requestId, reason)
		table.insert(endEvents, { player = person, actor = actor, generation = generation, requestId = requestId, reason = reason })
	end,
})
players.PlayerAdded:Fire(first) -- join enumeration race must not load twice
runFor(0.18)
check(first.loads == 1 and first.Character:GetAttribute("K0SpawnReady") == false, "character must wait for complete loading")
check(second.Character.human == nil and second.Character:GetAttribute("K0SpawnReady") == false, "late Humanoid must not be marked ready")
runFor(4)
for _, person in ipairs(players.list) do
	check(person.RespawnLocation == spawn, person.Name .. " must use the designated spawn")
	check(person.Character and person.Character:GetAttribute("K0SpawnReady") == true, person.Name .. " must eventually be ready")
	local delta = person.Character.root.Position - spawn.Position
	check(Vector3.new(delta.X, 0, delta.Z).Magnitude <= 14, person.Name .. " must be at the safe spawn")
end
check(first.loads == 1, "existing join must create only one character")
check(third.loads == 2, "failed character load must retry")
check(fourth.Character.root.Position.Z == 56, "misplaced character must be rescued")

local old = first.Character
old.human.Health = 0
old.human.Died:Fire()
old.human.Died:Fire()
runFor(4.9)
check(first.loads == 1, "respawn must respect the delay")
runFor(1)
check(first.loads == 2 and first.Character ~= old and first.Character:GetAttribute("K0SpawnReady"), "death must produce one ready life")
old.human.Died:Fire()
runFor(6)
check(first.loads == 2, "stale death must not replace the new life")

local leaving = player("Leaving", { failures = 1 })
table.insert(players.list, leaving)
players.PlayerAdded:Fire(leaving)
runFor(0.2)
check(leaving.loads == 1, "leaving-player test must start one load")
players.PlayerRemoving:Fire(leaving)
leaving.Parent = nil
runFor(10)
check(leaving.loads == 1, "departed player must not retry")

-- A permanently failing API must keep exponential backoff rather than spin.
local failing = player("PermanentFailure", { failures = 10000 })
table.insert(players.list, failing)
players.PlayerAdded:Fire(failing)
runFor(21)
check(failing.loads >= 3 and failing.loads <= 5, "persistent failure must stay bounded by backoff")
players.PlayerRemoving:Fire(failing)
failing.Parent = nil

local tutorialSpawn = { Position = Vector3.new(50, 0.1, -50), Size = spawn.Size, Enabled = true }
function tutorialSpawn:IsA(name) return name == "SpawnLocation" end
function tutorialSpawn:IsDescendantOf(parent) return parent == workspace end
local swapping = player("Swapping", { loadDelay = 1.5, appearanceDelay = 1.4 })
table.insert(players.list, swapping)
players.PlayerAdded:Fire(swapping)
runFor(0.1)
local loadingOld = swapping.Character
check(swapping.loads == 1 and not loadingOld:GetAttribute("K0SpawnReady"), "race fixture has an in-flight initial load")
check(SpawnService.requestSpawn(swapping, tutorialSpawn, 1), "server accepts tutorial destination")
runFor(0.1)
check(SpawnService.requestSpawn(swapping, spawn, 2), "newer return supersedes an in-flight tutorial request")
runFor(5)
check(swapping.loads == 2 and swapping.Character ~= loadingOld, "coalesced route change creates exactly one latest life")
check(swapping.RespawnLocation == spawn and swapping.Character:GetAttribute("K0SpawnReady"), "latest lobby destination owns readiness")
local swapReadyCount = 0
for _, event in ipairs(readyEvents) do
	if event.player == swapping then
		swapReadyCount = swapReadyCount + 1
		check(event.requestId == 2, "stale initial/tutorial loads never publish readiness")
	end
end
check(swapReadyCount == 1, "only the newest life becomes ready")
local loadedLobby = swapping.Character
check(SpawnService.requestSpawn(swapping, tutorialSpawn, 3), "a ready player may start a fresh tutorial life")
check(not loadedLobby:GetAttribute("K0SpawnReady"), "old live character is revoked synchronously")
runFor(5)
check(swapping.loads == 3 and swapping.Character ~= loadedLobby, "destination change replaces a live Character")
check(swapping.RespawnLocation == tutorialSpawn and swapping.Character:GetAttribute("K0SpawnReady"), "tutorial life is ready at tutorial destination")
check((swapping.Character.root.Position - tutorialSpawn.Position).Magnitude <= 14, "per-player rescue uses requested destination")
check(first.RespawnLocation == spawn, "one player's route change never changes another player's spawn")
check(not SpawnService.requestSpawn(swapping, spawn, 3), "duplicate generation cannot reload another life")
check(not SpawnService.requestSpawn(swapping, spawn, 2), "older generation cannot reverse a completed route")
local tutorialLife = swapping.Character
tutorialLife.human.Health = 0
tutorialLife.human.Died:Fire()
runFor(9)
check(swapping.loads == 4 and swapping.Character:GetAttribute("K0SpawnReady"), "automatic respawn keeps tutorial route with a new life")
check(SpawnService.requestSpawn(swapping, spawn, 4), "return after death requests a new lobby life")
runFor(5)
local finalLife = swapping.Character
tutorialLife.human.Died:Fire()
runFor(7)
check(swapping.loads == 5 and swapping.Character == finalLife and finalLife:GetAttribute("K0SpawnReady"), "stale death cannot replace returned lobby life")
players.PlayerRemoving:Fire(swapping)
swapping.Parent = nil
os.clock = originalClock
print("K0 spawn lifecycle: 4 players, retry/backoff, late Humanoid, per-player routes, load races, stale lives, respawn and leave passed")
