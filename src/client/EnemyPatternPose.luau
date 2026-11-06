-- Per-strike posing: long volleys hold their cast instead of stretching one swing.
local RS=game:GetService('ReplicatedStorage')
local Patterns=require(RS.Shared.EnemyPatterns)
local Pose={}
function Pose.phase(model,current,attack)
 local id=model:GetAttribute('K0PatternId');if not id then return nil end
 local profile=Patterns.get(model:GetAttribute('EnemyKind'));if not profile then return nil end
 local d;for _,candidate in ipairs(profile.attacks)do if candidate.id==id then d=candidate;break end end
 if not d then return nil end
 local age=current-attack.start
 if age<attack.w then return math.clamp(age/attack.w,0,1)*.62 end
 if age<attack.w+attack.a then
  if d.motion=='cast'then return .62+math.min(.14,((age-attack.w)%d.interval)/d.interval*.14)end
  local strike=math.min(d.pulses-1,math.floor((age-attack.w)/d.interval));local localAge=age-attack.w-strike*d.interval
  return .62+.16*math.clamp(localAge/.18,0,1)
 end
 return .78+.22*math.clamp((age-attack.w-attack.a)/attack.r,0,1)
end
function Pose.accent(model,current,attack)
 if not model:GetAttribute('K0PatternId')then return CFrame.identity end
 local age=current-attack.start;local wind=math.sin(math.clamp(age/attack.w,0,1)*math.pi*.5)
 local release=age<attack.w and wind or math.max(0,1-(age-attack.w)/.25)
 local motion=model:GetAttribute('K0PatternMotion')
 if motion=='cast'then return CFrame.Angles(math.rad(-5*release),0,0)end
 if motion=='slam'then return CFrame.Angles(math.rad(-9*release),0,0)end
 if motion=='dash'then return CFrame.Angles(math.rad(9*release),0,0)end
 if motion=='hop'then return CFrame.new(0,-.10*release,0)end
 return CFrame.Angles(0,math.rad(-12*release),0)
end
return Pose
