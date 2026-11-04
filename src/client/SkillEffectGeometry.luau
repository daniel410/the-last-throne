-- Pure geometry used by rendering and CPU regression fixtures.
local G={}
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
return G
