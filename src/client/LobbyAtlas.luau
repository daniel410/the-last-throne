-- Read-only lobby atlas using the battle cartography and server snapshot progress.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Progress=require(Shared.DeepwoodProgress)
local T=require(script.Parent.TDInventoryTheme)
local Canvas=require(script.Parent.DeepwoodMapCanvas)
local Survey=require(Shared.CampaignCartography)
local M={}
local epics={}
for _,epic in ipairs(Content.epics)do table.insert(epics,{epic.region,epic.hub:sub(1,3)})end
function M.create(parent)
 local root=Instance.new('Frame');root.Name='LobbyAtlas';root.Position=UDim2.fromOffset(16,60);root.Size=UDim2.new(1,-32,1,-72);root.BackgroundTransparency=1;root.Visible=false;root.Parent=parent
 local tabs=Instance.new('ScrollingFrame');tabs.Name='EpicCategories';tabs.Size=UDim2.new(1,0,0,48);tabs.BackgroundTransparency=1;tabs.BorderSizePixel=0;tabs.ScrollBarThickness=3;tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.CanvasSize=UDim2.fromOffset(#epics*174,0);tabs.Parent=root
 local area=Instance.new('ScrollingFrame');area.Name='Atlas';area.Position=UDim2.fromOffset(0,78);area.Size=UDim2.new(1,0,1,-154);area.BackgroundColor3=Color3.fromRGB(12,26,31);area.BorderSizePixel=0;area.ScrollBarThickness=5;area.CanvasSize=UDim2.new();area.Parent=root
 local scene=Instance.new('Frame');scene.Name='Cartography';scene.BackgroundTransparency=1;scene.Parent=area
 local summary=T.label(root,'Progress','',UDim2.fromOffset(2,51),UDim2.new(1,-158,0,23),11,T.color.gold)
 local fit=T.button(root,'Fit','FIT',UDim2.new(1,-150,0,50),UDim2.fromOffset(64,24))
 local zoomButton=T.button(root,'Zoom','ZOOM',UDim2.new(1,-80,0,50),UDim2.fromOffset(80,24))
 local detail=T.label(root,'RegionDetail','',UDim2.new(0,4,1,-70),UDim2.new(1,-8,0,46),12,T.color.gold)
 local hint=T.label(root,'Hint','Select a region for unlock details. Drag to explore the map.',UDim2.new(0,4,1,-23),UDim2.new(1,-8,0,22),10,T.color.muted)
 local buttons,snapshot,atlas,selected={},nil,nil,nil
 local epic,zoom,overview=1,1,false
 local resizeChrome
 local function hero()return snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]end
 local function journal()local h=hero();return h and (h.deepwood or Progress.new())or {main=-1,explored={}}end
 local function describe(id)
  selected=id;local z=Content.zones[id];local j=journal()
  local status
  if not hero()then status='Select a hero to view unlock progress.'
  elseif not Access.allowed(j,id)then
   local previous=Content.mainChapters[z.requiresMain]
   status=previous and 'LOCKED · Complete '..previous.title..' to unlock.'or 'LOCKED'
  elseif j.clears and j.clears[id]then status='COMPLETED · Enter an adventure to revisit.'
  else status='OPEN · Enter an adventure to explore.'end
  detail.Text=z.name..' / '..Survey.zones[id].landmark..' · '..status
  if resizeChrome then resizeChrome()end
 end
 resizeChrome=function()
  local width,height=root.AbsoluteSize.X,root.AbsoluteSize.Y
  local landscape=height<360 and width>=450
  local narrow=width<600
  local footer=math.max(46,math.ceil(game:GetService('TextService'):GetTextSize(detail.Text,12,detail.Font,Vector2.new(math.max(1,width-(landscape and 160 or 8)),10000)).Y)+8)
  hint.Visible=not landscape and not narrow
  summary.Visible=not landscape
  if landscape then
   tabs.Position=UDim2.new();tabs.Size=UDim2.new(0,144,1,0)
   tabs.ScrollingDirection=Enum.ScrollingDirection.Y;tabs.CanvasSize=UDim2.fromOffset(0,#epics*50)
   for i,b in ipairs(buttons)do b.Position=UDim2.fromOffset(0,(i-1)*50);b.Size=UDim2.fromOffset(138,44)end
   area.Position=UDim2.fromOffset(152,0);area.Size=UDim2.new(1,-244,1,-footer-8)
   detail.Position=UDim2.new(0,152,1,-footer);detail.Size=UDim2.new(1,-152,0,footer)
   fit.Position=UDim2.new(1,-84,0,0);zoomButton.Position=UDim2.new(1,-84,0,50)
   fit.Size=UDim2.fromOffset(84,44);zoomButton.Size=UDim2.fromOffset(84,44)
  else
   tabs.Position=UDim2.new();tabs.Size=UDim2.new(1,0,0,48)
   tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.CanvasSize=UDim2.fromOffset(#epics*174,0)
   for i,b in ipairs(buttons)do b.Position=UDim2.fromOffset((i-1)*174,0);b.Size=UDim2.fromOffset(168,44)end
   summary.Position=UDim2.fromOffset(2,50);summary.Size=UDim2.new(1,narrow and -4 or -184,0,44)
   local y=narrow and 98 or 50
   fit.Position=UDim2.new(1,-178,0,y);zoomButton.Position=UDim2.new(1,-88,0,y)
   fit.Size=UDim2.fromOffset(84,44);zoomButton.Size=UDim2.fromOffset(88,44)
   local top=narrow and 150 or 102
   local bottom=footer+(hint.Visible and 26 or 0)
   area.Position=UDim2.fromOffset(0,top);area.Size=UDim2.new(1,0,1,-top-bottom-8)
   detail.Position=UDim2.new(0,4,1,-bottom);detail.Size=UDim2.new(1,-8,0,footer)
  end
 end
 local function layout()
  resizeChrome()
  if not atlas then return end
  local w,h=math.max(1,area.AbsoluteSize.X),math.max(1,area.AbsoluteSize.Y)
  local width=math.max(w,h*atlas.aspect)*zoom
  -- Region names remain legible; drag scrolls a large epic on small displays.
  width=overview and math.min(w,h*atlas.aspect)or math.max(width,900)
  for _,row in pairs(atlas.rows)do row.name.Visible=not overview;row.status.Visible=not overview;row.landmark.Visible=not overview end
  scene.Size=UDim2.fromOffset(width,width/atlas.aspect);scene.Position=UDim2.fromOffset(math.max(0,(w-width)/2),math.max(0,(h-width/atlas.aspect)/2));area.CanvasSize=UDim2.fromOffset(math.max(w,width),math.max(h,width/atlas.aspect))
  atlas.update({journal=journal()},nil,nil)
 end
 local function render()
  for _,v in ipairs(scene:GetChildren())do v:Destroy()end
  atlas=nil;selected=nil;area.CanvasPosition=Vector2.zero
  local spec=epics[epic];local j=journal();local ids={};local count,opened=0,0
  for i,b in ipairs(buttons)do
   local prefix=epics[i][2];local available=false
   if prefix and hero()then for id in pairs(Content.zones)do if id:sub(1,3)==prefix and Access.allowed(j,id)then available=true;break end end end
   b.Caption.Text=(i==epic and '> 'or '')..epics[i][1]:upper()..(not prefix and '\nLOCKED · COMING SOON' or not available and '\nLOCKED'or '')
  end
  if not spec[2]then
   summary.Text='LOCKED · COMING SOON';detail.Text=spec[1]..' is a future expedition. Its story map is not available yet.';return
  end
  for id in pairs(Content.zones)do if id:sub(1,3)==spec[2]then ids[id]=true;count+=1;if Access.allowed(j,id)then opened+=1 end end end
  summary.Text=string.format('%s · %d / %d REGIONS OPEN',spec[1]:upper(),opened,count)
  atlas=Canvas.create(scene,ids,false,describe);layout()
  local first=spec[2]..'01';atlas.select(first)
 end
 for i,spec in ipairs(epics)do
  local b=T.button(tabs,'Epic'..i,spec[1]:upper(),UDim2.fromOffset((i-1)*174,0),UDim2.fromOffset(168,44));b.Caption.TextSize=10;buttons[i]=b
  b.Activated:Connect(function()epic=i;zoom=1;overview=root.AbsoluteSize.Y<360 or root.AbsoluteSize.X<600;render()end)
 end
 root:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 area:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()if atlas then layout()end end)
 fit.Activated:Connect(function()zoom=1;overview=true;layout();area.CanvasPosition=Vector2.zero end)
 zoomButton.Activated:Connect(function()overview=false;zoom=zoom==1 and 1.5 or 1;layout()end)
 return {root=root,show=function(s)snapshot=s;root.Visible=true;overview=root.AbsoluteSize.Y<360 or root.AbsoluteSize.X<600;render()end,update=function(s)snapshot=s;if root.Visible then render()end end,
  selectEpic=function(i)if epics[i]then epic=i;zoom=1;overview=root.AbsoluteSize.Y<360 or root.AbsoluteSize.X<600;render()end end,
  selectRegion=function(id)if atlas and atlas.rows[id]then atlas.select(id)end end,
  rows=function()return atlas and atlas.rows or {}end}
end
return M
