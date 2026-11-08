-- Prototype-only values from docs/knight-combat-spec.md. No progression is saved.
-- Preserve the reviewed three-hit rhythm and sustained damage at a 0.70s mean.
local knightBasicTempo = 0.70 / 0.50
local Config = {
	MaxHealth = 1000,
	AttackPower = 100,
	MaxMana = 100,
	ManaRegenFraction = 0.0015,
	MageManaRegenMultiplier = 2,
	ElfManaRegenMultiplier = 2,
	ManaRegenDelay = 1,
	SprintSpeed = 24,
	WalkSpeed = 16,
	GuardSpeed = 8,
	AttackSpeed = 6.4,
	InputBuffer = 0.12,
	ComboReset = 0.6,
	AttackMaxTargets = 3,
	AttackHeight = 7,
	Attacks = {
		{ windup = 0.16 * knightBasicTempo, active = 0.10 * knightBasicTempo, recovery = 0.16 * knightBasicTempo, damage = 0.75 * knightBasicTempo, posture = 12, range = 5.5, angle = 100 },
		{ windup = 0.18 * knightBasicTempo, active = 0.10 * knightBasicTempo, recovery = 0.18 * knightBasicTempo, damage = 0.90 * knightBasicTempo, posture = 14, range = 5.5, angle = 110 },
		{ windup = 0.26 * knightBasicTempo, active = 0.12 * knightBasicTempo, recovery = 0.24 * knightBasicTempo, damage = 1.20 * knightBasicTempo, posture = 24, range = 6.0, angle = 100 },
	},
	Guard = { raiseTime = 0.10, perfectTime = 0.15, cooldown = 0.40, angle = 120, damageMultiplier = 0.2, counterDuration = 1.5 },
	Dodge = { duration = 0.65, moveDuration = 0.30, distance = 7, invulnerableStart = 0.08, invulnerableEnd = 0.28, doubleTapWindow = 0.30,
		sideRoll = { distance = 14, moveDuration = 0.55, jumpHeight = 2.5 } },
	HitStun = 0.25,
	SlimeSplit = { count = 2, sizeMultiplier = 0.5, healthMultiplier = 0.25 },
	Enemy = {
		-- First training opponent. Values are a prototype, not story rewards.
		Slime = {
			health = 220, posture = 40, walkSpeed = 7, aggroRange = 18, leashRange = 28,
			exposeTime = 1.20, respawnTime = 5,
			attacks = {{ name = "Melee", windup = 0.80, active = 0.10, recovery = 0.90, range = 3.5, angle = 100, damage = 40, blockable = true }},
		},
		Goblin = {
			health = 300, posture = 60, walkSpeed = 10, aggroRange = 25, leashRange = 36,
			exposeTime = 1.20, respawnTime = 5,
			attacks = {{ name = "Melee", windup = 0.60, active = 0.10, recovery = 0.80, range = 4, angle = 90, damage = 80, blockable = true }},
		},
		-- Initial K0 test values, pending Orc Warrior playtesting; armor and
		-- flank-specific damage are future behavior, not part of this preset.
		Orc = {
			health = 900, posture = 100, walkSpeed = 8.5, aggroRange = 25, leashRange = 36,
			exposeTime = 1.20, respawnTime = 5,
			attacks = {{ name = "Melee", windup = 0.85, active = 0.12, recovery = 1.05, range = 5, angle = 90, damage = 125, blockable = true }},
		},
		Ogre = {
			health = 6000, posture = 220, walkSpeed = 7, aggroRange = 25, leashRange = 36,
			exposeTime = 1.50, respawnTime = 5,
			attacks = {
				{ name = "Melee", windup = 1.20, active = 0.15, recovery = 1.40, range = 7, angle = 80, damage = 220, blockable = true },
				{ name = "Unblockable", windup = 1.50, active = 0.15, recovery = 1.60, range = 8, angle = 360, damage = 180, blockable = false },
			},
		},
		HitStun = 0.25,
		HitInterruptImmunity = 1.25,
		PostureDelay = 4,
		PostureRegenFraction = 0.10,
		PostureImmunity = 3,
		OgreReconsider = 0.5,
		GoblinStartSpacing = 0.5,
		MovementInterval = 0.25,
		PathInterval = 1.2,
	},
	-- Generous error budget pending measurements under real network conditions.
	MovementBudget = 8,
	RemoteBurst = 10,
	RemoteRefillPerSecond = 8,
}

-- Prototype-only basic attacks; these are not finalized class balance,
-- equipment or skills. Dwarf swings a hand axe; Mage swings a wooden staff.
-- Keep Knight tied to the existing K0 values. Elf uses one server-resolved
-- ranged shot with a narrow forward aim assist, not a client damage claim.
-- Dwarf keeps its reviewed stroke but uses a heavier 0.80s basic cadence.
-- Scale all phases together to preserve motion/contact joins. Scale damage
-- equally to preserve sustained basic DPS before integer damage rounding.
local dwarfBasicTempo = 0.80 / 0.42
Config.BasicAttackProfiles = {
	knight = {
		id = "knight.sword.basic", attackPower = Config.AttackPower,
		maxTargets = Config.AttackMaxTargets, maxHeight = Config.AttackHeight, attacks = Config.Attacks,
	},
	elf = {
		id = "elf.bow.basic", attackPower = 100, maxTargets = 1, maxHeight = 10,
		attacks = {{ windup = 0.44, active = 0.16, recovery = 0.60, damage = 0.70, posture = 8, range = 55, angle = 45 }},
	},
	dwarf = {
		id = "dwarf.axe.basic", attackPower = 100, maxTargets = 3, maxHeight = 7,
		attacks = {{ windup = 0.16 * dwarfBasicTempo, active = 0.10 * dwarfBasicTempo, hitDelay = 0.06 * dwarfBasicTempo, recovery = 0.16 * dwarfBasicTempo, damage = 0.75 * dwarfBasicTempo, posture = 12, range = 5.5, angle = 100 }},
	},
	mage = {
		id = "mage.staff.basic", attackPower = 100, maxTargets = 3, maxHeight = 7,
		attacks = {{ windup = 0.32, active = 0.20, recovery = 0.32, damage = 0.75, posture = 12, range = 4.5, angle = 100 }},
	},
}

-- Shared basic skill definitions. Growth and branch eligibility are server owned.
-- Physical skills use only their own cooldown; magic also costs mana.
Config.Skills = {
	knight = {
		{ id = "knight.common.bash", name = "SHIELD BASH", requiresShield = true, cooldown = 10, windup = 0.20, active = 0.10, recovery = 0.40, damage = 0.8, posture = 55, range = 5, angle = 80, maxHeight = 7, maxTargets = 3, effect = "bash", stunDuration = 5, description = "Strike with your shield and stun enemies hit for 5 seconds." },
		{ id = "knight.common.whirlwind", name = "WHIRLWIND", cooldown = 8, windup = 0.25, active = 0.18, recovery = 0.4, damage = 1.0, posture = 18, range = 7, angle = 360, maxHeight = 7, maxTargets = 8, effect = "whirlwind" },
		{ id = "knight.common.provoke", name = "PROVOKE", cooldown = 12, windup = 0.25, active = 0.1, recovery = 0.3, damage = 0, posture = 0, range = 12, angle = 360, maxHeight = 10, maxTargets = 8, effect = "provoke", provokeDuration = 4, attackDownDuration = 4, attackDownMultiplier = 0.85, defenseBreakDuration = 4, description = "Taunt enemies. They deal 15% less damage and take 10% more damage for 4 seconds.", defenseBreakDamageMultiplier = 1.10 },
	},
	elf = {
		{ id = "elf.common.aimed", name = "AIMED SHOT", cooldown = 6, windup = 0.45, active = 0.10, recovery = 0.30, damage = 1.4, posture = 16, range = 55, angle = 35, maxHeight = 10, maxTargets = 1, effect = "aimed", ranged = true },
		{ id = "elf.common.rapid", name = "RAPID FIRE", cooldown = 8, windup = 0.24, active = 0.48, recovery = 0.30, damage = 0.55, posture = 5, range = 55, angle = 45, maxHeight = 10, maxTargets = 1, effect = "rapid", ranged = true, shotCount = 3, shotInterval = 0.18 },
		{ id = "elf.common.multi", name = "MULTI SHOT", cooldown = 10, windup = 0.30, active = 0.10, recovery = 0.35, damage = 0.75, posture = 8, range = 50, angle = 70, maxHeight = 10, maxTargets = 5, effect = "multi", ranged = true },
	},
	dwarf = {
		{ id = "dwarf.common.overhead", name = "OVERHEAD SMASH", cooldown = 6, windup = 0.65, active = 0.18, hitDelay = 0.06, recovery = 0.30, damage = 1.4, posture = 25, range = 6, angle = 80, maxHeight = 7, maxTargets = 1, effect = "overhead" },
		{ id = "dwarf.common.throw", name = "AXE THROW", cooldown = 7, windup = 0.30, active = 0.10, recovery = 0.30, damage = 1.1, posture = 18, range = 32, angle = 45, maxHeight = 10, maxTargets = 1, effect = "throw", ranged = true },
		{ id = "dwarf.common.ground", name = "GROUND SLAM", cooldown = 10, windup = 0.35, active = 0.18, hitDelay = 0.06, recovery = 0.40, damage = 1.2, posture = 30, range = 6, angle = 360, maxHeight = 7, maxTargets = 8, effect = "slam", stunDuration = 5, description = "Slam nearby enemies and stun targets hit for 5 seconds." },
	},
	mage = {
		{ id = "mage.common.mana_bolt", name = "MANA BOLT", cooldown = 3, manaCost = 15, magic = true, windup = 0.45, active = 0.12, recovery = 0.45, damage = 1.0, posture = 10, range = 40, angle = 45, maxHeight = 10, maxTargets = 1, effect = "mana_bolt", ranged = true },
		{ id = "mage.common.water_ball", name = "WATER BALL", cooldown = 5, manaCost = 12, magic = true, windup = 0.35, active = 0.12, recovery = 0.35, damage = 0.85, posture = 8, range = 40, angle = 45, maxHeight = 10, maxTargets = 1, effect = "water", ranged = true },
		{ id = "mage.common.gravity", name = "GRAVITY", cooldown = 8, manaCost = 20, magic = true, windup = 0.4, active = 0.12, recovery = 0.4, damage = 0.7, posture = 15, range = 40, angle = 45, maxHeight = 10, maxTargets = 8, effect = "gravity", areaRadius = 10, ranged = true, slowDuration = 10, slowMultiplier = 0.3, description = "Slow enemies in the area; they can still attack." },
	},
}

local Advanced=game and require(game:GetService("ReplicatedStorage").Shared.AdvancedSkills) or dofile("src/shared/AdvancedSkills.luau")
for classId,skills in pairs(Advanced.skills) do for _,skill in ipairs(skills) do table.insert(Config.Skills[classId],skill) end end
for classId,skills in pairs(Advanced.common) do for _,skill in ipairs(skills) do table.insert(Config.Skills[classId],skill) end end
-- One shared projection for authoritative damage, HUD previews and mastery.
-- Copy appended definitions so requiring Config never mutates AdvancedSkills.
Config.MageSpellDamageMultiplier = 1.4
local boostedStarterSpells = { ["mage.common.mana_bolt"]=true, ["mage.common.water_ball"]=true, ["mage.common.gravity"]=true }
for index, definition in ipairs(Config.Skills.mage) do
	local skill = {}
	for key, value in pairs(definition) do skill[key] = value end
	if skill.magic and skill.damage > 0 then
		-- Root 1–3 spells inherit the corresponding starter spell damage update.
		local inherited = boostedStarterSpells[skill.id] or (skill.advanced and skill.root and skill.root >= 1 and skill.root <= 3 and not skill.ultimate)
		skill.damage = skill.damage * Config.MageSpellDamageMultiplier * (inherited and 2 or 1)
	end
	-- Gravity descendants inherit its slow and minimum area, retaining larger authored areas.
	if skill.advanced and skill.root == 3 and not skill.ultimate and skill.damage > 0 then
		skill.inheritedGravity = true
		skill.slow, skill.slowDuration = 0.3, 10
		if skill.form == "ground" then skill.radius = math.max(skill.radius, 10)
		elseif skill.form == "area" then skill.range = math.max(skill.range, 10) end
	end
	Config.Skills.mage[index] = skill
end
-- Copy timing fields; never mutate shared attack definitions.
function Config.scaledBasicAttack(definition, rate)
 local result={}
 for key,value in pairs(definition) do result[key]=value end
 for _,key in ipairs({'windup','active','recovery','hitDelay'}) do
  if result[key] then result[key]=result[key]/rate end
 end
 return result
end
return Config
