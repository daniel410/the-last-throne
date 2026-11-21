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
local scoria = C(91, 37, 27)
local molten = C(166, 41, 17)
local shear = C(209, 52, 14)
local shadedShear = C(165, 27, 8)
local ember = C(183, 37, 9)
local thread = C(224, 52, 14)
local slag = C(31, 25, 28)
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

local function channel(root, name, a, b, width, depth, speed)
	local length = (b - a).Magnitude
	local frame = CFrame.lookAt((a + b) / 2, b)
	local surface = depth * .38
	contour(root, name .. 'ScoriaBed', V(width, depth, length + .9), frame, scoria, M.Basalt, 'Ball')
	contour(root, name, V(width * .79, depth * .44, length + 1.15),
		frame * CFrame.new(width * -.025, surface, 0), molten, M.SmoothPlastic, 'Ball')

	-- Two lobes overlap the channel at different widths and tones as the melt splits around slag.
	for _, side in ipairs({-1, 1}) do
		local stretch = side < 0 and .76 or .57
		contour(root, 'MoltenShearLobe', V(width * .29, depth * .23, length * stretch),
			frame * CFrame.new(side * width * .16, surface + depth * .30, side * length * .13)
				* CFrame.Angles(0, side * .13, 0),
			side < 0 and shear or shadedShear, M.SmoothPlastic, 'Ball')
	end
	for _, side in ipairs({-1, 1}) do
		local z = side * length * .15
		local flake = frame * CFrame.new(side * width * .33, surface + depth * .10, z)
			* CFrame.Angles(0, side * .54, 0)
		contour(root, 'CooledSlagFlake', V(width * .31, math.max(.42, depth * .43), length * .27),
			flake, slag, M.Basalt, 'Wedge')
	end

	-- Short heat streaks move downslope. Nothing illuminates the surrounding rocks locally.
	for _, side in ipairs({-1, 1}) do
		local offset = V(side * width * .13, surface + depth * .45, 0)
		local from = frame * (offset + V(0, 0, length * .28))
		local to = frame * (offset - V(0, 0, length * .28))
		local phase = side < 0 and .22 or .63
		local vein = frame * CFrame.new(side * width * .11, surface + depth * .38, side * length * .105)
			* CFrame.Angles(0, -side * .10, 0)
		contour(root, 'GlowingFissure', V(width * .125, math.max(.09, depth * .10), length * (side < 0 and .69 or .49)),
			vein, ember, M.Neon)
		local streak = contour(root, 'AdvectingEmberStreak',
			V(width * (side < 0 and .20 or .125), math.max(.09, depth * .08), length * .21),
			CFrame.lookAt(from:Lerp(to, phase), to), thread, M.Neon)
		Motion.track(streak, from, to, speed * (side < 0 and 1 or .81), phase)
	end
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
	local toe = point(9, basinHeight, 8)
	local out = point(23, basinHeight, 9)
	local bedA, bedB = source - V(0, 1.4, 0), chute - V(0, 1.4, 0)
	contour(root, 'BasaltChuteBed', V(17, 4.5, (bedB - bedA).Magnitude + .6),
		CFrame.lookAt((bedA + bedB) / 2, bedB), dark, M.Basalt)
	channel(root, 'VentThroat', source, lip, 11, 3.0, 4.8)
	channel(root, 'RiftApron', lip, chute, 13, 3.2, 6)
	channel(root, 'LavaCurtainCore', chute, toe, 12, 3.6, 10)
	channel(root, 'LavaBasinCore', toe, out, 17, 1.8, 3.4)
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
