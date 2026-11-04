-- TD navigation renders the picture and the shared Maps nameplate independently.
local RS=game:GetService('ReplicatedStorage')
local TextService=game:GetService('TextService')
local T=require(script.Parent.TDInventoryTheme)
local TD=require(RS.Shared.TDUI.LobbyHomeArtAssets)
local RPG=require(RS.Shared.RPGNavigationArt)
local Art={}
local keys={Heroes='hero',Quest='quests',Maps='maps',DiamondShop='shop'}
function Art.layout(button)
 local size=button.AbsoluteSize
 if size.X<=0 or size.Y<=0 then return end
 local viewport=button.PictureViewport
 local picture=viewport.NavigationIcon
 local plate=button.NavigationPlaqueArt
 local crop,plaqueCrop=picture.ImageRectSize,plate.ImageRectSize
 -- Preserve each crop's aspect ratio and join their visible edges. Fit the
 -- picture into the height left above the full-width plaque, keeping small
 -- screens' labels readable instead of shrinking the whole assembly.
 local bodyRatio,plateRatio=crop.Y/crop.X,plaqueCrop.Y/plaqueCrop.X
 local width=size.X*.98
 local plateHeight=width*plateRatio
 local overlap=width*.02
 local bodyWidth=math.min(width,(size.Y-plateHeight+overlap)/bodyRatio)
 local bodyHeight=bodyWidth*bodyRatio
 local left=(size.X-width)*.5
 local top=(size.Y-(bodyHeight+plateHeight-overlap))*.5
 viewport.Position=UDim2.fromOffset((size.X-bodyWidth)*.5,top)
 viewport.Size=UDim2.fromOffset(bodyWidth,bodyHeight)
 picture.AnchorPoint=Vector2.zero
 picture.Position=UDim2.fromOffset(0,0)
 picture.Size=UDim2.fromScale(1,1)
 plate.Position=UDim2.fromOffset(left,top+bodyHeight-overlap)
 plate.Size=UDim2.fromOffset(width,plateHeight)
 local label=button.Caption
 label.Position=plate.Position
 label.Size=plate.Size
 local textSize=size.Y<64 and 14 or size.X<100 and 16 or math.clamp(math.floor(size.X*.17),18,34)
 local bounds=TextService:GetTextSize(label.Text,textSize,Enum.Font.GothamBlack,Vector2.new(10000,1000))
 local availableWidth=width*(button.Name=='Blacksmith' and .82 or .92)
 label.TextSize=math.max(1,math.floor(math.min(textSize,textSize*availableWidth/math.max(1,bounds.X),plateHeight*.85)))
 label.TextScaled=false;label.TextWrapped=false
end
function Art.apply(button,id)
 local key=keys[id]
 local source,body
 if key then
  source=TD.overrides[key] or TD;body=TD.navigationBodies[key]
 else
  source=RPG;body=RPG.regions[id]
 end
 local viewport=Instance.new('Frame');viewport.Name='PictureViewport';viewport.BackgroundTransparency=1;viewport.ClipsDescendants=true
 viewport.Position=UDim2.fromScale(.01,0);viewport.Size=UDim2.fromScale(.98,.72);viewport.ZIndex=3;viewport.Parent=button
 local picture=T.sprite(viewport,'NavigationIcon','body',UDim2.new(),UDim2.fromScale(1,1),{
  image=source.image,width=source.width,height=source.height,renderWidth=source.renderWidth,renderHeight=source.renderHeight,regions={body=body}})
 picture.ZIndex=3;picture:SetAttribute('NavigationSource',key and 'TD' or 'RPG-TD-frame')
 local plaque=TD.navigationPlaque
 local plate=T.sprite(button,'NavigationPlaqueArt','plate',UDim2.fromScale(.01,.70),UDim2.fromScale(.98,.30),{
  image=plaque.image,width=plaque.width,height=plaque.height,renderWidth=plaque.renderWidth,renderHeight=plaque.renderHeight,regions={plate=plaque.region}})
 plate.ZIndex=3
 local resizeConnection=button:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()Art.layout(button)end)
 button.Destroying:Connect(function()resizeConnection:Disconnect()end)
 Art.layout(button)
 local function tint(value)picture.ImageColor3=value;plate.ImageColor3=value end
 button.MouseEnter:Connect(function()tint(Color3.fromRGB(222,238,255))end)
 button.MouseLeave:Connect(function()tint(Color3.new(1,1,1))end)
 button.SelectionGained:Connect(function()tint(Color3.fromRGB(222,238,255))end)
 button.SelectionLost:Connect(function()tint(Color3.new(1,1,1))end)
 return picture,plate
end
return Art
