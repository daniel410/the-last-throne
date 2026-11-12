-- Continuous preparation, contact and recovery from the authoritative attack clock.
local RS=game:GetService('ReplicatedStorage')
local Patterns=require(RS.Shared.EnemyPatterns)
local Pose={}
local function smooth(t)
 t=math.clamp(t,0,1);return t*t*(3-2*t)
end
local function definition(model)
 local id=model:GetAttribute('K0PatternId');if not id then return nil end
 local profile=Patterns.get(model:GetAttribute('EnemyKind'));if not profile then return nil end
 for _,d in ipairs(profile.attacks)do if d.id==id then return d end end
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
 local release=elapsed>=0 and 1-smooth(elapsed/.24)or 0
 local weight=prepare+release
 if d.motion=='cast'then return CFrame.Angles(math.rad(-5*weight),0,0)end
 if d.motion=='slam'then return CFrame.Angles(math.rad(-9*weight),0,0)end
 if d.motion=='dash'then return CFrame.Angles(math.rad(9*weight),0,0)end
 if d.motion=='hop'then return CFrame.new(0,-.10*weight,0)end
 return CFrame.Angles(0,math.rad(-12*weight),0)
end
return Pose
