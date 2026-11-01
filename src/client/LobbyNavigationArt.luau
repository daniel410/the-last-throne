-- TD navigation renders the picture and the shared Maps nameplate independently.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local TD=require(RS.Shared.TDUI.LobbyHomeArtAssets)
local RPG=require(RS.Shared.RPGNavigationArt)
local Art={}
local keys={Heroes='hero',Quest='quests',Maps='maps',DiamondShop='shop'}
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
 local function tint(value)picture.ImageColor3=value;plate.ImageColor3=value end
 button.MouseEnter:Connect(function()tint(Color3.fromRGB(222,238,255))end)
 button.MouseLeave:Connect(function()tint(Color3.new(1,1,1))end)
 button.SelectionGained:Connect(function()tint(Color3.fromRGB(222,238,255))end)
 button.SelectionLost:Connect(function()tint(Color3.new(1,1,1))end)
 return picture,plate
end
return Art
