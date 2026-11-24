-- Lower, inactive route fixtures beside the sixth chapters' authored actions.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local halfTurn = math.pi

local function shelterMarkRootPocket(pal, part, beam)
	local earth = pal.ground:Lerp(C(119, 90, 59), .73)
	local silt = earth:Lerp(C(66, 51, 47), .73)
	local stone = pal.rock:Lerp(C(166, 143, 99), .62)
	local wood = pal.wood:Lerp(C(149, 108, 67), .55)

	part('RefugeEarthShoulder', V(5.68, .92, 7.60), V(0, .23, .15), earth, M.Ground, 'Corner', V(0, -.24, 0))
	part('RootPocketSilt', V(3.02, .29, 4.54), V(.31, .12, .08), silt, M.Mud, 'Wedge', V(0, .14, 0))
	part('SetShelterKerb', V(1.22, .82, 5.60), V(-1.48, .38, .12), stone, M.Slate, nil, V(0, -.13, 0))
	part('ShelterKerbReturn', V(2.08, .64, 1.22), V(-.96, .25, -2.51), stone, M.Slate,
		'Wedge', V(0, halfTurn + .16, 0))
	part('ShelterKerbFacing', V(.39, .24, 4.37), V(-.85, .70, .19), stone:Lerp(pal.trim, .36),
		M.Limestone, nil, V(0, -.13, 0))
	beam('RefugeRootCrown', V(-2.50, .15, 2.65), V(-1.57, 1.18, 1.57), .93, wood, M.Wood)
	beam('RefugeRootTaper', V(-1.57, 1.18, 1.57), V(.50, .23, .78), .58, wood, M.Wood)
	part('RefugeKerbTimberWedge', V(.60, .47, 1.46), V(-.65, .25, -1.72), wood:Lerp(stone, .3),
		M.Wood, 'Wedge', V(0, -.21, 0))
end

local function rearguardRopeTurnFooting(pal, part, beam)
	local shale = pal.rock:Lerp(C(124, 125, 115), .68)
	local wood = pal.wood:Lerp(C(152, 115, 86), .72)
	local rope = C(184, 156, 112)

	part('RopeTurnShaleToe', V(6.30, .77, 6.78), V(0, .23, 0), shale, M.Slate, 'Corner', V(0, .27, 0))
	part('RopeTurnExposedStone', V(4.90, .45, 1.47), V(-.22, .21, -.98), shale:Lerp(pal.trim, .24),
		M.Slate, 'Wedge', V(0, -.30, 0))
	beam('RopeTurnRoot', V(-2.45, .14, .51), V(-.10, .82, .89), .67, wood, M.Wood)
	beam('RopeTurnExposedRoot', V(-.10, .82, .89), V(2.56, .19, 2.14), .49,
		wood:Lerp(C(199, 163, 121), .36), M.Wood)
	for _, x in ipairs({-1.65, 1.65}) do
		local z = .53 - x * .34
		part('ScoutRopeStake', V(.44, 1.91, .47), V(x, .90, z), wood, M.Wood, nil, V(.11, 0, x * .04))
		part('ScoutStakeLashing', V(.55, .27, .57), V(x, 1.48, z), rope, M.Fabric)
		beam('TurnGuideRope', V(x, 1.48, z), V(.20, 1.16, .15), .17, rope, M.Fabric)
	end
end

local function villageRelayWindbreak(pal, part)
	local slate = pal.rock:Lerp(C(93, 103, 122), .63)
	local ice = pal.trim:Lerp(C(92, 134, 152), .55)
	local dressed = slate:Lerp(pal.ground, .38)
	local bronze = C(134, 104, 72)

	part('RelayWindbreakFoundation', V(4.96, .60, 7.12), V(0, .19, 0), slate, M.Cobblestone)
	part('RelayWindbreakFace', V(1.68, 1.51, 6.58), V(.46, .96, 0), slate, M.Slate)
	part('RelayWindbreakCoping', V(2.29, .42, 6.88), V(.46, 1.88, 0), dressed, M.Slate)
	part('RelayWindScour', V(3.27, .81, 6.87), V(-1.34, .36, -.12), pal.ground, M.Snow,
		'Wedge', V(0, math.pi / 2, 0))
	part('RelayExposedIceRim', V(.99, .38, 5.94), V(-1.69, .33, -.21), ice, M.Glacier,
		'Wedge', V(0, math.pi / 2 + .12, 0))
	for _, z in ipairs({-2.52, 2.52}) do
		part('WindbreakReturnStone', V(2.90, 1.21, .95), V(.32, .65, z), dressed, M.Slate,
			'Wedge', V(0, -math.pi / 2, 0))
		part('DormantRelayAnchor', V(.25, .64, .72), V(1.38, 1.10, z), bronze, M.CorrodedMetal)
	end
end

local function coldSideRailSaddle(pal, part, beam)
	local basalt = pal.rock:Lerp(C(75, 73, 76), .68)
	local firestone = basalt:Lerp(C(159, 131, 106), .61)
	local metal = C(90, 132, 132)
	local clamp = metal:Lerp(C(146, 156, 142), .54)

	part('ColdSideBasaltShoulder', V(5.89, .74, 7.48), V(0, .16, .09), basalt, M.Basalt,
		'Corner', V(0, .18, 0))
	part('ColdSideServiceTread', V(1.68, .43, 6.83), V(-1.72, .21, 0), firestone, M.Slate)
	for _, z in ipairs({-2.69, 2.38}) do
		part('RailSaddleStone', V(2.02, .79, 1.42), V(.48, .55, z), basalt, M.Basalt)
		part('RailSaddleWeb', V(.46, 1.18, .55), V(.48, 1.41, z), metal, M.CorrodedMetal)
		part('RailSaddleClamp', V(.91, .39, .51), V(.48, 1.95, z), clamp, M.Metal)
	end
	beam('ColdSideGuardRail', V(.48, 1.95, -2.69), V(.48, 1.95, 2.38), .39, metal, M.Metal)
	beam('ColdSideReturnedRail', V(.48, 1.95, 2.38), V(1.31, 1.43, 3.63), .39, metal, M.Metal)
end

local function royalRecordWallRecess(pal, part)
	local stone = pal.rock:Lerp(C(104, 108, 111), .64)
	local dressed = stone:Lerp(C(165, 155, 133), .70)
	local worn = dressed:Lerp(C(182, 174, 156), .66)

	part('TombRecessStoneBed', V(6.16, .64, 4.60), V(0, .18, 0), stone, M.Cobblestone)
	part('TombRecessBackWall', V(4.75, 2.54, .73), V(0, 1.57, -.91), stone, M.Slate)
	for _, x in ipairs({-1.92, 1.92}) do
		part('TombRecessQuoin', V(1.18, 2.46, 2.49), V(x, 1.48, -.16), stone, M.Cobblestone)
		part('TombRecessLintelShoulder', V(1.13, .74, 1.58), V(x * .82, 2.94, -.14), dressed,
			M.Limestone, 'Wedge', V(0, math.sign(x) * math.pi / 2, 0))
	end
	part('TombRecessLintel', V(2.82, .60, 1.45), V(0, 3.13, -.18), dressed, M.Limestone)
	part('WornRecordLedge', V(3.70, .48, 2.02), V(0, 1.16, .62), worn, M.Limestone)
	part('TombRecessCourseLine', V(3.63, .10, .12), V(0, .97, 1.69), stone, M.Slate)
end

return {
	['DW-06'] = {goal = 'exp_2', step = 1, name = 'ShelterMarkRootPocket', side = -11, compose = shelterMarkRootPocket},
	['GW-06'] = {goal = 'exp_2', name = 'RearguardRopeTurnFooting', offset = V(-11, 0, 8), compose = rearguardRopeTurnFooting},
	['FV-06'] = {goal = 'exp_2', step = 2, name = 'VillageRelayWindbreak', side = 12, compose = villageRelayWindbreak},
	['EC-06'] = {goal = 'exp_1', step = 1, name = 'ColdSideRailSaddle', side = -11, compose = coldSideRailSaddle},
	['HG-06'] = {goal = 'exp_1', step = 1, name = 'RoyalRecordWallRecess', side = -11, compose = royalRecordWallRecess},
}
