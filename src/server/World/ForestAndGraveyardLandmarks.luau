-- Grounded, script-free scenery for the watchtower, rootway, and keeper approach.
-- The shared landmark builder owns the placement and the existing actors own progress.
local Models = {}
local V = Vector3.new
local M = Enum.Material

Models.profiles = {
	['DW-04'] = {name = 'WatchtowerSignalFooting', goal = 'link_record'},
	['GW-04'] = {name = 'RootwayBankCut', goal = 'lantern'},
	['HG-01'] = {name = 'KeeperLanternRevetment', goal = 'shelter'},
}

local function watchtowerFooting(palette, part, beam)
	local stone = palette.rock:Lerp(palette.trim, .45)
	local coping = stone:Lerp(palette.trim, .30)
	local moss = palette.ground:Lerp(palette.rock, .20)

	part('BuriedLimestoneSill', V(20, 2.1, 8), V(-1.2, .30, 1.1), stone, M.Cobblestone)
	part('RoughFieldstoneToe', V(7.2, 2.45, 6.2), V(7.3, .36, 1.8), stone, M.Cobblestone,
		false, V(0, -.19, .04), 'Wedge')

	for i, x in ipairs({-8, -2.7, 2.7, 7.4}) do
		part('AbutmentLowerCourse', V(5.35, 2, 5.2), V(x, 2.1, 2), stone:Lerp(coping, i * .06), M.Brick)
	end
	for i, x in ipairs({-7, -1.4, 4.2}) do
		part('AbutmentUpperCourse', V(5.4, 1.8, 4.45), V(x, 3.88, 2.2), stone:Lerp(coping, i * .11), M.Brick)
	end
	part('WeatheredCoping', V(14.4, .95, 4.8), V(-2.2, 5.14, 2.2), coping, M.Slate)
	part('MossedCopingEnd', V(5.2, .26, 4), V(-6.45, 5.68, 2.49), moss, M.Grass)
	part('MossAtFoot', V(5.8, .31, 4.85), V(7.19, 1.39, .6), moss, M.Grass,
		false, V(0, .18, 0), 'Corner')

	part('TimberBearingSill', V(13.5, .85, 1.7), V(-2.25, 5.94, 1.2), palette.wood, M.Wood)
	part('TimberBraceFoot', V(13.9, .9, 2.45), V(-1.6, .14, -3.75), palette.wood, M.Wood)
	for _, x in ipairs({-6.8, 3.15}) do
		beam('TimberRakingBrace', V(x, .43, -3.6), V(x, 5.86, 1.05), 1.36, palette.wood, M.Wood)
		part('TimberBracePeg', V(.42, .55, 1.45), V(x, 5.97, 1.16), coping, M.CorrodedMetal)
	end
end

local function rootwayBank(palette, part, beam)
	local earth = palette.ground:Lerp(palette.wood, .42)
	local slate = palette.rock:Lerp(palette.trim, .20)
	local root = palette.wood:Lerp(Color3.fromRGB(160, 128, 103), .76)
	local bark = root:Lerp(Color3.fromRGB(178, 147, 118), .34)
	local heartwood = Color3.fromRGB(206, 179, 139)

	part('BuriedShaleRib', V(22.2, 3.6, 11.4), V(-.5, .72, .72), slate, M.Slate,
		false, V(0, .15, -.05), 'Wedge')
	part('ShaleCutShoulder', V(13.4, 4.4, 10.2), V(5.86, 1.2, 3.1), slate, M.Slate,
		false, V(0, -.28, .14), 'Corner')
	part('ExposedSoilBank', V(16.8, 3.3, 8.8), V(-1.2, 2.3, 2.15), earth, M.Ground,
		false, V(.06, .12, -.05), 'Wedge')
	part('LowerShaleSeam', V(12.6, 1.28, 5.2), V(-4.8, .40, -2.75), slate:Lerp(palette.trim, .16), M.Slate,
		false, V(0, .22, .07), 'Wedge')
	part('ForestFloorRind', V(12.4, 1.1, 5.4), V(-.08, 3.25, 4.18), palette.ground, M.Ground,
		false, V(.09, .12, -.09), 'Wedge')

	local crown = V(-2.3, 4.5, 5.05)
	local fork = V(-6.3, 3.0, -.5)
	local mainElbow = V(-9.5, 1.75, -3.5)
	local sideElbow = V(4.2, 2.5, 1.05)
	beam('ExposedRootCrown', crown, fork, 3.65, root, M.Wood)
	beam('MainRootElbow', fork, mainElbow, 2.55, root, M.Wood)
	beam('MainRootSink', mainElbow, V(-12.9, -.50, -5.3), 1.45, root, M.Wood)
	beam('BankRootFork', crown, sideElbow, 2.34, bark, M.Wood)
	beam('BankRootReturn', sideElbow, V(10.25, .04, -1.75), 1.42, root, M.Wood)
	beam('FineRootTaper', fork, V(-3.13, -.38, -6.25), .90, bark, M.Wood)
	beam('BarkRidge', V(-2.38, 5.77, 5.25), V(-6.24, 4.05, -.42), .66, bark, M.Wood)
	beam('ExposedForkGrain', V(-6.3, 4.04, -.65), V(-9.5, 2.79, -3.7), .78, heartwood, M.Wood)
	part('StormSplitHeartwood', V(1.65, .5, 3.35), V(-8.31, 3.29, -2.48), heartwood, M.Wood,
		false, V(-.32, .78, .14), 'Wedge')
end

local function keeperRevetment(palette, part)
	local stone = palette.rock:Lerp(palette.trim, .34)
	local weathered = stone:Lerp(palette.trim, .32)
	local moss = palette.ground:Lerp(palette.rock, .37)
	local yaw = V(0, -.32, 0)

	part('RevetmentFoundation', V(21.4, 1.85, 9.7), V(-.4, .25, .7), stone, M.Cobblestone)
	part('ShelterRoadKerb', V(17.5, .8, 2.15), V(.65, .81, -3.2), weathered, M.Slate)
	for i, x in ipairs({-7.6, -2.4, 2.8, 7.9}) do
		part('WeatheredAshlarCourse', V(4.97, 1.68, 4.65), V(x, 1.85, 2.25), stone:Lerp(weathered, i * .10), M.Slate)
	end

	part('KeeperSillStone', V(7.8, .62, 5.8), V(.34, 2.75, .9), weathered, M.Slate)
	part('RetainedWingStone', V(5.2, 2.5, 5.1), V(-7, 3.79, 2.1), stone, M.Slate, false, yaw)
	part('LowerWingStone', V(4.85, 1.35, 4.6), V(7.3, 3.16, 2.3), stone, M.Slate,
		false, V(0, .17, 0), 'Wedge')
	part('WeatheredWingCap', V(5.62, .82, 5.48), V(-7.03, 5.04, 2.1), weathered, M.Slate, false, yaw)
	part('WingStoneMoss', V(4.4, .25, 3.4), V(-7.7, 5.50, 2.38), moss, M.Ground, false, yaw)
	part('BrokenKerbEnd', V(3.1, 1.67, 3.6), V(10, .45, -2.65), stone, M.Slate,
		false, V(0, .49, -.08), 'Corner')
end

function Models.compose(id, palette, part, beam)
	if id == 'DW-04' then
		watchtowerFooting(palette, part, beam)
	elseif id == 'GW-04' then
		rootwayBank(palette, part, beam)
	elseif id == 'HG-01' then
		keeperRevetment(palette, part)
	end
end

return Models
