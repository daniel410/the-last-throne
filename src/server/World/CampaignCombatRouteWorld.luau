-- Expanded real ground and themed walking trails, reserved before the scenery pass.
-- Existing pinned TD trees, cliffs and architectural landmarks dress the widened
-- footprint in EpicWorldArt; this module adds the readable foreground route.
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local K=require(script.Parent.EpicEnvironmentKit)
local W={version=1};local V=Vector3.new
local themes={DW='Deepwood',GW='Gloamwood',FV='FrozenVale',EC='EmberCaldera',HG='HauntedGraveyard'}
local function vec(p)return V(table.unpack(p))end
function W.create(world,scope)
 local root=world.folder:FindFirstChild('CampaignCombatRoutes')or Instance.new('Folder');root.Name='CampaignCombatRoutes';root.Parent=world.folder
 local name='Epic'..scope.epic;if root:FindFirstChild(name)then return end
 local scene=Instance.new('Folder');scene.Name=name;scene:SetAttribute('RouteWorldVersion',W.version);scene.Parent=root
 local foundation=Instance.new('Model');foundation.Name='RouteFoundation'..scope.epic;foundation.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;foundation.Parent=world.terrain
 for id,z in pairs(scope.content.zones)do
  local theme=themes[id:sub(1,2)];local pal=K.palette[theme]
  local material=theme=='FrozenVale'and Enum.Material.Snow or theme=='EmberCaldera'and Enum.Material.Basalt or theme=='HauntedGraveyard'and Enum.Material.Slate or Enum.Material.Grass
  local floor=K.part(foundation,'JourneyGround',V(z.size[1],64,z.size[2]),CFrame.new(vec(z.center)-V(0,32,0)),pal.ground,material)
  floor.CanCollide=true;floor.CanQuery=true;floor:SetAttribute('RouteZone',id)
 end
 for _,c in ipairs(scope.content.chapters)do
  local theme=themes[c.id:sub(1,2)];local pal=K.palette[theme]
  for _,g in ipairs(c.goals)do local plan=c.combatRoutes[g.id]
   if plan then
    local site=Instance.new('Model');site.Name=c.id..'_'..g.id;site.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;site:SetAttribute('ChapterId',c.id);site:SetAttribute('GoalId',g.id);site:SetAttribute('Theme',theme);site:SetAttribute('RouteTitle',plan.title);site.Parent=scene
    local previous=vec(g.position)
    for index,point in ipairs(plan.points)do
     local at=vec(point)
     local start=previous;local delta=at-start
     if delta.Magnitude>1 then
      local normal=V(-delta.Z,0,delta.X).Unit
      local last=start
      for segment=1,8 do
       local t=segment/8;local p=start:Lerp(at,t)+normal*math.sin(t*math.pi)*(theme=='FrozenVale'and 8 or 13)*(index%2==0 and 1 or -1)
       local path=K.beam(site,'JourneyWalkingTrail',last+V(0,.09,0),p+V(0,.09,0),24,pal.ground:Lerp(pal.trim,.28),theme=='EmberCaldera'and Enum.Material.Cobblestone or Enum.Material.Ground)
       path.Size=V(24,.12,path.Size.Z+2.5);path:SetAttribute('RouteZone',c.zone);last=p
      end
     end
     local verge=at+V(index%2==0 and 34 or -34,0,27)
     K.lantern(site,verge,pal)
     if theme=='Gloamwood'then
      local a=K.part(site,'ScoutTrailPost',V(.8,7,.8),CFrame.new(verge+V(0,3.5,2)),pal.wood,Enum.Material.Wood)
      for bar=1,3 do K.part(site,'ThreeBarScoutSignal',V(2,.25,.15),a.CFrame*CFrame.new(0,bar*.6-1,-.5),pal.trim,Enum.Material.Metal)end
     elseif theme=='EmberCaldera'then
      for _,side in ipairs({-1,1})do K.part(site,'FreightTrailRail',V(.45,.2,12),CFrame.new(verge+V(side*4,.15,0)),pal.trim,Enum.Material.Metal)end
     elseif theme=='HauntedGraveyard'then
      K.part(site,'ProcessionalWaystone',V(2,3,1),CFrame.new(verge+V(3,1.5,0))*CFrame.Angles(0,.12,0),pal.rock,Enum.Material.Slate)
     elseif theme=='FrozenVale'then
      K.part(site,'SnowTrailMarker',V(1,4,1),CFrame.new(verge+V(3,2,0)),pal.wood,Enum.Material.Wood)
      K.part(site,'BlueTrailPennant',V(2,1.3,.1),CFrame.new(verge+V(4,3,0)),Color3.fromRGB(42,84,153),Enum.Material.Fabric)
     end
     previous=at
    end
   end
  end
 end
 return scene
end
-- The art pass grounds the old road mesh on retained surfaces. Reconcile its
-- small Y offsets with the widened real floor, then add safe midground clusters.
function W.finish(world,scope)
 local Env=require(script.Parent.DeepwoodEnvironment)
 local Areas=require(Shared.CampaignAreas)
 local Bounds=require(Shared.CampaignBounds)
 local root=world.folder.CampaignCombatRoutes['Epic'..scope.epic]
 if root:GetAttribute('Finished')then return end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.terrain,workspace.Terrain};ray.RespectCanCollide=true
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and (p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail')then
   local y,id=Bounds.region(p.Position.X,p.Position.Z)
   local z=id and scope.content.zones[id]
   if z and p.CFrame.UpVector.Y>.999 and math.abs(p.Position.Y-y)<2 then
    local pal=K.palette[themes[id:sub(1,2)]]
    p.CFrame+=V(0,y+.12-p.Position.Y,0)
    p.Color=pal.ground:Lerp(pal.trim,.28);p.Material=Enum.Material.Ground
   end
  end
 end
 local function distance(p,a,b)
  local d=V(b.X-a.X,0,b.Z-a.Z);local t=math.clamp(V(p.X-a.X,0,p.Z-a.Z):Dot(d)/math.max(.001,d:Dot(d)),0,1)
  return (V(p.X-a.X,0,p.Z-a.Z)-d*t).Magnitude
 end
 local anchors,lines={},{}
 for _,c in ipairs(scope.content.chapters)do
  for _,g in ipairs(c.goals)do
   anchors[#anchors+1]={vec(g.position),#g.enemies>0 and 76 or 28}
   local previous=vec(g.position)
   for _,point in ipairs(c.combatRoutes[g.id]and c.combatRoutes[g.id].points or {})do
    local at=vec(point);anchors[#anchors+1]={at,43};lines[#lines+1]={previous,at};previous=at
   end
   for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then anchors[#anchors+1]={vec(step.position),30}end end
  end
 end
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and (p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ReturnLoop')then
  lines[#lines+1]={p.CFrame:PointToWorldSpace(V(0,0,-p.Size.Z/2)),p.CFrame:PointToWorldSpace(V(0,0,p.Size.Z/2))}
 end end
 local groves=Instance.new('Folder');groves.Name='RouteMidground';groves.Parent=root
 local placed={}
 local function safe(at,r,z)
  if not Areas.contains(z,at.X,at.Z,-r-8)then return false end
  for _,a in ipairs(anchors)do if math.abs(at.Y-a[1].Y)<35 and distance(at,a[1],a[1])<r+a[2]then return false end end
  for _,l in ipairs(lines)do if math.abs(at.Y-l[1].Y)<35 and distance(at,l[1],l[2])<r+24 then return false end end
  for _,p in ipairs(placed)do if distance(at,p[1],p[1])<r+p[2]+3 then return false end end
  return true
 end
 for _,c in ipairs(scope.content.chapters)do
  local theme=themes[c.id:sub(1,2)];local pal=K.palette[theme];local z=C.zones[c.zone]
  for _,g in ipairs(c.goals)do local plan=c.combatRoutes[g.id]
   for index,point in ipairs(plan and plan.points or {})do
    local at=vec(point);local count=0
    for _,offset in ipairs({V(-62,0,47),V(67,0,-42),V(-84,0,-54),V(83,0,58),V(12,0,86),V(-14,0,-89)})do
     local q=at+offset;local radius=(theme=='Deepwood'or theme=='Gloamwood')and 17 or 13
     if safe(q,radius,z)then
      local hit=workspace:Raycast(q+V(0,5,0),V(0,-10,0),ray)
      if hit and math.abs(hit.Position.Y-q.Y)<1 then
       if theme=='Deepwood'or theme=='Gloamwood'then
        Env.asset(groves,'ForestTree',q,32+(index%3)*5)
        if theme=='Gloamwood'then K.web(groves,q+V(-8,19,0),q+V(8,24,0),q+V(0,12,4),pal)end
       elseif theme=='FrozenVale'then Env.asset(groves,'SnowTree',q,26+(index%3)*3)
       elseif theme=='EmberCaldera'then
        K.rock(groves,q+V(0,4,0),V(11,12,9),pal.rock,index)
        K.rock(groves,q+V(6,1,4),V(7,5,9),pal.trim,index+1)
       else K.tree(groves,q,27+(index%3)*3,pal,true)end
       placed[#placed+1]={q,radius};count+=1
      end
     end
     if count==2 then break end
    end
   end
  end
 end
 require(script.Parent.CampaignSceneryCollision).apply(root)
 root:SetAttribute('RouteMidgroundClusters',#placed);root:SetAttribute('Finished',true)
end
return W
