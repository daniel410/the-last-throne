-- Advanced choreography retimes the reviewed sword/axe contact curves. Native
-- socket review takes precedence over inventing Euler poses for held weapons.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
local Clips=require(script.Parent.K0MeleeClips)
local Melee=require(script.Parent.K0MeleeMotion)
local Shield=require(script.Parent.K0ShieldBashMotion)
local Motion={}
local records=setmetatable({},{__mode="k"})
local definitions={}
for _,classId in ipairs({"knight","dwarf"}) do
 for _,d in ipairs(Config.Skills[classId]) do if d.advanced then definitions[d.id]=d end end
end
local function smooth(x) x=math.clamp(x,0,1);return x*x*(3-2*x) end
local function v(x,y,z) return Vector3.new(x or 0,y or 0,z or 0) end
local function rot(a) return CFrame.Angles(math.rad(a.X),math.rad(a.Y),math.rad(a.Z)) end
local function rebuild(pose)
 for channel,a in pairs(pose.angles) do pose[channel]=rot(a) end
 return pose
end
local function mix(a,b,weight)
 local pose={angles={},axeStrikeTurn=a.axeStrikeTurn}
 for channel,value in pairs(a.angles) do pose.angles[channel]=value:Lerp(b.angles[channel],weight) end
 return rebuild(pose)
end
local function resting(classId)
 local pose={angles={}}
 for channel,a in pairs(Clips.rest[classId]) do pose.angles[channel]=v(unpack(a)) end
 return rebuild(pose)
end
local function source(classId,kind,pulse,rigType,skillId)
 local combo=kind=="cross" and pulse%2==0 and 2 or 1
 if kind=="sweep" or kind=="spin" then combo=2 end
 if kind=="chop" or kind=="slam" then combo=3 end
 if classId=="knight" then
  local variant=kind=="sweep" and "knight.mixamo.wide" or kind=="chop" and "knight.mixamo.power" or nil
  return Config.BasicAttackProfiles.knight.attacks[combo],function(age) return Melee.sample("knight",combo,age,nil,nil,variant,rigType) end
 end
 local index=kind=="throw" and 2 or kind=="slam" and 3 or 1
 local base=Config.Skills.dwarf[index]
 local clipId=kind=="sweep" and "dwarf.mixamo.sweep"
  or kind=="slam" and "dwarf.mixamo.grounded"
  or skillId=="dwarf_hooking_chop" and "dwarf.mixamo.backhand" or base.id
 return base,function(age) return Melee.sample("dwarf",1,age,nil,nil,clipId,rigType) end
end
local function gunner(d,kind,age)
 local contact=d.windup
 local pulse,since=Presentation.beat(d,age)
 local load=smooth(age/math.max(.01,contact*.7))
 local fade=1-smooth((age-contact-d.active)/d.recovery)
 local kick=pulse>0 and since<.16 and math.sin(math.pi*math.clamp(since/.16,0,1)) or 0
 -- Arms point the held barrel forward; only the elbow supplies recoil.
 local angles={right=v(90+(kind=="lob" and 35*(1-smooth((age-contact+.08)/.08)) or 0),0,-5),
  left=v(kind=="lob" and 35 or 87,0,kind=="lob" and 18 or 10),
  elbow=v(-12*kick),leftElbow=v(-35),wrist=v(),neck=v(),
  torso=v(3-6*kick,kind=="lob" and 12 or 0,0),rightHip=v(-8),leftHip=v(10),rightKnee=v(10),leftKnee=v(8),weapon=v()}
 local pose={angles={},cutting=false}
 for channel,a in pairs(Clips.rest.dwarf) do pose.angles[channel]=v(unpack(a)):Lerp(angles[channel] or v(),load*fade) end
 return rebuild(pose)
end
function Motion.sample(classId,d,age,rigType)
 if type(age)~="number" or age~=age then return nil end
 local profile=Presentation.get(d);if not profile then return nil end
 local kind=profile.motion
 if d.branch=="gunner" then return gunner(d,kind,age) end
 local contact=d.windup+(d.hitDelay or 0)
 local ending=d.windup+d.active
 local pulse,since=Presentation.beat(d,age)
 local base,sample=source(classId,kind,math.max(1,pulse),rigType,d.id)
 local bContact=base.windup+(base.hitDelay or 0)
 local pose
 if age<contact then
  pose=sample(bContact*math.clamp(age/contact,0,1))
 elseif age<ending then
  if pulse<(d.pulses or 1) then
   local phase=math.clamp(since/d.interval,0,1)
   local follow=bContact+math.min(.10,base.active*.7)
   if phase<.32 then pose=sample(bContact+(follow-bContact)*smooth(phase/.32))
   elseif phase<.66 then pose=mix(sample(follow),sample(bContact*.6),smooth((phase-.32)/.34))
   else pose=sample(bContact*(.6+.4*smooth((phase-.66)/.34))) end
  else pose=sample(bContact+(base.windup+base.active-bContact)*math.clamp(since/.12,0,1)) end
 else
  local recovery=math.clamp((age-ending)/d.recovery,0,1)
  pose=mix(sample(base.windup+base.active+base.recovery*recovery),resting(classId),smooth(recovery))
  if classId=="dwarf" then pose.axeStrikeTurn=(pose.axeStrikeTurn or 1)*(1-smooth(recovery)) end
 end
 if kind=="shield" and classId=="knight" then
  local bash=Config.Skills.knight[1]
  local t=age<contact and age/contact*bash.windup
   or age<ending and bash.windup+math.min(bash.active,math.max(0,since))
   or bash.windup+bash.active+bash.recovery*math.clamp((age-ending)/d.recovery,0,1)
  local shield=Shield.sample(t,rigType)
  -- Use the reviewed shield-first choreography, including its sheathed sword.
  for _,channel in ipairs(Clips.channels) do
   if shield[channel] then pose[channel]=shield[channel];local x,y,z=shield[channel]:ToEulerAnglesXYZ();pose.angles[channel]=v(math.deg(x),math.deg(y),math.deg(z)) end
  end
  if age>=ending then pose=mix(pose,resting(classId),smooth((age-ending)/d.recovery)) end
 elseif kind=="shield" and classId=="dwarf" then
  local weight=smooth(age/math.max(.01,contact*.7))*(1-smooth((age-ending)/d.recovery))
  for channel,a in pairs(Clips.rest.dwarf) do pose.angles[channel]=v(unpack(a)):Lerp(v(unpack(Clips.guard.dwarf[channel])),weight) end
  pose.angles.torso=v(12,0,-5)*weight
  pose.angles.left=v(65,0,15)*weight
  rebuild(pose);pose.axeStrikeTurn=weight
 elseif kind=="spin" then
  -- Rotate the whole visual rig. A 360-degree waist twist leaves the legs
  -- planted backwards and is visibly wrong even when the matrix is finite.
  local turns=math.clamp((age-contact+.06)/math.max(.1,d.active+.06),0,1)
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
 pose.cutting=profile.effect=="slash" and age>=contact-.045 and age<ending
 return pose
end
function Motion.forCharacter(character,now)
 local mode=character:GetAttribute("K0State")
 if mode~="Attack" or character:GetAttribute("TLTDeathFalling") then records[character]=nil;return nil end
 local classId=character:GetAttribute("K0ClassId")
 local d=definitions[character:GetAttribute("K0SkillId")]
 local started=character:GetAttribute("K0AttackStartedAt")
 if not d or not Clips.rest[classId] or type(started)~="number" then records[character]=nil;return nil end
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
  local root,aim=pose.root,pose.aimWeapon;pose=mix(record.entry,pose,blend);pose.root,pose.aimWeapon=root,aim
 end
 return pose
end
return Motion
