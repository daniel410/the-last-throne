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
		table.clear(api.heroClasses)
		table.clear(api.pendingCharacters)
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
local function spawnEnemy(distance, kind)
	kind = kind or "Goblin"
	local model, humanoid, root = rig(kind, enemies, origin + Vector3.new(0, 0, -(distance or 3)), Vector3.new(0, 0, 1))
	local config = api.Config.Enemy[kind]
	local state = { id = 1, model = model, humanoid = humanoid, root = root, kind = kind, config = config,
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
 Config=Config, playerStates=playerStates, enemyStates=enemyStates, activePlayers=activePlayers, heroClasses=heroClasses, pendingCharacters=pendingCharacters,
 setEnemyFolder=function(value) enemyFolder=value end,
 setClock=function(value) now=function() return value end end,
 injectResolver=function(value)
   contextResolver=function(player, character)
     local resolved=value(player, character)
     if type(resolved)=="string" then
       return { heroId="hero-" .. player.UserId, baseClassId=resolved, epoch=1, characterGeneration=1 }
     end
     return resolved
   end
 end,
 setupCharacter=setupCharacter, readCombatContext=readCombatContext,
 clearAction=clearAction, processCombatSamples=processCombatSamples, stepPlayer=stepPlayer,
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

	case("server-selected-knight-and-forged-client-class", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy()
		equal(state.baseClassId, "knight", "server resolver class")
		equal(state.character:GetAttribute("K0ClassId"), "knight", "replicated class")
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

	case("knight-can-hit-low-slime-once", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3, "Slime")
		local target = origin + Vector3.new(0, -1.6, -3)
		enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
		action(state, "Attack", 0)
		sample(0.17)
		near(enemy.humanoid.Health, 9925, "a low Slime receives the server-authoritative sword hit")
		sample(0.20)
		near(enemy.humanoid.Health, 9925, "the same sword window cannot hit Slime twice")
	end)
	case("slime-melee-is-server-authoritative", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3, "Slime")
		local target = origin + Vector3.new(0, -1.6, -3)
		enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
		api.beginEnemyAttack(enemy, state, 0)
		sample(0.81)
		near(state.humanoid.Health, 960, "Slime deals its configured 40 server damage")
		sample(0.85)
		near(state.humanoid.Health, 960, "Slime cannot damage the player twice in one attack")
	end)
	case("mage-arcane-is-server-owned-and-cooldown-limited", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(20)
		action(state, "CastArcane", 0)
		equal(state.character:GetAttribute("K0AttackKind"), "Arcane", "Mage enters replicated cast pose")
		near(state.stamina, 85, "server charges the configured stamina cost")
		sample(0.46)
		near(enemy.humanoid.Health, 9900, "server resolves Arcane Bolt damage")
		equal(type(state.character:GetAttribute("K0SpellVisual")), "string", "server publishes spell visual snapshot")
		sample(0.50)
		near(enemy.humanoid.Health, 9900, "one spell cannot hit the same enemy twice")
		action(state, "CastArcane", 1.1)
		equal(state.character:GetAttribute("K0Feedback"), "SkillCooling", "early recast reports cooldown")
		equal(state.spellSeq, 1, "early recast emits no new spell")
		action(state, "CastArcane", 3.01)
		equal(state.character:GetAttribute("K0AttackKind"), "Arcane", "spell can be cast after cooldown")
	end)
	case("arcane-denies-other-classes-and-wall-damage", function()
		api.injectResolver(function() return "knight" end)
		local knight = spawnPlayer()
		action(knight, "CastArcane", 0)
		equal(knight.attack, nil, "non-Mage cannot request Arcane Bolt")
		near(knight.stamina, 100, "denied cast spends no stamina")
		reset()
		api.injectResolver(function() return "mage" end)
		local mage = spawnPlayer()
		local enemy = spawnEnemy(20)
		local wall = Instance.new("Part")
		wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(mage, "CastArcane", 0)
		sample(0.46)
		near(enemy.humanoid.Health, 10000, "wall blocks server Arcane Bolt damage")
	end)


	case("targeted-elf-shot-prefers-clicked-enemy", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local decoy = spawnEnemy(5)
		local selected = spawnEnemy(8, "Orc")
		selected.root.CFrame = CFrame.new(origin + Vector3.new(8, 0, 0))
		action(state, "Attack", 0, nil, selected.model)
		sample(0.23)
		near(selected.humanoid.Health, 9930, "server hits explicitly selected side target")
		near(decoy.humanoid.Health, 10000, "selected shot does not hit the nearer forward target")
	end)
	case("targeted-mage-checks-wall-range-and-forgery", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local target = spawnEnemy(20)
		local fake = Instance.new("Model"); fake.Parent = fixture
		action(state, "CastArcane", 0, nil, fake)
		equal(state.attack, nil, "unregistered target is rejected")
		fake:Destroy()
		local wall = Instance.new("Part"); wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(state, "CastArcane", 0, nil, target.model)
		sample(0.46)
		near(target.humanoid.Health, 10000, "selected enemy behind wall takes no damage")
		equal(state.character:GetAttribute("K0Feedback"), "TargetBlocked", "blocked target is explained")
		reset(); api.injectResolver(function() return "mage" end)
		state = spawnPlayer(); target = spawnEnemy(45)
		action(state, "CastArcane", 0, nil, target.model); sample(0.46)
		near(target.humanoid.Health, 10000, "selected enemy outside server range takes no damage")
	end)
	case("dead-selected-target-does-not-retarget", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local other, selected = spawnEnemy(5), spawnEnemy(8)
		action(state, "Attack", 0, nil, selected.model)
		selected.humanoid.Health = 0
		sample(0.23)
		near(other.humanoid.Health, 10000, "dead target does not redirect damage to another enemy")
		equal(state.character:GetAttribute("K0Feedback"), "TargetUnavailable", "dead target is explained")
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

	case("elf-nearest-forward-target-one-server-shot", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local nearEnemy = spawnEnemy(15)
		local farEnemy = spawnEnemy(25)
		farEnemy.id = 2
		action(state, "Attack", 0)
		equal(state.character:GetAttribute("K0AttackProfileId"), "elf.bow.basic", "server chooses Elf bow profile")
		sample(0.23)
		near(nearEnemy.humanoid.Health, 9930, "nearest visible target receives 70 damage")
		near(farEnemy.humanoid.Health, 10000, "single shot does not hit a second target")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "server publishes one shot")
		equal(state.character:GetAttribute("K0ArrowTo"), nearEnemy.root.Position, "visual endpoint follows server target")
		sample(0.24)
		near(nearEnemy.humanoid.Health, 9930, "active window cannot deal duplicate damage")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "one arrow per attack window")
	end)
	case("elf-25-86-stud-shot-persists-and-provokes-goblin", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		enemy.nextMoveAt = 0
		action(state, "Attack", 0)
		api.setClock(0.23)
		api.heartbeat(1 / 60)
		near(enemy.humanoid.Health, 230, "real 25.86-stud hit survives the same heartbeat")
		near(enemy.rangedAttackers[state], 6.23, "actual attacking state recorded")
		equal(enemy.target, state, "goblin targets the ranged attacker inside its leash")
		equal(enemy.mode, "Chase", "goblin reacts rather than restoring health")
		near(enemy.rangedAggroUntil, 6.23, "six-second retaliation lifetime")
		near((enemy.humanoid.WalkToPoint - state.root.Position).Magnitude, 0, "chase moves toward validated attacker")
	end)
	case("elf-outside-leash-keeps-damage-only-while-recent", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(50)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(state, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		near(enemy.humanoid.Health, 230, "outside leash damage is not immediately restored")
		equal(enemy.target, nil, "attacker outside the 36-stud leash is not chased")
		equal(enemy.mode, "Idle", "enemy remains at its spawn")
		action(state, "Attack", 0.61)
		api.setClock(0.84); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "another shot deals damage and refreshes grace")
		near(enemy.rangedAggroUntil, 6.84, "latest hit extends the six-second timeout")
		api.setClock(6.3); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "earlier timeout cannot prematurely heal")
		api.setClock(6.85); api.heartbeat(0)
		near(enemy.humanoid.Health, 300, "enemy recovers after the final timeout")
		equal(enemy.rangedAttackers, nil, "reset clears retaliation identities")
	end)
	case("elf-retaliation-cannot-break-spawn-leash", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		enemy.nextMoveAt = 0
		action(state, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		equal(enemy.target, state, "attacker initially within leash")
		enemy.model:PivotTo(CFrame.lookAt(enemy.spawnPosition + Vector3.new(0, 0, 36.1), enemy.spawnPosition + Vector3.new(0, 0, 37.1)))
		enemy.nextMoveAt = 0
		api.setClock(0.24); api.heartbeat(0)
		equal(enemy.target, nil, "over-leash enemy stops chasing")
		near((enemy.humanoid.WalkToPoint - enemy.spawnPosition).Magnitude, 0, "over-leash enemy returns to spawn")
		near(enemy.humanoid.Health, 230, "health persists while returning")
	end)
	case("elf-old-hero-is-never-a-retaliation-target", function()
		local contexts = {}
		api.injectResolver(function(player) return contexts[player] end)
		local player = { Parent = Players, UserId = -2101 }
		contexts[player] = { heroId = "elf-old", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local elf = spawnPlayer(player)
		local otherPlayer = { Parent = Players, UserId = -2102 }
		contexts[otherPlayer] = { heroId = "other", baseClassId = "dwarf", epoch = 1, characterGeneration = 1 }
		spawnPlayer(otherPlayer)
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(elf, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		equal(enemy.target, elf, "live Elf is the initial target")
		contexts[player] = nil
		api.setClock(0.24); api.heartbeat(0)
		equal(enemy.target, nil, "revoked hero is not chased despite remaining grace")
		near(enemy.humanoid.Health, 230, "live second player leaves bounded damage grace intact")
	end)
	case("multiple-elf-hits-retain-each-valid-attacker", function()
		local contexts = {}
		api.injectResolver(function(player) return contexts[player] end)
		local nearPlayer = { Parent = Players, UserId = -2202 }
		contexts[nearPlayer] = { heroId = "near-elf", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local nearElf = spawnPlayer(nearPlayer)
		local farPlayer = { Parent = Players, UserId = -2201 }
		contexts[farPlayer] = { heroId = "far-elf", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local farElf = spawnPlayer(farPlayer)
		local farPosition = origin + Vector3.new(0, 0, 24.14)
		farElf.character:PivotTo(CFrame.lookAt(farPosition, farPosition + Vector3.new(0, 0, -1)))
		farElf.lastMotionPosition, farElf.lastSafePivot = farElf.root.Position, farElf.character:GetPivot()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(nearElf, "Attack", 0)
		action(farElf, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "both independent hits apply")
		near(enemy.rangedAttackers[nearElf], 6.23, "near attacker remains in threat table")
		near(enemy.rangedAttackers[farElf], 6.23, "far attacker is recorded separately")
		equal(enemy.target, nearElf, "farther outside-leash hit does not erase nearby valid target")
	end)
	case("knight-melee-leash-reset-is-unchanged", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(state, "Attack", 0)
		sample(0.17)
		near(enemy.humanoid.Health, 225, "Knight hit remains 75")
		state.character:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, 30), origin + Vector3.new(0, 0, 29)))
		state.lastMotionPosition, state.lastSafePivot, state.lastMotionAt = state.root.Position, state.character:GetPivot(), 0.17
		api.setClock(0.18); api.heartbeat(0)
		near(enemy.humanoid.Health, 300, "ordinary melee encounter still resets at spawn when target leaves aggro")
		equal(enemy.rangedAttackers, nil, "melee does not create ranged retaliation")
	end)
	case("elf-range-and-facing-validated", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local tooFar = spawnEnemy(56)
		local behind = spawnEnemy(3)
		behind.id = 2
		behind.model:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, 3), origin + Vector3.new(0, 0, 4)))
		action(state, "Attack", 0)
		sample(0.23)
		near(tooFar.humanoid.Health, 10000, "outside 55-stud range is rejected")
		near(behind.humanoid.Health, 10000, "target behind the server facing is rejected")
		equal(state.character:GetAttribute("K0ArrowTo"), origin + Vector3.new(0, 0, -55), "miss ends at maximum range")
	end)
	case("elf-wall-blocks-server-shot", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(20)
		local wall = Instance.new("Part")
		wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(state, "Attack", 0)
		sample(0.23)
		near(enemy.humanoid.Health, 10000, "wall prevents ranged damage")
		local endpoint = state.character:GetAttribute("K0ArrowTo")
		near((endpoint - origin).Magnitude, 9.5, "miss visual stops on first wall")
	end)
	for _, angle in { 20, 23 } do
		case("elf-forward-cone-" .. angle, function()
			api.injectResolver(function() return "elf" end)
			local state = spawnPlayer()
			local enemy = spawnEnemy(15)
			local target = origin + Vector3.new(15 * math.sin(math.rad(angle)), 0, -15 * math.cos(math.rad(angle)))
			enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
			action(state, "Attack", 0)
			sample(0.23)
			near(enemy.humanoid.Health, angle == 20 and 9930 or 10000, "45-degree total cone boundary")
		end)
	end
	case("elf-server-facing-and-input-burst-limit", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(state, "Attack", 0, Vector3.new(0, 0, 1))
		for _ = 1, 50 do action(state, "Attack", 0) end
		equal(state.attackSeq, 1, "burst cannot start additional attacks")
		equal(state.tokens, 0, "repeated remote requests exhaust the server bucket")
		sample(0.23)
		near(enemy.humanoid.Health, 9930, "forged direction does not reverse server facing")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "burst yields only one shot")
	end)
	case("elf-cannot-use-knight-guard", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy()
		action(state, "BlockStart", 0)
		equal(state.mode, "Idle", "Elf cannot start Knight guard")
		state.mode, state.guardStarted = "Block", 0.46
		api.beginEnemyAttack(enemy, state, 0)
		sample(0.61)
		near(state.humanoid.Health, 920, "forged guard does not reduce damage")
		equal(state.counter, nil, "Elf has no Knight counter")
	end)
	case("session-context-required-before-combat-setup", function()
		local ready = false
		api.injectResolver(function() return ready and "elf" or nil end)
		local model = rig("WaitingCharacter", characters, origin, Vector3.new(0, 0, -1))
		model:SetAttribute("K0SpawnReady", true)
		local player = { Parent = Players, Character = model, UserId = -2001 }
		api.activePlayers[player] = true
		api.setupCharacter(player, model)
		api.setupCharacter(player, model)
		equal(api.pendingCharacters[player], model, "duplicate setup shares a single pending character")
		task.wait(0.15)
		equal(api.playerStates[player], nil, "spawn alone does not activate combat")
		ready = true
		waitFor(function() return api.playerStates[player] ~= nil end, "session becomes ready")
		local state = api.playerStates[player]
		equal(state.baseClassId, "elf", "ready server context activates Elf")
		action(state, "Attack", 0)
		api.setupCharacter(player, model)
		task.wait(0.15)
		equal(api.playerStates[player], state, "duplicate ready setup cannot replace active state")
		equal(state.attackSeq, 1, "duplicate ready setup cannot reset attack sequence")
	end)
	case("hero-switch-invalidates-unfired-elf-attack", function()
		local context = { heroId = "elf-hero", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		api.injectResolver(function() return context end)
		local old, player = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(old, "Attack", 0)
		context = { heroId = "knight-hero", baseClassId = "knight", epoch = 2, characterGeneration = 2 }
		sample(0.23)
		near(enemy.humanoid.Health, 10000, "old windup cannot hit after epoch switch")
		equal(old.character:GetAttribute("K0ArrowSeq"), 0, "old epoch cannot publish a shot")
		local new = spawnPlayer(player)
		equal(new.baseClassId, "knight", "new hero may start Knight combat")
		equal(api.playerStates[player], new, "new hero owns combat state")
	end)
	case("stale-character-cannot-cancel-new-setup", function()
		local ready = false
		api.injectResolver(function() return ready and "elf" or nil end)
		local old = rig("OldCharacter", characters, origin, Vector3.new(0, 0, -1))
		local new = rig("NewCharacter", characters, origin, Vector3.new(0, 0, -1))
		old:SetAttribute("K0SpawnReady", true)
		new:SetAttribute("K0SpawnReady", true)
		local player = { Parent = Players, Character = old, UserId = -2002 }
		api.activePlayers[player] = true
		api.setupCharacter(player, old)
		player.Character = new
		api.setupCharacter(player, new)
		api.setupCharacter(player, old)
		equal(api.pendingCharacters[player], new, "late old callback cannot replace current pending life")
		ready = true
		waitFor(function() return api.playerStates[player] ~= nil end, "new character setup")
		equal(api.playerStates[player].character, new, "only new character becomes active")
	end)
	case("hero-switch-clears-fired-elf-visual-and-future-hits", function()
		local context = { heroId = "elf-hero", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		api.injectResolver(function() return context end)
		local old, player = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(old, "Attack", 0)
		sample(0.23)
		near(enemy.humanoid.Health, 9930, "shot before switch lands once")
		equal(type(old.character:GetAttribute("K0ArrowVisual")), "string", "server publishes shot visual")
		context = { heroId = "mage-hero", baseClassId = "mage", epoch = 2, characterGeneration = 2 }
		sample(0.24)
		api.stepPlayer(old, 0.24, 0, false)
		near(enemy.humanoid.Health, 9930, "old shot cannot hit again after switch")
		equal(old.character:GetAttribute("K0ArrowVisual"), nil, "old visual is invalidated")
		local new = spawnPlayer(player)
		equal(new.baseClassId, "mage", "different hero enters with its own class")
	end)

	case("hero-class-stays-fixed-and-new-hero-can-differ", function()
		api.injectResolver(function() return "dwarf" end)
		local first, player = spawnPlayer()
		local second = spawnPlayer(player)
		equal(second.baseClassId, "dwarf", "respawn uses first server class")
		equal(second.character:GetAttribute("K0AttackProfileId"), "dwarf.axe.basic", "profile stays fixed")
		first.humanoid.Health = 0
		task.wait()
		equal(api.playerStates[player], second, "old death cannot replace new state")
		api.injectResolver(function() return "mage" end)
		equal(api.readCombatContext(player, second.character), nil, "same hero class cannot change")
		api.injectResolver(function() return { heroId = "other-hero", baseClassId = "mage", epoch = 2, characterGeneration = 2 } end)
		local third = spawnPlayer(player)
		equal(third.baseClassId, "mage", "different hero can have a different class")
	end)
	case("unsupported-class-fails-closed", function()
		api.injectResolver(function() return "priest" end)
		local player = { Parent = Players, UserId = -999 }
		api.activePlayers[player] = true
		equal(api.readCombatContext(player, nil), nil, "unsupported server class denied")
		api.injectResolver(function() return "knight" end)
		equal(api.readCombatContext(player, nil).baseClassId, "knight", "valid later context can become ready")
		equal(api.heroClasses[player], nil, "invalid context does not create a hero")
	end)
	case("yielding-resolver-fails-closed", function()
		local player = { Parent = Players, UserId = -1000 }
		api.activePlayers[player] = true
		local continued = false
		api.injectResolver(function() coroutine.yield(); continued = true; return "mage" end)
		equal(api.readCombatContext(player, nil), nil, "yielding resolver returns no context")
		equal(continued, false, "yielded resolver cannot later enable combat")
		equal(api.heroClasses[player], nil, "yielded resolver cannot create a hero")
	end)
	case("public-start-accepts-trusted-server-resolver", function()
		api.start(enemies, function() return { heroId = "mage-hero", baseClassId = "mage", epoch = 1, characterGeneration = 1 } end)
		local player = { Parent = Players, UserId = -1001 }
		api.activePlayers[player] = true
		equal(api.readCombatContext(player, nil).baseClassId, "mage", "actual public start installs server resolver")
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
