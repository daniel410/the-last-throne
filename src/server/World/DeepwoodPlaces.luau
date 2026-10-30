-- Authored places and optional walking loops inside the existing story footprint.
-- Small height changes use two wide ramps; no jump, reward or story gate is added.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.DeepwoodContent)
local Bounds=require(Shared.DeepwoodBounds)
local Access=require(Shared.DeepwoodAccess)
local Env=require(script.Parent.DeepwoodEnvironment)
local Places={version=1}
local C={earth=Color3.fromRGB(128,116,77),stone=Color3.fromRGB(137,148,119),moss=Color3.fromRGB(101,126,79),wood=Color3.fromRGB(105,76,46),gold=Color3.fromRGB(219,176,82),cloth=Color3.fromRGB(38,86,133),root=Color3.fromRGB(73,68,66),water=Color3.fromRGB(104,182,186)}
local themes={['DW-01']='Old Pilgrim Grove',['DW-02']='Scattered Caravan',['DW-03']='Ranger Overlook',['DW-04']='Ruined Cloister',['DW-05']='Occupied Courtyard',['DW-06']='Root Sanctuary',['DW-07']='Broken Seal Circle',['DW-S1']='Stolen Supply Camp',['DW-S2']='Quarry Watercourse',['DW-S3']='Fallen Standard Ridge'}
local function part(parent,name,size,cf,color,material,solid)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=typeof(cf)=='Vector3' and CFrame.new(cf) or cf;p.Color=color;p.Material=material or Enum.Material.Slate
 p.Anchored=true;p.CanTouch=false;p.CanCollide=solid==true;p.CanQuery=solid==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if not solid then p:SetAttribute('TLTDecorative',true) end
 p.Parent=parent;return p
end
local function strip(parent,name,a,b,width,color,solid)
 local d=b-a;if d.Magnitude<.1 then return end
 local cf=CFrame.lookAt((a+b)/2,b)
 return part(parent,name,Vector3.new(width,solid and 1 or .08,d.Magnitude+.4),cf-cf.UpVector*(solid and .5 or 0),color,solid and Enum.Material.Slate or Enum.Material.Ground,solid)
end
local function segmentDistance(p,a,b)
 local d=b-a;local t=math.clamp((p-a):Dot(d)/math.max(.001,d:Dot(d)),0,1);return (p-a-d*t).Magnitude
end
local function reservations(world,id)
 local z=Content.zones[id];local center=Vector3.new(table.unpack(z.center));local anchors={world.spawns[id].Position};local lanes={}
 for _,ch in ipairs(Content.chapters) do
  local previous=world.spawns[id].Position
  for _,g in ipairs(ch.goals) do
   local p=Vector3.new(table.unpack(g.position))
   if math.abs(p.Y-center.Y)<1 and math.abs(p.X-center.X)<z.size[1]/2 and math.abs(p.Z-center.Z)<z.size[2]/2 then
    table.insert(anchors,p);table.insert(lanes,{center,p})
    if ch.zone==id then table.insert(lanes,{previous,p});previous=p end
    for _,step in ipairs(g.activity and g.activity.steps or {}) do table.insert(anchors,Vector3.new(table.unpack(step.position))) end
   end
  end
 end
 local props={}
 for _,p in ipairs(world.terrain[id]:GetDescendants()) do if p:IsA('BasePart') and p.CanCollide and p.Position.Y+p.Size.Y/2>center.Y+1 and p.Position.Y-p.Size.Y/2<center.Y+8 then table.insert(props,p) end end
 return anchors,lanes,props
end
local function location(world,id)
 local z=Content.zones[id];local center=Vector3.new(table.unpack(z.center));local anchors,lanes,props=reservations(world,id)
 local small=id:find('DW-S',1,true)~=nil;local halfX,halfZ=small and 50 or 68,small and 26 or 36
 local best,score
 for x=-z.size[1]/2+halfX+24,z.size[1]/2-halfX-24,12 do
  for zz=-z.size[2]/2+halfZ+24,z.size[2]/2-halfZ-24,12 do
   local p=center+Vector3.new(x,0,zz);local clearance=math.huge
   for _,a in ipairs(anchors) do
    local dx,dz=math.max(0,math.abs(p.X-a.X)-halfX),math.max(0,math.abs(p.Z-a.Z)-halfZ)
    clearance=math.min(clearance,math.sqrt(dx*dx+dz*dz)-30)
   end
   for _,lane in ipairs(lanes) do
    local n=math.max(1,math.ceil((lane[2]-lane[1]).Magnitude/10))
    for k=0,n do
     local q=lane[1]:Lerp(lane[2],k/n);local dx,dz=math.max(0,math.abs(p.X-q.X)-halfX),math.max(0,math.abs(p.Z-q.Z)-halfZ)
     clearance=math.min(clearance,math.sqrt(dx*dx+dz*dz)-18)
    end
   end
   for _,prop in ipairs(props) do
    local dx,dz=math.max(0,math.abs(p.X-prop.Position.X)-halfX-prop.Size.X/2),math.max(0,math.abs(p.Z-prop.Position.Z)-halfZ-prop.Size.Z/2)
    clearance=math.min(clearance,math.sqrt(dx*dx+dz*dz)-4)
   end
   if not score or clearance>score then best,score=p,clearance end
  end
 end
 return best,score,small,anchors
end
local function flag(parent,p,color)
 part(parent,'StandardPole',Vector3.new(.5,14,.5),p+Vector3.new(0,7,0),C.wood,Enum.Material.Wood,false)
 part(parent,'TornStandard',Vector3.new(5,7,.2),CFrame.new(p+Vector3.new(2.5,10,0))*CFrame.Angles(0,.3,.08),color,Enum.Material.Fabric,false)
end
local function crate(parent,p,size)
 part(parent,'WeatheredCargo',Vector3.one*size,p+Vector3.new(0,size/2,0),C.wood,Enum.Material.Wood,false)
 for _,x in ipairs({-.36,.36}) do part(parent,'IronCargoBand',Vector3.new(.2,size+.1,size+.1),p+Vector3.new(x*size,size/2,0),C.root,Enum.Material.Metal,false) end
end
local function scatter(world,parent,id,terrace)
 local zone=Content.zones[id];local center=Vector3.new(table.unpack(zone.center));local anchors,lanes,props=reservations(world,id)
 local candidates={}
 for i=1,110 do
  local x=((i*73)%109)/108*zone.size[1]*.76-zone.size[1]*.38
  local z=((i*47)%107)/106*zone.size[2]*.76-zone.size[2]*.38
  local p=center+Vector3.new(x,0,z);local clear=true
  if terrace and math.abs(p.X-terrace.X)<92 and math.abs(p.Z-terrace.Z)<70 then clear=false end
  for _,q in ipairs(anchors) do if (p-q).Magnitude<42 then clear=false end end
  for _,lane in ipairs(lanes) do if segmentDistance(p,lane[1],lane[2])<23 then clear=false end end
  for _,prop in ipairs(props) do if (p-Vector3.new(prop.Position.X,p.Y,prop.Position.Z)).Magnitude<math.min(25,prop.Size.Magnitude/2)+12 then clear=false end end
  if clear then table.insert(candidates,p) end
 end
 local planted={};local limit=id:find('DW-S',1,true) and 8 or 20
 for _,p in ipairs(candidates) do
  local clear=true;for _,q in ipairs(planted) do if (p-q).Magnitude<32 then clear=false end end
  if clear and #planted<limit then
   table.insert(planted,p);local i=#planted
   Env.tree(parent,p,24+(i%4)*4,false)
   part(parent,'GroveTrunk',Vector3.new(3,12,3),p+Vector3.new(0,6,0),C.wood,Enum.Material.Wood,true).Transparency=1
   local color=(id=='DW-06' or id=='DW-07') and Color3.fromRGB(112,123,88) or Color3.fromRGB(125,150,75)
   local patch=part(parent,'LeafLitter',Vector3.new(.06,13+i%4,10),CFrame.new(p+Vector3.new(0,.08,0))*CFrame.Angles(0,0,math.pi/2),color,Enum.Material.LeafyGrass,false);patch.Shape=Enum.PartType.Cylinder
   for k=1,3 do
    local offset=Vector3.new(math.cos(k*2.1+i)*7,0,math.sin(k*2.1+i)*7)
    local shrub=part(parent,'ForestUnderstory',Vector3.new(4,1.2+k*.3,4),p+offset+Vector3.new(0,.7,0),color,Enum.Material.Grass,false);shrub.Shape=Enum.PartType.Ball
   end
  end
 end
 parent:SetAttribute('AddedGroves',#planted)
end
local function dress(parent,id,p,s)
 local function stone(name,x,y,z,sx,sy,sz,solid)
  return part(parent,name,Vector3.new(sx,sy,sz)*s,p+Vector3.new(x,y,z)*s,C.stone,Enum.Material.Slate,solid)
 end
 if id=='DW-01' or id=='DW-03' then
  Env.tree(parent,p+Vector3.new(-26,0,-14)*s,id=='DW-03' and 62 or 48,true)
  for _,x in ipairs({-26,26}) do flag(parent,p+Vector3.new(x,0,15)*s,C.cloth) end
  for i=1,4 do stone('PilgrimWaystone',i*13-32.5,2,-17,4,4,4,false) end
 elseif id=='DW-02' or id=='DW-S1' then
  for _,x in ipairs({-25,25}) do
   part(parent,'CampCanopyPost',Vector3.new(.6,10,.6)*s,p+Vector3.new(x,5,-12)*s,C.wood,Enum.Material.Wood,false)
   for i=1,3 do crate(parent,p+Vector3.new(x+i*3-6,0,15)*s,(3+i%2)*s) end
  end
  for _,sign in ipairs({-1,1}) do
   part(parent,'CaravanAwning',Vector3.new(56,.25,10)*s,CFrame.new(p+Vector3.new(0,10,-12+sign*4.5)*s)*CFrame.Angles(sign*.22,0,0),C.cloth,Enum.Material.Fabric,false)
  end
  for i=1,3 do
   part(parent,'RolledBedroll',Vector3.new(4,.5,8)*s,p+Vector3.new(i*9-18,.25,-12)*s,Color3.fromRGB(153,136,93),Enum.Material.Fabric,false)
   local barrel=part(parent,'SupplyBarrel',Vector3.new(4,3,3)*s,CFrame.new(p+Vector3.new(22,2,i*4-14)*s)*CFrame.Angles(0,0,math.pi/2),C.wood,Enum.Material.Wood,false);barrel.Shape=Enum.PartType.Cylinder
  end
 elseif id=='DW-04' or id=='DW-05' then
  for _,x in ipairs({-27,0,27}) do
   stone('CloisterPillar',x,8,-17,4,16,4,true)
   stone('BrokenCapital',x,16.5,-17,7,2,7,false)
  end
  for _,x in ipairs({-25,25}) do stone('BrokenCloisterWall',x,3,16,14,6,4,true) end
  stone('CloisterLintel',-13.5,17,-17,31,3,5,false)
  if id=='DW-05' then flag(parent,p+Vector3.new(26,0,10)*s,Color3.fromRGB(129,52,43)) end
 elseif id=='DW-06' or id=='DW-07' then
  for i=1,8 do
   local a=i*math.pi/4;local q=p+Vector3.new(math.cos(a)*29,0,math.sin(a)*17)*s
   if math.abs(math.cos(a))<.8 then
    local root=part(parent,'AncientRootSpire',Vector3.new(4,10+i%3*3,4)*s,CFrame.new(q+Vector3.new(0,5,0)*s)*CFrame.Angles(.12,0,.18),C.root,Enum.Material.Wood,false)
    if i%2==0 then part(parent,'FaintSealShard',Vector3.new(1,2,1)*s,root.Position+Vector3.new(0,5,0)*s,Color3.fromRGB(155,122,202),Enum.Material.Neon,false) end
   end
  end
 elseif id=='DW-S2' then
  for i=1,5 do
   local q=p+Vector3.new(i*12-36,.16,-14+math.sin(i)*4)*s
   part(parent,'ShallowWatercourse',Vector3.new(15,.15,9)*s,q,C.water,Enum.Material.Glass,false).Transparency=.25
   Env.cliff(parent,q+Vector3.new(0,-2,-10)*s,7+i)
  end
  for i=1,8 do part(parent,'QuarryCrossingPlank',Vector3.new(2,.25,13)*s,p+Vector3.new(i*2.5-11,.2,-12)*s,C.wood,Enum.Material.Wood,false) end
 elseif id=='DW-S3' then
  for i=1,5 do
   local x=i*11-33;part(parent,'FallenTimber',Vector3.new(8,2,3)*s,CFrame.new(p+Vector3.new(x,1,-15)*s)*CFrame.Angles(0,i*.4,0),C.wood,Enum.Material.Wood,false)
  end
  flag(parent,p+Vector3.new(-22,0,12)*s,Color3.fromRGB(129,52,43));flag(parent,p+Vector3.new(22,0,12)*s,C.cloth)
 end
end
function Places.create(world)
 local old=world.terrain:FindFirstChild('DeepwoodPlaces')
 if old and old:GetAttribute('PlacesVersion')==Places.version then return old end
 if old then old:Destroy() end
 local folder=Instance.new('Folder');folder.Name='DeepwoodPlaces';folder.Parent=world.terrain
 local ids={};for id in pairs(Content.zones) do table.insert(ids,id) end;table.sort(ids)
 for _,id in ipairs(ids) do
  local p,clearance,small=location(world,id)
  local place=Instance.new('Model');place.Name=id;place:SetAttribute('PlaceTheme',themes[id]);place:SetAttribute('Clearance',clearance)
  -- Never put a new solid in an existing fight, checkpoint or interaction lane.
  if clearance>=0 then
   local s=small and .7 or 1;local rise=small and 4 or 6;local x=36*s;local run=32*s
   place:SetAttribute('TerraceCenter',p);place:SetAttribute('TerraceRise',rise)
   local camp=id=='DW-02' or id=='DW-03' or id=='DW-S1'
   local organic=id=='DW-01' or id=='DW-06' or id=='DW-07'
   local terrace=part(place,'WalkableTerrace',organic and Vector3.new(rise,72*s,64*s) or Vector3.new(72*s,rise,40*s),CFrame.new(p+Vector3.new(0,rise/2,0))*(organic and CFrame.Angles(0,0,math.pi/2) or CFrame.new()),camp and C.wood or (id=='DW-06' or id=='DW-07') and C.root or C.moss,camp and Enum.Material.WoodPlanks or Enum.Material.Slate,true)
   if organic then terrace.Shape=Enum.PartType.Cylinder;x=26*s end
   for _,sign in ipairs({-1,1}) do
    strip(place,'WalkableRamp',p+Vector3.new(sign*(x+run),0,0),p+Vector3.new(sign*x,rise,0),24*s,C.stone,true)
   end
   local previous=p+Vector3.new(-x-run,0,0)
   for i=1,12 do
    local t=i/12;local nextPoint=p+Vector3.new(-math.cos(t*math.pi)*(x+run),.12,math.sin(t*math.pi)*52*s)
    strip(place,'ReturnLoop',previous,nextPoint,14,C.earth,false);previous=nextPoint
   end
   dress(place,id,p+Vector3.new(0,rise,0),s)
  else
   -- A dense authored activity area takes priority; keep this pocket decorative.
   place:SetAttribute('TerraceSkipped',true)
   dress(place,id,p,.7)
  end
  scatter(world,place,id,clearance>=0 and p or nil)
  place.Parent=folder;task.wait()
 end
 -- Replace the unused ruler-straight strip with a gently winding, broken track.
 -- The full 96-stud foundation stays unobstructed and authoritative.
 for index,edge in ipairs(Access.edges) do
  local first,last=Bounds.ends(edge);local a,b=Vector3.new(table.unpack(first)),Vector3.new(table.unpack(last));local d=b-a
  local side=Vector3.new(-d.Z,0,d.X).Unit;local n=math.max(3,math.ceil(d.Magnitude/18))
  local model=Instance.new('Model');model.Name='WindingPass_'..index
  local function point(t)return a:Lerp(b,t)+side*math.sin(t*math.pi*2)*12+Vector3.new(0,.16,0)end
  for i=1,n do
   local from,to=point((i-1)/n),point(i/n)
   strip(model,'WornForestTrack',from,to,18+(i%3)*2,C.earth,false)
   if i%3==0 then
    local q=(from+to)/2+side*(i%2==0 and 30 or -30)
    Env.cliff(model,q-Vector3.new(0,1,0),4+i%4)
   end
  end
  model.Parent=folder
  local road=world.terrain:FindFirstChild('ConnectedPath_'..edge[1]..'_'..edge[2]);if road then road.Transparency=1;road.CanCollide=false;road.CanQuery=false end
  task.wait()
 end
 for _,region in ipairs(world.terrain:GetChildren()) do
  local stripPart=region:IsA('Model') and region:FindFirstChild('BroadStoneTrail');if stripPart then stripPart.Transparency=1 end
 end
 folder:SetAttribute('PlacesVersion',Places.version)
 return folder
end
return Places
