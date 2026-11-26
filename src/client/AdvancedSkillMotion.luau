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
 ["dwarf.gunner.shell_burst"]={gain=1.18,settle=.18},
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
 rollLoad={right=v(-62,-13,13),elbow=v(-38),left=v(34,-18,32),torso=v(30,-23,10),
  rightHip=v(-38),rightKnee=v(53),leftHip=v(-25),leftKnee=v(31)},
 rollRelease={right=v(31,14,8),elbow=v(-6),left=v(29,-24,34),torso=v(35,14,-11),
  rightHip=v(-19),rightKnee=v(27),leftHip=v(-43),leftKnee=v(55)},
 rollFollow={right=v(44,24,12),elbow=v(-19),left=v(21,-10,27),torso=v(20,25,-6),
  rightHip=v(-13),rightKnee=v(19),leftHip=v(-34),leftKnee=v(43)},
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
 local roll=profile.path=="roll"
 local bounce=profile.path=="bounce"
 local load=roll and bombPoses.rollLoad or bounce and bombPoses.lowLoad or bombPoses.load
 local release=roll and bombPoses.rollRelease or bounce and bombPoses.lowRelease or bombPoses.release
 local follow=roll and bombPoses.rollFollow or bounce and bombPoses.lowFollow or bombPoses.follow
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
 -- LoT's quick draw snaps at the elbow. Mortar recoil travels through
 -- the shoulder into the stance on a wider arc before the next lift.
 local peak=kind=="mortar" and .31 or .15
 local kick=pulse>0 and gain*smooth(since/(span*peak))*(1-smooth((since/span-peak)/(1-peak))) or 0
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
 local brace=kind=="mortar" and (14*load+16*kick+9*finish) or kind=="shoot" and 7*kick or 0
 if d.id=="dwarf.gunner.piercing_round" then
  -- Keep the burst on its socket axis while the stance takes the recoil.
  brace+=8*load+10*kick
  torso+=v(-5*kick,0,6*kick)
 elseif d.id=="dwarf.gunner.quickfire" then
  -- The off hand kicks, while a low stance catches all three shots.
  brace+=11+5*kick
  elbow-=v(19*kick)
  right+=v(9*kick)
  torso+=v(2-5*kick,0,-5*kick)
 elseif d.id=="dwarf.gunner.scatter_shot" then
  -- Shoulder the offhand gun low, then rock onto the rear foot at discharge.
  brace+=11*load+8*kick
  right+=v(-9*load+18*kick,-6*load,7*kick)
  elbow-=v(12*load+29*kick)
  torso+=v(12*load-13*kick,5*kick,-9*load+6*kick)
 end
 local retreat=(d.move or 0)<0 and kick or 0
 local angles={right=right,left=v(17+5*kick,-4,18),elbow=elbow,leftElbow=v(-12),wrist=v(),neck=v(6*retreat),
  torso=torso+v(-8*retreat),rightHip=v(-8-brace),leftHip=v(10-brace+12*retreat),
  rightKnee=v(10+brace*1.5),leftKnee=v(8+brace+14*retreat),weapon=v()}
 if d.id=="dwarf.gunner.gunner_shot" then
  -- Seat the left-hand gun against the line of sight, then take one recoil on the rear leg.
  local lower=pulse>0 and smooth((since-.046)/.072)*(1-smooth((since-.118)/.145)) or 0
  angles.right+=v(-11*load+18*kick-24*lower,3*load,-4*kick)
  angles.elbow+=v(10*load-26*kick+21*lower)
  angles.neck+=v(7*load,-10*load,4*load)
  angles.torso+=v(7*load-12*kick+8*lower,0,5*kick)
  angles.rightKnee+=v(17*load+20*kick)
 elseif d.id=="dwarf.gunner.piercing_round" then
  -- The off hand stays on the sight line through discharge, then lowers.
  local settle=pulse>0 and smooth((since-.035)/.075)*(1-smooth((since-.11)/.15)) or 0
  angles.neck+=v(6*load,-12*load,5*load)
  angles.right-=v(26*settle)
  angles.elbow+=v(-13*kick+17*settle)
  angles.leftKnee+=v(20*kick)
  angles.torso+=v(14*settle,0,-7*settle)
 end
 if d.id=="dwarf.gunner.scatter_shot" then
  local settle=pulse>0 and smooth((since-.045)/.075)*(1-smooth((since-.12)/.13)) or 0
  angles.rightKnee+=v(14*load+18*kick)
  angles.leftHip+=v(-13*settle,0,5*settle)
  angles.leftKnee+=v(16*settle)
  angles.torso+=v(10*settle,0,-4*settle)
 end
 if d.id=="dwarf.gunner.shell_burst" then
  -- Lift the left-hand tube from a crouch and lower it after the single shell.
  local sight=smooth((phase-.16)/.42)*(1-smooth((phase-.68)/.32))
  local settle=pulse>0 and smooth((since-.045)/.065)*(1-smooth((since-.11)/.16)) or 0
  angles.right+=v(24*sight-29*settle,-8*sight,8*kick)
  angles.elbow+=v(-21*sight-16*kick+20*settle)
  angles.torso+=v(13*sight-8*kick+15*settle,0,7*kick)
  angles.leftKnee+=v(22*sight+25*kick)
  angles.rightKnee+=v(17*settle)
 end
 if d.id=="dwarf.gunner.blast_step" then
  -- Take the backward skid on the rear leg while the offhand fires forward.
  angles.rightHip+=v(19*load-13*kick,0,-5*load)
  angles.rightKnee+=v(18*load+25*kick)
  angles.leftKnee+=v(-11*load+7*kick)
  angles.torso+=v(9*load-6*kick,0,5*kick)
  local settle=smooth((since-.04)/.06)*(1-smooth((since-.10)/.16))
  if pulse>0 then
   angles.elbow+=v(-18*kick+21*settle)
   angles.leftHip+=v(-13*settle,0,-6*settle)
   angles.leftKnee+=v(17*settle)
   angles.torso+=v(14*settle,0,-8*settle)
  end
 end
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
 if d.id=="knight_guarded_strike" then
  -- Keep the shield close on entry and bring it back up after the hit.
  local phase=age/contact
  local brace=smooth(phase/.48)*(1-smooth((phase-.62)/.38))
  local cover=smooth((age-contact)/.075)*(1-smooth((age-contact-.075)/.19))
  offset(pose,"leftElbow",v(19*brace+27*cover))
  offset(pose,"left",v(16,-10,8)*brace+v(12,-9,-10)*cover)
  offset(pose,"torso",v(8,-11,-7)*brace+v(-9,8,-5)*cover)
  offset(pose,"leftKnee",v(15*brace+17*cover))
 elseif d.id=="knight.steel_knight.shield_breaker" then
  local phase=age/contact
  local brace=smooth(phase/.55)*(1-smooth((phase-.55)/.45))
  local drive=smooth((age-contact)/.05)*(1-smooth((age-contact-.05)/.14))
  local recover=smooth((age-contact-.05)/.10)*(1-smooth((age-contact-.15)/.16))
  -- Tuck the shield before the shove, then pull it back over the chest.
  offset(pose,"leftElbow",v(19*brace+24*recover))
  offset(pose,"left",v(7,-9,-12)*brace+v(10,-5,8)*recover)
  offset(pose,"torso",v(-7,16,0)*brace+v(13,-6,-5)*drive+v(-9,6,0)*recover)
  offset(pose,"leftKnee",v(16*brace+18*drive))
  offset(pose,"rightHip",v(-11*drive))
 elseif d.id=="knight.paladin.shield_verdict" then
  local recoil=smooth((age-contact)/.04)*(1-smooth((age-contact-.04)/.16))
  offset(pose,"torso",v(-7*recoil,-4*recoil,0))
  offset(pose,"leftKnee",v(10*recoil))
 elseif d.id=="knight.steel_knight.breaker_charge" then
  local load=pulse==0 and smooth(age/(contact*.52))*(1-smooth((age/contact-.70)/.30)) or 0
  local drive=pulse>0 and smooth(since/.045)*(1-smooth((since-.045)/.16)) or 0
  local second=pulse==2 and drive or 0
  offset(pose,"torso",v(17,-10,-9)*load+v(12,3,-7)*drive+v(-17,10,5)*second)
  offset(pose,"left",v(18,-12,-13)*load+v(11,-7,-9)*drive+v(15,3,-4)*second)
  offset(pose,"leftKnee",v(21*load+13*drive+9*second))
  offset(pose,"rightHip",v(-13*load-9*drive))
 elseif d.id=="knight.paladin.valiant_advance" then
  -- Settle behind the shield on entry and brace the leading foot at contact.
  local stride=smooth(age/(contact*.42))*(1-smooth((age/contact-.60)/.40))
  local plant=pulse>0 and smooth(since/.05)*(1-smooth((since-.05)/.17)) or 0
  offset(pose,"leftElbow",v(22*stride+15*plant))
  offset(pose,"left",v(14,-8,-13)*stride+v(-4,8,-12)*plant)
  offset(pose,"torso",v(12,-7,5)*stride+v(13,5,-5)*plant)
  offset(pose,"rightHip",v(21*stride-8*plant))
  offset(pose,"leftKnee",v(15*stride+23*plant))
 elseif d.id=="knight.paladin.radiant_charge" then
  -- Drive low with the shield and rise over the other leg on the second beat.
  local load=smooth(age/(contact*.46))*(1-smooth((age/contact-.63)/.37))
  local push=pulse>0 and smooth(since/.052)*(1-smooth((since-.052)/.14)) or 0
  local first=pulse==1 and push or 0
  local second=pulse==2 and push or 0
  offset(pose,"torso",v(16,-9,-8)*load+v(15,-4,-7)*first+v(-14,12,9)*second)
  offset(pose,"left",v(12,-8,-9)*load+v(-15,6,-13)*first+v(21,8,13)*second)
  offset(pose,"leftElbow",v(24*load-12*first+16*second))
  offset(pose,"leftKnee",v(17*load+24*first))
  offset(pose,"rightHip",v(-14*load-13*second))
  offset(pose,"rightKnee",v(23*second))
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
  -- Turn into the angled return with the hand outside the chest.
  offset(ready,"right",v(-6,-22,28))
  offset(ready,"torso",v(4,-21,14))
  offset(ready,"left",v(21,6,-20))
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
  offset(pose,"right",v(-12,16,-18)*absorb)
  offset(pose,"left",v(-13,-6,15)*absorb)
 elseif d.id=="dwarf.iron_axe.returning_echo" then
  -- Tuck the hand toward the ribs and take the straight catch on the lead leg.
  offset(pose,"right",v(-14,-10,16)*absorb)
  offset(pose,"leftKnee",v(23*absorb))
  offset(pose,"leftHip",v(-13*absorb))
 end
 return pose
end
function Motion.sample(classId,d,age,rigType)
 if type(age)~="number" or age~=age then return nil end
 local profile=Presentation.get(d);if not profile then return nil end
 local kind=profile.motion
 if d.id=="knight.paladin.dawn_burst" then kind="chop" end
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
  if d.id=="dwarf.iron_axe.iron_shoulder" then
   local load=pulse==0 and smooth(age/(contact*.56))*(1-smooth((age/contact-.70)/.30)) or 0
   local plant=pulse>0 and smooth(since/.05)*(1-smooth((since-.05)/.18)) or 0
   offset(pose,"torso",v(19,-17,20)*load+v(14,11,14)*plant)
   offset(pose,"left",v(-28,16,-9)*load+v(-34,8,-12)*plant)
   offset(pose,"right",v(-15,-16,21)*load+v(-17,-9,13)*plant)
   offset(pose,"leftKnee",v(20*load+28*plant))
   offset(pose,"rightHip",v(-16*load-11*plant))
  end
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
  if d.id=="knight.steel_knight.twin_cyclone" then
   local load=pulse==0 and smooth(age/(contact*.54))*(1-smooth((age/contact-.68)/.32)) or 0
   local follow=pulse>0 and smooth(since/.055)*(1-smooth((since-.055)/.18)) or 0
   local bank=pulse==2 and -1 or 1
   offset(pose,"torso",v(9*load+12*follow,0,bank*(12*load+18*follow)))
   offset(pose,pulse==2 and "leftKnee" or "rightKnee",v(16*load+21*follow))
  end
 elseif kind=="thrust" then
  local brake=smooth((age-contact+.075)/.11)*(1-smooth((age-contact-.035)/.20))
  local weight=d.id=="knight.steel_knight.vanguard_strike" and 1.35 or 1
  offset(pose,"leftKnee",v(12*brake*weight))
  offset(pose,"rightHip",v(-8*brake*weight))
  if d.id=="knight.steel_knight.vanguard_strike" then
   local brace=smooth(age/(contact*.55))*(1-smooth((age-contact*.60)/(contact*.40)))
   local settle=pulse>0 and smooth(since/.055)*(1-smooth((since-.055)/.17)) or 0
   -- Catch the forward step under the sword shoulder, then draw the shield back in.
   local recover=pulse>0 and smooth((since-.05)/.08)*(1-smooth((since-.13)/.16)) or 0
   offset(pose,"left",v(16,-10,-18)*brace+v(-9,0,8)*settle)
   offset(pose,"torso",v(9,-13,-6)*brace+v(9,6,0)*settle)
   offset(pose,"leftHip",v(-16,0,-5)*settle)
   offset(pose,"leftKnee",v(24*settle))
   offset(pose,"rightHip",v(12,0,5)*settle)
   offset(pose,"left",v(19,8,-14)*recover)
   offset(pose,"elbow",v(-23*recover))
   offset(pose,"torso",v(-10,-7,3)*recover)
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
 elseif d.id=="knight.steel_knight.guardian_counter" then
  local brace=smooth(age/(contact*.32))*(1-smooth((age/contact-.71)/.29))
  local release=pulse>0 and smooth(since/.055)*(1-smooth((since-.055)/.17)) or 0
  -- Load behind the shield, then open it as the sword side rises.
  offset(pose,"left",v(37,-17,-28)*brace+v(-10,18,22)*release)
  offset(pose,"leftElbow",v(32*brace+5*release))
  offset(pose,"torso",v(13,-22,-10)*brace+v(-11,19,10)*release)
  offset(pose,"rightKnee",v(16*brace))
  offset(pose,"leftHip",v(-14*release,0,-6*release))
  offset(pose,"leftKnee",v(16*brace+27*release))
 end
 if d.id=="knight.steel_knight.challenging_strike" then
  -- Cover the sword shoulder, then open the shield as the blade cuts down.
  local phase=age/contact
  local brace=smooth(phase/.50)*(1-smooth((phase-.65)/.35))
  local plant=smooth((age-contact+.035)/.088)*(1-smooth((age-contact-.053)/.19))
  offset(pose,"left",v(38,-19,-23)*brace+v(-12,16,17)*plant)
  offset(pose,"leftElbow",v(24*brace+11*plant))
  offset(pose,"right",v(8,-13,12)*brace+v(-15,12,-10)*plant)
  offset(pose,"torso",v(9,-19,-7)*brace+v(17,12,7)*plant)
  offset(pose,"rightKnee",v(17*brace))
  offset(pose,"leftHip",v(-18*plant))
  offset(pose,"leftKnee",v(14*brace+31*plant))
 elseif d.id=="knight.steel_knight.warcry_assault" then
  -- Rally behind the shield, answer across the chest, then plant for the last shout.
  local phase=age/contact
  local brace=smooth(phase/.58)*(1-smooth((phase-.58)/.42))
  local drive=pulse>0 and smooth(since/.055)*(1-smooth((since-.055)/.15)) or 0
  local answer=pulse==2 and -1 or 1
  local weight=pulse==d.pulses and 1.4 or 1
  offset(pose,"left",v(21,-17,-13)*brace+v(12,11*answer,18*answer)*drive*weight)
  offset(pose,"torso",v(15,-9,5)*brace+v(-10,17*answer,-9*answer)*drive*weight)
  offset(pose,"neck",v(12*brace-15*drive))
  offset(pose,pulse==2 and "rightKnee" or "leftKnee",v(17*brace+22*drive*weight))
 elseif d.id=="knight.paladin.guardian_slash" then
  -- Cover the sword shoulder, step through the cut, then bring the guard back.
  local phase=age/contact
  local cover=smooth(phase/.47)*(1-smooth((phase-.67)/.33))
  local open=smooth((age-contact+.055)/.105)*(1-smooth((age-contact-.05)/.14))
  local recover=pulse>0 and smooth((since-.065)/.08)*(1-smooth((since-.145)/.18)) or 0
  offset(pose,"left",v(37,-13,-22)*cover+v(-18,19,24)*open+v(24,-11,-13)*recover)
  offset(pose,"leftElbow",v(24*cover+17*recover))
  offset(pose,"torso",v(9,-16,-8)*cover+v(9,14,7)*open)
  offset(pose,"leftHip",v(-16,0,-6)*open)
  offset(pose,"leftKnee",v(21*open+10*recover))
  offset(pose,"rightKnee",v(17*cover))
 elseif d.id=="knight.steel_knight.rallying_slash" then
  -- Coil behind the shield, then rise through the horizontal sword clip.
  local phase=age/contact
  local gather=smooth(phase/.58)*(1-smooth((phase-.58)/.42))
  local rise=pulse>0 and smooth(since/.065)*(1-smooth((since-.065)/.18)) or 0
  offset(pose,"torso",v(13,-12,10)*gather+v(-15,14,-8)*rise)
  offset(pose,"left",v(14,-8,-14)*gather+v(-12,14,21)*rise)
  offset(pose,"right",v(-14,0,-8)*gather+v(21,0,7)*rise)
  offset(pose,"rightKnee",v(18*gather))
  offset(pose,"leftKnee",v(13*rise))
 elseif d.id=="knight_crescent_cut" then
  local phase=age/contact
  local gather=smooth(phase/.5)*(1-smooth((phase-.5)/.5))
  local finish=pulse>0 and smooth(since/.075)*(1-smooth((since-.075)/.16)) or 0
  offset(pose,"torso",v(-5,17,6)*gather+v(9,-15,-8)*finish)
  offset(pose,"left",v(13,9,-12)*gather+v(-8,-6,13)*finish)
  offset(pose,"leftKnee",v(12*gather+16*finish))
 elseif d.id=="knight.paladin.dawn_burst" then
  -- Gather behind the shield, then drop the sword into a planted stance.
  local phase=age/contact
  local load=smooth(phase/.49)*(1-smooth((phase-.72)/.28))
  local plant=smooth((age-contact+.024)/.071)*(1-smooth((age-contact-.047)/.18))
  offset(pose,"left",v(32,-12,-21)*load+v(-18,12,18)*plant)
  offset(pose,"leftElbow",v(24*load-9*plant))
  offset(pose,"right",v(25,-10,8)*load+v(-16,6,-11)*plant)
  offset(pose,"torso",v(-9,-12,5)*load+v(24,9,-6)*plant)
  offset(pose,"leftKnee",v(17*load+35*plant))
  offset(pose,"rightKnee",v(21*load+18*plant))
 elseif d.id=="knight.paladin.dawn_spiral" then
  local phase=age/contact
  local coil=smooth(phase/.59)*(1-smooth((phase-.69)/.31))
  local drive=pulse>0 and smooth(since/.047)*(1-smooth((since-.047)/.16)) or 0
  local rise=math.max(0,pulse-1)*drive
  local bank=pulse==2 and -1 or 1
  offset(pose,"torso",v(16,-10,8)*coil+v(6-11*math.max(0,pulse-1),0,12*bank)*drive)
  offset(pose,"right",v(-12,0,14)*coil+v(22,0,-7)*rise)
  offset(pose,"left",v(27,-14,-12)*coil+v(-13,12,16)*rise)
  offset(pose,"leftKnee",v(16*coil+19*drive))
  offset(pose,"rightKnee",v(15*coil+(pulse==2 and 19 or 5)*drive))
 elseif d.id=="knight.paladin.oath_challenge" then
  -- Brace under the shield, then open the chest and plant as the challenge goes out.
  local phase=age/contact
  local gather=smooth(phase/.54)*(1-smooth((phase-.66)/.34))
  local plant=smooth((age-contact+.026)/.073)*(1-smooth((age-contact-.047)/.16))
  offset(pose,"left",v(33,-12,-22)*gather+v(-15,17,19)*plant)
  offset(pose,"leftElbow",v(26*gather-10*plant))
  offset(pose,"torso",v(16,-17,-8)*gather+v(-14,14,9)*plant)
  offset(pose,"neck",v(9*gather-15*plant))
  offset(pose,"rightKnee",v(23*gather))
  offset(pose,"leftKnee",v(25*plant))
 elseif d.id=="knight.paladin.radiant_sweep" then
  -- Coil low behind the shield and rise through the lead leg as the blade opens.
  local phase=age/contact
  local load=smooth(phase/.56)*(1-smooth((phase-.66)/.34))
  local release=smooth((age-contact+.018)/.079)*(1-smooth((age-contact-.061)/.16))
  offset(pose,"torso",v(12,-22,7)*load+v(-16,13,-5)*release)
  offset(pose,"right",v(-13,-7,10)*load+v(19,4,-12)*release)
  offset(pose,"elbow",v(-15*load+12*release))
  offset(pose,"left",v(26,-12,-15)*load+v(-15,12,19)*release)
  offset(pose,"rightHip",v(-14*load))
  offset(pose,"rightKnee",v(26*load))
  offset(pose,"leftKnee",v(23*release))
 elseif d.id=="knight.paladin.oathblade" then
  local settle=pulse>0 and smooth(since/.05)*(1-smooth((since-.05)/.15)) or 0
  if pulse==1 then
   offset(pose,"left",v(17,0,-12)*settle)
   offset(pose,"rightKnee",v(13)*settle)
  elseif pulse==2 then
   offset(pose,"left",v(-10,0,14)*settle)
   offset(pose,"leftKnee",v(19)*settle)
  end
 elseif d.id=="knight.paladin.sunward_cross" then
  -- Take the low first cut on the lead leg, then open the chest into the rising cut.
  local gather=smooth(age/(contact*.54))*(1-smooth((age/contact-.64)/.36))
  local stop=pulse>0 and smooth(since/.06)*(1-smooth((since-.06)/.13)) or 0
  local first=pulse==1 and stop or 0
  local second=pulse==2 and stop or 0
  local reset=pulse==1 and smooth((since-d.interval*.23)/(d.interval*.27))
   *(1-smooth((since-d.interval*.52)/(d.interval*.48))) or 0
  offset(pose,"torso",v(7,-13,8)*gather+v(16,-9,10)*first+v(-15,18,-15)*second+v(12,-17,8)*reset)
  offset(pose,"left",v(14,-10,-13)*gather+v(14,1,-8)*first+v(-14,10,17)*second)
  offset(pose,"right",v(-9,0,-8)*first+v(18,0,9)*second)
  offset(pose,"rightHip",v(-12,0,6)*reset)
  offset(pose,"leftKnee",v(17*gather+22*first))
  offset(pose,"rightKnee",v(19*reset+23*second))
 elseif d.id=="knight.paladin.oathbreaker_strike" then
  local load=smooth(age/(contact*.56))*(1-smooth((age/contact-.56)/.44))
  local plant=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.17))
  -- Lift the sword above the shield and drop the shoulder into the planted cut.
  offset(pose,"right",v(28,-12,11)*load+v(-19,7,-8)*plant)
  offset(pose,"left",v(23,-10,-14)*load+v(-12,7,14)*plant)
  offset(pose,"leftElbow",v(16*load-8*plant))
  offset(pose,"torso",v(-13,-12,7)*load+v(17,12,-8)*plant)
  offset(pose,"leftKnee",v(9*load+24*plant))
  offset(pose,"leftHip",v(-8*plant))
 elseif d.id=="knight.steel_knight.steel_sweep" then
  -- Wind behind the shield, then let the lead foot take the horizontal cut.
  local phase=age/contact
  local wind=smooth(phase/.52)*(1-smooth((phase-.64)/.36))
  local plant=pulse>0 and smooth(since/.052)*(1-smooth((since-.052)/.18)) or 0
  offset(pose,"torso",v(3,-22,7)*wind+v(9,15,-8)*plant)
  offset(pose,"left",v(24,-8,-17)*wind+v(-18,6,17)*plant)
  offset(pose,"rightKnee",v(17*wind))
  offset(pose,"leftHip",v(-14*plant,0,-6*plant))
  offset(pose,"leftKnee",v(26*plant))
 elseif d.id=="knight.steel_knight.sweeping_break" then
  -- Lower the sword-side shoulder into contact, then brake over the front leg.
  local coil=smooth(age/(contact*.57))*(1-smooth((age/contact-.57)/.43))
  local brake=smooth((age-contact+.05)/.11)*(1-smooth((age-contact-.06)/.18))
  local recover=smooth((age-contact-.045)/.078)*(1-smooth((age-contact-.123)/.18))
  offset(pose,"torso",v(10,-16,-9)*coil+v(14,9,8)*brake)
  offset(pose,"right",v(-9,-12,16)*coil+v(18,10,-17)*brake)
  offset(pose,"elbow",v(-26*brake+36*recover))
  offset(pose,"left",v(19,-9,-15)*coil+v(-10,12,13)*brake)
  offset(pose,"rightHip",v(-14,0,5)*coil)
  offset(pose,"leftHip",v(-15,0,-8)*brake)
  offset(pose,"leftKnee",v(27*brake))
  offset(pose,"rightKnee",v(19*coil))
 elseif d.id=="dwarf.iron_axe.mountain_sweep" then
  -- Load around the rear heel and counterbalance the low axe with the empty hand.
  local phase=age/contact
  local crouch=smooth(phase/.64)*(1-smooth((phase-.79)/.21))
  local brake=smooth((age-contact)/.075)*(1-smooth((age-contact-.075)/.16))
  local recover=smooth((age-contact-.065)/.076)*(1-smooth((age-contact-.141)/.145))
  offset(pose,"torso",v(18,-9,8)*crouch+v(15,8,-12)*brake)
  offset(pose,"right",v(13,-17,18)*crouch+v(11,-13,-27)*brake)
  offset(pose,"elbow",v(-17*brake+32*recover))
  offset(pose,"left",v(12,-12,27)*crouch+v(-8,16,16)*brake)
  offset(pose,"rightHip",v(-18,0,8)*crouch)
  offset(pose,"leftHip",v(-18,0,-10)*brake)
  offset(pose,"rightKnee",v(27*crouch+12*brake))
  offset(pose,"leftKnee",v(17*crouch+26*brake))
 elseif d.id=="dwarf_low_sweep" then
  -- Drop through the knees before the sweep and rise through the back leg.
  local crouch=smooth(age/(contact*.65))*(1-smooth((age-contact)/.18))
  local rise=smooth((age-contact)/.095)*(1-smooth((age-contact-.095)/.16))
  offset(pose,"torso",v(10,-5,12)*crouch+v(-8,11,-9)*rise)
  offset(pose,"rightHip",v(-18,0,7)*crouch)
  offset(pose,"leftHip",v(-24,0,-7)*crouch)
  offset(pose,"rightKnee",v(25*crouch+8*rise))
  offset(pose,"leftKnee",v(32*crouch))
  offset(pose,"left",v(6,-11,19)*crouch)
  local drag=smooth((age-contact)/.085)*(1-smooth((age-contact-.085)/.16))
  offset(pose,"right",v(12,13,-17)*drag)
  offset(pose,"elbow",v(-21*drag))
  offset(pose,"torso",v(0,-10,9)*drag)
  offset(pose,"rightKnee",v(12*drag))
 elseif d.id=="dwarf.iron_axe.breaker_throw" then
  -- Wind the axe shoulder high, then stop the throwing arm across the body.
  local phase=age/contact
  local gather=smooth(phase/.60)*(1-smooth((phase-.70)/.30))
  local follow=smooth((age-contact)/.064)*(1-smooth((age-contact-.064)/.17))
  offset(pose,"right",v(-20,-16,20)*gather+v(14,22,-24)*follow)
  offset(pose,"elbow",v(-22*gather-24*follow))
  offset(pose,"left",v(19,-14,24)*gather+v(-11,12,17)*follow)
  offset(pose,"torso",v(-10,-20,12)*gather+v(19,20,-10)*follow)
  offset(pose,"rightKnee",v(24*gather))
  offset(pose,"leftHip",v(-14,0,-6)*follow)
  offset(pose,"leftKnee",v(26*follow))
 elseif d.id=="dwarf_braced_throw" then
  local phase=age/contact
  local plant=smooth(phase/.46)*(1-smooth((phase-.55)/.45))
  local release=pulse>0 and smooth(since/.065)*(1-smooth((since-.065)/.18)) or 0
  offset(pose,"torso",v(-9,-14,-7)*plant+v(10,12,5)*release)
  offset(pose,"rightKnee",v(23*plant+9*release))
  -- Counterbalance the axe with the empty hand and take the throw on the lead leg.
  offset(pose,"rightHip",v(-15,0,8)*plant)
  offset(pose,"leftHip",v(-17,0,-8)*release)
  offset(pose,"leftKnee",v(14*plant+25*release))
  offset(pose,"left",v(26,-12,22)*plant+v(-21,15,-13)*release)
  offset(pose,"elbow",v(-16*release))
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
 elseif d.id=="dwarf.iron_axe.tremor_guard" then
  local phase=age/contact
  local load=smooth(phase/.50)*(1-smooth((phase-.65)/.35))
  local stomp=pulse>0 and smooth(since/.05)*(1-smooth((since-.05)/.17)) or 0
  local recover=pulse>0 and smooth((since-.052)/.095)*(1-smooth((since-.147)/.20)) or 0
  -- Keep the empty forearm braced while the axe settles and lifts away.
  offset(pose,"left",v(33,-17,14)*load+v(17,9,-19)*stomp+v(12,-7,4)*recover)
  offset(pose,"elbow",v(-24*recover))
  offset(pose,"torso",v(-9,-7,8)*load+v(20,0,-5)*stomp+v(-11,0,5)*recover)
  offset(pose,"leftHip",v(-11*stomp))
  offset(pose,"leftKnee",v(14*load+29*stomp+9*recover))
  offset(pose,"rightKnee",v(10*load+21*stomp))
 elseif d.id=="dwarf.iron_axe.shatter_blow" then
  -- Brace under the raised axe, then check its rebound through both planted legs.
  local phase=age/contact
  local load=smooth(phase/.58)*(1-smooth((phase-.70)/.30))
  local plant=pulse>0 and smooth(since/.067)*(1-smooth((since-.067)/.18)) or 0
  local lift=pulse>0 and smooth((since-.07)/.09)*(1-smooth((since-.16)/.18)) or 0
  offset(pose,"torso",v(-11,5,-4)*load+v(20,-4,4)*plant)
  offset(pose,"right",v(13,-5,9)*load)
  offset(pose,"left",v(19,-7,-16)*load+v(-18,0,-9)*plant)
  offset(pose,"elbow",v(-24*lift))
  offset(pose,"leftHip",v(-12*load-13*plant))
  offset(pose,"rightHip",v(-9*load-13*plant))
  offset(pose,"leftKnee",v(19*load+23*plant))
  offset(pose,"rightKnee",v(17*load+21*plant))
 elseif d.id=="dwarf.iron_axe.crag_cleave" then
  local phase=age/contact
  local wind=smooth(phase/.52)*(1-smooth((phase-.58)/.42))
  local catch=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.14))
  local pull=smooth((age-contact-.06)/.09)*(1-smooth((age-contact-.15)/.18))
  -- Sink through the diagonal cut, then recover by folding the axe elbow.
  offset(pose,"torso",v(-6,-19,11)*wind+v(22,18,-16)*catch+v(-9,-6,4)*pull)
  offset(pose,"left",v(20,-11,19)*wind+v(-11,12,-9)*catch)
  offset(pose,"rightHip",v(-13,0,6)*wind)
  offset(pose,"rightKnee",v(20*wind))
  offset(pose,"leftHip",v(-13*catch))
  offset(pose,"leftKnee",v(31*catch))
  offset(pose,"elbow",v(-25*pull))
 elseif d.id=="dwarf.iron_axe.armor_splitter" then
  -- Draw the free elbow in while the axe loads. Pull the axe back after the bite.
  local phase=age/contact
  local load=smooth(phase/.58)*(1-smooth((phase-.58)/.42))
  local weight=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.18))
  local pull=smooth((age-contact-.045)/.085)*(1-smooth((age-contact-.13)/.16))
  offset(pose,"torso",v(-8,-11,5)*load+v(12*weight,0,4*weight)+v(-8,6,-4)*pull)
  offset(pose,"left",v(24,-9,-14)*load)
  offset(pose,"elbow",v(-19*pull))
  offset(pose,"leftKnee",v(13*weight))
  offset(pose,"rightKnee",v(16*weight+14*load))
 end
 if d.id=="dwarf.iron_axe.twin_axe_path" then
  local phase=age/contact
  local load=smooth(phase/.55)*(1-smooth((phase-.55)/.45))
  local snap=pulse>0 and smooth(since/.045)*(1-smooth((since-.045)/.13)) or 0
  local transfer=pulse==1 and smooth((since-.07)/.065)*(1-smooth((since-.135)/.065)) or 0
  local side=pulse==2 and -1 or 1
  -- The right hand reloads across the body for a lower backhand release.
  offset(pose,"right",v(-12,11,-15)*load+v(-18,-24,21)*transfer+v(14*side,8,-17*side)*snap)
  offset(pose,"elbow",v(-29*transfer+19*snap))
  offset(pose,"torso",v(-6,-17,9)*load+v(8,17*side,12*side)*snap+v(8,-16,-9)*transfer)
  offset(pose,pulse==2 and "leftKnee" or "rightKnee",v(17*load+22*snap+12*transfer))
 elseif d.id=="dwarf.iron_axe.stonebound_leap" then
  local phase=math.clamp(age/math.max(.01,contact),0,1)
  local air=math.max(0,1-((phase-.61)/.39)^2)*1.5
  local landing=smooth((age-contact)/.055)*(1-smooth((age-contact-.055)/.18))
  local tuck=smooth((phase-.22)/.39)*(1-smooth((phase-.61)/.39))
  local recover=smooth((age-contact-.075)/.085)*(1-smooth((age-contact-.16)/.17))
  pose.root=CFrame.new(0,air-.33*landing,0)
  offset(pose,"rightHip",v(-21,0,5)*tuck)
  offset(pose,"leftHip",v(-15,0,-5)*tuck)
  offset(pose,"rightKnee",v(25*tuck+23*landing))
  offset(pose,"leftKnee",v(30*tuck+32*landing))
  offset(pose,"left",v(-12,0,-15)*tuck+v(13,-10,-22)*landing)
  offset(pose,"elbow",v(-22*recover))
  offset(pose,"torso",v(-10*tuck+19*landing-11*recover,0,6*landing))
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
