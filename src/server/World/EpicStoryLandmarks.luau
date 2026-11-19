-- Roadside structures built in studs with a shared ground pivot and a -Z front.
-- Quest actors and progress are owned by the existing activity modules.
local Shared = game.ReplicatedStorage.Shared
local Content = require(Shared.CampaignContent)
local Areas = require(Shared.CampaignAreas)
local Bounds = require(Shared.CampaignBounds)
local Route = require(Shared.CampaignNavigationRoute)
local Kit = require(script.Parent.EpicEnvironmentKit)
local ArchiveAndCanal = require(script.Parent.ArchiveAndCanalLandmarks)
local ForestAndGraveyard = require(script.Parent.ForestAndGraveyardLandmarks)

local RescueRoute = require(script.Parent.RescueRouteLandmarks)

local Landmarks = {version = 1}
local V = Vector3.new
local M = Enum.Material
local profiles = {
	['DW-02'] = {name = 'ConvoyRecoveryShelter', goal = 'survivors'},
	['GW-01'] = {name = 'SplitTrailRootButtress', goal = 'trail'},
	['FV-03'] = {name = 'AvalancheSnowFence', goal = 'west_beacon'},
	['EC-03'] = {name = 'OreSortingBay', goal = 'supports'},
	['HG-03'] = {name = 'KeeperDrainCulvert', goal = 'crypt'},
}
local roadNames = {
	WornCurvedRoute = true,
	JourneyWalkingTrail = true,
	RegionalReturnTrail = true,
	ReturnLoop = true,
	ExpansionWalkingLine = true,
}

local function compose(model, id, profile, palette, builder)
	local function part(name, size, at, color, material, solid, angles, shape)
		local cf = CFrame.new(at)
		if angles then cf = cf * CFrame.Angles(angles.X, angles.Y, angles.Z) end
		local p = Kit.part(model, name, size, cf, color, material, shape)
		p:SetAttribute('EpicDetailSolid', solid == true)
		p:SetAttribute('TLTSceneryDistance', 480)
		return p
	end
	local function beam(name, a, b, width, color, material, solid)
		local p = Kit.beam(model, name, a, b, width, color, material)
		p:SetAttribute('EpicDetailSolid', solid == true)
		p:SetAttribute('TLTSceneryDistance', 480)
	end
	if builder then
		builder(profile, palette, part, beam)
	elseif id == 'DW-02' then
		local linen = Color3.fromRGB(143, 183, 200)
		for _, x in ipairs({-10, 10}) do
			for _, z in ipairs({-5, 5}) do
				local tall = z < 0 and 13 or 10
				part('LodgeFieldBoulder', V(4, 2.2, 4), V(x, .45, z), palette.rock, M.Cobblestone, true)
				beam('ShelterUpright', V(x, 1, z), V(x, tall, z), 1.4, palette.wood, M.Wood, true)
			end
			beam('ShelterSideBrace', V(x, 6.4, 5), V(x, 11.8, -3), .8, palette.wood, M.Wood, true)
		end
		beam('ShelterFrontHeader', V(-11, 13, -5), V(11, 13, -5), 1.3, palette.wood, M.Wood, true)
		beam('ShelterRearHeader', V(-11, 10, 5), V(11, 10, 5), 1.1, palette.wood, M.Wood, true)
		for i = -2, 2 do
			part('StitchedCanopyPanel', V(4.55, .25, 13), V(i * 4.5, 11.75, 0), linen:Lerp(palette.trim, math.abs(i) * .075),
				M.Fabric, false, V(.29, 0, 0))
		end
		part('CanvasStretcher', V(4, .35, 9), V(-2, 1.45, -1), palette.trim, M.Fabric)
		for _, x in ipairs({-4, 0}) do
			beam('StretcherPole', V(x, 1.3, -6.7), V(x, 1.3, 4.7), .38, palette.wood, M.Wood)
		end
		for _, z in ipairs({-4, 2}) do
			part('TrestleCradle', V(4.8, 1.2, .8), V(-2, .6, z), palette.wood, M.Wood)
		end
		part('ShelterRearBench', V(9, 1.7, 2.8), V(3.5, .65, 5.1), palette.wood, M.WoodPlanks, true)
	elseif id == 'GW-01' then
		local root = palette.wood:Lerp(Color3.fromRGB(134, 117, 103), .56)
		local slate = palette.rock:Lerp(palette.trim, .14)
		local seam = slate:Lerp(palette.trim, .35)
		part('RootedShaleShelf', V(16, 4.6, 11), V(-2, 1.25, 1.6), slate, M.Slate, true, V(0, .18, 0), 'Wedge')
		part('RootedShaleShoulder', V(9.2, 4.2, 8), V(6, 1.05, 3.2), slate, M.Slate, true, V(0, -.46, 0), 'Corner')
		part('RootedShaleSpur', V(7, 3.2, 7), V(-8.1, .75, -2), slate, M.Slate, true, V(0, .67, 0), 'Corner')
		part('RootedShaleSeam', V(11, 1.45, 9), V(-1.4, 1.86, 2.8), seam, M.Slate, false, V(0, .17, 0), 'Wedge')
		beam('OldSplitStump', V(-2, 0, 4), V(-3.5, 12, 5.7), 4.6, root, M.Wood, true)
		beam('BrokenStumpSpike', V(-2, 7.5, 5), V(1, 16, 6.5), 2.05, root, M.Wood, true)
		part('SplitBarkShoulder', V(2.25, 9.2, 2), V(-4.6, 8.1, 4.6), root:Lerp(palette.wood, .24),
			M.Wood, true, V(-.06, .35, -.13), 'Wedge')
		part('PaleExposedHeartwood', V(2.15, 7.3, .82), V(-2.5, 9.8, 3), Color3.fromRGB(190, 170, 139),
			M.Wood, false, V(-.14, -.2, -.095), 'Wedge')
		beam('ExposedSplinter', V(-1.36, 10.2, 4.1), V(.55, 15.15, 5.35), .78,
			root:Lerp(Color3.fromRGB(184, 158, 129), .82), M.Wood)
		for _, run in ipairs({
			{V(-8.5, 3.8, 1), V(-12, 1.5, -5), V(-13, -.1, -7)},
			{V(4, 4.2, 2), V(8, 2.8, -2), V(11.5, 0, -6)},
			{V(2, 2.9, 7), V(8.5, 1.4, 7), V(11.5, -.2, 8)},
		}) do
			beam('SweptRootShoulder', V(-2, 5.7, 5), run[1], 2.5, root, M.Wood, true)
			beam('ExposedRootRun', run[1], run[2], 1.5, root:Lerp(palette.wood, .42), M.Wood, true)
			beam('RootTail', run[2], run[3], .85, root, M.Wood)
		end
	elseif id == 'FV-03' then
		local iron = palette.wood:Lerp(palette.rock, .48)
		local weatheredGrain = Color3.fromRGB(126, 109, 94)
		for _, x in ipairs({-12, 0, 12}) do
			part('WindbreakFoot', V(4.5, 2.5, 4.5), V(x, .55, 2.2), palette.rock, M.Glacier, true)
			beam('WindbreakUpright', V(x, .9, 2.2), V(x, 9.8, 3.4), 1.4, palette.wood, M.Wood, true)
			beam('WindbreakSillBrace', V(x, 0, -3.9), V(x, 6.25, 2.8), .92, palette.wood, M.Wood, true)
			part('WindbreakIronCollar', V(1.58, .68, 1.58), V(x, 7.15, 3.04), iron, M.CorrodedMetal)
		end
		for _, x in ipairs({-6, 6}) do
			for i = 1, 4 do
				local h = 1.5 + i * 1.67
				part('WindbreakSlat', V(12, 1.08, .7), V(x, h, 2.2 + h * .12), palette.wood:Lerp(palette.trim, .12 + i * .035),
					M.WoodPlanks, true, V(.11, 0, 0))
			end
			-- Exposed grain on the upper rail stays readable against the bright drift.
			part('WindbreakWeatheredRailFace', V(11.5, .56, .1), V(x, 8.23, 2.81),
				weatheredGrain, M.WoodPlanks, false, V(.11, 0, 0))
		end
		part('WindPackedSnow', V(12.6, 3.7, 10), V(-5.7, 1.02, 3), palette.ground, M.Snow, true,
			V(0, math.pi + .08, 0), 'Wedge')
		part('BrokenDriftEdge', V(12.2, 2.75, 7.8), V(5.2, .68, 3.2), palette.ground, M.Snow, true,
			V(0, math.pi - .17, .06), 'Corner')
		part('ExposedIceLip', V(14.5, 1.3, 5), V(-4, .25, -1.6), palette.trim, M.Glacier, false, V(0, -.18, 0), 'Wedge')
		part('FenceSnowCrust', V(12, .4, 1.1), V(-6, 8.83, 3.15), palette.ground, M.Snow)
		part('FenceSnowCrust', V(8.2, .36, 1.1), V(5, 8.8, 3.15), palette.ground, M.Snow)
	elseif id == 'EC-03' then
		local timber = palette.wood:Lerp(Color3.fromRGB(132, 94, 66), .45)
		local ore = palette.rock:Lerp(Color3.fromRGB(125, 96, 75), .37)
		for _, x in ipairs({-8, 8}) do
			part('SorterFoot', V(5, 2, 7), V(x, .45, 2), palette.rock, M.Basalt, true)
			beam('SorterTrestle', V(x, 1, 2), V(x, 7.1, 4.6), 1.9, timber, M.Wood, true)
			beam('SorterDiagonal', V(x, .65, -4), V(x, 5.8, 4), 1.15, timber, M.Wood, true)
		end
		for _, x in ipairs({-6, 6}) do
			beam('SortingChuteRim', V(x, 2.2, -4.8), V(x, 8.8, 6.6), 1.1, timber, M.Wood, true)
			beam('SortingChuteIron', V(x, 2.85, -4.8), V(x, 9.45, 6.6), .37, palette.trim, M.CorrodedMetal)
		end
		part('InclinedOreGrateBed', V(11.8, .8, 13.2), V(0, 5.36, .9), ore:Lerp(palette.wood, .35),
			M.WoodPlanks, true, V(-.525, 0, 0))
		for i = 0, 6 do
			part('GrateCrossbar', V(11.5, .55, .42), V(0, 3.16 + i, -4.3 + i * 1.72),
				palette.trim:Lerp(Color3.fromRGB(152, 143, 119), .68), M.Metal)
		end
		for i, x in ipairs({-3.5, -1.5, 1, 4}) do
			part('DiscardedOre', V(2.6, 1.8 + i * .11, 3.3), V(x, .62, -6.8 + (i % 2)), ore:Lerp(palette.trim, i / 15),
				M.Rock, false, V(0, i * .62, 0), 'Corner')
		end
	else
		local moss = palette.rock:Lerp(palette.ground, .55)
		local cutStone = palette.trim:Lerp(Color3.fromRGB(174, 177, 154), .4)
		local wetStone = Color3.fromRGB(49, 56, 62)
		part('CulvertFootCourse', V(21, 2.2, 10), V(0, .45, 2), palette.rock, M.Cobblestone, true)
		part('CulvertClosedBack', V(15, 6.3, 2), V(0, 3.25, 5.8), palette.rock, M.Slate, true)
		-- The downstream face shows a narrow service drain within the closed masonry.
		part('CulvertRearWeepSlot', V(6.4, .84, .08), V(0, 1.92, 6.86), wetStone, M.Slate)
		part('CulvertRearDripStone', V(8.4, .46, .52), V(0, 2.63, 6.72), cutStone, M.Slate)
		part('CulvertRearSill', V(8.8, .34, .92), V(0, 1.32, 6.69), cutStone, M.Cobblestone)
		for _, x in ipairs({-4.18, 4.18}) do
			part('CulvertRearQuoin', V(.85, 1.55, .36), V(x, 1.99, 6.79), moss, M.Cobblestone)
			part('CulvertSillReturn', V(1.05, .38, 1.65), V(x, 1.33, 6.08), cutStone, M.Slate,
				false, V(0, 0, 0), 'Wedge')
		end
		part('CulvertRunoff', V(6.2, .25, 6), V(0, .04, -3), moss, M.Mud)
		part('CulvertRunoffInvert', V(3.8, .18, 5.8), V(0, .21, -3.02), palette.wood, M.Slate)
		for _, x in ipairs({-1, 1}) do
			part('CulvertWingWall', V(2.5, 2.6, 4.45), V(x * 5.25, 1.05, -3.12), cutStone, M.Slate,
				false, V(0, -x * .34, 0), 'Wedge')
			part('CulvertAshlarPier', V(5.1, 6.1, 8), V(x * 6, 3, 2), palette.rock, M.Cobblestone, true)
			part('CulvertSpringCourse', V(5.1, 1.4, 9), V(x * 5.6, 6, 2), cutStone, M.Slate, true)
			beam('CulvertVaultStone', V(x * 5.3, 6.5, -1.3), V(x * 2, 8.2, -1.3), 2.35, cutStone, M.Slate, true)
			part('CulvertMossCapping', V(7, .35, 6.4), V(x * 6, 6.9, 2), moss, M.Ground)
		end
		part('CulvertVaultCap', V(5.5, 2.35, 8.6), V(0, 8.25, 2.2), palette.rock, M.Slate, true)
		for _, x in ipairs({-2.15, 0, 2.15}) do
			part('FixedDrainGrille', V(.44, 6.5, .58), V(x, 3.6, -.85), palette.wood, M.CorrodedMetal, true)
		end
		part('DrainGrilleCrossbar', V(7.3, .42, .6), V(0, 2.6, -.95), palette.wood, M.CorrodedMetal, true)
	end
end

local function vec(at)
	return V(at[1], at[2], at[3])
end

local function lanesFor(id, spawn)
	local lanes = {}
	for _, chapter in ipairs(Content.chapters) do
		if chapter.zone ~= id then continue end
		for _, variant in ipairs({'worldPoints', 'points'}) do
			local previous = {spawn.X, spawn.Y, spawn.Z}
			for _, goal in ipairs(chapter.goals) do
				local combat = chapter.combatRoutes and chapter.combatRoutes[goal.id]
				local targets = combat and (combat[variant] or combat.points)
				if not targets or #targets == 0 then
					targets = {}
					for _, step in ipairs(goal.activity and goal.activity.steps or {goal}) do
						if step.position then table.insert(targets, step.position) end
					end
				end
				for _, at in ipairs(targets) do
					local route = Route.route(previous, at)
					for i = 2, #route do
						table.insert(lanes, {vec(route[i - 1]), vec(route[i])})
					end
					previous = at
				end
			end
		end
	end
	return lanes
end

local function distance(point, a, b)
	local line = V(b.X - a.X, 0, b.Z - a.Z)
	local offset = V(point.X - a.X, 0, point.Z - a.Z)
	local t = math.clamp(offset:Dot(line) / math.max(.001, line:Dot(line)), 0, 1)
	return (offset - line * t).Magnitude
end

local function approachFor(id, goalId, world)
	local spawn = world.spawns[id].Position
	for _, goal in ipairs(Content.byId[id].goals) do
		if goal.id == goalId then return vec(goal.position) end
	end
	return spawn
end

local function offsets(decorative)
	local result = {}
	local first, last, stride, slots = 68, 212, 18, 16
	if decorative then first, last, stride, slots = 26, 152, 6, 32 end
	for radius = first, last, stride do
		for i = 0, slots - 1 do
			local yaw = (i + radius / 36) * 2 * math.pi / slots
			table.insert(result, V(math.cos(yaw) * radius, 0, math.sin(yaw) * radius))
		end
	end
	return result
end

local function buildModel(site, id, center, size, palette, safe, ground, world, profile, builder)
	local existing = site:FindFirstChild(profile.name)
	if existing then return existing end

	local model = Instance.new('Model')
	model.Name = profile.name
	model.WorldPivot = CFrame.identity
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	compose(model, id, profile, palette, builder)
	local bounds, span = model:GetBoundingBox()
	local radius = V(span.X / 2 + math.abs(bounds.X), 0, span.Z / 2 + math.abs(bounds.Z)).Magnitude
	local decorativeOnly = builder ~= nil
	local pad = radius + (decorativeOnly and 2 or 5)
	local spawn = world.spawns[id].Position
	local approach = approachFor(id, profile.goal, world)
	local lanes = lanesFor(id, spawn)

	local roads = {}
	for _, p in ipairs(world.folder:GetDescendants()) do
		if p:IsA('BasePart') and roadNames[p.Name] and p.Transparency < .5
			and math.abs(p.Position.Y - center.Y) < 24
			and distance(center, p.Position, p.Position) < math.max(size[1], size[2]) + p.Size.Z / 2 then
			table.insert(roads, p)
		end
	end

	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances = {world.folder}
	local decorative = {}
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA('BasePart') and not p.CanQuery and p.Transparency < .7 and p.Size.Y > 2 then
			table.insert(decorative, p)
		end
	end

	local function eligible(at)
		if math.abs(at.X - center.X) > size[1] / 2 - pad or math.abs(at.Z - center.Z) > size[2] / 2 - pad
			or Bounds.region(at.X, at.Z, pad, id) or Bounds.connection(at.X, at.Z, pad) then return nil end
		-- Low visual-only works can sit closer to a route than solid structures.
		if decorativeOnly then
			if distance(at, spawn, spawn) < pad + 24 then return nil end
		elseif not safe(at, pad) then
			return nil
		end
		for _, area in ipairs(Content.zones[id].expansionAreas or {}) do
			if Areas.contains(area, at.X, at.Z, pad + 8) or Areas.contains(area.connector, at.X, at.Z, pad + 8) then return nil end
		end
		for _, lane in ipairs(lanes) do
			if distance(at, lane[1], lane[2]) < pad + (decorativeOnly and 8 or 16) then return nil end
		end
		for _, road in ipairs(roads) do
			local rel = road.CFrame:PointToObjectSpace(at)
			if math.abs(rel.X) < road.Size.X / 2 + pad and math.abs(rel.Z) < road.Size.Z / 2 + pad then return nil end
		end
		local base, supported = ground(at)
		if not supported or math.abs(base.Y - center.Y) > 5 then return nil end

		local front = V(approach.X, base.Y, approach.Z)
		local pivot = CFrame.lookAt(base, front)
		for _, x in ipairs({-.42, .42}) do
			for _, z in ipairs({-.42, .42}) do
				local foot = pivot:PointToWorldSpace(V(bounds.X + x * span.X, 0, bounds.Z + z * span.Z))
				local sample, valid = ground(foot)
				if not valid or math.abs(sample.Y - base.Y) > .6 then return nil end
			end
		end
		local test = pivot * CFrame.new(bounds.X, (bounds.Y + span.Y / 2 + 2) / 2, bounds.Z)
		if #workspace:GetPartBoundsInBox(test, V(span.X + 8, bounds.Y + span.Y / 2 - 2, span.Z + 8), overlap) > 0 then
			return nil
		end
		-- Non-queryable scene dressing also needs an unobstructed silhouette.
		for _, p in ipairs(decorative) do
			local rel = test:ToObjectSpace(p.CFrame)
			local width = V(p.Size.X, 0, p.Size.Z).Magnitude / 2
			local halfX, halfY, halfZ = width, p.Size.Y / 2, width
			if decorativeOnly then
				local s = p.Size / 2
				local right, up, back = rel.RightVector, rel.UpVector, rel.ZVector
				halfX = math.abs(right.X) * s.X + math.abs(up.X) * s.Y + math.abs(back.X) * s.Z
				halfY = math.abs(right.Y) * s.X + math.abs(up.Y) * s.Y + math.abs(back.Y) * s.Z
				halfZ = math.abs(right.Z) * s.X + math.abs(up.Z) * s.Y + math.abs(back.Z) * s.Z
			end
			if math.abs(rel.X) < span.X / 2 + halfX + 2 and math.abs(rel.Z) < span.Z / 2 + halfZ + 2
				and math.abs(rel.Y) < span.Y / 2 + halfY then return nil end
		end
		return pivot
	end

	for _, offset in ipairs(offsets(decorativeOnly)) do
		local pivot = eligible(V(approach.X, center.Y, approach.Z) + offset)
		if not pivot then continue end
		model:PivotTo(pivot)
		model:SetAttribute('LandmarkVersion', builder and 2 or Landmarks.version)
		model:SetAttribute('SourceKind', 'NewNativeGeometry')
		model:SetAttribute('StoryZone', id)
		model:SetAttribute('StoryGoal', profile.goal)
		model:SetAttribute('GroundPosition', pivot.Position)
		model:SetAttribute('ApproachPosition', approach)
		model:SetAttribute('PlacementRadius', radius)
		model:SetAttribute('PartCount', #model:GetChildren())
		model.Parent = site
		return model
	end

	model:Destroy()
	return nil
end

function Landmarks.build(site, id, center, size, palette, safe, ground, world)
	local original = profiles[id]
	if original then
		return buildModel(site, id, center, size, palette, safe, ground, world, original)
	end

	local models = ForestAndGraveyard.profiles[id] and ForestAndGraveyard or RescueRoute
	local profile = models.profiles[id]
	if profile then
		return buildModel(site, id, center, size, palette, safe, ground, world, profile,
			function(_, colors, part, beam)
				models.compose(id, colors, part, beam)
			end)
	end

	for _, profile in ipairs(ArchiveAndCanal.profiles[id] or {}) do
		buildModel(site, id, center, size, palette, safe, ground, world, profile, ArchiveAndCanal.compose)
	end
end

return Landmarks
