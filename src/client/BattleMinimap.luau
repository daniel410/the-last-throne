-- A north-up preview built from the current training field, not a concept screenshot.
local Workspace=game:GetService('Workspace')
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local Map={}
function Map.create(parent)
 local frame=Instance.new('Frame');frame.Name='Minimap';frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-10,0,8);frame.Size=UDim2.fromOffset(168,168);frame.BackgroundColor3=Color3.fromRGB(7,22,35);frame.BorderSizePixel=0;frame.Parent=parent
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=frame
 local outline=Instance.new('UIStroke');outline.Color=Theme.color.silver;outline.Thickness=5;outline.Parent=frame
 local view=Instance.new('ViewportFrame');view.Name='MapPreview';view.Position=UDim2.fromOffset(5,5);view.Size=UDim2.new(1,-10,1,-10);view.BackgroundColor3=Color3.fromRGB(27,61,36);view.BorderSizePixel=0;view.Ambient=Color3.fromRGB(210,221,215);view.LightColor=Color3.new(1,1,1);view.LightDirection=Vector3.new(-1,-3,-1);view.Parent=frame
 local curve=Instance.new('UICorner');curve.CornerRadius=UDim.new(1,0);curve.Parent=view
 local world=Instance.new('WorldModel');world.Name='MapScene';world.Parent=view
 local camera=Instance.new('Camera');camera.FieldOfView=10;camera.CFrame=CFrame.lookAt(Vector3.new(0,1029,0),Vector3.zero,Vector3.new(0,0,-1));camera.Parent=view;view.CurrentCamera=camera
 for i,p in ipairs({UDim2.fromScale(.5,0),UDim2.fromScale(1,.5),UDim2.fromScale(.5,1),UDim2.fromScale(0,.5)}) do Chrome.diamond(frame,'MapGem'..i,p,12,Theme.color.gold) end
 local north=Theme.label(frame,'North','N',UDim2.new(.5,-10,0,9),UDim2.fromOffset(20,18),10,Theme.color.text);north.TextXAlignment=Enum.TextXAlignment.Center
 local playerMarker=Theme.label(frame,'PlayerMarker','▲',UDim2.fromScale(.5,.5),UDim2.fromOffset(20,20),18,Color3.fromRGB(98,204,255));playerMarker.AnchorPoint=Vector2.new(.5,.5);playerMarker.TextXAlignment=Enum.TextXAlignment.Center;playerMarker.TextStrokeTransparency=0;playerMarker.TextStrokeColor3=Color3.new(1,1,1);playerMarker.Visible=false;playerMarker.ZIndex=4
 local caption=Theme.label(frame,'Region','DEEPWOOD',UDim2.new(0,12,1,-30),UDim2.new(1,-24,0,18),9,Theme.color.text);caption.TextXAlignment=Enum.TextXAlignment.Center;caption.TextStrokeTransparency=.2;caption.TextStrokeColor3=Color3.new(0,0,0)
 local menuButton=Theme.button(frame,'MapMenu','≡',UDim2.new(1,-34,0,0),UDim2.fromOffset(40,40));menuButton.Caption.Visible=false
 Theme.icon(menuButton,'settings',UDim2.fromOffset(4,4),UDim2.new(1,-8,1,-8))
 local menu=Theme.frame(frame,'MapActions',UDim2.new(1,-168,0,199),UDim2.fromOffset(168,146));menu.Visible=false
 local hero=Theme.button(menu,'Hero','HERO [H]',UDim2.fromOffset(10,8),UDim2.fromOffset(148,36))
 local bag=Theme.button(menu,'Bag','BAG [B]',UDim2.fromOffset(10,52),UDim2.fromOffset(148,36))
 menuButton.Activated:Connect(function() menu.Visible=not menu.Visible end)
 hero.Activated:Connect(function() menu.Visible=false end);bag.Activated:Connect(function() menu.Visible=false end)
 local terrain,enemyMarkers,lastUpdate=nil,{},-math.huge
 local function point(marker,position)
  local x,z=position.X/180,position.Z/180
  marker.Position=UDim2.fromScale(.5+x,.5+z);marker.Visible=x*x+z*z<.21
 end
 local function update(character)
  local now=os.clock();if now-lastUpdate<.1 then return end;lastUpdate=now
  local field=Workspace:FindFirstChild('DeepwoodK0');local source=field and field:FindFirstChild('TerrainBlockout')
  if source and source~=terrain then
   world:ClearAllChildren();terrain=source
   local count=0
   for _,part in ipairs(source:GetDescendants()) do
    if part:IsA('BasePart') and part.Transparency<1 and count<100 then
     local copy=Instance.new('Part');copy.Name=part.Name;copy.Size,copy.CFrame,copy.Color=part.Size,part.CFrame,part.Color;copy.Shape=part:IsA('Part') and part.Shape or Enum.PartType.Block;copy.Material=Enum.Material.SmoothPlastic;copy.Anchored=true;copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.Parent=world;count+=1
    end
   end
   frame:SetAttribute('PreviewPartCount',count)
  end
  local root=character and character:FindFirstChild('HumanoidRootPart')
  if root then point(playerMarker,root.Position);playerMarker.Rotation=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z)) else playerMarker.Visible=false end
  local enemies=field and field:FindFirstChild('Enemies');local present={}
  if enemies then
   for _,enemy in ipairs(enemies:GetChildren()) do
    local human=enemy:FindFirstChildOfClass('Humanoid');local enemyRoot=enemy:FindFirstChild('HumanoidRootPart')
    if human and human.Health>0 and enemyRoot then
     local marker=enemyMarkers[enemy]
     if not marker then
      marker=Instance.new('Frame');marker.Name='EnemyMarker';marker.Size=UDim2.fromOffset(6,6);marker.AnchorPoint=Vector2.new(.5,.5);marker.BackgroundColor3=Color3.fromRGB(247,101,81);marker.BorderSizePixel=0;marker.ZIndex=3;marker.Parent=frame
      local circle=Instance.new('UICorner');circle.CornerRadius=UDim.new(1,0);circle.Parent=marker;enemyMarkers[enemy]=marker
     end
     point(marker,enemyRoot.Position);present[enemy]=true
    end
   end
  end
  for enemy,marker in pairs(enemyMarkers) do if not present[enemy] then marker:Destroy();enemyMarkers[enemy]=nil end end
 end
 return {frame=frame,menu=menu,hero=hero,bag=bag,update=update}
end
return Map
