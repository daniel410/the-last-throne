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
	return Rules.defense(dodging, dodgeAge, blocking, guardAge, dot, blockable, stamina, cost, g, d)
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
equal(stamina, 100, "perfect guard consumes no impact cost")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, true, 16, 16)
equal(outcome, "Blocked", "equal stamina pays block cost")
near(multiplier, 0.2, "ordinary block reduces damage")
equal(stamina, 0, "ordinary block can leave zero stamina")
outcome, multiplier, stamina = defense(false, 0, true, 0.25, 1, true, 15, 16)
equal(outcome, "GuardBroken", "insufficient stamina breaks guard")
equal(stamina, 0, "guard break drains remaining stamina")
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
print("K0 rules: " .. checks .. " checks passed")
