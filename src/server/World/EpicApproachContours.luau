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
	local silt = C(105, 88, 66)
	wedge(model, 'FloodCutSilt', frame, -3.7, .2, 13.8, 1.85, 8.5, -7, silt, M.Mud)
	wedge(model, 'FloodCutSlump', frame, 4.35, 1.2, 12, 1.28, 8.15, 12, C(112, 98, 72), M.Ground)
	wedge(model, 'MarshTurfLedge', frame, -4, 1.35, 12.6, 2.06, 6.35, -6, C(98, 108, 65), M.Grass)
	wedge(model, 'RunoffGravel', frame, 7.55, -.8, 8.5, .68, 4.9, 19, C(116, 108, 87), M.Pebble)
end

local function rootSection(model, name, a, b, diameter, color)
	local axis = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.pi / 2, 0)
	local section = Kit.part(model, name, V((b - a).Magnitude + .35, diameter, diameter), axis, color, M.Wood)
	section.Shape = Enum.PartType.Cylinder
end

local function roots(model, frame)
	wedge(model, 'RootBankSoil', frame, -2, 1.2, 16, 3.3, 8.1, -16, C(64, 61, 56), M.Ground)
	local bark = C(111, 88, 67)
	for _, root in ipairs({
		{V(-8.4, .12, -2), V(-3.4, 2.9, 1.9), V(6.8, .58, 4.2), 2.7, 1.45},
		{V(-7.2, .24, 3.2), V(-2.7, 1.99, 2), V(9.5, .29, -.8), 1.75, 1.14},
		{V(-1.4, .15, -3.4), V(2, 1.82, .7), V(7.3, .19, 3.7), 1.24, .82},
	}) do
		local a, b, c, broad, narrow = table.unpack(root)
		rootSection(model, 'RefugeRootFlare', frame * a, frame * b, broad, bark)
		rootSection(model, 'RefugeRootTaper', frame * b, frame * c, narrow, bark:Lerp(C(55, 50, 55), .3))
	end
end

local function basalt(model, frame)
	local layers = {
		{-7.2, -.6, 9.7, 4.1, 6.5, -12, C(73, 66, 75)},
		{-.8, .55, 7.5, 5.55, 8.5, -6, C(87, 75, 77)},
		{5.4, .85, 6.2, 4.4, 7.2, 2, C(69, 61, 69)},
		{10, 1.5, 5.2, 2.75, 5.75, 16, C(82, 72, 73)},
	}
	for _, row in ipairs(layers) do
		local x, z, width, height, depth, yaw, tint = table.unpack(row)
		block(model, 'HeatworksBasaltCut', frame, x, height / 2 - .33, z, width, height, depth, yaw, tint, M.Basalt)
		wedge(model, 'HeatworksBasaltFracture', frame, x, z - .45, width * .94, height + .48, depth * .9, yaw,
			tint:Lerp(C(121, 105, 93), .35), M.Slate)
	end
end

local function masonry(model, frame)
	local stone = C(112, 107, 104)
	wedge(model, 'CulvertTalus', frame, 1, .7, 15.5, 1.8, 6.6, -14, C(76, 79, 70), M.Rock)
	block(model, 'RetainingStoneLower', frame, -4, .48, 0, 7.8, 1.65, 4.3, -7, stone, M.Cobblestone)
	block(model, 'RetainingStoneLower', frame, 3.3, .39, .66, 6.5, 1.45, 4, -4, stone:Lerp(C(86, 90, 80), .45), M.Cobblestone)
	block(model, 'RetainingStoneUpper', frame, -3.6, 1.7, .14, 7.2, 1.02, 3.45, -6, stone, M.Slate)
	wedge(model, 'SpalledCoping', frame, .55, .72, 6.4, 2.1, 3.1, -10, C(124, 116, 102), M.Slate)
	wedge(model, 'WaterlineRubble', frame, 6.1, 1.14, 4.95, .95, 4.4, 28, C(73, 77, 70), M.Cobblestone)
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
	model:SetAttribute('ApproachContourVersion', 1)
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
	local at, supported = ground(CFrame.lookAlong(objective, direction) * V(32, 0, -31))
	if not supported or math.abs(at.Y - objective.Y) > 3 then return end

	create(site, 'AvalancheBendWindcut', CFrame.lookAlong(at, direction), 'FV-03', 'west_beacon', function(model, frame)
		local dark = C(87, 108, 130)
		local ice = C(135, 184, 205)
		local snow = C(216, 230, 235)
		wedge(model, 'WindcutShaleShoulder', frame, 0, 0, 26, 5.5, 13, 6, dark, M.Slate)
		wedge(model, 'WindcutIceFace', frame, -4, -1.1, 15.3, 6.35, 11.1, 1, ice, M.Glacier)
		wedge(model, 'WindcutSnowCornice', frame, -4.5, -1.7, 14.1, 6.88, 9.5, -3, snow, M.Snow)
		wedge(model, 'WindcutShaleScree', frame, 10.3, 1.7, 12.7, 2.58, 9.6, 21, dark, M.Slate)
		wedge(model, 'WindcutSnowTail', frame, 12.2, 1, 10.5, 2.8, 8.1, 12, snow, M.Snow)
	end)
end

return Contours
