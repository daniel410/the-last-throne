-- Absolute server time drives draw, anchor, release and follow-through.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Clip=require(game.ReplicatedStorage.Shared.ElfBowClip)
local Motion={}
local records=setmetatable({},{__mode="k"})
local function axis(keys,t)
 local i=1
 for n=1,#keys-1 do if t>=keys[n][1] then i=n end end
 local a,b=keys[i],keys[i+1];local h=b[1]-a[1]
 local u=math.clamp((t-a[1])/h,0,1);local u2,u3=u*u,u*u*u
 return (2*u3-3*u2+1)*a[2]+(u3-2*u2+u)*h*a[3]+(-2*u3+3*u2)*b[2]+(u3-u2)*h*b[3]
end
function Motion.sample(t)
 local pose={angles={},draw=axis(Clip.curves.draw,t)}
 for channel,curves in pairs(Clip.curves) do
  if channel~="draw" then
   local a={axis(curves[1],t),axis(curves[2],t),axis(curves[3],t)}
   pose.angles[channel]=Vector3.new(unpack(a))
   pose[channel]=CFrame.Angles(math.rad(a[1]),math.rad(a[2]),math.rad(a[3]))
  end
 end
 return pose
end
local function definition(character)
 local skillId=character:GetAttribute("K0SkillId")
 if not skillId then return Config.BasicAttackProfiles.elf.attacks[1] end
 for _,d in ipairs(Config.Skills.elf) do if d.id==skillId and d.ranged then return d end end
end
local function rest()
 local pose=Motion.sample(0);pose.time=0;pose.nocked=true;pose.ikWeight=0;return pose
end
function Motion.forCharacter(character,now)
 if character:GetAttribute("K0ClassId")~="elf" then records[character]=nil;return nil end
 local mode=character:GetAttribute("K0State")
 if (mode~="Attack" and mode~="Idle") or character:GetAttribute("TLTDeathFalling") then records[character]=nil;return nil end
 local record=records[character]
 if mode=="Attack" then
  local d=definition(character);local started=character:GetAttribute("K0AttackStartedAt")
  if not d or type(started)~="number" then return nil end
  if not record or record.started~=started or record.definition~=d then
   record={definition=d,started=started};records[character]=record
  end
 end
 if not record then return rest() end
 local d=record.definition;local age=now-record.started
 local total=d.windup+d.active+d.recovery
 if age>=total then records[character]=nil;return rest() end
 local release=d.windup
 local t
 if d.effect=="rapid" and age>=d.windup then
  local count=character:GetAttribute("K0RapidShotCount") or 0
  local at=character:GetAttribute("K0RapidShotAt")
  if count<=0 or type(at)~="number" then t=.8
  else
   local since=math.max(0,now-at)
   if since<.04 then t=.8+.1*since/.04
   elseif count<d.shotCount then
    local due=record.started+d.windup+count*d.shotInterval
    local span=math.max(.04,due-(at+.04))
    t=.18+.62*math.clamp((now-at-.04)/span,0,1)
   else
    t=.9+.1*math.clamp((now-at-.04)/math.max(.01,record.started+total-at-.04),0,1)
   end
  end
 elseif age<release then t=.8*math.clamp(age/release,0,1)
 elseif age<release+.04 then t=.8+.1*(age-release)/.04
 else t=.9+.1*math.clamp((age-release-.04)/math.max(.01,total-release-.04),0,1) end
 local pose=Motion.sample(t)
 pose.time=t;pose.nocked=t<.8
 -- Hold the hand at anchor on release; move it behind the cheek instead of
 -- chasing the string as it snaps forward. IK weight is sampled, never integrated.
 pose.ikWeight=t<.8 and math.clamp(t/.18,0,1) or math.clamp(1-(t-.8)/.035,0,1)
 if d.effect=="rapid" and age>=d.windup then
  local count=character:GetAttribute("K0RapidShotCount") or 0
  local at=character:GetAttribute("K0RapidShotAt")
  if count<d.shotCount then
   local anchor=Motion.sample(.8)
   for _,channel in ipairs({"left","leftElbow","torso","neck","weapon"}) do pose[channel]=anchor[channel] end
   if type(at)=="number" and now-at>=.04 then
    pose.ikWeight=math.clamp((now-at-.04)/.035,0,1)
    pose.nocked=now-at>=.065 and t<.8
   end
  end
 end
 return pose
end
return Motion
