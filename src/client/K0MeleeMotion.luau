-- Authored, in-place melee motion. Time comes from the accepted server action;
-- no frame accumulator, root movement, asset download or local hit authority.
local Config = require(game:GetService("ReplicatedStorage").Shared.K0Config)
local Motion = {}
local actions = setmetatable({}, { __mode = "k" })

local function rotation(x, y, z)
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end

local channels = { "right", "left", "elbow", "leftElbow", "wrist", "neck", "torso", "rightHip", "leftHip", "rightKnee", "leftKnee", "weapon" }
local function angles(x,y,z) return Vector3.new(x or 0,y or 0,z or 0) end
local function pose(right, elbow, wrist, torso, left, weapon, hips)
	return {
		right = angles(unpack(right)), elbow = angles(elbow), wrist = angles(unpack(wrist)),
		leftElbow = angles(24), neck = angles(-torso[1]*.25,-torso[2]*.5,-torso[3]*.35),
		torso = angles(unpack(torso)), left = angles(unpack(left)), weapon = angles(unpack(weapon)),
		rightHip = angles(hips and hips[1] or 0), leftHip = angles(hips and hips[2] or 0),
		rightKnee = angles(hips and hips[3] or 0), leftKnee = angles(hips and hips[4] or 0),
	}
end

local rest = {
	knight = pose({0,0,0}, 0, {0,0,0}, {0,0,0}, {0,0,0}, {-25,0,0}),
	dwarf = pose({0,0,0}, 0, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}),
}
-- Combat-ready finish keeps the shield and free hand engaged between cuts.
local guard = {
	knight = pose({28,5,-7}, 18, {-3,0,0}, {0,0,0}, {30,-35,8}, {-90,0,0}, {0,0,0,0}),
	dwarf = pose({32,0,-10}, 20, {-3,0,0}, {2,0,-2}, {20,8,14}, {-85,0,0}, {0,0,0,0}),
}
for _,p in pairs(rest) do p.leftElbow=Vector3.zero; p.neck=Vector3.zero end
-- Poses are in torso axes, converted into each rig's actual shoulder basis by
-- the renderer. Elbow flexion stays on its hinge; the wrist never spins the axe.
local strokes = {
	knight = {
		{ -- Descending forehand; shield stays near the chest, clear of the blade.
			load = pose({75,-15,-10}, 30, {-5,0,-5}, {4,-18,-3}, {24,-20,8}, {-110,0,0}, {5,-7,3,5}),
			hit = pose({60,10,-5}, 12, {3,0,4}, {-6,5,3}, {30,-22,10}, {-112,0,0}, {-7,7,6,2}),
			follow = pose({45,45,10}, 18, {5,0,6}, {-8,16,4}, {26,-16,8}, {-102,0,0}, {-8,8,7,2}),
		},
		{ -- Return cut: load on the left and unwind toward the sword side.
			load = pose({55,55,15}, 30, {-5,0,5}, {4,20,3}, {28,-20,12}, {-105,0,0}, {-6,6,4,2}),
			hit = pose({55,5,-8}, 12, {3,0,-4}, {-4,0,-3}, {30,-20,8}, {-110,0,0}, {6,-7,2,6}),
			follow = pose({75,-40,-20}, 22, {5,0,-6}, {-4,-20,-4}, {24,-15,8}, {-100,0,0}, {8,-8,2,6}),
		},
		{ -- Committed diagonal finisher, rather than repeating the first sweep.
			load = pose({120,-8,-12}, 35, {-5,0,-4}, {6,-12,-3}, {32,-22,10}, {-100,0,0}, {6,-9,4,7}),
			hit = pose({60,15,0}, 10, {4,0,3}, {-10,6,2}, {36,-24,10}, {-118,0,0}, {-10,10,9,3}),
			follow = pose({40,28,10}, 18, {6,0,5}, {-10,16,3}, {28,-18,8}, {-108,0,0}, {-12,10,10,3}),
		},
	},
	dwarf = {{
		load = pose({114,8,-24}, 40, {-5,0,-4}, {10,9,-5}, {42,10,20}, {-91,0,0}, {7,-9,7,9}),
		hit = pose({82,22,-14}, 12, {4,0,3}, {-7,5,4}, {30,-10,18}, {-145,0,0}, {-9,9,10,4}),
		follow = pose({65,40,-8}, 18, {6,0,5}, {-10,16,5}, {22,-6,15}, {-130,0,0}, {-10,10,11,4}),
	}},
}

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

local function definitionFor(classId,combo)
 local profile=Config.BasicAttackProfiles[classId]
 if not strokes[classId] or not profile then return nil end
 local index=math.clamp(math.floor(tonumber(combo) or 1),1,#profile.attacks)
 return profile.attacks[index],strokes[classId][index]
end

function Motion.sample(classId, combo, age, entry, entrySlope)
 local definition,stroke=definitionFor(classId,combo)
 if not definition or type(age)~="number" or age~=age then return nil end
 local w,a,r=definition.windup,definition.active,definition.recovery
 local impact=w+(definition.hitDelay or 0)
 local followAt=w+a+r*.15
 local total=w+a+r
 local values={entry or rest[classId],stroke.load,stroke.hit,stroke.follow,guard[classId]}
 local times={0,w*.45,impact,followAt,total}
 local result=frame(values,times,age,entrySlope)
 result.cutting=age>=w*.45 and age<=w+a and age<total
 return result
end

-- Continue from the last accepted action's evaluated pose, including a new
-- attack accepted during recovery. A late observer needs no frame history to
-- reproduce an isolated strike, and playback never accumulates frame delta.
local function presentation(record, now)
 local d=definitionFor(record.classId,record.combo)
 local total=d.windup+d.active+d.recovery
 local age=now-record.started
 if age<=total then return Motion.sample(record.classId,record.combo,age,record.entry,record.entrySlope) end
 local result=frame({guard[record.classId],guard[record.classId],rest[record.classId]}, {0,.10,.42}, age-total)
 result.cutting=false
 return result
end

function Motion.forCharacter(character, now)
 local classId=character:GetAttribute("K0ClassId")
 local mode=character:GetAttribute("K0State")
 if not strokes[classId] or (mode~="Attack" and mode~="Idle")
  or character:GetAttribute("K0SkillId")~=nil or character:GetAttribute("TLTDeathFalling") then
  actions[character]=nil;return nil
 end
 local previous=actions[character]
 if mode=="Idle" then
  if not previous or previous.classId~=classId then return nil end
  local d=definitionFor(classId,previous.combo)
  if now-previous.started>d.windup+d.active+d.recovery+.42 then actions[character]=nil;return nil end
  return presentation(previous,now)
 end
 local started=character:GetAttribute("K0AttackStartedAt")
 local combo=character:GetAttribute("K0Combo")
 if type(started)~="number" then actions[character]=nil;return nil end
 if not previous or previous.started~=started or previous.classId~=classId or previous.combo~=combo then
  local entry,entrySlope=rest[classId],nil
  if previous and previous.classId==classId and started>=previous.started then
   entry=presentation(previous,started).angles
   local before,after=presentation(previous,started-.0001),presentation(previous,started+.0001)
   entrySlope={}
   for _,channel in ipairs(channels) do entrySlope[channel]=(after.angles[channel]-before.angles[channel])/.0002 end
  end
  previous={classId=classId,combo=combo,started=started,entry=entry,entrySlope=entrySlope}
  actions[character]=previous
 end
 return Motion.sample(classId,combo,now-started,previous.entry,previous.entrySlope)
end

return Motion
