-- Real native GUI and campaign projection; isolated data only, no player saves.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'local QA only')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local Survey=require(game.ReplicatedStorage.Shared.CampaignCartography)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Canvas=require(Client.DeepwoodMapCanvas)
local State=require(Client.DeepwoodMapState)
local Scope=require(game.ReplicatedStorage.Shared.CampaignMapScope)
local report={checks=0,zones=0,footprints=0,roads=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='CartographyQA';gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=game.CoreGui
local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(900,650);frame.Parent=gui
local journal={main=35,version=2,explored={},clears={}}
for _,chapter in ipairs(C.chapters)do journal.clears[chapter.id]=true end
for id,z in pairs(C.zones)do
 local s=Survey.zones[id];check(s~=nil,'survey exists '..id);report.zones+=1
 check(#s.rects>0 and #s.roads>0,'actual scenery and curved roads '..id)
 for _,r in ipairs(s.rects)do
  check(r[1]>=0 and r[2]>=0 and r[1]+r[3]<=Survey.resolution and r[2]+r[4]<=Survey.resolution,'bounded footprint '..id)
 end
 journal.explored[id]={};for i=1,144 do journal.explored[id][tostring(i)]=true end
 report.footprints+=#s.rects;report.roads+=#s.roads
end
local markerRoot=Instance.new('Part');markerRoot.Anchored=true
for epic=1,5 do
 frame:ClearAllChildren()
 local atlas=Canvas.create(frame,Scope.ids(epic),false);atlas.update({journal=journal});task.wait()
 check(#atlas.exits==((epic==1 or epic==5)and 1 or 2),'adjacent road count')
 for _,exit in ipairs(atlas.exits)do
  local link=exit.link
  local p=atlas.project(link.finish[1],link.finish[3])
  check(p.X>0 and p.X<1 and p.Y>0 and p.Y<1,'road destination inside atlas')
  check(exit.button:GetAttribute('Accessible')==true,'completed road open')
  check(exit.button.Caption.Text:find(C.epics[link.epic].region:upper(),1,true)~=nil,'named next epic')
  atlas.update({journal={main=(math.max(epic,link.epic)-1)*7-1}})
  check(exit.button:GetAttribute('Accessible')==false,'road locked before predecessor completion')
  atlas.update({journal=journal})
 end
 for id,row in pairs(atlas.rows)do
  check(row.landmark.Text==Survey.zones[id].landmark,'real landmark caption '..id)
  local anchor=Survey.zones[id].landmarkAnchor
  if anchor then
   local at=atlas.project(anchor[1],anchor[2])
   check((Vector2.new(row.landmark.Position.X.Scale,row.landmark.Position.Y.Scale)-at).Magnitude<.00001,'landmark at actual TD hero mesh '..id)
  end
  check(row.checkpoint.Visible,'completed region spawn '..id)
  local p=atlas.project(table.unpack({Survey.zones[id].spawn[1],Survey.zones[id].spawn[2]}))
  check((Vector2.new(row.checkpoint.Position.X.Scale,row.checkpoint.Position.Y.Scale)-p).Magnitude<.00001,'checkpoint at actual spawn '..id)
  markerRoot.CFrame=CFrame.new(Vector3.new(table.unpack(C.zones[id].center)))*CFrame.Angles(0,math.pi/2,0)
  atlas.update({journal=journal},markerRoot)
  check(atlas.pin.Visible and atlas.youLabel.Visible and atlas.youLabel.Text=='YOU','detailed map identifies the local player '..id)
  check(atlas.youLabel.Rotation==0 and math.abs(atlas.pin.Rotation)>1,'YOU stays upright when heading changes '..id)
  check(atlas.youLabel.Position.X.Scale==atlas.pin.Position.X.Scale and atlas.youLabel.Position.Y.Scale==atlas.pin.Position.Y.Scale,'YOU follows the projected player position '..id)
 end
 atlas.update({journal=journal},nil);check(not atlas.pin.Visible and not atlas.youLabel.Visible,'missing/respawning player removes both markers')
end
markerRoot:Destroy()
gui:Destroy()
print('EPIC_MAP_CONNECTIONS_QA '..game.HttpService:JSONEncode(report))
