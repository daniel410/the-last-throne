-- Event-driven enemy health display, following TD's green/yellow/red thresholds.
-- The server's Humanoid remains the only health authority.
local EnemyHealthBar = {}
local Text = require(game:GetService("ReplicatedStorage").Shared.K0Text)

local function healthColor(ratio)
	if ratio <= 0.25 then return Color3.fromRGB(230, 80, 80) end
	if ratio <= 0.5 then return Color3.fromRGB(230, 200, 70) end
	return Color3.fromRGB(90, 220, 90)
end

function EnemyHealthBar.attach(model, humanoid)
	local root = assert(model:FindFirstChild("HumanoidRootPart"), "Enemy health bar needs a root")
	assert(root:IsA("BasePart") and humanoid:IsA("Humanoid"), "Enemy health bar needs a Humanoid and root part")
	local old = model:FindFirstChild("EnemyHealthBar")
	if old then old:Destroy() end
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local gui = Instance.new("BillboardGui")
	gui.Name = "EnemyHealthBar"
	gui.Adornee = root
	gui.Size = UDim2.fromOffset(96, 30)
	local height = model:GetAttribute("TdMonsterTargetHeight") or 4
	local footOffset = root.Size.Y * 1.5
	gui.StudsOffsetWorldSpace = Vector3.new(0, height - footOffset + 1.45, 0)
	gui.MaxDistance = 100
	gui.AlwaysOnTop = false
	gui.Parent = model
	local name = Instance.new("TextLabel")
	name.Name, name.Text = "EnemyName", humanoid.DisplayName
	name.BackgroundTransparency, name.Size = 1, UDim2.new(1, 0, 0, 13)
	name.Font, name.TextSize = Enum.Font.GothamBold, 10
	name.TextColor3, name.TextStrokeTransparency = Color3.fromRGB(255, 246, 220), 0.2
	name.AutoLocalize = false
	name.Parent = gui
	local badge = Instance.new("TextLabel")
	badge.Name, badge.Text = "BossBadge", Text.EnemyBossBadge
	badge.AnchorPoint, badge.Position = Vector2.new(0.5, 0), UDim2.fromScale(0.5, 0)
	badge.Size = UDim2.fromOffset(76, 18)
	badge.BackgroundColor3, badge.BorderSizePixel = Color3.fromRGB(75, 22, 25), 0
	badge.Font, badge.TextSize = Enum.Font.GothamBold, 12
	badge.TextColor3 = Color3.fromRGB(255, 218, 127)
	badge.AutoLocalize = false
	badge.Parent = gui
	local border = Instance.new("UIStroke")
	border.Color, border.Thickness, border.ApplyStrokeMode = Color3.fromRGB(222, 178, 84), 1, Enum.ApplyStrokeMode.Border
	border.Parent = badge
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, 4), badge
	local bg = Instance.new("Frame")
	bg.Name, bg.Position, bg.Size = "HpBg", UDim2.fromOffset(0, 15), UDim2.new(1, 0, 0, 14)
	bg.BackgroundColor3, bg.BackgroundTransparency, bg.BorderSizePixel = Color3.fromRGB(15, 15, 15), 0.25, 0
	bg.Parent = gui
	local fill = Instance.new("Frame")
	fill.Name, fill.BorderSizePixel, fill.Size = "HpFill", 0, UDim2.fromScale(1, 1)
	fill.Parent = bg
	local value = Instance.new("TextLabel")
	value.Name, value.BackgroundTransparency, value.Size = "HpValue", 1, UDim2.fromScale(1, 1)
	value.Font, value.TextSize = Enum.Font.GothamBold, 10
	value.TextColor3, value.TextStrokeTransparency = Color3.new(1, 1, 1), 0.25
	value.AutoLocalize = false
	value.ZIndex = 2
	value.Parent = bg
	local function refreshRank()
		local boss = model:GetAttribute("StoryBoss") == true
		badge.Visible = boss
		gui.Size = UDim2.fromOffset(boss and 144 or 96, boss and 56 or 30)
		gui.StudsOffsetWorldSpace = Vector3.new(0, height - footOffset + 1.45 + (boss and 0.9 or 0), 0)
		name.Position = UDim2.fromOffset(0, boss and 22 or 0)
		name.Size = UDim2.new(1, 0, 0, boss and 17 or 13)
		name.TextSize = boss and 12 or 10
		bg.Position = UDim2.fromOffset(0, boss and 41 or 15)
	end
	local function refresh()
		local maximum = math.max(0, humanoid.MaxHealth)
		local current = math.clamp(humanoid.Health, 0, maximum)
		local ratio = maximum > 0 and current / maximum or 0
		gui.Enabled = current > 0
		fill.Size = UDim2.fromScale(ratio, 1)
		fill.BackgroundColor3 = healthColor(ratio)
		value.Text = string.format("%d / %d", math.ceil(current), math.ceil(maximum))
	end
	humanoid.HealthChanged:Connect(refresh)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refresh)
	model:GetAttributeChangedSignal("StoryBoss"):Connect(refreshRank)
	humanoid:GetPropertyChangedSignal("DisplayName"):Connect(function() name.Text = humanoid.DisplayName end)
	refreshRank()
	refresh()
	return gui
end

return EnemyHealthBar
