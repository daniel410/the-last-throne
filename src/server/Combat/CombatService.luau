-- Deepwood K0 prototype. The server owns action timing, resources and damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local Config = require(ReplicatedStorage.Shared.K0Config)
local Rules = require(script.Parent.K0Rules)

local CombatService = {}
local started = false
local playerStates = {}
local enemyStates = {}
local enemyFolder
local lastGoblinStart = -math.huge
local hadLivingPlayer = false
local nextEnemyId = 0

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

local function unobstructed(first, second, excludeA, excludeB)
	local delta = second - first
	if delta.Magnitude < 0.01 then
		return true
	end
	local exclusions = { excludeA, excludeB }
	-- Combatants do not count as wall cover for other combatants.
	if enemyFolder then table.insert(exclusions, enemyFolder) end
	for _, state in pairs(playerStates) do
		if state.character.Parent then table.insert(exclusions, state.character) end
	end
	return workspace:Raycast(first, delta, rayParams(exclusions)) == nil
end

local function updateFeedback(state, value)
	state.feedbackSeq = state.feedbackSeq + 1
	state.character:SetAttribute("K0Feedback", value)
	state.character:SetAttribute("K0FeedbackSeq", state.feedbackSeq)
end

local function setStamina(state, value)
	state.stamina = math.max(0, math.min(Config.MaxStamina, value))
	state.character:SetAttribute("K0Stamina", math.floor(state.stamina * 10 + 0.5) / 10)
end

local function spendStamina(state, amount, current, regenDelay)
	setStamina(state, state.stamina - amount)
	state.regenAt = current + (regenDelay or Config.StaminaRegenDelay)
end

local function setPlayerState(state, name)
	if state.mode == name then
		return
	end
	state.mode = name
	state.character:SetAttribute("K0State", name)
	local speed = Config.WalkSpeed
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

local function clearAction(state)
	releaseDodgeOwnership(state)
	state.attack = nil
	state.dodge = nil
	state.guardStarted = nil
	state.character:SetAttribute("K0AttackPhase", "None")
	state.character:SetAttribute("K0Invulnerable", false)
end

local function resetCombo(state)
	state.combo = 0
	state.character:SetAttribute("K0Combo", 0)
end

local function alive(state)
	return state and state.player.Parent == Players and state.player.Character == state.character
		and state.character.Parent ~= nil and state.humanoid.Health > 0 and state.root.Parent ~= nil
end

local function markDead(state)
	if state.mode == "Dead" then
		return
	end
	state.queued = nil
	state.counter = nil
	clearAction(state)
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

local function startAttack(state, current)
	if state.attack then
		local previous = state.attack
		local previousEnd = previous.started + previous.definition.windup + previous.definition.active + previous.definition.recovery
		if current >= previousEnd then
			state.lastAttackFinished = previousEnd
		end
	end
	local nextCombo = 1
	if state.combo > 0 and current - state.lastAttackFinished <= Config.ComboReset then
		nextCombo = state.combo % 3 + 1
	end
	clearAction(state)
	state.queued = nil
	state.combo = nextCombo
	state.character:SetAttribute("K0Combo", nextCombo)
	state.attack = {
		started = current,
		definition = Config.Attacks[nextCombo],
		direction = horizontalUnit(state.root.CFrame.LookVector, Vector3.new(0, 0, -1)),
		hits = {},
		hitCount = 0,
		counterDamage = nil,
	}
	setPlayerState(state, "Attack")
	state.character:SetAttribute("K0AttackPhase", "Windup")
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
	spendStamina(state, Config.Guard.initialCost, current)
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
	spendStamina(state, Config.Dodge.cost, current)
	setPlayerState(state, "Dodge")
	updateFeedback(state, "ActionStarted")
end

local function resourceReady(state, action, current)
	if action == "Dodge" then
		return state.stamina >= Config.Dodge.cost and current >= state.lastDodgeStarted + Config.Dodge.cooldown
	elseif action == "BlockStart" then
		return state.stamina >= Config.Guard.initialCost and current >= state.lastGuardStarted + Config.Guard.cooldown
	end
	return action == "Attack"
end

local function executeAction(state, action, direction, current)
	if action == "Attack" then
		startAttack(state, current)
	elseif action == "BlockStart" then
		startGuard(state, current)
	elseif action == "Dodge" then
		startDodge(state, direction, current)
	end
end

local function acceptAction(state, action, direction, current)
	if not alive(state) or state.mode == "Dead" or state.mode == "Stunned" then
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
	if action ~= "Attack" and action ~= "Dodge" and action ~= "BlockStart" then
		return
	end
	if action == "BlockStart" and state.mode == "Block" then
		return
	end
	if not resourceReady(state, action, current) then
		return
	end
	if state.mode == "Idle" or state.mode == "Block" then
		executeAction(state, action, direction, current)
		return
	end
	local eligibleAt = math.huge
	if state.mode == "Attack" and state.attack then
		eligibleAt = state.attack.started + Rules.nextAllowedInAttack(action, state.attack.definition)
	elseif state.mode == "Dodge" and state.dodge then
		eligibleAt = state.dodge.started + Config.Dodge.duration
	end
	if current >= eligibleAt then
		executeAction(state, action, direction, current)
	elseif eligibleAt - current <= Config.InputBuffer then
		-- A held button cannot extend the lifetime of a previous buffered input.
		if not state.queued or Rules.priority(action) > Rules.priority(state.queued.action) then
			state.queued = { action = action, direction = direction, expires = current + Config.InputBuffer }
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
	local result, multiplier, remaining = Rules.defense(
		playerState.mode == "Dodge", playerState.dodge and current - playerState.dodge.started or -1,
		playerState.mode == "Block", playerState.guardStarted and current - playerState.guardStarted or -1,
		guardDot, attack.definition.blockable, playerState.stamina, attack.definition.guardCost, Config.Guard, Config.Dodge
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
		setStamina(playerState, remaining)
		playerState.regenAt = current + Config.StaminaRegenDelay
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
		if result == "GuardBroken" then
			setStamina(playerState, 0)
			playerState.regenAt = current + Config.GuardBreakRegenDelay
			playerState.stunnedUntil = current + Config.Guard.breakStun
		else
			playerState.stunnedUntil = current + Config.HitStun
		end
		setPlayerState(playerState, "Stunned")
		updateFeedback(playerState, result == "GuardBroken" and "GuardBroken" or "Interrupted")
	end
	local damage = math.max(1, math.floor(attack.definition.damage * multiplier + 0.5))
	playerState.humanoid:TakeDamage(damage)
	if playerState.humanoid.Health <= 0 then
		markDead(playerState)
	end
end

local function applySwordHits(state, current)
	local attack = state.attack
	if not attack or attack.hitCount >= Config.AttackMaxTargets then
		return
	end
	local origin = state.root.Position
	local candidates = {}
	for _, enemy in pairs(enemyStates) do
		if enemyAlive(enemy) and not attack.hits[enemy.model] then
			local position = enemy.root.Position
			local distance = horizontal(position - origin).Magnitude
			local dot = facingDot(origin, attack.direction, position)
			if Rules.withinCone(distance, math.abs(position.Y - origin.Y), dot, attack.definition.range, Config.AttackHeight, attack.definition.angle)
				and unobstructed(origin, position, state.character, enemy.model) then
				table.insert(candidates, { enemy = enemy, distance = distance })
			end
		end
	end
	table.sort(candidates, function(left, right)
		if left.distance == right.distance then
			return left.enemy.id < right.enemy.id
		end
		return left.distance < right.distance
	end)
	for _, candidate in ipairs(candidates) do
		if attack.hitCount >= Config.AttackMaxTargets then
			break
		end
		local enemy = candidate.enemy
		attack.hits[enemy.model] = true
		attack.hitCount = attack.hitCount + 1
		if attack.counterDamage == nil then
			attack.counterDamage = 0
			if state.counter and state.counter.expires > current then
				attack.counterDamage = state.counter.bonus
				state.counter = nil
			end
		end
		local multiplier = enemy.mode == "Exposed" and 1.15 or 1
		local damage = math.max(1, math.floor(Config.AttackPower * (attack.definition.damage + attack.counterDamage) * multiplier + 0.5))
		enemy.humanoid:TakeDamage(damage)
		if enemy.humanoid.Health > 0 then
			damagePosture(enemy, attack.definition.posture, current)
		end
		updateFeedback(state, "Hit")
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
			dodge.moved = dodge.moved + distance
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
		local permitted, remaining = Rules.movementBudget(state.movementBudget, elapsed, travelled, Config.WalkSpeed, Config.MovementBudget)
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

local function stepPlayer(state, current, dt)
	if not alive(state) then
		markDead(state)
		return
	end
	if not checkMovement(state, current) then
		return
	end
	if state.mode == "Attack" and state.attack then
		local attack = state.attack
		local phase = Rules.phase(current - attack.started, attack.definition)
		state.character:SetAttribute("K0AttackPhase", phase)
		if phase == "Active" then
			applySwordHits(state, current)
		elseif phase == "None" then
			state.lastAttackFinished = attack.started + attack.definition.windup + attack.definition.active + attack.definition.recovery
			state.attack = nil
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
	if state.queued then
		local queued = state.queued
		if current >= queued.expires or not resourceReady(state, queued.action, current) then
			state.queued = nil
		else
			local isReady = state.mode == "Idle" or state.mode == "Block"
			if state.mode == "Attack" and state.attack then
				isReady = Rules.allowedInAttack(queued.action, current - state.attack.started, state.attack.definition)
			end
			if isReady then
				state.queued = nil
				executeAction(state, queued.action, queued.direction, current)
			end
		end
	end
	if current >= state.regenAt and state.mode ~= "Block" and state.mode ~= "Dead" then
		setStamina(state, state.stamina + Config.StaminaRegen * math.min(dt, 0.25))
	end
end

local function closestTarget(enemy)
	local closest, closestDistance
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
			local path = PathfindingService:CreatePath({ AgentRadius = enemy.kind == "Ogre" and 3 or 2, AgentHeight = enemy.kind == "Ogre" and 7 or 5, AgentCanJump = false, WaypointSpacing = 5 })
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
	else
		lastGoblinStart = current
	end
	local definition = enemy.config.attacks[attackIndex]
	local direction = horizontalUnit(target.root.Position - enemy.root.Position, enemy.root.CFrame.LookVector)
	enemy.attack = { definition = definition, started = current, direction = direction, origin = enemy.root.Position, hits = {}, locked = false, extraRecovery = 0 }
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
	enemy.pattern = 0
	enemy.posture = enemy.config.posture
	enemy.postureImmuneUntil = 0
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
			for _, playerState in pairs(playerStates) do
				applyPlayerHit(enemy, playerState, attack, current)
				if enemy.attack ~= attack then
					break
				end
			end
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
	local target, distance = closestTarget(enemy)
	if not target or horizontal(enemy.root.Position - enemy.spawnPosition).Magnitude > enemy.config.leashRange then
		enemy.target = nil
		if horizontal(enemy.root.Position - enemy.spawnPosition).Magnitude > 2 then
			setEnemyState(enemy, "Chase")
			moveEnemy(enemy, enemy.spawnPosition, current)
		else
			if enemy.humanoid.Health < enemy.humanoid.MaxHealth then
				resetEnemy(enemy)
			else
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

local function registerEnemy(model, savedTemplate, savedPivot, savedId)
	local kind = model:GetAttribute("EnemyKind")
	local config = Config.Enemy[kind]
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not config or not humanoid or not root or not root:IsA("BasePart") then
		warn("K0 skipped enemy without a supported kind, Humanoid or HumanoidRootPart:", model:GetFullName())
		return
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
	}
	enemyStates[model] = enemy
	humanoid.MaxHealth = config.health
	humanoid.Health = config.health
	humanoid.WalkSpeed = config.walkSpeed
	model:SetAttribute("K0Posture", config.posture)
	model:SetAttribute("K0MaxPosture", config.posture)
	model:SetAttribute("K0Telegraph", "None")
	model:SetAttribute("K0AttackSeq", 0)
	setEnemyState(enemy, "Idle")
	pcall(function() root:SetNetworkOwner(nil) end)
	humanoid.Died:Connect(function()
		resetEnemyAttack(enemy)
		setEnemyState(enemy, "Dead")
		enemy.pathToken = enemy.pathToken + 1
		task.delay(config.respawnTime, function()
			if enemyStates[model] ~= enemy or not enemyFolder.Parent then
				return
			end
			enemyStates[model] = nil
			model:Destroy()
			local replacement = template:Clone()
			replacement:PivotTo(spawnPivot)
			replacement.Parent = enemyFolder
			registerEnemy(replacement, template, spawnPivot, enemy.id)
		end)
	end)
end

local function setupCharacter(player, character)
	task.spawn(function()
		-- CharacterAdded precedes the engine's actual spawn placement. Do not
		-- establish the movement baseline or enter combat before SpawnService
		-- has confirmed the new life at the safe spawn.
		while player.Parent == Players and player.Character == character and character:GetAttribute("K0SpawnReady") ~= true do
			task.wait(0.1)
		end
		if player.Parent ~= Players or player.Character ~= character or not character:IsDescendantOf(workspace) then
			return
		end
		local humanoid = character:WaitForChild("Humanoid", 10)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if not humanoid or not root or not humanoid:IsA("Humanoid") or not root:IsA("BasePart")
			or player.Parent ~= Players or player.Character ~= character or not character:IsDescendantOf(workspace)
			or humanoid.Health <= 0 then
			return
		end
		local current = now()
		local state = {
			player = player, character = character, humanoid = humanoid, root = root, mode = "", stamina = Config.MaxStamina,
			combo = 0, lastAttackFinished = -math.huge, lastDodgeStarted = -math.huge, lastGuardStarted = -math.huge,
			regenAt = current, stunnedUntil = 0, feedbackSeq = 0, attack = nil, queued = nil, counter = nil,
			lastMotionPosition = root.Position, lastSafePivot = character:GetPivot(), lastMotionAt = current, movementBudget = Config.MovementBudget,
			tokens = Config.RemoteBurst, lastRefill = current,
		}
		playerStates[player] = state
		humanoid.MaxHealth = Config.MaxHealth
		humanoid.Health = Config.MaxHealth
		character:SetAttribute("K0MaxStamina", Config.MaxStamina)
		character:SetAttribute("K0Stamina", Config.MaxStamina)
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
	player.CharacterAdded:Connect(function(character) setupCharacter(player, character) end)
	if player.Character then
		setupCharacter(player, player.Character)
	end
end

function CombatService.start(enemies)
	assert(not started, "K0 combat service already started")
	assert(enemies and enemies:IsA("Folder"), "K0 combat needs an enemy Folder")
	started = true
	enemyFolder = enemies
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end
	assert(remotes:IsA("Folder"), "ReplicatedStorage.Remotes must be a Folder")
	local actionRemote = remotes:FindFirstChild("K0Action")
	if not actionRemote then
		actionRemote = Instance.new("RemoteEvent")
		actionRemote.Name = "K0Action"
		actionRemote.Parent = remotes
	end
	assert(actionRemote:IsA("RemoteEvent"), "K0Action must be a RemoteEvent")
	for _, model in ipairs(enemies:GetChildren()) do
		if model:IsA("Model") then
			registerEnemy(model)
		end
	end
	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		local state = playerStates[player]
		if state then
			clearAction(state)
			playerStates[player] = nil
		end
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		setupPlayer(player)
	end
	actionRemote.OnServerEvent:Connect(function(player, action, direction, ...)
		local state = playerStates[player]
		if not state or not alive(state) or type(action) ~= "string" or #action > 16 or select("#", ...) > 0 or not validDirection(direction) then
			return
		end
		local current = now()
		-- Releasing guard is always safe and must not be dropped after a burst.
		if action == "BlockEnd" then
			acceptAction(state, action, direction, current)
			return
		end
		state.tokens = math.min(Config.RemoteBurst, state.tokens + math.max(0, current - state.lastRefill) * Config.RemoteRefillPerSecond)
		state.lastRefill = current
		if state.tokens < 1 then
			return
		end
		state.tokens = state.tokens - 1
		if checkMovement(state, current) then
			acceptAction(state, action, direction, current)
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		local current = now()
		local living = 0
		for _, state in pairs(playerStates) do
			stepPlayer(state, current, dt)
			if alive(state) then
				living = living + 1
			end
		end
		if living > 0 then
			hadLivingPlayer = true
		elseif hadLivingPlayer then
			hadLivingPlayer = false
			for _, enemy in pairs(enemyStates) do
				resetEnemy(enemy)
			end
		end
		for _, enemy in pairs(enemyStates) do
			stepEnemy(enemy, current, dt)
		end
	end)
end

return CombatService
