-- K0 R1/R2 deterministic native service-path regression.
-- run-in-roblox --place <fixed local build> --script tests/k0-timing-native.luau
-- The same script can run in an isolated local Play server with a real Player.
-- It clones production Source, changes only the final return, and automatically
-- captures the original RemoteEvent/Heartbeat callback expressions verbatim.
-- No production test hook, handwritten replacement combat logic or remote
-- transport simulation. Player0 uses an explicit identity mock with native rigs.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

assert(game.PlaceId == 0, "Timing QA requires an isolated unpublished local place")
assert(not workspace:FindFirstChild("K0TimingQaFixture"), "Timing QA fixture already exists")
local production = assert(ServerScriptService:FindFirstChild("Server"), "K0 server missing")
production = assert(production:FindFirstChild("Combat"), "K0 Combat missing")
production = assert(production:FindFirstChild("CombatService"), "K0 CombatService missing")
local report = { kind = "K0_TIMING_NATIVE", checks = 0, cases = {}, failures = {},
	coverage = "Production service and verbatim callbacks with synthetic clock; no real RemoteEvent transport, input, historical rewind, latency or performance acceptance",
	limits = "Missed unsampled windows and eligible buffered commands have a 0.25-second experimental processing cap; current position/facing/defense is used",
	players = #Players:GetPlayers(), realCharacterCases = 0, identityMockCases = 0 }
local api, privateModule, fixture, enemyFolder, characters, startedRun
local realPlayer, realSnapshot
local origin = Vector3.new(10000, 1000, 10000)
local T = 0 -- exact boundary ages do not subtract a large synthetic epoch

local function equal(actual, expected, label)
	report.checks += 1
	assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", actual " .. tostring(actual))
end
local function near(actual, expected, label, tolerance)
	report.checks += 1
	assert(math.abs(actual - expected) < (tolerance or 0.000001), label .. ": expected " .. tostring(expected) .. ", actual " .. tostring(actual))
end
local function restoreRealCharacter()
	if not realSnapshot or not realSnapshot.character.Parent then return end
	local saved = realSnapshot
	saved.character:PivotTo(saved.pivot)
	saved.humanoid.MaxHealth = saved.maxHealth
	saved.humanoid.Health = saved.health
	saved.humanoid.WalkSpeed = saved.walkSpeed
	saved.root.AssemblyLinearVelocity = saved.velocity
	saved.root.AssemblyAngularVelocity = saved.angularVelocity
	for key in pairs(saved.character:GetAttributes()) do
		if key:sub(1, 2) == "K0" then saved.character:SetAttribute(key, nil) end
	end
	for key, value in pairs(saved.attributes) do saved.character:SetAttribute(key, value) end
	pcall(function() saved.root:SetNetworkOwnershipAuto() end)
end
local function resetCase()
	if api then
		for _, state in pairs(api.playerStates) do api.clearAction(state) end
		table.clear(api.playerStates)
		table.clear(api.enemyStates)
	end
	if enemyFolder then enemyFolder:ClearAllChildren() end
	if characters then characters:ClearAllChildren() end
	restoreRealCharacter()
end
local function case(id, callback)
	resetCase()
	local before = report.checks
	local ok, message = xpcall(callback, debug.traceback)
	table.insert(report.cases, { id = id, pass = ok, checks = report.checks - before, error = not ok and tostring(message) or nil })
	if not ok then table.insert(report.failures, id .. ": " .. tostring(message)) end
end
local function nativeRig(name, parent, position, facing)
	local model = Instance.new("Model")
	model.Name = name
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CanCollide = false
	root.CanTouch = false
	root.CFrame = CFrame.lookAt(position, position + facing)
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
local function playerState(preferReal)
	local model, humanoid, root, player
	if preferReal ~= false and realPlayer then
		model, humanoid, root, player = realSnapshot.character, realSnapshot.humanoid, realSnapshot.root, realPlayer
		model:PivotTo(CFrame.lookAt(origin, origin + Vector3.new(0, 0, -1)))
		humanoid.MaxHealth, humanoid.Health = 10000, 10000
		report.realCharacterCases += 1
	else
		model, humanoid, root = nativeRig("IdentityMockCharacter", characters, origin, Vector3.new(0, 0, -1))
		player = { Parent = Players, Character = model, UserId = -10001 }
		report.identityMockCases += 1
	end
	local state = { player = player, character = model, humanoid = humanoid, root = root,
		mode = "Idle", stamina = api.Config.MaxStamina, combo = 0, lastAttackFinished = -math.huge,
		lastDodgeStarted = -math.huge, lastGuardStarted = -math.huge, regenAt = math.huge,
		stunnedUntil = 0, feedbackSeq = 0, lastMotionPosition = root.Position,
		lastSafePivot = model:GetPivot(), lastMotionAt = T, movementBudget = api.Config.MovementBudget,
		tokens = api.Config.RemoteBurst, lastRefill = T }
	api.playerStates[player] = state
	return state
end
local function enemyState(kind, offset)
	local position = origin + (offset or Vector3.new(0, 0, -3))
	local model, humanoid, root = nativeRig(kind, enemyFolder, position, Vector3.new(0, 0, 1))
	local config = assert(api.Config.Enemy[kind])
	local enemy = { id = 1, model = model, humanoid = humanoid, root = root, kind = kind, config = config,
		mode = "Idle", posture = config.posture, postureImmuneUntil = 0, lastPostureDamage = T,
		lastPerfectResponse = -math.huge, pattern = 0, attackSeq = 0, pathToken = 0,
		pathPending = false, nextMoveAt = math.huge, nextPathAt = math.huge, reconsiderAt = math.huge,
		spawnPosition = root.Position, spawnPivot = model:GetPivot() }
	api.enemyStates[model] = enemy
	return enemy
end
local function frame(current, dt)
	api.setClock(current)
	api.heartbeat(dt or 1 / 60)
end
local function intent(state, action, current, direction)
	api.setClock(current)
	api.remote(state.player, action, direction)
end
local function beginSword(state, index)
	state.combo = index - 1
	state.lastAttackFinished = T
	api.startAttack(state, T)
	return state.attack.definition
end
local function beginEnemy(enemy, state, activeAt)
	api.beginEnemyAttack(enemy, state, activeAt - enemy.config.attacks[1].windup)
	return enemy.attack.definition
end

local ok, fatal = xpcall(function()
	local original = production.Source
	-- Structural end markers avoid counting parentheses inside comments/strings.
	-- Fail explicitly if production changes this callback layout.
	local remoteExpression = assert(original:match("actionRemote%.OnServerEvent:Connect%((function.-\n\tend)%)\n\tRunService%.Heartbeat:Connect"), "production RemoteEvent callback boundary missing")
	local heartbeatExpression = assert(original:match("RunService%.Heartbeat:Connect%((function.-\n\tend)%)\nend%s+return CombatService%s*$"), "production Heartbeat callback boundary missing")
	local tail = "\nlocal qaRemote=" .. remoteExpression .. "\nlocal qaHeartbeat=" .. heartbeatExpression .. "\n" .. [[
return {
 Config=Config, Rules=Rules, playerStates=playerStates, enemyStates=enemyStates,
 setEnemyFolder=function(value) enemyFolder=value end,
 setClock=function(value) now=function() return value end end,
 startAttack=startAttack, beginEnemyAttack=beginEnemyAttack, acceptAction=acceptAction,
 stepPlayer=stepPlayer, stepEnemy=stepEnemy, processCombatSamples=processCombatSamples,
 clearAction=clearAction, markDead=markDead, resetEnemyAttack=resetEnemyAttack,
 remote=qaRemote, heartbeat=qaHeartbeat
}
]]
	local instrumented, replacements = original:gsub("\nreturn CombatService%s*$", function() return tail end)
	assert(replacements == 1, "only the final return may be replaced")
	privateModule = Instance.new("ModuleScript")
	privateModule.Name = "K0TimingQaPrivate"
	privateModule.Source = instrumented
	privateModule.Parent = production.Parent -- preserves script.Parent.K0Rules resolution
	api = require(privateModule)
	report.originalSourceBytes = #original
	report.remoteCallbackBytes = #remoteExpression
	report.heartbeatCallbackBytes = #heartbeatExpression
	report.sourceTailOnly = true
	fixture = Instance.new("Folder")
	fixture.Name = "K0TimingQaFixture"
	fixture.Parent = workspace
	enemyFolder = Instance.new("Folder")
	enemyFolder.Name = "Enemies"
	enemyFolder.Parent = fixture
	characters = Instance.new("Folder")
	characters.Name = "Characters"
	characters.Parent = fixture
	local ground = Instance.new("Part")
	ground.Name = "TimingGround"
	ground.Anchored = true
	ground.Size = Vector3.new(200, 4, 200)
	ground.Position = origin + Vector3.new(0, -3, 0)
	ground.Parent = fixture
	api.setEnemyFolder(enemyFolder)
	if not RunService:IsRunning() then RunService:Run(); startedRun = true end
	local candidate = Players:GetPlayers()[1]
	local character = candidate and candidate.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if candidate and humanoid and root and humanoid.Health > 0 then
		realPlayer = candidate
		realSnapshot = { character = character, humanoid = humanoid, root = root,
			pivot = character:GetPivot(), maxHealth = humanoid.MaxHealth, health = humanoid.Health,
			walkSpeed = humanoid.WalkSpeed, attributes = character:GetAttributes(),
			velocity = root.AssemblyLinearVelocity, angularVelocity = root.AssemblyAngularVelocity }
	end
	report.context = realPlayer and "isolated Play: real Player/Character for nonfatal cases; native identity fixtures for death cases"
		or "isolated Run: zero real Player coverage; strict player identity mocks with native Model/Humanoid/physics APIs"
	near(api.Rules.MaxLateHit, 0.25, "late hit experimental cap")
	near(api.Rules.MaxLateBuffer, 0.25, "late buffer experimental cap")

	for index = 1, 3 do
		case("R1-sword-" .. index .. "-skip-active-and-deduplicate", function()
			local state, enemy = playerState(), enemyState("Ogre")
			local definition = beginSword(state, index)
			frame(T + definition.windup - 0.01)
			near(enemy.humanoid.Health, 10000, "no damage before active")
			frame(T + definition.windup + definition.active + 0.01, definition.active + 0.02)
			local expected = 10000 - math.floor(api.Config.AttackPower * definition.damage + 0.5)
			near(enemy.humanoid.Health, expected, "skipped active still hits once")
			frame(T + definition.windup + definition.active + 0.02)
			near(enemy.humanoid.Health, expected, "recovery cannot duplicate damage")
		end)
	end
	for _, kind in { "Goblin", "Orc", "Ogre" } do
		case("R1-enemy-" .. kind .. "-skip-active-and-deduplicate", function()
			local state, enemy = playerState(), enemyState(kind)
			local definition = beginEnemy(enemy, state, T + 0.2)
			frame(T + 0.19)
			near(state.humanoid.Health, 10000, "enemy windup cannot hit")
			frame(T + 0.2 + definition.active + 0.01, definition.active + 0.02)
			near(state.humanoid.Health, 10000 - definition.damage, "missed enemy active hits once")
			frame(T + 0.2 + definition.active + 0.02)
			near(state.humanoid.Health, 10000 - definition.damage, "enemy cannot damage same target twice")
		end)
	end
	case("R1-normal-active-cannot-hit-new-target-in-recovery", function()
		local state, enemy = playerState(), enemyState("Ogre", Vector3.new(0, 0, -20))
		local definition = beginSword(state, 1)
		frame(T + definition.windup + 0.01)
		near(enemy.humanoid.Health, 10000, "target outside active range")
		enemy.model:PivotTo(CFrame.new(origin + Vector3.new(0, 0, -3)))
		frame(T + definition.windup + definition.active + 0.01)
		near(enemy.humanoid.Health, 10000, "observed active cannot become a recovery hit")
	end)
	case("R1-normal-active-multiple-samples-still-one-hit", function()
		local state, enemy = playerState(), enemyState("Ogre")
		local definition = beginSword(state, 1)
		frame(T + definition.windup)
		frame(T + definition.windup + 0.03)
		frame(T + definition.windup + 0.08)
		near(enemy.humanoid.Health, 9925, "three active samples have one damage event")
	end)
	for _, late in { 0.25, 0.2501, 3 } do
		case("R1-late-hit-cap-" .. late, function()
			local state, enemy = playerState(), enemyState("Ogre")
			local definition = beginSword(state, 1)
			frame(T + definition.windup + definition.active + late, late)
			near(enemy.humanoid.Health, late <= 0.25 and 9925 or 10000, "bounded late hit policy")
		end)
	end
	case("R1-current-position-rejects-missed-behind-target", function()
		local state, enemy = playerState(), enemyState("Ogre", Vector3.new(0, 0, 3))
		beginSword(state, 1)
		frame(T + 0.27, 0.2)
		near(enemy.humanoid.Health, 10000, "late processing cannot invent a rear sword hit")
	end)
	case("R1-current-block-state-is-not-historically-rewound", function()
		local state, enemy = playerState(), enemyState("Goblin")
		beginEnemy(enemy, state, T + 0.16)
		api.acceptAction(state, "BlockStart", nil, T - 0.2)
		frame(T + 0.27, 0.2)
		near(state.humanoid.Health, 9984, "current ordinary block reduces Goblin damage")
		near(state.stamina, 80, "raise plus impact stamina charged once")
	end)
	case("R1-cancel-before-active-and-dead-attacker", function()
		local state, enemy = playerState(false), enemyState("Ogre")
		beginSword(state, 1)
		api.clearAction(state)
		state.mode = "Idle"
		frame(T + 0.27)
		near(enemy.humanoid.Health, 10000, "cancelled attack cannot hit")
		beginSword(state, 1)
		state.humanoid.Health = 0
		frame(T + 0.27)
		near(enemy.humanoid.Health, 10000, "dead attacker cannot hit")
	end)
	case("R1-pending-earlier-player-kill-cancels-enemy", function()
		local state, enemy = playerState(), enemyState("Goblin")
		enemy.humanoid.Health = 50
		beginSword(state, 1) -- active at T+0.16
		beginEnemy(enemy, state, T + 0.17)
		api.setClock(T + 0.28)
		api.processCombatSamples(T + 0.28)
		equal(enemy.humanoid.Health <= 0, true, "earlier sword kills enemy")
		near(state.humanoid.Health, 10000, "killed enemy loses later pending hit")
	end)
	case("R1-pending-earlier-enemy-stun-cancels-sword", function()
		local state, enemy = playerState(), enemyState("Goblin")
		beginSword(state, 1)
		beginEnemy(enemy, state, T + 0.15)
		api.processCombatSamples(T + 0.27)
		near(state.humanoid.Health, 9920, "earlier enemy hit is applied")
		near(enemy.humanoid.Health, 10000, "stun cancels later sword")
		equal(state.mode, "Stunned", "interrupted state preserved")
	end)
	case("R1-remote-resolves-old-window-before-new-action", function()
		local state, enemy = playerState(), enemyState("Ogre")
		beginSword(state, 1)
		intent(state, "Attack", T + 0.43)
		near(enemy.humanoid.Health, 9925, "remote entry resolves old active before replacing attack")
		equal(state.combo, 2, "new attack starts once after old hit")
	end)
	case("R1-remote-earlier-enemy-death-denies-new-input", function()
		local state, enemy = playerState(false), enemyState("Goblin")
		state.humanoid.Health = 50
		beginEnemy(enemy, state, T + 0.16)
		intent(state, "Attack", T + 0.27)
		equal(state.humanoid.Health <= 0, true, "pending enemy damage kills sender")
		equal(state.mode, "Dead", "sender marked dead")
		equal(state.attack, nil, "new remote intent cannot revive attack")
	end)
	for _, age in { 0.079, 0.281 } do
		case("R1-dodge-position-before-enemy-hit-" .. age, function()
			local state = playerState()
			intent(state, "Dodge", T, Vector3.new(0, 0, -1))
			equal(state.mode, "Dodge", "native ownership allows dodge")
			local dodge = assert(state.dodge)
			local enemy = enemyState("Goblin", Vector3.new(0, 0, 3))
			beginEnemy(enemy, state, T + age - 0.001)
			frame(T + age, age)
			near(state.humanoid.Health, 10000, "already moved outside enemy range before non-invulnerable sample")
			local expectedDistance = api.Config.Dodge.distance * age / api.Config.Dodge.moveDuration
			-- Native Vector3 at the isolated 10,000-stud coordinate is quantized;
			-- only world position gets 0.002 stud tolerance, never costs or timing.
			near((state.root.Position - origin).Magnitude, expectedDistance, "dodge moves to current time before hit", 0.002)
			near(dodge.moved, expectedDistance, "cumulative dodge budget remains exact")
			local position, moved = state.root.Position, dodge.moved
			frame(T + age, 0)
			near((state.root.Position - position).Magnitude, 0, "same timestamp cannot move twice")
			near(dodge.moved, moved, "same timestamp preserves cumulative distance")
			near(state.stamina, 70, "dodge charged once")
		end)
	end
	for _, age in { 0.08, 0.28 } do
		case("R1-dodge-invulnerability-boundary-" .. age, function()
			local state = playerState()
			intent(state, "Dodge", T, Vector3.new(0, 0, -1))
			local z = age == 0.08 and -4.5 or -9
			local enemy = enemyState("Goblin", Vector3.new(0, 0, z))
			beginEnemy(enemy, state, T + age - 0.001)
			frame(T + age, age)
			near(state.humanoid.Health, age == 0.08 and 10000 or 9920, "invulnerability start included and end excluded at current moved position")
			near(state.stamina, 70, "boundary hit cannot charge dodge twice")
		end)
	end
	case("R1-dodge-wall-and-same-time-idempotence", function()
		local state = playerState()
		local wall = Instance.new("Part")
		wall.Name = "TimingWall"
		wall.Anchored = true
		wall.Size = Vector3.new(20, 20, 1)
		wall.Position = origin + Vector3.new(0, 0, -2)
		wall.Parent = characters
		intent(state, "Dodge", T, Vector3.new(0, 0, -1))
		frame(T + 0.3, 0.3)
		equal(state.dodge.blocked, true, "native Blockcast stops dodge at wall")
		equal((state.root.Position - origin).Magnitude < 1.5, true, "dodge cannot cross wall")
		local position = state.root.Position
		frame(T + 0.3, 0)
		near((state.root.Position - position).Magnitude, 0, "blocked same-time observation cannot move twice")
		near(state.stamina, 70, "blocked dodge costs once")
	end)

	for _, action in { "Attack", "BlockStart", "Dodge" } do
		case("R2-60Hz-single-" .. action, function()
			local state = playerState()
			local definition = beginSword(state, 1)
			local eligible = api.Rules.nextAllowedInAttack(action, definition)
			local received = eligible - api.Config.InputBuffer + 0.001
			intent(state, action, T + received)
			equal(state.queued and state.queued.action, action, "single input accepted into queue")
			local expires = state.queued.expires
			local previousFrame = math.floor(eligible * 60) / 60
			if previousFrame == eligible then previousFrame -= 1 / 60 end
			frame(T + previousFrame)
			equal(state.queued ~= nil, true, "not consumed before eligible")
			local nextFrame = previousFrame + 1 / 60
			frame(T + nextFrame)
			equal(state.queued, nil, "consumed at next 60Hz observation")
			equal(state.mode, action == "BlockStart" and "Block" or action, "requested mode started")
			equal(T + nextFrame > expires, true, "reproduction crosses receive-time expiry")
			local feedback = state.feedbackSeq
			frame(T + nextFrame)
			equal(state.feedbackSeq, feedback, "same observation cannot consume twice")
			if action == "Attack" then equal(state.combo, 2, "single next combo")
			elseif action == "BlockStart" then near(state.stamina, 96, "guard initial cost once")
			else near(state.stamina, 70, "dodge cost once") end
		end)
	end
	case("R2-repeated-input-cannot-extend-buffer", function()
		local state = playerState()
		beginSword(state, 1)
		intent(state, "Attack", T + 0.301)
		local expires = assert(state.queued).expires
		intent(state, "Attack", T + 0.32)
		near(state.queued.expires, expires, "held repeat preserves first expiry")
		intent(state, "Attack", T + 0.433333333)
		equal(state.combo, 2, "due queue consumed once before repeated remote input")
		equal(state.queued, nil, "repeat does not immediately queue a third attack")
	end)
	case("R2-release-cancels-buffered-guard", function()
		local state = playerState()
		beginSword(state, 1)
		intent(state, "BlockStart", T + 0.201)
		equal(state.queued and state.queued.action, "BlockStart", "guard buffered")
		intent(state, "BlockEnd", T + 0.25)
		frame(T + 0.333333333)
		equal(state.queued, nil, "release cancels guard queue")
		equal(state.mode, "Attack", "released guard does not start")
		near(state.stamina, 100, "cancelled guard costs nothing")
	end)
	for _, action in { "BlockStart", "Dodge" } do
		case("R2-resource-denial-" .. action, function()
			local state = playerState()
			local definition = beginSword(state, 1)
			local eligible = api.Rules.nextAllowedInAttack(action, definition)
			intent(state, action, T + eligible - 0.119)
			equal(state.queued and state.queued.action, action, "resource-ready action queues")
			state.stamina = 0
			frame(T + eligible + 0.01)
			equal(state.queued, nil, "resource loss discards queue")
			equal(state.mode, "Attack", "resource denied action does not start")
			near(state.stamina, 0, "resource denial cannot overspend")
		end)
	end
	case("R2-death-discards-buffer", function()
		local state = playerState(false)
		beginSword(state, 1)
		intent(state, "Attack", T + 0.301)
		state.humanoid.Health = 0
		frame(T + 0.433333333)
		equal(state.queued, nil, "death clears queue")
		equal(state.mode, "Dead", "dead state preserved")
		equal(state.attack, nil, "death cannot execute buffered attack")
	end)
	for _, late in { 0.25, 0.2501, 3 } do
		case("R2-late-buffer-cap-" .. late, function()
			local state = playerState()
			beginSword(state, 1)
			intent(state, "Attack", T + 0.301)
			frame(T + 0.42 + late, late)
			equal(state.queued, nil, "due or expired queue consumed exactly once")
			equal(state.attack ~= nil, late <= 0.25, "bounded late buffer policy")
		end)
	end
	case("R2-exact-expiry-is-not-accepted", function()
		local state = playerState()
		beginSword(state, 1)
		intent(state, "Attack", T + 0.3)
		equal(state.queued, nil, "eligible == expires is outside half-open lifetime")
		frame(T + 0.433333333)
		equal(state.attack, nil, "expired single input never starts next attack")
	end)
	case("R2-higher-priority-dodge-replaces-due-attack", function()
		local state = playerState()
		beginSword(state, 1)
		intent(state, "Attack", T + 0.301)
		intent(state, "Dodge", T + 0.433333333)
		equal(state.mode, "Dodge", "higher-priority incoming dodge replaces due attack")
		equal(state.attack, nil, "buffered attack does not also execute")
		near(state.stamina, 70, "replacement dodge costs once")
	end)
	case("R2-due-dodge-precedes-lower-priority-remote", function()
		local state = playerState()
		beginSword(state, 1)
		intent(state, "Dodge", T + 0.241)
		intent(state, "Attack", T + 0.366666667)
		equal(state.mode, "Dodge", "due dodge is not overridden by fresh attack")
		equal(state.queued, nil, "lower-priority remote does not make a second action")
		near(state.stamina, 70, "due dodge costs once")
	end)
end, debug.traceback)
if not ok then table.insert(report.failures, "fixture: " .. tostring(fatal)) end
local cleanupOk, cleanupError = pcall(function()
	resetCase()
	if fixture then fixture:Destroy() end
	if privateModule then privateModule:Destroy() end
	if startedRun then RunService:Stop() end
end)
if not cleanupOk then table.insert(report.failures, "cleanup: " .. tostring(cleanupError)) end
report.pass = #report.failures == 0
print("K0_TIMING_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 timing regression failed; see K0_TIMING_NATIVE")
