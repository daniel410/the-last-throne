-- Native ground-edge scenery for the five regional handoffs.
-- The -Z face looks toward the story goal, with all stations above a buried foundation.
local Finale = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

Finale.profiles = {
	['DW-07'] = {name = 'ConvoyRoadLoadingSill', goal = 'core_record'},
	['GW-07'] = {name = 'NorthernWindgapStrata', goal = 'exit'},
	['FV-07'] = {name = 'FreightSledLanding', goal = 'reunion'},
	['EC-07'] = {name = 'DispatchCarrierCradle', goal = 'courier'},
	['HG-07'] = {name = 'AlliedReturnParapet', goal = 'portal'},
}

local function loadingSill(palette, part)
	local mud = C(103, 82, 63)
	local tread = C(76, 65, 51)
	local ashlar = palette.rock:Lerp(palette.trim, .38)
	part('CompactedLoadingEarth', V(16, 1.1, 10), V(0, .17, -.3), mud, M.Ground)
	for _, x in ipairs({-3.4, 3.4}) do
		part('WagonRutBed', V(1.32, .14, 7.82), V(x, .73, -1.18), tread, M.Mud)
		part('TimberWheelStop', V(3.8, 1.18, 1.94), V(x, 1.18, 1.6),
			C(147, 101, 65), M.Wood, false, V(0, -.1, 0), 'Wedge')
	end
	part('SillFoundation', V(13.4, 2, 3.1), V(0, .52, 3.28), palette.rock, M.Cobblestone)
	for _, x in ipairs({-4.4, 0, 4.4}) do
		part('DressedLoadingSill', V(4.32, .86, 3.55), V(x, 1.91, 3.16), ashlar, M.Slate)
	end
end

local function windgapStrata(palette, part)
	local weathered = C(112, 132, 151)
	local snow = C(185, 205, 217)
	part('ShaleToe', V(17, 1.32, 9.1), V(0, .31, .35), palette.rock, M.Rock)
	part('ShelteredStratum', V(10.8, 3.12, 8), V(-2.7, 1.29, .6),
		palette.rock, M.Slate, false, V(0, .14, 0), 'Wedge')
	part('WindpolishedShale', V(8.05, 3.66, 7.3), V(-3.72, 1.57, .95),
		weathered, M.Slate, false, V(0, .14, 0), 'Wedge')
	part('NorthFaceSnowDrift', V(6.66, 4.02, 6.8), V(-4.14, 1.73, 1.24),
		snow, M.Snow, false, V(0, .14, 0), 'Wedge')
	part('FracturedLeeStratum', V(7.3, 2.41, 6.68), V(4.7, 1, .54),
		weathered:Lerp(palette.rock, .32), M.Slate, false, V(0, -.24, 0), 'Wedge')
	part('LeewardSnowTongue', V(5.4, 1.08, 5.32), V(5.36, .42, -1.25),
		snow, M.Snow, false, V(0, -.3, 0), 'Wedge')
end

local function sledLanding(palette, part)
	local packed = C(158, 188, 201)
	local burnished = C(87, 130, 156)
	part('CompressedFreightSnow', V(17.5, 1.16, 9.75), V(0, .19, 0), packed, M.Snow)
	for _, x in ipairs({-3.05, 3.05}) do
		part('BurnishedSledRunnerTrack', V(.97, .16, 7.45), V(x, .77, -1.01), burnished, M.Glacier)
		part('SledStopCheek', V(3.65, 1.58, 2.45), V(x, 1.5, 2.34),
			C(120, 100, 88), M.Wood, false, V(0, math.pi, 0), 'Wedge')
		part('FreightSillSupport', V(4.1, 2.34, 2.35), V(x, .89, 3.68), palette.rock, M.Slate)
	end
	part('FreightSillIceLip', V(14.63, .94, 2.1), V(0, 2.16, 3.7), palette.trim, M.Glacier)
end

local function dispatchCradle(palette, part)
	local cutBasalt = palette.rock:Lerp(C(130, 112, 107), .48)
	local iron = C(130, 110, 101)
	part('BasaltDispatchFooting', V(15.7, 1.94, 9.28), V(0, .51, 0), palette.rock, M.Basalt)
	part('CarrierBedWearPlane', V(14.18, .58, 8.19), V(0, 1.59, 0), cutBasalt, M.Slate)
	for _, x in ipairs({-4.2, 4.2}) do
		part('CarrierSaddle', V(3.69, 1.13, 7.48), V(x, 2.35, .02), cutBasalt, M.Basalt)
		part('CarrierIronRollway', V(1.12, .43, 6.86), V(x, 3.04, .02), iron, M.CorrodedMetal)
		part('CarrierToeStop', V(3.05, .99, 1.5), V(x, 3.37, 3.05),
			iron, M.Metal, false, V(0, math.pi, 0), 'Wedge')
	end
	part('CradleRearLintel', V(10.8, .65, 1.34), V(0, 2.05, 3.24), palette.rock, M.Basalt)
end

local function returnParapet(palette, part, beam)
	local dryStone = C(139, 145, 144)
	local iron = C(109, 127, 122)
	part('BuriedParapetFooting', V(16.75, 1.85, 6.05), V(0, .53, 0), palette.rock, M.Rock)
	part('ShieldedDressingLedge', V(13.5, .74, 2.5), V(-.27, 1.06, -2.03), dryStone, M.Slate)
	for i, x in ipairs({-5.1, 0, 5.1}) do
		local height = i == 3 and 1.6 or 2.35
		part('RetainedParapetAshlar', V(5.03, height, 2.9), V(x, 1.42 + height / 2, .91),
			palette.rock:Lerp(dryStone, .3), M.Cobblestone)
		part('WeatheredParapetCap', V(5.21, .6, 3.21), V(x, 1.53 + height, .91), dryStone, M.Slate)
	end
	beam('AlliedBrace', V(-4.96, 1.24, -2.11), V(-4.96, 3.46, -.69), .51, iron, M.CorrodedMetal)
	beam('AlliedBrace', V(-1.64, 1.24, -2.11), V(-1.64, 3.46, -.69), .51, iron, M.CorrodedMetal)
end

local builders = {
	['DW-07'] = loadingSill,
	['GW-07'] = windgapStrata,
	['FV-07'] = sledLanding,
	['EC-07'] = dispatchCradle,
	['HG-07'] = returnParapet,
}

function Finale.compose(id, palette, part, beam)
	builders[id](palette, part, beam)
end

return Finale
