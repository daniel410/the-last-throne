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
	local tread = C(71, 60, 46)
	local ashlar = palette.rock:Lerp(palette.trim, .38)
	local timber = C(111, 82, 58)
	part('CompactedLoadingEarth', V(13.6, 1.12, 9.8), V(0, .04, -.45), mud, M.Ground)
	for _, x in ipairs({-5.2, 5.2}) do
		part('FeatheredRoadVerge', V(4.5, .63, 9), V(x, -.02, -.01),
			mud:Lerp(C(112, 109, 73), .45), M.Ground, false, V(0, x < 0 and -.14 or .14, 0), 'Wedge')
	end
	for _, x in ipairs({-3.4, 3.4}) do
		part('WagonRutBed', V(1.25, .13, 7.7), V(x, .57, -1.37), tread, M.Mud)
		part('TimberWheelStop', V(3.8, 1.27, 2.1), V(x, 1.18, 1.6),
			timber, M.Wood, false, V(0, -.1, 0), 'Wedge')
	end
	part('SillFoundation', V(13.4, 2, 3.1), V(0, .52, 3.28), palette.rock, M.Cobblestone)
	for _, x in ipairs({-4.4, 0, 4.4}) do
		part('DressedLoadingSill', V(4.32, .86, 3.55), V(x, 1.91, 3.16), ashlar, M.Slate)
	end
end

local function windgapStrata(_, part)
	local weathered = C(123, 144, 162)
	local lowerSlate = C(91, 110, 129)
	local snow = C(185, 205, 217)
	part('ShaleToe', V(17, 1.32, 9.1), V(0, .24, .35), lowerSlate, M.Slate)
	part('ExposedBedding', V(15.1, 1.26, 8.2), V(.28, .65, .43),
		lowerSlate:Lerp(weathered, .39), M.Slate, false, V(0, .08, 0), 'Wedge')
	part('ShelteredStratum', V(10.8, 3.12, 8), V(-2.7, 1.29, .6),
		lowerSlate, M.Slate, false, V(0, .14, 0), 'Wedge')
	part('WindpolishedShale', V(8.05, 3.66, 7.3), V(-3.72, 1.57, .95),
		weathered, M.Slate, false, V(0, .14, 0), 'Wedge')
	part('NorthFaceSnowDrift', V(5.92, 3.92, 6.3), V(-4.28, 1.81, 1.43),
		snow, M.Snow, false, V(0, .14, 0), 'Wedge')
	part('FracturedLeeStratum', V(7.3, 2.41, 6.68), V(4.7, 1, .54),
		weathered:Lerp(lowerSlate, .54), M.Slate, false, V(0, -.24, 0), 'Wedge')
	part('LeewardSnowTongue', V(5.4, 1.08, 5.32), V(5.36, .42, -1.25),
		snow:Lerp(weathered, .18), M.Snow, false, V(0, -.3, 0), 'Wedge')
end

local function sledLanding(palette, part)
	local packed = C(161, 191, 204)
	local burnished = C(93, 133, 154)
	local timber = C(109, 86, 68)
	part('CompressedFreightSnow', V(15.1, .68, 8.25), V(-.55, .02, .61), packed, M.Snow)
	part('FeatheredFreightApproach', V(14.2, .62, 4.15), V(-.7, .035, -2.7),
		packed:Lerp(C(208, 228, 235), .36), M.Snow, false, nil, 'Wedge')
	for _, x in ipairs({-4.1, 2}) do
		part('BurnishedSledRunnerTrack', V(1.12, .15, 6.8), V(x, .36, .05), burnished, M.Glacier)
		part('SledStopCheek', V(3.65, 1.75, 2.5), V(x, 1.19, 2.25),
			timber, M.Wood, false, V(0, math.pi, 0), 'Wedge')
		part('FreightSillSupport', V(4.1, 2.18, 2.35), V(x, .78, 3.68), palette.rock, M.Slate)
	end
	part('FreightSillIceLip', V(14.63, .94, 2.1), V(-.65, 2.16, 3.7), palette.trim, M.Glacier)
end

local function dispatchCradle(palette, part)
	local cutBasalt = palette.rock:Lerp(C(126, 111, 102), .44)
	local iron = C(120, 117, 108)
	part('BasaltDispatchFooting', V(15.7, 1.94, 9.28), V(0, .51, 0), palette.rock, M.Basalt)
	part('CarrierBedWearPlane', V(14.18, .45, 8.19), V(0, 1.54, 0), cutBasalt, M.Slate)
	for _, x in ipairs({-4.2, 4.2}) do
		part('CarrierSaddle', V(3.45, 1.09, 7.48), V(x, 2.25, .02), cutBasalt, M.Basalt)
		part('CarrierIronRollway', V(1.18, .46, 7.7), V(x, 2.91, -.17), iron, M.CorrodedMetal)
		part('CarrierLoadingRamp', V(1.82, 1.48, 1.88), V(x, 2.38, -3.52),
			iron, M.CorrodedMetal, false, nil, 'Wedge')
		part('CarrierToeStop', V(2.5, 1.15, 1.48), V(x, 3.29, 3.05),
			iron:Lerp(cutBasalt, .21), M.Metal, false, V(0, math.pi, 0), 'Wedge')
	end
	part('CradleRearLintel', V(10.8, .74, 1.34), V(0, 2.05, 3.24), cutBasalt, M.Basalt)
end

local function returnParapet(palette, part, beam)
	local dryStone = C(149, 157, 155)
	local iron = C(123, 143, 136)
	part('BuriedParapetFooting', V(16.75, 1.85, 6.05), V(0, .53, 0), palette.rock, M.Rock)
	part('ShieldedDressingLedge', V(13.5, .74, 2.5), V(-.27, 1.06, -2.03), dryStone, M.Slate)
	for i, x in ipairs({-5.1, 0, 5.1}) do
		local height = 2.39 - (i - 1) * .55
		part('RetainedParapetAshlar', V(5.03, height, 2.9), V(x, 1.42 + height / 2, .91),
			palette.rock:Lerp(dryStone, .44), M.Cobblestone)
		part('WeatheredParapetCap', V(5.16, .6, 3.33), V(x, 1.53 + height, .87), dryStone, M.Slate)
	end
	beam('AlliedBrace', V(-4.96, 1.24, -2.11), V(-4.96, 3.46, -.69), .51, iron, M.CorrodedMetal)
	beam('AlliedBrace', V(-1.64, 1.24, -2.11), V(-1.64, 3.19, -.69), .51, iron, M.CorrodedMetal)
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
