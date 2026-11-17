-- Permanent worn approach only; personal rescue state remains client/server owned.
local Trail={version=1}
local V=Vector3.new
function Trail.build(parent,entry,target,ground,clear)
 local delta=V(target.X-entry.X,0,target.Z-entry.Z)
 if delta.Magnitude<4 or delta.Magnitude>160 then return nil,'Distance' end
 local normal=V(-delta.Z,0,delta.X).Unit
 local count=math.ceil(delta.Magnitude/4)
 local points={}
 -- Preflight the full width before adding anything: no partial dead-end trail.
 for i=0,count do
  local p=entry:Lerp(target,i/count)
  local center,ok=ground(p)
  if not ok then return nil,'Ground' end
  for _,side in ipairs({-3,3})do
   local edge,valid=ground(p+normal*side)
   if not valid or math.abs(edge.Y-center.Y)>.35 then return nil,'CrossSlope' end
  end
  if i>0 and math.abs(center.Y-points[i].Y)>.35 then return nil,'Slope' end
  if not clear(center)then return nil,'Occupied' end
  points[i+1]=center
 end
 local model=Instance.new('Model');model.Name='MineAccessTrail'
 model:SetAttribute('From',entry);model:SetAttribute('To',target)
 model:SetAttribute('TrailVersion',Trail.version)
 for i=1,count do
  local a,b=points[i],points[i+1]
  local p=Instance.new('Part');p.Name='WornMineApproach';p.Anchored=true
  p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
  p.Material=Enum.Material.Ground;p.Color=Color3.fromRGB(99,83,69)
  p.Size=V(6,.06,(b-a).Magnitude+.025)
  p.CFrame=CFrame.lookAt((a+b)/2+V(0,.035,0),b+V(0,.035,0))
  p:SetAttribute('EpicDetailSolid',false);p:SetAttribute('TLTSceneryDistance',700)
  p.Parent=model
 end
 model.Parent=parent
 return model
end
return Trail
