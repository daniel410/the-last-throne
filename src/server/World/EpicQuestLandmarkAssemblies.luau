-- Terrain-side fixtures for the five representative quest actions.
local Bounds = require(game.ReplicatedStorage.Shared.CampaignBounds)
local Kit = require(script.Parent.EpicEnvironmentKit)

local Assemblies = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function dryShelf(pal, part, beam)
	local fieldstone = pal.rock:Lerp(pal.wood, .32)
	local wetEarth = pal.ground:Lerp(C(89, 70, 46), .65)
	local splitWood = pal.wood:Lerp(C(164, 121, 77), .65)
	part('DrainageShoulder', V(11, 1.2, 6), V(0, .20, .45), wetEarth, M.Ground, 'Wedge')
	for _, x in ipairs({-2.7, 2.7}) do
		part('GravelDrainLip', V(3.4, .3, 1.6), V(x, .07, -2.6), fieldstone, M.Pebble)
	end
	part('RunoffApron', V(1.9, .21, 1.5), V(0, .04, -2.63), wetEarth:Lerp(fieldstone, .44), M.Ground, 'Wedge')
	-- The hood drains onto a shallow stone run across the top of the wet bank.
	part('DripBed', V(7.8, .55, .66), V(0, .25, -1.38), wetEarth, M.Pebble)
	for _, x in ipairs({-3.5, 3.5}) do
		part('DripSplashStone', V(.83, .20, .92), V(x, .50, -1.49), fieldstone, M.Slate,
			'Wedge', V(0, math.pi, 0))
		part('FieldstoneFoot', V(2.25, .92, 3.7), V(x, .26, .44), fieldstone, M.Cobblestone)
		part('ShelfTrestle', V(.72, 1.7, 2.7), V(x, 1.23, .44), pal.wood, M.Wood)
		beam('RainHoodPost', V(x, 1.7, 1.65), V(x, 4.28, 1.65), .48, pal.wood, M.Wood)
		beam('RainHoodKnee', V(x, 2.7, 1.65), V(x, 3.49, -.16), .34, splitWood, M.Wood)
	end
	part('RaisedDrySlats', V(8.1, .28, 3.2), V(0, 2.08, .43), splitWood, M.WoodPlanks)
	for _, z in ipairs({-.67, .57, 1.81}) do
		part('OverlappingRainShingle', V(8.5, .24, 1.46), V(0, 3.71 + z * .28, z), pal.wood, M.WoodPlanks,
			nil, V(-.273, 0, 0))
	end
	part('RainHoodDripEdge', V(8.55, .34, .23), V(0, 3.29, -1.38), splitWood, M.Wood)
	part('WaxedCanvasRoll', V(2.7, .44, .53), V(-1.8, 2.44, .76), C(150, 133, 100), M.Fabric, 'Cylinder')
end

local function rearguardBank(pal, part, beam)
	local shale = pal.rock:Lerp(C(132, 142, 150), .57)
	local exposedRoot = pal.wood:Lerp(C(154, 123, 86), .73)
	local heartwood = C(185, 154, 112)
	part('RootBankShaleFoot', V(10.2, 1.5, 5.4), V(0, .30, .6), shale, M.Slate, 'Wedge')
	part('LoamBankShoulder', V(8.2, 1.5, 4.2), V(-.75, .39, 1), pal.ground, M.Ground, 'Corner', V(0, .35, 0))
	beam('ExposedRootShoulder', V(-3.1, .21, -1.4), V(.3, 1.81, 1.45), 1.08, exposedRoot, M.Wood)
	beam('ExposedRootFork', V(.3, 1.81, 1.45), V(4.05, .22, .16), .73, exposedRoot, M.Wood)
	beam('RootTaper', V(.3, 1.81, 1.45), V(.94, .34, 3.08), .61, pal.wood, M.Wood)
	-- The split follows the root across the trail-facing and return-facing sides.
	beam('SplitHeartwood', V(-1.65, .99, -.81), V(-.10, 1.88, .59), .38, heartwood, M.Wood)
	beam('SplitHeartwood', V(.48, 1.93, 1.79), V(2.18, .95, 1.16), .34, heartwood, M.Wood)
	local shaleFace = shale:Lerp(pal.trim, .4)
	part('ShaleShoulder', V(3.45, .75, 2.4), V(-3.28, .24, 1.41), shaleFace, M.Slate,
		'Wedge', V(0, .37, 0))
	part('ShaleToe', V(2.7, .48, 1.62), V(2.78, .14, -.59), shaleFace, M.Slate,
		'Wedge', V(0, -2.71, 0))
	for _, x in ipairs({-3.65, 3.65}) do
		beam('RetreatRopePeg', V(x, .12, .6), V(x * .94, 2.48, 1.15), .37, exposedRoot, M.Wood)
	end
	beam('SaggingRetreatRope', V(-3.45, 2.28, 1.12), V(0, 1.64, 1.36), .16, pal.trim, M.Fabric)
	beam('SaggingRetreatRope', V(0, 1.64, 1.36), V(3.45, 2.28, 1.12), .16, pal.trim, M.Fabric)
end

local function signalSill(pal, part, beam)
	local iron = C(93, 117, 129)
	local shelter = C(98, 151, 146)
	part('GlacialShaleFoot', V(8.8, 1.55, 5.3), V(0, .31, .2), pal.rock, M.Slate, 'Wedge')
	part('PackedSnowLedge', V(6.1, 1.04, 4.1), V(-1, .30, 1.05), pal.ground, M.Snow, 'Corner', V(0, -.4, 0))
	part('BrokenSnowShelf', V(3.45, .65, 2.4), V(2.15, .22, 1.15), pal.ground, M.Snow, 'Wedge',
		V(0, .48, 0))
	part('ChiseledRelaySill', V(5.9, .55, 2.9), V(.64, 1.04, .82), pal.trim, M.Glacier)
	part('ExposedCradleSeat', V(5.65, .18, 1.74), V(.64, 1.36, .80), iron:Lerp(pal.rock, .4), M.Metal)
	for _, x in ipairs({-1.52, 2.75}) do
		part('CradleFoot', V(1.05, .32, 2.05), V(x, 1.61, .80), iron, M.Metal)
		part('CradleFootBolt', V(.22, .14, .22), V(x, 1.82, .02), pal.trim, M.Metal)
		beam('SightingCradleUpright', V(x, 1.65, 1.18), V(x, 3.27, .89), .43, iron, M.Metal)
	end
	part('RelayObservationCrosshead', V(4.9, .39, 1.12), V(.61, 3.13, .91), iron, M.Metal)
	for _, side in ipairs({-1, 1}) do
		beam('ShelterRoofInlay', V(.61, 3.63, .31), V(.61 + side * .72, 3.19, .31), .17, shelter, M.Metal)
	end
	part('RelayFootIce', V(5.75, .42, 1.27), V(-.91, .18, -1.72), pal.rock:Lerp(pal.trim, .48), M.Glacier, 'Wedge')
end

local function planFootings(pal, part, beam)
	local firebrick = pal.rock:Lerp(C(161, 117, 84), .63)
	local wornFirebrick = C(170, 128, 97)
	local soot = pal.wood:Lerp(C(52, 42, 38), .57)
	for _, x in ipairs({-5, 5}) do
		part('BasaltWorktableFoot', V(2.45, .63, 3.2), V(x, .19, 0), pal.rock, M.Basalt)
		part('RefractoryBearingTile', V(1.94, .23, 2.75), V(x, .55, .02), firebrick, M.Brick)
		beam('IronTrestleBrace', V(x, .64, .65), V(x * .65, 1.88, .33), .33, soot, M.CorrodedMetal)
	end
	-- Short returns expose the dry trough on either side of the taller drafting table.
	local dryBed = firebrick:Lerp(soot, .6)
	part('DryRecoveryBed', V(11.57, .24, 1.86), V(0, .05, -2.47), dryBed, M.Basalt)
	part('RecoveryOuterLip', V(14.72, .38, .32), V(0, .13, -3.23), firebrick, M.Brick)
	part('RecoveryInnerLip', V(12.22, .38, .32), V(0, .13, -1.71), firebrick, M.Brick)
	for _, side in ipairs({-1, 1}) do
		part('DryRecoveryReturn', V(1.57, .24, 5.59), V(side * 6.57, .05, -.605), dryBed, M.Basalt)
		part('RecoveryReturnOuterLip', V(.32, .38, 5.26), V(side * 7.36, .13, -.44), firebrick, M.Brick)
		part('RecoveryReturnInnerLip', V(.32, .38, 3.74), V(side * 5.95, .13, .32), firebrick, M.Brick)
		part('WornRecoveryMouthTile', V(.42, .21, 1.28), V(side * 7.36, .40, 1.53), wornFirebrick, M.Brick)
		part('WornRecoveryMouthTile', V(.42, .21, 1.28), V(side * 5.95, .40, 1.53), wornFirebrick, M.Brick)
	end
	for _, x in ipairs({-2.2, -.15, 2.0}) do
		part('DryCrucibleSweepings', V(1.2, .12, .49), V(x, .21, -2.44), pal.trim:Lerp(wornFirebrick, .37),
			M.Pebble, 'Wedge', V(0, x * .14, 0))
	end
end

local function gateAnchor(pal, part, beam)
	local limestone = pal.rock:Lerp(C(169, 158, 137), .56)
	local iron = C(84, 81, 80)
	for _, x in ipairs({-2.65, 0, 2.65}) do
		part('EmbeddedAnchorAshlar', V(2.56, .66, 4.05), V(x, .19, .12), pal.rock, M.Slate)
		part('WornCopingLip', V(2.55, .25, 2.69), V(x, .61, .47), limestone, M.Cobblestone)
		part('ChamferedCopingApron', V(2.55, .28, 1.1), V(x, .59, -1.40),
			limestone:Lerp(pal.rock, .24), M.Slate, 'Wedge')
	end
	part('WinchBearingSeat', V(2.64, .32, 2.04), V(0, .88, 0), limestone, M.Slate)
	for _, side in ipairs({-1, 1}) do
		part('BearingSeatButtress', V(.75, .50, 1.65), V(side * 1.12, .83, .13), limestone:Lerp(pal.rock, .24),
			M.Slate, 'Wedge', V(0, side * math.pi / 2, 0))
	end
	part('CentralWinchBearing', V(1.04, 1.55, 1.04), V(0, 1.72, 0), iron, M.Metal)
	part('AxleBearingCollar', V(.64, 1.56, 1.56), V(0, 2.43, 0), iron, M.CorrodedMetal,
		'Cylinder', V(0, 0, math.pi / 2))
	for _, x in ipairs({-3.25, 3.25}) do
		part('AnchorBoltHead', V(.37, .18, .37), V(x, .81, -.93), iron, M.Metal)
		beam('AnchorTieStrap', V(x, .74, -.93), V(x * .17, .99, -.39), .24, iron, M.CorrodedMetal)
	end
end

local profiles = {
	['DW-02'] = {goal = 'exp_1', name = 'RecoveryRainShelf', offset = V(0, 0, 11), compose = dryShelf},
	['GW-06'] = {goal = 'exp_2', name = 'RearguardLanternRootBank', offset = V(-1.8, 0, -8.1), compose = rearguardBank},
	['FV-04'] = {goal = 'exp_1', name = 'ArchiveSignalObservationSill', offset = V(10, 0, 0), compose = signalSill},
	['EC-05'] = {goal = 'exp_1', name = 'CrewPlanWorktableFootings', offset = V(0, 0, 6), compose = planFootings},
	['HG-04'] = {goal = 'exp_1', name = 'GateWinchAnchorPlinth', offset = V(-3, 0, -1), compose = gateAnchor, useResult = true},
}

function Assemblies.create(scene, chapter, goal, context)
	local profile = profiles[chapter.id]
	if not profile or goal.id ~= profile.goal or not goal.activity.finish then return end

	local finish = goal.activity.finish
	local target = V(table.unpack(finish.position))
	local anchor = profile.useResult and context.result or target
	local at = anchor + profile.offset
	local y = Bounds.surface(at.X, at.Z)
	if not y or math.abs(y - anchor.Y) > .5 then return end

	-- Attach the main-route rearguard separately from its distant incident wing.
	local parent = finish.rearguard and scene.Parent or scene
	if parent:FindFirstChild(profile.name) then return end

	local origin = V(at.X, y, at.Z)
	local frame = CFrame.new(origin)
	if chapter.id == 'FV-04' then frame = CFrame.lookAt(origin, V(target.X, y, target.Z)) end

	local model = Instance.new('Model')
	model.Name = profile.name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model.WorldPivot = frame

	local function part(name, size, localAt, color, material, shape, angles)
		local cf = frame * CFrame.new(localAt)
		if angles then cf *= CFrame.Angles(angles.X, angles.Y, angles.Z) end
		local p = Kit.part(model, name, size, cf, color, material, shape)
		if shape == 'Cylinder' then p.Shape = Enum.PartType.Cylinder end
	end
	local function beam(name, a, b, width, color, material)
		Kit.beam(model, name, frame:PointToWorldSpace(a), frame:PointToWorldSpace(b), width, color, material)
	end
	profile.compose(context.pal, part, beam)

	-- The work belongs on the flat floor, clear of the incident apron and ramp.
	local box, size = model:GetBoundingBox()
	for _, x in ipairs({-1, 1}) do
		for _, z in ipairs({-1, 1}) do
			local corner = box:PointToWorldSpace(V(x * size.X / 2, 0, z * size.Z / 2))
			local height = Bounds.surface(corner.X, corner.Z)
			if not height or math.abs(height - y) > .12 then model:Destroy(); return end
		end
	end

	model:SetAttribute('SourceKind', 'NewNativeGeometry')
	model:SetAttribute('QuestLandmarkVersion', 3)
	model:SetAttribute('StoryZone', chapter.id)
	model:SetAttribute('StoryGoal', goal.id)
	model:SetAttribute('GroundPosition', origin)
	model:SetAttribute('ApproachPosition', target)
	model:SetAttribute('PartCount', #model:GetChildren())
	model.Parent = parent
	return model
end

return Assemblies
