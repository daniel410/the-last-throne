-- A bounded north-up 2D atlas with personal discovery and semantic markers.
local Workspace=game:GetService('Workspace')
local Text=require(game:GetService('ReplicatedStorage').Shared.K0Text)
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local State=require(script.Parent.DeepwoodMapState)
local Access=require(game:GetService('ReplicatedStorage').Shared.DeepwoodAccess)
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Canvas=require(script.Parent.DeepwoodMapCanvas)
local Map={}
function Map.create(parent)
 local frame=Instance.new('Frame');frame.Name='Minimap';frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-10,0,8);frame.Size=UDim2.fromOffset(168,168);frame.BackgroundColor3=Color3.fromRGB(7,22,35);frame.BorderSizePixel=0;frame.Parent=parent
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=frame
 local outline=Instance.new('UIStroke');outline.Color=Theme.color.silver;outline.Thickness=5;outline.Parent=frame
 local view=Instance.new('Frame');view.Name='MapPreview';view.Position=UDim2.fromOffset(8,8);view.Size=UDim2.new(1,-16,1,-16);view.BackgroundColor3=Color3.fromRGB(27,61,36);view.ClipsDescendants=true;view.BorderSizePixel=0;view.Parent=frame
 local curve=Instance.new('UICorner');curve.CornerRadius=UDim.new(1,0);curve.Parent=view
 local atlas,regionId
 local function clearScene() for _,child in ipairs(view:GetChildren()) do if not child:IsA('UICorner') then child:Destroy() end end end
 for i,p in ipairs({UDim2.fromScale(.5,0),UDim2.fromScale(1,.5),UDim2.fromScale(.5,1),UDim2.fromScale(0,.5)}) do Chrome.diamond(frame,'MapGem'..i,p,12,Theme.color.gold) end
 local north=Theme.label(frame,'North','N',UDim2.new(.5,-10,0,9),UDim2.fromOffset(20,18),10,Theme.color.text);north.TextXAlignment=Enum.TextXAlignment.Center
 local playerPulse=Instance.new('Frame');playerPulse.Name='PlayerPulse';playerPulse.AnchorPoint=Vector2.new(.5,.5);playerPulse.BackgroundColor3=Color3.fromRGB(71,232,255);playerPulse.BorderSizePixel=0;playerPulse.Visible=false;playerPulse.ZIndex=4;playerPulse.Parent=frame
 local pulseCorner=Instance.new('UICorner');pulseCorner.CornerRadius=UDim.new(1,0);pulseCorner.Parent=playerPulse
 local playerMarker=Theme.label(frame,'PlayerMarker','▲',UDim2.fromScale(.5,.5),UDim2.fromOffset(28,28),24,Color3.fromRGB(92,239,255));playerMarker.AnchorPoint=Vector2.new(.5,.5);playerMarker.TextXAlignment=Enum.TextXAlignment.Center;playerMarker.TextStrokeTransparency=0;playerMarker.TextStrokeColor3=Color3.fromRGB(0,25,40);playerMarker.BackgroundColor3=Color3.fromRGB(0,22,40);playerMarker.BackgroundTransparency=.08;playerMarker.Visible=false;playerMarker.ZIndex=6
 local markerCorner=Instance.new('UICorner');markerCorner.CornerRadius=UDim.new(1,0);markerCorner.Parent=playerMarker
 local markerOutline=Instance.new('UIStroke');markerOutline.Color=Color3.new(1,1,1);markerOutline.Thickness=2;markerOutline.Parent=playerMarker
 local you=Theme.label(frame,'PlayerLabel',Text.MinimapYou,UDim2.fromScale(.5,.5),UDim2.fromOffset(36,14),10,Color3.new(1,1,1));you.AnchorPoint=Vector2.new(.5,.5);you.TextXAlignment=Enum.TextXAlignment.Center;you.TextStrokeColor3=Color3.new(0,0,0);you.TextStrokeTransparency=0;you.ZIndex=7;you.Visible=false
 local caption=Theme.label(frame,'Region','DEEPWOOD',UDim2.new(0,12,1,-30),UDim2.new(1,-24,0,18),9,Theme.color.text);caption.TextXAlignment=Enum.TextXAlignment.Center;caption.TextStrokeTransparency=.2;caption.TextStrokeColor3=Color3.new(0,0,0)
 local fullMap=Theme.button(frame,'WorldMap','M',UDim2.fromOffset(-8,-4),UDim2.fromOffset(40,40));fullMap.ZIndex=10
 local wallet=require(script.Parent.WalletDisplay).create(frame);wallet.Position=UDim2.new(0,0,1,12)
 local menuButton=Theme.button(frame,'MapMenu','≡',UDim2.new(1,-34,0,0),UDim2.fromOffset(40,40));menuButton.Caption.Visible=false
 Theme.icon(menuButton,'settings',UDim2.fromOffset(4,4),UDim2.new(1,-8,1,-8))
 local menu=Theme.frame(frame,'MapActions',UDim2.new(1,-168,0,240),UDim2.fromOffset(168,194));menu.Visible=false
 local hero=Theme.button(menu,'Hero','HERO [H]',UDim2.fromOffset(10,8),UDim2.fromOffset(148,36))
 local bag=Theme.button(menu,'Bag','BAG [B]',UDim2.fromOffset(10,52),UDim2.fromOffset(148,36))
 local journal=Theme.button(menu,'Journal','JOURNAL [J]',UDim2.fromOffset(10,96),UDim2.fromOffset(148,36))
 journal.Activated:Connect(function() menu.Visible=false end)
 menuButton.Activated:Connect(function() menu.Visible=not menu.Visible end)
 hero.Activated:Connect(function() menu.Visible=false end);bag.Activated:Connect(function() menu.Visible=false end)
 local enemyMarkers,lastUpdate={},-math.huge
 local mapOrigin=Vector3.zero;local mapWidth=180
 local function point(marker,position)
  local x,z=(position.X-mapOrigin.X)/mapWidth,(position.Z-mapOrigin.Z)/mapWidth
  marker.Position=UDim2.fromScale(.5+x,.5+z);marker.Visible=x*x+z*z<.21
 end
 local function update(character)
  local now=os.clock();if now-lastUpdate<.1 then return end;lastUpdate=now
  local field=Workspace:FindFirstChild('DeepwoodK0')
  local charRoot=character and character:FindFirstChild('HumanoidRootPart')
  local inAdventure=State.current and not State.current.training and charRoot
  local id=inAdventure and Access.region(charRoot.Position.X,charRoot.Position.Z) or nil
  if id then
   local z=Content.zones[id];mapOrigin=Vector3.new(table.unpack(z.center));mapWidth=math.max(z.size[1],z.size[2])*168/152;caption.Text=z.name
   if regionId~=id then clearScene();atlas=Canvas.create(view,id,true);atlas.pin.Visible=false;regionId=id end
   atlas.update(State.current,nil,State.target)
  else
   if regionId then clearScene();regionId=nil;atlas=nil end
   mapOrigin=Vector3.zero;mapWidth=180;caption.Text='TRAINING'
  end
  fullMap.Visible=inAdventure~=nil and inAdventure~=false
  frame:SetAttribute('PreviewPartCount',0)
  local root=character and character:FindFirstChild('HumanoidRootPart')
  local human=character and character:FindFirstChildOfClass('Humanoid')
  if root and (not human or human.Health>0) then
   local offset=Vector2.new(root.Position.X-mapOrigin.X,root.Position.Z-mapOrigin.Z)/mapWidth
   local clamped=offset.Magnitude>.38
   if clamped then offset=offset.Unit*.38 end
   playerMarker.Position=UDim2.fromScale(.5+offset.X,.5+offset.Y);playerMarker.Visible=true;playerMarker:SetAttribute('AtMapEdge',clamped)
   playerMarker.Rotation=math.deg(math.atan2(root.CFrame.LookVector.X,-root.CFrame.LookVector.Z))
   playerPulse.Position=playerMarker.Position;playerPulse.Visible=true
   local phase=(math.sin(now*4)+1)/2;playerPulse.Size=UDim2.fromOffset(32+8*phase,32+8*phase);playerPulse.BackgroundTransparency=.65+.2*phase
   you.Position=playerMarker.Position+UDim2.fromOffset(0,offset.Y>.25 and -23 or 23);you.Visible=true
  else playerMarker.Visible=false;playerPulse.Visible=false;you.Visible=false end
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
 return {frame=frame,menu=menu,hero=hero,bag=bag,journal=journal,fullMap=fullMap,update=update}
end
return Map
