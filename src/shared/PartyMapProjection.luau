local P={text={legend='● PARTY',downed='DOWN',outside='OUT OF VIEW'}}
local function finite(v)return type(v)=='number'and v==v and math.abs(v)<1e7 end
function P.position(member,project,compact)
 local pos=member and member.position
 if type(pos)~='table'or not finite(pos[1])or not finite(pos[2])or not finite(pos[3])then return nil end
 local point=project(pos[1],pos[3]);local x,y=point.X,point.Y
 if not finite(x)or not finite(y)then return nil end
 local dx,dy=x-.5,y-.5;local distance=math.sqrt(dx*dx+dy*dy)
 local outside
 if compact then
  outside=distance>.34
  if outside then x=.5+dx/distance*.34;y=.5+dy/distance*.34 end
 else
  outside=x<.025 or x>.975 or y<.025 or y>.975
  x=math.max(.025,math.min(.975,x));y=math.max(.025,math.min(.975,y))
 end
 return {x=x,y=y,outside=outside,angle=math.deg((math.atan2 or math.atan)(dy,dx)),downed=member.downed==true}
end
return P
