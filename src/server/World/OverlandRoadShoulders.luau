-- Native scenery on the existing JourneyPass slab.
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
		{'ExposedBasalt'},
	},
	['EC-07'] = {
		{'CooledBasalt', palette.EmberCaldera.rock, M.Basalt, 2.8, 15},
		{'WeatheredRoadstone', C(111, 109, 113), M.Slate, 1.8, 14},
		{'KeeperRoadstone', palette.HauntedGraveyard.trim:Lerp(palette.HauntedGraveyard.rock, .36), M.Slate, 2.4, 16},
	},
}

local basalt = palette.EmberCaldera.rock
local fracture = palette.EmberCaldera.trim:Lerp(palette.FrozenVale.ground, .37)
local heartwood = palette.Deepwood.wood:Lerp(palette.Deepwood.trim, .61)

local function buildBasaltOutcrop(root, base, side)
	local relief = side == 1 and 1 or .79
	-- The eroded apron seats the exposed, jointed rocks at the edge of the thaw.
	Kit.part(root, 'BasaltTalus', V(23, 1.6, 11),
		base * CFrame.new(-side * .42, .5, 0) * CFrame.Angles(0, side * math.pi / 2, 0),
		basalt:Lerp(palette.EmberCaldera.ground, .55), M.Basalt, 'Wedge')

	-- The irregular crown reads in silhouette against the broad banks behind it.
	local joints = {
		{side * 1.2, -5.8, 4.5, 4.2, .28},
		{side * 1.7, -.3, 5.8, 5.16, -.4},
		{side * 2.5, 5.3, 5.2, 4.35, -.18},
	}
	for index, joint in ipairs(joints) do
		local x, z, width, height, yaw = table.unpack(joint)
		height *= relief
		local pivot = base * CFrame.new(x, -.28, z) * CFrame.Angles(0, yaw * side, 0)
		local color = basalt:Lerp(fracture, .30 + .05 * index)
		local depth = width * .98
		local fractureHeight = 1.68
		Kit.part(root, 'JointedBasalt', V(width, height, depth),
			pivot * CFrame.new(0, height * .5, 0), color, M.Basalt)
		Kit.part(root, 'BasaltFracture', V(width, fractureHeight, depth),
			pivot * CFrame.new(0, height + fractureHeight * .5 - .09, 0), fracture, M.Slate, 'Wedge')
	end
end

local function dressVerge(root, name, base, side)
	if name == 'ConvoyVerge' then
		Kit.part(root, 'ExposedVergeRoot', V(2.5, 2.9, 16.2),
			base * CFrame.new(side * 2.3, 1.16, .2) * CFrame.Angles(0, side * .24, 0),
			heartwood, M.Wood, 'Wedge')
		if side == -1 then
			Kit.part(root, 'ExposedVergeRoot', V(1.55, 1.95, 8),
				base * CFrame.new(-side * .15, .68, -1.25) * CFrame.Angles(0, side * .77, 0),
				heartwood:Lerp(palette.Deepwood.wood, .24), M.Wood, 'Wedge')
		end
	elseif name == 'WindgapShale' then
		-- The first packed snow collects in the lee of the dark shale.
		Kit.part(root, 'WindPackedSnow', V(5.8, 1.7, 15.4),
			base * CFrame.new(-side * 2.2, .55, -.9) * CFrame.Angles(0, side * .11, 0),
			palette.FrozenVale.ground:Lerp(palette.FrozenVale.trim, .26), M.Snow, 'Wedge')
	elseif name == 'KeeperRoadstone' then
		-- Surviving dressed stones mark the beginning of the keeper road.
		for offset = -1, 1 do
			local wear = math.abs(offset)
			local height = 2.11 - wear * .48
			local color = palette.HauntedGraveyard.trim:Lerp(palette.HauntedGraveyard.rock, .14 + wear * .16)
			Kit.part(root, 'KeeperDressedStone', V(4.25 - wear * .45, height, 3.76 - wear * .2),
				base * CFrame.new(-side * (2.85 + offset * .38), height * .5 - .25, offset * 3.54)
					* CFrame.Angles(0, side * offset * .085, 0), color, M.Slate)
		end
	end
end

local Shoulders = {}

function Shoulders.build(floor, sourceId, a, b)
	local root = Instance.new('Folder')
	root.Name = 'RoadShoulders'
	root.Parent = floor.Parent
	for index, spec in ipairs(profiles[sourceId]) do
		local name, color, material, height, length = table.unpack(spec)
		for _, side in ipairs({-1, 1}) do
			local t = .18 + (index - 1) * .32 + side * .035
			if name == 'ExposedBasalt' and side == 1 then t = .59 end
			local z = floor.CFrame:PointToObjectSpace(a:Lerp(b, t)).Z
			local base = floor.CFrame * CFrame.new(side * 39, floor.Size.Y / 2, z)
			if name == 'ExposedBasalt' then
				buildBasaltOutcrop(root, base, side)
			else
				local toeColor = color:Lerp(C(73, 77, 83), .18)
				local toe = base * CFrame.new(-side * 1.1, .22, 0)
				Kit.part(root, name .. 'Toe', V(length + 3, 1, 10),
					toe * CFrame.Angles(0, side * math.pi / 2, 0), toeColor, material, 'Wedge')
				-- Wedge rises toward local +Z, which becomes the outside edge.
				local crest = base * CFrame.new(side * 1.3, height * .5 - .23, -.5)
					* CFrame.Angles(0, side * math.pi / 2, 0)
				Kit.part(root, name, V(length, height, 9.2), crest, color, material, 'Wedge')
				dressVerge(root, name, base, side)
				if name == 'RootwayShale' and index == 2 and side == 1 then
					-- A second exposed root marks the same shoulder on the return from Gloamwood.
					Kit.part(root, 'ExposedVergeRoot', V(2.6, 2.75, 15),
						base * CFrame.new(-.65, 1.08, -.2) * CFrame.Angles(0, -.29, 0),
						heartwood:Lerp(palette.Deepwood.wood, .12), M.Wood, 'Wedge')
				end
				if sourceId == 'FV-07' and index == 2 then
					local melt = base * CFrame.new(-side * 3.2, .23, 2.4)
						* CFrame.Angles(0, side * (math.pi / 2 + .12), 0)
					Kit.part(root, 'ExposedMeltEdge', V(12, 1, 4.2), melt,
						basalt:Lerp(palette.EmberCaldera.trim, .18), M.Basalt, 'Wedge')
				end
			end
		end
	end
end

return Shoulders
