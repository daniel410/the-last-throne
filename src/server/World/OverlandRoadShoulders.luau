-- Low native scenery on the existing JourneyPass slab.
local Kit = require(script.Parent.EpicEnvironmentKit)
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local palette = Kit.palette

local profiles = {
	['DW-07'] = {
		{'ConvoyVerge', palette.Deepwood.ground, M.Ground, 1.2, 16},
		{'RootwayShale', palette.Gloamwood.rock, M.Slate, 2.3, 14},
		{'RootwayShale', palette.Gloamwood.rock, M.Slate, 2.8, 17},
	},
	['GW-07'] = {
		{'WindgapShale', palette.Gloamwood.trim:Lerp(palette.Gloamwood.rock, .5), M.Slate, 2.7, 15},
		{'FirstSnowDrift', palette.FrozenVale.ground:Lerp(palette.FrozenVale.trim, .42), M.Snow, 2.1, 14},
		{'FirstSnowDrift', palette.FrozenVale.ground, M.Snow, 3.2, 17},
	},
	['FV-07'] = {
		{'ThawSnowbank', palette.FrozenVale.ground, M.Snow, 3.1, 23},
		{'ThawSnowbank', palette.FrozenVale.trim, M.Snow, 1.5, 16},
		{'ExposedBasalt', palette.EmberCaldera.rock, M.Basalt, 2.5, 21},
	},
	['EC-07'] = {
		{'CooledBasalt', palette.EmberCaldera.rock, M.Basalt, 2.8, 15},
		{'WeatheredRoadstone', C(111, 109, 113), M.Slate, 1.8, 14},
		{'KeeperRoadstone', palette.HauntedGraveyard.trim:Lerp(palette.HauntedGraveyard.rock, .36), M.Slate, 2.4, 16},
	},
}

local Shoulders = {}

function Shoulders.build(floor, sourceId, a, b)
	local root = Instance.new('Folder')
	root.Name = 'RoadShoulders'
	root.Parent = floor.Parent
	for index, spec in ipairs(profiles[sourceId]) do
		local name, color, material, height, length = table.unpack(spec)
		local toeColor = color:Lerp(C(73, 77, 83), .18)
		for _, side in ipairs({-1, 1}) do
			local t = .18 + (index - 1) * .32 + side * .035
			local z = floor.CFrame:PointToObjectSpace(a:Lerp(b, t)).Z
			local base = floor.CFrame * CFrame.new(side * 39, floor.Size.Y / 2, z)
			local toe = base * CFrame.new(-side * 1.1, .22, 0)
			Kit.part(root, name .. 'Toe', V(length + 3, 1, 10),
				toe * CFrame.Angles(0, side * math.pi / 2, 0), toeColor, material, 'Wedge')
			-- Wedge rises toward local +Z, which becomes the outside edge.
			local crest = base * CFrame.new(side * 1.3, height * .5 - .23, -.5)
				* CFrame.Angles(0, side * math.pi / 2, 0)
			Kit.part(root, name, V(length, height, 9.2), crest, color, material, 'Wedge')
		end
	end
end

return Shoulders
