-- Deepwood K0 prototype. The server owns action timing, resources and damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local Advanced=require(ReplicatedStorage.Shared.AdvancedSkills)
local AdvancedCombat=require(script.Parent.AdvancedCombat)
local advancedEffectRemote
local Growth = require(ReplicatedStorage.Shared.HeroProgression)
local rewardHandler
local Config = require(ReplicatedStorage.Shared.K0Config)
local Rules = require(script.Parent.K0Rules)
local EnemyHealthBar = require(script.Parent.Parent.World.EnemyHealthBar)
local Text = require(ReplicatedStorage.Shared.K0Text)

local CombatService = {}
local started = false
local playerStates = {}
-- Hero selection and life generation are held by a trusted server service.
-- Replicated attributes and remote arguments never select a combat profile.
local activePlayers = {}
local heroClasses = {}
local pendingCharacters = {}
local contextResolver = function(_player, _character) return nil end
local enemyStates = {}
local enemyFolder
local hitEffectRemote
local lastGoblinStart = -math.huge
local hadLivingPlayer = false
local nextEnemyId = 0
-- Respond to the actual attacker briefly; the enemy itself still respects its spawn leash.
local ATTACKER_RECOGNITION_SECONDS = 6

local function now()
	return os.clock()
end

local function finiteVector(vector)
	return typeof(vector) == "Vector3" and Rules.isFinite(vector.X) and Rules.isFinite(vector.Y) and Rules.isFinite(vector.Z)
end

local function horizontal(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end

local function horizontalUnit(vector, fallback)
	local flat = horizontal(vector)
	if flat.Magnitude < 0.001 then
		return fallback
	end
	return flat.Unit
end

local function facingDot(origin, direction, target)
	local towards = horizontal(target - origin)
	if towards.Magnitude < 0.001 then
		return 1
	end
	return horizontalUnit(direction, Vector3.new(0, 0, -1)):Dot(towards.Unit)
end

local function rayParams(exclusions)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclusions
	params.RespectCanCollide = true
	params.IgnoreWater = true
	return params
end

local function combatRayParams(excludeA, excludeB)
	local exclusions = { excludeA, excludeB }
	-- Combatants do not count as wall cover for other combatants.
	if enemyFolder then table.insert(exclusions, enemyFolder) end
	for _, state in pairs(playerStates) do
		if state.character.Parent then table.insert(exclusions, state.character) end
	end
	return rayParams(exclusions)
end

local function unobstructed(first, second, excludeA, excludeB)
	local delta = second - first
	if delta.Magnitude < 0.01 then
		return true
	end
	return workspace:Raycast(first, delta, combatRayParams(excludeA, excludeB)) == nil
end

local function updateFeedback(state, value)
	state.feedbackSeq = state.feedbackSeq + 1
	state.character:SetAttribute("K0Feedback", value)
	state.character:SetAttribute("K0FeedbackSeq", state.feedbackSeq)
end


local function setPlayerState(state, name)
	if state.mode == name then
		return
	end
	state.mode = name
	state.character:SetAttribute("K0State", name)
	local speed = state.sprinting and Config.SprintSpeed or Config.WalkSpeed
	if name ~= "Idle" then state.sprinting = false; state.character:SetAttribute("K0Sprinting", false) end
	if name == "Attack" then
		speed = Config.AttackSpeed
	elseif name == "Block" then
		speed = Config.GuardSpeed
	elseif name == "Dodge" or name == "Stunned" or name == "Dead" then
		speed = 0
	end
	state.humanoid.WalkSpeed = speed
end

local function releaseDodgeOwnership(state)
	if state.dodgeOwned then
		state.dodgeOwned = false
		if state.root.Parent then
			pcall(function()
				state.root:SetNetworkOwnershipAuto()
			end)
		end
	end
end

local function restoreAutoRotate(state)
	if state.savedAutoRotate ~= nil then
		if state.humanoid.Parent then state.humanoid.AutoRotate = state.savedAutoRotate end
		state.savedAutoRotate = nil
	end
end

local function clearAction(state)
	releaseDodgeOwnership(state)
	restoreAutoRotate(state)
	state.attack = nil
	state.dodge = nil
	state.guardStarted = nil
	state.character:SetAttribute("K0AttackPhase", "None")
	state.character:SetAttribute("K0AttackKind", nil)
	state.character:SetAttribute("K0SkillId", nil)
	state.character:SetAttribute("K0Invulnerable", false)
end

local function resetCombo(state)
	state.combo = 0
	state.character:SetAttribute("K0Combo", 0)
end

local function readCombatContext(player, character)
	-- The session service must return a synchronous snapshot. A yielding or
	-- failing resolver cannot postpone validation until after a hero switch.
	local thread = coroutine.create(contextResolver)
	local ok, context = coroutine.resume(thread, player, character)
	if coroutine.status(thread) ~= "dead" then
		pcall(coroutine.close, thread)
		return nil
	end
	if not ok or type(context) ~= "table" or type(context.heroId) ~= "string"
		or #context.heroId == 0 or #context.heroId > 128 or type(context.baseClassId) ~= "string"
		or not Config.BasicAttackProfiles[context.baseClassId]
		or not Rules.isFinite(context.epoch) or context.epoch < 1 or context.epoch % 1 ~= 0
		or not Rules.isFinite(context.characterGeneration) or context.characterGeneration < 1
		or context.characterGeneration % 1 ~= 0 then
		return nil
	end
	local remembered = heroClasses[player] and heroClasses[player][context.heroId]
	if remembered and remembered ~= context.baseClassId then return nil end
	return context
end

local function alive(state)
	if not state or playerStates[state.player] ~= state or state.player.Parent ~= Players or state.player.Character ~= state.character
		or state.character.Parent == nil or state.character:GetAttribute("K0SpawnReady") ~= true
		or state.humanoid.Health <= 0 or state.root.Parent == nil then
		return false
	end
	local context = readCombatContext(state.player, state.character)
	return context ~= nil and context.heroId == state.heroId and context.baseClassId == state.baseClassId
		and context.epoch == state.heroEpoch and context.characterGeneration == state.characterGeneration
end

local function markDead(state)
	if playerStates[state.player] ~= state or state.mode == "Dead" then
		return
	end
	state.queued = nil
	state.counter = nil
	clearAction(state)
	state.character:SetAttribute("K0ArrowVisual", nil)
	state.character:SetAttribute("K0SpellVisual", nil)
	resetCombo(state)
	setPlayerState(state, "Dead")
end

local function validDirection(direction)
	if direction == nil then
		return true
	end
	return finiteVector(direction) and direction.Magnitude <= 1.1 and math.abs(direction.Y) <= 0.1
end

local function enemyAlive(enemy)
	return enemy.model.Parent == enemyFolder and enemy.humanoid.Health > 0 and enemy.root.Parent ~= nil
end

local function setEnemyState(enemy, value)
	if enemy.mode ~= value then
		enemy.mode = value
		enemy.model:SetAttribute("K0EnemyState", value)
	end
end

local function stopEnemy(enemy)
	if enemy.root.Parent then
		enemy.humanoid:MoveTo(enemy.root.Position)
	end
end

local function resetEnemyAttack(enemy)
	enemy.attack = nil
	enemy.model:SetAttribute("K0Telegraph", "None")
end

local function damagePosture(enemy, amount, current)
	if current < enemy.postureImmuneUntil or enemy.mode == "Exposed" or not enemyAlive(enemy) then
		return
	end
	enemy.lastPostureDamage = current
	enemy.posture = math.max(0, enemy.posture - amount)
	enemy.model:SetAttribute("K0Posture", enemy.posture)
	if enemy.posture <= 0 then
		resetEnemyAttack(enemy)
		enemy.pathToken = enemy.pathToken + 1
		enemy.pathPending = false
		stopEnemy(enemy)
		enemy.exposedUntil = current + enemy.config.exposeTime
		setEnemyState(enemy, "Exposed")
	end
end

local function startAttack(state, current, targetModel)
	state.lastEquipmentCombat = current
	local profile = state.attackProfile
	if not profile or Config.BasicAttackProfiles[state.baseClassId] ~= profile or #profile.attacks == 0 then
		return
	end
	if state.attack then
		local previous = state.attack
		local previousEnd = previous.started + previous.definition.windup + previous.definition.active + previous.definition.recovery
		if current >= previousEnd then
			state.lastAttackFinished = previousEnd
		end
	end
	local nextCombo = 1
	if state.combo > 0 and current - state.lastAttackFinished <= Config.ComboReset then
		nextCombo = state.combo % #profile.attacks + 1
	end
	clearAction(state)
	state.queued = nil
	state.combo = nextCombo
	state.character:SetAttribute("K0Combo", nextCombo)
	state.attackSeq = state.attackSeq + 1
	state.character:SetAttribute("K0AttackSeq", state.attackSeq)
	local direction = horizontalUnit(state.root.CFrame.LookVector, Vector3.new(0, 0, -1))
	if targetModel and state.baseClassId ~= "elf" then
		local selected = enemyStates[targetModel]
		if selected and enemyAlive(selected) then
			local delta = horizontal(selected.root.Position - state.root.Position)
			if finiteVector(delta) and delta.Magnitude > 0.01 then
				direction = delta.Unit
				-- Turn at the accepted attack start, including buffered attacks.
				-- The hit direction is locked for the whole swing.
				state.savedAutoRotate = state.humanoid.AutoRotate
				state.humanoid.AutoRotate = false
				local position = state.root.Position
				state.root.CFrame = CFrame.lookAt(position, position + direction)
			end
		end
	end
	state.attack = {
		started = current,
		definition = profile.attacks[nextCombo],
		attackPower = (state.derived and (state.baseClassId=="mage" and state.derived.magicPower or state.derived.physicalPower) or profile.attackPower) * (1 + (state.equipment and state.equipment.power or 0) / 100),
		maxTargets = profile.maxTargets,
		maxHeight = profile.maxHeight,
		direction = direction,
		hits = {},
		hitCount = 0,
		counterDamage = nil,
		sampledActive = false, targetModel = targetModel,
	}
	setPlayerState(state, "Attack")
	state.character:SetAttribute("K0AttackKind", "Basic")
	state.character:SetAttribute("K0AttackPhase", "Windup")
	updateFeedback(state, "ActionStarted")
end

-- This movement is server-resolved, bounded and cannot cross a wall or edge.
local function skillStep(state, direction, distance)
	local params = rayParams({ state.character })
	local hit = workspace:Blockcast(state.root.CFrame, state.root.Size * 0.9, direction * distance, params)
	if hit then distance = math.max(0, math.min(distance, hit.Distance - 0.15)) end
	local destination = state.root.Position + direction * distance
	if not workspace:Raycast(destination + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), params) then return end
	state.character:PivotTo(state.character:GetPivot() + direction * distance)
	state.root.AssemblyLinearVelocity = Vector3.zero
	state.lastMotionPosition = state.root.Position
	state.lastSafePivot = state.character:GetPivot()
end

local function setMana(state, value)
	state.mana = math.clamp(value, 0, state.maxMana or Config.MaxMana)
	state.character:SetAttribute("K0Mana", math.floor(state.mana * 10 + 0.5) / 10)
end

local function startSkill(state, slot, current, targetModel)
	local skills = Config.Skills[state.baseClassId]
	if slot > state.slotCount then return end
	local skillIndex=state.skillSlots[slot] or 0
	if state.growth and not Advanced.unlocked(state.growth,state.baseClassId,skillIndex) then return end
	local skill = skills and skills[skillIndex]
	if skill and state.growth then skill=Growth.skill(state.baseClassId,state.skillSlots[slot],skill,state.growth) end
	if not skill then return end
	if state.mode ~= "Idle" then updateFeedback(state, "SkillBusy"); return end
	if current < (state.skillReadyAt[skill.id] or -math.huge) then updateFeedback(state, "SkillCooling"); return end
	-- Magic costs MP by contract, including future magic-archer abilities.
	if skill.magic and (type(skill.manaCost) ~= "number" or skill.manaCost <= 0) then return end
	if skill.magic and (not state.mana or state.mana < skill.manaCost) then updateFeedback(state, "NeedMana"); return end
	if skill.effect == "recall" and (not state.thrownUntil or current >= state.thrownUntil) then
		updateFeedback(state, "NoAxeToRecall"); return
	end
	if skill.effect == "recall" then targetModel = state.thrownTarget end
	local direction = horizontalUnit(state.root.CFrame.LookVector, Vector3.new(0, 0, -1))
	if skill.effect == "whirlwind" or skill.effect == "provoke" or skill.effect == "slam" then targetModel = nil end
	local selected = targetModel and enemyStates[targetModel]
	if selected and enemyAlive(selected) then
		local delta = horizontal(selected.root.Position - state.root.Position)
		if delta.Magnitude > 0.01 then
			direction = delta.Unit
			state.root.CFrame = CFrame.lookAt(state.root.Position, state.root.Position + direction)
		end
	end
	clearAction(state)
	state.queued = nil
	resetCombo(state)
	state.skillReadyAt[skill.id] = current + skill.cooldown
	state.lastEquipmentCombat = current
	if state.setSkillReadyAt then state.setSkillReadyAt(skill.id, state.skillReadyAt[skill.id]) end
	state.character:SetAttribute("K0SkillReady" .. slot, workspace:GetServerTimeNow() + skill.cooldown)
	if skill.magic then
		setMana(state, state.mana - skill.manaCost); state.manaRegenAt = current + Config.ManaRegenDelay
	end
	local advancedCast=skill.advanced and AdvancedCombat.snapshot(state,skill,direction,targetModel,enemyStates,unobstructed)
	if skill.move then skillStep(state,direction,skill.move) end
	if skill.shield then
		for _,friend in pairs(playerStates) do
			if alive(friend) and (friend==state or skill.partyShield and (friend.root.Position-state.root.Position).Magnitude<=10 and unobstructed(state.root.Position,friend.root.Position,state.character,friend.character)) then
				local amount=friend.humanoid.MaxHealth*skill.shield
				friend.branchShield={amount=math.max(amount,friend.branchShield and friend.branchShield.expires>current and friend.branchShield.amount or 0),expires=current+4}
				friend.character:SetAttribute("K0Shield",friend.branchShield.amount)
			end
		end
	end
	if skill.effect == "advance" then skillStep(state, direction, 6) end
	if skill.effect == "retreat" then skillStep(state, -direction, 4) end
	local recallFrom
	if skill.effect == "throw" then state.thrownUntil = current + 4; state.thrownTarget = targetModel; state.thrownPosition = nil end
	if skill.effect == "recall" then
		targetModel = state.thrownTarget; recallFrom = state.thrownPosition
		state.thrownUntil = nil; state.thrownTarget = nil; state.thrownPosition = nil
	end
	state.attack = {
		started = current, definition = skill, advancedCast=advancedCast, attackPower = (state.derived and (skill.magic and state.derived.magicPower or state.derived.physicalPower) or state.attackProfile.attackPower) * (1 + (state.equipment and state.equipment.power or 0) / 100),
		maxTargets = skill.maxTargets, maxHeight = skill.maxHeight, isSpell = skill.magic,
		isSkill = true, ranged = skill.ranged, direction = direction, recallFrom = recallFrom,
		hits = {}, hitCount = 0, counterDamage = nil, sampledActive = false, targetModel = targetModel,
	}
	state.savedAutoRotate = state.humanoid.AutoRotate
	state.humanoid.AutoRotate = false
	setPlayerState(state, "Attack")
	state.character:SetAttribute("K0SkillId", skill.id)
	state.character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow())
	if skill.effect == "rapid" then
		state.character:SetAttribute("K0RapidShotCount", 0)
		state.character:SetAttribute("K0RapidShotAt", nil)
	end
	state.character:SetAttribute("K0AttackKind", skill.magic and "Arcane" or "Basic")
	state.character:SetAttribute("K0AttackPhase", "Windup")
	state.attackSeq = state.attackSeq + 1
	state.character:SetAttribute("K0AttackSeq", state.attackSeq)
	if skill.advanced and advancedEffectRemote then advancedEffectRemote:FireAllClients(state.character,skill.id,state.root.Position,advancedCast.center,0) end
	updateFeedback(state, "ActionStarted")
end

local function startGuard(state, current)
	if state.attack then
		state.lastAttackFinished = current
	end
	clearAction(state)
	state.queued = nil
	state.guardStarted = current
	state.lastGuardStarted = current
	setPlayerState(state, "Block")
	updateFeedback(state, "ActionStarted")
end

local function startDodge(state, direction, current)
	-- The short server-owned move prevents a client from extending the dodge.
	-- A previous dodge may have reached its end before the heartbeat cleaned it up.
	releaseDodgeOwnership(state)
	local ok = pcall(function()
		state.root:SetNetworkOwner(nil)
	end)
	if not ok then
		return
	end
	clearAction(state)
	state.dodgeOwned = true
	state.queued = nil
	resetCombo(state)
	local fallback = -horizontalUnit(state.root.CFrame.LookVector, Vector3.new(0, 0, -1))
	local travel = direction and horizontalUnit(direction, fallback) or fallback
	state.dodge = { started = current, direction = travel, moved = 0 }
	state.lastDodgeStarted = current
	state.dodgeSeq = (state.dodgeSeq or 0) + 1
	state.character:SetAttribute("K0DodgeSeq", state.dodgeSeq)
	setPlayerState(state, "Dodge")
	updateFeedback(state, "ActionStarted")
end

local function resourceReady(state, action, current)
	if action == "Dodge" then
		return true
	elseif action == "BlockStart" then
		return current >= state.lastGuardStarted + Config.Guard.cooldown
	end
	return action == "Attack" and state.attackProfile ~= nil and Config.BasicAttackProfiles[state.baseClassId] == state.attackProfile
end

local function executeAction(state, action, direction, current, targetModel)
	if action == "Attack" then
		startAttack(state, current, targetModel)
	elseif action == "BlockStart" then
		startGuard(state, current)
	elseif action == "Dodge" then
		startDodge(state, direction, current)
	end
end

local function actionEligibleAt(state, action, current)
	if state.mode == "Idle" or state.mode == "Block" then
		return current
	elseif state.mode == "Attack" and state.attack then
		return state.attack.started + Rules.nextAllowedInAttack(action, state.attack.definition)
	elseif state.mode == "Dodge" and state.dodge then
		return state.dodge.started + Config.Dodge.duration
	end
	return math.huge
end

local function acceptAction(state, action, direction, current, targetModel)
	if not alive(state) or state.mode == "Dead" or state.mode == "Stunned" then
		return
	end
	local inventoryContext = readCombatContext(state.player, state.character)
	if inventoryContext and inventoryContext.inventoryLocked and action ~= "BlockEnd" and action ~= "SprintEnd" then return end
	if state.inventoryManaged and (action == "Attack" or action:match("^Skill") or action == "CastArcane" or action == "BlockStart") then
		if not state.equipment or not state.equipment.weapon then updateFeedback(state, "EquipWeapon"); return end
		if state.baseClassId == "knight" and (action == "BlockStart" or action == "Skill1") and not state.equipment.offhand then updateFeedback(state, "EquipShield"); return end
	end
	if action == "Item1" or action == "Item2" then
		if state.inventoryManaged then updateFeedback(state, "InventoryItemOnly"); return end
		local slot = action == "Item1" and 1 or 2
		if state.itemCounts[slot] <= 0 then updateFeedback(state, "ItemEmpty"); return end
		if slot == 1 then
			if state.humanoid.Health >= state.humanoid.MaxHealth then updateFeedback(state, "HealthFull"); return end
			state.humanoid.Health = math.min(state.humanoid.MaxHealth, state.humanoid.Health + 40)
		else
			if not state.mana then updateFeedback(state, "NoManaPool"); return end
			if state.mana >= (state.maxMana or Config.MaxMana) then updateFeedback(state, "ManaFull"); return end
			setMana(state, state.mana + 40)
		end
		state.itemCounts[slot] -= 1
		state.character:SetAttribute("K0ItemCount" .. slot, state.itemCounts[slot])
		return
	end
	if action == "SprintEnd" then
		state.sprinting = false
		state.character:SetAttribute("K0Sprinting", false)
		if state.mode == "Idle" then state.humanoid.WalkSpeed = Config.WalkSpeed end
		return
	end
	if action == "SprintStart" then
		if state.mode == "Idle" then
			state.sprinting = true
			state.sprintExpires = current + 1
			state.character:SetAttribute("K0Sprinting", true)
			state.humanoid.WalkSpeed = Config.SprintSpeed
		end
		return
	end
	if action == "BlockEnd" then
		if state.queued and state.queued.action == "BlockStart" then
			state.queued = nil
		end
		if state.mode == "Block" then
			clearAction(state)
			setPlayerState(state, "Idle")
		end
		return
	end
	if action == "CastArcane" and state.baseClassId == "mage" then
		startSkill(state, 1, current, targetModel)
		return
	end
	local skillSlot = action:match("^Skill([12345])$")
	if skillSlot then startSkill(state, tonumber(skillSlot), current, targetModel); return end
	if action ~= "Attack" and action ~= "Dodge" and action ~= "BlockStart" then
		return
	end
	if action == "BlockStart" and state.mode == "Block" then
		return
	end
	if not resourceReady(state, action, current) then
		return
	end
	if state.queued and Rules.priority(state.queued.action) > Rules.priority(action) then
		return
	end
	if state.mode == "Idle" or state.mode == "Block" then
		executeAction(state, action, direction, current, targetModel)
		return
	end
	local eligibleAt = actionEligibleAt(state, action, current)
	if current >= eligibleAt then
		executeAction(state, action, direction, current, targetModel)
	elseif eligibleAt < current + Config.InputBuffer then
		-- A held button cannot extend the lifetime of a previous buffered input.
		if not state.queued or Rules.priority(action) > Rules.priority(state.queued.action) then
			state.queued = { action = action, direction = direction, targetModel = targetModel, eligibleAt = eligibleAt, expires = current + Config.InputBuffer }
		end
	end
end

local function applyPlayerHit(enemy, playerState, attack, current)
	if not alive(playerState) or attack.hits[playerState.character] then
		return
	end
	local origin = attack.origin
	local target = playerState.root.Position
	local delta = horizontal(target - origin)
	local dot = facingDot(origin, attack.direction, target)
	if not Rules.withinCone(delta.Magnitude, math.abs(target.Y - origin.Y), dot, attack.definition.range, Config.AttackHeight, attack.definition.angle) then
		return
	end
	if not unobstructed(origin, target, enemy.model, playerState.character) then
		return
	end
	attack.hits[playerState.character] = true
	local guardDot = facingDot(target, playerState.root.CFrame.LookVector, origin)
	local result, multiplier = Rules.defense(
		playerState.mode == "Dodge", playerState.dodge and current - playerState.dodge.started or -1,
		playerState.mode == "Block", playerState.guardStarted and current - playerState.guardStarted or -1,
		guardDot, attack.definition.blockable, Config.Guard, Config.Dodge
	)
	if result == "Dodge" then
		updateFeedback(playerState, "Dodged")
		return
	elseif result == "PerfectBlock" then
		playerState.counter = { bonus = 0.50, expires = current + Config.Guard.counterDuration }
		if current >= enemy.lastPerfectResponse + 0.6 then
			enemy.lastPerfectResponse = current
			if enemy.kind == "Ogre" then
				damagePosture(enemy, 20, current)
			else
				attack.extraRecovery = 0.4
			end
		end
		updateFeedback(playerState, "PerfectBlock")
		return
	elseif result == "Blocked" then
		if not playerState.counter or playerState.counter.bonus < 0.25 or playerState.counter.expires <= current then
			playerState.counter = { bonus = 0.25, expires = current + Config.Guard.counterDuration }
		else
			playerState.counter.expires = current + Config.Guard.counterDuration
		end
		updateFeedback(playerState, "Blocked")
	else
		playerState.queued = nil
		playerState.counter = nil
		clearAction(playerState)
		resetCombo(playerState)
		playerState.stunnedUntil = current + Config.HitStun
		setPlayerState(playerState, "Stunned")
		updateFeedback(playerState, "Interrupted")
	end
	if playerState.rallyUntil and current < playerState.rallyUntil then multiplier = multiplier * 0.8 end
	local damage = math.max(1, math.floor(attack.definition.damage * multiplier + 0.5))
	damage = math.max(1, damage - (playerState.equipment and playerState.equipment.armor or 0) - (playerState.derived and playerState.derived.armor or 0))
	if playerState.branchShield and playerState.branchShield.expires>current then
		local absorbed=math.min(damage,playerState.branchShield.amount)
		playerState.branchShield.amount=playerState.branchShield.amount-absorbed;damage=damage-absorbed
		playerState.character:SetAttribute("K0Shield",playerState.branchShield.amount)
	end
	playerState.humanoid:TakeDamage(damage)
	playerState.lastEquipmentCombat = current
	if playerState.humanoid.Health <= 0 then
		markDead(playerState)
	end
end

local function damageEnemy(state, enemy, attack, current)
	if attack.hits[enemy.model] then return end
	attack.hits[enemy.model] = true
	attack.hitCount = attack.hitCount + 1
	if attack.counterDamage == nil then
		attack.counterDamage = 0
		if state.baseClassId == "knight" and state.counter and state.counter.expires > current then
			attack.counterDamage = state.counter.bonus
			state.counter = nil
		end
	end
	local multiplier = (enemy.mode == "Exposed" and 1.15 or 1)
		* Rules.defenseBreakMultiplier(current, enemy.defenseBreakUntil, Config.Skills.knight[3].defenseBreakDamageMultiplier)
	if enemy.marks and enemy.marks[state] and current < enemy.marks[state] then multiplier *= 1.2 end
	local d=attack.definition
	local ownedMark=enemy.branchMarks and enemy.branchMarks[state.heroId]
	if d.advanced then
		if ownedMark and ownedMark.expires>current and d.consume==ownedMark.kind then
			multiplier=multiplier*(1+(d.markBonus or 0));attack.branchMarked=true
			enemy.branchMarks[state.heroId]=nil
		else attack.branchMarked=false end
		if d.wetBonus and (enemy.model:GetAttribute("K0WetUntil") or 0)>workspace:GetServerTimeNow() then multiplier=multiplier*(1+d.wetBonus) end
		if d.weakenBonus and (enemy.defenseBreakUntil or 0)>current then multiplier=multiplier*(1+d.weakenBonus) end
	end
	local damage = math.max(1, math.floor(attack.attackPower * (d.damage + attack.counterDamage) * multiplier + 0.5))
	-- Set the attacker before TakeDamage: a lethal hit can synchronously fire
	-- Died, and split offspring must inherit the real server-validated attacker.
	local expires = current + ATTACKER_RECOGNITION_SECONDS
	enemy.attackers = enemy.attackers or {}
	enemy.attackers[state] = expires
	enemy.aggroUntil = expires
	enemy.lastAttacker = state
	if not (enemy.provokedBy and current < (enemy.provokeUntil or 0) and alive(enemy.provokedBy)
		and horizontal(enemy.provokedBy.root.Position - enemy.spawnPosition).Magnitude <= enemy.config.leashRange) then
		enemy.target = state
	end
	local healthBefore = enemy.humanoid.Health
	local position = enemy.root.Position
	-- Retain this impact's hit set before damage can fire Died. A split child
	-- must not be sampled by the same swing or projectile that made it.
	enemy.lethalHitSet = enemy.kind == "Slime" and not enemy.splitGroup and damage >= healthBefore and attack.hits or nil
	enemy.humanoid:TakeDamage(damage)
	if enemy.humanoid.Health > 0 then enemy.lethalHitSet = nil end
	local applied = math.max(0, healthBefore - math.max(0, enemy.humanoid.Health))
	if applied > 0 and hitEffectRemote then
		-- This is presentation data for an already resolved hit, never an
		-- input to damage. A position snapshot survives a lethal target's removal.
		local direction = horizontalUnit(position - state.root.Position, attack.direction)
		hitEffectRemote:FireAllClients(enemy.model, position, applied, state.baseClassId, enemy.kind, direction, attack.isSkill and attack.definition.id or nil)
	end
	if enemy.humanoid.Health > 0 then
		if applied>0 and d.advanced then
			if d.mark then enemy.branchMarks=enemy.branchMarks or {};enemy.branchMarks[state.heroId]={kind=d.mark,expires=current+8};enemy.model:SetAttribute("K0BranchMark",d.mark) end
			if d.slow and enemy.kind~="Ogre" then enemy.gravityUntil=current+(d.slowDuration or 2);enemy.gravityMultiplier=d.slow;enemy.model:SetAttribute("K0GravityUntil",workspace:GetServerTimeNow()+(d.slowDuration or 2)) end
			if d.taunt and enemy.kind~="Ogre" then enemy.provokedBy=state;enemy.provokeUntil=current+d.taunt;enemy.model:SetAttribute("K0ProvokeUntil",workspace:GetServerTimeNow()+d.taunt) end
			if d.push and enemy.kind~="Ogre" then
				local push=horizontalUnit(enemy.root.Position-state.root.Position,attack.direction)*d.push
				local wall=workspace:Blockcast(enemy.root.CFrame,enemy.root.Size*.9,push,rayParams({enemy.model,state.character}))
				if not wall and workspace:Raycast(enemy.root.Position+push,Vector3.new(0,-10,0),rayParams({enemy.model,state.character})) then enemy.model:PivotTo(enemy.model:GetPivot()+push) end
			end
		end
		if applied > 0 and attack.isSkill and attack.definition.effect == "mark" then
			enemy.marks = enemy.marks or {}; enemy.marks[state] = current + 8
			enemy.model:SetAttribute("K0MarkedUntil", workspace:GetServerTimeNow() + 8)
		end
		if applied > 0 and attack.isSkill and attack.definition.effect == "bash" and enemy.kind ~= "Ogre" and enemy.attack then resetEnemyAttack(enemy) end
		if applied > 0 and attack.isSkill and attack.definition.effect == "water" then
			enemy.model:SetAttribute("K0WetUntil", workspace:GetServerTimeNow() + 4)
		end
		if applied > 0 and attack.isSkill and attack.definition.effect == "gravity" then
			enemy.gravityUntil = current + attack.definition.slowDuration
			enemy.gravityMultiplier = attack.definition.slowMultiplier
			enemy.humanoid.WalkSpeed = enemy.config.walkSpeed * enemy.gravityMultiplier
			enemy.model:SetAttribute("K0GravityUntil", workspace:GetServerTimeNow() + attack.definition.slowDuration)
		end
		if not enemy.attack and enemy.mode ~= "Exposed" then setEnemyState(enemy, "Chase") end
		local posture=d.posture
		if d.advanced then
			if attack.branchMarked then posture=posture+(d.markPosture or 0) end
			if d.weakenPosture and (enemy.defenseBreakUntil or 0)>current then posture=posture+d.weakenPosture end
			if d.counterPosture and attack.counterDamage>0 then posture=posture+d.counterPosture end
		end
		damagePosture(enemy,posture,current)
	end
	updateFeedback(state, "Hit")
end

-- Knight, Dwarf and Mage share melee cone and obstruction checks.
local function applySwordHits(state, current)
	local attack = state.attack
	if not attack or attack.hitCount >= attack.maxTargets then
		return
	end
	local origin = state.root.Position
	local candidates = {}
	local selected = attack.targetModel and enemyStates[attack.targetModel]
	if attack.targetModel and not attack.hits[attack.targetModel] then
		local failure
		if not selected or not enemyAlive(selected) then
			failure = "TargetUnavailable"
		else
			local position = selected.root.Position
			local distance = horizontal(position - origin).Magnitude
			local dot = facingDot(origin, attack.direction, position)
			if not Rules.withinCone(distance, math.abs(position.Y - origin.Y), dot, attack.definition.range, attack.maxHeight, attack.definition.angle)
				or not unobstructed(origin, position, state.character, selected.model) then failure = "TargetBlocked" end
		end
		if failure then
			if attack.targetFeedback ~= failure then updateFeedback(state, failure); attack.targetFeedback = failure end
			return
		end
	end
	for _, enemy in pairs(enemyStates) do
		if enemyAlive(enemy) and not attack.hits[enemy.model] then
			local position = enemy.root.Position
			local distance = horizontal(position - origin).Magnitude
			local dot = facingDot(origin, attack.direction, position)
			if Rules.withinCone(distance, math.abs(position.Y - origin.Y), dot, attack.definition.range, attack.maxHeight, attack.definition.angle)
				and unobstructed(origin, position, state.character, enemy.model) then
				table.insert(candidates, { enemy = enemy, distance = distance })
			end
		end
	end
	table.sort(candidates, function(left, right)
		if selected and (left.enemy == selected) ~= (right.enemy == selected) then return left.enemy == selected end
		if left.distance == right.distance then
			return left.enemy.id < right.enemy.id
		end
		return left.distance < right.distance
	end)
	for _, candidate in ipairs(candidates) do
		if attack.hitCount >= attack.maxTargets then
			break
		end
		damageEnemy(state, candidate.enemy, attack, current)
	end
end

-- One server-resolved shot per attack. An explicit registered target is
-- checked for life, range and obstruction; otherwise narrow aim assist uses
-- the nearest visible enemy. The endpoint is presentation data, never input.
-- A missed Active window uses the existing bounded late-sample rule.
local function applyArrowShot(state, current)
	local attack = state.attack
	if not attack or attack.arrowFired then return end
	attack.arrowFired = true
	local origin, target, nearest = state.root.Position, nil, math.huge
	local selected = attack.targetModel and enemyStates[attack.targetModel]
	local selectedEndpoint
	if attack.targetModel then
		if selected and enemyAlive(selected) then
			local position = selected.root.Position
			local delta = position - origin
			local distance = delta.Magnitude
			local direction = horizontalUnit(delta, attack.direction)
			selectedEndpoint = origin + direction * math.min(distance, attack.definition.range)
			local wall = workspace:Raycast(origin, selectedEndpoint - origin, combatRayParams(state.character, enemyFolder))
			if wall then selectedEndpoint = wall.Position end
			if distance <= attack.definition.range and math.abs(delta.Y) <= attack.maxHeight
				and unobstructed(origin, position, state.character, selected.model) then
				target, selectedEndpoint = selected, position
			else
				updateFeedback(state, "TargetBlocked")
			end
		else
			updateFeedback(state, "TargetUnavailable")
		end
	end
	for _, enemy in pairs(enemyStates) do
		if not attack.targetModel and not (attack.isSkill and attack.definition.effect == "recall") and enemyAlive(enemy) and not attack.hits[enemy.model] then
			local position = enemy.root.Position
			local delta = position - origin
			local distance = delta.Magnitude
			local dot = facingDot(origin, attack.direction, position)
			if Rules.withinCone(distance, math.abs(delta.Y), dot, attack.definition.range, attack.maxHeight, attack.definition.angle)
				and (distance < nearest or (distance == nearest and (not target or enemy.id < target.id)))
				and unobstructed(origin, position, state.character, enemy.model) then
				target, nearest = enemy, distance
			end
		end
	end
	local endpoint
	if target then
		endpoint = target.root.Position
	elseif selectedEndpoint then
		endpoint = selectedEndpoint
	elseif attack.recallFrom then
		endpoint = attack.recallFrom
	else
		local delta = attack.direction * attack.definition.range
		local wall = workspace:Raycast(origin, delta, combatRayParams(state.character, enemyFolder))
		endpoint = wall and wall.Position or origin + delta
	end
	local sequence, visualName
	if attack.isSpell or (attack.isSkill and state.baseClassId == "dwarf") then
		state.spellSeq = state.spellSeq + 1
		sequence, visualName = state.spellSeq, "K0SpellVisual"
	else
		state.arrowSeq = state.arrowSeq + 1
		sequence, visualName = state.arrowSeq, "K0ArrowVisual"
		state.character:SetAttribute("K0ArrowFrom", origin)
		state.character:SetAttribute("K0ArrowTo", endpoint)
		state.character:SetAttribute("K0ArrowSeq", sequence)
	end
	-- A single replicated snapshot avoids combining endpoints from two shots
	-- if separate attributes arrive in different replication updates.
	if attack.isSkill and attack.definition.effect == "throw" then
		state.thrownTarget = target and target.model or nil
		state.thrownPosition = endpoint
	end
	local visualFrom, visualTo = origin, endpoint
	if attack.isSkill and attack.definition.effect == "recall" then visualFrom, visualTo = endpoint, origin end
	state.character:SetAttribute(visualName, string.format("%d|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f",
		sequence, visualFrom.X, visualFrom.Y, visualFrom.Z, visualTo.X, visualTo.Y, visualTo.Z))
	local multiVisualTargets = {}
	if target then
		damageEnemy(state, target, attack, current)
		if attack.isSkill and attack.definition.effect == "gravity" then
			local center = endpoint
			state.character:SetAttribute("K0GravityAreaVisual", string.format("%d|%.3f|%.3f|%.3f", state.spellSeq, center.X, center.Y, center.Z))
			local others = {}
			for _, enemy in pairs(enemyStates) do
				local delta = enemy.root.Position - center
				if enemy ~= target and not attack.hits[enemy.model] and enemyAlive(enemy) and horizontal(delta).Magnitude <= attack.definition.areaRadius
					and math.abs(delta.Y) <= attack.maxHeight and unobstructed(center, enemy.root.Position, target.model, enemy.model) then
					table.insert(others, enemy)
				end
			end
			table.sort(others, function(a, b)
				local da, db = (a.root.Position - center).Magnitude, (b.root.Position - center).Magnitude
				if da == db then return a.id < b.id end
				return da < db
			end)
			for _, enemy in ipairs(others) do
				if attack.hitCount >= attack.maxTargets then break end
				damageEnemy(state, enemy, attack, current)
			end
		elseif attack.isSkill and attack.definition.effect == "multi" then
			local aim = horizontalUnit(target.root.Position - origin, attack.direction)
			local others = {}
			for _, enemy in pairs(enemyStates) do
				local delta = enemy.root.Position - origin
				if enemy ~= target and not attack.hits[enemy.model] and enemyAlive(enemy)
					and Rules.withinCone(delta.Magnitude, math.abs(delta.Y), facingDot(origin, aim, enemy.root.Position), attack.definition.range, attack.maxHeight, attack.definition.angle)
					and unobstructed(origin, enemy.root.Position, state.character, enemy.model) then table.insert(others, enemy) end
			end
			table.sort(others, function(a, b)
				local da, db = (a.root.Position - origin).Magnitude, (b.root.Position - origin).Magnitude
				if da == db then return a.id < b.id end
				return da < db
			end)
			for _, enemy in ipairs(others) do
				if attack.hitCount >= attack.maxTargets then break end
				local position = enemy.root.Position
				table.insert(multiVisualTargets, position)
				damageEnemy(state, enemy, attack, current)
			end
		elseif attack.isSkill and attack.definition.effect == "pierce" then
			local aim = horizontalUnit(target.root.Position - origin, attack.direction)
			local others = {}
			for _, enemy in pairs(enemyStates) do
				local delta = enemy.root.Position - origin
				if enemy ~= target and not attack.hits[enemy.model] and enemyAlive(enemy) and Rules.withinCone(delta.Magnitude, math.abs(delta.Y), facingDot(origin, aim, enemy.root.Position), attack.definition.range, attack.maxHeight, attack.definition.angle)
					and unobstructed(origin, enemy.root.Position, state.character, enemy.model) then table.insert(others, enemy) end
			end
			table.sort(others, function(a,b) return (a.root.Position-origin).Magnitude < (b.root.Position-origin).Magnitude end)
			for _, enemy in ipairs(others) do
				if attack.hitCount >= attack.maxTargets then break end
				damageEnemy(state, enemy, attack, current)
			end
		end
	end
	if attack.isSkill and attack.definition.effect == "multi" then
		-- Four visual lanes accompany the primary shot even with no enemies.
		-- Extra target damage remains strictly in the server-validated loop above.
		local aim = horizontalUnit(endpoint - origin, attack.direction)
		local angles = { -24, -12, 12, 24 }
		while #multiVisualTargets < 4 do
			local angle = math.rad(angles[#multiVisualTargets + 1])
			local direction = CFrame.Angles(0, angle, 0):VectorToWorldSpace(aim)
			local delta = direction * attack.definition.range
			local wall = workspace:Raycast(origin, delta, combatRayParams(state.character, enemyFolder))
			table.insert(multiVisualTargets, wall and wall.Position or origin + delta)
		end
		local points = { tostring(sequence), string.format("%.3f", origin.X), string.format("%.3f", origin.Y), string.format("%.3f", origin.Z) }
		for _, position in ipairs(multiVisualTargets) do
			table.insert(points, string.format("%.3f", position.X)); table.insert(points, string.format("%.3f", position.Y)); table.insert(points, string.format("%.3f", position.Z))
		end
		state.character:SetAttribute("K0MultiShotVisual", table.concat(points, "|"))
	end
end

local function moveDodge(state, current)
	local dodge = state.dodge
	if not dodge then
		return
	end
	local elapsed = current - dodge.started
	local targetDistance = Config.Dodge.distance * math.min(1, elapsed / Config.Dodge.moveDuration)
	local distance = math.max(0, targetDistance - dodge.moved)
	if distance > 0 and not dodge.blocked then
		local direction = dodge.direction * distance
		local params = rayParams({ state.character })
		local hit = workspace:Blockcast(state.root.CFrame, state.root.Size * 0.9, direction, params)
		if hit then
			distance = math.max(0, math.min(distance, hit.Distance - 0.15))
			dodge.blocked = true
		end
		local destination = state.root.Position + dodge.direction * distance
		local ground = workspace:Raycast(destination + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), params)
		if not ground then
			distance = 0
			dodge.blocked = true
		end
		if distance > 0 then
			state.character:PivotTo(state.character:GetPivot() + dodge.direction * distance)
			state.root.AssemblyLinearVelocity = Vector3.new(0, state.root.AssemblyLinearVelocity.Y, 0)
			-- An unobstructed step reaches this exact cumulative distance.
			-- Repeating the same server timestamp must not move or cast again.
			if dodge.blocked then
				dodge.moved = dodge.moved + distance
			else
				dodge.moved = targetDistance
			end
		end
	end
	state.character:SetAttribute("K0Invulnerable", elapsed >= Config.Dodge.invulnerableStart and elapsed < Config.Dodge.invulnerableEnd)
end

local function checkMovement(state, current)
	local position = state.root.Position
	if not finiteVector(position) then
		return false
	end
	local elapsed = math.max(0, math.min(0.5, current - state.lastMotionAt))
	if state.mode ~= "Dodge" then
		local travelled = (position - state.lastMotionPosition).Magnitude
		-- Replicated movement can arrive in bursts between heartbeats. Accumulate
		-- the unused allowance instead of charging every sample as a fresh burst.
		local permitted, remaining = Rules.movementBudget(state.movementBudget, elapsed, travelled, state.sprinting and Config.SprintSpeed or Config.WalkSpeed, Config.MovementBudget)
		if not permitted then
			-- Rewind to the last accepted server sample; never use a rejected position for hits.
			state.character:PivotTo(state.lastSafePivot)
			state.root.AssemblyLinearVelocity = Vector3.zero
			state.lastMotionPosition = state.root.Position
			state.movementBudget = 0
			state.queued = nil
			state.lastMotionAt = current
			return false
		end
		state.movementBudget = remaining
	else
		state.movementBudget = Config.MovementBudget
	end
	state.lastMotionPosition = state.root.Position
	state.lastSafePivot = state.character:GetPivot()
	state.lastMotionAt = current
	return true
end

-- Resolve pending player and enemy windows before input, state transitions or
-- cancellation can discard an attack. A delayed observation uses current
-- player/target positions and defense; enemy origin/direction remain the last
-- server-observed windup lock. No historical guard/dodge is reconstructed.
-- If both sides are overdue, the earlier window starts first; player wins a tie.
local function processCombatSamples(current, requiredState)
	local validPlayers, orderedPlayers, pending, pendingPlayers = {}, {}, {}, {}
	local needsTargets = false
	for _, state in pairs(playerStates) do
		local attack = state.attack
		if alive(state) and state.mode == "Attack" and attack then
			if attack.isSkill and attack.definition.advanced then
				local fired=attack.advancedFired or 0
				while fired<attack.definition.pulses do
					local due=attack.started+attack.definition.windup+fired*attack.definition.interval
					if current<due then break end
					fired=fired+1
					if current<=due+Rules.MaxLateHit+Rules.TimeEpsilon then
						pendingPlayers[state]=true
						table.insert(pending,{player=state,attack=attack,advancedIndex=fired,at=due,order=0,id=state.player.UserId})
					else attack.advancedFired=fired end
				end
			elseif attack.isSkill and attack.definition.effect == "rapid" then
				local fired = attack.rapidFired or 0
				while fired < attack.definition.shotCount do
					local due = attack.started + attack.definition.windup + fired * attack.definition.shotInterval
					if current < due then break end
					fired += 1
					if current <= due + Rules.MaxLateHit + Rules.TimeEpsilon then
						pendingPlayers[state] = true
						table.insert(pending, { player = state, attack = attack, rapidIndex = fired, at = due, order = 0, id = state.player.UserId })
					else
						attack.rapidFired = fired
					end
				end
			elseif Rules.shouldSampleHitWindow(current - attack.started, attack.definition, attack.sampledActive) then
				pendingPlayers[state] = true
				table.insert(pending, { player = state, attack = attack,
					at = attack.sampledActive and current or attack.started + attack.definition.windup + (attack.definition.hitDelay or 0),
					order = 0, id = state.player.UserId })
			end
		end
	end
	for _, enemy in pairs(enemyStates) do
		local attack = enemy.attack
		if enemyAlive(enemy) and attack
			and Rules.shouldSampleHitWindow(current - attack.started, attack.definition, attack.sampledActive) then
			needsTargets = true
			table.insert(pending, { enemy = enemy, attack = attack,
				at = attack.sampledActive and current or attack.started + attack.definition.windup,
				order = 1, id = enemy.id })
		end
	end
	-- An enemy hit may reach any player. A player-only hit needs just its own
	-- validated attacker; when no hit is due, only the input sender is checked.
	for _, state in pairs(playerStates) do
		if alive(state) and (needsTargets or pendingPlayers[state] or state == requiredState) then
			validPlayers[state] = checkMovement(state, current)
			if needsTargets and validPlayers[state] and state.mode == "Dodge" then
				-- An enemy samples the position at this server time. Advance only
				-- the already server-owned dodge before checking that position;
				-- stepPlayer's later call at the same time is idempotent.
				if state.dodge and state.dodgeOwned then
					moveDodge(state, current)
					validPlayers[state] = checkMovement(state, current)
				else
					validPlayers[state] = false
				end
			end
			if needsTargets then table.insert(orderedPlayers, state) end
		end
	end
	if needsTargets then
		table.sort(orderedPlayers, function(a, b) return a.player.UserId < b.player.UserId end)
	end
	if #pending > 1 then
		table.sort(pending, function(a, b)
			if a.at ~= b.at then return a.at < b.at end
			if a.order ~= b.order then return a.order < b.order end
			return a.id < b.id
		end)
	end
	for _, sample in ipairs(pending) do
		local attack = sample.attack
		if sample.player then
			local state = sample.player
			if validPlayers[state] and alive(state) and state.mode == "Attack" and state.attack == attack then
				attack.sampledActive = true
				if sample.advancedIndex then
					attack.advancedFired=math.max(attack.advancedFired or 0,sample.advancedIndex)
					AdvancedCombat.resolve(state,attack,current,{enemies=enemyStates,clear=unobstructed,damage=damageEnemy,move=skillStep,
						visual=function(actor,d,origin,center,pulse,points) if advancedEffectRemote then advancedEffectRemote:FireAllClients(actor.character,d.id,origin,center,pulse,points) end end},sample.advancedIndex)
				elseif sample.rapidIndex then
					attack.rapidFired = math.max(attack.rapidFired or 0, sample.rapidIndex)
					state.character:SetAttribute("K0RapidShotAt", workspace:GetServerTimeNow())
					state.character:SetAttribute("K0RapidShotCount", sample.rapidIndex)
					attack.arrowFired, attack.hits, attack.hitCount, attack.counterDamage = false, {}, 0, nil
					applyArrowShot(state, current)
				elseif attack.isSkill and attack.definition.effect == "provoke" then
					local candidates = {}
					local origin = state.root.Position
					for _, enemy in pairs(enemyStates) do
						local delta = enemy.root.Position - origin
						if enemyAlive(enemy) and horizontal(delta).Magnitude <= attack.definition.range
							and math.abs(delta.Y) <= attack.maxHeight
							and horizontal(origin - enemy.spawnPosition).Magnitude <= enemy.config.leashRange
							and unobstructed(origin, enemy.root.Position, state.character, enemy.model) then
							table.insert(candidates, enemy)
						end
					end
					table.sort(candidates, function(a, b)
						local da, db = (a.root.Position - origin).Magnitude, (b.root.Position - origin).Magnitude
						if da == db then return a.id < b.id end
						return da < db
					end)
					for index = 1, math.min(attack.maxTargets, #candidates) do
						local enemy = candidates[index]
						enemy.provokedBy, enemy.provokeUntil = state, current + attack.definition.provokeDuration
						enemy.defenseBreakUntil = current + attack.definition.defenseBreakDuration
						enemy.model:SetAttribute("K0DefenseBreakUntil", workspace:GetServerTimeNow() + attack.definition.defenseBreakDuration)
						enemy.target = state
						enemy.model:SetAttribute("K0ProvokeUntil", workspace:GetServerTimeNow() + attack.definition.provokeDuration)
						if not enemy.attack and enemy.mode ~= "Exposed" then setEnemyState(enemy, "Chase") end
					end
				elseif attack.isSkill and not attack.ranged then
					applySwordHits(state, current)
					if attack.isSpell then
						state.spellSeq += 1
						local first = state.root.Position
						local last = first + attack.direction * attack.definition.range
						local wall = workspace:Raycast(first, last - first, combatRayParams(state.character, enemyFolder))
						if wall then last = wall.Position end
						state.character:SetAttribute("K0SpellVisual", string.format("%d|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", state.spellSeq, first.X, first.Y, first.Z, last.X, last.Y, last.Z))
					end
				elseif state.baseClassId == "elf" or attack.isSpell or attack.ranged then applyArrowShot(state, current)
				else applySwordHits(state, current) end
			end
		else
			local enemy = sample.enemy
			if enemyAlive(enemy) and enemy.attack == attack then
				attack.sampledActive = true
				for _, state in ipairs(orderedPlayers) do
					if validPlayers[state] then applyPlayerHit(enemy, state, attack, current) end
					if enemy.attack ~= attack or not enemyAlive(enemy) then break end
				end
			end
		end
	end
	return validPlayers
end

local function stepPlayer(state, current, dt, movementAlreadyChecked)
	if not alive(state) then
		markDead(state)
		return
	end
	if not movementAlreadyChecked and not checkMovement(state, current) then
		return
	end
	if state.mode == "Attack" and state.attack then
		local attack = state.attack
		local phase = Rules.phase(current - attack.started, attack.definition)
		state.character:SetAttribute("K0AttackPhase", phase)
		if phase == "None" then
			state.lastAttackFinished = attack.started + attack.definition.windup + attack.definition.active + attack.definition.recovery
			state.attack = nil
			restoreAutoRotate(state)
			state.character:SetAttribute("K0AttackKind", nil)
			state.character:SetAttribute("K0SkillId", nil)
			setPlayerState(state, "Idle")
		end
	elseif state.mode == "Dodge" and state.dodge then
		moveDodge(state, current)
		if current >= state.dodge.started + Config.Dodge.duration then
			clearAction(state)
			setPlayerState(state, "Idle")
		end
	elseif state.mode == "Stunned" and current >= state.stunnedUntil then
		setPlayerState(state, "Idle")
	end
	if state.mode ~= "Attack" and state.combo > 0 and current - state.lastAttackFinished > Config.ComboReset then
		resetCombo(state)
	end
	if state.counter and current >= state.counter.expires then
		state.counter = nil
	end
	local consumedAction
	if state.queued then
		local queued = state.queued
		if queued.eligibleAt >= queued.expires or current > queued.eligibleAt + Rules.MaxLateBuffer + Rules.TimeEpsilon
			or not resourceReady(state, queued.action, current) then
			state.queued = nil
		elseif Rules.bufferCanExecute(current, queued.eligibleAt, queued.expires) then
			local isReady = state.mode == "Idle" or state.mode == "Block"
			if state.mode == "Attack" and state.attack then
				isReady = Rules.allowedInAttack(queued.action, current - state.attack.started, state.attack.definition)
			end
			if isReady then
				state.queued = nil
				executeAction(state, queued.action, queued.direction, current, queued.targetModel)
				consumedAction = queued.action
			end
		end
	end
	if state.sprinting and current >= state.sprintExpires then
		state.sprinting = false
		state.character:SetAttribute("K0Sprinting", false)
		if state.mode == "Idle" then state.humanoid.WalkSpeed = Config.WalkSpeed end
	end
	-- Recovery is server-owned and continues during combat; dead or invalid
	-- characters already returned through alive() above.
	if state.branchShield and current>=state.branchShield.expires then state.branchShield=nil;state.character:SetAttribute("K0Shield",0) end
	if state.humanoid.Health < state.humanoid.MaxHealth then
		state.humanoid.Health = math.min(state.humanoid.MaxHealth,
			state.humanoid.Health + state.humanoid.MaxHealth * Config.HealthRegenFraction * math.min(dt, 0.25))
	end
	if state.mana and current >= state.manaRegenAt and state.mode ~= "Dead" then
		setMana(state, state.mana + Config.ManaRegen * math.min(dt, 0.25))
	end
	return consumedAction
end

local function closestTarget(enemy, current)
	local forced = enemy.provokedBy
	if forced then
		if current < (enemy.provokeUntil or 0) and alive(forced)
			and horizontal(forced.root.Position - enemy.spawnPosition).Magnitude <= enemy.config.leashRange then
			return forced, horizontal(forced.root.Position - enemy.root.Position).Magnitude
		end
		enemy.provokedBy, enemy.provokeUntil = nil, nil
		enemy.model:SetAttribute("K0ProvokeUntil", nil)
	end
	local closest, closestDistance
	if enemy.attackers then
		for attacker, expires in pairs(enemy.attackers) do
			if current >= expires or not alive(attacker) then
				enemy.attackers[attacker] = nil
			else
				local distance = horizontal(attacker.root.Position - enemy.root.Position).Magnitude
				if not closestDistance or distance < closestDistance then closest, closestDistance = attacker, distance end
			end
		end
		-- A validated hit is recognized even outside passive detection range.
		-- stepEnemy separately keeps the enemy inside its own spawn leash.
		if closest then return closest, closestDistance end
	end
	for _, playerState in pairs(playerStates) do
		if alive(playerState) then
			local position = playerState.root.Position
			local distance = horizontal(position - enemy.root.Position).Magnitude
			local distanceFromSpawn = horizontal(position - enemy.spawnPosition).Magnitude
			if distanceFromSpawn <= enemy.config.leashRange and distance <= enemy.config.aggroRange
				and (not closestDistance or distance < closestDistance) then
				closest, closestDistance = playerState, distance
			end
		end
	end
	return closest, closestDistance
end

local function moveEnemy(enemy, destination, current)
	if current < enemy.nextMoveAt then
		return
	end
	enemy.nextMoveAt = current + Config.Enemy.MovementInterval
	local origin = enemy.root.Position
	local pathBlocked = not unobstructed(origin, destination, enemy.model, enemy.target and enemy.target.character or enemy.model)
	if pathBlocked and current >= enemy.nextPathAt and not enemy.pathPending then
		enemy.nextPathAt = current + Config.Enemy.PathInterval
		enemy.pathPending = true
		enemy.pathToken = enemy.pathToken + 1
		local token = enemy.pathToken
		local startPosition = origin
		local goal = destination
		task.spawn(function()
			local path = PathfindingService:CreatePath({ AgentRadius = enemy.kind == "Ogre" and 3 or 2, AgentHeight = enemy.kind == "Ogre" and 10 or 5, AgentCanJump = false, WaypointSpacing = 5 })
			local ok = pcall(function()
				path:ComputeAsync(startPosition, goal)
			end)
			if token == enemy.pathToken then
				enemy.pathPending = false
				if ok and path.Status == Enum.PathStatus.Success then
					enemy.waypoints = path:GetWaypoints()
					enemy.waypointIndex = 1
				else
					enemy.waypoints = nil
				end
			end
		end)
	elseif not pathBlocked then
		enemy.waypoints = nil
	end
	if pathBlocked and enemy.waypoints then
		while enemy.waypoints[enemy.waypointIndex] and horizontal(enemy.waypoints[enemy.waypointIndex].Position - origin).Magnitude < 2 do
			enemy.waypointIndex = enemy.waypointIndex + 1
		end
		local waypoint = enemy.waypoints[enemy.waypointIndex]
		if waypoint then
			destination = waypoint.Position
		end
	end
	enemy.humanoid:MoveTo(destination)
end

local function beginEnemyAttack(enemy, target, current)
	local attackIndex = 1
	if enemy.kind == "Ogre" then
		attackIndex = enemy.pattern % 3 == 2 and 2 or 1
		enemy.pattern = enemy.pattern + 1
	elseif enemy.kind == "Goblin" then
		lastGoblinStart = current
	end
	local definition = enemy.config.attacks[attackIndex]
	local direction = horizontalUnit(target.root.Position - enemy.root.Position, enemy.root.CFrame.LookVector)
	enemy.attack = { definition = definition, started = current, direction = direction, origin = enemy.root.Position, hits = {}, locked = false, extraRecovery = 0, sampledActive = false }
	enemy.target = target
	enemy.attackSeq = enemy.attackSeq + 1
	enemy.model:SetAttribute("K0AttackSeq", enemy.attackSeq)
	enemy.model:SetAttribute("K0Telegraph", definition.name)
	enemy.model:SetAttribute("K0AttackOrigin", enemy.root.Position)
	enemy.model:SetAttribute("K0AttackDirection", direction)
	enemy.model:SetAttribute("K0AttackRange", definition.range)
	enemy.model:SetAttribute("K0AttackAngle", definition.angle)
	enemy.pathToken = enemy.pathToken + 1
	enemy.pathPending = false
	stopEnemy(enemy)
	setEnemyState(enemy, "Windup")
end

local function resetEnemy(enemy)
	if not enemyAlive(enemy) then
		return
	end
	resetEnemyAttack(enemy)
	enemy.pathToken = enemy.pathToken + 1
	enemy.pathPending = false
	enemy.waypoints = nil
	enemy.target = nil
	enemy.attackers = nil
	enemy.aggroUntil = 0
	enemy.lastAttacker = nil
	enemy.provokedBy, enemy.provokeUntil = nil, nil
	enemy.defenseBreakUntil = nil
	enemy.model:SetAttribute("K0DefenseBreakUntil", nil)
	enemy.model:SetAttribute("K0ProvokeUntil", nil)
	enemy.pattern = 0
	enemy.posture = enemy.config.posture
	enemy.postureImmuneUntil = 0
	enemy.gravityUntil, enemy.gravityMultiplier = nil, nil
	enemy.humanoid.WalkSpeed = enemy.config.walkSpeed
	enemy.model:SetAttribute("K0GravityUntil", nil)
	enemy.humanoid.Health = enemy.humanoid.MaxHealth
	enemy.model:SetAttribute("K0Posture", enemy.posture)
	enemy.model:PivotTo(enemy.spawnPivot)
	stopEnemy(enemy)
	setEnemyState(enemy, "Idle")
end

local function stepEnemy(enemy, current, dt)
	if not enemyAlive(enemy) then
		return
	end
	if enemy.gravityUntil and current >= enemy.gravityUntil then
		enemy.gravityUntil, enemy.gravityMultiplier = nil, nil
		enemy.humanoid.WalkSpeed = enemy.config.walkSpeed
		enemy.model:SetAttribute("K0GravityUntil", nil)
	end
	if enemy.mode == "Exposed" then
		if current >= enemy.exposedUntil then
			enemy.posture = enemy.config.posture
			enemy.model:SetAttribute("K0Posture", enemy.posture)
			enemy.postureImmuneUntil = current + Config.Enemy.PostureImmunity
			enemy.reconsiderAt = current + 0.5
			setEnemyState(enemy, "Idle")
		end
		return
	end
	if current - enemy.lastPostureDamage >= Config.Enemy.PostureDelay and enemy.posture < enemy.config.posture then
		enemy.posture = math.min(enemy.config.posture, enemy.posture + enemy.config.posture * Config.Enemy.PostureRegenFraction * math.min(dt, 0.25))
		enemy.model:SetAttribute("K0Posture", math.floor(enemy.posture * 10 + 0.5) / 10)
	end
	if enemy.attack then
		local attack = enemy.attack
		local elapsed = current - attack.started
		local definition = attack.definition
		if elapsed < definition.windup and not attack.locked then
			if enemy.target and alive(enemy.target) then
				attack.direction = horizontalUnit(enemy.target.root.Position - enemy.root.Position, attack.direction)
			end
			attack.origin = enemy.root.Position
			if elapsed >= definition.windup - 0.20 then
				attack.locked = true
			end
			enemy.model:SetAttribute("K0AttackDirection", attack.direction)
			enemy.model:SetAttribute("K0AttackOrigin", attack.origin)
			enemy.root.CFrame = CFrame.lookAt(enemy.root.Position, enemy.root.Position + attack.direction)
		end
		local phase = Rules.phase(elapsed, definition)
		if phase == "Windup" then
			setEnemyState(enemy, "Windup")
		elseif phase == "Active" then
			setEnemyState(enemy, "Active")
		elseif elapsed < definition.windup + definition.active + definition.recovery + attack.extraRecovery then
			setEnemyState(enemy, "Recovery")
			enemy.model:SetAttribute("K0Telegraph", "None")
		else
			resetEnemyAttack(enemy)
			enemy.reconsiderAt = current + (enemy.kind == "Ogre" and Config.Enemy.OgreReconsider or 0)
			setEnemyState(enemy, "Idle")
		end
		return
	end
	local target, distance = closestTarget(enemy, current)
	if not target or horizontal(enemy.root.Position - enemy.spawnPosition).Magnitude > enemy.config.leashRange then
		enemy.target = nil
		if horizontal(enemy.root.Position - enemy.spawnPosition).Magnitude > 2 then
			setEnemyState(enemy, "Chase")
			moveEnemy(enemy, enemy.spawnPosition, current)
		else
			if enemy.humanoid.Health < enemy.humanoid.MaxHealth and current >= (enemy.aggroUntil or 0) then
				resetEnemy(enemy)
			else
				if enemy.mode ~= "Idle" then stopEnemy(enemy) end
				setEnemyState(enemy, "Idle")
			end
		end
		return
	end
	enemy.target = target
	local maxRange = enemy.config.attacks[1].range
	local canSee = unobstructed(enemy.root.Position, target.root.Position, enemy.model, target.character)
	if distance <= maxRange * 0.92 and canSee and current >= enemy.reconsiderAt
		and (enemy.kind ~= "Goblin" or current >= lastGoblinStart + Config.Enemy.GoblinStartSpacing) then
		beginEnemyAttack(enemy, target, current)
	else
		setEnemyState(enemy, "Chase")
		moveEnemy(enemy, target.root.Position, current)
	end
end

local registerEnemy

local function scheduleEnemyRespawn(enemy)
	if enemy.respawnScheduled then return end
	enemy.respawnScheduled = true
	task.delay(enemy.config.respawnTime, function()
		local model = enemy.model
		if enemyStates[model] ~= enemy or not enemyFolder or not enemyFolder.Parent then return end
		enemyStates[model] = nil
		model:Destroy()
		local replacement = enemy.template:Clone()
		replacement:PivotTo(enemy.spawnPivot)
		replacement.Parent = enemyFolder
		registerEnemy(replacement, enemy.template, enemy.spawnPivot, enemy.id)
	end)
end

local function retireSplitChild(enemy)
	if enemy.retired then return end
	enemy.retired = true
	enemyStates[enemy.model] = nil
	enemy.pathToken = enemy.pathToken + 1
	local group = enemy.splitGroup
	group.remaining = math.max(0, group.remaining - 1)
	local model = enemy.model
	task.delay(0.35, function() if model.Parent then model:Destroy() end end)
	if group.remaining == 0 and not group.creating then scheduleEnemyRespawn(group.parent) end
end

local function splitSlime(enemy)
	local settings = Config.SlimeSplit
	local lethalHitSet = enemy.lethalHitSet
	enemy.lethalHitSet = nil
	local group = {
		parent = enemy, remaining = 0, creating = true,
		childHealth = math.max(1, math.floor(enemy.humanoid.MaxHealth * settings.healthMultiplier + 0.5)),
	}
	local parentPosition = enemy.root.Position
	local forward = horizontalUnit(enemy.root.CFrame.LookVector, Vector3.new(0, 0, -1))
	local right = Vector3.new(-forward.Z, 0, forward.X)
	local parentFoot = enemy.root.Size.Y * 1.5
	for index = 1, settings.count do
		local child, counted
		local ok, err = pcall(function()
			child = enemy.template:Clone()
			child.Name = "SmallSlime"
			child:SetAttribute("SlimeSplitGeneration", 1)
			if lethalHitSet then lethalHitSet[child] = true end
			child:ScaleTo(settings.sizeMultiplier)
			for _, name in ipairs({ "TdMonsterTargetHeight", "TdMonsterVisualMultiplier", "TdMonsterScale" }) do
				local value = child:GetAttribute(name)
				if type(value) == "number" then child:SetAttribute(name, value * settings.sizeMultiplier) end
			end
			local root = assert(child:FindFirstChild("HumanoidRootPart"))
			local side = index == 1 and -1 or 1
			local position = parentPosition + right * side * math.max(0.6, root.Size.X * 1.2)
				+ Vector3.new(0, -parentFoot + root.Size.Y * 1.5, 0)
			local pivot = CFrame.lookAt(position, position + forward)
			child:PivotTo(pivot)
			child.Parent = enemyFolder
			group.remaining = group.remaining + 1
			counted = true
			local registered = registerEnemy(child, enemy.template, pivot, nil, group)
			if not registered then
				group.remaining = group.remaining - 1
				counted = false
				child:Destroy()
			end
		end)
		if not ok then
			if child then
				local partial = enemyStates[child]
				if partial then partial.retired = true; enemyStates[child] = nil end
				if counted then group.remaining = math.max(0, group.remaining - 1) end
				child:Destroy()
			end
			warn("K0 could not create a split slime: " .. tostring(err))
		end
	end
	group.creating = false
	if group.remaining == 0 then scheduleEnemyRespawn(enemy) end
end

registerEnemy = function(model, savedTemplate, savedPivot, savedId, splitGroup)
	local kind = model:GetAttribute("EnemyKind")
	local config = Config.Enemy[kind]
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not config or not humanoid or not root or not root:IsA("BasePart") then
		warn("K0 skipped enemy without a supported kind, Humanoid or HumanoidRootPart:", model:GetFullName())
		return nil
	end
	local spawnPivot = savedPivot or model:GetPivot()
	local template = savedTemplate or model:Clone()
	if not savedId then
		nextEnemyId = nextEnemyId + 1
		savedId = nextEnemyId
	end
	local enemy = {
		id = savedId, model = model, kind = kind, config = config, humanoid = humanoid, root = root,
		spawnPivot = spawnPivot, spawnPosition = root.Position, template = template, mode = "", attack = nil, attackSeq = 0,
		posture = config.posture, postureImmuneUntil = 0, lastPostureDamage = now(), lastPerfectResponse = -math.huge,
		pattern = 0, reconsiderAt = 0, nextMoveAt = 0, nextPathAt = 0, pathToken = 0, pathPending = false,
		splitGroup = splitGroup,
	}
	enemyStates[model] = enemy
	local health = splitGroup and splitGroup.childHealth or config.health
	humanoid.MaxHealth = health
	humanoid.Health = health
	humanoid.WalkSpeed = config.walkSpeed
	if splitGroup then humanoid.DisplayName = Text.Enemy.SmallSlime end
	EnemyHealthBar.attach(model, humanoid)
	model:SetAttribute("K0Posture", config.posture)
	model:SetAttribute("K0MaxPosture", config.posture)
	model:SetAttribute("K0Telegraph", "None")
	model:SetAttribute("K0AttackSeq", 0)
	setEnemyState(enemy, "Idle")
	pcall(function() root:SetNetworkOwner(nil) end)
	if splitGroup then
		local attacker = splitGroup.parent.lastAttacker
		local expires = splitGroup.parent.aggroUntil or 0
		if attacker and alive(attacker) and expires > now() then
			enemy.attackers = { [attacker] = expires }
			enemy.aggroUntil, enemy.lastAttacker, enemy.target = expires, attacker, attacker
			setEnemyState(enemy, "Chase")
		end
		model.AncestryChanged:Connect(function()
			if not model:IsDescendantOf(enemyFolder) then retireSplitChild(enemy) end
		end)
	end
	humanoid.Died:Connect(function()
		if enemy.deathHandled then return end
		enemy.deathHandled = true
		local winner=enemy.lastAttacker
		if not splitGroup and rewardHandler and winner and playerStates[winner.player]==winner and winner.player.Parent==Players then
			-- Trial training levels; approved XP formula 8 + 2 * enemy level.
			local level=({Slime=1,Goblin=2,Orc=4,Ogre=8})[kind] or 1
			rewardHandler(winner.player,winner.heroId,8+2*level,true)
		end
		resetEnemyAttack(enemy)
		setEnemyState(enemy, "Dead")
		enemy.pathToken = enemy.pathToken + 1
		if splitGroup then
			retireSplitChild(enemy)
		elseif kind == "Slime" then
			splitSlime(enemy)
		else
			scheduleEnemyRespawn(enemy)
		end
	end)
	return enemy
end

local function setupCharacter(player, character)
	if not activePlayers[player] or player.Parent ~= Players or player.Character ~= character then return end
	local current = playerStates[player]
	if pendingCharacters[player] == character or (current and current.character == character) then return end
	pendingCharacters[player] = character
	task.spawn(function()
		-- CharacterAdded precedes the engine's actual spawn placement. Do not
		-- establish the movement baseline or enter combat before SpawnService
		-- confirms placement and the session service activates this hero/life.
		local humanoid, root, context
		while activePlayers[player] and pendingCharacters[player] == character
			and player.Parent == Players and player.Character == character do
			humanoid = character:FindFirstChildOfClass("Humanoid")
			root = character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health <= 0 then break end
			if character:GetAttribute("K0SpawnReady") == true and character:IsDescendantOf(workspace)
				and humanoid and root and root:IsA("BasePart") then
				context = readCombatContext(player, character)
				if context then break end
			end
			task.wait(0.1)
		end
		local stillPending = pendingCharacters[player] == character
		if stillPending then pendingCharacters[player] = nil end
		if not context or not stillPending or not activePlayers[player] or player.Parent ~= Players or player.Character ~= character
			or not character:IsDescendantOf(workspace) or humanoid.Health <= 0 then return end
		local classId = context.baseClassId
		local classes = heroClasses[player]
		if not classes then classes = {}; heroClasses[player] = classes end
		classes[context.heroId] = classId
		local attackProfile = Config.BasicAttackProfiles[classId]
		local current = now()
		local derived=context.growth and Growth.derived(classId,context.growth)
		local state = {
			player = player, character = character, humanoid = humanoid, root = root, mode = "",
			baseClassId = classId, attackProfile = attackProfile, attackSeq = 0, dodgeSeq = 0, arrowSeq = 0, spellSeq = 0,
			growth=context.growth, derived=derived, maxMana=derived and derived.mana or Config.MaxMana,
			mana = (derived and derived.mana>0) and derived.mana or (not derived and classId=="mage" and Config.MaxMana or nil), manaRegenAt = current,
			itemCounts = context.itemCounts or {3, 3}, equipment = context.equipment, inventoryManaged = context.inventoryManaged,
			skillSlots = context.skillSlots or {1, 2, 3, 0, 0}, slotCount = context.slotCount or 3, skillReadyAt = context.skillReadyAt or {}, setSkillReadyAt = context.setSkillReadyAt,
			heroId = context.heroId, heroEpoch = context.epoch, characterGeneration = context.characterGeneration,
			combo = 0, lastAttackFinished = -math.huge, lastDodgeStarted = -math.huge, lastGuardStarted = -math.huge,
			stunnedUntil = 0, feedbackSeq = 0, attack = nil, queued = nil, counter = nil,
			lastMotionPosition = root.Position, lastSafePivot = character:GetPivot(), lastMotionAt = current, movementBudget = Config.MovementBudget,
			tokens = Config.RemoteBurst, lastRefill = current,
		}
		playerStates[player] = state
		if state.growth then
			local sp,kp=Growth.points(state.growth)
			for key,value in pairs({K0Level=state.growth.level,K0XP=state.growth.xp,K0XPToNext=Growth.xpToNext(state.growth.level),K0StatPoints=sp,K0SkillPoints=kp}) do character:SetAttribute(key,value) end
			for i=1,3 do character:SetAttribute("K0SkillRank"..i,state.growth.mastery[i]) end
		end
		humanoid.MaxHealth = (derived and derived.health or Config.MaxHealth) + (state.equipment and state.equipment.health or 0)
		humanoid.Health = humanoid.MaxHealth
		if state.inventoryManaged then
			character:SetAttribute("TLTEquippedWeapon", state.equipment and state.equipment.weapon or "")
			character:SetAttribute("TLTEquippedOffhand", state.equipment and state.equipment.offhand or "")
			for index = 1, 2 do character:SetAttribute("K0ItemDefinition" .. index, context.itemSlots[index]) end
		end
		character:SetAttribute("K0ClassId", classId)
		character:SetAttribute("K0HeroId", context.heroId)
		character:SetAttribute("K0HeroEpoch", context.epoch)
		character:SetAttribute("K0CharacterGeneration", context.characterGeneration)
		character:SetAttribute("K0AttackProfileId", attackProfile.id)
		character:SetAttribute("K0AttackSeq", 0)
		character:SetAttribute("K0DodgeSeq", 0)
		character:SetAttribute("K0ArrowSeq", 0)
		character:SetAttribute("K0ArrowFrom", nil)
		character:SetAttribute("K0ArrowTo", nil)
		character:SetAttribute("K0ArrowVisual", nil)
		character:SetAttribute("K0SpellVisual", nil)
		character:SetAttribute("K0AttackKind", nil)
		character:SetAttribute("K0ItemCount1", state.itemCounts[1])
		character:SetAttribute("K0ItemCount2", state.itemCounts[2])
		character:SetAttribute("K0MaxMana", state.mana and state.maxMana or nil)
		character:SetAttribute("K0Mana", state.mana)
		-- Clear legacy prototype attributes if an existing character is reused.
		character:SetAttribute("K0MaxStamina", nil)
		character:SetAttribute("K0Stamina", nil)
		character:SetAttribute("K0SkillSlotCount", state.slotCount)
		character:SetAttribute("K0Sprinting", false)
		for slot = 1, 5 do
			local skill = slot <= state.slotCount and Config.Skills[classId][state.skillSlots[slot] or 0]
			character:SetAttribute("K0EquippedSkill" .. slot, skill and skill.id or "")
			character:SetAttribute("K0SkillReady" .. slot, skill and workspace:GetServerTimeNow() + math.max(0, (state.skillReadyAt[skill.id] or current) - current) or 0)
		end
		character:SetAttribute("K0Combo", 0)
		character:SetAttribute("K0AttackPhase", "None")
		character:SetAttribute("K0Invulnerable", false)
		character:SetAttribute("K0Feedback", "None")
		character:SetAttribute("K0FeedbackSeq", 0)
		setPlayerState(state, "Idle")
		humanoid.Died:Connect(function() markDead(state) end)
	end)
end

local function setupPlayer(player)
	if activePlayers[player] then
		return
	end
	activePlayers[player] = true
	player.CharacterAdded:Connect(function(character) setupCharacter(player, character) end)
	if player.Character then
		setupCharacter(player, player.Character)
	end
end

-- Resolver is supplied only by the trusted hero session server. It must return
-- nil or a non-yielding {heroId, baseClassId, epoch, characterGeneration}.
function CombatService.isSafeForEquipment(player)
	local state = playerStates[player]
	if not alive(state) or not finiteVector(state.root.Position) or state.mode ~= "Idle" or state.sprinting or now() - (state.lastEquipmentCombat or -math.huge) < 5 then return false end
	for _, enemy in pairs(enemyStates) do
		if enemyAlive(enemy) and (enemy.target == state or (enemy.root.Position - state.root.Position).Magnitude < 45) then return false end
	end
	return true
end

function CombatService.refreshEquipment(player, equipment)
	local state = playerStates[player]
	if not state or player.Character ~= state.character or not equipment then return end
	state.equipment = equipment
	local context=readCombatContext(player,state.character)
	if context and context.growth then
		state.growth=context.growth
		state.derived=Growth.derived(state.baseClassId,state.growth)
		state.maxMana=state.derived.mana
		if state.maxMana>0 then setMana(state,math.min(state.mana or 0,state.maxMana)) else state.mana=nil end
		state.character:SetAttribute("K0MaxMana",state.mana and state.maxMana or nil)
		local sp,kp=Growth.points(state.growth)
		for key,value in pairs({K0Level=state.growth.level,K0XP=state.growth.xp,K0XPToNext=Growth.xpToNext(state.growth.level),K0StatPoints=sp,K0SkillPoints=kp}) do state.character:SetAttribute(key,value) end
		for i=1,3 do state.character:SetAttribute("K0SkillRank"..i,state.growth.mastery[i]) end
	end
	local health = state.humanoid.Health
	state.humanoid.MaxHealth = (state.derived and state.derived.health or Config.MaxHealth) + equipment.health
	state.humanoid.Health = math.min(health, state.humanoid.MaxHealth)
	state.character:SetAttribute("TLTEquippedWeapon", equipment.weapon or "")
	state.character:SetAttribute("TLTEquippedOffhand", equipment.offhand or "")
	state.character:SetAttribute("TLTEquipmentPower", equipment.power)
	state.character:SetAttribute("TLTEquipmentArmor", equipment.armor)
end

function CombatService.canUseInventoryItem(player, definition)
	local state = playerStates[player]
	if not alive(state) or state.mode == "Dead" or state.mode == "Stunned" then return false, "Unavailable" end
	if definition.restore == "health" and state.humanoid.Health >= state.humanoid.MaxHealth then return false, "HealthFull", state.character end
	if definition.restore == "mana" then
		if not state.mana then return false, "NoManaPool", state.character end
		if state.mana >= (state.maxMana or Config.MaxMana) then return false, "ManaFull", state.character end
	end
	return true, nil, state.character
end

function CombatService.applyInventoryItem(player, definition, character)
	local state = playerStates[player]
	if not state or state.character ~= character or not alive(state) then return end
	if definition.restore == "health" then state.humanoid.Health = math.min(state.humanoid.MaxHealth, state.humanoid.Health + definition.amount)
	elseif definition.restore == "mana" and state.mana then setMana(state, state.mana + definition.amount) end
end

function CombatService.start(enemies, serverContextResolver, awardXP)
	rewardHandler=awardXP
	assert(not started, "K0 combat service already started")
	assert(enemies and enemies:IsA("Folder"), "K0 combat needs an enemy Folder")
	assert(type(serverContextResolver) == "function", "K0 combat needs a server hero context resolver")
	contextResolver = serverContextResolver
	started = true
	enemyFolder = enemies
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end
	assert(remotes:IsA("Folder"), "ReplicatedStorage.Remotes must be a Folder")
	advancedEffectRemote=Instance.new("RemoteEvent");advancedEffectRemote.Name="K0AdvancedEffect";advancedEffectRemote.Parent=remotes
	local actionRemote = remotes:FindFirstChild("K0Action")
	if not actionRemote then
		actionRemote = Instance.new("RemoteEvent")
		actionRemote.Name = "K0Action"
		actionRemote.Parent = remotes
	end
	assert(actionRemote:IsA("RemoteEvent"), "K0Action must be a RemoteEvent")
	hitEffectRemote = remotes:FindFirstChild("K0HitEffect")
	if not hitEffectRemote then
		hitEffectRemote = Instance.new("RemoteEvent")
		hitEffectRemote.Name = "K0HitEffect"
		hitEffectRemote.Parent = remotes
	end
	assert(hitEffectRemote:IsA("RemoteEvent"), "K0HitEffect must be a RemoteEvent")
	for _, model in ipairs(enemies:GetChildren()) do
		if model:IsA("Model") then
			registerEnemy(model)
		end
	end
	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		activePlayers[player] = nil
		heroClasses[player] = nil
		pendingCharacters[player] = nil
		local state = playerStates[player]
		if state then
			clearAction(state)
			playerStates[player] = nil
		end
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		setupPlayer(player)
	end
	actionRemote.OnServerEvent:Connect(function(player, action, direction, targetModel, ...)
		local state = playerStates[player]
		if not state or not alive(state) or type(action) ~= "string" or #action > 16 or select("#", ...) > 0 or not validDirection(direction) then
			return
		end
		if action ~= "Attack" and action ~= "Dodge" and action ~= "BlockStart" and action ~= "BlockEnd" and action ~= "CastArcane" and action ~= "SprintStart" and action ~= "SprintEnd" and action ~= "Item1" and action ~= "Item2" and not action:match("^Skill[12345]$") then
			return
		end
		if targetModel ~= nil then
			if typeof(targetModel) ~= "Instance" or not enemyStates[targetModel]
				or not (action == "Attack" or action:match("^Skill[12345]$") or (action == "CastArcane" and state.baseClassId == "mage")) then return end
		end
		local current = now()
		-- Releasing guard is always safe and must not be dropped after a burst.
		if action == "BlockEnd" or action == "SprintEnd" then
			if state.mode == "Block" or (state.queued and state.queued.action == "BlockStart") then
				processCombatSamples(current, state)
			end
			acceptAction(state, action, direction, current, targetModel)
			return
		end
		state.tokens = math.min(Config.RemoteBurst, state.tokens + math.max(0, current - state.lastRefill) * Config.RemoteRefillPerSecond)
		state.lastRefill = current
		if state.tokens < 1 then
			return
		end
		state.tokens = state.tokens - 1
		local validPlayers = processCombatSamples(current, state)
		if not validPlayers[state] or not alive(state) then
			return
		end
		-- A valid higher-priority new intent may replace a due buffered one.
		-- Lower/equal repeated input cannot preempt an already due intent.
		local queued = state.queued
		if queued and Rules.bufferCanExecute(current, queued.eligibleAt, queued.expires)
			and Rules.priority(action) > Rules.priority(queued.action) and resourceReady(state, action, current)
			and current >= actionEligibleAt(state, action, current) then
			state.queued = nil
		end
		local consumed = stepPlayer(state, current, 0, true)
		if consumed and Rules.priority(action) <= Rules.priority(consumed) then
			return
		end
		acceptAction(state, action, direction, current, targetModel)
	end)
	RunService.Heartbeat:Connect(function(dt)
		local current = now()
		local validPlayers = processCombatSamples(current)
		local living = 0
		for _, state in pairs(playerStates) do
			if validPlayers[state] ~= false then
				stepPlayer(state, current, dt, validPlayers[state] == true)
			end
			if alive(state) then
				living = living + 1
			end
		end
		if living > 0 then
			hadLivingPlayer = true
		elseif hadLivingPlayer then
			hadLivingPlayer = false
			for _, enemy in pairs(enemyStates) do
				if enemy.splitGroup then retireSplitChild(enemy) else resetEnemy(enemy) end
			end
		end
		for _, enemy in pairs(enemyStates) do
			stepEnemy(enemy, current, dt)
		end
	end)
end

return CombatService
