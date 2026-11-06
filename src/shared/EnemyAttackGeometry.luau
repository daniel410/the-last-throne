-- Pure numeric geometry, shared by server and prediction-free warning rendering.
local G={}
function G.contains(shape,x,z,height,range,width,radius,innerRadius,angle)
 if math.abs(height)>8 then return false end
 local d=x*x+z*z
 if shape=='circle' or shape=='trail'then return d<=radius*radius end
 if shape=='ring'then return d<=radius*radius and d>=innerRadius*innerRadius end
 if shape=='line'then return z>=0 and z<=range and math.abs(x)<=width end
 if shape=='cone'then return d<=range*range and (d<.0001 or z/math.sqrt(d)>=math.cos(math.rad(angle*.5)))end
 return false
end
function G.segmentDistance(px,py,pz,ax,ay,az,bx,by,bz)
 local dx,dy,dz=bx-ax,by-ay,bz-az;local n=dx*dx+dy*dy+dz*dz
 local t=n>0 and math.max(0,math.min(1,((px-ax)*dx+(py-ay)*dy+(pz-az)*dz)/n))or 0
 local x,y,z=px-ax-dx*t,py-ay-dy*t,pz-az-dz*t
 return math.sqrt(x*x+y*y+z*z),t
end
return G
