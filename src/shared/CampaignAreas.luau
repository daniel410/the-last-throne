-- Shared X/Z footprints for new incident wings, navigation, authority and maps.
local A={}
function A.contains(rect,x,z,margin)
 margin=margin or 0
 return math.abs(x-rect.center[1])<=rect.size[1]/2+margin and math.abs(z-rect.center[3])<=rect.size[2]/2+margin
end
function A.containsZone(zone,x,z,margin)
 if A.contains(zone,x,z,margin)then return true end
 for _,area in ipairs(zone.expansionAreas or {})do if A.contains(area,x,z,margin)or A.contains(area.connector,x,z,margin)then return true end end
 return false
end
function A.height(zone,x,z,margin)
 local height=A.contains(zone,x,z,margin)and zone.center[2]or nil
 for _,a in ipairs(zone.expansionAreas or {})do
  local y
  if A.contains(a,x,z,margin)then y=a.center[2]
  elseif A.contains(a.connector,x,z,margin)then
   local first,last=a.connector.rampStart,a.connector.rampEnd
   local dx,dz=last[1]-first[1],last[3]-first[3]
   local t=math.max(0,math.min(1,((x-first[1])*dx+(z-first[3])*dz)/math.max(.001,dx*dx+dz*dz)))
   y=first[2]+(last[2]-first[2])*t
  end
  if y and (not height or y>height)then height=y end
 end
 return height
end
function A.extent(zone)
 local a,b,c,d=zone.center[1]-zone.size[1]/2,zone.center[3]-zone.size[2]/2,zone.center[1]+zone.size[1]/2,zone.center[3]+zone.size[2]/2
 for _,area in ipairs(zone.expansionAreas or {})do
  a=math.min(a,area.center[1]-area.size[1]/2);b=math.min(b,area.center[3]-area.size[2]/2)
  c=math.max(c,area.center[1]+area.size[1]/2);d=math.max(d,area.center[3]+area.size[2]/2)
 end
 return a,b,c,d
end
return A
