-- Continuous preparation, contact and recovery from the authoritative attack clock.
local Snapshot=require(script.Parent.EnemyPatternDefinition)
local AttackFrame=require(game:GetService('ReplicatedStorage').Shared.EnemyAttackFrame)
local Pose={}
local facingCache=setmetatable({},{__mode='k'})
local function smooth(t)
 t=math.clamp(t,0,1);return t*t*(3-2*t)
end
local function definition(model)
 return Snapshot.get(model)
end
local function wrap(angle)return (angle+math.pi)%(math.pi*2)-math.pi end
local function facing(model,d)
 local frame=Snapshot.frame(model)
 local origin=frame.origin or Vector3.zero
 local direction=frame.direction or Vector3.new(0,0,-1)
 local aim=frame.aim or origin+direction*12
 local castOrigin=frame.castOrigin
 local row=facingCache[model]
 if row and row.d==d and row.origin==origin and row.direction==direction and row.aim==aim and row.castOrigin==castOrigin then return row.yaws end
 local base=Vector3.new(direction.X,0,direction.Z)
 base=base.Magnitude>.001 and base.Unit or Vector3.new(0,0,-1)
 local attack={d=d,origin=origin,direction=direction,aim=aim,castOrigin=castOrigin}
 local yaws={}
 for pulse=1,d.pulses do
  local _,_,dir=AttackFrame.resolve(attack,pulse)
  local flat=Vector3.new(dir.X,0,dir.Z)
  flat=flat.Magnitude>.001 and flat.Unit or base
  local yaw=math.atan2(base:Cross(flat).Y,base:Dot(flat))
  yaws[pulse]=pulse==1 and yaw or yaws[pulse-1]+wrap(yaw-yaws[pulse-1])
 end
 facingCache[model]={d=d,origin=origin,direction=direction,aim=aim,castOrigin=castOrigin,yaws=yaws}
 return yaws
end
function Pose.facingYaw(model,current,attack)
 local d=definition(model);if not d then return 0 end
 local yaws=facing(model,d);local age=current-attack.start
 if age<attack.w then return yaws[1]*smooth(age/attack.w)end
 local elapsed=age-attack.w
 local pulse=math.min(d.pulses,math.floor(math.max(0,elapsed)/d.interval)+1)
 local localAge=elapsed-(pulse-1)*d.interval
 local hold=math.min(.12,d.interval*.24)
 if pulse<d.pulses then
  -- Turn throughout the next preparation, rather than snapping at contact.
  local blend=smooth((localAge-hold)/math.max(.1,d.interval-hold))
  return yaws[pulse]+(yaws[pulse+1]-yaws[pulse])*blend
 end
 local settle=math.min(.8,math.max(.3,attack.r*.65))
 return yaws[pulse]+wrap(-yaws[pulse])*smooth((localAge-hold)/settle)
end
function Pose.phase(model,current,attack)
 local d=definition(model);if not d then return nil end
 local age=current-attack.start
 -- Authored clips contact at .62. Preserve that phase on every server pulse.
 if age<attack.w then
  local t=math.clamp(age/attack.w,0,1)
  if t<.8 then return .5*smooth(t/.8)end
  return .5+.12*smooth((t-.8)/.2)
 end
 local elapsed=age-attack.w
 if elapsed<attack.a then
  local strike=math.min(d.pulses-1,math.floor(elapsed/d.interval))
  local localAge=elapsed-strike*d.interval
  local follow=math.min(.14,d.interval*.25)
  if localAge<follow then return .62+.16*smooth(localAge/follow)end
  if strike==d.pulses-1 then return .78 end
  local prepare=d.interval*.72
  local ready=d.motion=='cast' and .60 or .44
  if localAge<prepare then return .78+(ready-.78)*smooth((localAge-follow)/(prepare-follow))end
  return ready+(.62-ready)*smooth((localAge-prepare)/(d.interval-prepare))
 end
 return .78+.22*smooth((elapsed-attack.a)/attack.r)
end
function Pose.accent(model,current,attack)
 local d=definition(model);if not d then return CFrame.identity end
 local age=current-attack.start
 local prepare=age<attack.w and smooth(age/attack.w)or 0
 local elapsed=age-attack.w
 -- A smooth pulse envelope avoids an extra root snap at repeated contacts.
 local pulse=math.min(d.pulses-1,math.floor(math.max(0,elapsed)/d.interval))
 local localAge=elapsed-pulse*d.interval
 local release=elapsed>=0 and 1-smooth(localAge/.24)or 0
 if elapsed>=0 and pulse<d.pulses-1 then
  local anticipation=math.min(.18,d.interval*.3)
  release=release+smooth((localAge-(d.interval-anticipation))/anticipation)
 end
 local weight=prepare+release
 -- Rotate the complete visual hierarchy. Skin joints and staff grips remain
 -- intact, and the authoritative server root never moves or turns here.
 local facingFrame=CFrame.Angles(0,Pose.facingYaw(model,current,attack),0)
 local style=d.motionStyle
 if style=='thrust'then return facingFrame*CFrame.new(0,0,-.12*weight)*CFrame.Angles(math.rad(3*weight),0,0)end
 if d.motion=='cast'then return facingFrame*CFrame.Angles(math.rad(-5*weight),0,0)end
 if d.motion=='slam'then return facingFrame*CFrame.Angles(math.rad(-9*weight),0,0)end
 if d.motion=='dash'then return facingFrame*CFrame.Angles(math.rad(9*weight),0,0)end
 if d.motion=='hop'then return facingFrame*CFrame.new(0,-.10*weight,0)end
 return facingFrame*CFrame.Angles(0,math.rad(-8*math.sin(math.pi*prepare)),0)
end
function Pose.joint(model,channel,phase)
 if channel~='weapon'then return CFrame.identity end
 local d=definition(model)
 if not d then return CFrame.identity end
 -- Bounded additions preserve the reviewed mesh joints and original grip.
 local ready=smooth(math.min(phase/.5,1))
 local contact=smooth((phase-.5)/.12)
 local settle=1-smooth((phase-.78)/.22)
 local preparation=ready*(1-contact)*settle
 local follow=contact*settle
 if d.motionStyle=='thrust'then return CFrame.Angles(math.rad(-10*preparation+7*follow),math.rad(-5*preparation),0)end
 if d.motion=='slam' or d.motionStyle=='slam'then return CFrame.Angles(math.rad(-12*preparation+6*follow),0,math.rad(4*preparation))end
 if d.motionStyle=='cleave'then return CFrame.Angles(0,math.rad(-10*preparation+10*follow),math.rad(-5*preparation))end
 return CFrame.identity
end
return Pose
