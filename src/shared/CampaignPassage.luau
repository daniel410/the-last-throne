-- Join the actual rectangular mouths, including their oblique side edges.
-- Pure geometry shared by collision construction and server height validation.
local P={halfWidth=52,overlap=4}
local function point(origin,dx,dz,t,side,y)
 return {origin[1]+dx*t-dz*side,y,origin[3]+dz*t+dx*side}
end
local function interval(zone,origin,dx,dz,side)
 local x,z=origin[1]-dz*side,origin[3]+dx*side
 local low,high=-math.huge,math.huge
 for _,axis in ipairs({{x,dx,zone.center[1],zone.size[1]},{z,dz,zone.center[3],zone.size[2]}})do
  if math.abs(axis[2])>.000001 then
   local a=(axis[3]-axis[4]/2-axis[1])/axis[2]
   local b=(axis[3]+axis[4]/2-axis[1])/axis[2]
   low=math.max(low,math.min(a,b));high=math.min(high,math.max(a,b))
  end
 end
 return low,high
end
function P.create(first,last)
 local origin=first.center
 local dx,dz=last.center[1]-origin[1],last.center[3]-origin[3]
 local length=math.sqrt(dx*dx+dz*dz);assert(length>0,'distinct passage centers')
 dx,dz=dx/length,dz/length
 local cuts={-P.halfWidth,P.halfWidth}
 -- A mouth can cross a rectangle corner. Split there so every boundary edge
 -- lies exactly on its owning floor rather than cutting across that corner.
 for _,zone in ipairs({first,last})do for _,sx in ipairs({-1,1})do for _,sz in ipairs({-1,1})do
  local side=-(zone.center[1]+sx*zone.size[1]/2-origin[1])*dz+(zone.center[3]+sz*zone.size[2]/2-origin[3])*dx
  if side>-P.halfWidth+.001 and side<P.halfWidth-.001 then table.insert(cuts,side)end
 end end end
 table.sort(cuts)
 local sections={}
 for _,side in ipairs(cuts)do
  if #sections==0 or side-sections[#sections].side>.001 then
   local _,a=interval(first,origin,dx,dz,side)
   local b=interval(last,origin,dx,dz,side)
   assert(b>a,'overlapping passage mouths')
   table.insert(sections,{side=side,
    approach=point(origin,dx,dz,a-P.overlap,side,first.center[2]),
    first=point(origin,dx,dz,a,side,first.center[2]),
    last=point(origin,dx,dz,b,side,last.center[2]),
    departure=point(origin,dx,dz,b+P.overlap,side,last.center[2])})
  end
 end
 -- Discard cuts belonging to the unused back face of a rectangle.
 for i=#sections-1,2,-1 do
  local a,b,c=sections[i-1],sections[i],sections[i+1]
  local t=(b.side-a.side)/(c.side-a.side)
  local function collinear(key)
   return math.abs(b[key][1]-(a[key][1]+(c[key][1]-a[key][1])*t))<.001
    and math.abs(b[key][3]-(a[key][3]+(c[key][3]-a[key][3])*t))<.001
  end
  if collinear('first')and collinear('last')then table.remove(sections,i)end
 end
 local triangles={}
 for i=2,#sections do
  local a,b=sections[i-1],sections[i]
  for _,keys in ipairs({{'approach','first'},{'first','last'},{'last','departure'}})do
   local p,q,r,s=a[keys[1]],b[keys[1]],a[keys[2]],b[keys[2]]
   table.insert(triangles,{p,q,r});table.insert(triangles,{q,s,r})
  end
 end
 return {triangles=triangles,sections=sections}
end
function P.height(passage,x,z)
 local height
 for _,t in ipairs(passage.triangles)do
  local a,b,c=t[1],t[2],t[3]
  local den=(b[3]-c[3])*(a[1]-c[1])+(c[1]-b[1])*(a[3]-c[3])
  if math.abs(den)>.000001 then
   local u=((b[3]-c[3])*(x-c[1])+(c[1]-b[1])*(z-c[3]))/den
   local v=((c[3]-a[3])*(x-c[1])+(a[1]-c[1])*(z-c[3]))/den
   if u>=-.00001 and v>=-.00001 and u+v<=1.00001 then
    local y=u*a[2]+v*b[2]+(1-u-v)*c[2]
    height=math.max(height or y,y)
   end
  end
 end
 return height
end
return P
