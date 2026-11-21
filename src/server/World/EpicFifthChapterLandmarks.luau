-- Inactive terrain and fixtures alongside the fifth chapters' investigation routes.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function barracksFreightBreach(pal, part, beam)
	local earth = pal.ground:Lerp(C(109, 80, 55), .68)
	local stone = pal.rock:Lerp(C(131, 121, 96), .47)
	local timber = pal.wood:Lerp(C(126, 93, 62), .45)
	local grain = timber:Lerp(C(179, 144, 94), .72)
	local iron = C(98, 87, 75)
	local wornIron = iron:Lerp(stone, .58)

	part('TrampledFreightShoulder', V(6.4, .62, 9.4), V(-.17, .19, .16), earth, M.Ground, 'Wedge')
	part('EmbeddedLoadingSill', V(4.25, .76, 3.06), V(.1, .29, -2.29), stone, M.Cobblestone)
	part('CollapsedLoadingSill', V(3.9, .62, 2.54), V(.19, .23, 2.79), stone, M.Cobblestone, nil,
		V(.06, .22, -.09))
	for _, x in ipairs({-1.08, 1.08}) do
		part('FreightTrestleSocket', V(.94, .63, 1.23), V(x, .77, -2.18), stone, M.Slate)
		beam('SeveredFreightRail', V(x, 1.27, -3.37), V(x - .13, 1.12, -.81), .55, timber, M.Wood)
		part('FracturedRailGrain', V(.50, .43, .63), V(x - .14, 1.07, -.58), grain, M.Wood, 'Wedge',
			V(.15, .04, 0))
	end
	beam('SunkFreightRail', V(-.71, .37, .43), V(-1.22, .97, 3.87), .61, timber, M.Wood)
	part('BentRollerAxle', V(2.68, .28, .28), V(.09, 1.21, -2.02), iron, M.CorrodedMetal, 'Cylinder')
	part('SeizedTimberRoller', V(1.50, .59, .59), V(.07, 1.21, -2.02), timber, M.Wood, 'Cylinder')
	-- The exposed end grain makes the seized roller distinct from the broken rails.
	for _, side in ipairs({-1, 1}) do
		part('SeizedRollerEndGrain', V(.14, .55, .55), V(.07 + side * .77, 1.21, -2.02), grain, M.Wood,
			'Cylinder')
		part('SeizedRollerThrustWasher', V(.11, .37, .37), V(.09 + side * 1.04, 1.21, -2.02), wornIron,
			M.Metal, 'Cylinder')
	end
end

local function scoutLandingStoneAbutment(pal, part)
	local shale = pal.rock:Lerp(C(118, 125, 124), .62)
	local splitStone = shale:Lerp(C(169, 171, 142), .68)
	local loam = pal.ground:Lerp(C(82, 69, 53), .55)
	local wood = pal.wood:Lerp(C(137, 112, 78), .51)
	local iron = C(79, 91, 99)

	part('LandingErodedToe', V(6.1, .56, 8.1), V(.12, .15, .20), loam, M.Ground, 'Corner', V(0, .21, 0))
	part('LandingShaleFooting', V(3.92, .65, 7.03), V(.12, .24, .14), shale, M.Slate)
	for _, z in ipairs({-2.25, -.05, 2.37}) do
		local tone = shale:Lerp(pal.trim, .14 + .035 * z)
		part('StaggeredAbutmentCourse', V(2.93, .77, 2.18), V(.34 + z * .09, .85, z), tone, M.Slate,
			nil, V(0, .05 * z, 0))
	end
	part('WeatheredLandingCap', V(3.20, .37, 3.70), V(.48, 1.42, -1.49), splitStone, M.Limestone, nil,
		V(.04, -.04, 0))
	part('SplitLandingCap', V(3.15, .46, 3.01), V(.56, 1.40, 2.05), splitStone, M.Limestone, 'Wedge',
		V(0, math.pi, 0))
	-- A pale bedding plane over dark shale stays legible in the approach's night lighting.
	part('LandingCapSplitFace', V(2.52, .51, .75), V(.34, 1.29, -3.04), splitStone, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('LandingShaleRunoffFace', V(1.84, .59, .57), V(.61, .84, -3.18), shale:Lerp(loam, .35), M.Slate,
		'Wedge')
	part('BuriedLandingTie', V(3.50, .44, 1.27), V(-.30, 1.63, .41), wood, M.Wood)
	part('LandingTieStrap', V(.29, .18, 1.29), V(-1.28, 1.90, .41), iron, M.CorrodedMetal)
	part('ShaleAbutmentSpall', V(2.06, .50, 1.40), V(-1.91, .25, 2.02), shale, M.Slate, 'Wedge',
		V(0, .5, 0))
end

local function buriedConvoyWheelTrace(pal, part, beam)
	local packed = pal.ground:Lerp(pal.rock, .42)
	local drift = pal.ground:Lerp(pal.trim, .44)
	local ice = pal.rock:Lerp(pal.trim, .48)
	local ash = pal.wood:Lerp(C(132, 107, 86), .64)
	local iron = C(70, 81, 92)
	local endGrain = ash:Lerp(C(166, 138, 110), .64)

	part('ScouredConvoySnowFoot', V(6.26, .70, 9.75), V(0, .20, .14), packed, M.Snow, 'Wedge',
		V(0, math.pi, 0))
	for _, x in ipairs({-1.59, 1.59}) do
		part('FrozenWheelRut', V(1.03, .22, 7.65), V(x, .31, -.40), ice, M.Glacier, 'Wedge',
			V(0, math.pi, 0))
	end
	part('DriftOverConvoyAxle', V(4.11, 1.34, 6.31), V(.65, .52, 1.70), drift, M.Snow, 'Corner')
	part('DriftUnderWheel', V(2.84, .88, 3.16), V(-1.37, .35, .86), packed, M.Snow, 'Wedge')
	-- The lower half of the wheel is lost under the drift. Only the rim and two spokes remain exposed.
	local rim = {V(-1.69, .59, -2.16), V(-1.69, 1.48, -1.80), V(-1.69, 1.98, -.91),
		V(-1.69, 1.78, .13), V(-1.69, .98, .88)}
	for index = 1, #rim - 1 do
		local a, b = rim[index], rim[index + 1]
		beam('ExposedTimberFelloe', a, b, .37, ash, M.Wood)
		local band = V(-.18, .11, 0)
		beam('FrozenWheelIronTire', a + band, b + band, .17, iron, M.CorrodedMetal)
	end
	local axle = V(-1.69, .62, -.59)
	beam('BrokenWheelSpoke', axle, rim[2], .26, ash, M.Wood)
	beam('IceCrustedWheelSpoke', axle, rim[4], .30, ash:Lerp(ice, .24), M.Wood)
	part('ConvoyWheelHub', V(.85, .69, .69), axle + V(-.23, .10, 0), endGrain, M.Wood, 'Cylinder')
	part('ConvoyWheelHubCap', V(.25, .39, .39), axle + V(-.69, .10, 0), iron, M.CorrodedMetal, 'Cylinder')
	part('WindPackedSnowBelowHub', V(1.26, .47, 2.25), V(-2.17, .37, -.06), drift, M.Snow, 'Wedge',
		V(0, -.24, 0))
end

local function circuitModelCatchBasin(pal, part)
	local basalt = pal.rock:Lerp(C(85, 77, 72), .57)
	local brick = basalt:Lerp(C(164, 119, 92), .72)
	local mineral = C(143, 137, 111)
	local iron = C(94, 99, 91)

	part('CatchBasinAshApron', V(6.3, .56, 7.4), V(.12, .14, .19), pal.ground, M.Ground, 'Corner',
		V(0, .38, 0))
	part('CatchBasinBasaltFoot', V(4.91, .64, 6.16), V(0, .23, .12), basalt, M.Basalt)
	part('CatchBasinMineralBed', V(2.75, .22, 4.61), V(0, .56, .16), mineral, M.Limestone)
	for _, x in ipairs({-1.83, 1.83}) do
		part('CatchBasinRefractoryWall', V(.69, .91, 5.48), V(x, .86, .13), brick, M.Brick)
		part('CatchBasinRecessedIronRim', V(.34, .18, 4.92), V(x * .91, 1.35, .13), iron, M.CorrodedMetal)
	end
	part('CatchBasinBackWall', V(3.02, .81, .84), V(0, .84, 2.47), brick, M.Brick)
	part('CatchBasinSpillSill', V(2.99, .46, 1.06), V(0, .71, -2.46), brick, M.Brick, 'Wedge',
		V(0, math.pi, 0))
	part('CatchBasinOverflowTongue', V(1.42, .25, 1.83), V(0, .67, -3.02), basalt, M.Basalt, 'Wedge',
		V(0, math.pi, 0))
	for _, side in ipairs({-1, 1}) do
		part('OverflowChannelCheek', V(.51, .32, 1.67), V(side * .73, .72, -2.86), brick, M.Brick, 'Wedge',
			V(0, math.pi + side * .10, 0))
	end
	part('OverflowMineralRun', V(.71, .14, 1.77), V(-.07, .79, -2.98), mineral, M.Limestone, 'Wedge',
		V(0, math.pi - .05, 0))
end

local function easternGalleryConduitSaddle(pal, part)
	local slate = pal.rock:Lerp(C(114, 116, 116), .51)
	local coping = slate:Lerp(C(157, 150, 131), .64)
	local iron = C(80, 78, 82)
	local lead = C(109, 111, 113)
	local burnishedLead = lead:Lerp(coping, .68)
	local lengthwise = V(0, math.pi / 2, 0)

	part('GallerySaddleSiltToe', V(5.80, .46, 8.81), V(0, .15, .09), pal.ground:Lerp(slate, .58), M.Ground,
		'Corner', V(0, -.23, 0))
	part('GallerySaddleFoundation', V(4.26, .58, 7.69), V(.08, .23, .11), slate, M.Cobblestone)
	part('InactiveConduitSheath', V(6.67, .88, .88), V(.09, 1.04, .10), iron, M.CorrodedMetal, 'Cylinder',
		lengthwise)
	for _, z in ipairs({-2.20, 2.45}) do
		part('GalleryDressedSaddle', V(3.06, .79, 1.56), V(.09, .87, z), coping, M.Slate)
		part('GallerySaddleCollar', V(.45, 1.24, 1.24), V(.09, 1.16, z), lead, M.Metal, 'Cylinder',
			lengthwise)
		part('GalleryCollarSeam', V(.16, 1.18, 1.18), V(.09, 1.16, z + math.sign(z) * .25), burnishedLead,
			M.Metal, 'Cylinder', lengthwise)
		part('GallerySaddleChamfer', V(.68, .48, 1.40), V(-1.59, .73, z), slate, M.Slate, 'Wedge',
			V(0, -math.pi / 2, 0))
	end
	for _, z in ipairs({-3.20, 3.40}) do
		part('GalleryConduitEndBand', V(.25, 1.03, 1.03), V(.09, 1.04, z), burnishedLead, M.Metal, 'Cylinder',
			lengthwise)
	end
	part('GalleryServicePaving', V(1.20, .35, 6.58), V(1.64, .52, .07), coping, M.Limestone)
end

return {
	['DW-05'] = {goal = 'exp_2', step = 2, name = 'BarracksFreightBreach', side = -11, compose = barracksFreightBreach},
	['GW-05'] = {goal = 'exp_2', step = 2, name = 'ScoutLandingStoneAbutment', side = -11, compose = scoutLandingStoneAbutment},
	['FV-05'] = {goal = 'exp_1', step = 1, name = 'BuriedConvoyWheelTrace', side = 11, compose = buriedConvoyWheelTrace},
	['EC-05'] = {goal = 'exp_2', step = 1, name = 'CircuitModelCatchBasin', side = 11, compose = circuitModelCatchBasin},
	['HG-05'] = {goal = 'exp_2', step = 2, name = 'EasternGalleryConduitSaddle', side = -11, compose = easternGalleryConduitSaddle},
}
