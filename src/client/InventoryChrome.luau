-- Code-native silver rails and restrained gold fittings from the approved bag v2.
local Base = require(script.Parent.TDInventoryTheme)
local Chrome = {}
function Chrome.diamond(parent, name, position, size, color)
	local gem = Instance.new("Frame")
	gem.Name, gem.Position, gem.Size, gem.Rotation = name, position, UDim2.fromOffset(size,size), 45
	gem.AnchorPoint, gem.BackgroundColor3, gem.BorderSizePixel = Vector2.new(.5,.5), color, 0
	local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(255,226,149); stroke.Thickness=1; stroke.Parent=gem
	local gradient=Instance.new("UIGradient"); gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(137,96,29)); gradient.Rotation=90; gradient.Parent=gem
	gem.Parent=parent
	return gem
end
function Chrome.frame(parent,name,position,size)
	local frame=Instance.new("Frame")
	frame.Name,frame.Position,frame.Size=name,position,size
	frame.BackgroundColor3,frame.BorderSizePixel=Color3.fromRGB(7,20,39),0
	frame.Parent=parent
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,6); corner.Parent=frame
	local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(80,121,157); stroke.Thickness=1; stroke.Parent=frame
	local gradient=Instance.new("UIGradient"); gradient.Color=ColorSequence.new(Color3.fromRGB(17,43,77),Color3.fromRGB(4,13,26)); gradient.Rotation=90; gradient.Parent=frame
	if name=="InventoryPanel" then
		stroke.Color,stroke.Thickness=Color3.fromRGB(187,205,225),4
		local inner=Instance.new("Frame"); inner.Name="InnerGoldRail"; inner.BackgroundTransparency=1; inner.Position=UDim2.fromOffset(5,5); inner.Size=UDim2.new(1,-10,1,-10); inner.Parent=frame
		local line=Instance.new("UIStroke"); line.Color=Base.color.gold; line.Thickness=1; line.Parent=inner
		for i,p in ipairs({UDim2.fromOffset(6,6),UDim2.new(1,-6,0,6),UDim2.new(0,6,1,-6),UDim2.new(1,-6,1,-6)}) do Chrome.diamond(frame,"CornerGem"..i,p,15,Color3.fromRGB(255,192,45)) end
	end
	return frame
end
function Chrome.card(parent,name,position,size,selected,occupied)
	local frame=Instance.new("TextButton")
	frame.Name,frame.Position,frame.Size,frame.Text=name,position,size,""
	frame.BackgroundColor3,frame.BorderSizePixel=selected and Color3.fromRGB(11,44,76) or Color3.fromRGB(7,17,29),0
	frame.AutoButtonColor,frame.Selectable=false,occupied
	frame.Parent=parent
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,7); corner.Parent=frame
	local line=Instance.new("UIStroke"); line.Name="SelectionOutline"; line.Color=selected and Color3.fromRGB(57,195,255) or Color3.fromRGB(116,140,163); line.Thickness=selected and 3 or 1.5; line.Transparency=occupied and 0 or .55; line.Parent=frame
	if selected then
		for i,p in ipairs({UDim2.fromOffset(3,3),UDim2.new(1,-3,0,3),UDim2.new(0,3,1,-3),UDim2.new(1,-3,1,-3)}) do Chrome.diamond(frame,"SelectedGem"..i,p,7,Base.color.gold) end
	end
	return frame
end
return Chrome
