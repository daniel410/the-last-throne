-- Advanced choreography retimes the reviewed sword/axe contact curves. Native
-- socket review takes precedence over inventing Euler poses for held weapons.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
local FinalBeat=require(script.Parent.SkillFinalBeat)
local Bomb=require(script.Parent.BombVisual)
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
local function offset(pose,channel,delta)
 pose.angles[channel]+=delta
 pose[channel]=rot(pose.angles[channel])+pose[channel].Position
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
local bombPoses={
 hold={right=v(52,-8,12),elbow=v(-64),left=v(19,-10,30),torso=v(3,-6,2)},
 load={right=v(-31,-23,37),elbow=v(-104),left=v(46,-18,30),torso=v(-9,-29,7),
  rightHip=v(-19),rightKnee=v(25),leftHip=v(8),leftKnee=v(14)},
 release={right=v(111,12,12),elbow=v(-12),left=v(21,-23,28),torso=v(11,17,-6),
  rightHip=v(-14),rightKnee=v(16),leftHip=v(-22),leftKnee=v(25)},
 follow={right=v(47,38,5),elbow=v(-25),left=v(16,-14,22),torso=v(17,26,-10),
  rightHip=v(-12),rightKnee=v(12),leftHip=v(-19),leftKnee=v(23)},
 lowLoad={right=v(-53,-17,19),elbow=v(-28),left=v(28,-26,27),torso=v(24,-21,6),
  rightHip=v(-28),rightKnee=v(39),leftHip=v(-31),leftKnee=v(42)},
 lowRelease={right=v(47,11,16),elbow=v(-8),left=v(24,-18,39),torso=v(28,15,-8),
  rightHip=v(-19),rightKnee=v(34),leftHip=v(-28),leftKnee=v(37)},
 lowFollow={right=v(57,27,15),elbow=v(-15),left=v(20,-11,36),torso=v(24,23,-8),
  rightHip=v(-21),rightKnee=v(24),leftHip=v(-24),leftKnee=v(28)},
}
local opposite={
 right="left",left="right",elbow="leftElbow",leftElbow="elbow",
 rightHip="leftHip",leftHip="rightHip",rightKnee="leftKnee",leftKnee="rightKnee",
}
local function offhandPose(pose)
 local angles={}
 for channel in pairs(pose.angles) do
  local a=pose.angles[opposite[channel] or channel]
  angles[channel]=v(a.X,-a.Y,-a.Z)
 end
 pose.angles=angles
 pose.offhand=true
 return rebuild(pose)
end
local function bombToss(d,age,profile)
 local launch=d.windup+(d.hitDelay or 0)-profile.flight
 local loaded=launch*.61
 local low=profile.path=="bounce" or profile.path=="roll"
 local load=low and bombPoses.lowLoad or bombPoses.load
 local release=low and bombPoses.lowRelease or bombPoses.release
 local follow=low and bombPoses.lowFollow or bombPoses.follow
 local followTime=d.pulses>1 and .09 or .13
 local rest=resting("dwarf")
 local a,b,u
 if age<launch*.2 then
  a,b,u=rest.angles,bombPoses.hold,age/(launch*.2)
 elseif age<loaded then
  a,b,u=bombPoses.hold,load,(age-launch*.2)/(loaded-launch*.2)
 elseif age<launch then
  a,b,u=load,release,(age-loaded)/(launch-loaded)
 else
  local pulse=math.min(d.pulses,math.floor((age-launch)/d.interval)+1)
  local since=age-launch-(pulse-1)*d.interval
  local reload=d.interval*.61
  if since<followTime then
   a,b,u=release,follow,since/followTime
  elseif pulse<d.pulses then
   if since<reload then a,b,u=follow,load,(since-followTime)/(reload-followTime)
   else a,b,u=load,release,(since-reload)/(d.interval-reload) end
  else
   local lastLaunch=launch+(d.pulses-1)*d.interval
   local recovery=d.windup+d.active+d.recovery-lastLaunch-followTime
   a,b,u=follow,rest.angles,(since-followTime)/recovery
  end
 end
 local weight=smooth(u)
 local pose={angles={},cutting=false}
 for channel,value in pairs(rest.angles) do
  pose.angles[channel]=(a[channel] or value):Lerp(b[channel] or value,weight)
 end
 return offhandPose(pose)
end
local function gunner(d,kind,age)
 local pulse,since=Presentation.beat(d,age)
 local phase=age/d.windup
 local ready=smooth(phase/.76)*(1-smooth((age-d.windup-d.active)/d.recovery))
 local recoil=gunRecoil[d.id]
 local span=math.min(d.interval or .3,recoil and recoil.settle or .24)
 local gain=recoil and recoil.gain or 1
 local kick=pulse>0 and gain*smooth(since/(span*.18))*(1-smooth((since/span-.18)/.82)) or 0
 local finish=FinalBeat.weight(d,pulse,since)
 local load=smooth(phase/.55)*(1-smooth((phase-.55)/.45))
 local right,elbow,torso
 if kind=="mortar" then
  local elevation=smooth(phase/.78)*(1-smooth((age-d.windup-d.active)/d.recovery))
  local reset=0
  if pulse>0 and pulse<d.pulses then
   local cycle=since/d.interval
   reset=smooth((cycle-.23)/.23)*(1-smooth((cycle-.46)/.45))
  end
  right=v(90+20*load+16*elevation+24*kick-24*reset+8*finish,-5*load,-5)
  elbow=v(-14*load-27*kick-21*reset-9*finish)
  torso=v(3-7*elevation-16*kick+10*reset-7*finish,0,4*load)
 else
  right=v(90-18*load+8*kick,0,-5)
  elbow=v(-12*kick)
  torso=v(3-6*kick,0,0)
 end
 local brace=kind=="mortar" and (14*load+12*kick+9*finish) or kind=="shoot" and 7*kick or 0
 if d.id=="dwarf.gunner.piercing_round" then
  -- Keep the burst on its socket axis while the stance takes the recoil.
  brace+=8*load+10*kick
  torso+=v(-5*kick,0,6*kick)
 end
 local retreat=(d.move or 0)<0 and kick or 0
 local angles={right=right,left=v(17+5*kick,-4,18),elbow=elbow,leftElbow=v(-12),wrist=v(),neck=v(6*retreat),
  torso=torso+v(-8*retreat),rightHip=v(-8-brace),leftHip=v(10-brace+12*retreat),
  rightKnee=v(10+brace*1.5),leftKnee=v(8+brace+14*retreat),weapon=v()}
 local pose={angles={},cutting=false}
 for channel,a in pairs(Clips.rest.dwarf) do pose.angles[channel]=v(unpack(a)):Lerp(angles[channel],ready) end
 return offhandPose(pose)
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
 local pulse,since=Presentation.beat(d,age)
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
 if d.id=="knight.steel_knight.shield_breaker" then
  local phase=age/contact
  local brace=smooth(phase/.55)*(1-smooth((phase-.55)/.45))
  local drive=smooth((age-contact)/.05)*(1-smooth((age-contact-.05)/.14))
  -- Wind behind the shield and drive through the lead leg after contact.
  offset(pose,"torso",v(-7,16,0)*brace+v(13,-6,-5)*drive)
  offset(pose,"leftKnee",v(16*brace+18*drive))
  offset(pose,"rightHip",v(-11*drive))
 elseif d.id=="knight.paladin.shield_verdict" then
  local recoil=smooth((age-contact)/.04)*(1-smooth((age-contact-.04)/.16))
  offset(pose,"torso",v(-7*recoil,-4*recoil,0))
  offset(pose,"leftKnee",v(10*recoil))
 end
 if age>=ending then pose=mix(pose,resting("knight"),smooth((age-ending)/d.recovery)) end
 local finish=FinalBeat.weight(d,pulse,since)
 if finish>0 then
  if d.id=="knight.steel_knight.unyielding_front" then
   -- Plant the shield forward and let the lead leg absorb the second impact.
   offset(pose,"torso",v(13,-7,-6)*finish)
   offset(pose,"left",v(15,-11,-16)*finish)
   offset(pose,"leftKnee",v(22*finish))
   offset(pose,"rightHip",v(-12*finish))
  elseif d.id=="knight.paladin.oath_of_dawn" then
   -- Raise the sword and open the shield arm as the crest ascends.
   offset(pose,"right",v(40,-6,-20)*finish)
   offset(pose,"left",v(-21,5,26)*finish)
   offset(pose,"torso",v(-12,5,4)*finish)
  end
 end
 return pose
end
local function axeCatch(d,age,contact,ending,base,sample,classId)
 local flight=d.interval
 local caught=contact+flight
 local release=base.windup+(base.hitDelay or 0)
 local ready=resting(classId)
 offset(ready,"right",v(82,-12,-8))
 offset(ready,"elbow",v(-38))
 offset(ready,"torso",v(-8,18,-8))
 if d.crosscut then
  offset(ready,"right",v(-9,-16,19))
  offset(ready,"torso",v(4,-14,11))
 end
 if age<caught then
  local travel=math.clamp((age-contact)/flight,0,1)
  local outgoing=sample(release+(base.windup+base.active-release)*smooth(travel/.28))
  return mix(outgoing,ready,smooth((travel-.32)/.68))
 end
 local settle=smooth((age-caught)/(ending+d.recovery-caught))
 local pose=mix(ready,resting(classId),settle)
 local absorb=smooth((age-caught)/.055)*(1-smooth((age-caught-.055)/.17))
 offset(pose,"elbow",v(-24*absorb))
 offset(pose,"torso",v(-11*absorb,8*absorb))
 if d.crosscut then
  offset(pose,"rightKnee",v(21*absorb))
  offset(pose,"leftHip",v(-14*absorb))
 end
 return pose
end
function Motion.sample(classId,d,age,rigType)
 if type(age)~="number" or age~=age then return nil end
 local profile=Presentation.get(d);if not profile then return nil end
 local kind=profile.motion
 local bomb=Bomb.get(d.id)
 if bomb then return bombToss(d,age,bomb) end
 if d.branch=="gunner" then return gunner(d,d.form=="cone" and "shoot" or kind,age) end
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
  local u=math.clamp(age/contact,0,1)
  if kind=="slam" or kind=="chop" or d.braced then
   -- Spend more of the windup with the weapon loaded, then accelerate
   -- through the same authored contact pose at the same combat time.
   u=u+.13*math.sin(u*math.pi*2)
  end
  pose=sample(bContact*u)
 elseif d.returning and kind=="throw" then
  pose=axeCatch(d,age,contact,ending,base,sample,classId)
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
  -- Each confirmed beat has its own turn of the visual rig. The server
  -- root and aim remain available for movement and range presentation.
  local turns
  if (d.pulses or 1)>1 then
   turns=pulse==0 and smooth(age/contact) or
    pulse-1+(pulse<d.pulses and smooth(since/d.interval) or 0)
  else turns=smooth((age-contact+.06)/math.max(.1,d.active+.06)) end
  pose.root=CFrame.Angles(0,-math.pi*2*turns,0)
  pose.torso=rot(v(0,0,0));pose.angles.torso=v()
 elseif kind=="thrust" then
  local brake=smooth((age-contact+.075)/.11)*(1-smooth((age-contact-.035)/.20))
  local weight=d.id=="knight.steel_knight.vanguard_strike" and 1.35 or 1
  offset(pose,"leftKnee",v(12*brake*weight))
  offset(pose,"rightHip",v(-8*brake*weight))
  if d.id=="knight.steel_knight.vanguard_strike" then
   local brace=smooth(age/(contact*.55))*(1-smooth((age-contact*.60)/(contact*.40)))
   local settle=pulse>0 and smooth(since/.055)*(1-smooth((since-.055)/.17)) or 0
   offset(pose,"left",v(16,-10,-18)*brace+v(-9,0,8)*settle)
   offset(pose,"torso",v(9,-13,-6)*brace+v(9,6,0)*settle)
   offset(pose,"leftKnee",v(15*settle))
  elseif d.id=="knight_driving_thrust" then
   local settle=smooth(since/.055)*(1-smooth((since-.055)/.16))
   offset(pose,"leftKnee",v(10*settle))
   offset(pose,"rightHip",v(-9*settle,0,-4*settle))
   offset(pose,"torso",v(-6*settle,0,0))
  end
 elseif d.id=="dwarf_hooking_chop" then
  local pull=smooth(since/.06)*(1-smooth((since-.06)/.16))
  offset(pose,"torso",v(-8,14,6)*pull)
  offset(pose,"elbow",v(23,0,0)*pull)
  offset(pose,"rightKnee",v(12,0,0)*pull)
 end
 if d.id=="knight.steel_knight.counter_slash" then
  local brace=smooth(age/(contact*.46))*(1-smooth((age-contact*.62)/(contact*.38)))
  local recoil=smooth((age-contact)/.06)*(1-smooth((age-contact-.06)/.15))
  offset(pose,"left",v(12,0,-16)*brace+v(-13,0,12)*recoil)
  offset(pose,"torso",v(8,-12,-6)*brace+v(3,13,6)*recoil)
  offset(pose,"leftKnee",v(12*brace+14*recoil))
 end
 if d.id=="knight_crescent_cut" then
  local phase=age/contact
  local gather=smooth(phase/.5)*(1-smooth((phase-.5)/.5))
  local finish=pulse>0 and smooth(since/.075)*(1-smooth((since-.075)/.16)) or 0
  offset(pose,"torso",v(-5,17,6)*gather+v(9,-15,-8)*finish)
  offset(pose,"left",v(13,9,-12)*gather+v(-8,-6,13)*finish)
  offset(pose,"leftKnee",v(12*gather+16*finish))
 elseif d.id=="knight.paladin.oathbreaker_strike" then
  local load=smooth(age/(contact*.56))*(1-smooth((age/contact-.56)/.44))
  local plant=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.17))
  -- Leave the authored sword contact intact and put the weight through the lead leg.
  offset(pose,"torso",v(-9,0,7)*load+v(12,0,-6)*plant)
  offset(pose,"leftKnee",v(9*load+19*plant))
  offset(pose,"leftHip",v(-8*plant))
 elseif d.id=="dwarf_braced_throw" then
  local phase=age/contact
  local plant=smooth(phase/.46)*(1-smooth((phase-.55)/.45))
  local release=pulse>0 and smooth(since/.065)*(1-smooth((since-.065)/.18)) or 0
  offset(pose,"torso",v(-9,-14,-7)*plant+v(10,12,5)*release)
  offset(pose,"rightKnee",v(23*plant+9*release))
  offset(pose,"leftKnee",v(14*plant+16*release))
  offset(pose,"left",v(19,-9,16)*plant+v(-13,9,-6)*release)
 end
 local finish=FinalBeat.weight(d,pulse,since)
 if finish>0 then
  if classId=="dwarf" then
   -- Mountain Collapse settles through both knees after the second strike.
   offset(pose,"torso",v(18*finish))
   offset(pose,"leftKnee",v(18*finish))
   offset(pose,"rightKnee",v(24*finish))
  else
   local spinning=kind=="spin"
   offset(pose,"torso",v((spinning and 9 or 13)*finish,0,(spinning and -9 or 6)*finish))
   offset(pose,"leftKnee",v(16*finish))
   offset(pose,"rightHip",v(-11*finish))
  end
 end
 if d.id=="dwarf.iron_axe.mountain_strike" then
  local phase=age/contact
  local lift=smooth(phase/.56)*(1-smooth((phase-.56)/.44))
  local weight=smooth((age-contact)/.075)*(1-smooth((age-contact-.075)/.22))
  -- Plant both feet while the axe is high, then absorb the blow low.
  offset(pose,"torso",v(-12,8,0)*lift+v(18,0,0)*weight)
  offset(pose,"leftHip",v(-10*lift-14*weight))
  offset(pose,"rightHip",v(-8*lift-11*weight))
  offset(pose,"leftKnee",v(15*lift+22*weight))
  offset(pose,"rightKnee",v(12*lift+19*weight))
 elseif d.id=="dwarf.iron_axe.armor_splitter" then
  local weight=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.18))
  offset(pose,"torso",v(12*weight,0,4*weight))
  offset(pose,"leftKnee",v(13*weight))
  offset(pose,"rightKnee",v(16*weight))
 end
 if d.id=="dwarf.iron_axe.stonebound_leap" then
  local phase=math.clamp(age/math.max(.01,contact),0,1)
  local air=math.max(0,1-((phase-.61)/.39)^2)*1.5
  local landing=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.18))
  local tuck=smooth((phase-.22)/.39)*(1-smooth((phase-.61)/.39))
  pose.root=CFrame.new(0,air-.24*landing,0)
  offset(pose,"rightHip",v(-21,0,5)*tuck)
  offset(pose,"leftHip",v(-15,0,-5)*tuck)
  offset(pose,"rightKnee",v(25*tuck+18*landing))
  offset(pose,"leftKnee",v(30*tuck+24*landing))
  offset(pose,"left",v(-12,0,-15)*tuck)
  offset(pose,"torso",v(-10*tuck+12*landing))
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
  pose.offhand=target.offhand
 end
 return pose
end
return Motion
