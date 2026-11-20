-- Terrain-side fixtures for the route clues and repairs in the third chapters.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function reliefRosterStand(pal, part, beam)
	local stone = pal.rock:Lerp(C(144, 143, 118), .52)
	local oak = pal.wood:Lerp(C(148, 114, 76), .50)
	local wornOak = oak:Lerp(C(191, 156, 108), .68)
	local iron = C(96, 93, 82)
	part('RosterGravelSill', V(5.4, .46, 4.6), V(0, .15, .23), stone:Lerp(pal.ground, .42), M.Pebble, 'Wedge')
	for _, x in ipairs({-1.62, 1.62}) do
		part('RosterFieldstoneFoot', V(1.44, .73, 1.76), V(x, .29, .28), stone, M.Cobblestone)
		part('RosterTimber', V(.52, 3.58, .56), V(x, 2.19, .28), oak, M.Wood)
		beam('RosterKneeBrace', V(x, .61, .87), V(x, 2.54, .29), .32, oak, M.Wood)
	end
	local boardTilt = V(-.16, 0, 0)
	part('RosterBackBoard', V(4.25, 1.84, .32), V(0, 3.12, .09), oak, M.WoodPlanks, nil, boardTilt)
	part('WornRosterCap', V(4.55, .32, 1.12), V(0, 4.11, .23), wornOak, M.Wood, 'Wedge')
	part('RosterLowerLip', V(4.24, .26, .54), V(0, 2.20, -.07), wornOak, M.Wood)
	for _, x in ipairs({-1.6, 1.6}) do
		part('RosterForgedClip', V(.25, 1.33, .20), V(x, 3.18, -.12), iron, M.CorrodedMetal, nil, boardTilt)
	end
end

local function refugeReturnRootMarker(pal, part, beam)
	local shale = pal.rock:Lerp(C(141, 147, 143), .61)
	local bark = pal.wood:Lerp(C(118, 97, 75), .60)
	local grain = bark:Lerp(C(178, 151, 111), .67)
	local iron = C(111, 110, 93)
	part('ExposedOverlookShale', V(5.35, .68, 8.2), V(0, .24, .14), shale, M.Slate, 'Wedge',
		V(0, math.pi, 0))
	part('OverlookShaleToe', V(2.42, .54, 4.1), V(.88, .17, -1.56), shale:Lerp(pal.rock, .45), M.Slate,
		'Corner', V(0, -.44, 0))
	beam('ScouredMarkerRoot', V(-1.66, .19, 3.55), V(-1.01, 1.9, -.47), 1.05, bark, M.Wood)
	beam('MarkerRootFork', V(-1.01, 1.9, -.47), V(.85, .31, -3.57), .75, bark, M.Wood)
	beam('ExposedMarkerRootGrain', V(-1.35, .95, 2.62), V(-.86, 2.09, -.33), .33, grain, M.Wood)
	beam('NotchedMarkerStake', V(.35, .39, .57), V(.55, 4.05, .57), .68, bark, M.Wood)
	part('ReturnMarkerCrossband', V(2.35, .61, .33), V(.53, 3.25, .18), grain, M.WoodPlanks,
		nil, V(0, .11, -.09))
	part('ReturnMarkerTailBand', V(1.77, .35, .24), V(.52, 2.43, .19), grain, M.WoodPlanks,
		nil, V(0, .11, -.09))
	for _, x in ipairs({-.12, 1.17}) do
		part('ReturnMarkerClench', V(.18, .18, .13), V(x, 3.24, -.03), iron, M.CorrodedMetal)
	end
end

local function ravineWalkRailAnchor(pal, part, beam)
	local shale = pal.rock:Lerp(C(105, 129, 144), .56)
	local snow = pal.ground:Lerp(shale, .35)
	local iron = C(79, 106, 119)
	local edge = C(159, 181, 183)
	part('WalkRailScouredGlacialFoot', V(4.95, .94, 8.18), V(0, .36, .12), shale, M.Glacier, 'Wedge')
	part('WalkRailLeewardSnow', V(2.79, .55, 4.51), V(-1.05, .36, 1.14), snow, M.Snow, 'Corner',
		V(0, .44, 0))
	part('WalkRailSocketStone', V(2.86, .79, 5.94), V(.29, .43, -.67), shale, M.Slate)
	for _, z in ipairs({-2.68, 1.42}) do
		part('WalkRailSolePlate', V(1.79, .22, 1.53), V(.39, .94, z), iron, M.Metal)
		part('WalkRailForgedUpright', V(.47, 2.36, .49), V(.39, 2.20, z), iron, M.Metal)
		for _, x in ipairs({-.20, .98}) do
			part('WalkRailRivet', V(.21, .15, .24), V(x, 1.11, z), edge, M.Metal)
		end
	end
	beam('WalkRailCounterbrace', V(.39, 1.11, -1.93), V(.39, 2.76, 1.40), .35, iron, M.Metal)
	part('WalkRailCappedGrip', V(.55, .37, 5.27), V(.39, 3.41, -.57), edge, M.Metal)
end

local function belowRailCoolantInspectionHead(pal, part)
	local basalt = pal.rock:Lerp(C(89, 82, 81), .45)
	local refractory = basalt:Lerp(C(159, 116, 83), .55)
	local lime = refractory:Lerp(C(188, 155, 122), .55)
	local iron = C(109, 104, 99)
	part('InspectionAshApron', V(5.12, .44, 7.88), V(0, .15, -.31), pal.ground:Lerp(basalt, .57), M.Ground,
		'Wedge')
	part('InspectionFoot', V(4.52, .60, 4.48), V(0, .29, .85), basalt, M.Basalt)
	part('DryCoolantRun', V(2.02, .25, 4.60), V(0, .18, -1.91), basalt, M.Basalt)
	for _, x in ipairs({-1.28, 1.28}) do
		part('CoolantRunFirebrickLip', V(.44, .52, 4.6), V(x, .36, -1.91), refractory, M.Brick)
		part('InspectionHeadFirebrickCheek', V(1.05, 1.56, 2.41), V(x, 1.37, .94), refractory, M.Brick)
		part('CoolantRunMineralWear', V(.14, .14, 2.85), V(x * .80, .29, -1.79), lime, M.Limestone)
	end
	part('InspectionHeadBackstone', V(2.10, 1.55, .63), V(0, 1.37, 1.75), basalt, M.Basalt)
	part('InspectionIronFlange', V(3.72, .30, 2.58), V(0, 2.30, .93), iron, M.CorrodedMetal)
	for _, x in ipairs({-1.36, 1.36}) do
		part('InspectionFlangePin', V(.25, .20, .25), V(x, 2.55, .39), lime, M.Metal)
	end
end

local function keeperServiceDoorJamb(pal, part)
	local slate = pal.rock:Lerp(C(119, 126, 122), .58)
	local limestone = slate:Lerp(C(170, 160, 135), .62)
	local rust = C(106, 91, 76)
	part('ServiceDoorMossFoot', V(5.72, .43, 5.8), V(0, .14, .28), pal.ground:Lerp(slate, .63), M.Ground,
		'Corner', V(0, .30, 0))
	part('ServiceDoorFootCourse', V(5.28, .62, 3.71), V(0, .28, .27), slate, M.Cobblestone)
	part('ServiceDoorWornThreshold', V(4.88, .31, 2.34), V(.03, .75, -.40), limestone, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	for i = 0, 2 do
		local x = -1.47 - .13 * i
		part('ServiceDoorJambCourse', V(1.84 - .12 * i, 1.15, 1.92), V(x, 1.16 + i * 1.13, .73), slate, M.Slate)
		part('ServiceDoorDressedReturn', V(.20, 1.10, 1.92), V(x + .94 - .06 * i, 1.16 + i * 1.13, .73),
			limestone, M.Limestone)
	end
	part('ServiceDoorSpalledImpost', V(2.43, .61, 2.18), V(-1.54, 3.98, .71), limestone, M.Slate,
		'Wedge', V(0, math.pi / 2, 0))
	part('ServiceDoorHingePlate', V(.25, .58, .54), V(-.60, 2.18, .47), rust, M.CorrodedMetal)
	part('ServiceDoorBrokenSocket', V(1.49, .39, 1.84), V(1.42, .75, .82), slate, M.Slate, 'Corner',
		V(0, -.35, 0))
end

return {
	['DW-03'] = {goal = 'exp_1', step = 2, name = 'ReliefRosterStand', side = 10, compose = reliefRosterStand},
	['GW-03'] = {goal = 'exp_2', step = 2, name = 'RefugeReturnRootMarker', side = 10, compose = refugeReturnRootMarker},
	['FV-03'] = {goal = 'exp_2', step = 2, name = 'RavineWalkRailAnchor', side = 12, compose = ravineWalkRailAnchor},
	['EC-03'] = {goal = 'exp_2', step = 2, name = 'BelowRailCoolantInspectionHead', side = 10, compose = belowRailCoolantInspectionHead},
	['HG-03'] = {goal = 'exp_1', step = 2, name = 'KeeperServiceDoorJamb', side = -10, compose = keeperServiceDoorJamb},
}
