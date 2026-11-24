-- NPC visibility owns the entire billboard, including the role accent.
local Nameplate = {}

function Nameplate.create(root, description, height)
	local accent = Color3.fromHex(description.accent)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NPCLabel"
	gui.Size = UDim2.fromOffset(220, 44)
	gui.StudsOffset = Vector3.new(0, height, 0)
	gui.MaxDistance = 55
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0

	local label = Instance.new("TextLabel")
	label.AnchorPoint, label.Position = Vector2.new(.5,.5), UDim2.fromScale(.5,.5)
	label.Size = UDim2.new(1, -12, 0, 26)
	label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(14,24,38), .16
	label.Text = description.name.." · "..description.role
	label.TextColor3, label.Font = Color3.fromRGB(255,247,221), Enum.Font.GothamBold
	label.TextScaled, label.AutoLocalize = true, false
	label.ZIndex = 2
	label.Parent = gui
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize, limit.MaxTextSize, limit.Parent = 10, 13, label
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft, padding.PaddingRight = UDim.new(0,12), UDim.new(0,8)
	padding.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0,5), label
	local edge = Instance.new("UIStroke")
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color, edge.Transparency, edge.Parent = accent, .36, label
	local tab = Instance.new("Frame")
	tab.Name = "RegionAccent"
	tab.AnchorPoint, tab.Position = Vector2.new(0,.5), UDim2.new(0,2,.5,0)
	tab.Size, tab.Rotation = UDim2.fromOffset(5,5), 45
	tab.BackgroundColor3, tab.BorderSizePixel, tab.ZIndex = accent, 0, 3
	tab.Parent = label
	gui.Parent = root
	return gui
end

return Nameplate
