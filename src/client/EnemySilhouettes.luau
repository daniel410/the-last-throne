-- Nearby enemies get a depth-tested edge. Confirmed combat feedback has priority.
local Patterns = require(game.ReplicatedStorage.Shared.EnemyPatterns)
local EnemyOutline = {}
local MAX_OUTLINES = 10
local regions = {
	Deepwood = {distance = 38, alpha = .74},
	Gloamwood = {distance = 48, alpha = .50},
	FrozenVale = {distance = 38, alpha = .68},
	EmberCaldera = {distance = 40, alpha = .66},
	HauntedGraveyard = {distance = 48, alpha = .52},
}
local edgeColors = {
	physical = Color3.fromRGB(244,198,163), venom = Color3.fromRGB(211,234,115),
	web = Color3.fromRGB(222,193,242), arcane = Color3.fromRGB(218,167,255),
	frost = Color3.fromRGB(143,226,255), fire = Color3.fromRGB(255,176,108),
	soul = Color3.fromRGB(136,239,209), shadow = Color3.fromRGB(211,163,249),
}

function EnemyOutline.clear(outlines)
	for model, outline in pairs(outlines) do
		outline:Destroy()
		outlines[model] = nil
	end
end

function EnemyOutline.update(outlines, models, origin, region)
	local style = regions[region]
	if not origin or not style then
		EnemyOutline.clear(outlines)
		return
	end

	local nearby = {}
	for _, model in ipairs(models) do
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			local distance = (root.Position - origin).Magnitude
			if distance <= style.distance then
				local humanoid = model:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0
					and not model:FindFirstChild("K0TargetHighlight")
					and not model:FindFirstChild("ProvokeEffect")
					and not model:FindFirstChild("GravityEffect") then
					table.insert(nearby, {model = model, distance = distance})
				end
			end
		end
	end
	table.sort(nearby, function(a, b)
		return a.distance < b.distance
	end)

	local visible = {}
	for index = 1, math.min(#nearby, MAX_OUTLINES) do
		visible[nearby[index].model] = true
	end
	for model, outline in pairs(outlines) do
		if not visible[model] or outline.Parent ~= model then
			outline:Destroy()
			outlines[model] = nil
		end
	end
	for model in pairs(visible) do
		local outline = outlines[model]
		if not outline then
			outline = Instance.new("Highlight")
			outline.Name = "EnemySilhouette"
			outline.Adornee = model
			outline.DepthMode = Enum.HighlightDepthMode.Occluded
			outline.FillTransparency = 1
			outlines[model] = outline
		end
		local profile = Patterns.get(model:GetAttribute("EnemyKind"))
		outline.OutlineColor = profile and edgeColors[profile.element] or edgeColors.physical
		outline.OutlineTransparency = model:GetAttribute("StoryBoss") == true and math.max(.42,style.alpha-.14) or style.alpha
		if outline.Parent ~= model then outline.Parent = model end
	end
end

return EnemyOutline
