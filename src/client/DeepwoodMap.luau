local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local Shared=game:GetService('ReplicatedStorage').Shared
local Theme=require(script.Parent.TDInventoryTheme)
local Text=require(Shared.K0Text)
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local State=require(script.Parent.DeepwoodMapState)
local Canvas=require(script.Parent.DeepwoodMapCanvas)
local Scope=require(Shared.CampaignMapScope)
local Checkpoints=require(Shared.CheckpointTravel)
local Map={}
function Map.start(button)
 local player=Players.LocalPlayer
 local gui=Instance.new('ScreenGui');gui.Name='DeepwoodWorldMap';gui.ResetOnSpawn=false;gui.DisplayOrder=43;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local panel=Theme.frame(gui,'WorldMap',UDim2.fromScale(.5,.5),UDim2.fromOffset(1100,800));panel.AnchorPoint=Vector2.new(.5,.5);panel.BackgroundTransparency=.05;panel.Visible=false
 local title=Theme.label(panel,'Title',Text.Map.Title,UDim2.fromOffset(22,12),UDim2.new(1,-88,0,30),21,Theme.color.gold)
 local subtitle=Theme.label(panel,'Subtitle',Text.Map.Subtitle,UDim2.fromOffset(24,43),UDim2.new(1,-90,0,18),10,Theme.color.muted)
 local progress=Theme.label(panel,'Progress','',UDim2.fromOffset(24,66),UDim2.new(1,-48,0,20),12,Theme.color.text)
 local close=Theme.button(panel,'Close','X',UDim2.new(1,-60,0,12),UDim2.fromOffset(44,44))
 local area=Instance.new('ScrollingFrame');area.Name='Atlas';area.Position=UDim2.fromOffset(18,96);area.Size=UDim2.new(1,-36,1,-232)
 area.BackgroundColor3=Color3.fromRGB(16,33,34);area.BorderSizePixel=0;area.ClipsDescendants=true;area.ScrollBarThickness=4;area.ScrollBarImageColor3=Theme.color.gold;area.Parent=panel
 local scene=Instance.new('Frame');scene.Name='Cartography';scene.BackgroundTransparency=1;scene.BorderSizePixel=0;scene.Parent=area
 local selected,travelTarget,updateTravel,layout
 local detail=Theme.label(panel,'RegionDetail',Text.Map.Ready,UDim2.new(0,24,1,-130),UDim2.new(1,-48,0,34),12,Theme.color.gold)
 local function describe(id)
  selected=id;local z=Content.zones[id];local journal=State.current and State.current.journal
  local message=Text.Map.Discover
  if journal and not Access.allowed(journal,id) then
   local previous=Content.mainChapters[z.requiresMain]
   message=string.format(Text.Map.Unlock,previous and previous.title or Text.Map.Title)
  elseif journal and journal.explored and journal.explored[id] then message=Text.Map.Ready end
  detail.Text=string.format(Text.Map.Detail,z.name,message)
  if updateTravel then updateTravel();if layout then layout()end end
 end
 local epic=1
 local atlas=Canvas.create(scene,Scope.ids(epic),false,describe)
 local controller
 local epicTabs=Instance.new('ScrollingFrame');epicTabs.Name='EpicCategories';epicTabs.BackgroundTransparency=1;epicTabs.BorderSizePixel=0;epicTabs.ScrollBarThickness=3;epicTabs.ScrollingDirection=Enum.ScrollingDirection.X;epicTabs.CanvasSize=UDim2.fromOffset(#Content.epics*174,0);epicTabs.Parent=panel
 local epicButtons={}
 local journey=Instance.new('ScrollingFrame');journey.AutomaticCanvasSize=Enum.AutomaticSize.None;journey.CanvasSize=UDim2.fromOffset(0,532);journey.ScrollBarThickness=4;journey.Name='Journey';journey.BackgroundColor3=Color3.fromRGB(12,26,32);journey.BackgroundTransparency=.15;journey.BorderSizePixel=0;journey.Position=UDim2.new(1,-214,0,96);journey.Size=UDim2.new(0,196,1,-232);journey.Parent=panel
 Theme.label(journey,'Title',Text.Map.Journey,UDim2.fromOffset(14,12),UDim2.new(1,-28,0,20),13,Theme.color.gold)
 Theme.label(journey,'Hint',Text.Map.JourneyHint,UDim2.fromOffset(14,36),UDim2.new(1,-28,0,30),10,Theme.color.muted)
 local chapters={}
 local journeyHint=journey.Hint
 for i=1,Content.mainCount do
  local id=Content.mainChapters[i].id;local item=Instance.new('TextButton');item.Name='Story'..i;item.Text='';item.AutoLocalize=false;item.BackgroundColor3=Color3.fromRGB(23,45,48);item.BackgroundTransparency=.2;item.BorderSizePixel=0
  item.Position=UDim2.fromOffset(10,70+(i-1)*66);item.Size=UDim2.new(1,-20,0,60);item.Parent=journey
  local name=Theme.label(item,'Name',string.format('%02d  %s',i,Content.zones[id].name),UDim2.fromOffset(10,2),UDim2.new(1,-20,.65,-2),11,Theme.color.text)
  local status=Theme.label(item,'Status','',UDim2.new(0,10,.65,0),UDim2.new(1,-20,.35,-2),9,Theme.color.muted)
  item.Activated:Connect(function() atlas.select(id) end);chapters[i]={button=item,name=name,status=status}
 end
 local compass=Theme.label(panel,'Compass',Text.Map.North..'\n↑',UDim2.new(1,-270,0,150),UDim2.fromOffset(36,40),16,Theme.color.gold);compass.AnchorPoint=Vector2.new(.5,.5);compass.TextXAlignment=Enum.TextXAlignment.Center;compass.ZIndex=8
 local legend=Theme.label(panel,'Legend',Text.Map.Legend,UDim2.new(0,24,1,-94),UDim2.new(1,-48,0,20),11)
 local hint=Theme.label(panel,'MapHint',Text.Map.Hint,UDim2.new(0,24,1,-73),UDim2.new(1,-48,0,18),10,Theme.color.muted)
 local navigation=Theme.button(panel,'NavigationTrail','',UDim2.new(0,18,1,-52),UDim2.new(1,-266,0,40))
 local minus=Theme.button(panel,'ZoomOut',Text.Map.ZoomOut,UDim2.new(1,-240,1,-52),UDim2.fromOffset(44,40))
 local plus=Theme.button(panel,'ZoomIn',Text.Map.ZoomIn,UDim2.new(1,-192,1,-52),UDim2.fromOffset(44,40))
 local fit=Theme.button(panel,'Fit',Text.Map.Fit,UDim2.new(1,-144,1,-52),UDim2.fromOffset(58,40))
 local you=Theme.button(panel,'Center',Text.Map.Center,UDim2.new(1,-82,1,-52),UDim2.fromOffset(64,40))
 local travel=Theme.button(panel,'TravelCheckpoint','',UDim2.new(.55,0,1,-136),UDim2.new(.45,-24,0,40),true)
 travel.Visible=false
 updateTravel=function()
  travelTarget=State.current and not State.current.training and Checkpoints.preferred(State.current.journal,selected)
  travel.Visible=travelTarget~=nil and travelTarget~=false
  travel.Caption.Text=travelTarget and string.format(Checkpoints.text.button,travelTarget.title)or ''
  travel.Caption.TextSize=11
 end
 travel.Activated:Connect(function()
  if not travelTarget then return end
  game:GetService('ReplicatedStorage'):WaitForChild('Remotes'):WaitForChild('DeepwoodRequest'):FireServer('TravelCheckpoint',travelTarget.id)
  panel.Visible=false;player:SetAttribute('TLTMapOpen',false)
 end)
 local zoom=1;local overview=false;local previousSize
 layout=function()
  local camera=workspace.CurrentCamera;if not camera then return end
  local viewport=gui.AbsoluteSize
  panel.Size=UDim2.fromOffset(math.min(1100,viewport.X-24),math.min(900,viewport.Y-24))
  local small=viewport.X<650;local short=viewport.Y<540
  title.TextSize=small and 16 or 21
  panel.Subtitle.Visible=not short;progress.Position=UDim2.fromOffset(24,short and 36 or 66)
  detail.TextSize=small and 10 or 12;legend.TextSize=small and 9 or 11;hint.Visible=not short
  navigation.Caption.TextSize=small and 10 or 13
  journey.Visible=viewport.X>=1000 and not short
  epicTabs.Position=UDim2.fromOffset(18,short and 60 or 96);epicTabs.Size=UDim2.new(1,-36,0,46)
  local mapTop=short and 112 or 148
  area.Position=UDim2.fromOffset(18,mapTop)
  journey.Position=UDim2.new(1,-214,0,mapTop);journey.Size=UDim2.new(0,196,1,-284)
  compass.Position=UDim2.new(1,journey.Visible and -285 or -72,0,mapTop+22)
  area.Size=UDim2.new(1,journey.Visible and -250 or -36,1,short and -212 or small and -332 or -284)
  detail.Position=UDim2.new(0,24,1,short and -82 or small and -178 or -130);detail.Size=UDim2.new(1,-48,0,short and 26 or 34)
  detail.Visible=not (travel.Visible and (small or short))
  detail.Size=UDim2.new(travel.Visible and .55 or 1,-48,0,short and 26 or 34)
  travel.Position=UDim2.new((small or short)and 0 or .55,(small or short)and 18 or 0,1,short and -98 or small and -184 or -136)
  travel.Size=UDim2.new((small or short)and 1 or .45,(small or short)and -36 or -24,0,40)
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
  local showNames=not short and not small
  for id,row in pairs(atlas.rows) do
   row.name.Visible=showNames;row.status.Visible=showNames;row.name.TextSize=font;row.name.Size=UDim2.fromOffset(labelWidth,32)
   local number=Content.byId[id] and Content.byId[id].number
   row.badge.Text=w<550 and string.format('%02d',(number-1)%7+1) or string.format(Text.Map.Main,(number-1)%7+1)
   if row.hit then
    row.hit.Size=not showNames and UDim2.fromOffset(28,28) or UDim2.fromOffset(labelWidth+8,48)
    row.hit.Position=not showNames and UDim2.fromScale(row.center.X,row.center.Y) or row.name.Position
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
 local function refreshEpic()
  local journal=State.current and State.current.journal or {main=0}
  local discovered,count=0,0
  for _,row in pairs(atlas.rows) do discovered+=row.name:GetAttribute('ExploredPercent') or 0;count+=1 end
  local first,last=Scope.range(epic)
  progress.Text=string.format(Text.Map.EpicProgress,math.clamp(journal.main-first+1,0,last-first+1),last-first+1,math.floor(discovered/math.max(1,count)))
  subtitle.Text=string.format(Text.Map.EpicSubtitle,epic,Content.epics[epic].region:upper())
  journeyHint.Text=Text.Map.EpicJourneyHint
  for i,item in ipairs(chapters) do
   item.button.Visible=i>=first and i<=last
   if item.button.Visible then item.button.Position=UDim2.fromOffset(10,70+(i-first)*66);item.name.Text=string.format('%02d  %s',i-first+1,Content.zones[Content.mainChapters[i].id].name) end
   local done=journal.main>=i;local active=journal.main==i-1
   item.status.Text=done and Text.Map.Complete or active and Text.Map.Current or Text.Map.Locked
   item.status.TextColor3=done and Theme.color.green or active and Theme.color.gold or Theme.color.muted
   item.button.BackgroundColor3=active and Color3.fromRGB(62,65,40) or Color3.fromRGB(23,45,48)
  end
  for i,b in ipairs(epicButtons) do b.Caption.Text=(i==epic and '> ' or '')..Content.epics[i].region:upper();b:SetAttribute('Selected',i==epic) end
 end
 local function selectEpic(index)
  if not Content.epics[index] then return end
  epic=index;selected=nil;scene:ClearAllChildren()
  atlas=Canvas.create(scene,Scope.ids(epic),false,describe)
  if controller then controller.atlas=atlas end
  journey.CanvasPosition=Vector2.zero
  atlas.update(State.current,nil,nil);refreshEpic();fitMap()
  local first,last=Scope.range(epic);local main=State.current and State.current.journal.main or 0;atlas.select(Content.mainChapters[math.clamp(main+1,first,last)].id)
  epicTabs.CanvasPosition=Vector2.new(math.max(0,(epic-1)*174-epicTabs.AbsoluteSize.X/2+84),0)
 end
 for i,spec in ipairs(Content.epics) do
  local b=Theme.button(epicTabs,'Epic'..i,spec.region:upper(),UDim2.fromOffset((i-1)*174,0),UDim2.fromOffset(168,42));b.Caption.TextSize=10;epicButtons[i]=b
  b.Activated:Connect(function()selectEpic(i)end)
 end
 local function playerEpic()
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if root then return Scope.epicFor(Access.region(root.Position.X,root.Position.Z)) end
  return math.clamp(math.floor((State.current and State.current.journal.main or 0)/7)+1,1,#Content.epics)
 end
 local function centerPlayer()
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if not root then return end
  local currentEpic=playerEpic();if epic~=currentEpic then selectEpic(currentEpic) end
  layout()
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
  if panel.Visible then selectEpic(playerEpic());updateTravel();layout() end
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
  atlas.update(State.current,root and human and human.Health>0 and root or nil,State.target,State.party())
  if lastRevision~=State.revision then
   lastRevision=State.revision;refreshEpic()
   if selected then describe(selected) end
   updateTravel();layout()
  end
 end)
 controller={open=open,atlas=atlas,panel=panel,setZoom=setZoom,fit=fitMap,center=centerPlayer,selectEpic=selectEpic}
 return controller
end
return Map
