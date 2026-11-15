-- Continuous preparation, contact and recovery from the authoritative attack clock.
local Snapshot=require(script.Parent.EnemyPatternDefinition)
local Pose={}
local function smooth(t)
 t=math.clamp(t,0,1);return t*t*(3-2*t)
end
local function definition(model)
 return Snapshot.get(model)
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
 local style=d.motionStyle
 if style=='thrust'then return CFrame.new(0,0,-.12*weight)*CFrame.Angles(math.rad(3*weight),0,0)end
 if d.motion=='cast'then return CFrame.Angles(math.rad(-5*weight),0,0)end
 if d.motion=='slam'then return CFrame.Angles(math.rad(-9*weight),0,0)end
 if d.motion=='dash'then return CFrame.Angles(math.rad(9*weight),0,0)end
 if d.motion=='hop'then return CFrame.new(0,-.10*weight,0)end
 return CFrame.Angles(0,math.rad(-12*weight),0)
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
