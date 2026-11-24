-- Roadside furnishings for the finale return routes, with the approach at local -Z.
local Fixtures = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

Fixtures.profiles = {
	['DW-07'] = {name = 'AltarRoadWaitingBay', goal = 'core_record'},
	['GW-07'] = {name = 'NorthernRoadWitnessStones', goal = 'exit'},
	['FV-07'] = {name = 'ReunionTerraceBench', goal = 'reunion'},
	['EC-07'] = {name = 'DispatchMapRail', goal = 'courier'},
	['HG-07'] = {name = 'AlliedExitWaymarker', goal = 'portal'},
}

local function waitingBay(palette, part, beam)
	local earth = palette.ground:Lerp(C(122, 97, 67), .82)
	local tread = earth:Lerp(C(151, 125, 84), .57)
	local stone = palette.rock:Lerp(C(139, 128, 98), .61)
	local timber = palette.wood:Lerp(C(143, 104, 63), .53)

	part('WaitingBayEarth', V(10.55, .82, 5.20), V(0, .16, .06), earth, M.Ground, false,
		V(0, .07, 0), 'Corner')
	part('WaitingBayPackedApproach', V(7.75, .55, 3.64), V(-.31, .12, -.79), tread, M.Ground, false,
		V(0, math.pi + .07, 0), 'Wedge')
	for _, side in ipairs({-1, 1}) do
		part('WaitingBayBoulder', V(2.05, 1.06, 2.20), V(side * 4.05, .35, .77), stone, M.Cobblestone,
			false, V(0, side * .30, 0), 'Corner')
		part('WaitingBaySeatPier', V(1.66, 1.05, 1.50), V(side * 2.80, .59, .92), stone, M.Slate,
			false, V(0, side * .11, 0))
	end
	part('WaitingBaySeat', V(7.05, .63, 1.67), V(0, 1.36, .89), timber, M.WoodPlanks)
	part('WaitingBaySeatWear', V(6.12, .08, .55), V(-.10, 1.68, .46), timber:Lerp(tread, .44), M.Wood)
	beam('WaitingBayRootCrown', V(4.47, .38, 1.45), V(3.96, .94, 2.02), .61, palette.wood, M.Wood)
	beam('WaitingBayRootTip', V(3.96, .94, 2.02), V(2.23, .36, 2.47), .39, palette.wood, M.Wood)
end

local function northernStones(palette, part)
	local shale = palette.rock:Lerp(C(128, 143, 147), .61)
	local seam = shale:Lerp(C(70, 81, 91), .62)
	local bedding = shale:Lerp(C(166, 171, 158), .59)
	local snow = palette.trim:Lerp(C(200, 215, 219), .71)

	part('WitnessStoneGroundBed', V(8.70, .74, 5.15), V(0, .11, .20), seam, M.Slate, false,
		V(0, -.13, 0), 'Corner')
	part('WitnessStoneSnowTongue', V(7.69, .54, 2.36), V(-.12, .15, -1.06), snow, M.Snow, false,
		V(0, math.pi - .22, 0), 'Wedge')
	part('WitnessStoneTallHeel', V(3.16, .91, 3.08), V(-1.78, .35, .58), shale, M.Slate, false,
		V(0, .13, 0))
	part('WitnessStoneTallFace', V(2.81, 2.58, 1.90), V(-1.86, 1.90, .58), shale, M.Slate, false,
		V(0, .13, -.06))
	part('WitnessStoneBeddingFace', V(2.86, .66, 1.93), V(-1.77, 3.11, .60), bedding, M.Slate, false,
		V(0, .13, -.06), 'Wedge')
	part('WitnessStoneSeam', V(2.56, .17, .13), V(-1.96, 1.42, -.38), seam, M.Slate, false,
		V(0, .13, -.06))
	part('WitnessStoneLowHeel', V(3.45, .79, 2.71), V(2.14, .28, .16), shale, M.Slate, false,
		V(0, -.28, 0))
	part('WitnessStoneLowFace', V(2.91, 1.83, 2.04), V(2.05, 1.16, .09), bedding, M.Slate, false,
		V(0, -.28, .06), 'Wedge')
	part('WitnessStoneShelteredSnow', V(2.15, .39, 1.62), V(2.58, .31, 1.25), snow, M.Snow, false,
		V(0, -.39, 0), 'Wedge')
end

local function reunionBench(palette, part)
	local slate = palette.rock:Lerp(C(103, 121, 132), .66)
	local ice = palette.trim:Lerp(C(96, 143, 164), .63)
	local timber = palette.wood:Lerp(C(142, 108, 74), .66)
	local worn = timber:Lerp(C(191, 162, 115), .57)

	part('ReunionTerraceFlagstones', V(9.87, .70, 4.92), V(0, .16, .44), slate, M.Slate)
	part('ReunionTerraceIceLip', V(9.26, .49, 1.91), V(-.12, .10, -1.91), ice, M.Glacier, false,
		V(0, math.pi - .12, 0), 'Wedge')
	part('ReunionTerraceShelteredDrift', V(7.33, .80, 2.08), V(-1.03, .24, 2.07), palette.ground,
		M.Snow, false, V(0, -.08, 0), 'Wedge')
	for _, x in ipairs({-3.07, 0, 3.07}) do
		part('ReunionBenchStonePier', V(1.25, 1.45, 1.86), V(x, 1.10, .45), slate, M.Slate, false,
			V(0, x * .03, 0))
	end
	for _, side in ipairs({-1, 1}) do
		part('ReunionBenchSeat', V(3.94, .53, 1.95), V(side * 2.04, 1.99, .45), timber, M.WoodPlanks,
			false, V(0, side * .035, 0))
		part('ReunionBenchSeatWear', V(3.46, .07, .89), V(side * 2.03, 2.26, .16), worn, M.Wood,
			false, V(0, side * .035, 0))
	end
end

local function dispatchRail(palette, part, beam)
	local basalt = palette.rock:Lerp(C(102, 89, 83), .65)
	local tread = basalt:Lerp(C(155, 129, 104), .61)
	local iron = C(107, 116, 110)
	local worn = iron:Lerp(C(183, 162, 128), .61)
	local slope = V(-.30, 0, 0)

	part('DispatchRailBasaltBed', V(8.76, .70, 4.69), V(0, .18, .23), basalt, M.Basalt)
	part('DispatchRailTread', V(7.27, .50, 2.08), V(-.22, .19, -1.87), tread, M.Slate, false,
		V(0, math.pi + .06, 0), 'Wedge')
	for _, x in ipairs({-2.55, 2.55}) do
		part('DispatchRailStoneFoot', V(1.75, .64, 1.99), V(x, .72, .43), tread, M.Basalt)
		part('DispatchRailIronShoe', V(.91, .28, 1.30), V(x, 1.06, .45), iron, M.CorrodedMetal)
		beam('DispatchRailUpright', V(x, 1.08, .51), V(x, 3.29, .43), .55, iron, M.CorrodedMetal)
		beam('DispatchRailKnee', V(x, 1.21, .62), V(x, 2.93, -.62), .37, iron, M.CorrodedMetal)
	end
	part('DispatchRailRest', V(6.47, .32, 2.09), V(0, 3.28, .12), iron, M.CorrodedMetal, false, slope)
	part('DispatchRailWornLedge', V(6.48, .37, .27), V(0, 3.15, -.88), worn, M.Metal, false, slope)
	part('DispatchRailRearRim', V(6.48, .25, .21), V(0, 3.68, 1.12), iron, M.Metal, false, slope)
end

local function alliedWaymarker(palette, part, beam)
	local ashlar = palette.rock:Lerp(C(146, 142, 125), .67)
	local worn = ashlar:Lerp(C(186, 171, 142), .61)
	local iron = C(120, 113, 97)

	part('WaymarkerBuriedApron', V(8.79, .79, 5.01), V(0, .14, .33), ashlar, M.Cobblestone, false,
		V(0, -.08, 0), 'Corner')
	part('WaymarkerApronStep', V(6.36, .51, 1.65), V(.09, .13, -1.63), worn, M.Limestone, false,
		V(0, math.pi - .08, 0), 'Wedge')
	part('WaymarkerStoneFoot', V(3.69, .86, 2.86), V(-.31, .48, .22), ashlar, M.Slate)
	part('WaymarkerStoneShaft', V(2.18, 2.87, 1.45), V(-.40, 2.11, .28), ashlar, M.Slate, false,
		V(0, .09, .045))
	part('WaymarkerDressedCrown', V(2.38, .77, 1.60), V(-.47, 3.70, .27), worn, M.Limestone, false,
		V(0, .09, .045), 'Wedge')
	part('WaymarkerRepairedFace', V(1.37, 1.74, .22), V(-.40, 2.60, -.45), worn, M.Limestone, false,
		V(0, .09, .045))
	part('WaymarkerIronCollar', V(2.27, .36, 1.55), V(-.37, 1.54, .27), iron, M.CorrodedMetal, false,
		V(0, .09, .045))
	part('WaymarkerBraceShoe', V(1.42, .52, 1.69), V(1.49, .49, 1.11), ashlar, M.Slate)
	beam('WaymarkerSideBrace', V(1.45, .68, 1.11), V(.64, 1.57, .52), .39, iron, M.CorrodedMetal)
	part('WaymarkerFallenCurbEnd', V(2.13, .77, 1.48), V(2.77, .31, -.29), ashlar, M.Limestone, false,
		V(0, -.39, .05), 'Wedge')
end

local builders = {
	['DW-07'] = waitingBay,
	['GW-07'] = northernStones,
	['FV-07'] = reunionBench,
	['EC-07'] = dispatchRail,
	['HG-07'] = alliedWaymarker,
}

function Fixtures.compose(id, palette, part, beam)
	builders[id](palette, part, beam)
end

return Fixtures
