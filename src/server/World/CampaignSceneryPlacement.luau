-- Move complete scenery assemblies off authored walking/escort lines. Never
-- solve an obstruction by making a visible wall or tree non-physical again.
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Route=require(game.ReplicatedStorage.Shared.CampaignNavigationRoute)
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={};local V=Vector3.new
local function vec(t)return V(table.unpack(t))end
local function routes(world)
 local lines={}
 local function add(a,b,road)
  -- Reports in another region use the regional road network/fast travel, not
  -- a straight chord through the intervening buildings.
  local _,from=Bounds.region(a.X,a.Z);local _,to=Bounds.region(b.X,b.Z)
  if not road and from and to and from~=to then return end
  a+=V(0,3.7,0);b+=V(0,3.7,0)
  local count=math.max(1,math.ceil((b-a).Magnitude/256))
  for i=1,count do
   local f,t=a:Lerp(b,(i-1)/count),a:Lerp(b,i/count)
   table.insert(lines,{f,t,low=V(math.min(f.X,t.X)-10,math.min(f.Y,t.Y)-3,math.min(f.Z,t.Z)-10),high=V(math.max(f.X,t.X)+10,math.max(f.Y,t.Y)+3,math.max(f.Z,t.Z)+10)})
  end
 end
 for _,c in ipairs(C.chapters)do
  local previous=world.spawns[c.zone]and world.spawns[c.zone].Position
  if previous then for _,g in ipairs(c.goals)do
   local targets={}
   local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points
   if points and #points>0 then for _,point in ipairs(points)do targets[#targets+1]={position=point}end
   else for _,step in ipairs(g.activity and g.activity.steps or {{position=g.position}})do targets[#targets+1]=step end end
   for _,s in ipairs(targets)do if s.position then
    local at=vec(s.position)
    if c.combatRoutes and c.combatRoutes[g.id]then add(at-V(24,0,0),at+V(24,0,0));add(at-V(0,0,24),at+V(0,0,24))end
    local path=Route.route({previous.X,previous.Y,previous.Z},s.position)
    for i=2,#path do add(vec(path[i-1]),vec(path[i]))end
    previous=at
   end end
  end end
 end
 -- Visible curved roads/return loops have their own authored approach lanes.
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and p.Transparency<.5 and (p.Name=='WornCurvedRoute'or p.Name=='ReturnLoop'or p.Name=='RegionalReturnTrail')then
   for _,side in ipairs({-1,0,1})do
    local x=side*math.min(6,math.max(0,p.Size.X/2-2))
    add(p.CFrame:PointToWorldSpace(V(x,0,-p.Size.Z/2)),p.CFrame:PointToWorldSpace(V(x,0,p.Size.Z/2)),true)
   end
  end
 end
 return lines
end
-- Existing regional roads can cross a new wing. Cut actual door openings in
-- its static wall beams; never leave a drawn road passing through a solid wall.
function M.openGalleries(world,root)
 local lines=routes(world);local opened=0
 for _,wall in ipairs(root:GetDescendants())do
  if wall:IsA('BasePart')and (wall.Name=='IceGalleryWall'or wall.Name=='RootGallery')then
   local spans={{-wall.Size.Z/2,wall.Size.Z/2}}
   for _,line in ipairs(lines)do
    local a,b=wall.CFrame:PointToObjectSpace(line[1]),wall.CFrame:PointToObjectSpace(line[2])
    local first,last=0,1
    for _,axis in ipairs({'X','Y'})do
     local half=wall.Size[axis]/2+(axis=='X'and 4 or 3);local delta=b[axis]-a[axis]
     if math.abs(delta)<.001 then
      if math.abs(a[axis])>half then first=2;break end
     else
      local t,u=(-half-a[axis])/delta,(half-a[axis])/delta
      first=math.max(first,math.min(t,u));last=math.min(last,math.max(t,u))
     end
    end
    if first<=last then
     local x,y=a:Lerp(b,first).Z,a:Lerp(b,last).Z
     local low,high=math.min(x,y)-4,math.max(x,y)+4
     local nextSpans={}
     for _,span in ipairs(spans)do
      if high<=span[1]or low>=span[2]then table.insert(nextSpans,span)
      else
       if low>span[1]+1 then table.insert(nextSpans,{span[1],low})end
       if high<span[2]-1 then table.insert(nextSpans,{high,span[2]})end
      end
     end
     spans=nextSpans
    end
   end
   if #spans~=1 or spans[1][1]~=-wall.Size.Z/2 or spans[1][2]~=wall.Size.Z/2 then
    for _,span in ipairs(spans)do
     local piece=wall:Clone();piece.Size=V(wall.Size.X,wall.Size.Y,span[2]-span[1]);piece.CFrame=wall.CFrame*CFrame.new(0,0,(span[1]+span[2])/2)
     piece:SetAttribute('SceneryRouteOpening',true);piece.Parent=wall.Parent
    end
    wall:Destroy();opened+=1
   end
  end
 end
 root:SetAttribute('GalleryRouteOpenings',opened)
 return opened
end
function M.apply(world,root)
 local lines=routes(world)
 local probe=Instance.new('Part');probe.Name='SceneryPlacementProbe';probe.Size=V(16,5,16);probe.Anchored=true;probe.Transparency=1;probe.CanCollide=false;probe.CanQuery=false;probe.CanTouch=false;probe.Parent=workspace
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.RespectCanCollide=true
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.RespectCanCollide=true
 local function blocked(m)
  local cf,size=m:GetBoundingBox();local radius=size.Magnitude/2
  local low,high=cf.Position-V(radius,radius,radius),cf.Position+V(radius,radius,radius)
  overlap.FilterDescendantsInstances={m};ray.FilterDescendantsInstances={m}
  for _,l in ipairs(lines)do
   if low.X<l.high.X and high.X>l.low.X and low.Y<l.high.Y and high.Y>l.low.Y and low.Z<l.high.Z and high.Z>l.low.Z then
    probe.CFrame=CFrame.new(l[1])
    local hits=workspace:GetPartsInPart(probe,overlap)
    if #hits>0 then return true,hits[1],l end
    local hit=(l[2]-l[1]).Magnitude>.01 and workspace:Blockcast(probe.CFrame,probe.Size,l[2]-l[1],ray)
    if hit then return true,hit.Instance,l end
   end
  end
  return false
 end
 local floorRay=RaycastParams.new();floorRay.FilterType=Enum.RaycastFilterType.Include;floorRay.FilterDescendantsInstances={world.terrain,workspace.Terrain};floorRay.RespectCanCollide=true
 local units={}
 for _,site in ipairs(root:GetChildren())do
  for _,group in ipairs(site:GetChildren())do
   if group.Name=='AuthoredVista'or group.Name=='LayeredVegetation'or group.Name=='TDScenicComposition'then
    for _,m in ipairs(group:GetChildren())do if m:IsA('Model')then
     if m.Name=='ShelteredQuarter'then
      for _,cabin in ipairs(m:GetChildren())do if cabin:IsA('Model')then table.insert(units,cabin)end end
     else table.insert(units,m)end
    end end
   end
  end
 end
 -- Legacy forge gates are complete three-part assemblies. Move both posts
 -- and their lintel together instead of leaving a displaced support behind.
 for _,m in ipairs(world.terrain:GetDescendants())do if m:IsA('Model')and m:GetAttribute('LegacyForgeGate')then table.insert(units,m)end end
 local moved=0
 for index,m in ipairs(units)do
  local obstructed,obstacle,line=blocked(m)
  if obstructed then
   local origin=m:GetPivot();local cf,size=m:GetBoundingBox();local base=cf.Position-V(0,size.Y/2,0)
   local found=false
   for ring=1,16 do
    for _,dir in ipairs({V(1,0,0),V(-1,0,0),V(0,0,-1),V(0,0,1),V(1,0,-1),V(-1,0,-1),V(1,0,1),V(-1,0,1)})do
     local delta=dir*ring*24
     local hit=workspace:Raycast(base+delta+V(0,80,0),V(0,-176,0),floorRay)
     if hit and math.abs(hit.Position.Y-base.Y)<48 then
      m:PivotTo(origin+delta+V(0,hit.Position.Y-base.Y,0))
      if not blocked(m)then found=true;break end
     end
    end
    if found then break end
    if ring%3==0 then task.wait()end
   end
   if found then
    local delta=m:GetPivot().Position-origin.Position
    local ground=m:GetAttribute('GroundPosition');if ground then m:SetAttribute('GroundPosition',ground+delta)end
    m:SetAttribute('SceneryOriginalPivot',m:GetAttribute('SceneryOriginalPivot')or origin);moved+=1
   else m:PivotTo(origin);warn('Scenery route relocation unavailable: '..m:GetFullName()..' / '..obstacle.Name..' / '..tostring(line[1])..' -> '..tostring(line[2]))end
  end
  if index%20==0 then task.wait()end
 end
 probe:Destroy()
 root:SetAttribute('SceneryRouteRelocations',(root:GetAttribute('SceneryRouteRelocations')or 0)+moved)
 return moved
end
return M
