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
local scoria = C(103, 42, 28)
local outerCrust = C(83, 42, 37)
local melt = C(166, 50, 25)
local thread = C(140, 39, 9)
local slag = C(37, 28, 29)
local up = V(0, 1, 0)
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

local function buildLavaRibbon(root, rows)
	local edges = {}
	local centers = {}
	for i, row in ipairs(rows) do
		local at, left, right, seam, rise = table.unpack(row)
		local before = rows[math.max(1, i - 1)][1]
		local after = rows[math.min(#rows, i + 1)][1]
		local toward = (after - before).Unit
		local across = toward:Cross(up).Unit
		local outward = across:Cross(toward)
		local top = at + outward * rise
		centers[i] = top + across * seam
		edges[i] = {
			top - across * left - outward * .3,
			top - across * (left * .61 - seam),
			top + across * (right * .55 + seam),
			top + across * right - outward * .35,
		}
	end

	-- Every bend shares a cross-section with its neighbor. The liquid does not pinch shut at joints.
	for i = 1, #rows - 1 do
		local a, b = rows[i][1], rows[i + 1][1]
		local width = (rows[i][2] + rows[i][3] + rows[i + 1][2] + rows[i + 1][3]) * .5
		local length = (b - a).Magnitude
		local frame = CFrame.lookAt((a + b) / 2, b)
		contour(root, 'FusedBasaltGutter', V(width * 1.05, 2.8, length + width * .56),
			frame * CFrame.new(0, -1.47, 0), dark, M.Basalt, 'Ball')
		for j, color in ipairs({scoria, melt, outerCrust}) do
			local front, back = edges[i], edges[i + 1]
			local name = j ~= 2 and 'FracturedCrustMargin' or i == 3 and 'LavaCurtainCore' or 'MoltenRibbon'
			local mat = j == 2 and M.SmoothPlastic or M.Basalt
			Kit.triangle(root, name, front[j], back[j], front[j + 1], .12, color, mat)
			Kit.triangle(root, name, front[j + 1], back[j], back[j + 1], .12, color, mat)
		end
	end

	-- A few slowly moving, subdued ember pools break up the surface without outlining it.
	for _, i in ipairs({2, 3, 4, 6}) do
		local a, b = centers[i], centers[i + 1]
		local frame = CFrame.lookAt((a + b) / 2, b)
		local length = (b - a).Magnitude
		local side = i == 3 and -.73 or .41
		local offset = frame.UpVector * .27 + frame.RightVector * side
		local from = a:Lerp(b, .14) + offset
		local to = a:Lerp(b, .86) + offset
		local phase = (i * .37) % 1
		local streak = contour(root, 'AdvectingEmberStreak', V(i == 3 and 1.35 or .91, .14, length * .18),
			CFrame.lookAt(from:Lerp(to, phase), to), thread, M.Neon, 'Ball')
		streak.Transparency = .2
		Motion.track(streak, from, to, i == 3 and 3.6 or 2.3, phase)
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
	local out = point(23, basinHeight, 9)
	local lower = point(6, basinHeight + height * .065, 4.2)
	local shoulder = point(11.4, basinHeight, 8)
	local bank = bend(chute, lower, shoulder, out, .84)
	local intake = bend(chute, lower, shoulder, out, .39)
	local turnOut = bend(chute, lower, shoulder, out, .65)
	buildLavaRibbon(root, {
		{source, 3.75, 3.1, -.16, 1.15},
		{lip, 5.3, 3.9, .21, 1.1},
		{chute, 5.65, 4.35, -.67, 1.05},
		{intake, 5.05, 4.6, -.14, 1},
		{turnOut, 4.8, 6.2, .63, .81},
		{bank, 6.35, 5.75, -.37, .67},
		{out, 4.5, 4.9, .23, .48},
	})
	rock('SpillSlagFragment', turnOut + face.RightVector * (3.75 * turn), V(3.4, 1.25, 2.7), .48, slag, 'Corner')
	rock('SpillSlagFragment', bank - face.RightVector * (4.3 * turn), V(3.9, 1.1, 3.1), -.38, slag, 'Wedge')
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
