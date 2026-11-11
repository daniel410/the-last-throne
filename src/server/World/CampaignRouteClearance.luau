-- Retire replaced collision and keep movable roadside scenery off walking lanes.
-- Floors, boundaries, objective anchors, actors and combat geometry are not moved.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Bounds=require(Shared.CampaignBounds)
local Areas=require(Shared.CampaignAreas)
local Safety={version=2}
local V=Vector3.new
local retired={ForestBoundary=true,OccupiedRuins=true,RavineIceWall=true,IceCitadelPillar=true,IceCitadelLintel=true,CoolantPipe=true,EmergencyCoolantPipe=true,WatchtowerPillar=true,AncientTrunk=true,BoundaryPillar=true,Memorial=true,GatePillar=true,GateLintel=true}
local movable={TreeCollision=true,GroveTrunk=true,OccupiedRuins=true,AltarObelisk=true,FrozenRouteMonument=true,CampBoard=true,BlueprintTable=true}
local function distance(p,a,b)
 local d=V(b.X-a.X,0,b.Z-a.Z);local offset=V(p.X-a.X,0,p.Z-a.Z)
 local t=math.clamp(offset:Dot(d)/math.max(.001,d:Dot(d)),0,1)
 return (offset-d*t).Magnitude
end
function Safety.retireBlockouts(world)
 -- StoryProps and the new architecture replace these exact blockout objects.
 -- Do not confuse an intentionally invisible foundation/boundary with a proxy.
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and (p:GetAttribute('StoryBlockoutProxy') or retired[p.Name] and p.Transparency>=.95)then
  p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
 end end
end
function Safety.apply(world,art)
 require(script.Parent.EmberCalderaWorld).repairEntrance(world)
 local roads={}
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and (p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ExpansionWalkingLine')and p.Transparency<.5 then table.insert(roads,p)end end
 local places=world.terrain:FindFirstChild('DeepwoodPlaces')
 if places then for _,p in ipairs(places:GetDescendants())do if p:IsA('BasePart')and p.Name=='ReturnLoop'and p.Transparency<.5 then table.insert(roads,p)end end end
 Safety.retireBlockouts(world)
 local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 local candidates={}
 for _,road in ipairs(roads)do
  for _,p in ipairs(workspace:GetPartBoundsInBox(road.CFrame+V(0,3.7,0),V(road.Size.X+4,5,road.Size.Z+4),params))do
   if movable[p.Name]then candidates[p]=true end
  end
 end
 local anchors,lanes={},{}
 for _,c in ipairs(Content.chapters)do
  local previous=world.spawns[c.zone]and world.spawns[c.zone].Position
  for _,g in ipairs(c.goals)do
   local p=V(table.unpack(g.position));table.insert(anchors,p)
   local last=p
   for _,point in ipairs(c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points or {})do
    local at=V(table.unpack(point));table.insert(anchors,at);table.insert(lanes,{last,at});last=at
   end
   local steps=g.activity and g.activity.steps
   for _,step in ipairs(steps and #steps>0 and steps or {{position=g.position}})do if step.position then
    local at=V(table.unpack(step.position));table.insert(anchors,at)
    if previous and math.abs(previous.Y-at.Y)<1 then table.insert(lanes,{previous,at})end
    previous=at
   end end
  end
 end
 for _,s in pairs(world.spawns)do table.insert(anchors,s.Position)end
 -- Expanded combat trails live beside the art root. Reserve their arrival
 -- clearings too, including the invisible simple colliders of legacy TD trees.
 for _,at in ipairs(anchors)do
  for _,p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(at+V(0,3.7,0)),V(48,5,48),params))do
   if movable[p.Name]then candidates[p]=true end
  end
 end
 local function free(at,r)
  for _,z in pairs(Content.zones)do for _,a in ipairs(z.expansionAreas or {})do
   if Areas.contains(a,at.X,at.Z,r+8)or Areas.contains(a.connector,at.X,at.Z,r+8)then return false end
  end end
  for _,road in ipairs(roads)do
   if math.abs(at.Y-road.Position.Y)<24 and distance(at,road.Position-road.CFrame.LookVector*road.Size.Z/2,road.Position+road.CFrame.LookVector*road.Size.Z/2)<road.Size.X/2+r+4 then return false end
  end
  for _,p in ipairs(anchors)do if math.abs(at.Y-p.Y)<24 and distance(at,p,p)<r+20 then return false end end
  for _,lane in ipairs(lanes)do if math.abs(at.Y-lane[1].Y)<1 and distance(at,lane[1],lane[2])<r+8 then return false end end
  return true
 end
 local floorRay=RaycastParams.new();floorRay.FilterType=Enum.RaycastFilterType.Include;floorRay.FilterDescendantsInstances={world.terrain,workspace.Terrain};floorRay.RespectCanCollide=true
 local ordered={};for p in pairs(candidates)do table.insert(ordered,p)end
 table.sort(ordered,function(a,b)return a:GetFullName()..tostring(a.Position)<b:GetFullName()..tostring(b.Position)end)
 local moved=0
 for _,p in ipairs(ordered)do
  local at=p.Position;local _,zone=Bounds.region(at.X,at.Z);local floor=zone and Content.zones[zone].center[2]
  local r=math.max(p.Size.X,p.Size.Z)/2;local destination
  if floor then for ring=1,8 do
   for index=0,15 do
    local angle=index*math.pi/8;local q=V(at.X+math.cos(angle)*ring*12,floor,at.Z+math.sin(angle)*ring*12)
    local _,id=Bounds.region(q.X,q.Z,-8)
    if id==zone and free(q,r)then
     local hit=workspace:Raycast(q+V(0,10,0),V(0,-20,0),floorRay)
     if hit and math.abs(hit.Position.Y-floor)<.5 then destination=V(q.X,at.Y,q.Z);break end
    end
   end
   if destination then break end
  end end
  if destination then
   local delta=destination-at
   -- Legacy tree visuals and their simple collider share a bounding-box center.
   if p.Name=='TreeCollision' or p.Name=='GroveTrunk'then
    for _,m in ipairs(p.Parent:GetChildren())do if m:IsA('Model')and (m.Name=='TDForestTree'or m.Name=='TDElderTree')then
     local cf=m:GetBoundingBox()
     if V(cf.X-at.X,0,cf.Z-at.Z).Magnitude<.1 then m:PivotTo(m:GetPivot()+delta);break end
    end end
   end
   -- The seal was authored as a sibling of its obelisk, not a welded child.
   if p.Name=='AltarObelisk'then for _,sibling in ipairs(p.Parent:GetChildren())do
    if sibling:IsA('BasePart')and sibling.Name=='VioletSeal'and (sibling.Position-at-V(0,14,0)).Magnitude<.1 then sibling.CFrame+=delta end
   end end
   if not p:GetAttribute('RouteClearanceOriginalPosition')then p:SetAttribute('RouteClearanceOriginalPosition',at)end
   p.CFrame+=delta;moved+=1
  end
 end
 art:SetAttribute('RouteClearanceVersion',Safety.version)
 art:SetAttribute('RelocatedRoadsideProps',(art:GetAttribute('RelocatedRoadsideProps')or 0)+moved)
 return moved
end
return Safety
