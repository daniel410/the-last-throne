-- Deepwood's approved aerial concepts translated into grounded, traversable places.
-- This pass owns scenery only. Story actors, mechanisms, rewards and floors stay authoritative.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Areas=require(Shared.CampaignAreas)
local K=require(script.Parent.EpicEnvironmentKit)
local Collision=require(script.Parent.CampaignSceneryCollision)
local V=Vector3.new
local C=Color3.fromRGB
local D={version=2}
local colors={stone=C(149,151,117),light=C(191,183,141),moss=C(91,123,59),wood=C(116,83,48),
 dark=C(72,57,38),blue=C(36,77,145),gold=C(224,178,77),red=C(129,57,42),cloth=C(194,174,124),
 path=C(170,153,107),root=C(77,65,46)}
local profiles={
 ['DW-01']={'Pilgrim Trail','Waystation','Trail'},
 ['DW-02']={'Convoy Refuge','Shelter','Supply'},
 ['DW-03']={'Elder Tree Outpost','Outpost','Market'},
 ['DW-04']={'Abandoned Watchtower','Watchtower','Ruin'},
 ['DW-05']={'Occupied Barracks','Barracks','Occupation'},
 ['DW-06']={'Rootwood Refuge','Rootwood','Roots'},
 ['DW-07']={'Black Root Precinct','AltarRuins','Roots'},
 ['DW-S1']={'Provision Camp','Storehouse','Supply'},
 ['DW-S2']={'Waterfall Quarry','Quarry','Work'},
 ['DW-S3']={'Old Red Battlefield','Battlefield','Occupation'},
}
function D.profile(id)return profiles[id]end

local function assembly(kind,role)
 if role=='Signature'then return require(script.Parent.DeepwoodArchitecture).build(kind)end
 local m=Instance.new('Model');m.Name=kind;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('DeepwoodConceptRole',role)
 local function part(name,size,at,color,material,yaw,shape,soft)
  local p=K.part(m,name,size,CFrame.new(at)*CFrame.Angles(0,yaw or 0,0),color or colors.wood,material or Enum.Material.Wood,shape)
  p:SetAttribute('EpicDetailSolid',not soft)
  p:SetAttribute('TLTSceneryDistance',role=='Signature'and 700 or 420)
  return p
 end
 local function beam(name,a,b,width,color,soft)
  local p=K.beam(m,name,a,b,width,color or colors.wood,Enum.Material.Wood)
  p:SetAttribute('EpicDetailSolid',not soft);p:SetAttribute('TLTSceneryDistance',700);return p
 end
 local function crate(at)
  part('ProvisionChest',V(5,4,4),at+V(0,2,0))
  for _,s in ipairs({-1,1})do part('ChestBrace',V(.3,4.2,4.2),at+V(s*1.6,2,0),colors.dark)end
  part('SupplyWrapping',V(5.2,.15,3),at+V(0,4.1,0),colors.cloth,Enum.Material.Fabric,0,nil,true)
 end
 local function standard(at,hostile,broken)
  local h=broken and 9 or 16
  part('StandardPost',V(.65,h,.65),at+V(0,h/2,0))
  beam('StandardCrossbar',at+V(-3,h-1,0),at+V(3,h-1,0),.55)
  part('DeepwoodStandard',V(5,7,.15),at+V(0,h-5,0),hostile and colors.red or colors.blue,Enum.Material.Fabric,0,nil,true)
  -- Match the native royal blue/gold vocabulary, without inventing a new icon texture.
  if not hostile then
   part('CrownBand',V(2.4,.55,.18),at+V(0,h-5.4,.12),colors.gold,Enum.Material.Metal,0,nil,true)
   for i=-1,1 do part('CrownPoint',V(.5,1.1,.18),at+V(i*.8,h-4.8,.12),colors.gold,Enum.Material.Metal,0,nil,true)end
  end
 end
 local function wall(at,length,height,yaw)
  local origin=CFrame.new(at)*CFrame.Angles(0,yaw or 0,0)
  local courses=math.ceil(height/3)
  for row=1,courses do
   local h=height/courses;local n=math.ceil(length/7)
   for i=1,n do
    local p=part('MossyMasonry',V(length/n-.16,h-.12,3.8),V(0,0,0),row==courses and colors.light or colors.stone,Enum.Material.Brick)
    p.CFrame=origin*CFrame.new((i-.5)*length/n-length/2,(row-.5)*h,0)
   end
  end
  part('MossOnCoping',V(length,.18,4),at+V(0,height+.05,0),colors.moss,Enum.Material.Grass,yaw,nil,true)
 end
 local function awning(at,width,depth,hostile)
  for _,s in ipairs({-1,1})do
   part('TimberSupport',V(.9,12,.9),at+V(s*(width/2-1),6,depth/2))
   part('TimberSupport',V(.9,15,.9),at+V(s*(width/2-1),7.5,-depth/2))
  end
  beam('CanopyRidge',at+V(-width/2,15,-depth/2),at+V(width/2,15,-depth/2),.8)
  local roof=part('CanvasAwning',V(width+2,.24,math.sqrt(depth*depth+9)),at+V(0,13.5,0),hostile and colors.red or colors.blue,Enum.Material.Fabric,0,nil,true)
  roof.CFrame*=CFrame.Angles(math.atan(3/depth),0,0)
  part('AwningGoldHem',V(width+2,.3,.35),at+V(0,12,depth/2),colors.gold,Enum.Material.Fabric,0,nil,true)
 end
 local function tableAt(at)
  for _,s in ipairs({-1,1})do part('TableTrestle',V(1,3.6,5),at+V(s*4,1.8,0))end
  part('TimberTabletop',V(12,.6,6),at+V(0,3.9,0))
 end
 local function roots(at)
  for i=0,3 do
   local a=i*1.4;local d=V(math.cos(a),0,math.sin(a))
   beam('RootButtress',at+V(0,8,0),at+d*9+V(0,2,0),3.5,colors.root)
   beam('RootTaper',at+d*9+V(0,2,0),at+d*17+V(0,.8,0),1.6,colors.root)
  end
 end
 if kind=='Market'then
  awning(V(0,0,0),20,11);tableAt(V(0,0,1));crate(V(-7,0,-3));crate(V(7,0,-3))
 elseif kind=='Supply'then
  crate(V(-5,0,0));crate(V(2,0,-2));crate(V(5,0,4));standard(V(-9,0,-4))
 elseif kind=='Ruin'or kind=='Occupation'then
  wall(V(0,0,-6),25,7);wall(V(-10,0,3),12,4,math.pi/2);standard(V(10,0,-5),kind=='Occupation',kind=='Occupation')
 elseif kind=='Roots'then roots(V(0,0,0));wall(V(9,0,-10),12,5)
 elseif kind=='Work'then tableAt(V(0,0,0));crate(V(-8,0,-4))
 else wall(V(0,0,-5),19,5);standard(V(-9,0,3));crate(V(6,0,0))end
 m.WorldPivot=CFrame.identity
 return m
end

function D.build(site,id,c,size,safe,ground,world)
 local profile=profiles[id];if not profile then return end
 local group=Instance.new('Folder');group.Name='DeepwoodConcept';group.Parent=site
 group:SetAttribute('ConceptVersion',D.version);group:SetAttribute('ConceptTitle',profile[1])
 group:SetAttribute('ConceptSource','2026-11-12-deepwood-epic-stories-v1')
 local placed={};local rejected=0;local reasons={}
 local function reject(reason)reasons[reason]=(reasons[reason]or 0)+1;return nil end
 local roads={}
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and p.Transparency<.5 and(p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ReturnLoop'or p.Name=='RegionalReturnTrail')
   and math.abs(p.Position.Y-c.Y)<18 and math.abs(p.Position.X-c.X)<size[1]+p.Size.Z/2 and math.abs(p.Position.Z-c.Z)<size[2]+p.Size.Z/2 then roads[#roads+1]=p end
 end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={group};overlap.RespectCanCollide=true
 local function eligible(p,r)
  if not safe(p,r+5)then return reject('Reserved')end
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
  for _,d in ipairs({V(r,0,0),V(-r,0,0),V(0,0,r),V(0,0,-r)})do
   local sample,valid=ground(p+d);if not valid or math.abs(sample.Y-q.Y)>.65 then return reject('Slope')end
  end
  if #workspace:GetPartBoundsInBox(CFrame.new(q+V(0,9,0)),V(r*2+6,16,r*2+6),overlap)>0 then return reject('Occupied')end
  return q
 end
 local function place(kind,role,index)
  local m=assembly(kind,role)
  -- Side pockets and the convoy clearing have tighter existing encounter
  -- envelopes. Their landmarks use the same kit at a village-scale footprint.
  if role=='Signature'and(id:find('%-S')or id=='DW-02')then m:ScaleTo(.68)end
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
     m:PivotTo(CFrame.new(p)*CFrame.Angles(0,math.atan2(c.X-p.X,c.Z-p.Z),0));m.Parent=group
     m:SetAttribute('GroundPosition',p);m:SetAttribute('ConceptZone',id);m:SetAttribute('PlacementRadius',r)
     Collision.apply(m);table.insert(placed,{p=p,r=r});result=m;break
    end
  end
  if not result and role=='Supporting'then
   -- Try a smaller roadside form rather than reducing combat/route reserves.
   m:ScaleTo(.65);local _,small=m:GetBoundingBox();r=V(small.X,0,small.Z).Magnitude/2+2
   for _,q in ipairs(candidates)do
    local p=eligible(q,r)
    if p then
     m:PivotTo(CFrame.new(p)*CFrame.Angles(0,math.atan2(c.X-p.X,c.Z-p.Z),0));m.Parent=group
     m:SetAttribute('GroundPosition',p);m:SetAttribute('ConceptZone',id);m:SetAttribute('PlacementRadius',r)
     Collision.apply(m);placed[#placed+1]={p=p,r=r};result=m;break
    end
   end
  end
  if not result then m:Destroy();rejected+=1 end
  task.wait()
  return result
 end
 place(profile[2],'Signature',1)
 for i=1,5 do place(profile[3],'Supporting',i+1)end
 -- Low grouped vegetation, limestone and earth create depth without a new
 -- canopy over the camera. Substantial stones retain collision off the routes.
 local dressing=Instance.new('Model');dressing.Name='WoodlandVerge';dressing.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;dressing.Parent=group
 local coverCount=0
 for i=1,32 do
  local a=i*2.399;local p=c+V(math.cos(a)*size[1]*(.23+(i%3)*.07),0,math.sin(a)*size[2]*(.23+(i%4)*.045))
  local q=eligible(p,9)
  if q then
   for j=1,3 do
    local rock=K.part(dressing,'VergeLimestone',V(4+j,1+j*.6,4),CFrame.new(q+V((j-2)*4,.5+j*.2,0))*CFrame.Angles(0,j+i,.12),colors.stone:Lerp(colors.moss,.25),Enum.Material.Slate,'Wedge')
    rock:SetAttribute('EpicDetailSolid',true);rock:SetAttribute('TLTSceneryDistance',300)
    local leaf=K.part(dressing,'VergeFern',V(6,.3,3),CFrame.new(q+V((j-2)*4,2.6,j*2))*CFrame.Angles(.2,j+i,0),colors.moss,Enum.Material.Grass,'Wedge')
    leaf:SetAttribute('TLTSceneryDistance',230)
   end
   coverCount+=1;table.insert(placed,{p=q,r=9})
  end
 end
 Collision.apply(dressing)
 group:SetAttribute('Assemblies',#group:GetChildren()-1);group:SetAttribute('SkippedAssemblies',rejected);group:SetAttribute('VergeClusters',coverCount)
 local reasonRows={};for reason,count in pairs(reasons)do reasonRows[#reasonRows+1]=reason..'='..count end;table.sort(reasonRows)
 group:SetAttribute('PlacementRejections',table.concat(reasonRows,', '))
 site:SetAttribute('DeepwoodConceptVersion',D.version)
 return group
end

function D.paths(site,ground,world)
 local paint=Instance.new('Folder');paint.Name='DeepwoodRouteFinish';paint.Parent=site
 local rows=0
 local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={workspace.Terrain,world.terrain};floor.RespectCanCollide=true
 local roads={}
 for _,p in ipairs(site:GetDescendants())do if p:IsA('BasePart')and p.Name=='WornCurvedRoute'then roads[#roads+1]=p end end
 for i,p in ipairs(roads)do
  p.Color=colors.path:Lerp(colors.moss,.18);p.Material=Enum.Material.Cobblestone
  if i%9==0 and rows<28 then
   local full=true;local points={}
   for j=-1,1 do
    local q=p.CFrame:PointToWorldSpace(V(j*math.min(5,p.Size.X*.28),0,0));local at,ok=ground(q)
    if not ok or math.abs(at.Y-p.Position.Y)>.4 then full=false end
    local visible=workspace:Raycast(at+V(0,2,0),V(0,-5,0),floor)
    if not visible or math.abs(visible.Position.Y-at.Y)>.3 then full=false end
    points[#points+1]=at
   end
   if full then
    for j,q in ipairs(points)do
     local tile=K.part(paint,'WornTrailPaver',V(3.5,.045,3),CFrame.new(q+V(0,.09,0))*p.CFrame.Rotation,colors.light:Lerp(colors.moss,(j%2)*.15),Enum.Material.Slate)
     tile.CastShadow=false;tile:SetAttribute('TLTSceneryDistance',280)
    end
    rows+=1
   end
  end
 end
 paint:SetAttribute('PavingRows',rows)
 -- Quiet masonry at existing report/planning destinations gives the scattered
 -- story anchors a human-scale place, without copying an actor or interaction.
 local courts=0
 for _,chapter in ipairs(Content.chapters)do if chapter.zone==site.Name and not chapter.side then
  for _,g in ipairs(chapter.goals)do
   local at=V(table.unpack(g.position))
   if #g.enemies==0 and not g.id:match('^exp_')and courts<3 then
    local p,ok=ground(at);local valid=ok and math.abs(p.Y-at.Y)<.4
    for _,d in ipairs({V(14,0,0),V(-14,0,0),V(0,0,12),V(0,0,-12)})do
     local q,supported=ground(at+d);if not supported or math.abs(q.Y-p.Y)>.35 then valid=false end
    end
    if valid then
     local worn=K.part(paint,'WornMeetingCourt',V(34,.055,28),CFrame.new(p+V(0,.08,0)),colors.path:Lerp(colors.moss,.3),Enum.Material.Cobblestone,'Ball')
     worn.CastShadow=false;worn:SetAttribute('TLTSceneryDistance',380)
     for x=-1,1 do for z=-1,1 do
      local q=ground(p+V(x*6,0,z*6))
      local tile=K.part(paint,'MeetingFlagstone',V(5,.04,4.5),CFrame.new(q+V(0,.12,0))*CFrame.Angles(0,(x+z)*.04,0),colors.light:Lerp(colors.moss,.26),Enum.Material.Slate)
      tile.CastShadow=false;tile:SetAttribute('TLTSceneryDistance',280)
     end end
     courts+=1
    end
   end
  end
 end end
 paint:SetAttribute('MeetingCourts',courts)
end
function D.finish(world)
 -- Combat/report roads are emitted after EpicWorldArt. Finish those same
 -- authoritative route drawings too, rather than leaving a second dark road grid.
 local Bounds=require(Shared.CampaignBounds)
 local floorNames={ForestGround=true,JourneyGround=true,JourneyPass=true,ForestBedrock=true,WalkableTerrace=true,WalkableRamp=true,TerraceLanding=true,TrailEmbankment=true}
 local floors={workspace.Terrain}
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.CanCollide
  and(floorNames[p.Name]or p.Name:match('^Support_')or p.Name:match('^TrailSupport_')or p.Name:match('^ConnectedPath_'))then floors[#floors+1]=p end end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=floors;ray.RespectCanCollide=true
 local grounded=0
 local legacy=world.folder:FindFirstChild('GroundedForest')
 if legacy then for _,m in ipairs(legacy:GetDescendants())do
  if m:IsA('Model')and m:GetAttribute('TDEnvironmentSource')=='TDLimestoneCliff'then
   local cf,ext=m:GetBoundingBox()
   local hit=workspace:Raycast(cf.Position+V(0,180,0),V(0,-480,0),ray)
   -- Old cliff islands were exposed like stone flowerpots beneath the trees.
   -- Sink the intact pinned TD mesh into the retained bank, exposing only its lip.
   if hit then
    local delta=hit.Position.Y+1.5-(cf.Y+ext.Y/2)
    if delta<0 then m:PivotTo(m:GetPivot()+V(0,delta,0));grounded+=1 end
    m:SetAttribute('DeepwoodBankGrounded',true)
   end
  end
 end end
 local landmarks={}
 for id,z in pairs(Content.zones)do if id:sub(1,2)=='DW'then
  local site=world.folder.EpicWorldArt.EpicWorldArt_1[id]
  local group=site and site:FindFirstChild('DeepwoodConcept')
  if group then for _,m in ipairs(group:GetChildren())do if m:GetAttribute('DeepwoodConceptRole')=='Signature'then
   landmarks[#landmarks+1]={at=m:GetAttribute('GroundPosition'),radius=m:GetAttribute('PlacementRadius'),center=V(table.unpack(z.center))}
  end end end
 end end
 -- Legacy perimeter groves can sit directly in front of a newly authored
 -- landmark even when their high canopies do not block the hero's body sweep.
 -- Prune complete ordinary trees and their paired simple collider together;
 -- preserve every TD elder-tree hero and every authoritative story object.
 local pruned=0
 for _,tree in ipairs(world.folder:GetDescendants())do
  if tree:IsA('Model')and(tree:GetAttribute('TDEnvironmentSource')=='ForestTree'or tree:GetAttribute('TDEnvironmentSource')=='TDForestTree')then
   local cf,ext=tree:GetBoundingBox();local p=cf.Position;local r=math.max(ext.X,ext.Z)/2
   local remove=false
   for _,hero in ipairs(landmarks)do
    local offset=V(p.X-hero.at.X,0,p.Z-hero.at.Z)
    local direction=V(hero.center.X-hero.at.X,0,hero.center.Z-hero.at.Z)
    local t=direction.Magnitude>.01 and offset:Dot(direction.Unit)or -1
    local side=direction.Magnitude>.01 and(offset-direction.Unit*t).Magnitude or math.huge
    if math.abs((p.Y-ext.Y/2)-hero.at.Y)<40 and(offset.Magnitude<hero.radius+r+10 or t>0 and t<110 and side<r+18)then remove=true;break end
   end
   if remove then
    for _,sibling in ipairs(tree.Parent:GetChildren())do
     if sibling:IsA('BasePart')and(sibling.Name=='TreeCollision'or sibling.Name=='GroveTrunk'or sibling.Name=='ForestRoot')
      and V(sibling.Position.X-p.X,0,sibling.Position.Z-p.Z).Magnitude<.2 then sibling:Destroy()end
    end
    tree:Destroy();pruned+=1
   end
  end
 end
 local painted=0
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and not p.CanCollide and p.Transparency<.5
   and(p.Name=='JourneyWalkingTrail'or p.Name=='RegionalReturnTrail'or p.Name=='ExpansionWalkingLine'or p.Name=='ReturnLoop'or p.Name=='WornCurvedRoute')then
   local _,id=Bounds.region(p.Position.X,p.Position.Z)
   if id and id:sub(1,2)=='DW'then
    local returning=p.Name=='RegionalReturnTrail'or p.Name=='ReturnLoop'
    p.Color=returning and colors.path:Lerp(colors.moss,.27)or colors.path
    p.Material=returning and Enum.Material.Ground or Enum.Material.Cobblestone
    p.Size=V(math.min(p.Size.X,returning and 9 or 16),p.Size.Y,p.Size.Z)
    p:SetAttribute('DeepwoodConceptPath',true);painted+=1
   end
  end
 end
 world.folder:SetAttribute('DeepwoodFinishedPaths',painted)
 world.folder:SetAttribute('DeepwoodGroundedVergeCliffs',(world.folder:GetAttribute('DeepwoodGroundedVergeCliffs')or 0)+grounded)
 world.folder:SetAttribute('DeepwoodLandmarkPrunedTrees',(world.folder:GetAttribute('DeepwoodLandmarkPrunedTrees')or 0)+pruned)
end
return D
