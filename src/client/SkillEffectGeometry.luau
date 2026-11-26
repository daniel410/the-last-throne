-- Geometry and floor projection for client skill effects.
local G={}
local function humanoidModel(part)
 local model=part and part:FindFirstAncestorOfClass("Model")
 while model do
  if model:FindFirstChildOfClass("Humanoid") then return model end
  model=model:FindFirstAncestorOfClass("Model")
 end
end
local function groundProbe(character)
 local excluded=character and {character} or {}
 local world=workspace:FindFirstChild("DeepwoodK0")
 local enemies=world and world:FindFirstChild("Enemies")
 if enemies then table.insert(excluded,enemies) end
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 params.RespectCanCollide=true
 return function(start,length)
  for _=1,4 do
   params.FilterDescendantsInstances=excluded
   local hit=workspace:Raycast(start,-Vector3.yAxis*length,params)
   if not hit then return nil end
   local actor=humanoidModel(hit.Instance)
   if not actor then return hit end
   table.insert(excluded,actor)
  end
 end
end
function G.floor(position,character,lift,drop)
 local hit=groundProbe(character)(position+Vector3.yAxis*2,18)
 if hit then return hit.Position+Vector3.yAxis*(lift or .12) end
 return position-Vector3.yAxis*(drop or 2.6)
end
function G.sector(origin,direction,radius,angle,count)
 local forward=Vector3.new(direction.X,0,direction.Z)
 forward=forward.Magnitude>.001 and forward.Unit or Vector3.new(0,0,-1)
 local right=Vector3.new(-forward.Z,0,forward.X)
 local points={}
 for i=0,count do
  local a=math.rad(-angle/2+angle*i/count)
  points[#points+1]=origin+(forward*math.cos(a)+right*math.sin(a))*radius
 end
 return points
end
-- Keep the radius in XZ. Ground height is strictly a rendering adjustment.
function G.groundSector(points,center,character,maxHeight)
 local probe=groundProbe(character)
 local support=probe(center+Vector3.yAxis*.5,1.25)
 if not support or support.Normal.Y<.65 then return points end
 local normal=support.Normal
 local floor=support.Position
 local projected,normals={},{}
 for i,point in ipairs(points) do
  if i==#points and (point-points[1]).Magnitude<.001 then
   projected[i],normals[i]=projected[1],normals[1]
  else
   local planeHeight=(center-point):Dot(normal)/normal.Y
   local expected=floor.Y+math.clamp(planeHeight,-maxHeight,maxHeight)
   local start=Vector3.new(point.X,math.min(expected+1.6,floor.Y+maxHeight+.02),point.Z)
   local length=start.Y-math.max(expected-2.4,floor.Y-maxHeight-.02)
   local hit=probe(start,length)
   if hit and hit.Normal.Y>=.65 then
    projected[i],normals[i]=hit.Position+Vector3.yAxis*.10,hit.Normal
   end
  end
 end
 local supported={}
 for i=1,#points-1 do
  if projected[i] and projected[i+1] then
   local delta=points[i+1]-points[i]
   local firstRise=-delta:Dot(normals[i])/normals[i].Y
   local lastRise=-delta:Dot(normals[i+1])/normals[i+1].Y
   local rise=projected[i+1].Y-projected[i].Y
   -- A ramp can meet a landing, while a sharp step between flat faces needs a break.
   supported[i]=rise>=math.min(firstRise,lastRise)-.65 and rise<=math.max(firstRise,lastRise)+.65
  end
 end
 return projected,supported
end
function G.lightning(first,last,count)
 local delta=last-first
 local side=delta:Cross(Vector3.yAxis)
 side=side.Magnitude>.001 and side.Unit or Vector3.xAxis
 local points={first}
 for i=1,count-1 do
  points[#points+1]=first+delta*(i/count)+side*((i%2==0 and -1 or 1)*math.min(.7,delta.Magnitude*.04))
 end
 points[#points+1]=last
 return points
end
function G.fanLaunch(origin,muzzle,target)
 local path=target-origin
 -- Point-blank cover may sit between the actor and the visible weapon tip.
 if muzzle and (muzzle-origin).Magnitude<=6 and (muzzle-origin):Dot(path)<path:Dot(path) then
  return muzzle
 end
 return origin
end
return G
