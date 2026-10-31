-- Authored, in-place melee motion. Time comes from the accepted server action;
-- no frame accumulator, root movement, asset download or local hit authority.
local Config = require(game:GetService("ReplicatedStorage").Shared.K0Config)
local Motion = {}

local function rotation(x, y, z)
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end

local channels = { "right", "left", "elbow", "wrist", "torso", "rightHip", "leftHip", "rightKnee", "leftKnee", "weapon" }
local function pose(right, elbow, wrist, torso, left, weapon, hips)
	return {
		right = rotation(unpack(right)), elbow = rotation(elbow), wrist = rotation(unpack(wrist)),
		torso = rotation(unpack(torso)), left = rotation(unpack(left)), weapon = rotation(unpack(weapon)),
		rightHip = rotation(hips and hips[1] or 0), leftHip = rotation(hips and hips[2] or 0),
		rightKnee = rotation(hips and hips[3] or 0), leftKnee = rotation(hips and hips[4] or 0),
	}
end

local rest = {
	knight = pose({0,0,0}, 0, {0,0,0}, {0,0,0}, {0,0,0}, {-25,0,0}),
	dwarf = pose({0,0,0}, 0, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}),
}
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
			hit = pose({65,5,-8}, 12, {3,0,-4}, {-4,0,-3}, {30,-20,8}, {-110,0,0}, {6,-7,2,6}),
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

local function mix(a, b, u)
	u = math.clamp(u, 0, 1)
	local result = {}
	for _, channel in ipairs(channels) do
		-- Torso leads the shoulder; elbow and wrist follow. All arrive at the
		-- same authored contact instant, with no rigid, simultaneous arm snap.
		local t = channel == "torso" and (1-(1-u)^1.35)
			or channel == "elbow" and u^1.12
			or (channel == "wrist" or channel == "weapon") and u^1.25 or u
		t = t * t * (3 - 2 * t)
		result[channel] = a[channel]:Lerp(b[channel], t)
	end
	return result
end

function Motion.sample(classId, combo, age)
	local profile = Config.BasicAttackProfiles[classId]
	if not strokes[classId] or type(age) ~= "number" or age ~= age then return nil end
	local index = math.clamp(math.floor(tonumber(combo) or 1), 1, #profile.attacks)
	local definition, stroke = profile.attacks[index], strokes[classId][index]
	local w, a, r = definition.windup, definition.active, definition.recovery
	local impact = w + (definition.hitDelay or 0)
	local loaded = w * 0.45
	local followAt = w + a + r * 0.15
	local total = w + a + r
	local result
	if age < loaded then result = mix(rest[classId], stroke.load, age / loaded)
	elseif age < impact then result = mix(stroke.load, stroke.hit, (age-loaded) / (impact-loaded))
	elseif age < followAt then result = mix(stroke.hit, stroke.follow, (age-impact) / (followAt-impact))
	else result = mix(stroke.follow, rest[classId], (age-followAt) / (total-followAt)) end
	result.cutting = age >= loaded and age <= w + a and age < total
	return result
end

function Motion.forCharacter(character, now)
	if character:GetAttribute("K0State") ~= "Attack" or character:GetAttribute("K0SkillId") ~= nil
		or character:GetAttribute("TLTDeathFalling") then return nil end
	local started = character:GetAttribute("K0AttackStartedAt")
	if type(started) ~= "number" then return nil end
	return Motion.sample(character:GetAttribute("K0ClassId"), character:GetAttribute("K0Combo"), now-started)
end

return Motion
