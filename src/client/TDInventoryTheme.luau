-- RPG rendering adapter over pinned, byte-identical TD atlas definitions.
local Shared = game:GetService("ReplicatedStorage").Shared
local Art = require(Shared.TDUI.StatusWindowArtAssets)
local Icons = require(Shared.TDUI.UIIconAssets)
local TweenService = game:GetService("TweenService")
local Theme = {color = {
	navy=Color3.fromRGB(20,29,45), ink=Color3.fromRGB(8,16,30), blue=Color3.fromRGB(20,55,100),
	gold=Color3.fromRGB(222,185,106), silver=Color3.fromRGB(156,185,210), text=Color3.fromRGB(242,239,224),
	muted=Color3.fromRGB(161,179,199), green=Color3.fromRGB(155,225,174), error=Color3.fromRGB(255,174,145),
}}
function Theme.sprite(parent, name, key, position, size)
	local data, crop = Art, Art.regions[key]
	if Art.overrides[key] then data = Art.overrides[key]; crop = data.regions[key] end
	local result = Instance.new("ImageLabel")
	result.Name, result.Position, result.Size, result.BackgroundTransparency = name, position, size, 1
	result.Image = data.image
	local sx,sy = data.renderWidth/data.width, data.renderHeight/data.height
	local x,y = math.round(crop.x*sx), math.round(crop.y*sy)
	result.ImageRectOffset = Vector2.new(x,y)
	result.ImageRectSize = Vector2.new(math.round((crop.x+crop.width)*sx)-x,math.round((crop.y+crop.height)*sy)-y)
	if crop.slice then
		result.ScaleType = Enum.ScaleType.Slice
		result.SliceCenter = Rect.new(math.round(crop.slice.left*sx),math.round(crop.slice.top*sy),math.round(crop.slice.right*sx),math.round(crop.slice.bottom*sy))
		result.SliceScale = crop.sliceScale
	else result.ScaleType = Enum.ScaleType.Fit end
	result:SetAttribute("TDArtKey",key)
	result.Parent = parent
	return result
end
function Theme.icon(parent, key, position, size)
	local crop = Icons.icons[key]
	local data = Icons.atlases[crop.atlas]
	local result = Instance.new("ImageLabel")
	result.Name, result.Image, result.BackgroundTransparency = "TDIcon_" .. key, data.image, 1
	local sx,sy = data.renderWidth/data.width, data.renderHeight/data.height
	result.ImageRectOffset = Vector2.new(math.round(crop.x*sx),math.round(crop.y*sy))
	result.ImageRectSize = Vector2.new(math.round((crop.x+crop.width)*sx)-result.ImageRectOffset.X,math.round((crop.y+crop.height)*sy)-result.ImageRectOffset.Y)
	result.Position, result.Size, result.ScaleType, result.Parent = position, size, Enum.ScaleType.Fit, parent
	return result
end
function Theme.frame(parent, name, position, size)
	local frame = Instance.new("Frame")
	frame.Name, frame.Position, frame.Size = name, position, size
	frame.BackgroundColor3, frame.BorderSizePixel = Theme.color.navy, 0
	frame.Parent = parent
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,8); corner.Parent=frame
	local outline=Instance.new("UIStroke"); outline.Color=Theme.color.silver; outline.Transparency=0.5; outline.Parent=frame
	local art = Theme.sprite(frame,"TDPanelArt","panel",UDim2.new(),UDim2.fromScale(1,1))
	art.SliceScale=0.3
	return frame
end
function Theme.label(parent, name, text, position, size, textSize, color)
	local value=Instance.new("TextLabel")
	value.Name,value.Text,value.Position,value.Size = name,text,position,size
	value.BackgroundTransparency,value.BorderSizePixel=1,0
	value.Font,value.TextSize,value.TextColor3 = Enum.Font.GothamMedium,textSize or 14,color or Theme.color.text
	value.TextXAlignment,value.TextYAlignment = Enum.TextXAlignment.Left,Enum.TextYAlignment.Center
	value.TextWrapped,value.AutoLocalize=true,false
	value.Parent=parent
	return value
end
function Theme.button(parent,name,text,position,size,primary)
	local button=Instance.new("TextButton")
	button.Name,button.Position,button.Size,button.Text=name,position,size,""
	button.BackgroundColor3,button.BorderSizePixel=primary and Color3.fromRGB(25,83,53) or Theme.color.blue,0
	button.AutoButtonColor,button.Selectable,button.AutoLocalize=false,true,false
	button.Parent=parent
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,8); corner.Parent=button
	local art=Theme.sprite(button,"TDButtonArt",primary and "shellUpgrade" or "shellDetails",UDim2.new(),UDim2.fromScale(1,1))
	art.SliceScale=0.32
	local title=Theme.label(button,"Caption",text,UDim2.fromOffset(14,2),UDim2.new(1,-28,1,-4),13)
	title.TextXAlignment,title.Font=Enum.TextXAlignment.Center,Enum.Font.GothamBold
	button.MouseEnter:Connect(function()
		if button.Active then TweenService:Create(art,TweenInfo.new(.12),{ImageColor3=Color3.fromRGB(222,238,255)}):Play() end
	end)
	button.MouseLeave:Connect(function() TweenService:Create(art,TweenInfo.new(.16),{ImageColor3=Color3.new(1,1,1)}):Play() end)
	return button
end
function Theme.enabled(button,enabled)
	button.Active,button.Selectable=enabled,enabled
	button.Caption.TextTransparency=enabled and 0 or .45
	button.BackgroundTransparency=enabled and 0 or .4
	button.TDButtonArt.ImageTransparency=enabled and 0 or .4
end
return Theme
