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
	local function smooth(value)
		local x = math.max(0, math.min(1, value))
		return x * x * (3 - 2 * x)
	end
	local launch = smooth(u / 0.18)
	local stand = smooth((u - 0.90) / 0.10)
	local landing = smooth((u - 0.56) / 0.34)
	local tuck = smooth((u - 0.52) / 0.12) * (1 - stand)
	local flight = launch * (1 - smooth((u - 0.52) / 0.12))
	-- Stretch out in the travel direction first. Only the landing contains a
	-- full forward roll; yaw selects left/right instead of a sideways cartwheel.
	local roll = -2 * math.pi * landing
	local pitch = -math.pi / 2 * launch + roll + math.pi / 2 * stand
	local yaw = -side * math.pi / 2 * launch * (1 - stand)
	local lift = u < 0.60 and jumpHeight * math.sin(math.pi * u / 0.60)
		or -0.65 * math.sin(math.pi * (u - 0.60) / 0.40)
	return roll, lift, tuck, flight, pitch, yaw
end

return DodgeRules
