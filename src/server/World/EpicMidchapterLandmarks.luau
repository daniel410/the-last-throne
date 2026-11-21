-- Terrain-side assemblies for the incidents where the first rescues become plans.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function stragglerBendShoulder(pal, part)
	local fieldstone = pal.rock:Lerp(pal.trim, .53)
	local cutFace = fieldstone:Lerp(C(167, 150, 112), .65)
	local runoff = pal.ground:Lerp(C(108, 83, 59), .72)
	local depositedSilt = runoff:Lerp(C(161, 132, 92), .65)
	local moss = pal.ground:Lerp(pal.leaf, .43)
	part('ShelteredBendEarthBank', V(6.2, 1.32, 9.9), V(-.5, .38, 0), moss, M.Ground,
		'Wedge', V(0, math.pi, 0))
	part('WashedBankToe', V(1.68, .37, 8.3), V(1.88, .14, -.22), runoff, M.Pebble,
		'Wedge', V(0, math.pi, 0))
	for i, z in ipairs({-3.1, -.60, 2.05}) do
		local x = .91 - i * .29
		part('ShelterBendFieldstone', V(2.72, .91 + i * .12, 2.4), V(x, .37 + i * .06, z),
			fieldstone:Lerp(pal.rock, i * .13), M.Cobblestone, nil, V(0, .09 * i, 0))
		part('WashedCopingShale', V(2.56, .36, 2.29), V(x, .96 + i * .12, z + .03), cutFace,
			M.Slate, 'Wedge', V(0, -math.pi / 2 + .09 * i, 0))
	end
	-- Sediment collects where the water drops off the stone-lined bend.
	part('BendSiltRibbon', V(.61, .22, 4.15), V(2.29, .22, -1.50), depositedSilt, M.Sand,
		'Wedge', V(0, .045, 0))
	part('BendSiltRibbon', V(.64, .22, 3.23), V(2.13, .20, 2.18), depositedSilt, M.Sand,
		'Wedge', V(0, .12, 0))
	part('RunoffFan', V(2.45, .20, 1.97), V(1.45, .12, 4.02), runoff, M.Ground, 'Corner',
		V(0, -.42, 0))
end

local function outerWebRootShelf(pal, part, beam)
	local shale = pal.rock:Lerp(pal.trim, .56)
	local freshShale = shale:Lerp(C(156, 158, 137), .70)
	local bark = pal.wood:Lerp(C(139, 111, 90), .63)
	local heartwood = bark:Lerp(C(192, 162, 117), .50)
	part('RootShelfBuriedShale', V(4.9, 1.37, 10.1), V(.48, .39, .02), pal.rock, M.Slate,
		'Wedge', V(0, math.pi, 0))
	part('RootShelfExposedEdge', V(2.8, .83, 7.5), V(-.86, .26, -.57), shale, M.Slate,
		'Wedge', V(0, -.22, 0))
	part('RootShelfSplitBedding', V(1.6, .42, 4.34), V(1.19, .34, -2.23), freshShale, M.Slate,
		'Wedge', V(0, math.pi + .12, 0))
	part('RootShelfReturnBedding', V(1.82, .44, 2.30), V(.34, .34, 3.12), freshShale, M.Slate,
		'Corner', V(0, -.24, 0))
	beam('RootShelfShoulder', V(.45, .24, -4.66), V(.77, 2.08, 1.12), 1.15, bark, M.Wood)
	beam('RootShelfBuriedFork', V(.77, 2.08, 1.12), V(2.19, .26, 4.36), .84, bark, M.Wood)
	beam('RootShelfLowFork', V(.77, 2.08, 1.12), V(-1.17, .31, 4.15), .66, bark, M.Wood)
	beam('RootShelfWornRidge', V(.12, .85, -3.18), V(.24, 2.06, .97), .43, heartwood, M.Wood)
	beam('RootShelfWornRidge', V(.24, 2.06, .97), V(-.70, .88, 3.34), .33, heartwood, M.Wood)
	beam('RootShelfSplitForkGrain', V(1.14, 1.91, 1.42), V(1.99, .83, 3.38), .39, heartwood, M.Wood)
	part('RootShelfFracturedToe', V(1.65, .42, 1.45), V(-1.66, .10, 2.37), shale, M.Slate,
		'Corner', V(0, .62, 0))
end

local function twinBeaconTerraceSill(pal, part)
	local ashlar = pal.rock:Lerp(pal.trim, .24)
	local wornSlate = pal.rock:Lerp(pal.trim, .57)
	local exposedSlate = ashlar:Lerp(C(123, 150, 170), .51)
	local drift = pal.ground:Lerp(pal.trim, .30)
	local treadSnow = pal.ground:Lerp(wornSlate, .46)
	part('TerraceGlacialFoot', V(7.38, .91, 4.98), V(0, .39, .47), pal.rock, M.Slate, 'Wedge')
	for _, x in ipairs({-2.29, 0, 2.29}) do
		part('TerraceRetainingFoot', V(2.25, .32, 1.88), V(x, .325, -.52), ashlar, M.Cobblestone)
		part('TerraceRetainingCourse', V(2.25, .42, 1.76), V(x, .685, -.46), exposedSlate, M.Slate)
		part('TerraceWornCoping', V(2.27, .29, 2.21), V(x, 1.04, -.48), wornSlate, M.Slate)
	end
	part('ShelteredTerraceDrift', V(6.62, .86, 3.12), V(-.24, .80, 1.42), drift, M.Snow,
		'Wedge', V(0, math.pi, 0))
	part('TerraceCompressedSnow', V(5.63, .38, 1.19), V(.72, .17, -1.78), treadSnow, M.Snow, 'Wedge')
	part('TerraceCopingSnowCurl', V(1.91, .58, 1.30), V(-2.17, .93, .50), drift, M.Snow,
		'Corner', V(0, -.19, 0))
	part('FracturedTerraceEnd', V(1.45, .64, 2.66), V(3.15, .49, 1.19), ashlar, M.Slate,
		'Corner', V(0, -.36, 0))
end

local function mineFreightLineSeat(pal, part)
	local basalt = pal.rock:Lerp(C(111, 99, 100), .45)
	local ash = pal.ground:Lerp(C(112, 85, 73), .53)
	local rail = C(104, 95, 87)
	local plate = rail:Lerp(C(158, 132, 109), .59)
	local tread = rail:Lerp(C(177, 160, 144), .61)
	part('FreightLineAshBallast', V(5.65, .65, 9.52), V(0, .27, 0), ash, M.Ground, 'Wedge')
	for _, z in ipairs({-3.11, -.1, 3.19}) do
		part('FreightLineBasaltSleeper', V(4.73, .70, 1.11), V(0, .48, z), basalt, M.Basalt)
		for _, x in ipairs({-.98, .98}) do
			part('FreightLineIronChairs', V(.89, .39, .91), V(x, 1.01, z), plate, M.CorrodedMetal)
		end
	end
	for _, x in ipairs({-.98, .98}) do
		part('FreightRailFoot', V(.38, .13, 7.81), V(x, 1.155, .04), rail, M.CorrodedMetal)
		part('FreightRailWeb', V(.17, .24, 7.81), V(x, 1.30, .04), rail, M.CorrodedMetal)
		part('FreightRailWornHead', V(.31, .14, 7.81), V(x, 1.46, .04), tread, M.Metal)
		part('FreightRailCutFoot', V(.47, .15, .24), V(x, 1.155, -3.94), plate, M.CorrodedMetal)
		part('FreightRailCutWeb', V(.19, .24, .24), V(x, 1.31, -3.94), plate, M.CorrodedMetal)
		part('FreightRailCutHead', V(.36, .14, .24), V(x, 1.47, -3.94), tread, M.Metal)
	end
end

local function keeperReturnLanternNiche(pal, part)
	local ashlar = pal.rock:Lerp(C(151, 144, 134), .59)
	local coping = pal.trim:Lerp(C(181, 167, 145), .56)
	local wornStone = ashlar:Lerp(C(168, 151, 123), .72)
	local iron = C(101, 99, 94)
	part('KeeperNicheApron', V(6.68, .52, 4.48), V(0, .21, .18), pal.ground:Lerp(ashlar, .53),
		M.Cobblestone, 'Wedge', V(0, math.pi, 0))
	part('KeeperNichePlinth', V(5.48, .81, 3.05), V(0, .38, .32), ashlar, M.Cobblestone)
	part('KeeperNicheBackstone', V(3.95, 2.74, .84), V(0, 2.16, 1.14), pal.rock, M.Slate)
	for _, x in ipairs({-1.43, 1.43}) do
		part('KeeperNicheJambLowerCourse', V(.96, .95, 1.99), V(x, 1.265, .32), ashlar, M.Slate)
		part('KeeperNicheJambBed', V(.96, .18, 1.99), V(x, 1.83, .32), wornStone, M.Limestone)
		part('KeeperNicheJambUpperCourse', V(.96, 1.63, 1.99), V(x, 2.715, .32), ashlar, M.Slate)
		part('KeeperNicheBeveledShoulder', V(.94, .53, 2.12), V(x, 3.75, .34), coping, M.Slate,
			'Wedge', V(0, math.sign(x) * math.pi / 2, 0))
	end
	part('KeeperNicheLintel', V(2.0, .53, 2.11), V(0, 3.75, .34), coping, M.Slate)
	part('KeeperNicheWornSill', V(2.04, .32, 1.88), V(0, .95, .08), coping, M.Cobblestone)
	part('KeeperNicheDripNose', V(1.91, .24, .62), V(0, .83, -.90), wornStone, M.Limestone,
		'Wedge', V(0, math.pi, 0))
	part('KeeperNicheLampSeat', V(1.43, .20, .94), V(0, 1.20, .41), iron, M.CorrodedMetal)
end

return {
	['DW-02'] = {goal = 'exp_2', step = 2, name = 'StragglerBendDrainageShoulder', side = -9, compose = stragglerBendShoulder},
	['GW-02'] = {goal = 'exp_1', step = 2, name = 'OuterWebRootShelf', side = -9, compose = outerWebRootShelf},
	['FV-02'] = {goal = 'exp_2', step = 1, name = 'TwinBeaconTerraceSill', side = -9, compose = twinBeaconTerraceSill},
	['EC-02'] = {goal = 'exp_2', step = 2, name = 'MineFreightLineSeat', side = -9, compose = mineFreightLineSeat},
	['HG-02'] = {goal = 'exp_2', step = 3, name = 'KeeperReturnLanternNiche', side = -9, compose = keeperReturnLanternNiche},
}
