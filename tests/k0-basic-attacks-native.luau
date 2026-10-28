-- Isolated Roblox engine test of the actual CombatService local functions and
-- original RemoteEvent/Heartbeat callbacks. The only source transformation is
-- the final return, exposing private state and a server resolver for fixtures.
-- No real player, RemoteEvent transport, client animation or network is tested.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "Basic attack QA requires an empty isolated local place")
assert(not workspace:FindFirstChild("K0BasicAttackQaFixture"), "Basic attack QA fixture already exists")
local production = assert(ServerScriptService:FindFirstChild("Server"))
production = assert(production:FindFirstChild("Combat")):FindFirstChild("CombatService")
assert(production, "K0 CombatService missing")
local report = { kind = "K0_BASIC_ATTACK_NATIVE", checks = 0, cases = {}, failures = {},
	coverage = "Actual server service/callback code, identity mocks, native rig/physics, synthetic clock; no transport, real player or client animation" }
local api, privateModule, fixture, characters, enemies, startedRun
local origin = Vector3.new(20000, 1000, 20000)
local nextId = 0

local function equal(actual, expected, label)
	report.checks += 1
	assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function near(actual, expected, label)
	report.checks += 1
	assert(math.abs(actual - expected) < 0.000001, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function waitFor(predicate, label)
	local deadline = os.clock() + 3
	while not predicate() and os.clock() < deadline do task.wait() end
	assert(predicate(), "Timed out: " .. label)
end
local function reset()
	if api then
		for _, state in pairs(api.playerStates) do api.clearAction(state) end
		table.clear(api.playerStates)
		table.clear(api.enemyStates)
		table.clear(api.activePlayers)
		table.clear(api.playerClasses)
		api.setClock(0)
	end
	if characters then characters:ClearAllChildren() end
	if enemies then enemies:ClearAllChildren() end
	if fixture then
		local wall = fixture:FindFirstChild("Wall")
		if wall then wall:Destroy() end
	end
end
local function case(name, body)
	reset()
	local before = report.checks
	local ok, err = xpcall(body, debug.traceback)
	table.insert(report.cases, { id = name, pass = ok, checks = report.checks - before, error = not ok and tostring(err) or nil })
	if not ok then table.insert(report.failures, name .. ": " .. tostring(err)) end
end
local function rig(name, parent, position, direction)
	local model = Instance.new("Model")
	model.Name = name
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = CFrame.lookAt(position, position + direction)
	root.Anchored = true
	root.CanCollide = false
	root.Parent = model
	model.PrimaryPart = root
	local humanoid = Instance.new("Humanoid")
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.MaxHealth = 10000
	humanoid.Health = 10000
	humanoid.Parent = model
	model.Parent = parent
	return model, humanoid, root
end
local function spawnPlayer(player)
	local model = rig("MockCharacter", characters, origin, Vector3.new(0, 0, -1))
	model:SetAttribute("K0SpawnReady", true)
	if not player then
		nextId += 1
		player = { Parent = Players, UserId = -nextId }
	end
	player.Character = model
	api.activePlayers[player] = true
	api.setupCharacter(player, model)
	waitFor(function()
		local state = api.playerStates[player]
		return state and state.character == model
	end, "server character setup")
	return api.playerStates[player], player
end
local function spawnEnemy(distance)
	local model, humanoid, root = rig("Goblin", enemies, origin + Vector3.new(0, 0, -(distance or 3)), Vector3.new(0, 0, 1))
	local config = api.Config.Enemy.Goblin
	local state = { id = 1, model = model, humanoid = humanoid, root = root, kind = "Goblin", config = config,
		mode = "Idle", posture = config.posture, postureImmuneUntil = 0, lastPostureDamage = 0,
		lastPerfectResponse = -math.huge, pattern = 0, attackSeq = 0, pathToken = 0,
		pathPending = false, nextMoveAt = math.huge, nextPathAt = math.huge, reconsiderAt = math.huge,
		spawnPosition = root.Position, spawnPivot = model:GetPivot() }
	api.enemyStates[model] = state
	return state
end
local function action(state, name, time, direction, ...)
	api.setClock(time)
	api.remote(state.player, name, direction, ...)
end
local function sample(time)
	api.setClock(time)
	api.processCombatSamples(time)
end

local ok, fatal = xpcall(function()
	local original = production.Source
	local remoteExpression = assert(original:match("actionRemote%.OnServerEvent:Connect%((function.-\n\tend)%)\n\tRunService%.Heartbeat:Connect"), "remote callback boundary missing")
	local heartbeatExpression = assert(original:match("RunService%.Heartbeat:Connect%((function.-\n\tend)%)\nend%s+return CombatService%s*$"), "heartbeat callback boundary missing")
	local tail = "\nlocal qaRemote=" .. remoteExpression .. "\nlocal qaHeartbeat=" .. heartbeatExpression .. "\n" .. [[
return {
 Config=Config, playerStates=playerStates, enemyStates=enemyStates, activePlayers=activePlayers, playerClasses=playerClasses,
 setEnemyFolder=function(value) enemyFolder=value end,
 setClock=function(value) now=function() return value end end,
 injectResolver=function(value) classResolver=value end,
 setupCharacter=setupCharacter, resolveBaseClass=resolveBaseClass,
 clearAction=clearAction, processCombatSamples=processCombatSamples,
 start=CombatService.start, startAttack=startAttack, beginEnemyAttack=beginEnemyAttack,
 remote=qaRemote, heartbeat=qaHeartbeat
}
]]
	local instrumented, replacements = original:gsub("\nreturn CombatService%s*$", function() return tail end)
	assert(replacements == 1, "test may replace only final return")
	privateModule = Instance.new("ModuleScript")
	privateModule.Name = "K0BasicAttackQaPrivate"
	privateModule.Source = instrumented
	privateModule.Parent = production.Parent
	api = require(privateModule)
	fixture = Instance.new("Folder")
	fixture.Name = "K0BasicAttackQaFixture"
	fixture.Parent = workspace
	characters = Instance.new("Folder")
	characters.Name = "Characters"
	characters.Parent = fixture
	enemies = Instance.new("Folder")
	enemies.Name = "Enemies"
	enemies.Parent = fixture
	api.setEnemyFolder(enemies)
	if not RunService:IsRunning() then RunService:Run(); startedRun = true end

	case("production-default-and-forged-client-class", function()
		local state = spawnPlayer()
		local enemy = spawnEnemy()
		equal(state.baseClassId, "knight", "default server resolver")
		equal(state.character:GetAttribute("K0ClassId"), "knight", "replicated default class")
		equal(state.character:GetAttribute("K0AttackProfileId"), "knight.sword.basic", "replicated profile")
		state.character:SetAttribute("K0ClassId", "mage")
		state.character:SetAttribute("K0AttackProfileId", "mage.staff.basic")
		action(state, "Attack", 0, "mage")
		equal(state.attack, nil, "forged direction rejected")
		action(state, "Attack", 0, nil, "mage")
		equal(state.attack, nil, "extra class argument rejected")
		action(state, "Attack", 0)
		equal(state.attack.definition, api.Config.Attacks[1], "replicated claim cannot change Knight attack")
		sample(0.17)
		near(enemy.humanoid.Health, 9925, "Knight first hit remains 75")
	end)

	for _, classId in { "dwarf", "mage" } do
		case(classId .. "-melee-hit-deduplicate-and-buffer", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			local profile = api.Config.BasicAttackProfiles[classId]
			equal(state.baseClassId, classId, "server injected class")
			equal(state.character:GetAttribute("K0AttackProfileId"), profile.id, "profile replicated for visuals")
			equal(#profile.attacks, 1, "experimental single melee attack")
			state.counter = { bonus = 100, expires = 5 }
			local beforeCount = #fixture:GetDescendants()
			action(state, "Attack", 0)
			equal(state.character:GetAttribute("K0AttackSeq"), 1, "first attack sequence")
			sample(0.17)
			near(enemy.humanoid.Health, 9925, "melee hit and no Knight counter bonus")
			sample(0.20)
			near(enemy.humanoid.Health, 9925, "same window cannot hit twice")
			equal(#fixture:GetDescendants(), beforeCount, "melee does not create a projectile")
			action(state, "Attack", 0.301)
			equal(state.queued and state.queued.action, "Attack", "second attack buffers")
			action(state, "Attack", 0.433333333)
			equal(state.character:GetAttribute("K0AttackSeq"), 2, "valid buffer executes once")
			equal(state.combo, 1, "single-hit profile loops at one")
		end)
		case(classId .. "-range-and-wall", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy(6)
			action(state, "Attack", 0)
			sample(0.17)
			near(enemy.humanoid.Health, 10000, "out of melee range")
			local wall = Instance.new("Part")
			wall.Name = "Wall"
			wall.Anchored = true
			wall.Size = Vector3.new(8, 8, 0.2)
			wall.Position = origin + Vector3.new(0, 0, -1.5)
			wall.Parent = fixture
			enemy.model:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, -3), origin + Vector3.new(0, 0, -2)))
			action(state, "Attack", 0.43)
			near(state.attack.started, 0.43, "second melee actually starts behind wall")
			sample(0.60)
			near(enemy.humanoid.Health, 10000, "solid wall blocks melee")
		end)
		case(classId .. "-missed-active-window", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			action(state, "Attack", 0)
			sample(0.27)
			near(enemy.humanoid.Health, 9925, "one delayed sample recovers skipped active window")
			sample(0.28)
			near(enemy.humanoid.Health, 9925, "recovery cannot hit twice")
		end)
		case(classId .. "-no-knight-guard", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			action(state, "BlockStart", 0)
			equal(state.mode, "Idle", "no Knight guard action")
			near(state.stamina, 100, "denied guard has no cost")
			state.mode = "Block" -- exercise defense fail-closed even for corrupt state
			state.guardStarted = 0.46
			api.beginEnemyAttack(enemy, state, 0)
			sample(0.61)
			near(state.humanoid.Health, 920, "forced guard cannot mitigate Goblin attack")
			equal(state.counter, nil, "no Knight counter is granted")
		end)
	end

	case("first-class-stays-fixed-across-respawn", function()
		api.injectResolver(function() return "dwarf" end)
		local first, player = spawnPlayer()
		api.injectResolver(function() return "mage" end)
		local second = spawnPlayer(player)
		equal(second.baseClassId, "dwarf", "respawn uses first server class")
		equal(second.character:GetAttribute("K0AttackProfileId"), "dwarf.axe.basic", "profile stays fixed")
		first.humanoid.Health = 0
		task.wait()
		equal(api.playerStates[player], second, "old death cannot replace new state")
	end)
	case("unsupported-class-fails-closed", function()
		api.injectResolver(function() return "elf" end)
		local player = { Parent = Players, UserId = -999 }
		api.activePlayers[player] = true
		equal(api.resolveBaseClass(player), nil, "unsupported server class denied")
		api.injectResolver(function() return "knight" end)
		equal(api.resolveBaseClass(player), nil, "failed first resolution is not replaced")
		equal(api.playerClasses[player], false, "failure is pinned for session")
	end)
	case("late-resolver-cannot-revive-departed-player", function()
		local gate = Instance.new("BindableEvent")
		local player = { Parent = Players, UserId = -1000 }
		api.activePlayers[player] = true
		api.injectResolver(function() gate.Event:Wait(); return "mage" end)
		local finished, result = false, nil
		task.spawn(function() result = api.resolveBaseClass(player); finished = true end)
		task.wait()
		api.activePlayers[player] = nil
		player.Parent = nil
		gate:Fire()
		waitFor(function() return finished end, "yielding resolver completion")
		equal(result, nil, "departed player has no class")
		equal(api.playerClasses[player], nil, "departed player cannot be recached")
		gate:Destroy()
	end)
	case("public-start-accepts-trusted-server-resolver", function()
		api.start(enemies, function() return "mage" end)
		local player = { Parent = Players, UserId = -1001 }
		api.activePlayers[player] = true
		equal(api.resolveBaseClass(player), "mage", "actual public start installs server resolver")
	end)
end, debug.traceback)
if not ok then table.insert(report.failures, "fixture: " .. tostring(fatal)) end
local cleanupOk, cleanupError = pcall(function()
	reset()
	if fixture then fixture:Destroy() end
	if privateModule then privateModule:Destroy() end
	if startedRun then RunService:Stop() end
end)
if not cleanupOk then table.insert(report.failures, "cleanup: " .. tostring(cleanupError)) end
report.pass = #report.failures == 0
print("K0_BASIC_ATTACK_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 basic attack native QA failed; see K0_BASIC_ATTACK_NATIVE")
