-- Engine-independent K0 decisions; used by the server and by Lua boundary tests.
local Rules = {}

-- Experimental server-stall limits. These are not latency compensation.
Rules.MaxLateHit = 0.25
Rules.MaxLateBuffer = 0.25
Rules.TimeEpsilon = 1e-9 -- numeric roundoff only; not a network grace period

function Rules.isFinite(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Rules.phase(elapsed, attack)
	if elapsed < attack.windup then
		return "Windup"
	elseif elapsed < attack.windup + attack.active then
		return "Active"
	elseif elapsed < attack.windup + attack.active + attack.recovery then
		return "Recovery"
	end
	return "None"
end

-- The active interval is [windup, windup+active). A fully skipped interval
-- gets one late observation; an interval already observed does not get an
-- extra, potentially false, observation after it has ended.
function Rules.shouldSampleHitWindow(elapsed, attack, sampledActive)
	if not Rules.isFinite(elapsed) or elapsed < attack.windup then
		return false
	end
	local activeEnd = attack.windup + attack.active
	return elapsed < activeEnd or (not sampledActive and elapsed <= activeEnd + Rules.MaxLateHit + Rules.TimeEpsilon)
end

-- Buffer expiration is evaluated against when the command became eligible,
-- not when the next server frame happened to run.
function Rules.bufferCanExecute(current, eligibleAt, expires)
	return Rules.isFinite(current) and Rules.isFinite(eligibleAt) and Rules.isFinite(expires)
		and eligibleAt < expires and current >= eligibleAt and current <= eligibleAt + Rules.MaxLateBuffer + Rules.TimeEpsilon
end

function Rules.allowedInAttack(action, elapsed, attack)
	local recoveryStart = attack.windup + attack.active
	local attackEnd = recoveryStart + attack.recovery
	if action == "Attack" then
		return elapsed >= attackEnd
	elseif action == "Dodge" then
		return elapsed >= recoveryStart + 0.10
	elseif action == "BlockStart" then
		return elapsed >= math.max(recoveryStart, attackEnd - 0.10)
	end
	return false
end

function Rules.nextAllowedInAttack(action, attack)
	local recoveryStart = attack.windup + attack.active
	local attackEnd = recoveryStart + attack.recovery
	if action == "Attack" then
		return attackEnd
	elseif action == "Dodge" then
		return recoveryStart + 0.10
	elseif action == "BlockStart" then
		return math.max(recoveryStart, attackEnd - 0.10)
	end
	return math.huge
end

function Rules.withinCone(distance, height, facingDot, range, maxHeight, angle)
	return Rules.isFinite(distance) and Rules.isFinite(height) and Rules.isFinite(facingDot)
		and distance <= range and height <= maxHeight
		and (angle >= 360 or facingDot >= math.cos(math.rad(angle / 2)))
end

function Rules.movementBudget(budget, elapsed, distance, walkSpeed, capacity)
	if not Rules.isFinite(budget) or not Rules.isFinite(elapsed) or not Rules.isFinite(distance)
		or budget < 0 or elapsed < 0 or distance < 0 then
		return false, 0
	end
	local allowance = math.min(capacity, budget + walkSpeed * elapsed * 1.35)
	return distance <= allowance, math.max(0, allowance - distance)
end

function Rules.defense(isDodging, dodgeAge, isGuarding, guardAge, guardFacingDot, blockable, stamina, cost, guard, dodge)
	if isDodging and dodgeAge >= dodge.invulnerableStart and dodgeAge < dodge.invulnerableEnd then
		return "Dodge", 0, stamina
	end
	if not isGuarding or guardAge < guard.raiseTime or not blockable or not Rules.isFinite(guardFacingDot)
		or guardFacingDot < math.cos(math.rad(guard.angle / 2)) then
		return "Hit", 1, stamina
	end
	if guardAge < guard.raiseTime + guard.perfectTime then
		return "PerfectBlock", 0, stamina
	end
	if stamina < cost then
		return "GuardBroken", 1, 0
	end
	return "Blocked", guard.damageMultiplier, stamina - cost
end

function Rules.priority(action)
	return ({ Attack = 1, BlockStart = 2, Dodge = 3 })[action] or 0
end

return Rules
