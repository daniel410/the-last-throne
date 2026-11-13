-- Authored DW-03 composition, pinned real meshes rather than a primitive fallback.
local K=require(script.Parent.EpicEnvironmentKit)
local Geometry=require(script.Parent.DeepwoodElderGroveGeometry)
local V=Vector3.new
local Grove={version=2,origin=V(-280,18.08,-1728)}
function Grove.build(group,ground)
 local template=assert(game.ServerStorage:FindFirstChild('DeepwoodElderGroveTemplate'),'Pinned Elder Grove template missing')
 local m=template:Clone();m.Name='ElderGrove';m.WorldPivot=CFrame.identity
 m:SetAttribute('DeepwoodConceptRole','Signature');m:SetAttribute('ConceptZone','DW-03')
 m:SetAttribute('GrovePruneRadius',86)
 local previewGround=m:FindFirstChild('GroveGround');if previewGround then previewGround.Transparency=1;previewGround.CastShadow=false end
 local bodies=Instance.new('Model');bodies.Name='GroundedBodies';bodies.Parent=m
 for _,r in ipairs(Geometry.rocks)do
  local p=K.part(bodies,'FacetedOutcrop',V(table.unpack(r.size)),CFrame.new(V(table.unpack(r.position))),Color3.fromRGB(151,149,116),Enum.Material.Slate)
  p:SetAttribute('TLTSceneryDistance',420)
 end
 for _,at in ipairs(Geometry.saplings)do
  local a=V(table.unpack(at));local b=a+V(-2,15,-1);local c=a+V(1,27,0)
  for _,segment in ipairs({{a,b,3.5},{b,c,2.5}})do
   local p=K.beam(bodies,'WeatheredTrunk',segment[1],segment[2],segment[3],Color3.fromRGB(126,83,40),Enum.Material.Wood)
   p:SetAttribute('TLTSceneryDistance',420)
  end
 end
 -- Each mesh is a modest streaming unit; the whole grove is not atomic.
 for _,p in ipairs(m:GetChildren())do if p:IsA('MeshPart')then
  local chunk=Instance.new('Model');chunk.Name=p.Name;chunk.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;chunk.Parent=m;p.Parent=chunk
 end end
 local point,valid=ground(Grove.origin);assert(valid and math.abs(point.Y-Grove.origin.Y)<.75,'Elder Grove retained floor changed')
 m:PivotTo(CFrame.new(point));m:SetAttribute('GroundPosition',point)
 local _,ext=m:GetBoundingBox();m:SetAttribute('PlacementRadius',V(ext.X,0,ext.Z).Magnitude/2+2)
 require(script.Parent.CampaignSceneryCollision).apply(m)
 m.Parent=group
 return m,point,m:GetAttribute('PlacementRadius')
end
function Grove.finish(world,ray)
 local site=world.folder:FindFirstChild('EpicWorldArt')
 site=site and site:FindFirstChild('EpicWorldArt_1');site=site and site:FindFirstChild('DW-03')
 local group=site and site:FindFirstChild('DeepwoodConcept')
 if not(group and group:FindFirstChild('ElderGrove'))or(world.folder:GetAttribute('DeepwoodElderGroveVersion')or 0)>=Grove.version then return end
 local clearings={{V(0,0,35),64},{V(25,0,95),72},{V(-82,0,152),40}}
 for _,c in ipairs(clearings)do workspace.Terrain:FillCylinder(CFrame.new(Grove.origin+c[1]+V(0,18,0)),36,c[2],Enum.Material.Air)end
 local paths=Instance.new('Model');paths.Name='GroveRouteLinks';paths.Parent=group
 local hidden=0
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and not p.CanCollide and not p:IsDescendantOf(group)and(p:GetAttribute('DeepwoodConceptPath')or p.Name=='WornTrailPaver'or p.Name=='WornMeetingCourt'or p.Name=='MeetingFlagstone')then
   local q=p.Position-Grove.origin
   if(q.X-8)^2/150^2+(q.Z-45)^2/155^2<1 then p.Transparency=1;p.CastShadow=false;hidden+=1 end
  end
 end
 for _,route in ipairs({{{-170,0},{-130,15},{-100,45},{-80,80},{-65,130}},{{38,80},{45,110},{60,150},{78,188}},{{156,29},{180,40},{210,55}}})do
  for i=2,#route do
   local a=Grove.origin+V(route[i-1][1],0,route[i-1][2]);local b=Grove.origin+V(route[i][1],0,route[i][2]);local n=math.ceil((b-a).Magnitude/6)
   for j=0,n-1 do
    local at=a:Lerp(b,(j+.5)/n);local hit=workspace:Raycast(at+V(0,12,0),V(0,-30,0),ray)
    if hit and math.abs(hit.Position.Y-Grove.origin.Y)<1 then
     local p=K.part(paths,'GroveWalkingLink',V(7,.025,(b-a).Magnitude/n+.2),CFrame.lookAt(V(at.X,hit.Position.Y+.06,at.Z),V(b.X,hit.Position.Y+.06,b.Z)),Color3.fromRGB(166,147,96),Enum.Material.Cobblestone)
     p.CastShadow=false;p:SetAttribute('TLTSceneryDistance',420)
    end
   end
  end
 end
 world.folder:SetAttribute('DeepwoodGroveHiddenPaint',hidden)
 -- Replace only the old elder within the authored trunk area. Story actors stay.
 local old={}
 for _,m in ipairs(world.folder:GetDescendants())do
  if m:IsA('Model')and m.Name=='TDElderTree'and not m:IsDescendantOf(group)then
   local at=m:GetBoundingBox()
   if V(at.X-Grove.origin.X,0,at.Z-Grove.origin.Z).Magnitude<100 then old[#old+1]=m end
  end
 end
 for _,m in ipairs(old)do m:Destroy()end
 world.folder:SetAttribute('DeepwoodElderGroveVersion',Grove.version)
 world.folder:SetAttribute('DeepwoodReplacedElderTrees',(world.folder:GetAttribute('DeepwoodReplacedElderTrees')or 0)+#old)
end
return Grove
