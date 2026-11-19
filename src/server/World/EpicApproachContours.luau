-- Low relief beyond the approach lane silhouettes the existing story stations.
-- Native geometry shares neither collision nor progression with the stations.
local Kit = require(script.Parent.EpicEnvironmentKit)
local Contours = {}

local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function wedge(model, name, frame, x, z, width, height, depth, yaw, color, material)
	local at = frame * CFrame.new(x, height / 2 - .32, z) * CFrame.Angles(0, math.rad(yaw), 0)
	return Kit.part(model, name, V(width, height, depth), at, color, material, 'Wedge')
end

local function block(model, name, frame, x, y, z, width, height, depth, yaw, color, material)
	local at = frame * CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(yaw), 0)
	return Kit.part(model, name, V(width, height, depth), at, color, material)
end

local function marsh(model, frame)
	local silt = C(86, 72, 57)
	wedge(model, 'FloodCutSilt', frame, -3.9, -.35, 13.6, 1.42, 8.1, -13, silt, M.Mud)
	wedge(model, 'FloodCutSlump', frame, 3.9, .6, 11.8, 1.19, 7.2, 18, C(118, 100, 76), M.Ground)
	wedge(model, 'MarshTurfLedge', frame, -4.25, 1.65, 11.3, 1.94, 6.3, -10, C(113, 126, 77), M.Grass)
	wedge(model, 'RunoffGravel', frame, 7.4, -1.25, 8.4, .56, 4.6, 28, C(123, 115, 94), M.Pebble)
end

local function rootSection(model, name, a, b, diameter, color)
	local axis = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0)
	local section = Kit.part(model, name, V((b - a).Magnitude + .35, diameter, diameter), axis, color, M.Wood)
	section.Shape = Enum.PartType.Cylinder
end

local function roots(model, frame)
	wedge(model, 'RootBankSoil', frame, -1.8, 1.5, 16, 2.75, 7.8, -16, C(63, 59, 53), M.Ground)
	local bark = C(122, 94, 71)
	local exposedBark = C(164, 128, 94)
	for _, root in ipairs({
		{V(-8.4, .12, -1), V(-3.55, 2.32, .95), V(6.8, .28, 4.2), 2.5, 1.48, exposedBark},
		{V(-7.2, .24, 3.2), V(-2.65, 1.8, 2.15), V(9.4, .27, -1.2), 1.69, 1.1, bark},
		{V(-1.45, .13, -3.4), V(2.15, 1.57, .2), V(7.5, .18, 3.3), 1.22, .8, bark:Lerp(exposedBark, .52)},
	}) do
		local a, b, c, broad, narrow, tint = table.unpack(root)
		rootSection(model, 'RefugeRootFlare', frame * a, frame * b, broad, tint)
		rootSection(model, 'RefugeRootTaper', frame * b, frame * c, narrow, tint:Lerp(C(66, 54, 52), .23))
	end
end

local function basalt(model, frame)
	local layers = {
		{-7.2, -.3, 9.5, 2.75, 6.3, -21, C(78, 69, 74)},
		{-1.1, 1.25, 8.4, 4.15, 8.45, -10, C(91, 78, 79)},
		{5.35, 1.2, 7.15, 3.65, 7.5, 6, C(75, 65, 72)},
		{9.85, .45, 5.1, 2.15, 5.75, 23, C(87, 75, 73)},
	}
	for _, row in ipairs(layers) do
		local x, z, width, height, depth, yaw, tint = table.unpack(row)
		wedge(model, 'HeatworksBasaltCut', frame, x, z, width, height, depth, yaw, tint, M.Basalt)
		-- Lower, warmer shoulders trace the strata below the pressure gauge.
		wedge(model, 'HeatworksBasaltFracture', frame, x + .38, z - 1.3, width * .92, height * .73, depth * .83, yaw + 4,
			tint:Lerp(C(139, 113, 100), .46), M.Slate)
	end
end

local function masonry(model, frame)
	local wetStone = C(89, 94, 93)
	local dryStone = C(155, 151, 143)
	wedge(model, 'CulvertTalus', frame, 1.2, 1, 15, 1.35, 6.2, -14, C(75, 80, 74), M.Rock)
	block(model, 'RetainingStoneLower', frame, -4.35, .54, .02, 8.25, 1.76, 4.4, -9, wetStone, M.Cobblestone)
	block(model, 'RetainingStoneLower', frame, 3.37, .35, .8, 6.6, 1.38, 3.9, -1, wetStone, M.Cobblestone)
	block(model, 'RetainingStoneUpper', frame, -4.55, 1.76, -.08, 7.5, .87, 3.72, -9, dryStone, M.Slate)
	wedge(model, 'SpalledCoping', frame, .52, .62, 5.9, 2.05, 3.75, -11, C(137, 134, 130), M.Slate)
	wedge(model, 'WaterlineRubble', frame, 6.25, .46, 4.55, .85, 4.1, 32, C(77, 83, 80), M.Cobblestone)
end

local incidentContours = {
	['DW-Q1:exp_1'] = {'MarshFloodcut', 2, 1, 6.5, 10, marsh},
	['GW-03:exp_1'] = {'RefugeRootShelf', 2, 1, 6, 10, roots},
	['EC-06:exp_2'] = {'HeatworksBasaltCutbank', 2, 1, 7, 12, basalt},
	['HG-03:exp_2'] = {'FortressDrainRetainingRuin', 1, 2, 17, 11, masonry},
}

local function create(parent, name, frame, story, goal, compose)
	local model = Instance.new('Model')
	model.Name = name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model.WorldPivot = frame
	model:SetAttribute('SourceKind', 'NewNativeGeometry')
	model:SetAttribute('ApproachContourVersion', 2)
	model:SetAttribute('StoryZone', story)
	model:SetAttribute('StoryGoal', goal)
	model:SetAttribute('GroundPosition', frame.Position)
	compose(model, frame)
	model:SetAttribute('PartCount', #model:GetChildren())
	model.Parent = parent
end

function Contours.buildIncident(scene, chapter, goal, area)
	local profile = incidentContours[chapter.id .. ':' .. goal.id]
	if not profile then return end

	local name, target, preceding, lateral, setback, compose = table.unpack(profile)
	local origin = V(table.unpack(goal.activity.steps[target].position))
	local previous = V(table.unpack(goal.activity.steps[preceding].position))
	local approach = V(previous.X - origin.X, 0, previous.Z - origin.Z).Unit
	local facing = CFrame.lookAlong(origin, approach)
	local pos = facing * V(lateral, 0, setback)
	-- Keep the authored toes on the flat wing. The inset includes the
	-- widest contour, while the route itself remains on the open side.
	local cx, cy, cz = table.unpack(area.center)
	local inset = 12
	pos = V(
		math.clamp(pos.X, cx - area.size[1] / 2 + inset, cx + area.size[1] / 2 - inset),
		cy,
		math.clamp(pos.Z, cz - area.size[2] / 2 + inset, cz + area.size[2] / 2 - inset)
	)
	create(scene, name, CFrame.lookAlong(pos, approach), chapter.id, goal.id, compose)
end

function Contours.buildRavine(site, landmark, ground)
	if not landmark then return end

	local objective = landmark:GetAttribute('ApproachPosition')
	local towardFence = landmark:GetPivot().Position - objective
	local direction = V(towardFence.X, 0, towardFence.Z).Unit
	local at, supported = ground(CFrame.lookAlong(objective, direction) * V(6, 0, -44))
	if not supported or math.abs(at.Y - objective.Y) > 3 then return end

	create(site, 'AvalancheBendWindcut', CFrame.lookAlong(at, direction), 'FV-03', 'west_beacon', function(model, frame)
		local shale = C(89, 110, 130)
		local ice = C(125, 172, 193)
		local snow = C(214, 229, 236)
		-- The low toe faces the sign; the cornice gathers on the fence side.
		wedge(model, 'WindcutShaleShoulder', frame, -4, .4, 17.2, 3.05, 10.6, 157, shale, M.Slate)
		wedge(model, 'WindcutIceFace', frame, -6.2, 0, 11.2, 3.98, 9.8, 161, ice, M.Glacier)
		wedge(model, 'WindcutSnowCornice', frame, -7.8, .35, 9.4, 4.4, 8.6, 153, snow, M.Snow)
		wedge(model, 'WindcutShaleScree', frame, 4.75, 1.4, 11.2, 1.52, 7.8, 198, shale, M.Slate)
		wedge(model, 'WindcutSnowTail', frame, 6.8, 1, 8.4, 1.32, 6.1, 192, snow, M.Snow)
	end)
end

return Contours
