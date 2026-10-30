-- Continuous ground beneath the authored clearings; rock/tree edges frame the
-- playable footprint. Only a small foundation model persists under streaming.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.DeepwoodContent)
local Access=require(Shared.DeepwoodAccess)
local Bounds=require(Shared.DeepwoodBounds)
local Env=require(script.Parent.DeepwoodEnvironment)
local Ground={}
local rock=Color3.fromRGB(91,107,78)
local function part(parent,name,size,cf,color,material)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
 p.Color=color;p.Material=material;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanTouch=false;p.CanCollide=true;p.CanQuery=true;p.Parent=parent;return p
end
function Ground.create(world)
 local previous=world:FindFirstChild('GroundedForest')
 local rebuild=previous and previous:GetAttribute('GroundedForestVersion')==1
 if rebuild then previous:Destroy() end
 -- Upgrade a generated Studio scene too, so reusing it cannot retain the
 -- rejected narrow bridge walls after the source changes.
 local terrain=world:FindFirstChild('TerrainBlockout')
 if terrain then
  for _,p in ipairs(terrain:GetChildren()) do if p.Name=='BridgeParapet' then p:Destroy() end end
  for _,edge in ipairs(Access.edges) do
   local road=terrain:FindFirstChild('ConnectedPath_'..edge[1]..'_'..edge[2])
   if road then
    local a,b=Bounds.ends(edge);local first,last=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
    road.Size=Vector3.new(24,2,(last-first).Magnitude+4);road.CFrame=CFrame.lookAt((first+last)/2,last)-Vector3.new(0,.9,0)
   end
  end
 end
 if previous and not rebuild then return end
 local container=Instance.new('Folder');container.Name='GroundedForest';container.Parent=world
 local foundation=Instance.new('Model');foundation.Name='PersistentGround';foundation.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
 local minX,minZ,maxX,maxZ=math.huge,math.huge,-math.huge,-math.huge
 for _,z in pairs(Content.zones) do
  minX=math.min(minX,z.center[1]-z.size[1]/2-180);maxX=math.max(maxX,z.center[1]+z.size[1]/2+180)
  minZ=math.min(minZ,z.center[3]-z.size[2]/2-180);maxZ=math.max(maxZ,z.center[3]+z.size[2]/2+180)
 end
 for x=minX,maxX-1,512 do for z=minZ,maxZ-1,512 do
  local sx,sz=math.min(512,maxX-x),math.min(512,maxZ-z)
  part(foundation,'ForestBedrock',Vector3.new(sx,68,sz),CFrame.new(x+sx/2,Bounds.backgroundHeight-34,z+sz/2),Color3.fromRGB(65,96,54),Enum.Material.Grass)
 end end
 -- These few simple colliders stay resident even when nearby art streams out.
 for id,z in pairs(Content.zones) do
  part(foundation,'Support_'..id,Vector3.new(z.size[1],z.center[2]+80,z.size[2]),CFrame.new(z.center[1],(z.center[2]-80)/2,z.center[3]),Color3.fromRGB(83,93,67),Enum.Material.Ground)
 end
 for i,edge in ipairs(Access.edges) do
  local a,b=Vector3.new(table.unpack(Content.zones[edge[1]].center)),Vector3.new(table.unpack(Content.zones[edge[2]].center))
  local delta=b-a
  local start,finish=Bounds.ends(edge);local first,last=Vector3.new(table.unpack(start)),Vector3.new(table.unpack(finish))
  part(foundation,'TrailSupport_'..i,Vector3.new(96,2,(last-first).Magnitude+4),CFrame.lookAt((first+last)/2,last)-Vector3.new(0,1,0),Color3.fromRGB(83,123,67),Enum.Material.Grass)
  local flat=Vector3.new(delta.X,0,delta.Z);local segments=math.ceil(flat.Magnitude/32)
  local slopes=Instance.new('Model');slopes.Name='EarthShoulders_'..i
  local side=Vector3.new(-flat.Unit.Z,0,flat.Unit.X)
  for n=1,segments do
   local t=(n-.5)/segments;local p=a:Lerp(b,t)
   local top=math.min(Bounds.trailHeight(edge,(n-1)/segments),Bounds.trailHeight(edge,n/segments))-.8
   part(foundation,'TrailEmbankment',Vector3.new(96,top+80,flat.Magnitude/segments+1),CFrame.lookAt(Vector3.new(p.X,(top-80)/2,p.Z),Vector3.new(p.X,(top-80)/2,p.Z)+flat),Color3.fromRGB(83,123,67),Enum.Material.Grass)
   for _,sign in ipairs({-1,1}) do
    local normal=side*sign;local center=Vector3.new(p.X,(top+Bounds.backgroundHeight)/2,p.Z)+normal*80
    local slope=Instance.new('WedgePart');slope.Name='TrailEarthSlope';slope.Size=Vector3.new(flat.Magnitude/segments+1,math.max(1,top-Bounds.backgroundHeight),64)
    slope.CFrame=CFrame.lookAt(center,center+normal);slope.Anchored=true;slope.CanTouch=false;slope.Color=Color3.fromRGB(83,123,67);slope.Material=Enum.Material.Grass;slope.Parent=slopes
   end
  end
  slopes.Parent=container;task.wait()
 end
 foundation.Parent=container;task.wait()
 local function boundary(parent,pos,tangent,length,index)
  local height=16+(index%4)*1.2
  local center=Vector3.new(pos.X,(pos.Y+height+Bounds.backgroundHeight)/2,pos.Z)
  local p=part(parent,'ForestBoundary',Vector3.new(8,pos.Y+height-Bounds.backgroundHeight,length+1),CFrame.lookAt(center,center+tangent),rock,Enum.Material.Slate)
  p:SetAttribute('TLTWorldBoundary',true)
 end
 local function rootedTree(parent,p,height)
  if p.Y>Bounds.backgroundHeight then
   local stem=part(parent,'ForestRoot',Vector3.new(3,p.Y-Bounds.backgroundHeight,3),CFrame.new(p.X,(p.Y+Bounds.backgroundHeight)/2,p.Z),Color3.fromRGB(87,66,45),Enum.Material.Wood)
   stem.CanCollide=false;stem.CanQuery=false;stem:SetAttribute('TLTDecorative',true)
  end
  Env.tree(parent,p,height,false)
 end
 local ids={};for id in pairs(Content.zones) do table.insert(ids,id) end;table.sort(ids)
 for _,id in ipairs(ids) do
  local zone=Content.zones[id];local c=Vector3.new(table.unpack(zone.center));local sx,sz=zone.size[1],zone.size[2]
  local region=Instance.new('Model');region.Name='ForestEdge_'..id
  local n=0
  for _,side in ipairs({{Vector3.new(1,0,0),Vector3.new(0,0,1),sx/2,sz},{Vector3.new(-1,0,0),Vector3.new(0,0,1),sx/2,sz},{Vector3.new(0,0,1),Vector3.new(1,0,0),sz/2,sx},{Vector3.new(0,0,-1),Vector3.new(1,0,0),sz/2,sx}}) do
   local normal,tangent,extent,length=table.unpack(side);local segments=math.ceil(length/24);local step=length/segments
   for i=1,segments do
    local p=c+normal*(extent-4)+tangent*((i-.5)*step-length/2);local outside=p+normal*12
    local other=Bounds.region(outside.X,outside.Z,0,id)
    if not other and not Bounds.connection(p.X,p.Z,20) then
     n+=1;boundary(region,p,tangent,step,n)
     if i%3==0 then
      local tree=p+normal*18-Vector3.new(0,6,0)
      rootedTree(region,tree,42+(i%4)*4)
      Env.cliff(region,p+normal*7-Vector3.new(0,7,0),26+(i%3)*3)
     end
    end
   end
  end
  region.Parent=container;task.wait()
 end
 -- Open forest passes: keep both road edges free of walls, including camera
 -- collision. Distant vegetation/mounds frame the pass beyond the wide verge.
 for index,edge in ipairs(Access.edges) do
  local a,b=Vector3.new(table.unpack(Content.zones[edge[1]].center)),Vector3.new(table.unpack(Content.zones[edge[2]].center))
  local flat=Vector3.new(b.X-a.X,0,b.Z-a.Z);local tangent=flat.Unit;local normal=Vector3.new(-tangent.Z,0,tangent.X)
  local segments=math.ceil(flat.Magnitude/32)
  local segment=Instance.new('Model');segment.Name='ForestTrail_'..index
  for i=1,segments do
   local t=(i-.5)/segments;local p=a:Lerp(b,t);p=Vector3.new(p.X,Bounds.trailHeight(edge,t),p.Z)
   for _,sign in ipairs({-1,1}) do
    local edgePos=p+normal*sign*(80+(i%3)*6)
    if not Bounds.region(edgePos.X,edgePos.Z,20) and not Bounds.connection(edgePos.X,edgePos.Z,12) then
     if i%2==0 then
      local mound=part(segment,'ForestMound',Vector3.new(36,18+(i%3)*3,42),CFrame.lookAt(Vector3.new(edgePos.X,Bounds.backgroundHeight+3,edgePos.Z),Vector3.new(edgePos.X,Bounds.backgroundHeight+3,edgePos.Z)+tangent),Color3.fromRGB(83,123,67),Enum.Material.Grass)
      mound.Shape=Enum.PartType.Ball;mound.CanCollide=false;mound.CanQuery=false;mound:SetAttribute('TLTDecorative',true)
      local offset=80+(i%3)*6;local height=Bounds.backgroundHeight+(p.Y-.8-Bounds.backgroundHeight)*(112-offset)/64
      rootedTree(segment,Vector3.new(edgePos.X,height,edgePos.Z),42+(i%3)*6)
     end
    end
   end
  end
  segment.Parent=container;task.wait()
 end
 container:SetAttribute('GroundedForestVersion',2)
end
return Ground
