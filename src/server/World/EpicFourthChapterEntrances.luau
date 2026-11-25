-- Permanent entrance scenery for five Chapter 4 routes.
local K = require(script.Parent.EpicEnvironmentKit)
local Entrances = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local sides = {-1, 1}

local function watchtowerCourt(part, span, pal)
	local oldMasonry = C(111, 118, 94)
	local timber = C(129, 97, 64)
	local iron = C(97, 93, 81)

	part('RescueCourtTowerShoe', V(5.3, 2.65, 4.8), V(-13.1, 1.1, 0), pal.rock, M.Cobblestone, true)
	part('RescueCourtMasonryPier', V(3.75, 5.8, 3.7), V(-13.1, 4.87, 0), oldMasonry, M.Cobblestone, true)
	part('RescueCourtDressedCap', V(4.6, .83, 4.3), V(-13.1, 8, 0), pal.trim, M.Slate)
	part('RescueCourtShutterPost', V(2.14, 6.45, 2.5), V(-13.1, 11, 0), timber, M.Wood, true)
	for index = 0, 2 do
		part('RescueCourtShutterSlat', V(4.6, 1.3, .51), V(-11.4, 9.1 + index * 1.42, 1),
			timber, M.WoodPlanks)
	end
	span('RescueCourtShutterBrace', V(-13.1, 8.45, 1.31), V(-9.27, 12.55, 1.31), .59, .33, pal.wood, M.Wood)
	for _, level in ipairs({9.15, 11.95}) do
		part('RescueCourtHingeStrap', V(2.29, .36, 2.78), V(-13.1, level, 0), iron, M.CorrodedMetal)
	end
	part('RescueCourtOppositeShoe', V(3.6, 1.47, 3.35), V(13.58, .57, 0), pal.rock, M.Cobblestone, true)
	part('RescueCourtBrokenLowWall', V(3.42, 1.42, 3.19), V(13.75, 1.83, 0),
		oldMasonry, M.Slate, true, -.08, 'Wedge')
end

local function rootRefuge(part, span, pal)
	local shale = C(113, 133, 136)
	local heartwood = C(159, 131, 99)
	local bark = C(108, 89, 77)
	local iron = C(95, 90, 84)

	part('RootRefugeShaleSeat', V(5.75, 2.28, 5.55), V(13.1, .93, 0), pal.rock, M.Slate, true)
	part('RootRefugeShaleLayer', V(5.35, 1.51, 4.95), V(13.25, 2.56, 0), shale, M.Slate, true, .12, 'Wedge')
	part('RootRefugeExposedCleavage', V(5.28, .49, 4.76), V(13.21, 2.4, 0), C(141, 155, 147), M.Slate, false, .12)
	span('RootRefugeWeatheredRoot', V(14.3, 2.56, .27), V(13.68, 6.33, .07), 3.72, 3.82, bark, M.Wood, true)
	span('RootRefugeRootSpur', V(13.85, 5.97, .07), V(10.11, 8.31, .07), 2.66, 3.18, bark, M.Wood, true)
	part('RootRefugeExposedHeartwood', V(.73, 2.45, 2.92), V(10.03, 8.35, .07), heartwood, M.Wood, false, -.52)
	for _, face in ipairs(sides) do
		span('RootRefugeBarkEdge', V(14.2, 3.54, face * 1.82), V(11.24, 7.61, face * 1.61),
			.38, .33, heartwood, M.Wood)
	end
	part('RootRefugeTieBank', V(5.36, 1.54, 4.84), V(-13.35, .56, 0), pal.rock, M.Slate, true, 0, 'Corner')
	part('RootRefugeTieShoe', V(3.09, .72, 3.11), V(-13.15, 1.14, 0), shale, M.Slate, true)
	part('RootRefugeRopePost', V(1.96, 4.48, 1.96), V(-13.15, 3.56, 0), bark, M.Wood, true, .1)
	for _, level in ipairs({3.83, 4.17}) do
		part('RootRefugeRopeBinding', V(2.1, .23, 2.13), V(-13.23, level, 0),
			heartwood, M.Fabric, false, .1)
	end
	part('RootRefugeAnchorPlate', V(2.18, .45, 2.19), V(-13.29, 5.68, 0), iron, M.CorrodedMetal, false, .1)
end

local function archiveSignalGalleries(part, _, pal)
	local stone = C(104, 138, 157)
	local cornice = C(152, 180, 196)
	local slot = C(69, 87, 102)

	for _, side in ipairs(sides) do
		local x = side * 13.35
		part('SignalGalleryRecessFoot', V(4.54, 1.79, 3.7), V(x, .68, 0), pal.rock, M.Slate, true)
		part('SignalGalleryRecessLowerPier', V(3.48, 4.45, 3.22), V(x, 3.67, 0), stone, M.Slate, true)
		for _, jamb in ipairs(sides) do
			part('SignalGalleryRecessJamb', V(.88, 3.25, 3.23), V(x + jamb * 1.24, 7.44, 0), stone, M.Slate, true)
		end
		part('SignalGalleryPlateTrack', V(1.58, .5, 3.18), V(x, 5.97, 0), slot, M.Metal)
		part('SignalGalleryPierCap', V(4.01, 1.26, 3.46), V(x, 9.46, 0), cornice, M.Slate, true)
		part('SignalGalleryCorniceStep', V(4.85, .8, 3.68), V(x, 10.4, 0), stone, M.Slate, true)
		part('SignalGalleryCorniceSnow', V(4.91, .51, 3.83), V(x, 10.92, 0), pal.ground, M.Snow)
	end
	part('SignalGalleryClearLintel', V(24, 1.85, 3.22), V(0, 10.84, 0), stone, M.Slate, true)
	part('SignalGalleryUpperCornice', V(27.7, .74, 3.72), V(0, 12.12, 0), cornice, M.Slate, true)
	part('SignalGalleryUpperSnowLine', V(27.2, .58, 3.81), V(-.38, 12.68, 0), pal.ground, M.Snow)
end

local function coolantInspection(part, span, pal)
	local basalt = C(84, 77, 79)
	local iron = C(117, 109, 100)
	local oxide = C(157, 98, 70)
	local sediment = C(124, 98, 79)
	local center = V(-13, 4.24, .05)

	part('CoolantInspectionPipeSeat', V(5.75, 2.25, 5.3), V(-13, .9, 0), basalt, M.Basalt, true)
	part('CoolantInspectionPipeCradle', V(4.03, 1.48, 3.62), V(-13, 2.43, 0), pal.rock, M.Basalt, true)
	for index = 0, 7 do
		local angle = math.pi * index / 4
		local position = center + V(math.cos(angle) * 1.85, math.sin(angle) * 1.85, 0)
		part('CoolantInspectionPipeWall', V(1.66, .64, 3.26), position, iron, M.CorrodedMetal, true, angle + math.pi / 2)
		for _, face in ipairs(sides) do
			part('CoolantInspectionFlange', V(1.83, .79, .44), position + V(0, 0, face * 1.76),
				oxide, M.CorrodedMetal, false, angle + math.pi / 2)
		end
	end
	part('CoolantInspectionDryInvert', V(2.28, .28, 3.53), center + V(0, -1.44, 0), sediment, M.Ground)
	part('CoolantInspectionGuideFoot', V(4.23, 1.48, 4.36), V(13.5, .6, 0), basalt, M.Basalt, true)
	part('CoolantInspectionDryGuide', V(2.85, .53, 3.5), V(13.58, 1.56, 0), sediment, M.Ground)
	for _, edge in ipairs(sides) do
		part('CoolantInspectionGuideEdge', V(.48, .65, 3.7), V(13.61 + edge * 1.19, 1.86, 0),
			pal.trim, M.Slate, true)
	end
	span('CoolantInspectionCradleBrace', V(-14.8, 1.69, 1.82), V(-14.42, 3.15, 1.67), .55, .59, iron, M.Metal)
end

local function gateWorkshop(part, span, pal)
	local limestone = C(152, 145, 139)
	local base = C(109, 103, 110)
	local iron = C(109, 105, 94)
	local wood = C(119, 99, 79)

	for _, side in ipairs(sides) do
		local x = side * 13.1
		local height = side < 0 and 11.35 or 9.65
		part('GateWorkshopAnchorPlinth', V(5.32, 2.03, 4.86), V(x, .79, 0), base, M.Limestone, true)
		part('GateWorkshopAnchorPier', V(3.42, height - 1.8, 3.8), V(x, (height + 1.8) / 2, 0),
			limestone, M.Limestone, true)
		part('GateWorkshopAnchorBedJoint', V(3.5, .23, 3.89), V(x, 4.45, 0), base, M.Limestone)
		part('GateWorkshopAnchorBearing', V(4.24, .94, 4.33), V(x, height, 0), iron, M.Metal, true)
		span('GateWorkshopAnchorKnee', V(x, height - 2.78, 0), V(x - side * 2.93, height + .39, 0),
			.93, 1.59, iron, M.Metal, true)
	end
	span('GateWorkshopAnchorCrossbeam', V(-13.45, 11.97, 0), V(13.45, 10.27, 0),
		1.51, 2.65, iron, M.CorrodedMetal, true)
	span('GateWorkshopSlingStop', V(-13.39, 10.51, 1.45), V(-9.44, 11.72, 1.45), .56, .62, wood, M.Wood)
	part('GateWorkshopHeadstock', V(3.08, 2.58, 3.03), V(-11.31, 12.43, 0), iron, M.Metal)
end

local profiles = {
	['DW-04'] = {goal = 'exp_1', build = watchtowerCourt},
	['GW-04'] = {goal = 'exp_2', build = rootRefuge},
	['FV-04'] = {goal = 'exp_1', build = archiveSignalGalleries},
	['EC-04'] = {goal = 'exp_1', build = coolantInspection},
	['HG-04'] = {goal = 'exp_1', build = gateWorkshop},
}

function Entrances.create(model, chapterId, goalId, entry, area, palette)
	local profile = profiles[chapterId]
	if not profile or profile.goal ~= goalId then return false end

	-- Keep Z-axis supports inside the apron, clear of the board beside the pivot.
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
