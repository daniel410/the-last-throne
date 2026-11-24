-- Fixed infrastructure beside chapter-two activities; movable quest props are authored separately.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function awningFooting(pal, part, beam)
	local stone = pal.rock:Lerp(C(130, 125, 102), .58)
	local timber = pal.wood:Lerp(C(133, 98, 63), .58)
	local iron = C(105, 93, 76)
	part('RainCutBank', V(6, .72, 3.75), V(0, .12, .08), C(98, 78, 59), M.Mud, 'Corner',
		V(0, .17, 0))
	part('SlopedSplashStone', V(4.7, .43, 1.54), V(-.26, .16, -1.03), stone, M.Slate, 'Wedge',
		V(0, math.pi / 2, 0))
	part('RoundedDripStone', V(1.21, .49, 1.26), V(-2.11, .20, -.66), stone, M.Cobblestone, 'Corner')
	part('AwningPier', V(2.01, .83, 2.10), V(1.37, .35, .45), stone, M.Cobblestone)
	part('InsetPoleShoe', V(1.24, .32, 1.16), V(1.36, .88, .44), iron, M.CorrodedMetal)
	part('FixedAwningUpright', V(.72, 3.39, .79), V(1.37, 2.56, .44), timber, M.Wood)
	part('AwningTieCleat', V(.98, .27, .63), V(1.37, 2.79, -.12), iron, M.CorrodedMetal)
	beam('UprightFootBrace', V(-.05, .65, .32), V(1.36, 2.10, .44), .37, timber, M.Wood)
end

local function lanternCradle(pal, part, beam)
	local shale = pal.rock:Lerp(C(121, 136, 135), .66)
	local root = pal.wood:Lerp(C(106, 83, 62), .56)
	part('LeafMouldBed', V(5.93, .62, 3.67), V(0, .11, .32), C(84, 72, 55), M.Ground, 'Corner',
		V(0, -.16, 0))
	part('CleavedShaleShelf', V(4.7, 1.19, 2.17), V(.1, .40, .53), shale, M.Slate, 'Corner',
		V(0, -.13, 0))
	part('ExposedShaleLip', V(3.0, .24, 1.13), V(.65, .57, .08), shale:Lerp(C(158, 156, 135), .45), M.Slate,
		'Wedge', V(0, math.pi + .21, 0))
	beam('SplitRootBase', V(-2.68, .15, .55), V(-1.05, 1.12, .95), .73, root, M.Wood)
	beam('RootForkOverShelf', V(-1.05, 1.12, .95), V(.42, .85, 1.63), .51, root, M.Wood)
	part('EmptyLanternSocket', V(1.49, .51, 1.28), V(1.07, .59, -.57), C(103, 101, 83), M.Slate)
	for _, x in ipairs({.54, 1.60}) do
		part('SocketRetainingFlange', V(.22, .29, .94), V(x, .98, -.57), C(139, 116, 81), M.CorrodedMetal)
	end
end

local function dryLoadSill(pal, part)
	local ice = pal.rock:Lerp(C(106, 155, 171), .63)
	local timber = pal.wood:Lerp(C(113, 77, 49), .70)
	part('CellarIceApron', V(6.17, .76, 3.9), V(0, .17, .21), ice, M.Glacier, 'Corner', V(0, .13, 0))
	part('PackedDriftAtThreshold', V(2.32, .77, 3.40), V(-1.65, .35, .18), C(213, 227, 231), M.Snow,
		'Wedge', V(0, math.pi / 2, 0))
	part('RaisedSlateSill', V(4.93, .61, 2.82), V(.28, .43, .17), ice:Lerp(C(106, 118, 126), .58), M.Slate)
	for _, x in ipairs({-1.32, 1.92}) do
		part('PalletRunner', V(.55, .39, 2.57), V(x, .84, -.03), timber, M.Wood)
	end
	for _, z in ipairs({-1.05, -.40, .25, .90}) do
		part('DryPalletBoard', V(4.32, .22, .53), V(.30, 1.10, z), timber, M.WoodPlanks)
	end
end

local function coolingDraftBench(pal, part)
	local basalt = pal.rock:Lerp(C(94, 83, 71), .56)
	local iron = C(106, 109, 106)
	part('BasaltDraftingBedding', V(6.1, .69, 3.79), V(0, .15, .19), basalt, M.Basalt, 'Corner',
		V(0, -.12, 0))
	part('AshAlongBenchFoot', V(2.90, .39, 1.63), V(-1.25, .19, -1.15), C(119, 99, 79), M.Ground,
		'Wedge', V(0, -.32, 0))
	for _, x in ipairs({-1.77, 1.77}) do
		part('BasaltBenchPier', V(1.38, 1.74, 2.13), V(x, 1.17, .15), basalt, M.Basalt)
		part('ForgedTopClip', V(.33, .32, 1.01), V(x, 2.50, -.15), iron, M.CorrodedMetal)
	end
	part('InclinedDraftSurface', V(5.14, .43, 2.27), V(0, 2.21, .13), basalt:Lerp(C(142, 146, 135), .52),
		M.Slate, nil, V(-.16, 0, 0))
	part('WornDraftEdge', V(4.85, .17, .38), V(0, 2.34, .99), C(146, 125, 96), M.Metal,
		nil, V(-.16, 0, 0))
	part('BenchCrossTie', V(4.36, .37, .38), V(0, 1.22, .65), iron, M.CorrodedMetal)
end

local function gateRigBlocking(pal, part)
	local stone = pal.rock:Lerp(C(135, 132, 110), .63)
	local timber = pal.wood:Lerp(C(137, 104, 75), .52)
	local iron = C(119, 97, 74)
	part('RecessedRigApron', V(6.08, .69, 3.89), V(0, .13, .11), stone, M.Cobblestone, 'Corner',
		V(0, -.11, 0))
	part('LowLoadingSill', V(4.85, .61, 2.76), V(0, .41, .1), stone, M.Slate)
	for _, x in ipairs({-1.48, 1.48}) do
		part('IronShoe', V(1.58, .24, 1.70), V(x, .81, .29), iron, M.CorrodedMetal)
		part('CutRigChock', V(1.32, .71, 1.64), V(x, 1.16, .24), timber, M.Wood, 'Wedge',
			V(0, math.pi, 0))
		part('HeelBolt', V(.27, .16, .29), V(x, 1.01, -.43), C(152, 135, 109), M.Metal)
	end
	part('FixedCrossTie', V(4.33, .32, .64), V(0, .93, 1.08), timber, M.Wood)
end

return {
	['DW-02'] = {goal = 'exp_1', step = 2, name = 'ShelterAwningFooting', side = -12, compose = awningFooting},
	['GW-02'] = {goal = 'exp_2', step = 2, name = 'ScoutLanternRootCradle', side = -12, compose = lanternCradle},
	['FV-02'] = {goal = 'exp_1', step = 1, name = 'CellarDryLoadSill', side = -12, compose = dryLoadSill},
	['EC-02'] = {goal = 'exp_1', step = 2, name = 'CoolingDraftBench', side = -12, compose = coolingDraftBench},
	['HG-02'] = {goal = 'exp_1', step = 3, name = 'AllianceRigBlocking', side = -12, compose = gateRigBlocking},
}
