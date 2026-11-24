-- Grounded roadside details for the second incident in each opening chapter.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function creekShoulder(pal, part)
	local wet = pal.rock:Lerp(C(65, 70, 58), .58)
	local dry = wet:Lerp(C(160, 148, 111), .58)
	part('WaterlineShelf', V(6.4, .66, 3.8), V(0, .12, .25), wet, M.Slate, 'Corner', V(0, .14, 0))
	part('CreekSediment', V(5.6, .31, 2.2), V(.14, .11, -.54), C(109, 86, 62), M.Mud, 'Wedge',
		V(0, math.pi + .16, 0))
	for i, x in ipairs({-2.25, -.38, 1.84}) do
		part('RoundedCrossingStone', V(1.84, .66 + i * .12, 2.05), V(x, .36, .38 - i * .27),
			dry:Lerp(wet, i * .14), M.Cobblestone, 'Corner', V(0, i * .53, 0))
	end
	part('WaterDarkenedStake', V(.57, 1.65, .67), V(2.36, .71, .91), pal.wood, M.Wood, nil, V(.12, .2, -.14))
	part('ExposedStakeEnd', V(.59, .25, .69), V(2.49, 1.54, 1.01), C(147, 111, 67), M.Wood, 'Wedge',
		V(.12, .2, -.14))
end

local function scoutNotch(pal, part, beam)
	local shale = pal.rock:Lerp(C(113, 119, 113), .57)
	local roots = pal.wood:Lerp(C(117, 91, 67), .55)
	part('CompressedLeafFloor', V(5.9, .52, 3.7), V(0, .08, .19), C(94, 73, 54), M.Ground, 'Corner',
		V(0, -.12, 0))
	part('ExposedShaleCut', V(5.5, 1.64, 2.36), V(.25, .59, .82), shale, M.Slate, 'Wedge', V(0, .18, 0))
	part('SplitShaleEdge', V(3.82, .48, 1.53), V(-.23, .85, .87), shale:Lerp(pal.trim, .33), M.Slate,
		'Wedge', V(0, .15, 0))
	beam('LongRootShoulder', V(-2.76, .13, -.36), V(-1.77, 1.21, 1.23), .63, roots, M.Wood)
	beam('RootAboveCut', V(-1.77, 1.21, 1.23), V(.71, 1.12, 1.91), .48, roots, M.Wood)
	part('ShaleFlake', V(1.47, .37, 1.14), V(1.7, .16, -.67), shale, M.Slate, 'Corner', V(0, -.46, 0))
end

local function windbreakPocket(pal, part)
	local ice = pal.rock:Lerp(C(109, 159, 174), .65)
	local timber = pal.wood:Lerp(C(95, 61, 39), .69)
	part('IceShoulder', V(6.6, 1.02, 3.8), V(0, .24, .37), ice, M.Glacier, 'Corner', V(0, .11, 0))
	part('LeeSnowDrift', V(5.5, 1.32, 3.14), V(.2, .5, .28), C(209, 220, 224), M.Snow, 'Wedge',
		V(0, math.pi + .12, 0))
	for _, x in ipairs({-2.48, 2.48}) do
		part('WindbreakShoe', V(1.23, .73, 1.31), V(x, .42, .81), ice, M.Slate)
		part('WindbreakStub', V(.63, 2.14, .71), V(x, 1.38, .81), timber, M.Wood, nil, V(-.10, 0, 0))
	end
	for _, y in ipairs({1.24, 1.99}) do
		part('LowWindbreakBoard', V(5.64, .51, .36), V(0, y, .74 - y * .10), timber, M.WoodPlanks,
			nil, V(-.10, 0, 0))
	end
	part('CrustedSnowCap', V(3.77, .17, .43), V(-.57, 2.29, .55), C(225, 234, 237), M.Snow)
end

local function liftGuide(pal, part, beam)
	local basalt = pal.rock:Lerp(C(89, 78, 66), .63)
	local iron = C(97, 103, 102)
	part('ServiceGuideFoundation', V(6.55, .77, 3.52), V(0, .15, .18), basalt, M.Basalt)
	part('AshOnFoundation', V(4.1, .33, 2.4), V(.21, .39, 1.01), C(117, 94, 73), M.Ground, 'Wedge',
		V(0, .23, 0))
	for _, x in ipairs({-2.33, 2.33}) do
		part('GuideAnchorPlate', V(1.26, .29, 1.34), V(x, .68, .41), iron, M.CorrodedMetal)
		part('GuideBoltHead', V(.31, .21, .32), V(x, .92, -.01), C(161, 151, 127), M.Metal)
		part('GuideRailFoot', V(.62, .74, .61), V(x, .98, .62), iron, M.CorrodedMetal)
	end
	beam('FixedServiceGuide', V(-2.97, 1.21, .62), V(2.29, 1.21, .62), .48, iron, M.CorrodedMetal)
	beam('SlopedGuideNose', V(2.29, 1.21, .62), V(2.94, .81, .62), .42, C(136, 129, 111), M.Metal)
end

local function keeperAnchor(pal, part, beam)
	local stone = pal.rock:Lerp(C(128, 131, 116), .69)
	local coping = stone:Lerp(C(167, 165, 143), .42)
	part('KeeperPlinthBedding', V(5.8, .68, 3.45), V(0, .13, .26), stone, M.Cobblestone, 'Corner',
		V(0, -.09, 0))
	part('KeeperCurbBlock', V(4.96, 1.02, 1.7), V(0, .53, .53), stone, M.Slate)
	part('KeeperDripCoping', V(5.15, .34, 1.92), V(0, 1.08, .46), coping, M.Slate)
	for _, x in ipairs({-1.83, 1.83}) do
		part('KeeperRailSocket', V(.82, .29, .88), V(x, 1.33, .53), C(109, 78, 57), M.CorrodedMetal)
		beam('KeeperRailBracket', V(x, 1.39, .53), V(x, 2.29, .37), .39, C(109, 78, 57), M.CorrodedMetal)
	end
	beam('KeeperWornHandrail', V(-2.16, 2.29, .37), V(2.22, 2.29, .37), .51,
		pal.wood:Lerp(C(122, 98, 74), .64), M.Wood)
end

return {
	['DW-01'] = {goal = 'exp_2', step = 1, name = 'CreekCrossingShoulder', side = 10, compose = creekShoulder},
	['GW-01'] = {goal = 'exp_2', step = 2, name = 'ScoutCrouchNotch', side = -10, compose = scoutNotch},
	['FV-01'] = {goal = 'exp_2', step = 1, name = 'RefugeWindbreakPocket', side = 12, compose = windbreakPocket},
	['EC-01'] = {goal = 'exp_2', step = 1, name = 'LiftLandingGuide', side = -11, compose = liftGuide},
	['HG-01'] = {goal = 'exp_2', step = 3, name = 'KeeperRailAnchor', side = -11, compose = keeperAnchor},
}
