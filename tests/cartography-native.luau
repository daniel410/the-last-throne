-- Real native GUI and campaign projection; isolated data only, no player saves.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'local QA only')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Survey=require(game.ReplicatedStorage.Shared.CampaignCartography)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Canvas=require(Client.DeepwoodMapCanvas)
local State=require(Client.DeepwoodMapState)
local Scope=require(game.ReplicatedStorage.Shared.CampaignMapScope)
local report={checks=0,zones=0,footprints=0,roads=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='CartographyQA';gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=game.CoreGui
local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(900,650);frame.Parent=gui
local journal={main=35,version=2,explored={}}
for id,z in pairs(C.zones)do
 local s=Survey.zones[id];check(s~=nil,'survey exists '..id);report.zones+=1
 check(#s.rects>0 and #s.roads>0,'actual scenery and curved roads '..id)
 for _,r in ipairs(s.rects)do
  check(r[1]>=0 and r[2]>=0 and r[1]+r[3]<=Survey.resolution and r[2]+r[4]<=Survey.resolution,'bounded footprint '..id)
 end
 journal.explored[id]={};for i=1,144 do journal.explored[id][tostring(i)]=true end
 report.footprints+=#s.rects;report.roads+=#s.roads
end
for epic=1,5 do
 frame:ClearAllChildren()
 local atlas=Canvas.create(frame,Scope.ids(epic),false);atlas.update({journal=journal});task.wait()
 for id,row in pairs(atlas.rows)do
  check(row.landmark.Text==Survey.zones[id].landmark,'real landmark caption '..id)
  local anchor=Survey.zones[id].landmarkAnchor
  if anchor then
   local at=atlas.project(anchor[1],anchor[2])
   check((Vector2.new(row.landmark.Position.X.Scale,row.landmark.Position.Y.Scale)-at).Magnitude<.00001,'landmark at actual TD hero mesh '..id)
  end
  check(row.checkpoint.Visible,'discovered real spawn '..id)
  local p=atlas.project(table.unpack({Survey.zones[id].spawn[1],Survey.zones[id].spawn[2]}))
  check((Vector2.new(row.checkpoint.Position.X.Scale,row.checkpoint.Position.Y.Scale)-p).Magnitude<.00001,'checkpoint at actual spawn '..id)
 end
end
for _,size in ipairs({Vector2.new(1000,750),Vector2.new(667,317),Vector2.new(390,780)})do
 frame:ClearAllChildren();frame.Size=UDim2.fromOffset(size.X,size.Y)
 local lobby=require(Client.LobbyAtlas).create(frame);lobby.show({heroId='h',heroes={h={deepwood=journal}}});task.wait()
 for epic=1,5 do
  lobby.selectEpic(epic);task.wait()
  for id in pairs(lobby.rows())do check(C.zones[id].epic==epic,'lobby uses canonical campaign order')end
 end
end
frame:ClearAllChildren();frame.Size=UDim2.fromOffset(1000,750)
local character=Instance.new('Model');local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character
local minimap=require(Client.BattleMinimap).create(frame)
for _,id in ipairs({'DW-03','GW-03','FV-02','EC-04','HG-07'})do
 local z=C.zones[id];root.Position=Vector3.new(table.unpack(z.center));State.set({journal=journal},root.Position)
 minimap.update(character);task.wait(.12);minimap.update(character)
 local preview=minimap.frame.MapPreview
 local p=minimap.project(root.Position)
 check(p.Magnitude<.00001,'minimap center agrees with atlas '..id)
 root.Position+=Vector3.new(z.size[1]*.2,0,-z.size[2]*.2);task.wait(.12);minimap.update(character)
 local drawn=minimap.frame.PlayerMarker.Position
 local q=minimap.project(root.Position)
 check(math.abs(drawn.X.Scale-(.5+q.X))<.00001 and math.abs(drawn.Y.Scale-(.5+q.Y))<.00001,'player marker uses same transform '..id)
 check(preview:FindFirstChild('SurveyFootprint')~=nil,'compact map retains architecture '..id)
 check(preview:FindFirstChild('SurveyTrail')~=nil,'compact map retains curved roads '..id)
 for _,tile in ipairs(preview:GetChildren())do
  if tile.Name=='SurveyFootprint' or tile.Name=='SurveyGround_'..id then
   for _,dx in ipairs({-.5,.5})do for _,dy in ipairs({-.5,.5})do
    local corner=Vector2.new(tile.Position.X.Scale+tile.Size.X.Scale*dx-.5,tile.Position.Y.Scale+tile.Size.Y.Scale*dy-.5)
    check(corner.Magnitude<=.49001,'survey footprint stays inside circular minimap')
   end end
  end
 end
end
-- HUD UIScale must not scale the road length a second time.
frame:ClearAllChildren();frame.Size=UDim2.fromOffset(500,500)
local scale=Instance.new('UIScale');scale.Scale=.6;scale.Parent=frame
local atlas=Canvas.create(frame,'FV-02',false);task.wait();atlas.update({journal=journal});task.wait()
local road=frame:FindFirstChild('SurveyTrail');local source=Survey.zones['FV-02'].roads[1]
local a,b=atlas.project(source[1],source[2]),atlas.project(source[3],source[4])
local expected=Vector2.new((b.X-a.X)*frame.AbsoluteSize.X,(b.Y-a.Y)*frame.AbsoluteSize.Y).Magnitude
check(math.abs(road.AbsoluteSize.X-expected)<1,'HUD scale preserves surveyed road length')
character:Destroy();gui:Destroy()
print('CARTOGRAPHY_QA '..game.HttpService:JSONEncode(report))
