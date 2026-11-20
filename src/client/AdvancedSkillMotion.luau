-- Advanced choreography retimes the reviewed sword/axe contact curves. Native
-- socket review takes precedence over inventing Euler poses for held weapons.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
local Clips=require(script.Parent.K0MeleeClips)
local Melee=require(script.Parent.K0MeleeMotion)
local KnightBasic=require(script.Parent.K0KnightMixamoBasic)
local Shield=require(script.Parent.K0ShieldBashMotion)
local Motion={}
local records=setmetatable({},{__mode="k"})
local definitions={}
local owner={}
for _,classId in ipairs({"knight","dwarf"}) do
 for _,d in ipairs(Config.Skills[classId]) do
  if d.advanced or d.id=="knight.common.provoke" then
   definitions[d.id]=d
   owner[d.id]=classId
  end
 end
end
local function smooth(x) x=math.clamp(x,0,1);return x*x*(3-2*x) end
local function v(x,y,z) return Vector3.new(x or 0,y or 0,z or 0) end
local function rot(a) return CFrame.Angles(math.rad(a.X),math.rad(a.Y),math.rad(a.Z)) end
local function rebuild(pose)
 for channel,a in pairs(pose.angles) do pose[channel]=rot(a) end
 return pose
end
local function mix(a,b,weight)
 local pose={angles={}}
 for channel in pairs(a.angles) do
  local cf=a[channel]:Lerp(b[channel],weight)
  local x,y,z=cf:ToEulerAnglesXYZ()
  pose[channel]=cf
  pose.angles[channel]=v(math.deg(x),math.deg(y),math.deg(z))
 end
 if a.axeStrikeTurn or b.axeStrikeTurn then
  local start=a.axeStrikeTurn or 0
  pose.axeStrikeTurn=start+((b.axeStrikeTurn or 0)-start)*weight
 end
 return pose
end
local function resting(classId)
 local pose={angles={}}
 for channel,a in pairs(Clips.rest[classId]) do pose.angles[channel]=v(unpack(a)) end
 return rebuild(pose)
end
local function source(classId,kind,pulse,rigType,skillId)
 local combo=kind=="cross" and pulse%2==0 and 2 or 1
 if kind=="sweep" or kind=="spin" then combo=2 end
 if kind=="chop" or kind=="slam" or kind=="thrust" then combo=3 end
 if classId=="knight" then
  local variant=kind=="sweep" and "knight.mixamo.wide" or kind=="chop" and "knight.mixamo.power" or kind=="thrust" and "knight.skill.thrust" or nil
  local base=Config.BasicAttackProfiles.knight.attacks[combo]
  local sourceScale=(base.windup+base.active+base.recovery)/KnightBasic[combo].duration
  return base,function(age) return Melee.sample("knight",combo,age,nil,nil,variant,rigType) end,sourceScale
 end
 local index=kind=="throw" and 2 or kind=="slam" and 3 or 1
 local base=Config.Skills.dwarf[index]
 local clipId=kind=="sweep" and "dwarf.mixamo.sweep"
  or kind=="slam" and "dwarf.mixamo.grounded"
  or skillId=="dwarf_hooking_chop" and "dwarf.mixamo.backhand" or base.id
 return base,function(age) return Melee.sample("dwarf",1,age,nil,nil,clipId,rigType) end
end
-- Recoil gain and settling time distinguish a burst, a long rifle shot
-- and a braced cannon while the release pose keeps the bore on axis.
local gunRecoil={
 ["dwarf.gunner.quickfire"]={gain=.75,settle=.12},
 ["dwarf.gunner.scatter_shot"]={gain=1.45,settle=.22},
 ["dwarf.gunner.piercing_round"]={gain=1.20,settle=.23},
 ["dwarf.gunner.blast_step"]={gain=1.30,settle=.23},
 ["dwarf.gunner.siege_barrage"]={gain=1.25,settle=.30},
}
local function gunner(d,kind,age)
 local pulse,since=Presentation.beat(d,age)
 local phase=age/d.windup
 local ready=smooth(phase/.76)*(1-smooth((age-d.windup-d.active)/d.recovery))
 local recoil=gunRecoil[d.id]
 local span=math.min(d.interval or .3,recoil and recoil.settle or .24)
 local gain=recoil and recoil.gain or 1
 local kick=pulse>0 and gain*smooth(since/(span*.18))*(1-smooth((since/span-.18)/.82)) or 0
 local load=smooth(phase/.55)*(1-smooth((phase-.55)/.45))
 local right,left,elbow,torso
 if kind=="lob" then
  -- Cock the bomb behind the shoulder, open the elbow into release, then
  -- let the empty hand cross the chest. Reload before each later toss.
  if pulse>0 and pulse<(d.pulses or 1) then
   local u=since/d.interval
   load+=smooth((u-.24)/.38)*(1-smooth((u-.62)/.38))
  end
  right=v(78+61*load-34*kick,-28*load+16*kick,-10-14*load)
  left=v(48-18*kick,7,24)
  elbow=v(-67*load-12*kick)
  torso=v(4-10*kick,18*load-13*kick,5*load)
 elseif kind=="mortar" then
  right=v(90+20*load+24*kick,-5*load,-5)
  left=v(93+14*kick,0,14)
  elbow=v(-14*load-27*kick)
  torso=v(3-16*kick,0,4*load)
 else
  right=v(90-18*load+8*kick,0,-5)
  left=v(87+4*kick,0,10)
  elbow=v(-12*kick)
  torso=v(3-6*kick,0,0)
 end
 local angles={right=right,left=left,elbow=elbow,leftElbow=v(-35),wrist=v(),neck=v(),
  torso=torso,rightHip=v(-8),leftHip=v(10),rightKnee=v(10),leftKnee=v(8),weapon=v()}
 local pose={angles={},cutting=false}
 for channel,a in pairs(Clips.rest.dwarf) do pose.angles[channel]=v(unpack(a)):Lerp(angles[channel],ready) end
 return rebuild(pose)
end

local function challenge(d,age)
 local wind=smooth(age/(d.windup*.66))*(1-smooth((age/d.windup-.66)/.34))
 local shout=smooth((age/d.windup-.56)/.44)*(1-smooth((age-d.windup-d.active)/d.recovery))
 local pose=resting("knight")
 -- Draw the shield across the chest, then lift it clear of the face.
 pose.angles.left=v(78*wind+130*shout,-25*wind-15*shout,22*shout)
 pose.angles.right=v(32*wind+59*shout,15*wind,-24*shout)
 pose.angles.leftElbow=v(27*wind+14*shout)
 pose.angles.torso=v(12*wind-10*shout,16*wind-8*shout)
 pose.angles.neck=v(-6*wind+8*shout)
 return rebuild(pose)
end

local function shieldPose(d,age,rigType,contact,ending)
 local bash=Config.Skills.knight[1]
 local _,since=Presentation.beat(d,age)
 local impact=bash.windup
 local follow=impact+bash.active
 local t
 if age<contact then
  t=impact*age/contact
 elseif age>=ending then
  t=follow+bash.recovery*math.clamp((age-ending)/d.recovery,0,1)
 elseif age>=contact+((d.pulses or 1)-1)*(d.interval or 0) then
  t=impact+bash.active*math.clamp(since/(ending-contact-((d.pulses or 1)-1)*(d.interval or 0)),0,1)
 else
  local phase=since/d.interval
  if phase<.25 then t=impact+bash.active*smooth(phase/.25)
  elseif phase<.62 then t=follow-(follow-impact*.55)*smooth((phase-.25)/.37)
  else t=impact*(.55+.45*smooth((phase-.62)/.38)) end
 end
 local pose=resting("knight")
 for ch,cf in Shield.sample(t,rigType) do
  if pose.angles[ch] then
   pose[ch]=cf
   local x,y,z=cf:ToEulerAnglesXYZ()
   pose.angles[ch]=v(math.deg(x),math.deg(y),math.deg(z))
  end
 end
 return age>=ending and mix(pose,resting("knight"),smooth((age-ending)/d.recovery)) or pose
end
function Motion.sample(classId,d,age,rigType)
 if type(age)~="number" or age~=age then return nil end
 local profile=Presentation.get(d);if not profile then return nil end
 local kind=profile.motion
 if d.branch=="gunner" then return gunner(d,kind,age) end
 if kind=="slash" and classId=="knight" and (d.pulses or 1)>1 then kind="cross" end
 local contact=d.windup+(d.hitDelay or 0)
 local ending=d.windup+d.active
 if d.id=="knight.common.provoke" then return challenge(d,age) end
 if kind=="shield" and classId=="knight" then return shieldPose(d,age,rigType,contact,ending) end
 local pulse,since=Presentation.beat(d,age)
 local base,sample,sourceScale=source(classId,kind,math.max(1,pulse),rigType,d.id)
 local bContact=base.windup+(base.hitDelay or 0)
 local pose
 if age<contact then
  pose=sample(bContact*math.clamp(age/contact,0,1))
 elseif age<ending then
  if pulse<(d.pulses or 1) then
   local phase=math.clamp(since/d.interval,0,1)
   local follow=bContact+math.min(.10*(sourceScale or 1),base.active*.7)
   if phase<.32 then
    pose=sample(bContact+(follow-bContact)*smooth(phase/.32))
   else
    local nextBase,nextSample=source(classId,kind,pulse+1,rigType,d.id)
    local nextContact=nextBase.windup+(nextBase.hitDelay or 0)
    if phase<.66 then pose=mix(sample(follow),nextSample(nextContact*.6),smooth((phase-.32)/.34))
    else pose=nextSample(nextContact*(.6+.4*smooth((phase-.66)/.34))) end
   end
  else
   local lastContact=contact+((d.pulses or 1)-1)*(d.interval or 0)
   local follow=math.clamp(since/(ending-lastContact),0,1)
   pose=sample(bContact+(base.windup+base.active-bContact)*follow)
  end
 else
  local recovery=math.clamp((age-ending)/d.recovery,0,1)
  pose=mix(sample(base.windup+base.active+base.recovery*recovery),resting(classId),smooth(recovery))
 end
 if kind=="shield" and classId=="dwarf" then
  local weight=smooth(age/math.max(.01,contact*.7))*(1-smooth((age-ending)/d.recovery))
  for channel,a in pairs(Clips.rest.dwarf) do pose.angles[channel]=v(unpack(a)):Lerp(v(unpack(Clips.guard.dwarf[channel])),weight) end
  pose.angles.torso=v(12,0,-5)*weight
  pose.angles.left=v(65,0,15)*weight
  rebuild(pose);pose.axeStrikeTurn=weight
 elseif kind=="counter" and age<contact then
  local braceAge=base.windup*.68
  local brace=Melee.sample("knight",1,braceAge,nil,nil,"knight.mixamo.brace",rigType)
  local phase=age/contact
  pose=mix(pose,brace,.85*smooth(phase/.44)*(1-smooth((phase-.54)/.46)))
 elseif kind=="spin" then
  -- Rotate the whole visual rig. A 360-degree waist twist leaves the legs
  -- planted backwards and is visibly wrong even when the matrix is finite.
  local turns=smooth((age-contact+.06)/math.max(.1,d.active+.06))
  pose.root=CFrame.Angles(0,-math.pi*2*turns,0)
  pose.torso=rot(v(0,0,0));pose.angles.torso=v()
 end
 if d.id:find("stonebound_leap",1,true) then
  local phase=math.clamp(age/math.max(.01,contact),0,1)
  pose.root=CFrame.new(0,age<contact and math.sin(math.pi*phase)*1.4 or 0,0)
 elseif classId=="dwarf" then
  -- Only Ground Slam and explicit leap skills use the jump's visual root.
  pose.root=nil
 end
 pose.aimWeapon=kind=="thrust" and smooth(age/math.max(.01,contact*.7))*(1-smooth((age-ending)/d.recovery)) or nil
 local cuttingBeat=pulse==0 or since<=.12 or (pulse<(d.pulses or 1) and since>=d.interval-.045)
 pose.cutting=profile.effect=="slash" and age>=contact-.045 and age<ending and (kind=="spin" or cuttingBeat)
 return pose
end
function Motion.forCharacter(character,now)
 local mode=character:GetAttribute("K0State")
 if mode~="Attack" or character:GetAttribute("TLTDeathFalling") then records[character]=nil;return nil end
 local classId=character:GetAttribute("K0ClassId")
 local d=definitions[character:GetAttribute("K0SkillId")]
 local started=character:GetAttribute("K0AttackStartedAt")
 if not d or owner[d.id]~=classId or type(started)~="number" then records[character]=nil;return nil end
 local record=records[character]
 if not record or record.started~=started or record.d~=d then
  local entry=record and record.classId==classId and started>=record.started and Motion.sample(classId,record.d,started-record.started,record.rigType) or nil
  record={started=started,d=d,classId=classId,entry=entry};records[character]=record
 end
 local age=math.max(0,now-started)
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 record.rigType=humanoid and humanoid.RigType
 local pose=Motion.sample(classId,d,age,humanoid and humanoid.RigType)
 local blend=smooth(age/math.max(.01,d.windup*.35))
 if record.entry and blend<1 then
  local target=pose;pose=mix(record.entry,target,blend)
  pose.root=(record.entry.root or CFrame.identity):Lerp(target.root or CFrame.identity,blend)
  pose.aimWeapon=(record.entry.aimWeapon or 0)*(1-blend)+(target.aimWeapon or 0)*blend
  pose.cutting=target.cutting
 end
 return pose
end
return Motion
