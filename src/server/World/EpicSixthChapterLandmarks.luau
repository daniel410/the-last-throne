-- Inactive fixtures at the sixth chapters' shelter, service, and return routes.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function refugePathDrain(pal, part, beam)
	local silt = pal.ground:Lerp(C(111, 81, 56), .57)
	local stone = pal.rock:Lerp(C(149, 129, 93), .61)
	local bed = stone:Lerp(silt, .62)
	local root = pal.wood:Lerp(C(141, 101, 64), .46)

	part('ScouredRefugeBank', V(5.8, .68, 8.4), V(.08, .16, .11), silt, M.Ground, 'Corner', V(0, .19, 0))
	part('DrainStoneFoundation', V(4.32, .65, 6.6), V(0, .22, .15), bed, M.Cobblestone)
	local wetBed = bed:Lerp(C(53, 48, 39), .72)
	part('DarkDrainBed', V(1.57, .19, 6.88), V(0, .56, .01), wetBed, M.Pebble)
	part('SiltFanBelowDrain', V(2.12, .27, 1.51), V(.12, .33, -3.37), wetBed, M.Ground, 'Wedge',
		V(0, .09, 0))
	part('ExposedOutletSilt', V(1.32, .17, 1.31), V(.59, .64, 3.34), silt:Lerp(wetBed, .77), M.Pebble,
		'Wedge', V(0, math.pi + .18, 0))
	for _, x in ipairs({-1.37, 1.37}) do
		part('WornDrainCheek', V(1.08, .66, 5.50), V(x, .75, .16), stone, M.Slate, nil, V(0, x * .05, 0))
		for _, flow in ipairs({-1, 1}) do
			part('FlaredDrainMouth', V(.89, .55, 1.45), V(x * 1.12, .52, flow * 3.02), stone, M.Slate, 'Wedge',
				V(0, (flow == -1 and 0 or math.pi) + x * flow * .18, 0))
		end
	end
	part('DrainCrossingLintel', V(3.61, .40, 1.19), V(.03, 1.20, .61), stone:Lerp(C(178, 157, 115), .33),
		M.Slate, nil, V(0, -.07, .04))
	part('WornOutletStone', V(.78, .19, 1.07), V(1.58, .79, 2.88), stone:Lerp(C(181, 158, 118), .59),
		M.Slate, 'Wedge', V(0, math.pi + .18, 0))
	beam('RootAboveDrain', V(-2.71, .38, 2.52), V(-.99, 1.12, 2.01), .63, root, M.Wood)
	beam('RootAboveDrain', V(-.99, 1.12, 2.01), V(.13, .44, 2.88), .46, root, M.Wood)
end

local function scoutExtractionSkid(pal, part, beam)
	local shale = pal.rock:Lerp(C(141, 146, 136), .66)
	local wood = pal.wood:Lerp(C(193, 163, 119), .84)
	local track = pal.ground:Lerp(C(85, 69, 58), .54)
	local lash = C(190, 147, 97)
	local endGrain = wood:Lerp(C(224, 201, 157), .69)
	local pullRope = C(228, 198, 151)

	part('ExtractionWornShoulder', V(5.86, .58, 8.14), V(.09, .16, .12), track, M.Ground, 'Wedge')
	part('ExtractionShaleSeat', V(4.08, .63, 5.34), V(.12, .26, .57), shale, M.Slate, 'Corner',
		V(0, -.29, 0))
	for _, x in ipairs({-1.07, 1.07}) do
		beam('SkidRunner', V(x, .68, -2.64), V(x, .43, 2.59), .40, wood, M.Wood)
		beam('CurvedSkidNose', V(x, .68, -2.64), V(x * .92, 1.34, -3.25), .37, endGrain, M.Wood)
		part('TowBarLashing', V(.34, .42, .38), V(x * .90, 1.29, -3.13), lash, M.Leather)
		part('RunnerBinding', V(.48, .34, .43), V(x, .79, -1.78), lash, M.Fabric)
	end
	part('SkidTowCrossbar', V(2.13, .27, .30), V(0, 1.29, -3.10), endGrain, M.Wood)
	local ropeBight = V(0, 1.16, -3.66)
	beam('SkidPullRope', V(-.88, 1.42, -3.15), ropeBight, .25, pullRope, M.Fabric)
	beam('SkidPullRope', ropeBight, V(.88, 1.42, -3.15), .25, pullRope, M.Fabric)
	for _, z in ipairs({-1.56, -.46, .65, 1.75}) do
		part('EmptySkidSlat', V(2.62, .25, .72), V(0, .81 - z * .046, z), wood:Lerp(shale, .13), M.WoodPlanks)
	end
end

local function citadelServiceCoping(pal, part)
	local slate = pal.rock:Lerp(C(107, 123, 139), .63)
	local ice = pal.ground:Lerp(slate, .32)
	local cut = pal.trim:Lerp(slate, .51)
	local iron = C(73, 90, 104)

	part('CitadelWindPackedToe', V(6.30, .92, 8.41), V(.25, .26, .12), ice, M.Snow, 'Corner', V(0, -.24, 0))
	part('CitadelServiceBed', V(4.44, .72, 7.45), V(.03, .23, .21), slate, M.Slate)
	part('CitadelPackedSnowLip', V(2.88, .60, 4.93), V(-1.17, .58, .66), pal.ground, M.Snow, 'Wedge')
	part('WindScouredStoneMargin', V(.72, .25, 4.78), V(-.04, .69, .61), slate:Lerp(iron, .58), M.Slate,
		nil, V(0, -.07, 0))
	part('ExposedServiceWallToe', V(1.93, .29, .76), V(.39, .69, 3.48), slate:Lerp(cut, .28), M.Slate)
	for _, z in ipairs({-2.10, 1.90}) do
		part('ServiceWallDressedCourse', V(2.43, 1.06, 3.66), V(.40, 1.07, z), slate, M.Slate)
		part('SplitServiceCoping', V(2.81, .40, 3.53), V(.40, 1.76, z), cut, M.Slate, 'Wedge',
			V(0, z < 0 and 0 or math.pi, 0))
	end
	local sleeveX, sleeveY = 2.15, 1.51
	part('RecessedRelaySleeve', V(4.81, .75, .75), V(sleeveX, sleeveY, -.62), iron, M.CorrodedMetal, 'Cylinder',
		V(0, math.pi / 2, 0))
	for _, z in ipairs({-3.05, 1.80}) do
		part('ServiceSleeveFlange', V(.29, 1.22, 1.22), V(sleeveX, sleeveY, z), iron:Lerp(cut, .68), M.Metal,
			'Cylinder', V(0, math.pi / 2, 0))
		part('BlindFlangePlate', V(.13, .78, .78), V(sleeveX, sleeveY, z + (z < 0 and -.16 or .16)), iron,
			M.CorrodedMetal, 'Cylinder', V(0, math.pi / 2, 0))
	end
	for _, z in ipairs({-2.31, 1.10}) do
		part('SleeveStoneCradle', V(1.22, .72, .61), V(1.84, 1.02, z), cut, M.Slate)
		part('SleeveBandClamp', V(.17, .87, .87), V(sleeveX, sleeveY, z), iron:Lerp(cut, .48), M.Metal,
			'Cylinder', V(0, math.pi / 2, 0))
	end
end

local function heatworksObservationBaffle(pal, part)
	local basalt = pal.rock:Lerp(C(72, 70, 69), .63)
	local brick = basalt:Lerp(C(164, 110, 81), .71)
	local panel = C(109, 111, 101)

	part('ObservationAshShoulder', V(5.81, .62, 7.88), V(.12, .15, .18), pal.ground, M.Ground, 'Wedge')
	part('BaffleBasaltFoundation', V(4.25, .74, 7.42), V(0, .22, .02), basalt, M.Basalt)
	part('BaffleFirebrickWall', V(1.09, 1.48, 5.92), V(.81, 1.16, .14), brick, M.Brick)
	part('BaffleLintel', V(1.76, .35, 7.03), V(.84, 2.08, .14), basalt, M.Basalt)
	local wornBrick = brick:Lerp(C(187, 142, 110), .68)
	for i, z in ipairs({-1.96, .14, 2.24}) do
		part('BaffleRefractoryCrown', V(1.22, .31, 1.99), V(.82, 2.37, z),
			brick:Lerp(wornBrick, .18 + i * .09), M.Brick)
		part('ScouredRefractoryEdge', V(1.99, .12, .42), V(.45, 2.515, z),
			wornBrick, M.Concrete, 'Wedge', V(0, math.pi / 2, 0))
	end
	part('ObservationWearStone', V(1.20, .23, 4.81), V(-1.45, .61, .14), basalt:Lerp(panel, .74), M.Slate)
	for _, z in ipairs({-2.47, 2.74}) do
		part('BaffleStoneButtress', V(2.61, 1.78, .84), V(.16, 1.22, z), basalt, M.Basalt, 'Wedge',
			V(0, -math.pi / 2, 0))
	end
	for _, z in ipairs({-1.42, 0, 1.43}) do
		part('RivetedHeatShieldPlate', V(.19, 1.08, 1.28), V(.16, 1.47, z), panel, M.CorrodedMetal,
			nil, V(0, 0, -.14))
	end
	part('HeatShieldRetainingBar', V(.27, .18, 4.50), V(.13, 1.94, .01), panel:Lerp(brick, .33), M.Metal)
end

local function antechamberRailFooting(pal, part, beam)
	local slate = pal.rock:Lerp(C(107, 105, 110), .54)
	local stone = slate:Lerp(C(158, 152, 132), .70)
	local iron = C(100, 105, 113)

	part('AntechamberDustToe', V(5.47, .48, 7.92), V(.07, .14, .05), pal.ground, M.Ground, 'Corner')
	part('RailFootingRubbleCourse', V(3.88, .64, 7.22), V(.05, .26, .15), slate, M.Cobblestone)
	for _, z in ipairs({-2.36, 2.35}) do
		part('CarvedRailSocket', V(2.65, .82, 1.91), V(0, .83, z), stone, M.Slate)
		part('RailSocketIronShoe', V(1.25, .26, .93), V(0, 1.31, z),
			iron:Lerp(C(53, 57, 63), .57), M.CorrodedMetal)
		part('DressedSocketEnd', V(2.40, .22, .52), V(0, 1.22, z + math.sign(z) * .66),
			stone:Lerp(C(186, 177, 155), .55), M.Limestone, 'Wedge', V(0, z < 0 and math.pi or 0, 0))
		beam('RecessedRailUpright', V(0, 1.37, z), V(0, 2.27, z), .39, iron, M.CorrodedMetal)
	end
	part('RailSpine', V(.49, .37, 5.4), V(0, 2.25, 0), iron, M.CorrodedMetal)
	local wornIron = iron:Lerp(stone, .76)
	part('WornRailCap', V(.66, .18, 5.42), V(0, 2.48, 0), wornIron, M.Metal)
	for _, z in ipairs({-2.35, 2.35}) do
		beam('RailSocketKnee', V(0, 1.44, z), V(0, 2.21, z * .57), .24, iron, M.CorrodedMetal)
		beam('ReturnedRailEnd', V(0, 2.48, z * 1.13), V(0, 1.91, z * 1.23), .32, wornIron, M.Metal)
	end
	part('AntechamberServiceKerb', V(.89, .39, 5.91), V(-1.34, .62, .12), stone, M.Limestone)
end

return {
	['DW-06'] = {goal = 'exp_1', step = 2, name = 'RefugePathDrain', side = -11, compose = refugePathDrain},
	['GW-06'] = {goal = 'exp_1', name = 'ScoutExtractionSkid', offset = V(10, 0, -3), compose = scoutExtractionSkid},
	['FV-06'] = {goal = 'exp_1', step = 3, name = 'CitadelServiceCoping', side = -11, compose = citadelServiceCoping},
	['EC-06'] = {goal = 'exp_1', step = 2, name = 'HeatworksObservationBaffle', side = 11, compose = heatworksObservationBaffle},
	['HG-06'] = {goal = 'exp_2', step = 2, name = 'AntechamberRailFooting', side = -11, compose = antechamberRailFooting},
}
