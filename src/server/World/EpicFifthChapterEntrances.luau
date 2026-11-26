-- Permanent terrain and structures alongside five Chapter 5 incident entrances.
local Kit = require(script.Parent.EpicEnvironmentKit)
local Entrances = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local sides = {-1, 1}

local function prisonYard(part, span, palette)
	local masonry = C(117, 123, 102)
	local timber = C(124, 95, 66)
	local iron = C(91, 88, 81)

	part('PrisonScreenFooting', V(4.7, 1.85, 5.5), V(-13.1, .72, 0), palette.rock, M.Cobblestone, true)
	part('PrisonScreenSill', V(3.4, .72, 4.94), V(-13.05, 1.93, 0), masonry, M.Slate, true)
	for _, face in ipairs(sides) do
		local z = face * 1.92
		part('PrisonScreenUpright', V(.88, 8.05, .94), V(-13.3, 5.86, z), palette.wood, M.Wood, true)
		part('PrisonScreenIronShoe', V(1.06, .87, 1.1), V(-13.3, 2.62, z), iron, M.CorrodedMetal)
		span('PrisonScreenBatterBrace', V(-14.76, 2.06, z), V(-13.32, 6.8, z), .61, .61,
			timber, M.Wood)
	end
	for index = 0, 3 do
		part('PrisonScreenBoard', V(.44, 1.56, 4.65), V(-12.8, 3.2 + index * 1.67, -.05),
			timber, M.WoodPlanks)
	end
	part('PrisonScreenWeatherCap', V(1.68, .57, 4.86), V(-13.28, 10.05, -.04), masonry, M.Slate)
	part('PrisonWheelRutShoulder', V(4.1, 1.21, 6.25), V(13.43, .41, -.25), palette.rock, M.Ground, true)
	for _, z in ipairs({-2.36, -.19, 1.98}) do
		part('PrisonWheelRutCurb', V(2.83, .75, 2.09), V(13.78, 1.17, z), masonry, M.Cobblestone, true)
	end
	part('PrisonWheelRutWearLine', V(.31, .16, 5.8), V(12.41, 1.52, -.2), C(157, 148, 119), M.Slate)
end

local function trailShelf(part, span, palette)
	local darkShale = C(71, 93, 104)
	local weatheredShale = C(101, 122, 127)
	local cutShale = C(133, 153, 150)
	local shaleEdge = C(162, 177, 164)

	part('TrailShelfBuriedToe', V(5.6, 2.15, 6.1), V(-12.94, .87, .05), darkShale, M.Slate, true)
	part('TrailShelfWeatheredFace', V(4.8, 4.67, 5.93), V(-13.29, 4.07, .05),
		weatheredShale, M.Slate, true, -.08)
	part('TrailShelfBrokenCrest', V(4.07, 2.55, 5.58), V(-13.39, 7.06, .05),
		cutShale, M.Slate, true, -.16, 'Wedge')
	for index = 0, 2 do
		local height = 2.7 + index * 1.21
		span('TrailShelfExposedCleavage', V(-15.17, height + 1.1, 0), V(-10.8, height, 0),
			.42, 5.99 - index * .08, index == 1 and shaleEdge or cutShale, M.Slate)
	end
	part('TrailShelfOuterBerm', V(5.34, 1.56, 5.23), V(13.28, .59, -.12),
		palette.ground, M.Ground, true, 0, 'Wedge')
	part('TrailShelfLowShale', V(3.62, 1.08, 4.46), V(13.52, 1.62, -.32),
		darkShale, M.Slate, true, .11)
	part('TrailShelfLowCut', V(3.75, .45, 4.52), V(13.55, 2.14, -.32), cutShale, M.Slate, false, .11)
end

local function supplyTunnel(part, _, palette)
	local coursedStone = C(100, 130, 149)
	local dressedStone = C(146, 173, 186)
	local iron = C(94, 102, 110)

	for _, side in ipairs(sides) do
		local x = side * 12.7
		part('SupplyPortalSnowDrift', V(6.18, 1.9, 6.25), V(x + side * .59, .74, 0),
			palette.ground, M.Snow, true, .19 * side, 'Wedge')
		part('SupplyPortalPlinth', V(4.56, 2.08, 5.46), V(x, 1.03, 0), palette.rock, M.Slate, true)
		part('SupplyPortalTunnelJamb', V(4.01, 6.95, 4.8), V(x, 5.53, 0),
			coursedStone, M.Slate, true)
		for _, height in ipairs({4.03, 6.57}) do
			part('SupplyPortalBondCourse', V(4.12, .48, 4.91), V(x, height, 0), dressedStone, M.Slate)
		end
		part('SupplyPortalImpost', V(4.69, .99, 5.1), V(x, 9.33, 0), dressedStone, M.Slate, true)
	end
	part('SupplyPortalTunnelHeader', V(26.1, 2.22, 4.94), V(0, 10.87, 0), coursedStone, M.Slate, true)
	part('SupplyPortalBedrockCut', V(28.3, 1.45, 5.38), V(.28, 12.62, -.06), palette.rock, M.Slate, true)
	part('SupplyPortalPackedSnowCap', V(28.61, 1.08, 5.49), V(-.1, 13.72, -.11),
		palette.ground, M.Snow)
	part('SupplyPortalWinchAnchor', V(1.34, 2.62, 3.62), V(10.21, 2.96, 0), iron, M.CorrodedMetal, true)
	for _, z in ipairs({-1.24, 1.24}) do
		part('SupplyPortalWinchClamp', V(1.77, .55, .61), V(10.04, 3.63, z), iron, M.Metal)
	end
end

local function circuitGallery(part, span, palette)
	local basalt = C(86, 78, 82)
	local firebrick = C(155, 107, 78)
	local iron = C(119, 112, 106)
	local patina = C(146, 99, 77)

	part('CircuitFlumeBasaltSeat', V(5.88, 1.63, 6.29), V(-12.94, .64, 0), basalt, M.Basalt, true)
	part('CircuitFlumeRefractoryCourse', V(4.8, 1.32, 5.44), V(-13.02, 1.92, 0),
		firebrick, M.Brick, true)
	part('CircuitFlumeSacrificialBed', V(4.07, .53, 6.86), V(-13.06, 2.78, 0), iron, M.CorrodedMetal)
	for _, side in ipairs(sides) do
		local x = -13.06 + side * 1.86
		part('CircuitFlumeOpenSidewall', V(.58, 1.58, 6.48), V(x, 3.54, 0), iron, M.Metal, true)
		part('CircuitFlumeRolledLip', V(.82, .34, 6.84), V(x, 4.43, 0), patina, M.CorrodedMetal)
		for _, z in ipairs({-2.58, 2.58}) do
			span('CircuitFlumeRivetKnee', V(x + side * .44, 2.75, z), V(x, 4.11, z),
				.42, .55, patina, M.CorrodedMetal)
		end
	end
	for _, face in ipairs(sides) do
		part('CircuitFlumeEndShoe', V(4.68, .38, .43), V(-13.06, 2.79, face * 3.22),
			patina, M.CorrodedMetal)
	end
	part('CircuitFlumeOppositeBasaltBench', V(5.1, 1.46, 5.55), V(13.17, .55, .06),
		palette.rock, M.Basalt, true, .08, 'Corner')
	part('CircuitFlumeOppositeInspectionKerb', V(3.45, .8, 4.84), V(13.37, 1.48, .08),
		firebrick, M.Brick, true)
end

local function shieldConnection(part, span, palette)
	local limestone = C(158, 153, 146)
	local oldBed = C(113, 108, 115)
	local oxidizedIron = C(102, 112, 106)

	part('ShieldConduitButtressFoot', V(5.82, 2.23, 6.62), V(-12.99, .92, .08),
		oldBed, M.Limestone, true)
	part('ShieldConduitExistingWall', V(3.71, 8.17, 5.55), V(-14.02, 5.9, .08),
		limestone, M.Limestone, true)
	part('ShieldConduitBedJoint', V(3.85, .29, 5.65), V(-13.99, 4.9, .08), oldBed, M.Limestone)
	part('ShieldConduitCutCoping', V(4.57, 1.28, 6.16), V(-13.8, 10.61, .08),
		limestone, M.Limestone, true)
	part('ShieldConduitSleeveChase', V(.49, 1.4, 6.44), V(-11.99, 5.97, .08),
		palette.rock, M.Slate)
	for _, level in ipairs({5.12, 6.78}) do
		part('ShieldConduitStrapRail', V(.67, .34, 6.43), V(-11.74, level, .08),
			oxidizedIron, M.CorrodedMetal)
	end
	for _, z in ipairs({-2.44, 0, 2.57}) do
		part('ShieldConduitRetainingRib', V(.86, 2.05, .34), V(-11.41, 5.96, z),
			oxidizedIron, M.Metal)
	end
	span('ShieldConduitLateSlopingBrace', V(-9.85, 2.1, .07), V(-12.18, 6.8, .07),
		.91, 1.18, oxidizedIron, M.CorrodedMetal, true)
	part('ShieldConduitBraceSocket', V(2.24, 1.36, 2.47), V(-9.96, 1.44, .07), oldBed, M.Limestone, true)
	part('ShieldConduitOppositeWallToe', V(5.27, 1.72, 4.35), V(13.08, .66, 0),
		palette.rock, M.Limestone, true)
	part('ShieldConduitOppositeCoping', V(4.26, 1.55, 4.04), V(13.31, 2.11, 0),
		limestone, M.Limestone, true, -.09, 'Wedge')
end

local profiles = {
	['DW-05'] = {goal = 'exp_1', build = prisonYard},
	['GW-05'] = {goal = 'exp_1', build = trailShelf},
	['FV-05'] = {goal = 'exp_2', build = supplyTunnel},
	['EC-05'] = {goal = 'exp_1', build = circuitGallery},
	['HG-05'] = {goal = 'exp_1', build = shieldConnection},
}

function Entrances.create(model, chapterId, goalId, entry, area, palette)
	local profile = profiles[chapterId]
	if not profile or profile.goal ~= goalId then return false end

	-- On Z approaches the incident board stands beside the pivot at +X.
	local origin = area.axis == 'z' and entry + V(0, 0, area.side * 4.65) or entry
	local function part(name, size, position, color, material, solid, roll, shape)
		local frame = CFrame.new(origin + position) * CFrame.Angles(0, 0, roll or 0)
		local instance = Kit.part(model, name, size, frame, color, material, shape)
		if solid then instance:SetAttribute('EpicDetailSolid', true) end
	end
	local function span(name, a, b, height, depth, color, material, solid)
		local delta = b - a
		part(name, V(delta.Magnitude + .25, height, depth), (a + b) / 2, color, material, solid,
			math.atan2(delta.Y, delta.X))
	end
	profile.build(part, span, palette)
	return true
end

return Entrances
