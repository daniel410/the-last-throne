-- Authored, in-place melee motion. Time comes from the accepted server action;
-- no frame accumulator, root movement, asset download or local hit authority.
local Config = require(game:GetService("ReplicatedStorage").Shared.K0Config)
local Motion = {}
local actions = setmetatable({}, { __mode = "k" })

local function rotation(x, y, z)
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end

local Clips = require(script.Parent.K0MeleeClips)
local DwarfMixamo = require(script.Parent.K0DwarfMixamoClips)
local KnightMixamo = require(script.Parent.K0KnightMixamoBasic)
local KnightVariants = require(script.Parent.K0KnightMixamoVariants)
local channels = Clips.channels
local rest, guard = {}, {}
local function angles(x,y,z) return Vector3.new(x or 0,y or 0,z or 0) end
for classId, source in pairs(Clips.rest) do
 rest[classId], guard[classId] = {}, {}
 for _, channel in ipairs(channels) do
  rest[classId][channel] = angles(unpack(source[channel]))
  guard[classId][channel] = angles(unpack(Clips.guard[classId][channel]))
 end
end

-- Monotone cubic Hermite in authored angle space. Unlike per-segment ease-in/
-- ease-out, the blade retains velocity through contact. Slopes are shared by
-- adjacent segments; changing direction at a loaded pose remains intentional.
local function tangent(values, times, i, channel, axis)
 if i == 1 or i == #values then return 0 end
 local left, right = times[i]-times[i-1], times[i+1]-times[i]
 local a = (values[i][channel][axis]-values[i-1][channel][axis])/left
 local b = (values[i+1][channel][axis]-values[i][channel][axis])/right
 if a*b <= 0 then return 0 end
 local w1,w2=2*right+left,right+2*left
 return (w1+w2)/(w1/a+w2/b)
end
local function frame(values, times, age, entrySlope)
 local segment = 1
 for i=1,#times-1 do if age >= times[i] then segment=i end end
 local span=times[segment+1]-times[segment]
 local u=math.clamp((age-times[segment])/span,0,1)
 local u2,u3=u*u,u*u*u
 local result={angles={}}
 for _,channel in ipairs(channels) do
  local components={}
  for _,axis in ipairs({"X","Y","Z"}) do
   local a,b=values[segment][channel][axis],values[segment+1][channel][axis]
   local m0=segment==1 and entrySlope and entrySlope[channel][axis] or tangent(values,times,segment,channel,axis)
   local m1=tangent(values,times,segment+1,channel,axis)
   table.insert(components,(2*u3-3*u2+1)*a+(u3-2*u2+u)*span*m0+(-2*u3+3*u2)*b+(u3-u2)*span*m1)
  end
  result.angles[channel]=angles(unpack(components))
  result[channel]=rotation(unpack(components))
 end
 return result
end

local function definitionFor(classId,combo,skillId)
 if skillId then
  if classId=="knight" and skillId=="knight.common.whirlwind" then
   return Config.Skills.knight[2],KnightVariants["knight.mixamo.wide"]
  end
  if classId=="knight" and KnightVariants[skillId] then
   local variant=KnightVariants[skillId]
   return Config.BasicAttackProfiles.knight.attacks[variant.combo],variant
  end
  if classId=="dwarf" and DwarfMixamo.variants[skillId] then
   local variant=DwarfMixamo.variants[skillId]
   return Config.Skills.dwarf[variant.baseSkillIndex or 1],variant
  end
  local clip=classId=="dwarf" and DwarfMixamo.skills[skillId] or Clips.skills and Clips.skills[skillId]
  if not clip or clip.classId~=classId then return nil end
  for _,skill in ipairs(Config.Skills[classId] or {}) do
   if skill.id==skillId then return skill,clip end
  end
  return nil
 end
 local profile=Config.BasicAttackProfiles[classId]
 if not Clips.clips[classId] or not profile then return nil end
 local index=math.clamp(math.floor(tonumber(combo) or 1),1,#profile.attacks)
 return profile.attacks[index],classId=="dwarf" and index==1 and DwarfMixamo.basic
  or classId=="knight" and KnightMixamo[index] or Clips.clips[classId][index]
end

-- The exported Bezier handles have one-third interval lengths, so each
-- Blender segment is exactly a cubic Hermite segment in seconds/degrees.
local function sampleAxis(keys, age)
 local segment=1
 for i=1,#keys-1 do if age>=keys[i][1] then segment=i end end
 local a,b=keys[segment],keys[segment+1]
 local span=b[1]-a[1]
 local u=math.clamp((age-a[1])/span,0,1)
 local u2,u3=u*u,u*u*u
 return (2*u3-3*u2+1)*a[2]+(u3-2*u2+u)*span*a[3]
  +(-2*u3+3*u2)*b[2]+(u3-u2)*span*b[3]
end
function Motion.sample(classId, combo, age, entry, entrySlope, skillId, rigType, entryTurn, entryAcceleration)
 local definition,clip=definitionFor(classId,combo,skillId)
 if not definition or type(age)~="number" or age~=age then return nil end
 local w,a,r=definition.windup,definition.active,definition.recovery
 local total,impact=w+a+r,w+(definition.hitDelay or 0)
 -- Retiming anchors preserve contact if combat timing is adjusted later.
 local opening=w*(clip.entryFraction or .45)
 local current={0,opening,impact,w+a+r*.15,total}
 local authored={0,clip.entryUntil,clip.windup+clip.hitDelay,clip.windup+clip.active+clip.recovery*.15,clip.duration}
 local section=1
 for i=1,4 do if age>=current[i] then section=i end end
 local ratio=math.clamp((age-current[section])/(current[section+1]-current[section]),0,1)
 local time=authored[section]+(authored[section+1]-authored[section])*ratio
 local result={angles={}}
 local u=math.clamp(age/opening,0,1);local u2,u3=u*u,u*u*u
 local curves=rigType==Enum.HumanoidRigType.R6 and (clip.r6Curves or clip.curves) or clip.curves
 for _,channel in ipairs(channels) do
  local v={}
  for axis,name in ipairs({"X","Y","Z"}) do
   local value=sampleAxis(curves[channel][axis],time)
   if entry and age<opening then
    value+=(2*u3-3*u2+1)*(entry[channel][name]-rest[classId][channel][name])
     +(u3-2*u2+u)*opening*(entrySlope and entrySlope[channel][name] or 0)
    if entryAcceleration then
     local keys=curves[channel][axis]
     local first,nextKey=keys[1],keys[2]
     local span=nextKey[1]-first[1]
     local baseAcceleration=6*(nextKey[2]-first[2])/(span*span)-(4*first[3]+2*nextKey[3])/span
     local delta=entry[channel][name]-rest[classId][channel][name]
     local slope=entrySlope and entrySlope[channel][name] or 0
     local acceleration=baseAcceleration-6*delta/(opening*opening)-4*slope/opening
     -- Match outgoing acceleration as well as pose/velocity. The correction
     -- and its first two derivatives vanish at the end of anticipation.
     value+=.5*age*age*(1-u)^3*(entryAcceleration[channel][name]-acceleration)
    end
   end
   v[axis]=value
  end
  result.angles[channel]=angles(unpack(v));result[channel]=rotation(unpack(v))
 end
 result.cutting=not definition.ranged and age>=w*.45 and age<=w+a and age<total
 -- The forward-facing held axe turns into the previously authored strike
 -- orientation during anticipation, before the cutting interval begins.
 if classId=="dwarf" then
  -- Keep the grip orientation when chaining attacks. Resetting this separate
  -- yaw layer used to snap the axe by 110 degrees even though the arm joined.
  local from=entryTurn or 0
  result.axeStrikeTurn=from+(1-from)*u2*(3-2*u)
  if clip.returnToIdle then
   -- Unwind the socket with the arm during authored recovery, never later
   -- while the hand is already in its idle position.
   local settle=math.clamp((age-current[4])/(total-current[4]),0,1)
   result.axeStrikeTurn*=1-settle*settle*(3-2*settle)
  end
 end
 if classId=="dwarf" and not skillId and not clip.disableR6FollowAcross then
  -- R6 has no elbow/wrist segments, so its shorter rigid arm needs a
  -- little more cross-body follow-through after the contact interval.
  local across=math.clamp((age-impact-.005)/.065,0,1)
  local release=math.clamp((age-.29)/(total-.29),0,1)
  result.r6FollowAcross=across*across*(3-2*across)*(1-release*release*(3-2*release))
 end
 if clip.rootLift and rigType~=Enum.HumanoidRigType.R6 then
  result.root=CFrame.new(0,sampleAxis(clip.rootLift,time),0)
 end
 if classId=="knight" and skillId=="knight.common.whirlwind" then
  local turn=math.clamp((age-w)/a,0,1)
  result.root=CFrame.Angles(0,-2*math.pi*turn,0)
 end
 return result
end

-- Continue from the last accepted action's evaluated pose, including a new
-- attack accepted during recovery. A late observer needs no frame history to
-- reproduce an isolated strike, and playback never accumulates frame delta.
local function presentation(record, now)
 local d=definitionFor(record.classId,record.combo,record.skillId)
 local total=d.windup+d.active+d.recovery
 local age=(now-record.started)*(record.rate or 1)
 if age<=total then return Motion.sample(record.classId,record.combo,age,record.entry,record.entrySlope,record.skillId,record.rigType,record.entryTurn,record.entryAcceleration) end
 local result=record.classId=="dwarf"
  and frame({rest.dwarf,rest.dwarf},{0,.42},age-total)
  or frame({guard[record.classId],guard[record.classId],rest[record.classId]}, {0,.10,.42}, age-total)
 result.cutting=false
 if record.classId=="dwarf" then
  result.axeStrikeTurn=0
 end
 return result
end

function Motion.forCharacter(character, now)
 local classId=character:GetAttribute("K0ClassId")
 local mode=character:GetAttribute("K0State")
 local skillId=character:GetAttribute("K0SkillId")
 if not Clips.clips[classId] or (mode~="Attack" and mode~="Idle")
  or (skillId and not definitionFor(classId,1,skillId)) or character:GetAttribute("TLTDeathFalling") then
  actions[character]=nil;return nil
 end
 local previous=actions[character]
 if mode=="Idle" then
  if not previous or previous.classId~=classId then return nil end
  local d=definitionFor(classId,previous.combo,previous.skillId)
  if (now-previous.started)*(previous.rate or 1)>d.windup+d.active+d.recovery+.42 then actions[character]=nil;return nil end
  return presentation(previous,now)
 end
 local started=character:GetAttribute("K0AttackStartedAt")
 local combo=character:GetAttribute("K0Combo")
 if type(started)~="number" then actions[character]=nil;return nil end
 if not previous or previous.started~=started or previous.classId~=classId or previous.combo~=combo or previous.skillId~=skillId then
  local rate=not skillId and (character:GetAttribute("K0BasicAttackRate") or 1) or 1
  local entry,entrySlope,entryTurn,entryAcceleration=rest[classId],nil,0,nil
  if previous and previous.classId==classId and started>=previous.started then
   local previousPose=presentation(previous,started)
   entry,entryTurn=previousPose.angles,previousPose.axeStrikeTurn or 0
   local before,after=presentation(previous,started-.0001),presentation(previous,started+.0001)
   entrySlope,entryAcceleration={},classId=="dwarf" and {} or nil
   for _,channel in ipairs(channels) do
    entrySlope[channel]=(after.angles[channel]-before.angles[channel])/(.0002*rate)
    if entryAcceleration then entryAcceleration[channel]=(after.angles[channel]-2*entry[channel]+before.angles[channel])/(.0001*rate)^2 end
   end
  end
  local humanoid=character:FindFirstChildOfClass("Humanoid")
  previous={classId=classId,combo=combo,skillId=skillId,started=started,entry=entry,entrySlope=entrySlope,entryAcceleration=entryAcceleration,entryTurn=entryTurn,rigType=humanoid and humanoid.RigType,rate=rate}
  actions[character]=previous
 end
 return presentation(previous,now)
end

return Motion
