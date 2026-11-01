--!strict
-- Decorative button rendering. Optional verified atlas profiles never own input or text.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Art = {}
local NAVY = Color3.fromRGB(12,27,54)
local GOLD = Color3.fromRGB(255,190,0)
local SILVER = Color3.fromRGB(214,233,255)
local function finite(value: any): boolean
 return type(value)=="number" and value==value and math.abs(value)<math.huge
end
function Art.cropRegion(data: any, region: any): any
 if type(data)~="table" or type(region)~="table" then return nil end
 local width,height=data.width,data.height
 if not finite(width) or not finite(height) or width<=0 or height<=0 then return nil end
 local rw,rh=data.renderWidth or width,data.renderHeight or height
 if not finite(rw) or not finite(rh) or rw<1 or rh<1 then return nil end
 rw,rh=math.floor(rw),math.floor(rh)
 if not finite(region.x) or not finite(region.y) or not finite(region.width) or not finite(region.height) or region.width<=0 or region.height<=0 then return nil end
 local left,top=math.clamp(region.x,0,width),math.clamp(region.y,0,height)
 local right,bottom=math.clamp(region.x+region.width,0,width),math.clamp(region.y+region.height,0,height)
 if right<=left or bottom<=top then return nil end
 local x=math.clamp(math.round(left*rw/width),0,rw-1)
 local y=math.clamp(math.round(top*rh/height),0,rh-1)
 local endX=math.clamp(math.round(right*rw/width),x+1,rw)
 local endY=math.clamp(math.round(bottom*rh/height),y+1,rh)
 return {x=x,y=y,width=endX-x,height=endY-y}
end
local function layer(parent: GuiObject, name: string, inset: number, color: Color3, radius: number): Frame
 local frame=Instance.new("Frame")
 frame:SetAttribute("TDCustomArtSurface",true)
 frame.Name,frame.Position,frame.Size=name,UDim2.fromOffset(inset,inset),UDim2.new(1,-inset*2,1,-inset*2)
 frame.BackgroundColor3,frame.BorderSizePixel=color,0
 frame.ZIndex=parent.ZIndex
 frame.Active,frame.Selectable,frame.Parent=false,false,parent
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,radius);corner.Parent=frame
 return frame
end
local function gradient(parent: Instance, a: Color3, b: Color3)
 local effect=Instance.new("UIGradient")
 effect.Rotation,effect.Color,effect.Parent=90,ColorSequence.new(a,b),parent
end
local function outline(parent: GuiObject, tint: Color3, thickness: number)
 local stroke=Instance.new("UIStroke")
 stroke.ApplyStrokeMode,stroke.Color,stroke.Thickness,stroke.Parent=Enum.ApplyStrokeMode.Border,tint,thickness,parent
end
local function profile(): any
 local module=Shared.TDUI:FindFirstChild("LobbyHomeArtAssets")
 if not module or not module:IsA("ModuleScript") then return nil end
 local ok,value=pcall(require,module)
 return if ok and type(value)=="table" then value else nil
end
local function atlas(parent: TextButton, key: string, fallback: {GuiObject})
 local data=profile()
 local region=data and type(data.regions)=="table" and data.regions[key]
 if not data or not region then return end
 local source=if type(data.overrides)=="table" and type(data.overrides[key])=="table" then data.overrides[key] else data
 if type(source.image)~="string" or not source.image:match("^rbxassetid://%d+$") then return end
 if tonumber(source.image:match("%d+$"))==0 then return end
 if source~=data then region=source.regions and source.regions[key] end
 local crop=Art.cropRegion(source,region)
 if not crop then return end
 local image=Instance.new("ImageLabel")
 image:SetAttribute("TDCustomArtSurface",true)
 image.Name,image.BackgroundTransparency,image.ImageColor3="CitadelButtonArt",1,Color3.new(1,1,1)
 image.Image,image.ScaleType=source.image,if key=="play" then Enum.ScaleType.Stretch else Enum.ScaleType.Fit
 image:SetAttribute("CitadelAtlasKey",key)
 image.ImageRectOffset=Vector2.new(crop.x,crop.y)
 image.ImageRectSize=Vector2.new(crop.width,crop.height)
 image.Position,image.Size=UDim2.fromScale(0,0),UDim2.fromScale(1,1)
 image.ZIndex=parent.ZIndex+2
 image.Active,image.Selectable,image.Visible,image.Parent=false,false,false,parent
 local confirmed=false
 local function ready()
  local loaded=image.IsLoaded or confirmed
  image.Visible=loaded
  local captionY,captionH=region.captionY,region.captionH
  if loaded and finite(captionY) and finite(captionH) and captionY>=0 and captionH>0 and captionY+captionH<=1 then
   parent:SetAttribute("CitadelCaptionY",captionY)
   parent:SetAttribute("CitadelCaptionH",captionH)
  end
  parent:SetAttribute("CitadelAtlasReady",loaded)
  if data.framed==true then
   parent.BackgroundTransparency=if loaded then 1 else 0
   for _,item in fallback do item.Visible=not loaded end
  elseif loaded then
   for _,item in fallback do if item.Name=="NavigationArt" then item.Visible=false end end
  end
 end
 image:GetPropertyChangedSignal("IsLoaded"):Connect(ready)
 ready()
 task.spawn(function()
  pcall(function()
   game:GetService("ContentProvider"):PreloadAsync({image},function(_,status)
    if status==Enum.AssetFetchStatus.Success and image.Parent then confirmed=true;ready() end
   end)
  end)
 end)
end
function Art.enamel(button: TextButton, green: boolean?): {GuiObject}
 button:SetAttribute("TDCustomArtSurface",true)
 button.Text,button.BorderSizePixel="",0
 button.BackgroundColor3=Color3.new(1,1,1)
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,if green then 20 else 10);corner.Parent=button
 -- Root gradient is retained for readable semantic fallback and state inspection.
 gradient(button,if green then Color3.fromRGB(0,205,25) else SILVER,if green then Color3.fromRGB(0,144,12) else Color3.fromRGB(65,90,133))
 local shadows: {GuiObject}={}
 for i=1,3 do
  local shadow=layer(button,"MetalShadow"..i,-(4-i),Color3.new(0,0,0),if green then 20 else 10)
  shadow.Position=UDim2.fromOffset(-(4-i),7+(4-i))
  shadow.BackgroundTransparency=.55+i*.1
  table.insert(shadows,shadow)
 end
 local outer=layer(button,"MetalOuterRim",0,Color3.new(1,1,1),if green then 20 else 10)
 gradient(outer,if green then Color3.fromRGB(255,247,197) else Color3.fromRGB(239,249,255),if green then Color3.fromRGB(207,112,0) else Color3.fromRGB(87,118,164))
 outline(outer,if green then GOLD else SILVER,1)
 local inner=layer(button,"GoldInnerRim",3,Color3.new(1,1,1),if green then 17 else 8)
 gradient(inner,Color3.fromRGB(255,227,111),Color3.fromRGB(207,116,0))
 local well=layer(button,"EnamelWell",6,if green then Color3.new(1,1,1) else NAVY,if green then 14 else 6)
 gradient(well,if green then Color3.fromRGB(0,213,31) else Color3.fromRGB(235,249,255),if green then Color3.fromRGB(0,135,15) else Color3.fromRGB(101,143,208))
 local highlight=Instance.new("Frame")
 highlight.Name,highlight.Size,highlight.Position="TopMetalGlint",UDim2.new(1,-24,0,1),UDim2.fromOffset(12,2)
 highlight.BackgroundColor3,highlight.BorderSizePixel,highlight.Active,highlight.Selectable,highlight.Parent=Color3.new(1,1,1),0,false,false,button
 table.insert(shadows,outer);table.insert(shadows,inner);table.insert(shadows,well);table.insert(shadows,highlight)
 return shadows
end
function Art.play(button: TextButton)
 local fallback=Art.enamel(button,true)
 for _,side in {0,1} do
  local diamond=Instance.new("Frame")
  diamond.Name,diamond.AnchorPoint,diamond.Position="GoldenEndcap",Vector2.new(.5,.5),UDim2.fromScale(side,.5)
  diamond.Size,diamond.Rotation,diamond.BackgroundColor3=UDim2.fromOffset(19,19),45,GOLD
  diamond.BorderSizePixel,diamond.Active,diamond.Selectable,diamond.Parent=0,false,false,button
  gradient(diamond,Color3.fromRGB(255,249,183),Color3.fromRGB(217,126,0))
  outline(diamond,Color3.fromRGB(255,224,108),1)
  local jewel=layer(diamond,"DiamondInset",4,Color3.fromRGB(255,166,0),0)
  gradient(jewel,Color3.fromRGB(255,242,144),Color3.fromRGB(217,106,0))
  table.insert(fallback,diamond)
 end
 atlas(button,"play",fallback)
end
return Art
