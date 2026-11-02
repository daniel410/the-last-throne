-- Absolute rest-space poses: no accumulated drift, no gameplay/AI authority.
local M={}
local rightHeld={hammer=true,lantern=true,staff=true,key=true,book=true,map=true,pickaxe=true,wrench=true,sword=true,cup=true}
local function joint(point,rx,ry,rz)
 return CFrame.new(point)*CFrame.Angles(rx or 0,ry or 0,rz or 0)*CFrame.new(-point)
end
function M.pose(time,phase,weight,scale,width,prop,look)
 weight=math.clamp(weight,0,1);look=math.clamp(look or 0,-.45,.45)
 local breath=math.sin(time*1.8)*.012
 local shift=CFrame.new(0,-.06*weight*scale,0)
 local body=shift*CFrame.new(0,breath*scale,0)*joint(Vector3.new(0,2.34,0)*scale,
  -.025*weight,math.sin(phase)*.025*weight,math.sin(time*.8)*.008*(1-weight))
 local pose={Body=body,Head=body*joint(Vector3.new(0,4.2,0)*scale,math.sin(time*.9)*.018,look,0)}
 for _,side in ipairs({'L','R'}) do
  local sign=side=='L' and -1 or 1
  local stride=phase+(side=='L' and 0 or math.pi)
  local wave=math.sin(stride)
  -- Two-bone planar IK keeps soles level and stance feet on the ground.
  local hip=Vector3.new(sign*.55*width,2.23,0)*scale
  local knee=Vector3.new(sign*.55*width,1.35,0)*scale
  local ankle=Vector3.new(sign*.55*width,.57,0)*scale
  local lift=math.max(0,math.cos(stride))*.20*weight
  local z=-wave*.32*weight
  local dy=1.66-.06*weight-lift
  local d=math.clamp(math.sqrt(dy*dy+z*z),.101,1.66)
  local a=math.atan2(-z,dy)-math.acos(math.clamp((.88^2+d*d-.78^2)/(2*.88*d),-1,1))
  local b=math.pi-math.acos(math.clamp((.88^2+.78^2-d*d)/(2*.88*.78),-1,1))
  pose['Thigh'..side]=shift*joint(hip,a)
  pose['Shin'..side]=pose['Thigh'..side]*joint(knee,b)
  pose['Foot'..side]=pose['Shin'..side]*joint(ankle,-a-b)
  local held=(side=='R' and rightHeld[prop]) or (side=='L' and prop=='bow')
  local swing=-wave*(held and .12 or .32)*weight
  local elbow=held and .15 or .04
  if prop=='book' or prop=='map' then swing+=side=='R' and .18 or 0;elbow=side=='R' and .32 or elbow end
  local spread=-sign*.025
  if prop=='crown' then swing=.55;elbow=.8;spread=-sign*.25 end
  local shoulder=Vector3.new(sign*1.43*width,4.1,0)*scale
  local ep=Vector3.new(sign*1.49*width,3.07,-.04)*scale
  local wrist=Vector3.new(sign*1.49*width,2.2,-.04)*scale
  pose['Arm'..side]=body*joint(shoulder,swing+(prop=='crown' and 0 or math.sin(time*1.2+sign)*.015),0,spread)
  pose['Forearm'..side]=pose['Arm'..side]*joint(ep,elbow+(prop=='crown' and 0 or math.max(0,-wave)*.12*weight))
  pose['Hand'..side]=pose['Forearm'..side]*joint(wrist,0,0,prop=='crown' and 0 or math.sin(time*.9)*.012)
 end
 return pose
end
return M
