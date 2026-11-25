-- Fixed route details beside the chapter-five investigation and return paths.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function prisonWalkwayWheelStop(pal, part, beam)
	local earth = pal.ground:Lerp(C(102, 72, 49), .78)
	local stone = pal.rock:Lerp(C(146, 141, 117), .57)
	local timber = pal.wood:Lerp(C(157, 116, 77), .59)
	part('YardRuttedBedding', V(6.14, .71, 3.72), V(0, .12, .15), earth, M.Ground, 'Corner', V(0, .12, 0))
	part('WheelWearApron', V(3.46, .32, 1.57), V(-.79, .23, -.84), earth:Lerp(stone, .41), M.Pebble,
		'Wedge', V(0, math.pi / 2, 0))
	for _, x in ipairs({-1.86, 1.86}) do
		part('WheelStopStoneSeat', V(1.42, .62, 2.28), V(x, .32, .43), stone, M.Cobblestone)
		part('WheelStopRetainingPin', V(.35, .95, .38), V(x, .62, .95), C(108, 98, 78), M.CorrodedMetal)
	end
	beam('WheelStopTimber', V(-2.22, .89, .46), V(2.31, .89, .34), .54, timber, M.Wood)
	part('CrushedWheelStopEdge', V(2.59, .15, .35), V(-.64, 1.13, .24), timber:Lerp(stone, .34), M.Wood,
		'Wedge', V(0, math.pi / 2, 0))
end

local function huntingBankShaleCut(pal, part)
	local skirt = pal.ground:Lerp(C(82, 83, 69), .65)
	local shale = pal.rock:Lerp(C(101, 116, 116), .57)
	local face = pal.trim:Lerp(C(164, 158, 127), .57)
	part('BankScreeBedding', V(6.12, .83, 3.57), V(0, .13, .09), skirt, M.Ground, 'Corner', V(0, -.13, 0))
	part('BankSlippedShale', V(5.08, 1.34, 2.71), V(.03, .57, .29), shale, M.Slate, 'Wedge', V(0, math.pi / 2, 0))
	part('BankExposedLowerStratum', V(4.25, .34, 1.46), V(-.20, .64, .53), face, M.Slate, 'Wedge',
		V(.07, math.pi / 2, -.09))
	part('BankCrackedCap', V(2.57, .51, 2.14), V(-1.24, 1.16, .45), shale:Lerp(face, .42), M.Slate,
		nil, V(0, -.09, -.07))
	part('BankOpenCleavage', V(2.36, .38, 1.16), V(.95, .88, -.07), face, M.Slate, 'Wedge', V(0, -.32, .06))
	part('BankLooseShaleToe', V(1.53, .48, 1.31), V(-1.54, .39, -1.06), shale:Lerp(face, .60), M.Slate,
		'Corner', V(0, .38, 0))
	part('BankLeafMould', V(2.18, .23, 1.19), V(1.25, .13, -1.03), C(103, 87, 67), M.Ground, 'Wedge',
		V(0, -.31, 0))
end

local function tunnelHandrailFooting(pal, part, beam)
	local stone = pal.rock:Lerp(C(104, 135, 145), .61)
	local timber = pal.wood:Lerp(C(140, 104, 72), .69)
	local iron = C(101, 109, 109)
	part('TunnelMeltBedding', V(5.95, .78, 3.42), V(0, .13, .07), stone, M.Glacier, 'Corner', V(0, -.12, 0))
	part('TunnelSlateSill', V(4.89, .75, 2.50), V(.26, .36, .30), stone, M.Slate)
	part('MeltGrooveLip', V(3.69, .24, .36), V(.08, .78, -.89), pal.trim, M.Glacier, 'Wedge', V(0, math.pi / 2, 0))
	part('DriftAgainstSill', V(2.78, .77, 2.68), V(-1.40, .36, .43), C(208, 226, 233), M.Snow,
		'Wedge', V(0, -math.pi / 2, 0))
	part('HandrailPostSocket', V(1.18, .26, 1.25), V(1.14, .84, .37), iron, M.CorrodedMetal)
	part('FixedHandrailPier', V(.63, 2.63, .70), V(1.14, 2.13, .37), timber, M.Wood)
	beam('HandrailPierBrace', V(-.37, .84, .39), V(1.14, 2.05, .37), .37, timber, M.Wood)
	part('HandrailPierStrap', V(.78, .23, .77), V(1.14, 2.16, .37), iron, M.Metal)
end

local function emergencyReturnFlume(pal, part)
	local basalt = pal.rock:Lerp(C(95, 83, 74), .72)
	local brick = pal.trim:Lerp(C(174, 119, 79), .56)
	part('FlumeBasaltBedding', V(4.92, .69, 3.82), V(0, .14, .02), basalt, M.Basalt, 'Corner', V(0, -.10, 0))
	part('LowerReturnBed', V(1.57, .34, 3.30), V(.13, .51, -.07), basalt, M.Basalt, nil, V(-.07, 0, 0))
	for _, x in ipairs({-1.04, 1.30}) do
		part('RefractoryFlumeCheek', V(.71, .82, 3.45), V(x, .74, -.04), brick, M.Brick, nil, V(-.07, 0, 0))
		part('ReturnInletButtress', V(1.07, 1.96, 1.08), V(x, 1.25, 1.15), basalt, M.Basalt)
	end
	part('ReturnInletLintel', V(3.44, .40, .99), V(.13, 2.35, 1.14), brick, M.Brick)
	part('DryMineralRun', V(.83, .16, 1.87), V(.12, .71, -.62), C(166, 137, 99), M.Sand,
		'Wedge', V(0, math.pi, 0))
	part('WornOverflowLip', V(2.84, .22, .51), V(.13, .64, -1.55), brick:Lerp(pal.trim, .35), M.Slate)
end

local function westernConduitWallSleeve(pal, part)
	local stone = pal.rock:Lerp(C(145, 140, 126), .63)
	local cutStone = pal.trim:Lerp(C(192, 175, 144), .57)
	local iron = C(93, 99, 97)
	part('ConduitWallBedding', V(5.81, .75, 3.51), V(0, .14, .11), stone, M.Cobblestone, 'Corner',
		V(0, -.13, 0))
	part('WallSleeveThreshold', V(4.86, .56, 2.72), V(0, .38, .22), stone, M.Slate)
	for _, side in ipairs({-1, 1}) do
		part('ThroughWallAshlar', V(1.31, 2.26, 1.42), V(side * 1.63, 1.73, .61), stone, M.Limestone)
		part('SleeveJambIron', V(.25, 1.64, 1.68), V(side * .85, 1.48, .40), iron, M.CorrodedMetal)
		part('SleeveSpringer', V(1.12, .41, 1.53), V(side * 1.13, 2.61, .61), cutStone, M.Limestone,
			nil, V(0, 0, side * -.31))
	end
	part('SleeveCoping', V(3.61, .41, 1.81), V(0, 2.97, .62), cutStone, M.Limestone)
	part('ConduitRecessBed', V(1.55, .36, 2.32), V(0, .85, .02), iron, M.CorrodedMetal)
	part('DecommissionedConduit', V(2.50, .71, .71), V(0, 1.36, -.17), iron:Lerp(cutStone, .22), M.Metal,
		'Cylinder', V(0, math.pi / 2, 0))
end

return {
	['DW-05'] = {goal = 'exp_1', step = 2, name = 'PrisonWalkwayWheelStop', side = -12, compose = prisonWalkwayWheelStop},
	['GW-05'] = {goal = 'exp_1', step = 2, name = 'HuntingBankShaleCut', side = 12, compose = huntingBankShaleCut},
	['FV-05'] = {goal = 'exp_2', step = 2, name = 'TunnelHandrailFooting', side = -12, compose = tunnelHandrailFooting},
	['EC-05'] = {goal = 'exp_1', step = 2, name = 'EmergencyReturnFlume', side = -12, compose = emergencyReturnFlume},
	['HG-05'] = {goal = 'exp_1', step = 2, name = 'WesternConduitWallSleeve', side = 12, compose = westernConduitWallSleeve},
}
