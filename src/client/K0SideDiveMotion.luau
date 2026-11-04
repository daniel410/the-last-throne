-- A low sideways breakfall. Rotate around the laid-out body's long axis,
-- rather than cartwheeling the feet over the head. No physics-root movement.
local Motion = {}

local function smooth(value)
	local x = math.clamp(value, 0, 1)
	return x * x * (3 - 2 * x)
end

function Motion.sample(age, duration, side)
	local u = math.clamp(age / duration, 0, 1)
	side = side == -1 and -1 or 1
	local launch = smooth(u / 0.26)
	local stand = smooth((u - 0.84) / 0.16)
	local low = launch * (1 - stand)
	local turn = smooth((u - 0.36) / 0.46)
	local reach = smooth(u / 0.12) * (1 - smooth((u - 0.30) / 0.16))
	local brace = smooth((u - 0.30) / 0.16) * (1 - stand)
	return {
		root = CFrame.new(0, -1.15 * low + 0.18 * math.sin(math.pi * u) * (1 - launch), 0)
			* CFrame.Angles(0, 0, -side * math.pi / 2 * low)
			* CFrame.Angles(0, side * 2 * math.pi * turn, 0),
		-- Both hands reach toward the chosen side before bending for contact.
		right = CFrame.Angles(math.rad(35 * brace), 0, math.rad(side * 85 * reach + 18 * brace)),
		left = CFrame.Angles(math.rad(35 * brace), 0, math.rad(side * 85 * reach - 18 * brace)),
		elbow = CFrame.Angles(math.rad(-65 * brace), 0, 0),
		hip = CFrame.Angles(math.rad(-25 * brace), 0, 0),
		knee = CFrame.Angles(math.rad(65 * brace), 0, 0),
		neck = CFrame.Angles(math.rad(12 * brace), 0, 0),
	}
end

return Motion
