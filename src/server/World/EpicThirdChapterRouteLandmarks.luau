-- Permanent fieldwork beside the chapter-three rescue and signal routes.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function outpostSightRest(pal, part, beam)
	local clay = pal.ground:Lerp(C(121, 96, 67), .62)
	local rock = pal.rock:Lerp(C(143, 133, 100), .52)
	local wood = pal.wood:Lerp(C(151, 106, 67), .71)
	part('TerracePackedShoulder', V(7.4, .72, 4.6), V(0, .13, .03), clay, M.Ground, 'Corner', V(0, .13, 0))
	for _, x in ipairs({-1.45, 1.45}) do
		part('TerraceExposedSett', V(2.56, .42, 2.14), V(x, .13, -.62), rock, M.Cobblestone,
			'Wedge', V(0, math.pi, 0))
		part('SightRestStoneSeat', V(1.46, .66, 1.49), V(x, .41, .43), rock, M.Cobblestone)
		part('SightRestUpright', V(.55, 1.44, .66), V(x, 1.41, .43), wood, M.Wood)
		beam('SightRestBrace', V(x, .72, -.84), V(x, 1.68, .43), .31, wood, M.Wood)
	end
	part('SightRestCrosspiece', V(3.92, .35, .72), V(0, 2.18, .43), wood, M.WoodPlanks)
	for _, x in ipairs({-.66, .66}) do
		part('BearingNotchCheek', V(.44, .48, .74), V(x, 2.59, .43), pal.trim:Lerp(wood, .45), M.Wood)
	end
end

local function refugeLanternReturn(pal, part, beam)
	local shale = pal.rock:Lerp(C(108, 116, 111), .61)
	local root = pal.wood:Lerp(C(119, 88, 63), .69)
	local split = root:Lerp(C(178, 147, 110), .61)
	local iron = C(116, 105, 80)
	part('RefugeShaleApron', V(5.68, .74, 3.49), V(0, .13, .08), shale, M.Slate, 'Corner', V(0, -.13, 0))
	part('LanternReturnShaleFoot', V(3.63, .83, 2.40), V(-.35, .44, .25), shale, M.Slate, 'Wedge', V(0, -.24, 0))
	beam('LanternReturnRoot', V(-1.98, .46, .48), V(1.12, 2.35, .48), .81, root, M.Wood)
	part('LanternReturnRootEnd', V(.82, .25, .79), V(1.14, 2.45, .45), split, M.Wood, nil, V(0, 0, .39))
	part('LanternReturnShelf', V(2.60, .29, 1.38), V(-.13, 1.15, -.27), shale:Lerp(pal.trim, .49), M.Slate)
	for _, x in ipairs({.50, 1.02}) do
		part('RecoveredLanternPeg', V(.23, .22, .66), V(x, 1.94 + x * .42, .08), iron, M.CorrodedMetal)
		part('RecoveredLanternPegLip', V(.23, .25, .16), V(x, 2.08 + x * .42, -.23), iron, M.CorrodedMetal)
	end
	-- A fixed shelter lamp marks the shelf while the recovered lantern remains a quest object.
	local housing = iron:Lerp(root, .45)
	beam('ShelfLampHanger', V(1.08, 2.38, .45), V(1.08, 3.40, .08), .22, housing, M.Metal)
	part('ShelfLampBase', V(.66, .20, .65), V(1.08, 2.65, -.02), housing, M.Metal)
	part('ShelfLampPane', V(.43, .47, .44), V(1.08, 2.98, -.02), C(219, 171, 96), M.Neon)
	part('ShelfLampHood', V(.72, .24, .70), V(1.08, 3.32, -.02), housing, M.Metal)
end

local function ravineSupplyBank(pal, part)
	local stone = pal.rock:Lerp(C(100, 128, 143), .66)
	local snow = pal.ground:Lerp(C(212, 232, 238), .76)
	local ice = stone:Lerp(C(127, 180, 192), .50)
	local wood = pal.wood:Lerp(C(143, 109, 82), .61)
	part('RavineBankFoot', V(7.15, .86, 4.17), V(0, .18, .12), ice, M.Glacier, 'Corner', V(0, -.13, 0))
	part('ExposedRavineCut', V(5.72, 1.40, 3.08), V(-.33, .62, .31), stone, M.Slate, 'Wedge', V(0, math.pi / 2, 0))
	part('GlazedRavineSeam', V(4.80, .36, .51), V(-.63, .54, -1.20), ice, M.Glacier, nil, V(0, 0, -.10))
	part('RavinePackedDrift', V(4.23, .67, 2.67), V(-.90, 1.03, .49), snow, M.Snow, 'Wedge', V(0, math.pi / 2, 0))
	part('RavineDriftToe', V(2.30, .46, 1.80), V(-2.13, .27, -.70), snow, M.Snow, 'Corner', V(0, -.33, 0))
	part('SupplyStakeSocket', V(1.20, .54, 1.17), V(1.44, .75, .30), stone, M.Slate)
	part('SupplyBankStake', V(.43, 2.18, .49), V(1.44, 1.82, .30), wood, M.Wood, nil, V(.07, 0, -.12))
	part('SupplyStakeReflectiveCap', V(.59, .28, .59), V(1.60, 2.76, .38), snow:Lerp(ice, .32), M.Slate)
end

local function mineRescueRailSeat(pal, part, beam)
	local basalt = pal.rock:Lerp(C(87, 72, 65), .67)
	local firebrick = pal.trim:Lerp(C(168, 112, 76), .60)
	local iron = C(109, 103, 94)
	part('EvacuationAshBedding', V(6.06, .69, 3.42), V(0, .13, .06), basalt, M.Basalt, 'Corner', V(0, .1, 0))
	for _, x in ipairs({-1.68, 1.68}) do
		part('RescueRailBasaltSill', V(2.10, .50, 2.44), V(x, .23, .12), basalt, M.Basalt)
		part('RescueRailRefractoryToe', V(1.74, .32, .90), V(x, .37, -.90), firebrick, M.Brick,
			'Wedge', V(0, math.pi, 0))
		part('RescueRailMasonryPier', V(1.28, .93, 1.51), V(x, .56, .26), firebrick, M.Brick)
		part('RescueRailShoe', V(.96, .26, .86), V(x, 1.1, .26), iron, M.CorrodedMetal)
		part('RescueRailStanchion', V(.40, 1.36, .41), V(x, 1.71, .26), iron, M.Metal)
	end
	beam('EvacuationHandrail', V(-2.04, 2.37, .26), V(2.04, 2.37, .26), .37, iron:Lerp(firebrick, .29), M.Metal)
	part('AshAgainstPier', V(2.47, .30, 1.42), V(-1.30, .32, -.79), basalt:Lerp(firebrick, .25), M.Ground,
		'Wedge', V(0, math.pi / 2, 0))
end

local function fortressStoneRailSeat(pal, part)
	local stone = pal.rock:Lerp(C(141, 140, 131), .62)
	local coping = pal.trim:Lerp(C(191, 178, 152), .64)
	part('LandingSettBed', V(5.77, .68, 3.58), V(0, .12, .04), stone, M.Cobblestone, 'Corner', V(0, -.10, 0))
	part('LandingRailPlinth', V(4.89, .60, 2.36), V(0, .39, .23), stone, M.Limestone)
	for _, x in ipairs({-1.59, 1.59}) do
		part('LandingRakedButtress', V(1.39, .99, 2.07), V(x, .66, -.48), stone:Lerp(coping, .31),
			M.Limestone, 'Wedge')
		part('WornLandingRailPier', V(1.08, 1.46, 1.07), V(x, 1.40, .40), stone, M.Limestone)
		part('LandingPierShoulder', V(1.32, .32, 1.29), V(x, 2.06, .40), coping, M.Limestone)
	end
	part('LandingStoneHandrail', V(4.37, .46, .92), V(0, 2.34, .40), coping, M.Limestone)
	part('LandingRailRepairCramp', V(.29, .39, 1.00), V(.78, 2.43, .40), C(105, 106, 97), M.CorrodedMetal)
	part('FallenLandingSpall', V(1.20, .38, .80), V(1.49, .38, -.81), coping:Lerp(stone, .48), M.Slate,
		'Corner', V(0, .39, 0))
end

return {
	['DW-03'] = {goal = 'exp_2', step = 2, name = 'OutpostSightRest', side = 14, compose = outpostSightRest},
	['GW-03'] = {goal = 'exp_1', step = 2, name = 'RefugeLanternReturn', side = -14, compose = refugeLanternReturn},
	['FV-03'] = {goal = 'exp_1', step = 2, name = 'RavineSupplyBank', side = -14, compose = ravineSupplyBank},
	['EC-03'] = {goal = 'exp_1', step = 2, name = 'MineRescueRailSeat', side = 14, compose = mineRescueRailSeat},
	['HG-03'] = {goal = 'exp_2', step = 2, name = 'FortressStoneRailSeat', side = -14, compose = fortressStoneRailSeat},
}
