-- Prototype-only values from docs/knight-combat-spec.md. No progression is saved.
local Config = {
	MaxHealth = 1000,
	AttackPower = 100,
	MaxStamina = 100,
	WalkSpeed = 16,
	GuardSpeed = 8,
	AttackSpeed = 6.4,
	StaminaRegen = 20,
	StaminaRegenDelay = 0.8,
	GuardBreakRegenDelay = 1.2,
	InputBuffer = 0.12,
	ComboReset = 0.6,
	AttackMaxTargets = 3,
	AttackHeight = 7,
	Attacks = {
		{ windup = 0.16, active = 0.10, recovery = 0.16, damage = 0.75, posture = 12, range = 4.5, angle = 100 },
		{ windup = 0.18, active = 0.10, recovery = 0.18, damage = 0.90, posture = 14, range = 4.5, angle = 110 },
		{ windup = 0.26, active = 0.12, recovery = 0.24, damage = 1.20, posture = 24, range = 5.0, angle = 100 },
	},
	Guard = { raiseTime = 0.10, perfectTime = 0.15, initialCost = 4, cooldown = 0.40, angle = 120, damageMultiplier = 0.2, breakStun = 0.8, counterDuration = 1.5 },
	Dodge = { cost = 30, duration = 0.65, moveDuration = 0.30, distance = 7, invulnerableStart = 0.08, invulnerableEnd = 0.28, cooldown = 0.65 },
	HitStun = 0.25,
	Enemy = {
		Goblin = {
			health = 300, posture = 60, walkSpeed = 10, aggroRange = 25, leashRange = 36,
			exposeTime = 1.20, respawnTime = 5,
			attacks = {{ name = "Melee", windup = 0.60, active = 0.10, recovery = 0.80, range = 4, angle = 90, damage = 80, guardCost = 16, blockable = true }},
		},
		-- Initial K0 test values, pending Orc Warrior playtesting; armor and
		-- flank-specific damage are future behavior, not part of this preset.
		Orc = {
			health = 900, posture = 100, walkSpeed = 8.5, aggroRange = 25, leashRange = 36,
			exposeTime = 1.20, respawnTime = 5,
			attacks = {{ name = "Melee", windup = 0.85, active = 0.12, recovery = 1.05, range = 5, angle = 90, damage = 125, guardCost = 25, blockable = true }},
		},
		Ogre = {
			health = 6000, posture = 220, walkSpeed = 7, aggroRange = 25, leashRange = 36,
			exposeTime = 1.50, respawnTime = 5,
			attacks = {
				{ name = "Melee", windup = 1.20, active = 0.15, recovery = 1.40, range = 7, angle = 80, damage = 220, guardCost = 45, blockable = true },
				{ name = "Unblockable", windup = 1.50, active = 0.15, recovery = 1.60, range = 8, angle = 360, damage = 180, guardCost = 0, blockable = false },
			},
		},
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

-- Knight is the only class selected in the current game. Dwarf and Mage are
-- single-hit melee test fixtures, not finalized balance, equipment or skills.
-- The Axe Thrower swings a hand axe; Mage swings a wooden staff. No projectile
-- is part of either basic attack. Keep Knight tied to the existing K0 values.
Config.BasicAttackProfiles = {
	knight = {
		id = "knight.sword.basic", attackPower = Config.AttackPower,
		maxTargets = Config.AttackMaxTargets, maxHeight = Config.AttackHeight, attacks = Config.Attacks,
	},
	dwarf = {
		id = "dwarf.axe.basic", attackPower = 100, maxTargets = 3, maxHeight = 7,
		attacks = {{ windup = 0.16, active = 0.10, recovery = 0.16, damage = 0.75, posture = 12, range = 4.5, angle = 100 }},
	},
	mage = {
		id = "mage.staff.basic", attackPower = 100, maxTargets = 3, maxHeight = 7,
		attacks = {{ windup = 0.16, active = 0.10, recovery = 0.16, damage = 0.75, posture = 12, range = 4.5, angle = 100 }},
	},
}

return Config
