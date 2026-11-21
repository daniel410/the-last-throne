-- Basalt vents discharge into the existing scenic cut outside the playable caldera.
local Kit = require(script.Parent.EpicEnvironmentKit)
local Motion = require(script.Parent.ScenicFlowMarkers)
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local profiles = {
	['EC-01'] = {1, 155, 100, 1, 'AshSpireVent', 36},
	['EC-03'] = {-1, 142, 38, -1, 'MineFractureFlow'},
	['EC-04'] = {1, -153, 39, 1, 'CoolingRiftFlow'},
	['EC-07'] = {-1, -132, 57, -1, 'FurnaceRimVent'},
}

local dark = C(53, 44, 48)
local cooled = C(74, 56, 54)
local scoria = C(77, 35, 30)
local molten = C(164, 48, 23)
local shear = C(201, 71, 30)
local ember = C(142, 39, 9)
local thread = C(166, 49, 12)
local slag = C(37, 28, 29)
local Lava = {}

local function contour(root, name, size, frame, color, material, shape)
	local part
	if shape == 'Ball' then
		part = Kit.ellipsoid(root, name, size, frame, color, material)
	else
		part = Kit.part(root, name, size, frame, color, material, shape)
	end
	part.CastShadow = false
	return part
end

local function bend(start, lower, shoulder, outlet, t)
	local upper = start:Lerp(lower, t)
	local middle = lower:Lerp(shoulder, t)
	local foot = shoulder:Lerp(outlet, t)
	return upper:Lerp(middle, t):Lerp(middle:Lerp(foot, t), t)
end

local function channel(root, name, a, b, width, depth, speed, side)
	local length = (b - a).Magnitude
	local frame = CFrame.lookAt((a + b) / 2, b)
	local surface = depth * .34
	-- An overlapping rock gutter carries the melt at every join, including where it fans out.
	contour(root, 'FusedBasaltGutter', V(width * .92, depth * 1.34, length + width * .36),
		frame * CFrame.new(0, -depth * .64, 0), dark, M.Basalt, 'Ball')
	contour(root, 'ScoriaContactSkin', V(width * .98, depth * .62, length + width * .32),
		frame * CFrame.new(0, -depth * .05, 0), scoria, M.Basalt, 'Ball')
	contour(root, name, V(width * .74, depth * .47, length + width * .36),
		frame * CFrame.new(width * .04, surface, 0), molten, M.SmoothPlastic, 'Ball')

	-- The cooler edge overlaps the melt. The warmer tongue winds past it without a sharp parallel edge.
	local slagFrame = frame * CFrame.new(side * width * .31, surface - depth * .13, length * .09)
		* CFrame.Angles(0, side * .38, 0)
	contour(root, 'SinteredBasaltLip', V(width * .35, depth * .62, length * .75),
		slagFrame, slag, M.Basalt, 'Ball')
	contour(root, 'MoltenShearLobe', V(width * .37, depth * .26, length * .94 + width * .17),
		frame * CFrame.new(-side * width * .09, surface + depth * .17, -length * .037)
			* CFrame.Angles(0, side * .05, 0),
		shear, M.SmoothPlastic, 'Ball')

	for i, z in ipairs({.22, -.19}) do
		local x = side * width * (i == 1 and .095 or -.17)
		local vein = frame * CFrame.new(x, surface + depth * .30, length * z)
			* CFrame.Angles(0, z * side * .57, 0)
		contour(root, 'GlowingFissure', V(width * (i == 1 and .13 or .095), .14, length * (i == 1 and .26 or .19)),
			vein, ember, M.Neon, 'Ball')
	end
	local offset = V(-side * width * .04, surface + depth * .37, 0)
	local from = frame * (offset + V(0, 0, length * .25))
	local to = frame * (offset - V(0, 0, length * .25))
	local phase = side < 0 and .24 or .61
	local streak = contour(root, 'AdvectingEmberStreak', V(width * .135, .16, length * .22),
		CFrame.lookAt(from:Lerp(to, phase), to), thread, M.Neon, 'Ball')
	Motion.track(streak, from, to, speed, phase)
end

function Lava.build(parent, id, center, size, safe)
	local spec = profiles[id]
	if not spec then return false end
	local side, z, height, turn, name, basinHeight = table.unpack(spec)
	basinHeight = basinHeight or -14
	local at = center + V(side * (size[1]/2 + 77), 0, z)
	if not safe(at, 66) then return false end
	local root = Instance.new('Model')
	root.Name = name
	root.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	local face = CFrame.lookAt(at, at + V(-side, 0, 0))
	local function point(x, y, forward)
		return face * V(x * turn, y, -forward)
	end
	local function rock(partName, position, scale, yaw, color, shape)
		return Kit.part(root, partName, scale, CFrame.new(position) * face.Rotation * CFrame.Angles(0, yaw, 0),
			color, M.Basalt, shape)
	end

	-- The vent has a broken rim. Its lower lip follows the channel toward the play-facing edge.
	rock('BuriedVentFoot', point(0, -30, -14), V(50, 58, 34), 0, dark)
	rock('BrokenVentBack', point(1, height * .43, -30), V(48, height * 1.05, 24), .18, cooled, 'Wedge')
	for _, bank in ipairs({-1, 1}) do
		local rise = bank == -1 and 1 or .80
		rock('FracturedCraterRim', point(bank * 19, height * .37, -12),
			V(24, height * 1.12 * rise, 40), bank * .35, cooled, 'Wedge')
	end
	local head = math.max(0, basinHeight)
	local source = point(0, head + height * .45, -13)
	local lip = point(2, head + height * .37, -5)
	local chute = point(5, head + height * .24, 1)
	local out = point(23, basinHeight, 9)
	local lower = point(6, basinHeight + height * .065, 4.2)
	local shoulder = point(11.4, basinHeight, 8)
	local bank = bend(chute, lower, shoulder, out, .84)
	local intake = bend(chute, lower, shoulder, out, .39)
	local turnOut = bend(chute, lower, shoulder, out, .65)
	channel(root, 'VentThroat', source, lip, 10.8, 3.0, 4.8, -1)
	channel(root, 'RiftApron', lip, chute, 11.9, 3.2, 6, 1)
	channel(root, 'LavaCurtainCore', chute, intake, 11.5, 3.6, 8.1, -1)
	channel(root, 'LavaCurtainFoot', intake, turnOut, 11.7, 3.2, 7, 1)
	channel(root, 'LavaSpillFan', turnOut, bank, 13.7, 2.7, 5.1, -1)
	channel(root, 'LavaBasinCore', bank, out, 15.4, 1.8, 3.4, 1)
	-- Seat the top of the channel in the vent, and the fan between the existing basin banks.
	local bedA, bedB = source - V(0, 1.4, 0), chute - V(0, 1.4, 0)
	contour(root, 'BasaltChuteBed', V(17, 4.5, (bedB - bedA).Magnitude + .6),
		CFrame.lookAt((bedA + bedB) / 2, bedB), dark, M.Basalt)
	rock('CrustedBasinOutlet', point(24, basinHeight - 1.1, 9.7), V(7, 2.8, 12.7), -.28, dark, 'Wedge')
	if basinHeight > 0 then
		rock('BasaltBasinShelf', point(16, (basinHeight - 8) / 2, 9), V(28, basinHeight + 6.4, 18), .06, dark)
	end
	for _, bank in ipairs({-1, 1}) do
		rock('CooledBasinBank', point(16, basinHeight - 3, 9 + bank * 9), V(27, 8, 8), bank * .12, dark, 'Wedge')
	end
	root:SetAttribute('Source', source)
	root:SetAttribute('Outlet', out)
	root.Parent = parent
	return true
end

return Lava
