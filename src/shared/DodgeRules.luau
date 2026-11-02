-- Server timing decides the second tap; clients only sample its accepted pose.
local DodgeRules = {}

function DodgeRules.canRoll(dodge, current, window)
	return dodge ~= nil and dodge.kind == "Backstep"
		and current > dodge.started and current - dodge.started <= window + 1e-9
end

function DodgeRules.rollSide(lateral)
	return lateral < -0.15 and -1 or 1
end

function DodgeRules.rollPose(age, duration, side, jumpHeight)
	local u = math.max(0, math.min(1, age / duration))
	local progress = u * u * (3 - 2 * u)
	local tuck = math.sin(math.pi * u)
	return -2 * math.pi * side * progress, jumpHeight * tuck, tuck
end

return DodgeRules
