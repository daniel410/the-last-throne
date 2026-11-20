-- Remnants beside the fourth chapters' rescue, repair and return routes.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function watchtowerCableAbutment(pal, part, beam)
	local rubble = pal.rock:Lerp(C(140, 136, 108), .47)
	local oak = pal.wood:Lerp(C(133, 104, 71), .43)
	local grain = oak:Lerp(C(174, 141, 95), .64)
	local iron = C(90, 91, 77)

	part('AbutmentGravelToe', V(5.6, .57, 5.7), V(.15, .17, .22), rubble:Lerp(pal.ground, .38),
		M.Ground, 'Corner', V(0, .21, 0))
	part('CablePierFoot', V(3.74, .84, 2.96), V(0, .32, .42), rubble, M.Cobblestone)
	part('CablePierRubbleCourse', V(2.83, .72, 2.52), V(.11, 1.08, .48), rubble, M.Slate)
	part('CablePierDressedCap', V(3.16, .32, 2.82), V(.11, 1.58, .48), rubble:Lerp(grain, .18), M.Slate)
	part('PierBeddedUpright', V(.69, 3.25, .78), V(.05, 3.29, .52), oak, M.Wood)
	beam('PierBeddedBrace', V(-1.31, 1.72, .53), V(.06, 3.71, .53), .45, oak, M.Wood)
	part('CableCrossarm', V(2.20, .49, .67), V(.05, 4.17, .51), grain, M.Wood)
	part('AbutmentIronStaple', V(.48, .44, .19), V(.76, 4.16, .09), iron, M.CorrodedMetal)
	beam('SlackCableUpper', V(.79, 4.19, -.02), V(.93, 2.95, -.19), .13, iron, M.CorrodedMetal)
	beam('SlackCableLower', V(.93, 2.95, -.19), V(.60, 2.49, -.46), .13, iron, M.CorrodedMetal)
end

local function crushedLanternSill(pal, part, beam)
	local shale = pal.rock:Lerp(C(132, 140, 139), .55)
	local loam = pal.ground:Lerp(C(77, 66, 51), .61)
	local bark = pal.wood:Lerp(C(102, 82, 63), .51)
	local grain = bark:Lerp(C(177, 146, 105), .65)

	part('RootHeaveLoam', V(6.33, .78, 7.54), V(.11, .24, .21), loam, M.Ground, 'Wedge')
	part('BuriedPathSill', V(3.14, .44, 5.39), V(-1.09, .29, -.39), shale, M.Slate, nil, V(0, -.24, 0))
	part('UpturnedPathSill', V(2.58, .58, 3.62), V(1.38, .66, .20), shale, M.Slate,
		'Wedge', V(.16, .37, -.28))
	beam('HeavingRoot', V(-2.62, .27, 2.77), V(.38, 1.47, .62), 1.28, bark, M.Wood)
	beam('RootAcrossSill', V(.38, 1.47, .62), V(2.67, .34, -2.64), 1.03, bark, M.Wood)
	beam('HeaveExposedGrain', V(-1.25, 1.04, 2.03), V(.43, 1.80, .93), .38, grain, M.Wood)
	part('DisplacedLanternSocket', V(1.34, .51, 1.35), V(-1.66, .81, -1.76), shale, M.Cobblestone,
		nil, V(0, .14, -.35))
	beam('SnappedSocketTimber', V(-1.66, .91, -1.76), V(-1.94, 1.89, -1.55), .54, bark, M.Wood)
	part('BrokenSocketEndgrain', V(.53, .23, .53), V(-1.94, 1.91, -1.55), grain, M.Wood, 'Wedge',
		V(.20, -.23, .32))
end

local function relayReturnHallSkirting(pal, part)
	local schist = pal.rock:Lerp(C(108, 128, 144), .53)
	local dressed = schist:Lerp(C(156, 171, 175), .63)
	local packedSnow = pal.ground:Lerp(schist, .35)
	local iron = C(76, 95, 103)

	part('ReturnHallPackedSnowToe', V(5.75, .60, 8.86), V(.36, .18, .23), packedSnow, M.Snow, 'Wedge',
		V(0, math.pi, 0))
	part('ReturnHallSkirtingCourse', V(2.15, .88, 7.81), V(-.46, .38, .12), schist, M.Slate)
	for _, z in ipairs({-2.49, 2.72}) do
		part('ReturnHallSkirtingCap', V(2.59, .40, 2.53), V(-.46, 1.01, z), dressed, M.Slate)
		part('ReturnHallSeatClamp', V(.40, .34, .73), V(.67, .95, z), iron, M.Metal)
	end
	part('ReturnHallRecessedSleeve', V(2.02, .31, 2.52), V(-.46, .98, .13), iron, M.Metal)
	part('ReturnHallScouredIceEdge', V(1.34, .33, 3.29), V(1.02, .30, -1.22), schist, M.Glacier,
		'Corner', V(0, -.36, 0))
end

local function fracturedCoolantJunction(pal, part)
	local basalt = pal.rock:Lerp(C(78, 72, 70), .57)
	local refractory = basalt:Lerp(C(164, 107, 77), .63)
	local scale = C(159, 135, 105)
	local iron = C(101, 91, 83)
	local darkIron = iron:Lerp(C(40, 36, 31), .68)
	local alongRun = V(0, math.pi / 2, 0)

	part('JunctionAshShoulder', V(5.79, .56, 9.51), V(-.12, .17, .16), pal.ground:Lerp(basalt, .55),
		M.Ground, 'Wedge')
	part('JunctionBasaltBed', V(4.28, .68, 8.44), V(0, .32, .13), basalt, M.Basalt)
	for _, direction in ipairs({-1, 1}) do
		local z = direction * 2.22
		part('JunctionRefractorySaddle', V(3.37, .81, 1.56), V(0, 1.06, z), refractory, M.Brick)
		part('JunctionIronSleeve', V(2.41, 1.55, 1.55), V(0, 1.75, z), iron, M.CorrodedMetal,
			'Cylinder', alongRun)
		part('JunctionBrokenFlange', V(.26, 1.93, 1.93), V(0, 1.75, direction * 1.03), refractory,
			M.CorrodedMetal, 'Cylinder', alongRun)
		part('JunctionFractureFace', V(.1, 1.30, 1.30), V(0, 1.75, direction * .87), darkIron, M.Metal,
			'Cylinder', alongRun)
	end
	part('JunctionMineralStain', V(2.16, .12, 1.27), V(.05, .72, .04), scale, M.Limestone,
		'Corner', V(0, .28, 0))
end

local function allianceLandingGuardCourse(pal, part)
	local slate = pal.rock:Lerp(C(115, 124, 120), .61)
	local coping = slate:Lerp(C(160, 153, 135), .63)
	local loam = pal.ground:Lerp(slate, .66)

	part('LandingSiltApron', V(6.05, .47, 8.83), V(-.06, .13, -.12), loam, M.Ground, 'Corner',
		V(0, -.19, 0))
	part('LandingGuardFoundation', V(3.50, .72, 8.24), V(.12, .32, .13), slate, M.Cobblestone)
	part('LandingGuardLongCourse', V(2.83, .88, 4.08), V(.37, 1.12, 1.10), slate, M.Slate)
	part('LandingGuardEndCourse', V(2.68, .71, 2.74), V(.41, 1.03, -2.31), slate, M.Slate)
	part('LandingGuardLongCoping', V(3.06, .36, 4.15), V(.37, 1.74, 1.16), coping, M.Limestone)
	part('LandingGuardChippedCoping', V(2.96, .43, 2.93), V(.41, 1.60, -2.38), coping, M.Limestone,
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
