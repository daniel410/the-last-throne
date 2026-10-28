-- Run from the project root with: lua tests/k0-rules.spec.lua
-- These are engine-independent timing, safety and combat outcome checks.
local Rules = dofile("src/server/Combat/K0Rules.luau")
local Config = dofile("src/shared/K0Config.luau")
local checks = 0
local function equal(actual, expected, label)
	checks = checks + 1
	assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function near(actual, expected, label)
	checks = checks + 1
	assert(math.abs(actual - expected) < 0.000001, label)
end
local axe = Config.BasicAttackProfiles.dwarf.attacks[1]
equal(Rules.shouldSampleHitWindow(axe.windup + axe.hitDelay - 0.001, axe, false), false, "axe cannot hit before impact")
equal(Rules.shouldSampleHitWindow(axe.windup + axe.hitDelay, axe, false), true, "axe hits at impact")
equal(Rules.shouldSampleHitWindow(axe.windup + axe.active + 0.01, axe, false), true, "axe retains bounded late sample")
equal(Rules.shouldSampleHitWindow(axe.windup + axe.active + 0.01, axe, true), false, "observed axe window has no late repeat")
for index, attack in ipairs(Config.Attacks) do
	local activeStart = attack.windup
	local recoveryStart = activeStart + attack.active
	local finish = recoveryStart + attack.recovery
	equal(Rules.phase(0, attack), "Windup", "attack " .. index .. " starts in windup")
	equal(Rules.phase(activeStart, attack), "Active", "active starts inclusively")
	equal(Rules.phase(recoveryStart, attack), "Recovery", "active ends exclusively")
	equal(Rules.phase(finish, attack), "None", "recovery ends exclusively")
	equal(Rules.allowedInAttack("Dodge", recoveryStart + 0.099, attack), false, "dodge too early")
	equal(Rules.allowedInAttack("Dodge", recoveryStart + 0.1, attack), true, "dodge after recovery 0.10")
	equal(Rules.allowedInAttack("BlockStart", finish - 0.101, attack), false, "guard too early")
	equal(Rules.allowedInAttack("BlockStart", finish - 0.099, attack), true, "guard in final 0.10")
	equal(Rules.allowedInAttack("Attack", finish - 0.001, attack), false, "next attack waits")
	equal(Rules.allowedInAttack("Attack", finish, attack), true, "next attack after finish")
end
local g, d = Config.Guard, Config.Dodge
local function defense(dodging, dodgeAge, blocking, guardAge, dot, blockable, stamina, cost)
	return Rules.defense(dodging, dodgeAge, blocking, guardAge, dot, blockable, g, d)
end
local outcome, multiplier, stamina = defense(true, 0.08, false, 0, 1, true, 100, 16)
equal(outcome, "Dodge", "dodge begins at inclusive invulnerability start")
near(multiplier, 0, "dodge prevents damage")
outcome = defense(true, 0.28, false, 0, 1, true, 100, 16)
equal(outcome, "Hit", "dodge invulnerability ends exclusively")
outcome = defense(false, 0, true, 0.099, 1, true, 100, 16)
equal(outcome, "Hit", "guard raise does not defend early")
outcome, multiplier, stamina = defense(false, 0, true, 0.1, 1, true, 100, 16)
equal(outcome, "PerfectBlock", "perfect guard begins after raise")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, true, 16, 16)
equal(outcome, "Blocked", "ordinary guard blocks without stamina")
near(multiplier, 0.2, "ordinary block reduces damage")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, true, 15, 16)
equal(outcome, "Blocked", "guard has no stamina gate")
outcome = defense(false, 0, true, 0.15, -1, true, 100, 16)
equal(outcome, "Hit", "guard does not cover rear")
outcome = defense(false, 0, true, 0.15, 0/0, true, 100, 16)
equal(outcome, "Hit", "non-finite guard facing cannot block")
outcome = defense(false, 0, true, 0.15, 1, false, 100, 0)
equal(outcome, "Hit", "unblockable strike ignores guard")
equal(Rules.withinCone(4.5, 0, 1, 4.5, 7, 100), true, "range boundary included")
equal(Rules.withinCone(4.501, 0, 1, 4.5, 7, 100), false, "outside range rejected")
equal(Rules.withinCone(3, 7.001, 1, 4.5, 7, 100), false, "height limit")
equal(Rules.withinCone(3, 0, -1, 4.5, 7, 100), false, "rear outside sword cone")
equal(Rules.withinCone(0/0, 0, 1, 4.5, 7, 100), false, "NaN rejected")
equal(Rules.isFinite(math.huge), false, "infinity rejected")
equal(Rules.isFinite(-math.huge), false, "negative infinity rejected")
equal(Rules.priority("Dodge") > Rules.priority("BlockStart"), true, "dodge buffer priority")
equal(Rules.priority("BlockStart") > Rules.priority("Attack"), true, "guard buffer priority")
local budget = Config.MovementBudget
for frame = 1, 300 do
	-- A 16-stud/s walk can arrive as a 0.8-stud network update every third frame.
	local distance = frame % 3 == 0 and 0.8 or 0
	local allowed
	allowed, budget = Rules.movementBudget(budget, 1 / 60, distance, Config.WalkSpeed, Config.MovementBudget)
	if not allowed then error("normal bursty movement was rejected at frame " .. frame) end
end
checks = checks + 1
local allowed = Rules.movementBudget(Config.MovementBudget, 1 / 60, 30, Config.WalkSpeed, Config.MovementBudget)
equal(allowed, false, "large instantaneous displacement rejected")
allowed = Rules.movementBudget(Config.MovementBudget, 1 / 60, 0/0, Config.WalkSpeed, Config.MovementBudget)
equal(allowed, false, "non-finite movement rejected")

-- Orc's ordinary, blockable strike uses the same actual rules as Goblin/Ogre.
-- These are pure decisions, not proof of real Player hits or animations.
local orc = assert(Config.Enemy.Orc, "Orc combat preset missing; fallback is not allowed")
equal(orc.health, 900, "Orc prototype health")
equal(orc.posture, 100, "Orc prototype posture")
local orcAttack = assert(orc.attacks[1])
equal(#orc.attacks, 1, "Orc has one authored ordinary melee attack")
equal(orcAttack.blockable, true, "Orc strike is blockable")
equal(Rules.phase(orcAttack.windup - 0.001, orcAttack), "Windup", "Orc damage cannot begin before windup")
equal(Rules.phase(orcAttack.windup, orcAttack), "Active", "Orc active starts inclusively")
equal(Rules.phase(orcAttack.windup + orcAttack.active, orcAttack), "Recovery", "Orc active ends exclusively")
equal(Rules.withinCone(orcAttack.range, 0, 1, orcAttack.range, Config.AttackHeight, orcAttack.angle), true, "Orc maximum frontal range included")
equal(Rules.withinCone(orcAttack.range + 0.001, 0, 1, orcAttack.range, Config.AttackHeight, orcAttack.angle), false, "Orc out of range rejected")
equal(Rules.withinCone(1, 0, -1, orcAttack.range, Config.AttackHeight, orcAttack.angle), false, "Orc rear is outside frontal strike")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, orcAttack.blockable, 100, orcAttack.guardCost)
equal(outcome, "Blocked", "ordinary guard blocks Orc strike")
near(orcAttack.damage * multiplier, 25, "Orc ordinary block receives 25 damage")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, orcAttack.blockable, 24, orcAttack.guardCost)
equal(outcome, "Blocked", "Orc strike remains blockable without stamina")
near(orcAttack.damage * multiplier, 25, "Orc block still reduces damage")
outcome, multiplier = defense(true, 0.08, false, 0, 1, orcAttack.blockable, 100, orcAttack.guardCost)
equal(outcome, "Dodge", "Orc strike respects dodge window")
near(orcAttack.damage * multiplier, 0, "Orc dodge prevents damage")

-- Run the actual local attack-start function with side effects isolated. This
-- covers the shared Goblin timestamp and Ogre pattern without faking a Player
-- or rewriting the function's branch in the test. It does not run the full AI.
local serviceFile = assert(io.open("src/server/Combat/CombatService.luau", "r"))
local serviceSource = serviceFile:read("*a")
serviceFile:close()
local beginSource = assert(serviceSource:match("(local function beginEnemyAttack%(.-)\nlocal function resetEnemy"), "actual beginEnemyAttack source missing")
local context = setmetatable({
	horizontalUnit = function(_, fallback) return fallback end,
	stopEnemy = function(enemy) enemy.stopped = true end,
	setEnemyState = function(enemy, state) enemy.mode = state end,
}, { __index = _G })
local chunk, loadError = load("local lastGoblinStart=-math.huge\n" .. beginSource .. "\nreturn beginEnemyAttack,function() return lastGoblinStart end", "K0 actual attack-start contract", "t", context)
assert(chunk, loadError)
local beginEnemyAttack, goblinTimestamp = chunk()
local function mockEnemy(kind)
	local attributes = {}
	return { kind = kind, config = assert(Config.Enemy[kind]), pattern = 0, attackSeq = 0, pathToken = 0,
		root = { Position = 0, CFrame = { LookVector = "forward" } },
		model = { SetAttribute = function(_, key, value) attributes[key] = value end }, attributes = attributes }
end
local target = { root = { Position = 1 } }
local orcEnemy = mockEnemy("Orc")
beginEnemyAttack(orcEnemy, target, 10)
equal(goblinTimestamp(), -math.huge, "Orc attack does not start Goblin spacing clock")
equal(orcEnemy.attack.definition, orcAttack, "Orc uses its own attack without Goblin fallback")
equal(orcEnemy.mode, "Windup", "actual Orc attack enters windup")
equal(orcEnemy.attributes.K0AttackRange, 5, "Orc telegraph publishes its own range")
local goblinEnemy = mockEnemy("Goblin")
beginEnemyAttack(goblinEnemy, target, 10.1)
near(goblinTimestamp(), 10.1, "Goblin attack updates shared spacing timestamp")
beginEnemyAttack(orcEnemy, target, 10.2)
near(goblinTimestamp(), 10.1, "later Orc attack preserves Goblin spacing timestamp")
local ogreEnemy = mockEnemy("Ogre")
for index, expected in ipairs({ 1, 1, 2 }) do
	beginEnemyAttack(ogreEnemy, target, 11 + index)
	equal(ogreEnemy.attack.definition, Config.Enemy.Ogre.attacks[expected], "Ogre two melee then unblockable pattern " .. index)
end
near(goblinTimestamp(), 10.1, "Ogre attacks preserve Goblin spacing timestamp")

-- R1/R2 helper boundaries supplement the actual service/callback regression in
-- tests/k0-timing-native.luau; they are not the service integration evidence.
near(Rules.MaxLateHit, 0.25, "late missed-window cap is explicit")
near(Rules.MaxLateBuffer, 0.25, "late eligible-buffer cap is explicit")
for _, definition in ipairs(Config.Attacks) do
	local begin = definition.windup
	local finish = definition.windup + definition.active
	equal(Rules.shouldSampleHitWindow(begin - 0.0001, definition, false), false, "R1 no hit before active")
	equal(Rules.shouldSampleHitWindow(begin, definition, false), true, "R1 active start included")
	equal(Rules.shouldSampleHitWindow(finish - 0.0001, definition, true), true, "R1 observed active keeps sampling new targets")
	equal(Rules.shouldSampleHitWindow(finish, definition, true), false, "R1 observed active ends exclusively")
	equal(Rules.shouldSampleHitWindow(finish, definition, false), true, "R1 entirely skipped window has one late query")
	equal(Rules.shouldSampleHitWindow(finish + 0.25, definition, false), true, "R1 late cap boundary included")
	equal(Rules.shouldSampleHitWindow(finish + 0.2501, definition, false), false, "R1 above late cap rejected")
	equal(Rules.shouldSampleHitWindow(finish + 3, definition, false), false, "R1 long pause cannot cause ghost hit")
	equal(Rules.shouldSampleHitWindow(0/0, definition, false), false, "R1 non-finite clock rejected")
end
equal(Rules.bufferCanExecute(0.416667, 0.42, 0.421), false, "R2 cannot execute before eligible")
equal(Rules.bufferCanExecute(0.42, 0.42, 0.421), true, "R2 eligible boundary included")
equal(Rules.bufferCanExecute(0.433333, 0.42, 0.421), true, "R2 next 60Hz frame consumes valid single input")
equal(Rules.bufferCanExecute(0.67, 0.42, 0.421), true, "R2 late cap boundary included")
equal(Rules.bufferCanExecute(0.6701, 0.42, 0.421), false, "R2 above late cap rejected")
equal(Rules.bufferCanExecute(3.42, 0.42, 0.421), false, "R2 long pause cannot cause ghost input")
equal(Rules.bufferCanExecute(0.42, 0.42, 0.42), false, "R2 eligible at expiry is rejected")
equal(Rules.bufferCanExecute(0.433333, 0.42, 0.419), false, "R2 genuinely expired before eligibility")
equal(Rules.bufferCanExecute(math.huge, 0.42, 0.421), false, "R2 infinite current clock rejected")
equal(Rules.bufferCanExecute(0.433333, 0/0, 0.421), false, "R2 non-finite eligibility rejected")
print("K0 rules: " .. checks .. " checks passed")
