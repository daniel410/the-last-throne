-- Native scalable artwork: no external image upload or Restricted asset dependency.
-- TD palette: silver glass, gold stopper, red HP and blue MP. Shape + size mark
-- distinguish tiers without relying on color alone.
local Sprites = require(script.Parent.ItemSprites)
local Icon = {}
local function part(parent, name, x, y, w, h, color, radius)
	local frame = Instance.new("Frame")
	frame.Name, frame.BackgroundColor3, frame.BorderSizePixel = name, color, 0
	frame.Position, frame.Size = UDim2.fromScale(x, y), UDim2.fromScale(w, h)
	frame.Parent = parent
	if radius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius, corner.Parent = UDim.new(radius, 0), frame
	end
	return frame
end
function Icon.create(parent, definition, position, size)
	assert(definition.potionTier and definition.restore, "Potion icon needs a potion definition")
	local root = Instance.new("Frame")
	root.Name, root.BackgroundTransparency = "PotionIcon", 1
	root.Position, root.Size, root.Parent = position, size, parent
	root:SetAttribute("DefinitionId", definition.id)
	root:SetAttribute("PotionSize", definition.potionSize)
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio, aspect.DominantAxis, aspect.Parent = 1, Enum.DominantAxis.Height, root
	local illustration = Sprites.create(root, definition, UDim2.new(), UDim2.fromScale(1,1))
	if illustration then
		aspect:Destroy()
		local glass = part(root, "Glass", 0, 0, 1, 1, Color3.new(1,1,1))
		glass.BackgroundTransparency=1
		local mark=Instance.new("TextLabel")
		mark.Name,mark.Text="SizeMark",definition.potionTier==4 and "XL" or definition.potionSize:sub(1,1)
		mark.AnchorPoint=Vector2.new(.5,.5)
		mark.Position,mark.Size=UDim2.fromScale(.5,.7),UDim2.fromOffset(24,16)
		mark.BackgroundTransparency=1
		mark.TextColor3,mark.TextScaled,mark.Font=Color3.new(1,1,1),false,Enum.Font.GothamBold
		mark.TextSize,mark.TextStrokeTransparency=12,.3
		mark.AutoLocalize,mark.Parent=false,glass
		return root
	end
	local tier = definition.potionTier
	local width, height = ({.53, .60, .72, .82})[tier], ({.53, .56, .66, .72})[tier]
	local left, top = .5 - width / 2, .87 - height
	local silver, gold = Color3.fromRGB(191, 216, 235), Color3.fromRGB(222, 185, 106)
	part(root, "Neck", .4, top - .13, .2, .2, silver, .2)
	part(root, "Stopper", .36, top - .16, .28, .09, gold, .2)
	local body = part(root, "Glass", left, top, width, height, silver, tier == 1 and .5 or .25)
	local outline = Instance.new("UIStroke")
	outline.Color, outline.Thickness, outline.Parent = Color3.fromRGB(42, 57, 77), 1, body
	local liquid = part(body, "Liquid", .07, .18, .86, .73,
		definition.restore == "health" and Color3.fromRGB(216, 43, 66) or Color3.fromRGB(38, 133, 246), .25)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(130, 145, 175))
	gradient.Rotation, gradient.Parent = 90, liquid
	local shine = part(body, "GlassShine", .14, .13, .1, .48, Color3.new(1, 1, 1), .5)
	shine.BackgroundTransparency = .35
	if tier >= 3 then part(body, "GoldBand", 0, .78, 1, .08, gold) end
	local mark = Instance.new("TextLabel")
	mark.Name, mark.BackgroundTransparency = "SizeMark", 1
	mark.Position, mark.Size = UDim2.fromScale(.15, .27), UDim2.fromScale(.7, .6)
	mark.Text, mark.Font = (tier == 4 and "XL" or definition.potionSize:sub(1, 1)), Enum.Font.GothamBlack
	mark.TextColor3, mark.TextScaled, mark.TextStrokeTransparency = Color3.new(1, 1, 1), true, .45
	mark.AutoLocalize, mark.Parent = false, body
	return root
end
return Icon
