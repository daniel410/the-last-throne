-- Remnants beside the fourth chapters' rescue, repair and return routes.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function watchtowerCableAbutment(pal, part, beam)
	local rubble = pal.rock:Lerp(C(140, 136, 108), .47)
	local oak = pal.wood:Lerp(C(133, 104, 71), .43)
	local grain = oak:Lerp(C(174, 141, 95), .64)
	local iron = C(90, 91, 77)
	local wornIron = C(123, 119, 98)

	part('AbutmentGravelToe', V(5.6, .57, 5.7), V(.15, .17, .22), rubble:Lerp(pal.ground, .38),
		M.Ground, 'Corner', V(0, .21, 0))
	part('CablePierFoot', V(3.74, .84, 2.96), V(0, .32, .42), rubble, M.Cobblestone)
	part('CablePierRubbleCourse', V(2.83, .72, 2.52), V(.11, 1.08, .48), rubble, M.Slate)
	part('CablePierDressedCap', V(3.16, .32, 2.82), V(.11, 1.58, .48), rubble:Lerp(grain, .18), M.Slate)
	part('PierBeddedUpright', V(.69, 3.25, .78), V(.05, 3.29, .52), oak, M.Wood)
	beam('PierBeddedBrace', V(-1.31, 1.72, .53), V(.06, 3.71, .53), .45, oak, M.Wood)
	part('CableCrossarm', V(2.20, .49, .67), V(.05, 4.17, .51), grain, M.Wood)
	part('AbutmentGuideBackplate', V(.70, .48, .14), V(.76, 4.16, .12), iron, M.CorrodedMetal)
	for _, x in ipairs({.53, .99}) do
		part('AbutmentGuideCheek', V(.16, .35, .35), V(x, 4.16, -.08), wornIron, M.CorrodedMetal)
	end
	part('AbutmentGuideLip', V(.61, .13, .20), V(.76, 4.05, -.21), wornIron, M.Metal)
	beam('SlackCableUpper', V(.79, 4.19, -.02), V(.93, 2.95, -.19), .17, wornIron, M.CorrodedMetal)
	beam('SlackCableLower', V(.93, 2.95, -.19), V(.80, 1.58, -1.02), .19, wornIron, M.CorrodedMetal)
	beam('SlackCableAtPier', V(.80, 1.58, -1.02), V(.38, .68, -1.00), .19, wornIron, M.CorrodedMetal)
	part('CablePierBearingShoe', V(1.08, .34, 1.12), V(.07, 1.83, .52), iron, M.CorrodedMetal)
	part('CablePierShoeFlange', V(1.25, .15, 1.32), V(.07, 1.79, .52), wornIron, M.CorrodedMetal)
	part('CableFootWear', V(1.59, .22, .61), V(.30, .79, -.84), rubble:Lerp(grain, .65), M.Slate,
		nil, V(0, -.15, 0))
	part('CableHoldfastPlate', V(1.10, .14, .53), V(.25, .95, -.91), wornIron, M.CorrodedMetal)
	for _, x in ipairs({-.11, .61}) do
		part('CableHoldfastRivet', V(.18, .09, .18), V(x, 1.06, -.93), iron, M.Metal)
	end
	beam('BentCableFootEye', V(.38, .70, -1.00), V(.25, 1.04, -.94), .22, wornIron, M.CorrodedMetal)
	beam('CableFootEyeSeat', V(.25, 1.04, -.94), V(.08, .95, -.79), .20, iron, M.CorrodedMetal)
end

local function crushedLanternSill(pal, part, beam)
	local shale = pal.rock:Lerp(C(132, 140, 139), .55)
	local loam = pal.ground:Lerp(C(77, 66, 51), .61)
	local bark = pal.wood:Lerp(C(102, 82, 63), .51)
	local rootGrain = bark:Lerp(C(159, 133, 105), .49)
	local socketGrain = C(211, 180, 142)
	local splitShale = shale:Lerp(C(178, 184, 174), .77)

	part('RootHeaveLoam', V(6.33, .78, 7.54), V(.11, .24, .21), loam, M.Ground, 'Wedge')
	part('BuriedPathSill', V(3.14, .44, 5.39), V(-1.09, .29, -.39), shale, M.Slate, nil, V(0, -.24, 0))
	part('UpturnedPathSill', V(2.58, .58, 3.62), V(1.38, .66, .20), shale, M.Slate,
		'Wedge', V(.16, .37, -.28))
	-- The lighter bedding plane runs under the lifted sill and breaks into two layers.
	part('ExposedShaleBedding', V(2.42, .27, 2.38), V(1.28, .46, .59), splitShale, M.Slate,
		nil, V(.16, .37, -.26))
	part('ShearedShaleToe', V(1.35, .29, 1.12), V(1.58, .18, 1.62), splitShale:Lerp(loam, .28), M.Slate,
		'Corner', V(0, .67, 0))
	-- The break exposes the front face of two beds beneath the lifted stone.
	part('ShaleFractureLowerBed', V(2.12, .33, 1.48), V(.43, .42, -1.39), splitShale:Lerp(shale, .37),
		M.Slate, nil, V(.09, -.22, -.16))
	part('ShaleFractureUpperBed', V(2.01, .41, 1.34), V(.49, .74, -1.40), splitShale, M.Slate,
		'Wedge', V(.17, 2.84, .19))
	beam('HeavingRoot', V(-2.62, .27, 2.77), V(.38, 1.47, .62), 1.28, bark, M.Wood)
	beam('RootAcrossSill', V(.38, 1.47, .62), V(2.67, .34, -2.64), 1.03, bark, M.Wood)
	beam('HeaveExposedGrain', V(-1.25, 1.04, 2.03), V(.43, 1.80, .93), .38, rootGrain, M.Wood)
	part('DisplacedLanternSocket', V(1.34, .51, 1.35), V(-1.85, .80, -2.11), shale, M.Cobblestone,
		nil, V(0, .14, -.35))
	beam('SnappedSocketTimber', V(-1.85, .91, -2.11), V(-2.12, 1.83, -2.37), .71, bark, M.Wood)
	part('BrokenSocketEndgrain', V(.84, .46, .68), V(-2.12, 1.92, -2.47), socketGrain,
		M.Wood, 'Wedge', V(.27, -.16, .31))
	part('SocketSplitFace', V(.43, .85, .35), V(-2.24, 1.63, -2.60), socketGrain:Lerp(bark, .18),
		M.Wood, 'Wedge', V(.21, 2.67, .33))
	part('SocketFrontSplinter', V(.29, .73, .33), V(-1.87, 1.55, -2.62), socketGrain:Lerp(bark, .36),
		M.Wood, 'Wedge', V(.29, -.12, -.26))
	part('SocketBrokenStrap', V(.73, .15, .14), V(-1.96, 1.24, -2.52), C(107, 103, 91),
		M.CorrodedMetal, nil, V(.13, -.10, .24))
end

local function relayReturnHallSkirting(pal, part)
	local schist = pal.rock:Lerp(C(108, 128, 144), .53)
	local dressed = schist:Lerp(C(156, 171, 175), .63)
	local packedSnow = pal.ground:Lerp(schist, .23)
	local iron = C(62, 76, 85)
	local wornIron = C(154, 164, 159)

	part('ReturnHallPackedSnowToe', V(5.75, .60, 8.86), V(.36, .18, .23), packedSnow, M.Snow, 'Wedge',
		V(0, math.pi, 0))
	part('ReturnHallSkirtingCourse', V(2.15, .88, 7.81), V(-.46, .38, .12), schist, M.Slate)
	for _, z in ipairs({-2.49, 2.72}) do
		local capLevel = z < 0 and .93 or 1.01
		part('ReturnHallSkirtingCap', V(2.59, .40, 2.53), V(-.46, capLevel, z), dressed, M.Slate)
		part('ReturnHallSeatClamp', V(.40, .34, .73), V(.67, .95, z), iron, M.Metal)
	end
	part('ReturnHallRecessedSleeve', V(2.02, .26, 2.70), V(-.46, .92, .13), iron, M.Metal)
	part('ReturnHallExposedAxle', V(3.15, .57, .57), V(-.46, 1.27, .02), wornIron, M.Metal,
		'Cylinder', V(0, math.pi / 2, 0))
	for _, z in ipairs({-1.23, 1.45}) do
		part('ReturnHallAxleCollar', V(.32, .78, .78), V(-.46, 1.27, z), iron, M.Metal,
			'Cylinder', V(0, math.pi / 2, 0))
	end
	part('ReturnHallAxleJournalFace', V(.13, .48, .48), V(-.46, 1.27, -1.61),
		wornIron:Lerp(dressed, .42), M.Metal, 'Cylinder', V(0, math.pi / 2, 0))
	local bearingStone = dressed:Lerp(C(151, 143, 124), .58)
	part('ReturnHallNearBearingShoulder', V(.78, .54, 1.12), V(-1.36, .93, -1.16), bearingStone, M.Slate,
		'Wedge', V(0, math.pi / 2, 0))
	part('ReturnHallBearingCheek', V(.55, .62, 1.03), V(.33, .95, -1.26), bearingStone, M.Slate,
		'Wedge', V(0, -math.pi / 2, 0))
	part('ReturnHallPlowedSnowLip', V(1.43, .42, 3.07), V(.86, .38, .13), packedSnow, M.Snow,
		'Wedge', V(0, math.pi / 2, 0))
	part('ReturnHallPackedBearingEdge', V(.82, .28, 1.78), V(-1.59, .25, -1.60),
		packedSnow:Lerp(dressed, .30), M.Snow, 'Wedge', V(0, -math.pi / 2, 0))
	part('ReturnHallScouredIceEdge', V(1.34, .33, 3.29), V(1.02, .30, -1.22), schist, M.Glacier,
		'Corner', V(0, -.36, 0))
end

local function fracturedCoolantJunction(pal, part)
	local basalt = pal.rock:Lerp(C(78, 72, 70), .57)
	local refractory = basalt:Lerp(C(164, 107, 77), .63)
	local scale = C(154, 136, 111)
	local iron = C(89, 82, 77)
	local darkIron = iron:Lerp(C(40, 36, 31), .74)
	local dryIron = iron:Lerp(scale, .72)
	local oxidizedIron = iron:Lerp(refractory, .60)
	local alongRun = V(0, math.pi / 2, 0)

	part('JunctionAshShoulder', V(5.79, .56, 9.51), V(-.12, .17, .16), pal.ground:Lerp(basalt, .55),
		M.Ground, 'Wedge')
	part('JunctionBasaltBed', V(4.28, .68, 8.44), V(0, .32, .13), basalt, M.Basalt)
	for _, direction in ipairs({-1, 1}) do
		local z = direction * 2.22
		local pipeX = direction * .43
		part('JunctionRefractorySaddle', V(3.10, .81, 1.56), V(pipeX * .48, 1.06, z), refractory, M.Brick)
		part('JunctionIronSleeve', V(2.07, 1.55, 1.55), V(pipeX, 1.75, direction * 2.39), iron, M.CorrodedMetal,
			'Cylinder', alongRun)
		-- The back wall sits behind the broken collar, leaving a visible bore at the opening.
		part('JunctionBoreShadow', V(.10, 1.28, 1.28), V(pipeX, 1.75, direction * 1.32), darkIron, M.Metal,
			'Cylinder', alongRun)
		part('JunctionBeddedSleeveBand', V(.22, 1.62, 1.62), V(pipeX, 1.75, direction * 2.42),
			iron:Lerp(basalt, .47), M.Metal, 'Cylinder', alongRun)
		local fracture = direction < 0 and dryIron or oxidizedIron
		for facet = 0, 5 do
			local angle = (facet + direction * .24) * math.pi / 3
			local chipped = direction == -1 and facet == 1 or direction == 1 and facet == 4
			local shorter = direction == -1 and facet == 0 or direction == 1 and facet == 5
			local length = chipped and .10 or (shorter and .27 or .60)
			local edgeZ = direction * (1.45 - length / 2)
			part('JunctionBrokenRim', V(.85, .18, length),
				V(pipeX - math.sin(angle) * .74, 1.75 + math.cos(angle) * .74, edgeZ),
				chipped and iron or fracture, M.CorrodedMetal, nil, V(0, 0, angle))
		end
	end
	part('JunctionMineralStain', V(2.16, .12, 1.27), V(.05, .72, .04), scale, M.Limestone,
		'Corner', V(0, .28, 0))
	part('JunctionMineralRunoff', V(.97, .15, 2.35), V(.81, .71, -.19), scale:Lerp(refractory, .11),
		M.Limestone, 'Wedge', V(0, .52, 0))
	part('JunctionLeachFan', V(1.58, .12, .73), V(1.32, .71, .70), scale:Lerp(basalt, .28),
		M.Limestone, 'Corner', V(0, -.32, 0))
	part('JunctionSpalledBrick', V(.62, .29, .86), V(.64, .82, -.35), refractory, M.Brick,
		'Corner', V(0, -.53, -.14))
end

local function allianceLandingGuardCourse(pal, part)
	local slate = pal.rock:Lerp(C(115, 124, 120), .61)
	local coping = slate:Lerp(C(160, 153, 135), .63)
	local loam = pal.ground:Lerp(slate, .66)

	part('LandingSiltApron', V(6.05, .47, 8.83), V(-.06, .13, -.12), loam, M.Ground, 'Corner',
		V(0, -.19, 0))
	part('LandingGuardFoundation', V(3.50, .72, 8.24), V(.12, .32, .13), slate, M.Cobblestone)
	part('LandingGuardLowerBed', V(2.83, .35, 4.08), V(.37, .855, 1.10), slate, M.Slate)
	part('LandingGuardUpperBedNear', V(2.83, .53, 1.96), V(.37, 1.295, .04), slate:Lerp(coping, .27), M.Slate)
	part('LandingGuardUpperBedFar', V(2.71, .53, 2.00), V(.34, 1.295, 2.14), slate:Lerp(coping, .10), M.Slate)
	part('LandingGuardEndCourse', V(2.68, .71, 2.74), V(.41, 1.03, -2.31), slate, M.Slate)
	local wornCoping = coping:Lerp(C(181, 176, 159), .57)
	part('LandingGuardLongCoping', V(2.53, .36, 2.11), V(.11, 1.74, 2.18), coping, M.Limestone)
	part('LandingGuardMiddleCoping', V(2.34, .32, 1.95), V(.20, 1.71, .14), coping, M.Limestone)
	part('LandingGuardArrivalChamfer', V(4.15, .36, .54), V(1.64, 1.74, 1.16), wornCoping, M.Limestone,
		'Wedge', V(0, -math.pi / 2, 0))
	part('LandingGuardReturnChamfer', V(2.18, .32, .49), V(-1.29, 1.72, 2.14), wornCoping, M.Limestone,
		'Wedge', V(0, math.pi / 2, 0))
	part('LandingGuardChippedCoping', V(1.87, .38, 1.64), V(.14, 1.52, -1.88), coping, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('LandingGuardTaperedCoping', V(1.64, .31, .68), V(1.40, 1.48, -1.88), wornCoping, M.Limestone,
		'Wedge', V(0, -math.pi / 2, 0))
	part('LandingGuardWornEndstone', V(1.31, .24, .66), V(.27, 1.36, -3.43), wornCoping, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('LandingGuardJointCoping', V(2.05, .25, .69), V(.25, 1.60, -1.15), wornCoping, M.Limestone)
	part('LandingGuardArrivalFoot', V(2.39, .26, .92), V(.51, 1.15, -3.97), coping, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('LandingGuardDressedEnd', V(1.31, .29, .63), V(.25, 1.32, -3.24), wornCoping, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('LandingGuardShoulder', V(3.70, .45, 2.19), V(-.32, .84, 2.51), slate, M.Slate, 'Corner',
		V(0, math.pi, 0))
	part('LandingThresholdWear', V(1.47, .23, 2.60), V(-1.05, .79, -.62), coping, M.Limestone,
		'Wedge', V(0, math.pi / 2, 0))
end

return {
	['DW-04'] = {goal = 'exp_1', step = 3, name = 'WatchtowerCableAbutment', side = -11, compose = watchtowerCableAbutment},
	['GW-04'] = {goal = 'exp_1', step = 1, name = 'CrushedLanternSill', side = 10, compose = crushedLanternSill},
	['FV-04'] = {goal = 'exp_2', step = 3, name = 'RelayReturnHallSkirting', side = 11, compose = relayReturnHallSkirting},
	['EC-04'] = {goal = 'exp_1', step = 2, name = 'FracturedCoolantJunction', side = -11, compose = fracturedCoolantJunction},
	['HG-04'] = {goal = 'exp_2', step = 3, name = 'AllianceLandingGuardCourse', side = -11, compose = allianceLandingGuardCourse},
}
