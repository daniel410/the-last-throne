-- Keep the nearby silhouettes readable beneath Gloamwood's canopy.
local EnemyOutline = {}
local MAX_DISTANCE = 48
local MAX_OUTLINES = 10

function EnemyOutline.clear(outlines)
	for model, outline in pairs(outlines) do
		outline:Destroy()
		outlines[model] = nil
	end
end

function EnemyOutline.update(outlines, models, origin)
	if not origin then
		EnemyOutline.clear(outlines)
		return
	end

	local nearby = {}
	for _, model in ipairs(models) do
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			local distance = (root.Position - origin).Magnitude
			if distance <= MAX_DISTANCE then
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
		if not outlines[model] then
			local outline = Instance.new("Highlight")
			outline.Name = "GloamwoodEnemyOutline"
			outline.Adornee = model
			outline.DepthMode = Enum.HighlightDepthMode.Occluded
			outline.FillTransparency = 1
			outline.OutlineColor = Color3.fromRGB(191, 205, 219)
			outline.OutlineTransparency = 0.46
			outline.Parent = model
			outlines[model] = outline
		end
	end
end

return EnemyOutline
