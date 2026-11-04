-- Directional shoulder roll: turn toward travel, compress, roll, plant, recover.
-- Server movement owns translation; this only poses the visual skeleton.
local Motion = {}

local function smooth(value)
	local x = math.clamp(value, 0, 1)
	return x * x * (3 - 2 * x)
end

function Motion.sample(age, duration, side)
	local u = math.clamp(age / duration, 0, 1)
	side = side == -1 and -1 or 1
	local prepare = smooth(u / 0.16)
	local recover = smooth((u - 0.78) / 0.22)
	local compressed = prepare * (1 - recover)
	local turn = smooth((u - 0.12) / 0.66)
	local tuck = smooth((u - 0.08) / 0.16) * (1 - smooth((u - 0.68) / 0.22))
	local facing = prepare * (1 - recover)
	-- Yaw first, then pitch in that local plane: a forward shoulder roll
	-- along either lateral direction, without a horizontal barrel spin.
	local pitch = -2 * math.pi * turn - math.rad(18) * compressed * (1 - turn)
	return {
		root = CFrame.new(0, -1.15 * compressed, 0)
			* CFrame.Angles(0, -side * math.pi / 2 * facing, 0)
			* CFrame.Angles(pitch, 0, math.rad(side * 12 * tuck)),
		-- Keep weapons close and lead with the shoulder instead of diving
		-- with both hands overhead. R6 uses the same compact silhouette.
		right = CFrame.Angles(math.rad(55 * compressed + 25 * tuck), math.rad(-12 * tuck), math.rad(18 * compressed)),
		left = CFrame.Angles(math.rad(65 * compressed + 25 * tuck), math.rad(12 * tuck), math.rad(-18 * compressed)),
		elbow = CFrame.Angles(math.rad(-85 * tuck), 0, 0),
		hip = CFrame.Angles(math.rad(-65 * tuck - 12 * compressed), 0, 0),
		knee = CFrame.Angles(math.rad(105 * tuck), 0, 0),
		neck = CFrame.Angles(math.rad(-22 * tuck), 0, 0),
	}
end

return Motion
