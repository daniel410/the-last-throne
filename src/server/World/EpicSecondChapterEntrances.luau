-- Fixed approaches to five Chapter 2 incident spaces.
local K = require(script.Parent.EpicEnvironmentKit)
local Entrances = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function firstAidShelter(part, span, pal)
	local timber = C(119, 87, 54)
	local canvas = C(159, 141, 98)
	for _, side in ipairs({-1, 1}) do
		local x = side * 13.35
		local lowSide = side == 1
		local top = lowSide and 10.7 or 14.2
		part('ShelterDrainageShoe', V(4.6, 2.25, 4.2), V(x, .86, 0), pal.rock, M.Cobblestone, true)
		part('ShelterShoeDressedCap', V(3.6, .48, 3.5), V(x, 2, 0), C(119, 118, 90), M.Slate)
		part('ShelterAwnUpright', V(2.22, top - 2, 2.7), V(x, (top + 2) / 2, 0), timber, M.Wood, true)
		span('ShelterAwnKneeBrace', V(x, top - 3.4, 0), V(x - side * 3.1, top - .3, 0),
			.95, 2, pal.wood, M.Wood, true)
	end
	span('ShelterAwnRafter', V(-14.7, 14.2, 0), V(14.7, 10.5, 0), 1.18, 3.1, timber, M.Wood, true)
	span('ShelterMutedWaxedCanvas', V(-15.12, 14.95, 0), V(15.12, 11.15, 0), .55, 6.2, canvas, M.Fabric)
	part('ShelterRunoffEave', V(.8, .59, 6.42), V(15, 10.92, 0), pal.wood, M.Wood, false, -.12)
end

local function outerWebShelves(part, span, pal)
	local shale = C(107, 129, 125)
	local freshStone = C(141, 152, 128)
	local bark = C(89, 71, 64)
	local heartwood = C(157, 125, 96)
	part('WebShelfBedrock', V(5.6, 2.55, 6.25), V(-13.2, 1.02, 0), pal.rock, M.Slate, true)
	part('WebShelfBrokenCleavage', V(4.9, 1.53, 5.5), V(-13.14, 2.47, .13), shale, M.Slate, true, .16, 'Wedge')
	part('WebShelfExposedLayer', V(4.75, .54, 4.72), V(-13.21, 2.54, .04), freshStone, M.Slate, false, .16)
	span('WebShelfRootSoilLine', V(-15.45, 1.02, .0), V(-14.23, 4.62, .12), 3.3, 3.1, bark, M.Wood, true)
	span('WebShelfRootShoulder', V(-14.52, 4.25, .12), V(-11.55, 6.7, .12), 2.76, 3.08, bark, M.Wood, true)
	span('WebShelfRootCut', V(-11.75, 5.72, .12), V(-10.55, 7.02, .12), .52, 2.17, heartwood, M.Wood)
	span('WebShelfRootExposedGrain', V(-14.53, 3.15, -1.5), V(-12.03, 6.32, -1.5),
		.5, .32, heartwood, M.Wood)
	part('WebShelfOppositeStone', V(4.65, 1.68, 4.24), V(13.8, .61, .12), pal.rock, M.Slate, true, 0, 'Corner')
	part('WebShelfOppositeCleavage', V(3.5, .5, 3.08), V(13.82, 1.26, -.06), shale, M.Slate, false, -.17)
end

local function supplyCellar(part, span, pal)
	local stone = C(100, 126, 140)
	local edge = C(156, 176, 182)
	local larch = C(114, 90, 68)
	for _, side in ipairs({-1, 1}) do
		local x = side * 13
		part('CellarSlateShoe', V(5.38, 2.12, 5.2), V(x, .81, 0), pal.rock, M.Slate, true)
		part('CellarBankPackedSnow', V(3.35, 2.78, 5.45), V(side * 14.18, 1.2, 0),
			pal.ground, M.Snow, false, side * .12, 'Wedge')
		part('CellarDressedJamb', V(3.75, 8.5, 4.52), V(x, 5.5, 0), stone, M.Slate, true)
		part('CellarJambBedJoint', V(3.83, .23, 4.62), V(x, 4.82, 0), pal.rock, M.Slate)
		part('CellarWoodLiner', V(.62, 7.55, 3.9), V(side * 10.88, 5.6, 0), larch, M.Wood, true)
		span('CellarHewnShoulder', V(side * 13.4, 9.78, 0), V(side * 9.2, 11.62, 0),
			2.12, 4.3, stone, M.Slate, true)
	end
	part('CellarDressedLintel', V(20, 2.52, 4.4), V(0, 11.8, 0), edge, M.Slate, true)
	part('CellarWoodLinerHeader', V(20.1, .52, 3.94), V(0, 10.36, 0), larch, M.Wood)
	part('CellarCrownThawLine', V(18.5, .54, 5.26), V(-1.2, 13.12, 0), pal.ground, M.Snow, false, .024)
end

local function coolingOverlook(part, span, pal)
	local basalt = C(86, 79, 75)
	local iron = C(112, 114, 104)
	local oxide = C(173, 102, 66)
	for _, side in ipairs({-1, 1}) do
		local x = side * 13.45
		part('OverlookBasaltSeat', V(4.75, 2.08, 5.62), V(x, .83, 0), basalt, M.Basalt, true)
		part('OverlookAshBank', V(2.65, 1.11, 3.9), V(side * 14.46, .63, .29),
			C(128, 109, 92), M.Ground, false, .04, 'Corner')
		part('OverlookDressedRetainingCap', V(4.4, .78, 5.42), V(x, 2, 0), pal.rock, M.Slate)
		part('OverlookRailPedestal', V(1.78, 5.5, 2.5), V(x, 4.59, 0), iron, M.CorrodedMetal, true)
		part('OverlookRailBearing', V(2.75, .74, 2.75), V(x, 6.6, 0), iron, M.Metal)
	end
	span('OverlookFreightRailBrace', V(-13.45, 4.45, 0), V(-9.04, 7.25, 0), .84, 1.2, iron, M.Metal)
	part('OverlookFreightEndPlate', V(6.95, 1.63, 1.48), V(-11.63, 7.63, 0), iron, M.CorrodedMetal, true)
	part('OverlookFreightWearFace', V(2.85, 1.24, 1.55), V(-10.1, 7.66, 0), oxide, M.CorrodedMetal)
	part('OverlookCoolingEndPlate', V(4.52, .78, 2.1), V(13.5, 7.48, 0), pal.trim, M.Metal, true)
end

local function departureLanternWalk(part, _, pal)
	local foundation = C(113, 109, 113)
	local limestone = C(165, 156, 142)
	local agedMetal = C(110, 94, 78)
	for _, side in ipairs({-1, 1}) do
		local x = side * 13.4
		part('DepartureLanternPlinth', V(5.1, 1.38, 4.8), V(x, .49, 0), foundation, M.Limestone, true)
		part('DepartureLanternPier', V(3.64, 3.22, 3.56), V(x, 2.53, 0), limestone, M.Limestone, true)
		part('DepartureLanternPierBedJoint', V(3.71, .21, 3.63), V(x, 2.85, 0), foundation, M.Limestone)
		part('DepartureLanternRecessCore', V(3.64, 2.32, 1.23), V(x, 5.21, 0), foundation, M.Limestone, true)
		for _, face in ipairs({-1, 1}) do
			part('DepartureLanternRecessJamb', V(.86, 2.38, 3.49), V(x + face * 1.39, 5.21, 0),
				limestone, M.Limestone, true)
			part('DepartureLanternHood', V(1.88, .49, 1.22), V(x, 6.13, face * 1.12), agedMetal, M.Metal)
			part('DepartureLanternWickGuard', V(.66, .9, .56), V(x, 5.15, face * 1.16), agedMetal, M.Metal)
		end
		part('DepartureLanternCapstone', V(4.45, .9, 4.59), V(x, 6.59, 0), limestone, M.Limestone, true)
		part('DepartureLanternTopCourse', V(3.07, .65, 3.24), V(x, 7.32, 0), pal.trim, M.Limestone)
	end
end

local profiles = {
	['DW-02'] = {goal = 'exp_1', build = firstAidShelter},
	['GW-02'] = {goal = 'exp_1', build = outerWebShelves},
	['FV-02'] = {goal = 'exp_1', build = supplyCellar},
	['EC-02'] = {goal = 'exp_2', build = coolingOverlook},
	['HG-02'] = {goal = 'exp_2', build = departureLanternWalk},
}

function Entrances.create(model, chapterId, goalId, entry, area, palette)
	local profile = profiles[chapterId]
	if not profile or profile.goal ~= goalId then return false end

	-- Shift Z entrances beyond the sign while preserving the authored entrance pivot.
	local origin = area.axis == 'z' and entry + V(0, 0, area.side * 4.65) or entry
	local function part(name, size, position, color, material, solid, roll, shape)
		local frame = CFrame.new(origin + position) * CFrame.Angles(0, 0, roll or 0)
		local instance = K.part(model, name, size, frame, color, material, shape)
		if solid then instance:SetAttribute('EpicDetailSolid', true) end
	end
	local function span(name, a, b, height, depth, color, material, solid)
		local delta = b - a
		part(name, V(delta.Magnitude + .35, height, depth), (a + b) / 2, color, material, solid,
			math.atan2(delta.Y, delta.X))
	end
	profile.build(part, span, palette)
	return true
end

return Entrances
