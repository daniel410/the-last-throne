-- Geometry and floor projection for client skill effects.
local G={}
local function humanoidModel(part)
 local model=part and part:FindFirstAncestorOfClass("Model")
 while model do
  if model:FindFirstChildOfClass("Humanoid") then return model end
  model=model:FindFirstAncestorOfClass("Model")
 end
end
function G.floor(position,character,lift,drop)
 local excluded=character and {character} or {}
 local world=workspace:FindFirstChild("DeepwoodK0")
 local enemies=world and world:FindFirstChild("Enemies")
 if enemies then table.insert(excluded,enemies) end
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 params.RespectCanCollide=true
 local start=position+Vector3.yAxis*2
 -- Retry only when another character sits over the painted ground point.
 for _=1,4 do
  params.FilterDescendantsInstances=excluded
  local hit=workspace:Raycast(start,-Vector3.yAxis*18,params)
  if not hit then break end
  local actor=humanoidModel(hit.Instance)
  if not actor then return hit.Position+Vector3.yAxis*(lift or .12) end
  table.insert(excluded,actor)
 end
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
