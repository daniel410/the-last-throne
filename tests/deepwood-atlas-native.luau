-- Actual map construction/layout/projection with a Player facade and injected
-- viewport sizes. Native GUI geometry; synthetic discovery, no saved progress.
local Http=game:GetService('HttpService')
local client=game.StarterPlayer.StarterPlayerScripts.Client
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')
local report={kind='DEEPWOOD_ATLAS_NATIVE',checks=0,failures={}}
local function check(ok,message) report.checks+=1;assert(ok,message) end
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Progress=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local State=require(client.DeepwoodMapState)
local holder=Instance.new('Folder');holder.Name='AtlasQa';holder.Parent=workspace
local attributes=Instance.new('Folder');attributes.Parent=holder;attributes:SetAttribute('K0SessionPhase','Tutorial')
local char=Instance.new('Model');char.Parent=holder
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(table.unpack(Content.zones['DW-02'].center));root.Parent=char
local humanoid=Instance.new('Humanoid');humanoid.RequiresNeck=false;humanoid.Parent=char
local journal=Progress.new();journal.main=2;journal.explored={['DW-01']={['66']=true}}
State.set({journal=journal},root.Position)
local mock=[[local fixture=script.Fixture.Value
local attributes=fixture.Attributes.Value
local Players={LocalPlayer={Character=fixture.Character.Value,
 WaitForChild=function() return game:GetService('CoreGui') end,
 GetAttribute=function(_,key) return attributes:GetAttribute(key) end,
 SetAttribute=function(_,key,value) attributes:SetAttribute(key,value) end,
 GetAttributeChangedSignal=function(_,key) return attributes:GetAttributeChangedSignal(key) end}}
]]
local modules={}
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(667,317),Vector2.new(390,780)}) do
  attributes:SetAttribute('K0SessionPhase','Tutorial')
  local src,n=client.DeepwoodMap.Source:gsub("local Players=game:GetService%('Players'%)",function()return mock end);assert(n==1)
  src=src:gsub('local viewport=gui.AbsoluteSize',string.format('local viewport=Vector2.new(%d,%d)',size.X,size.Y))
  local m=Instance.new('ModuleScript');m.Name='AtlasQaMap';m.Source=src;m.Parent=client;table.insert(modules,m)
  local f=Instance.new('ObjectValue');f.Name='Fixture';f.Value=holder;f.Parent=m
  local av=Instance.new('ObjectValue');av.Name='Attributes';av.Value=attributes;av.Parent=holder
  local cv=Instance.new('ObjectValue');cv.Name='Character';cv.Value=char;cv.Parent=holder
  local map=require(m).start();map.open(true);task.wait(.4)
  local panel=map.panel;local atlas=panel.Atlas;local scene=atlas.Cartography
  check(panel.Visible,'adventure opens map')
  check(panel.Size.X.Offset<=size.X-24 and panel.Size.Y.Offset<=size.Y-24,'panel respects available safe area')
  check(math.abs(scene.Size.X.Offset/scene.Size.Y.Offset-map.atlas.aspect)<.02,'map preserves geographic aspect')
  local n=0;for _ in pairs(map.atlas.rows)do n+=1 end;check(n==10,'default shows seven main regions and three side regions')
  for _,name in ipairs({'Close','ZoomIn','ZoomOut','Fit','Center','NavigationTrail'}) do
   local b=panel[name];check(b.Position.Y.Scale*panel.AbsoluteSize.Y+b.Position.Y.Offset>=0,name..' stays inside panel vertically')
   check(b.AbsoluteSize.X>=40 and b.AbsoluteSize.Y>=40,name..' keeps a usable target')
  end
  check(map.atlas.pin.Visible and map.atlas.objective.Visible,'living player and objective remain visible')
  map.setZoom(2.5);task.wait(.1);map.center();task.wait(.1)
  check(scene:GetAttribute('Zoom')==2.5,'zoom reaches maximum')
  check(map.atlas.rows['DW-02']~=nil,'YOU uses player epic')
  map.fit();task.wait(.1)
  check(atlas.CanvasPosition==Vector2.zero,'FIT resets pan')
  check(scene.Size.Y.Offset<=atlas.AbsoluteSize.Y+1,'FIT shows the full north/south extent')
  map.atlas.select('DW-07')
  check(panel.RegionDetail.Text:find(Content.zones['DW-06'].name,1,true)~=nil,'locked selection explains the real prerequisite')
  for epic=1,5 do
   map.selectEpic(epic);task.wait(.1)
   local n=0;local first=(epic-1)*7+1
   for id in pairs(map.atlas.rows)do
    n+=1
    check(require(game.ReplicatedStorage.Shared.CampaignMapScope).epicFor(id)==epic,'map contains only selected epic regions')
   end
   check(n==(epic<=3 and 10 or 7),'epic includes optional regions where authored')
   local visible=0
   for _,b in ipairs(panel.Journey:GetChildren())do if b:IsA('TextButton')and b.Visible then visible+=1 end end
   check(visible==7,'journey lists seven selected stories')
   check(panel.Subtitle.Text:find(Content.epics[epic].region:upper(),1,true)~=nil,'subtitle follows epic')
   check(panel.Progress.Text:find('/ 7 STORIES',1,true)~=nil,'progress denominator is selected epic')
   check(scene.Size.Y.Offset<=atlas.AbsoluteSize.Y+1,'epic switch fits seven regions')
   check(panel.EpicCategories.AbsoluteSize.Y>=42,'epic selector touch height')
  end
  map.center();task.wait(.1);check(map.atlas.rows['DW-02']~=nil,'YOU returns from a different epic')
  root.Position=Vector3.new(table.unpack(Content.zones['HG-03'].center));map.open(true);task.wait(.1)
  check(map.atlas.rows['HG-03']~=nil and map.atlas.rows['DW-01']==nil,'opening selects actual player epic')
  -- Reproduce active Waterfall Quarry after completing the seven Deepwood stories.
  local side=Progress.copy(journal);side.main=7;side.expeditionMission='DW-Q3'
  side.explored['DW-S2']={['66']=true};side.accepted={['DW-Q3']=true}
  root.Position=Vector3.new(table.unpack(Content.zones['DW-S2'].center))
  State.set({journal=side},root.Position);map.open(true);task.wait(.4)
  local row=map.atlas.rows['DW-S2'];check(row~=nil,'active quarry area is drawn instead of blank map')
  check(row.name:GetAttribute('Accessible')==true,'active side region is accessible')
  check(row.cells[66].BackgroundTransparency==1,'saved explored side cell is visible')
  check(map.atlas.pin.Visible and map.atlas.objective.Visible,'side area player and target remain on map')
  local point=map.atlas.project(root.Position.X,root.Position.Z)
  check(point.X>0 and point.X<1 and point.Y>0 and point.Y<1,'quarry coordinates fit complete epic bounds')
  State.set({journal=journal},Vector3.new(table.unpack(Content.zones['DW-02'].center)))
  root.Position=Vector3.new(table.unpack(Content.zones['DW-02'].center))
  map.open(false);check(not attributes:GetAttribute('TLTMapOpen'),'closing restores combat input gate')
  attributes:SetAttribute('K0SessionPhase','Lobby');panel.Parent:Destroy();av:Destroy();cv:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
attributes:SetAttribute('K0SessionPhase','Lobby');State.set(nil,nil)
for _,m in ipairs(modules) do m:Destroy() end
holder:Destroy();report.pass=#report.failures==0
print('DEEPWOOD_ATLAS_NATIVE '..Http:JSONEncode(report));assert(report.pass,'Atlas QA failed')
