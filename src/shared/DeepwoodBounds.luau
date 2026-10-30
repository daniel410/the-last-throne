-- Authoritative walkable footprint: the existing ten clearings and nine trails.
-- Background forest is scenery, never an alternate route around story gates.
local Content=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent) or dofile('src/shared/DeepwoodContent.luau')
local Access=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodAccess) or dofile('src/shared/DeepwoodAccess.luau')
local Bounds={trailHalfWidth=48,backgroundHeight=-12}
local function finite(v) return type(v)=='number' and v==v and math.abs(v)<1e7 end
function Bounds.ends(edge)
 local first,last=Content.zones[edge[1]],Content.zones[edge[2]]
 local a,b=first.center,last.center;local dx,dz=b[1]-a[1],b[3]-a[3]
 local function exit(zone)
  return math.min(math.abs(dx)>.001 and zone.size[1]/2/math.abs(dx) or math.huge,math.abs(dz)>.001 and zone.size[2]/2/math.abs(dz) or math.huge)
 end
 local t0,t1=exit(first),1-exit(last)
 return {a[1]+dx*t0,a[2],a[3]+dz*t0},{a[1]+dx*t1,b[2],a[3]+dz*t1},t0,t1
end
function Bounds.trailHeight(edge,t)
 local a,b,t0,t1=Bounds.ends(edge)
 local u=math.max(0,math.min(1,(t-t0)/math.max(.001,t1-t0)))
 return a[2]+(b[2]-a[2])*u
end
function Bounds.region(x,z,margin,except)
 if not finite(x) or not finite(z) then return nil end
 margin=margin or 0
 local height,id
 for key,zone in pairs(Content.zones) do
  if key~=except and math.abs(x-zone.center[1])<=zone.size[1]/2+margin and math.abs(z-zone.center[3])<=zone.size[2]/2+margin then
   if not height or zone.center[2]>height then height,id=zone.center[2],key end
  end
 end
 return height,id
end
function Bounds.connection(x,z,margin)
 if not finite(x) or not finite(z) then return nil end
 local height,index
 for i,edge in ipairs(Access.edges) do
  local a,b=Content.zones[edge[1]].center,Content.zones[edge[2]].center
  local dx,dz=b[1]-a[1],b[3]-a[3]
  local t=math.max(0,math.min(1,((x-a[1])*dx+(z-a[3])*dz)/(dx*dx+dz*dz)))
  if (x-a[1]-t*dx)^2+(z-a[3]-t*dz)^2<=(Bounds.trailHalfWidth+(margin or 0))^2 then
   local y=Bounds.trailHeight(edge,t)-.2
   if not height or y>height then height,index=y,i end
  end
 end
 return height,index
end
function Bounds.surface(x,z)
 local height,id=Bounds.region(x,z)
 if height then return height,id end
 return Bounds.connection(x,z)
end
function Bounds.supported(x,y,z)
 local floor=Bounds.surface(x,z)
 return finite(y) and floor~=nil and y>=floor+1, floor
end
return Bounds
