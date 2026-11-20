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
	part('DarkDrainBed', V(1.26, .18, 5.9), V(0, .56, .07), bed:Lerp(C(52, 50, 39), .36), M.Pebble)
	for _, x in ipairs({-1.37, 1.37}) do
		part('WornDrainCheek', V(1.08, .66, 5.50), V(x, .75, .16), stone, M.Slate, nil, V(0, x * .05, 0))
		part('DrainMouthWing', V(.93, .44, 1.26), V(x * 1.12, .53, -3.08), stone, M.Slate, 'Wedge')
	end
	part('DrainCrossingLintel', V(3.61, .48, 1.52), V(.03, 1.22, .61), stone, M.Slate, nil, V(0, -.07, .04))
	beam('RootAboveDrain', V(-2.71, .38, 2.52), V(-.99, 1.12, 2.01), .63, root, M.Wood)
	beam('RootAboveDrain', V(-.99, 1.12, 2.01), V(1.37, .34, 3.31), .46, root, M.Wood)
end

local function scoutExtractionSkid(pal, part, beam)
	local shale = pal.rock:Lerp(C(141, 146, 136), .66)
	local wood = pal.wood:Lerp(C(178, 147, 103), .78)
	local track = pal.ground:Lerp(C(85, 69, 58), .54)
	local lash = C(96, 91, 71)

	part('ExtractionWornShoulder', V(5.86, .58, 8.14), V(.09, .16, .12), track, M.Ground, 'Wedge')
	part('ExtractionShaleSeat', V(4.08, .63, 5.34), V(.12, .26, .57), shale, M.Slate, 'Corner',
		V(0, -.29, 0))
	for _, x in ipairs({-1.07, 1.07}) do
		beam('SkidRunner', V(x, .68, -2.64), V(x, .43, 2.59), .33, wood, M.Wood)
		beam('CurvedSkidNose', V(x, .68, -2.64), V(x * .92, 1.15, -3.28), .29, wood, M.Wood)
		part('RunnerBinding', V(.41, .24, .35), V(x, .78, -1.78), lash, M.Fabric)
	end
	for _, z in ipairs({-1.56, -.46, .65, 1.75}) do
		part('EmptySkidSlat', V(2.62, .17, .88), V(0, .81 - z * .046, z), wood:Lerp(shale, .13), M.WoodPlanks)
	end
end

local function citadelServiceCoping(pal, part)
	local slate = pal.rock:Lerp(C(107, 123, 139), .63)
	local ice = pal.ground:Lerp(slate, .32)
	local cut = pal.trim:Lerp(slate, .51)
	local iron = C(73, 90, 104)

	part('CitadelWindPackedToe', V(6.30, .92, 8.41), V(.25, .26, .12), ice, M.Snow, 'Corner', V(0, -.24, 0))
	part('CitadelServiceBed', V(4.44, .72, 7.45), V(.03, .23, .21), slate, M.Slate)
	part('CitadelPackedSnowLip', V(3.31, .64, 5.12), V(-1.14, .62, .67), pal.ground, M.Snow, 'Wedge')
	for _, z in ipairs({-2.10, 1.90}) do
		part('ServiceWallDressedCourse', V(2.43, 1.06, 3.66), V(.40, 1.07, z), slate, M.Slate)
		part('SplitServiceCoping', V(2.81, .40, 3.53), V(.40, 1.76, z), cut, M.Slate, 'Wedge',
			V(0, z < 0 and 0 or math.pi, 0))
	end
	part('RecessedRelaySleeve', V(4.81, .63, .63), V(1.81, 1.13, -.62), iron, M.CorrodedMetal, 'Cylinder',
		V(0, math.pi / 2, 0))
	part('ServiceSleeveEndCap', V(.28, .88, .88), V(1.81, 1.13, -3.05), iron:Lerp(cut, .30), M.Metal, 'Cylinder',
		V(0, math.pi / 2, 0))
end

local function heatworksObservationBaffle(pal, part)
	local basalt = pal.rock:Lerp(C(72, 70, 69), .63)
	local brick = basalt:Lerp(C(164, 110, 81), .71)
	local panel = C(109, 111, 101)

	part('ObservationAshShoulder', V(5.81, .62, 7.88), V(.12, .15, .18), pal.ground, M.Ground, 'Wedge')
	part('BaffleBasaltFoundation', V(4.25, .74, 7.42), V(0, .22, .02), basalt, M.Basalt)
	part('BaffleFirebrickWall', V(1.09, 1.48, 5.92), V(.81, 1.16, .14), brick, M.Brick)
	part('BaffleLintel', V(1.76, .35, 7.03), V(.84, 2.08, .14), basalt, M.Basalt)
	for _, z in ipairs({-2.47, 2.74}) do
		part('BaffleStoneButtress', V(2.61, 1.78, .84), V(.16, 1.22, z), basalt, M.Basalt, 'Wedge',
			V(0, -math.pi / 2, 0))
	end
	for _, z in ipairs({-1.42, 0, 1.43}) do
		part('RivetedHeatShieldPlate', V(.19, .97, 1.34), V(.16, 1.47, z), panel, M.CorrodedMetal,
			nil, V(0, 0, -.14))
	end
end

local function antechamberRailFooting(pal, part, beam)
	local slate = pal.rock:Lerp(C(107, 105, 110), .54)
	local stone = slate:Lerp(C(158, 152, 132), .70)
	local iron = C(79, 83, 90)

	part('AntechamberDustToe', V(5.47, .48, 7.92), V(.07, .14, .05), pal.ground, M.Ground, 'Corner')
	part('RailFootingRubbleCourse', V(3.88, .64, 7.22), V(.05, .26, .15), slate, M.Cobblestone)
	for _, z in ipairs({-2.36, 2.35}) do
		part('CarvedRailSocket', V(2.65, .82, 1.91), V(0, .83, z), stone, M.Slate)
		part('RailSocketIronShoe', V(1.09, .22, .87), V(0, 1.28, z), iron, M.CorrodedMetal)
		beam('RecessedRailUpright', V(0, 1.37, z), V(0, 2.22, z), .30, iron, M.CorrodedMetal)
	end
	beam('WornRailCap', V(0, 2.24, -2.69), V(0, 2.24, 2.70), .39, iron:Lerp(stone, .19), M.Metal)
	part('AntechamberServiceKerb', V(.89, .39, 5.91), V(-1.34, .62, .12), stone, M.Limestone)
end

return {
	['DW-06'] = {goal = 'exp_1', step = 2, name = 'RefugePathDrain', side = -11, compose = refugePathDrain},
	['GW-06'] = {goal = 'exp_1', name = 'ScoutExtractionSkid', offset = V(10, 0, -3), compose = scoutExtractionSkid},
	['FV-06'] = {goal = 'exp_1', step = 3, name = 'CitadelServiceCoping', side = -11, compose = citadelServiceCoping},
	['EC-06'] = {goal = 'exp_1', step = 2, name = 'HeatworksObservationBaffle', side = 11, compose = heatworksObservationBaffle},
	['HG-06'] = {goal = 'exp_2', step = 2, name = 'AntechamberRailFooting', side = -11, compose = antechamberRailFooting},
}
