-- Offline engine audit. Never run against a published or player-owned session.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')
local V=Vector3.new
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
-- Match the production hub storage placement, which is added after world art.
for epic,info in ipairs(C.epics)do
 local offset=epic==1 and V(-55,0,-10)or V(45,0,epic==3 and 75 or 80)
 local chest=require(game.ServerScriptService.Server.World.StorageChest).create({folder=world.folder,origin=world.positions[info.hub]+offset})
 chest.Parent.Name=info.hub..'AccountStorage'
end
local report={zones={},roads=0,roadSamples=0,anchors=0,obstacles={},floorIssues={},anchorIssues={}}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world.folder}
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local function xyz(p)return {p.X,p.Y,p.Z}end
local probe=Instance.new('Part');probe.Name='TraversalAuditProbe';probe.Size=V(4,5,4);probe.Anchored=true;probe.CanCollide=false;probe.CanQuery=false;probe.CanTouch=false;probe.Transparency=1;probe.Parent=workspace
local function body(p,label,anchor)
 probe.CFrame=CFrame.new(p+V(0,3.7,0))
 local hits=workspace:GetPartsInPart(probe,overlap)
 for _,hit in ipairs(hits)do
  local key=hit:GetFullName()..tostring(hit.Position)
  local row=report.obstacles[key]
  if not row then row={path=hit:GetFullName(),position=xyz(hit.Position),size=xyz(hit.Size),invisible=hit.Transparency>=.95,examples={},samples=0};report.obstacles[key]=row end
  row.samples+=1;if #row.examples<3 then table.insert(row.examples,{at=xyz(p),label=label})end
  if anchor then table.insert(report.anchorIssues,{label=label,part=hit:GetFullName(),at=xyz(p)})end
 end
 local floor=workspace:Raycast(p+V(0,1,0),V(0,-5,0),ray)
 if not floor or math.abs(floor.Position.Y-p.Y)>.9 then
  table.insert(report.floorIssues,{label=label,at=xyz(p),hit=floor and floor.Instance:GetFullName(),height=floor and floor.Position.Y,anchor=anchor or false})
 end
end
local roadNames={WornCurvedRoute=true,WornForestTrack=true,InvestigationPath=true,ReturnLoop=true}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and roadNames[p.Name]and p.Transparency<.5 then
 report.roads+=1;local n=math.max(1,math.ceil(p.Size.Z/5));local width=math.min(p.Size.X/2-2,6)
 for i=0,n do for _,x in ipairs({-width,0,width})do
  local at=p.CFrame:PointToWorldSpace(V(x,0,(i/n-.5)*p.Size.Z))
  body(at,p:GetFullName());report.roadSamples+=1
 end end
 if report.roads%150==0 then task.wait()end
end end
for id,z in pairs(C.zones)do
 report.zones[id]={};local p=world.spawns[id].Position;body(V(p.X,z.center[2],p.Z),id..':spawn',true);report.anchors+=1
end
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
 body(V(table.unpack(g.position)),c.id..':'..g.id,true);report.anchors+=1
 for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position then body(V(table.unpack(s.position)),c.id..':'..g.id..':'..s.id,true);report.anchors+=1 end end
end end
-- Lobby and prologue training remain separate from the five campaign regions.
local lobby=require(game.ServerScriptService.Server.World.LobbyWorld).create()
local chest,storagePrompt=require(game.ServerScriptService.Server.World.StorageChest).create(lobby)
local facilities=require(game.ServerScriptService.Server.World.LobbyLandmarks).create(lobby)
require(game.ServerScriptService.Server.World.WeaponMerchant).create(lobby)
require(game.ServerScriptService.Server.World.LobbyResidents).create(lobby,facilities,storagePrompt)
require(game.ServerScriptService.Server.World.ItemShop).create(lobby)
local training=require(game.ServerScriptService.Server.World.TrainingField).create()
report.hubs={};report.hubPaths={};report.hubSamples=0
for name,w in pairs({Dawnspire=lobby,Training=training})do
 overlap.FilterDescendantsInstances={w.folder or w.model};ray.FilterDescendantsInstances={w.folder or w.model,workspace.Terrain}
 local p=w.spawn.Position;local floor=workspace:Raycast(p+V(0,1,0),V(0,-10,0),ray)
 local at=floor and floor.Position or p;body(at,name..':spawn',true);report.anchors+=1
 report.hubs[name]={spawn=xyz(p),floor=floor and floor.Position.Y}
 if name=='Dawnspire'then
  for _,item in ipairs(w.folder:GetDescendants())do if item:IsA('BasePart')and item.Name:find('Path')then
   for ix=-2,2 do for iz=-2,2 do body(item.CFrame:PointToWorldSpace(V(ix*item.Size.X/5,-.18,iz*item.Size.Z/5)),name..':'..item.Name);report.hubSamples+=1 end end
  end end
 end
 local goals={}
 for _,prompt in ipairs(w.folder:GetDescendants())do if prompt:IsA('ProximityPrompt')and prompt.Parent:IsA('BasePart')then table.insert(goals,{name=prompt:GetFullName(),p=prompt.Parent.Position,r=prompt.MaxActivationDistance})end end
 if name=='Training'then for _,enemy in ipairs(w.enemies:GetChildren())do if enemy.PrimaryPart then table.insert(goals,{name=enemy.Name,p=enemy.PrimaryPart.Position,r=10})end end end
 for _,goal in ipairs(goals)do
  local status='NoPath'
  for i=0,7 do
   local angle=i*math.pi/4;local q=V(goal.p.X+math.cos(angle)*math.min(6,goal.r-2),at.Y,goal.p.Z+math.sin(angle)*math.min(6,goal.r-2))
   probe.CFrame=CFrame.new(q+V(0,3.7,0))
   if #workspace:GetPartsInPart(probe,overlap)==0 then
    local path=game.PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
    path:ComputeAsync(at+V(0,3,0),q+V(0,3,0));status=path.Status.Name;path:Destroy()
    if status=='Success'then break end
   end
  end
  table.insert(report.hubPaths,{hub=name,goal=goal.name,status=status})
 end
end
report.obstacleCount=0;for _ in pairs(report.obstacles)do report.obstacleCount+=1 end
report.relocated={};report.retiredProxies=0
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')then
 if p:GetAttribute('RouteClearanceOriginalPosition')then table.insert(report.relocated,{path=p:GetFullName(),from=xyz(p:GetAttribute('RouteClearanceOriginalPosition')),to=xyz(p.Position)})end
 if p:GetAttribute('StoryBlockoutProxy')and not p.CanCollide and not p.CanQuery then report.retiredProxies+=1 end
end end
probe:Destroy()
print('MAP_TRAVERSAL '..game.HttpService:JSONEncode(report));return report
