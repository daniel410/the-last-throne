-- Story-specific concept landmarks; personal actors, progress and combat stay authoritative.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Areas=require(Shared.CampaignAreas)
local K=require(script.Parent.EpicEnvironmentKit)
local Collision=require(script.Parent.CampaignSceneryCollision)
local Profiles=require(script.Parent.RegionalConceptProfiles)
local V=Vector3.new
local C=Color3.fromRGB
local D={version=2}
local palettes={
 [2]={stone=C(102,116,135),light=C(153,168,186),moss=C(43,62,79),wood=C(58,54,65),path=C(89,103,122),trim=C(146,132,169)},
 [3]={stone=C(149,174,193),light=C(218,233,239),moss=C(132,166,184),wood=C(105,80,64),path=C(160,183,197),trim=C(91,143,178)},
 [4]={stone=C(81,77,75),light=C(156,127,92),moss=C(104,92,76),wood=C(98,69,46),path=C(119,103,86),trim=C(176,126,68)},
 [5]={stone=C(107,115,136),light=C(165,171,185),moss=C(67,79,91),wood=C(76,67,78),path=C(115,121,140),trim=C(134,120,155)},
}
function D.profile(id)return Profiles[id]end
local function assembly(role,colors,epic)
 local m=Instance.new('Model');m.Name=epic==2 and 'SilkenRuinCluster'or epic==3 and 'SnowboundSupplyCluster'or epic==4 and 'CrewServiceCluster'or 'KeeperMemorialCluster'
 m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m:SetAttribute('RegionalConceptRole',role)
 local function part(name,size,p,color,material,soft)
  local obj=K.part(m,name,size,CFrame.new(p),color or colors.stone,material or Enum.Material.Slate)
  obj:SetAttribute('EpicDetailSolid',not soft);obj:SetAttribute('TLTSceneryDistance',380);return obj
 end
 if epic==2 then
  for i=1,3 do
   part('BrokenWatchPier',V(3,5+i,3),V((i-2)*5,(5+i)/2,0))
   part('WatchPierCap',V(4,1,4),V((i-2)*5,5.5+i,0),colors.light)
  end
  for i=1,5 do
   local silk=part('HighSilverSilk',V(.09,.09,13),V((i-3)*1.1,8+i*.2,0),C(192,207,225),Enum.Material.Fabric,true)
   silk.CFrame*=CFrame.Angles(.65,(i-3)*.2,0)
  end
 elseif epic==3 then
  for _,x in ipairs({-4,4})do
   part('SnowSupplyChest',V(5,3,4),V(x,1.5,0),colors.wood,Enum.Material.WoodPlanks)
   part('SettledChestSnow',V(5.2,.2,4.2),V(x,3.1,0),colors.light,Enum.Material.Snow,true)
  end
  part('ShelteredRouteMarker',V(2,7,2),V(0,3.5,-4),colors.stone)
  part('BlueMarkerInset',V(.8,2,.12),V(0,5,-2.95),colors.trim,Enum.Material.Glass,true)
 elseif epic==4 then
  for _,x in ipairs({-5,5})do part('PipeRackLeg',V(1,6,3),V(x,3,0),colors.wood,Enum.Material.Wood)end
  for i=1,3 do
   part('DryServiceStock',V(13,1,1),V(0,3+i,0),colors.trim,Enum.Material.Metal)
   part('CrewToolCrate',V(3,2,3),V((i-2)*4,1,5),colors.wood,Enum.Material.WoodPlanks)
  end
 else
  for i=1,3 do
   part('KeeperMemorialFoot',V(4,1,4),V((i-2)*5,.5,0),colors.light)
   part('KeeperMemorialSlab',V(2.7,4+i%2,1.2),V((i-2)*5,2.5+i%2*.5,-1))
   part('QuietOffering',V(1,.6,1),V((i-2)*5,1.3,1),colors.trim,Enum.Material.Slate,true)
  end
 end
 m.WorldPivot=CFrame.identity;return m
end
function D.build(site,id,c,size,safe,ground,world)
 local profile=Profiles[id];if not profile then return end
 local colors=palettes[profile.epic]
 local group=Instance.new('Folder');group.Name='RegionalConcept';group.Parent=site
 group:SetAttribute('ConceptVersion',D.version);group:SetAttribute('ConceptTitle',profile.title)
 group:SetAttribute('ConceptSource','2026-11-13-regional-epic-stories-v1')
 local placed={};local rejected=0;local reasons={}
 local approaches={world.spawns[id].Position}
 for _,chapter in ipairs(Content.chapters)do if chapter.zone==id then
  for _,goal in ipairs(chapter.goals)do
   local p=V(table.unpack(goal.position))
   if math.abs(p.X-c.X)<size[1]/2 and math.abs(p.Z-c.Z)<size[2]/2 then approaches[#approaches+1]=p end
  end
 end end
 local function face(p)
  local nearest,distance
  for _,a in ipairs(approaches)do
   local d=V(a.X-p.X,0,a.Z-p.Z).Magnitude
   if not distance or d<distance then nearest,distance=a,d end
  end
  -- Blender entries face local +Z, not the camera's -Z convention.
  return CFrame.new(p)*CFrame.Angles(0,math.atan2(nearest.X-p.X,nearest.Z-p.Z),0),nearest
 end
 local lanes={};local Nav=require(Shared.CampaignNavigationRoute)
 -- Incident navigation bends through an entrance mouth. Reserve those actual
 -- walking segments, not only a straight chord between story anchors.
 for _,chapter in ipairs(Content.chapters)do if chapter.zone==id then
  local spawn=world.spawns[id].Position;local previous={spawn.X,spawn.Y,spawn.Z}
  for _,goal in ipairs(chapter.goals)do
   local targets={};local route=chapter.combatRoutes and chapter.combatRoutes[goal.id]
   if route and #(route.worldPoints or route.points)>0 then targets=route.worldPoints or route.points
   else for _,step in ipairs(goal.activity and goal.activity.steps or {{position=goal.position}})do if step.position then targets[#targets+1]=step.position end end end
   for _,target in ipairs(targets)do
    local path=Nav.route(previous,target)
    for i=2,#path do lanes[#lanes+1]={path[i-1],path[i]}end
    previous=target
   end
  end
 end end
 local function reject(reason)reasons[reason]=(reasons[reason]or 0)+1;return nil end
 local roads={}
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and p.Transparency<.5 and(p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ReturnLoop'or p.Name=='RegionalReturnTrail')
   and math.abs(p.Position.Y-c.Y)<18 and math.abs(p.Position.X-c.X)<size[1]+p.Size.Z/2 and math.abs(p.Position.Z-c.Z)<size[2]+p.Size.Z/2 then roads[#roads+1]=p end
 end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={group};overlap.RespectCanCollide=true
 local function eligible(p,r)
  if not safe(p,r+5)then return reject('Reserved')end
  for _,line in ipairs(lanes)do
   local a,b=line[1],line[2];local dx,dz=b[1]-a[1],b[3]-a[3]
   local t=math.clamp(((p.X-a[1])*dx+(p.Z-a[3])*dz)/math.max(.001,dx*dx+dz*dz),0,1)
   if (p.X-a[1]-t*dx)^2+(p.Z-a[3]-t*dz)^2<(r+10)^2 then return reject('WalkingLane')end
  end
  if math.abs(p.X-c.X)>size[1]/2-r-5 or math.abs(p.Z-c.Z)>size[2]/2-r-5 then return reject('Boundary')end
  for _,z in pairs(Content.zones)do for _,a in ipairs(z.expansionAreas or {})do
   if Areas.contains(a,p.X,p.Z,r+12)or Areas.contains(a.connector,p.X,p.Z,r+12)then return reject('Incident')end
  end end
  for _,road in ipairs(roads)do
   local q=road.CFrame:PointToObjectSpace(p)
   if math.abs(q.X)<road.Size.X/2+r+7 and math.abs(q.Z)<road.Size.Z/2+r+7 then return reject('Road')end
  end
  for _,other in ipairs(placed)do if V(p.X-other.p.X,0,p.Z-other.p.Z).Magnitude<r+other.r+18 then return reject('Neighbor')end end
  local q,ok=ground(p);if not ok or math.abs(q.Y-c.Y)>10 then return reject('Ground')end
  for _,d in ipairs({V(r,0,0),V(-r,0,0),V(0,0,r),V(0,0,-r),V(r*.7,0,r*.7),V(-r*.7,0,r*.7),V(r*.7,0,-r*.7),V(-r*.7,0,-r*.7)})do
   local sample,valid=ground(p+d);if not valid or math.abs(sample.Y-q.Y)>.65 then return reject('Slope')end
  end
  if #workspace:GetPartBoundsInBox(CFrame.new(q+V(0,9,0)),V(r*2+6,16,r*2+6),overlap)>0 then return reject('Occupied')end
  return q
 end
 local function place(kind,role,index)
  local satellite=role=='Supporting'and index<=3 and(id=='EC-02'or id=='FV-07')
  local m=(role=='Signature'or satellite)and require(script.Parent.RegionalArchitecture).build(kind)or assembly(role,colors,profile.epic)
  m:SetAttribute('RegionalConceptRole',role)
  if satellite then m:ScaleTo(id=='EC-02'and .85 or .6)end
  -- Side pockets and the convoy clearing have tighter existing encounter
  -- envelopes. Their landmarks use the same kit at a village-scale footprint.
  if role=='Signature'then
   local scale=id:find('%-S')and .85 or (id=='FV-07'or id=='EC-02'or id=='EC-07'or id=='HG-06')and 1.65 or 1.3
   m:ScaleTo(scale)
  end
  local cf,ext=m:GetBoundingBox()
  local r=V(ext.X,0,ext.Z).Magnitude/2+2;local result
  -- Authored uneven shoulders frame the actual objectives. Always reject a
  -- crowded slot, never force a building into the fight or expand the boundary.
  local candidates={}
  for ring=1,4 do
   for step=0,23 do
    local a=(step+index*3)*math.pi/12
    candidates[#candidates+1]=c+V(math.cos(a)*size[1]*(.17+ring*.065),0,math.sin(a)*size[2]*(.17+ring*.065))
   end
  end
  -- Smaller optional regions and incident wings can eliminate whole shoulder
  -- bands. Search the remaining in-zone grid with the identical safety gates.
  for x=-5,5 do for z=-5,5 do candidates[#candidates+1]=c+V(x*size[1]*.075,0,z*size[2]*.075)end end
  for _,q in ipairs(candidates)do
    local p=eligible(q,r)
    if p then
     local cf,approach=face(p);m:PivotTo(cf);m.Parent=group
     m:SetAttribute('ApproachPosition',approach)
     m:SetAttribute('GroundPosition',p);m:SetAttribute('ConceptZone',id);m:SetAttribute('PlacementRadius',r)
     Collision.apply(m);table.insert(placed,{p=p,r=r});result=m;break
    end
  end
  if not result then
   -- Try a smaller roadside form rather than reducing combat/route reserves.
   m:ScaleTo(role=='Signature'and(id:find('%-S')and .68 or 1)or .65);local _,small=m:GetBoundingBox();r=V(small.X,0,small.Z).Magnitude/2+2
   for _,q in ipairs(candidates)do
    local p=eligible(q,r)
    if p then
     local cf,approach=face(p);m:PivotTo(cf);m.Parent=group
     m:SetAttribute('ApproachPosition',approach)
     m:SetAttribute('GroundPosition',p);m:SetAttribute('ConceptZone',id);m:SetAttribute('PlacementRadius',r)
     Collision.apply(m);placed[#placed+1]={p=p,r=r};result=m;break
    end
   end
  end
  if not result then m:Destroy();rejected+=1 end
  task.wait()
  return result
 end
 place(profile.kind,'Signature',1)
 for i=1,3 do place(profile.kind,'Supporting',i+1)end
 -- Low grouped vegetation, limestone and earth create depth without a new
 -- canopy over the camera. Substantial stones retain collision off the routes.
 local dressing=Instance.new('Model');dressing.Name='RegionalVerge';dressing.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;dressing.Parent=group
 local coverCount=0
 for i=1,32 do
  local a=i*2.399;local p=c+V(math.cos(a)*size[1]*(.23+(i%3)*.07),0,math.sin(a)*size[2]*(.23+(i%4)*.045))
  local q=eligible(p,14)
  if q then
   for j=1,3 do
    local rock=K.part(dressing,'RegionalVergeStone',V(8+j,3+j*2,9),CFrame.new(q+V((j-2)*4,(3+j*2)/2-.2,0))*CFrame.Angles(0,j+i,.12),colors.stone:Lerp(colors.moss,.25),Enum.Material.Slate,'Wedge')
    rock:SetAttribute('EpicDetailSolid',true);rock:SetAttribute('TLTSceneryDistance',300)
    local leaf=K.part(dressing,'RegionalVergeDetail',V(6,.3,3),CFrame.new(q+V((j-2)*4,3+j*2,j*2))*CFrame.Angles(.2,j+i,0),colors.moss,(profile.epic==3 and Enum.Material.Glacier or profile.epic==4 and Enum.Material.Basalt or Enum.Material.Grass),'Wedge')
    leaf:SetAttribute('TLTSceneryDistance',230)
   end
   coverCount+=1;table.insert(placed,{p=q,r=14})
  end
 end
 Collision.apply(dressing)
 group:SetAttribute('Assemblies',#group:GetChildren()-1);group:SetAttribute('SkippedAssemblies',rejected);group:SetAttribute('VergeClusters',coverCount)
 local reasonRows={};for reason,count in pairs(reasons)do reasonRows[#reasonRows+1]=reason..'='..count end;table.sort(reasonRows)
 group:SetAttribute('PlacementRejections',table.concat(reasonRows,', '))
 site:SetAttribute('RegionalConceptVersion',D.version)
 return group
end
function D.paths(site,ground,world)
 local profile=Profiles[site.Name];if not profile then return end
 local colors=palettes[profile.epic]
 local group=Instance.new('Folder');group.Name='RegionalRouteFinish';group.Parent=site
 local count=0
 local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={workspace.Terrain,world.terrain};floor.RespectCanCollide=true
 for _,p in ipairs(site:GetDescendants())do
  if p:IsA('BasePart')and p.Name=='WornCurvedRoute'then
   p.Color=colors.path;p.Material=profile.epic==3 and Enum.Material.Snow or profile.epic==4 and Enum.Material.Basalt or Enum.Material.Cobblestone
   count+=1
   if count%16==0 and #group:GetChildren()<56 then
    for _,side in ipairs({-1,1})do
     local q=p.CFrame:PointToWorldSpace(V(side*math.min(5,p.Size.X*.25),0,0))
     local at,valid=ground(q)
     local hit=valid and workspace:Raycast(at+V(0,2,0),V(0,-5,0),floor)
     if hit and math.abs(hit.Position.Y-at.Y)<.3 and math.abs(at.Y-p.Position.Y)<.4 then
      local stone=K.part(group,'RegionalPathInlay',V(1.8,.04,1.5),CFrame.new(at+V(0,.07,0))*p.CFrame.Rotation,colors.light,Enum.Material.Slate)
      stone.CastShadow=false;stone:SetAttribute('TLTSceneryDistance',280)
     end
    end
   end
  end
 end
 group:SetAttribute('PathSegments',count)
end
-- Later epic construction can carve a shared border. Re-ground paint after the
-- overland roads finish, using only real collision floors and no new terrain.
function D.finish(world)
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
 ray.FilterDescendantsInstances={workspace.Terrain,world.terrain};ray.RespectCanCollide=true
 local sites=world.folder:FindFirstChild('EpicWorldArt');if not sites then return end
 for _,root in ipairs(sites:GetChildren())do for _,site in ipairs(root:GetChildren())do
  if site:FindFirstChild('RegionalConcept')then
   for _,p in ipairs(site:GetDescendants())do
    if p:IsA('BasePart')and(p.Name=='RegionalPathInlay'or p.Name=='WornCurvedRoute')then
     local hit=workspace:Raycast(p.Position+V(0,12,0),V(0,-30,0),ray)
     if hit and math.abs(hit.Position.Y-p.Position.Y)<10 then
      p.CFrame+=V(0,hit.Position.Y+(p.Name=='RegionalPathInlay'and .07 or .04)-p.Position.Y,0)
     elseif p.Name=='RegionalPathInlay'then p:Destroy()end
    end
   end
  end
 end end
end
return D
