local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local Shared=game:GetService('ReplicatedStorage').Shared
local Theme=require(script.Parent.TDInventoryTheme)
local Text=require(Shared.K0Text)
local Content=require(Shared.DeepwoodContent)
local Access=require(Shared.DeepwoodAccess)
local State=require(script.Parent.DeepwoodMapState)
local Canvas=require(script.Parent.DeepwoodMapCanvas)
local Map={}
function Map.start(button)
 local player=Players.LocalPlayer
 local gui=Instance.new('ScreenGui');gui.Name='DeepwoodWorldMap';gui.ResetOnSpawn=false;gui.DisplayOrder=43;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local panel=Theme.frame(gui,'WorldMap',UDim2.fromScale(.5,.5),UDim2.fromOffset(1100,800));panel.AnchorPoint=Vector2.new(.5,.5);panel.BackgroundTransparency=.05;panel.Visible=false
 local title=Theme.label(panel,'Title',Text.Map.Title,UDim2.fromOffset(22,12),UDim2.new(1,-88,0,30),21,Theme.color.gold)
 Theme.label(panel,'Subtitle',Text.Map.Subtitle,UDim2.fromOffset(24,43),UDim2.new(1,-90,0,18),10,Theme.color.muted)
 local progress=Theme.label(panel,'Progress','',UDim2.fromOffset(24,66),UDim2.new(1,-48,0,20),12,Theme.color.text)
 local close=Theme.button(panel,'Close','X',UDim2.new(1,-60,0,12),UDim2.fromOffset(44,44))
 local area=Instance.new('ScrollingFrame');area.Name='Atlas';area.Position=UDim2.fromOffset(18,96);area.Size=UDim2.new(1,-36,1,-232)
 area.BackgroundColor3=Color3.fromRGB(16,33,34);area.BorderSizePixel=0;area.ClipsDescendants=true;area.ScrollBarThickness=4;area.ScrollBarImageColor3=Theme.color.gold;area.Parent=panel
 local scene=Instance.new('Frame');scene.Name='Cartography';scene.BackgroundTransparency=1;scene.BorderSizePixel=0;scene.Parent=area
 local selected
 local detail=Theme.label(panel,'RegionDetail',Text.Map.Ready,UDim2.new(0,24,1,-130),UDim2.new(1,-48,0,34),12,Theme.color.gold)
 local function describe(id)
  selected=id;local z=Content.zones[id];local journal=State.current and State.current.journal
  local message=Text.Map.Discover
  if journal and not Access.allowed(journal,id) then
   local previous=Content.byId[string.format('DW-%02d',z.requiresMain)]
   message=string.format(Text.Map.Unlock,previous and previous.title or Text.Map.Title)
  elseif journal and journal.explored and journal.explored[id] then message=Text.Map.Ready end
  detail.Text=string.format(Text.Map.Detail,z.name,message)
 end
 local atlas=Canvas.create(scene,nil,false,describe)
 local journey=Instance.new('Frame');journey.Name='Journey';journey.BackgroundColor3=Color3.fromRGB(12,26,32);journey.BackgroundTransparency=.15;journey.BorderSizePixel=0;journey.Position=UDim2.new(1,-214,0,96);journey.Size=UDim2.new(0,196,1,-232);journey.Parent=panel
 Theme.label(journey,'Title',Text.Map.Journey,UDim2.fromOffset(14,12),UDim2.new(1,-28,0,20),13,Theme.color.gold)
 Theme.label(journey,'Hint',Text.Map.JourneyHint,UDim2.fromOffset(14,36),UDim2.new(1,-28,0,30),10,Theme.color.muted)
 local chapters={}
 for i=1,7 do
  local id=string.format('DW-%02d',i);local item=Instance.new('TextButton');item.Name='Story'..i;item.Text='';item.AutoLocalize=false;item.BackgroundColor3=Color3.fromRGB(23,45,48);item.BackgroundTransparency=.2;item.BorderSizePixel=0
  item.Position=UDim2.new(0,10,(i-1)/7,70-(i-1)*10);item.Size=UDim2.new(1,-20,1/7,-12);item.Parent=journey
  local name=Theme.label(item,'Name',string.format('%02d  %s',i,Content.zones[id].name),UDim2.fromOffset(10,2),UDim2.new(1,-20,.65,-2),11,Theme.color.text)
  local status=Theme.label(item,'Status','',UDim2.new(0,10,.65,0),UDim2.new(1,-20,.35,-2),9,Theme.color.muted)
  item.Activated:Connect(function() atlas.select(id) end);chapters[i]={button=item,name=name,status=status}
 end
 local compass=Theme.label(scene,'Compass',Text.Map.North..'\n↑',UDim2.fromScale(.93,.06),UDim2.fromOffset(36,40),16,Theme.color.gold);compass.AnchorPoint=Vector2.new(.5,.5);compass.TextXAlignment=Enum.TextXAlignment.Center;compass.ZIndex=8
 local legend=Theme.label(panel,'Legend',Text.Map.Legend,UDim2.new(0,24,1,-94),UDim2.new(1,-48,0,20),11)
 local hint=Theme.label(panel,'MapHint',Text.Map.Hint,UDim2.new(0,24,1,-73),UDim2.new(1,-48,0,18),10,Theme.color.muted)
 local navigation=Theme.button(panel,'NavigationTrail','',UDim2.new(0,18,1,-52),UDim2.new(1,-266,0,40))
 local minus=Theme.button(panel,'ZoomOut',Text.Map.ZoomOut,UDim2.new(1,-240,1,-52),UDim2.fromOffset(44,40))
 local plus=Theme.button(panel,'ZoomIn',Text.Map.ZoomIn,UDim2.new(1,-192,1,-52),UDim2.fromOffset(44,40))
 local fit=Theme.button(panel,'Fit',Text.Map.Fit,UDim2.new(1,-144,1,-52),UDim2.fromOffset(58,40))
 local you=Theme.button(panel,'Center',Text.Map.Center,UDim2.new(1,-82,1,-52),UDim2.fromOffset(64,40))
 local zoom=1;local overview=false;local previousSize
 local function layout()
  local camera=workspace.CurrentCamera;if not camera then return end
  local viewport=gui.AbsoluteSize
  panel.Size=UDim2.fromOffset(math.min(1100,viewport.X-24),math.min(900,viewport.Y-24))
  local small=viewport.X<650;local short=viewport.Y<540
  title.TextSize=small and 16 or 21
  panel.Subtitle.Visible=not short;progress.Position=UDim2.fromOffset(24,short and 36 or 66)
  detail.TextSize=small and 10 or 12;legend.TextSize=small and 9 or 11;hint.Visible=not short
  navigation.Caption.TextSize=small and 10 or 13
  journey.Visible=viewport.X>=1000 and not short
  area.Position=UDim2.fromOffset(18,short and 58 or 96)
  area.Size=UDim2.new(1,journey.Visible and -250 or -36,1,short and -142 or small and -280 or -232)
  detail.Position=UDim2.new(0,24,1,short and -82 or small and -178 or -130);detail.Size=UDim2.new(1,-48,0,short and 26 or 34)
  legend.Visible=not short
  legend.Position=UDim2.new(0,24,1,small and -144 or -94);hint.Position=UDim2.new(0,24,1,small and -126 or -73)
  local stacked=small and not short
  navigation.Position=UDim2.new(0,18,1,stacked and -108 or -52);navigation.Size=UDim2.new(1,stacked and -36 or -266,0,40)
  for index,control in ipairs({minus,plus,fit,you}) do
   control.Position=stacked and UDim2.new(0,18+({0,48,96,158})[index],1,-56) or UDim2.new(1,({-240,-192,-144,-82})[index],1,-52)
  end
  local available=area.AbsoluteSize
  if available.X<=0 or available.Y<=0 then return end
  local baseWidth=math.min(available.X,available.Y*atlas.aspect)
  if not overview and (viewport.X<1000 or short) then baseWidth=math.max(680,baseWidth) end
  local w=baseWidth*zoom;local h=w/atlas.aspect
  scene.Size=UDim2.fromOffset(w,h);scene.Position=UDim2.fromOffset(math.max(0,(available.X-w)/2),math.max(0,(available.Y-h)/2))
  area.CanvasSize=UDim2.fromOffset(math.max(w,available.X),math.max(h,available.Y))
  scene:SetAttribute('MapAspect',atlas.aspect);scene:SetAttribute('Zoom',zoom)
  -- Text stays readable while zooming. Fit is a geographic overview on phones.
  local font=w<650 and 10 or 12;local labelWidth=w<650 and 118 or 156
  for id,row in pairs(atlas.rows) do
   row.name.Visible=w>=550;row.status.Visible=w>=550;row.name.TextSize=font;row.name.Size=UDim2.fromOffset(labelWidth,32)
   row.badge.Text=w<550 and (id:match('DW%-(%d+)') or '◇') or (id:match('DW%-(%d+)') and string.format(Text.Map.Main,tonumber(id:match('DW%-(%d+)'))) or Text.Map.Side)
   if row.hit then
    row.hit.Size=w<550 and UDim2.fromOffset(28,28) or UDim2.fromOffset(labelWidth+8,48)
    row.hit.Position=w<550 and UDim2.fromScale(row.center.X,row.center.Y) or row.name.Position
   end
  end
 end
 area:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() if panel.Visible then task.defer(layout) end end)
 local function setZoom(value)
  local before=scene.AbsoluteSize;local view=area.AbsoluteSize;local old=area.CanvasPosition
  local center=Vector2.new((old.X+view.X/2-scene.Position.X.Offset)/math.max(1,before.X),(old.Y+view.Y/2-scene.Position.Y.Offset)/math.max(1,before.Y))
  overview=false;zoom=math.clamp(value,1,2.5);layout()
  area.CanvasPosition=Vector2.new(math.max(0,center.X*scene.Size.X.Offset-view.X/2),math.max(0,center.Y*scene.Size.Y.Offset-view.Y/2))
 end
 minus.Activated:Connect(function() setZoom(zoom-.5) end);plus.Activated:Connect(function() setZoom(zoom+.5) end)
 local function fitMap() overview=true;zoom=1;layout();area.CanvasPosition=Vector2.zero end
 fit.Activated:Connect(fitMap)
 local function centerPlayer()
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if not root then return end
  if overview then overview=false;layout() end
  local p=atlas.project(root.Position.X,root.Position.Z)
  area.CanvasPosition=Vector2.new(math.max(0,p.X*scene.Size.X.Offset-area.AbsoluteSize.X/2),math.max(0,p.Y*scene.Size.Y.Offset-area.AbsoluteSize.Y/2))
 end
 you.Activated:Connect(centerPlayer)
 local function refreshNavigation()
  local enabled=player:GetAttribute('TLTNavigationEnabled')~=false
  navigation.Caption.Text=enabled and Text.NavigationOn or Text.NavigationOff;navigation:SetAttribute('Enabled',enabled)
 end
 navigation.Activated:Connect(function() player:SetAttribute('TLTNavigationEnabled',player:GetAttribute('TLTNavigationEnabled')==false) end)
 player:GetAttributeChangedSignal('TLTNavigationEnabled'):Connect(refreshNavigation);refreshNavigation()
 local function open(value)
  value=value and State.current and not State.current.training and player:GetAttribute('K0SessionPhase')=='Tutorial'
  panel.Visible=value==true;player:SetAttribute('TLTMapOpen',panel.Visible)
  if panel.Visible then layout();task.defer(centerPlayer) end
 end
 if button then button.Activated:Connect(function() open(not panel.Visible) end) end
 close.Activated:Connect(function() open(false) end)
 UIS.InputBegan:Connect(function(input,processed)
  if not processed and input.KeyCode==Enum.KeyCode.M then open(not panel.Visible) end
 end)
 local elapsed=0;local lastRevision=-1
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  if player:GetAttribute('K0SessionPhase')~='Tutorial' or not State.current or State.current.training then open(false) end
  if not panel.Visible then return end
  local camera=workspace.CurrentCamera;local size=camera and camera.ViewportSize
  if size~=previousSize then previousSize=size;layout() end
  local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart');local human=c and c:FindFirstChildOfClass('Humanoid')
  atlas.update(State.current,root and human and human.Health>0 and root or nil,State.target)
  if lastRevision~=State.revision then
   lastRevision=State.revision;local discovered=0
   for _,row in pairs(atlas.rows) do discovered+=row.name:GetAttribute('ExploredPercent') or 0 end
   progress.Text=string.format(Text.Map.Progress,math.clamp(State.current.journal.main,0,7),math.floor(discovered/10))
   for i,item in ipairs(chapters) do
    local done=State.current.journal.main>=i;local active=State.current.journal.main==i-1
    item.status.Text=done and Text.Map.Complete or active and Text.Map.Current or Text.Map.Locked
    item.status.TextColor3=done and Theme.color.green or active and Theme.color.gold or Theme.color.muted
    item.button.BackgroundColor3=active and Color3.fromRGB(62,65,40) or Color3.fromRGB(23,45,48)
   end
   if selected then describe(selected) end
  end
 end)
 return {open=open,atlas=atlas,panel=panel,setZoom=setZoom,fit=fitMap,center=centerPlayer}
end
return Map
