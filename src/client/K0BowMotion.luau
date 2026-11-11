-- Absolute server time drives draw, anchor, release and follow-through.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Clip=require(game.ReplicatedStorage.Shared.ElfBowClip)
local ReloadClip=require(script.Parent.K0ElfMixamoReload)
local Motion={}
local records=setmetatable({},{__mode="k"})
local pending=setmetatable({},{__mode="k"})
local function axis(keys,t)
 local i=1
 for n=1,#keys-1 do if t>=keys[n][1] then i=n end end
 local a,b=keys[i],keys[i+1];local h=b[1]-a[1]
 local u=math.clamp((t-a[1])/h,0,1);local u2,u3=u*u,u*u*u
 return (2*u3-3*u2+1)*a[2]+(u3-2*u2+u)*h*a[3]+(-2*u3+3*u2)*b[2]+(u3-u2)*h*b[3]
end
local function sample(clip,t)
 local pose={angles={},draw=axis(clip.curves.draw,t)}
 for channel,curves in pairs(clip.curves) do
  if channel~="draw" then
   local a={axis(curves[1],t),axis(curves[2],t),axis(curves[3],t)}
   pose.angles[channel]=Vector3.new(unpack(a))
   pose[channel]=CFrame.Angles(math.rad(a[1]),math.rad(a[2]),math.rad(a[3]))
  end
 end
 return pose
end
function Motion.sample(t) return sample(Clip,t) end
function Motion.sampleBasic(t,rigType)
 return sample(rigType==Enum.HumanoidRigType.R6 and Clip or ReloadClip,t)
end
local function definition(character)
 local skillId=character:GetAttribute("K0SkillId")
 if not skillId then return Config.BasicAttackProfiles.elf.attacks[1] end
 -- Cone describes hit geometry, not whether an elf fires a bow.
 for _,d in ipairs(Config.Skills.elf) do if d.id==skillId and (d.ranged or d.form=="cone") then return d end end
end
local function rest(rigType)
 local pose=Motion.sample(0);pose.time=0;pose.nocked=rigType==Enum.HumanoidRigType.R6;pose.ikWeight=0;return pose
end
-- Advanced pulses are presentation events confirmed by the server. Sequence
-- matching prevents late events from changing a later cast of the same skill.
local function validNumber(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
function Motion.confirmPulse(character,skillId,pulse,attackSeq,firedAt,startedAt,now,firstReceived)
 if not character or type(skillId)~="string" or not validNumber(attackSeq) or attackSeq%1~=0
  or not validNumber(pulse) or pulse%1~=0 or not validNumber(now) or not validNumber(firedAt)
  or not validNumber(startedAt) or firedAt<startedAt or firedAt>now+.5 then return end
 local expected
 for _,d in ipairs(Config.Skills.elf) do if d.id==skillId then expected=d;break end end
 if not expected or not expected.advanced or type(expected.pulses)~="number" or expected.pulses<2
  or pulse<1 or pulse>expected.pulses
  or firedAt>=startedAt+expected.windup+expected.active+expected.recovery then return end
 local currentSeq=character:GetAttribute("K0AttackSeq")
 if validNumber(currentSeq) and attackSeq<currentSeq then return end
 local currentStarted=character:GetAttribute("K0AttackStartedAt")
 if validNumber(currentSeq) and currentSeq==attackSeq and validNumber(currentStarted)
  and currentStarted>startedAt then return end
 if character:GetAttribute("K0ClassId")~="elf" or character:GetAttribute("K0State")~="Attack"
  or character:GetAttribute("K0SkillId")~=skillId or currentSeq~=attackSeq
  or currentStarted~=startedAt or firedAt>now then
  -- RemoteEvents and attributes can replicate in either order. Keep a small,
  -- short-lived queue until the corresponding accepted action is observable.
  local queue=pending[character] or {};pending[character]=queue
  if #queue>=4 then table.remove(queue,1) end
  table.insert(queue,{id=skillId,pulse=pulse,seq=attackSeq,at=firedAt,started=startedAt,received=firstReceived or now})
  return
 end
 local d=definition(character);local started=character:GetAttribute("K0AttackStartedAt")
 if d~=expected or not validNumber(started) or firedAt<started or firedAt>=started+d.windup+d.active+d.recovery then return end
 local record=records[character]
 if not record or record.started~=started or record.definition~=d then
  record={definition=d,started=started,rate=not character:GetAttribute("K0SkillId") and (character:GetAttribute("K0BasicAttackRate") or 1) or 1};records[character]=record
 end
 if pulse<=(record.pulse or 0) then return end
 record.pulse=pulse;record.pulseAt=firedAt
end

-- Release metadata and projectile attributes may replicate in either order.
local function confirmedRelease(character,record,now)
 local payload=character:GetAttribute("K0ArrowRelease")
 local visual=character:GetAttribute("K0ArrowVisual")
 if type(payload)~="string"or #payload>128 or type(visual)~="string"then return end
 local fields=string.split(payload,"|")
 if #fields~=4 then return end
 local seq,started,at,arrowSeq=tonumber(fields[1]),tonumber(fields[2]),tonumber(fields[3]),tonumber(fields[4])
 if not validNumber(seq)or not validNumber(started)or not validNumber(at)or not validNumber(arrowSeq)
  or seq~=character:GetAttribute("K0AttackSeq")or math.abs(started-record.started)>.002
  or at<started or at>now+.002 or tonumber(visual:match("^(%d+)|"))~=arrowSeq then return end
 return at
end

function Motion.forCharacter(character,now)
 if character:GetAttribute("K0ClassId")~="elf" then records[character]=nil;return nil end
 local mode=character:GetAttribute("K0State")
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 local rigType=humanoid and humanoid.RigType
 if (mode~="Attack" and mode~="Idle") or character:GetAttribute("TLTDeathFalling") then records[character]=nil;return nil end
 local record=records[character]
 if mode=="Attack" then
  local d=definition(character);local started=character:GetAttribute("K0AttackStartedAt")
  if not d or type(started)~="number" then return nil end
  if not record or record.started~=started or record.definition~=d then
   record={definition=d,started=started,rate=not character:GetAttribute("K0SkillId") and (character:GetAttribute("K0BasicAttackRate") or 1) or 1};records[character]=record
  end
  local queue=pending[character]
  if queue then
   pending[character]=nil
   for _,event in ipairs(queue) do
    if now-event.received<=2 and now>=event.received then
     Motion.confirmPulse(character,event.id,event.pulse,event.seq,event.at,event.started,now,event.received)
    end
   end
   record=records[character]
  end
 end
 if not record then return rest(rigType) end
 local d=record.definition;local age=(now-record.started)*(record.rate or 1)
 local total=d.windup+d.active+d.recovery
 if age>=total then records[character]=nil;return rest(rigType) end
 local release=d.windup
 local t
 local awaitingShot=false
 local advancedMulti=d.advanced and type(d.pulses)=="number" and d.pulses>1
 local repeated=d.effect=="rapid" or advancedMulti
 if repeated and age>=d.windup then
  local count=advancedMulti and (record.pulse or 0) or (character:GetAttribute("K0RapidShotCount") or 0)
  local at=advancedMulti and record.pulseAt or character:GetAttribute("K0RapidShotAt")
  if count<=0 or type(at)~="number" then t=.8
  else
   local since=math.max(0,now-at)
   if since<.04 then t=.8+.1*since/.04
   elseif count<(advancedMulti and d.pulses or d.shotCount) then
    local due=record.started+d.windup+count*(advancedMulti and d.interval or d.shotInterval)
    local span=math.max(.04,due-(at+.04))
    t=.18+.62*math.clamp((now-at-.04)/span,0,1)
   else
    t=.9+.1*math.clamp((now-at-.04)/math.max(.01,record.started+total-at-.04),0,1)
   end
  end
 elseif age<release then t=.8*math.clamp(age/release,0,1)
 elseif age<release+.04 then t=.8+.1*(age-release)/.04
 else t=.9+.1*math.clamp((age-release-.04)/math.max(.01,total-release-.04),0,1) end
 -- Predicted windup completion is not proof that the server fired. A delayed
 -- or interrupted attack must keep its nocked arrow instead of faking a shot.
 if not repeated and not d.advanced and character:GetAttribute("K0ArrowReleaseProtocol")==1 and age>=release then
  local firedAt=confirmedRelease(character,record,now)
  if not firedAt then t=.8;awaitingShot=true
  else
   local since=math.max(0,now-firedAt)*(record.rate or 1)
   local remaining=total-(firedAt-record.started)*(record.rate or 1)
   t=since<.04 and .8+.1*since/.04 or .9+.1*math.clamp((since-.04)/math.max(.01,remaining-.04),0,1)
  end
 end
 local reload=d==Config.BasicAttackProfiles.elf.attacks[1] and rigType~=Enum.HumanoidRigType.R6
 local pose=reload and Motion.sampleBasic(t,rigType) or Motion.sample(t)
 pose.time=t;pose.nocked=t<.8
 -- Hold the hand at anchor on release; move it behind the cheek instead of
 -- chasing the string as it snaps forward. IK weight is sampled, never integrated.
 pose.ikWeight=t<.8 and math.clamp(t/.18,0,1) or math.clamp(1-(t-.8)/.035,0,1)
 if reload then
  pose.nocked=t>=ReloadClip.nockAt and t<.8
  pose.ikWeight=t<.8 and math.clamp((t-ReloadClip.ikStart)/(ReloadClip.ikFull-ReloadClip.ikStart),0,1)or pose.ikWeight
  pose.reloading=t<ReloadClip.nockAt
  local function smooth(u)u=math.clamp(u,0,1);return u*u*(3-2*u)end
  pose.quiverReachWeight=smooth((t-.08)/.06)*(1-smooth((t-.24)/.08))
  pose.quiverArrow=t>=.22 and t<ReloadClip.nockAt
  pose.quiverTaken=t>=.22
 end
 if repeated and age>=d.windup then
  local count=advancedMulti and (record.pulse or 0) or (character:GetAttribute("K0RapidShotCount") or 0)
  local at=advancedMulti and record.pulseAt or character:GetAttribute("K0RapidShotAt")
  if count<(advancedMulti and d.pulses or d.shotCount) then
   local anchor=Motion.sample(.8)
   for _,channel in ipairs({"left","leftElbow","torso","neck","weapon"}) do pose[channel]=anchor[channel] end
   if type(at)=="number" and now-at>=.04 then
    pose.ikWeight=math.clamp((now-at-.04)/.035,0,1)
    pose.nocked=now-at>=.065 and (advancedMulti or t<.8)
   elseif advancedMulti and count==0 then
    pose.nocked=true
   end
  end
 end
 if awaitingShot then pose.nocked=true;pose.ikWeight=1 end
 -- Lob ground-targeted arrows upward; direct shots retain their reviewed aim.
 if d.form=="ground" then
  local fade=math.clamp((total-age)/math.max(.01,d.recovery),0,1)
  local raise=math.clamp(age/math.max(.01,d.windup*.7),0,1)*fade
  pose.aimPitch=(d.element=="lightning" or d.element=="nature") and 25*raise or 40*raise
  local tilt=CFrame.Angles(math.rad(pose.aimPitch),0,0)
  pose.left=tilt*pose.left;pose.right=tilt*pose.right
 end
 return pose
end
return Motion
