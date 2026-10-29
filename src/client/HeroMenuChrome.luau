-- Code-native silver rails and gold fittings, matching the approved TD concepts.
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local Menu={}
function Menu.frame(parent,name,position,size)
 local frame=Chrome.frame(parent,name,position,size)
 local outline=frame:FindFirstChildOfClass('UIStroke');outline.Color=Color3.fromRGB(174,202,231);outline.Thickness=3
 local inner=Instance.new('Frame');inner.Name='GoldRail';inner.Position=UDim2.fromOffset(5,5);inner.Size=UDim2.new(1,-10,1,-10);inner.BackgroundTransparency=1;inner.Parent=frame
 local gold=Instance.new('UIStroke');gold.Color=Theme.color.gold;gold.Thickness=1;gold.Parent=inner
 for i,p in ipairs({UDim2.fromOffset(5,5),UDim2.new(1,-5,0,5),UDim2.new(0,5,1,-5),UDim2.new(1,-5,1,-5)}) do Chrome.diamond(frame,'GoldFitting'..i,p,13,Color3.fromRGB(255,197,52)) end
 return frame
end
function Menu.plaque(parent,name,text,position,size)
 local frame=Theme.sprite(parent,name,'shellDetails',position,size);frame.SliceScale=.32
 local caption=Theme.label(frame,'Caption',text,UDim2.fromOffset(18,3),UDim2.new(1,-36,1,-6),22,Theme.color.text)
 caption.Font=Enum.Font.GothamBold;caption.TextXAlignment=Enum.TextXAlignment.Center
 return frame
end
function Menu.node(parent,name,icon,position,size,unlocked,selected)
 local node=Instance.new('TextButton');node.Name=name;node.Position=position;node.Size=UDim2.fromOffset(size,size);node.Text='';node.BackgroundColor3=unlocked and Color3.fromRGB(13,82,167) or Color3.fromRGB(31,38,52);node.BorderSizePixel=0;node.AutoButtonColor=false;node.Parent=parent
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=node
 local ring=Instance.new('UIStroke');ring.Color=selected and Color3.fromRGB(255,204,74) or unlocked and Color3.fromRGB(169,211,255) or Color3.fromRGB(102,114,129);ring.Thickness=selected and 4 or 3;ring.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;ring.Parent=node
 local gradient=Instance.new('UIGradient');gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(40,53,85));gradient.Rotation=90;gradient.Parent=node
 if icon~='' then local art=Theme.icon(node,icon,UDim2.fromOffset(7,7),UDim2.new(1,-14,1,-14));art.ImageTransparency=unlocked and 0 or .62 end
 for i,p in ipairs({UDim2.fromScale(.5,0),UDim2.fromScale(1,.5),UDim2.fromScale(.5,1),UDim2.fromScale(0,.5)}) do Chrome.diamond(node,'NodeGem'..i,p,size*.13,unlocked and Theme.color.gold or Theme.color.silver) end
 return node
end
return Menu
