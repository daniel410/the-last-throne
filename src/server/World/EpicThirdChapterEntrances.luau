-- Authored silhouettes for the five Chapter 3 incident approaches.
local K = require(script.Parent.EpicEnvironmentKit)
local Entrances = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local sides = {-1, 1}

local function signalTerrace(part, span, pal)
	local timber = C(119, 81, 49)
	for _, side in ipairs(sides) do
		local x = side * 13
		part('LookoutStoneShoe', V(4.6, 2.5, 4.6), V(x, 1.05, 0), pal.rock, M.Cobblestone, true)
		part('LookoutTimberUpright', V(2.8, 16.5, 3.6), V(x, 9.1, 0), timber, M.Wood, true)
		span('LookoutKneeBrace', V(x, 11.2, 0), V(side * 8.8, 16.7, 0), 1.5, 2.7, pal.wood, M.Wood, true)
		part('LookoutLashing', V(3, .85, 3.8), V(x, 15.7, 0), C(159, 131, 87), M.Fabric)
		part('LookoutSignalPaddle', V(3.45, 5.5, .9), V(side * 4.1, 18.3, 0), side < 0 and C(177, 137, 63) or C(112, 121, 83), M.WoodPlanks, false, math.rad(side * -19))
	end
	part('LookoutLintel', V(29.8, 2.55, 3.3), V(0, 17.5, 0), pal.wood, M.Wood, true)
	part('LookoutSignalRail', V(15.8, .73, 1.25), V(0, 19.25, 0), timber, M.Wood)
end

local function lanternRefuge(part, span, pal)
	local bark = C(84, 69, 67)
	local heartwood = C(117, 92, 76)
	local warmGlass = C(231, 164, 92)
	for _, side in ipairs(sides) do
		part('RefugeShaleFoot', V(4.8, 2.4, 5.2), V(side * 13.2, 1, 0), pal.rock, M.Slate, true)
	end
	span('RefugeRootTrunk', V(-13.2, .8, .15), V(-12.9, 10.3, .1), 3.8, 4, bark, M.Wood, true)
	span('RefugeRootShoulder', V(-12.9, 10.2, .1), V(-9.45, 16.05, .1), 3.35, 3.6, bark, M.Wood, true)
	span('RefugeRootCrown', V(-9.65, 15.95, .1), V(-1.75, 18.55, .1), 3.18, 3.5, bark, M.Wood, true)
	span('RefugeRootUpperFork', V(-3.05, 18.2, .1), V(7.7, 19.8, .1), 1.85, 2.7, heartwood, M.Wood)
	span('RefugeRootRib', V(-13.8, 3.2, -1.8), V(-11.15, 13.35, -1.8), .7, .63, heartwood, M.Wood)
	span('RefugeRootRib', V(-13.25, 4.2, 1.95), V(-11.35, 13.15, 1.95), .61, .71, heartwood, M.Wood)
	part('RefugeLanternUpright', V(2.6, 14.2, 3.16), V(13.25, 7.6, 0), heartwood, M.Wood, true)
	span('RefugeLanternBracket', V(13.3, 12.15, 0), V(9.1, 14.15, 0), 1.18, 1.35, heartwood, M.Wood)
	part('RefugeLanternIronHousing', V(2.4, 2.75, 2.34), V(9.25, 12.6, 0), pal.wood, M.Metal)
	part('RefugeLanternGlass', V(2.54, 1.25, 2.48), V(9.25, 12.6, 0), warmGlass, M.Neon)
	part('RefugeLanternCap', V(2.85, .52, 2.85), V(9.25, 14, 0), C(122, 100, 76), M.Metal)
end

local function ravineRescue(part, span, pal)
	local larch = C(88, 83, 70)
	local windboard = C(126, 132, 117)
	for _, side in ipairs(sides) do
		local x = side * 12.75
		part('RavineStoneBase', V(5.15, 3, 5.25), V(x, 1.25, 0), pal.rock, M.Slate, true)
		part('RavinePackedSnowSkirt', V(5.35, .64, 5.35), V(x, .48, 0), pal.ground, M.Snow)
		span('RavineShelterLeg', V(x, 2.1, 0), V(side * 11, 11.25, 0), 2.85, 4, larch, M.Wood, true)
		span('RavineWindbreakRoof', V(side * 13.15, 11.4, 0), V(side * .05, 14.8, 0), 1.2, 5.2, windboard, M.WoodPlanks, true)
		span('RavineRoofSnow', V(side * 13.1, 12.15, 0), V(side * .06, 15.63, 0), .72, 4.85, pal.ground, M.Snow)
		part('RavinePaintedShoulder', V(3.2, 1.15, 4.15), V(side * 11.35, 9.55, 0), C(191, 144, 82), M.Wood)
	end
	part('RavineShelterTie', V(24.6, 1.24, 3.18), V(0, 11.55, 0), larch, M.Wood, true)
end

local function mineStaging(part, span, pal)
	local iron = C(93, 97, 94)
	local darkIron = C(68, 70, 73)
	local oxide = C(166, 100, 68)
	for _, side in ipairs(sides) do
		local x = side * 13.05
		part('MinePortalBasaltShoe', V(5.2, 3, 5.45), V(x, 1.23, 0), pal.rock, M.Basalt, true)
		part('MinePortalIronJamb', V(2.7, 14.85, 3.35), V(x, 8.65, 0), darkIron, M.CorrodedMetal, true)
		part('MinePortalBearingPlate', V(4.25, .86, 4.36), V(x, 15.66, 0), iron, M.Metal)
		span('MinePortalTrussBrace', V(side * 12.7, 16.2, 0), V(0, 20.15, 0), 1.35, 2.85, iron, M.Metal, true)
		span('MinePortalTrussWeb', V(side * 6.3, 18.22, 0), V(side * 1.1, 16, 0), 1, 2.8, darkIron, M.Metal)
		for _, face in ipairs(sides) do
			part('MinePortalFadedSafetyStripe', V(2.56, 1.28, .13), V(x, 11.8, face * 1.71), oxide, M.Metal)
		end
	end
	part('MinePortalClearSpan', V(29.4, 1.7, 3.8), V(0, 16.03, 0), iron, M.Metal, true)
	part('MinePortalRidgePlate', V(2.9, 1.8, 3.1), V(0, 20, 0), oxide, M.CorrodedMetal)
end

local function fortressLanding(part, span, pal)
	local stone = C(141, 135, 135)
	local cap = C(174, 168, 162)
	local mortar = C(101, 97, 107)
	for _, side in ipairs(sides) do
		local x = side * 12.75
		part('FortressWallPlinth', V(5.55, 1.75, 6), V(x, .68, 0), mortar, M.Limestone, true)
		part('FortressWallJamb', V(3.45, 10.8, 5), V(x, 6.1, 0), stone, M.Limestone, true)
		for course = 1, 3 do
			part('FortressDressedCourse', V(3.59, 2.17, 5.13), V(x, 2.7 * course + .2, 0), course == 2 and mortar or stone, M.Limestone)
		end
		part('FortressDoorImpost', V(4.5, 1.28, 5.55), V(x, 11.25, 0), cap, M.Limestone, true)
		span('FortressDoorSpring', V(side * 12.9, 11.85, 0), V(side * 9.1, 15.85, 0), 2.55, 5.1, stone, M.Limestone, true)
		span('FortressDoorVault', V(side * 9.25, 15.8, 0), V(side * 3.1, 18.15, 0), 2.55, 5.15, cap, M.Limestone, true)
	end
	part('FortressDoorCrownStone', V(6.55, 2.65, 5.35), V(0, 18.05, 0), stone, M.Limestone, true)
	part('FortressDoorCrownInset', V(2.35, 2.1, 5.49), V(0, 18.2, 0), pal.trim, M.Limestone)
end

local chapters = {
	['DW-03'] = {goal = 'exp_2', build = signalTerrace},
	['GW-03'] = {goal = 'exp_1', build = lanternRefuge},
	['FV-03'] = {goal = 'exp_1', build = ravineRescue},
	['EC-03'] = {goal = 'exp_1', build = mineStaging},
	['HG-03'] = {goal = 'exp_2', build = fortressLanding},
}

function Entrances.create(model, chapterId, goalId, entry, area, palette)
	local profile = chapters[chapterId]
	if not profile or profile.goal ~= goalId then return false end

	-- On Z connectors the existing board stands abreast of the model pivot.
	-- Set the structure into the apron so the board retains its own silhouette.
	local offset = area.axis == 'z' and V(0, 0, area.side * 3.9) or V(0, 0, 0)
	local function part(name, size, position, color, material, solid, roll)
		local frame = CFrame.new(entry + offset + position) * CFrame.Angles(0, 0, roll or 0)
		local instance = K.part(model, name, size, frame, color, material)
		if solid then instance:SetAttribute('EpicDetailSolid', true) end
	end
	local function span(name, a, b, height, depth, color, material, solid)
		local delta = b - a
		part(name, V(delta.Magnitude + .35, height, depth), (a + b) / 2, color, material, solid, math.atan2(delta.Y, delta.X))
	end
	profile.build(part, span, palette)
	return true
end

return Entrances
