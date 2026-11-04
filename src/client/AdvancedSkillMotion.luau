-- In-place procedural skill choreography. Absolute accepted server time is
-- sampled once for body and weapon; no root movement or local hit authority.
local Config = require(game.ReplicatedStorage.Shared.K0Config)
local Presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
local Clips = require(script.Parent.K0MeleeClips)
local Motion = {}
local records=setmetatable({},{__mode="k"})
local definitions = {}
for _, classId in ipairs({"knight", "dwarf"}) do
 for _, d in ipairs(Config.Skills[classId]) do if d.advanced then definitions[d.id] = d end end
end
local function smooth(x) x=math.clamp(x,0,1);return x*x*(3-2*x) end
local function v(x,y,z) return Vector3.new(x or 0,y or 0,z or 0) end
local function rot(a) return CFrame.Angles(math.rad(a.X),math.rad(a.Y),math.rad(a.Z)) end
local poses = {
 slash={v(75,55,-18),v(50,-65,-10),v(8,22,0),v(-6,-26,0)},
 sweep={v(60,80,-30),v(55,-85,12),v(4,32,0),v(-8,-38,0)},
 cross={v(85,55,-25),v(35,-65,25),v(10,24,0),v(-8,-28,0)},
 counter={v(72,28,-15),v(65,-60,-10),v(6,20,0),v(-6,-25,0)},
 thrust={v(45,35,-10),v(100,-8,-8),v(5,22,0),v(-12,-12,0)},
 shield={v(42,15,-16),v(62,-20,-12),v(8,22,0),v(-12,-18,0)},
 chop={v(145,30,-18),v(25,-30,10),v(-12,20,0),v(18,-24,0)},
 slam={v(150,8,-10),v(20,-8,-8),v(-16,8,0),v(22,-8,0)},
 throw={v(140,45,-12),v(75,-20,-15),v(-6,28,0),v(10,-28,0)},
 shoot={v(82,8,-12),v(73,8,-12),v(4,8,0),v(-5,8,0)},
 lob={v(145,25,-15),v(70,-15,-12),v(-8,22,0),v(10,-20,0)},
 mortar={v(95,5,-15),v(80,5,-15),v(6,8,0),v(-9,8,0)},
 spin={v(65,65,-25),v(65,-65,-25),v(5,30,0),v(-5,-30,0)},
}
function Motion.sample(classId,d,age)
 local p = Presentation.get(d);local key = poses[p.motion];if not key then return nil end
 local rest = Clips.rest[classId]
 local contact = d.windup+(d.hitDelay or 0)
 local total = d.windup+d.active+d.recovery
 local pulse, since = Presentation.beat(d,age)
 local anticipate = smooth(age/math.max(.01,contact*.7))
 local strike = smooth((age-contact+.065)/.065)
 if pulse>0 and (d.pulses or 1)>1 then
  local interval=d.interval or .3
  if pulse<(d.pulses or 1) then
   -- Follow through, reload, then accelerate into the next contact. Both
   -- sides of a pulse boundary have strike=1, avoiding a one-frame snap.
   if since<.04 then strike=1
   elseif since<interval-.06 then strike=1-smooth((since-.04)/math.max(.01,interval-.10))
   else strike=smooth((since-interval+.06)/.06) end
  else strike=1 end
 end
 local fade = 1-smooth((age-d.windup-d.active)/d.recovery)
 local weight = anticipate*fade
 local r = key[1]:Lerp(key[2],strike)
 local torso = key[3]:Lerp(key[4],strike)
 local left = v(35,0,18)
 if p.motion=="shield" or p.motion=="counter" then left=v(105,-65,5):Lerp(v(115,-30,0),strike)
 elseif p.motion=="shoot" or p.motion=="mortar" then left=v(88,-25,15)
 elseif p.motion=="slam" then left=v(105,-15,20):Lerp(v(55,0,12),strike) end
 if p.motion=="cross" and pulse%2==0 and pulse>0 then r=v(r.X,-r.Y,-r.Z) end
 if p.motion=="spin" then
  local turns=math.clamp((age-contact+.065)/math.max(.1,d.active),0,1)
  -- Full visual turns are reduced modulo 360; the physics root stays fixed.
  torso=v(0,age>=d.windup+d.active and 0 or -360*turns,0)
 end
 local angles={right=r,left=left,torso=torso,elbow=v(-22),wrist=v(0,0,-8),
  leftElbow=v(-30),leftWrist=v(),neck=v(-torso.X*.25,p.motion=="spin" and 0 or -torso.Y*.15,0),
  rightHip=v(-10,0,-3),leftHip=v(12,0,3),rightKnee=v(14),leftKnee=v(8),
  weapon=p.motion=="throw" and v(-115,0,0) or classId=="knight" and v(-120) or v(-145,0,0)}
 local result={angles={},axeStrikeTurn=classId=="dwarf" and weight or nil,cutting=p.effect=="slash" and age>=contact-.06 and age<d.windup+d.active}
 for channel, base in pairs(rest) do
  local resting=v(unpack(base));local target=angles[channel] or resting
  local value=resting:Lerp(target,weight)
  result.angles[channel]=value;result[channel]=rot(value)
 end
 return result
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
  local entry=record and record.classId==classId and started>=record.started
   and Motion.sample(classId,record.d,started-record.started) or nil
  record={started=started,d=d,classId=classId,entry=entry};records[character]=record
 end
 local age=math.max(0,now-started)
 local pose=Motion.sample(classId,d,age)
 local blend=smooth(age/math.max(.01,d.windup*.35))
 if record.entry and blend<1 then
  for channel,angle in pairs(pose.angles) do
   local value=record.entry.angles[channel]:Lerp(angle,blend)
   pose.angles[channel]=value;pose[channel]=rot(value)
  end
 end
 return pose
end
return Motion
