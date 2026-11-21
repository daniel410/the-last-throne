-- Basalt vents discharge into the existing scenic cut outside the playable caldera.
local Kit = require(script.Parent.EpicEnvironmentKit)
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local profiles = {
	['EC-01'] = {1, -151, 63, 1, 'AshSpireVent'},
	['EC-03'] = {-1, 142, 38, -1, 'MineFractureFlow'},
	['EC-04'] = {1, -153, 39, 1, 'CoolingRiftFlow'},
	['EC-07'] = {-1, -132, 57, -1, 'FurnaceRimVent'},
}

local dark = C(53, 44, 48)
local cooled = C(74, 56, 54)
local crust = C(164, 54, 21)
local hot = C(255, 129, 38)
local Lava = {}

local function strand(root, name, a, b, width, depth, color, material)
	local part = Kit.part(root, name, V(width, depth, (b-a).Magnitude + .6),
		CFrame.lookAt((a+b)/2, b), color, material)
	part.CastShadow = false
	return part
end

function Lava.build(parent, id, center, size, safe)
	local spec = profiles[id]
	if not spec then return false end
	local side, z, height, turn, name = table.unpack(spec)
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
	local source = point(0, height * .45, -13)
	local lip = point(2, height * .37, -5)
	local chute = point(5, height * .24, 1)
	local toe = point(9, -14, 8)
	local out = point(23, -14, 9)
	strand(root, 'BasaltChuteBed', source - V(0, 1.4, 0), chute - V(0, 1.4, 0), 17, 4.5, dark, M.Basalt)
	strand(root, 'VentThroat', source, lip, 11, 3.0, crust, M.Slate)
	strand(root, 'MoltenLip', source + V(0, .7, 0), lip + V(0, .7, 0), 5, 1.7, hot, M.Neon)
	strand(root, 'RiftApron', lip, chute, 13, 3.2, crust, M.Slate)
	strand(root, 'MoltenApron', lip + V(0, .7, 0), chute + V(0, .7, 0), 6, 1.9, hot, M.Neon)
	strand(root, 'LavaCurtainCrust', chute, toe, 12, 3.6, crust, M.Slate)
	strand(root, 'LavaCurtainCore', chute + V(-side * .8, .35, 0), toe + V(-side * .8, .35, 0), 6.5, 2.5, hot, M.Neon)
	strand(root, 'LavaBasinCrust', toe, out, 17, 1.8, crust, M.Slate)
	strand(root, 'LavaBasinCore', toe + V(0, .88, 0), out + V(0, .88, 0), 8, .6, hot, M.Neon)
	for _, bank in ipairs({-1, 1}) do
		rock('CooledBasinBank', point(16, -17, 9 + bank * 9), V(27, 8, 8), bank * .12, dark, 'Wedge')
	end
	root:SetAttribute('Source', source)
	root:SetAttribute('Outlet', out)
	root.Parent = parent
	return true
end

return Lava
