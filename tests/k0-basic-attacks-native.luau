-- Isolated Roblox engine test of the actual CombatService local functions and
-- original RemoteEvent/Heartbeat callbacks. The only source transformation is
-- the final return, exposing private state and a server resolver for fixtures.
-- No real player, RemoteEvent transport, client animation or network is tested.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "Basic attack QA requires an empty isolated local place")
assert(not workspace:FindFirstChild("K0BasicAttackQaFixture"), "Basic attack QA fixture already exists")
local production = assert(ServerScriptService:FindFirstChild("Server"))
production = assert(production:FindFirstChild("Combat")):FindFirstChild("CombatService")
assert(production, "K0 CombatService missing")
local report = { kind = "K0_BASIC_ATTACK_NATIVE", checks = 0, cases = {}, failures = {},
	coverage = "Actual server service/callback code, identity mocks, native rig/physics, synthetic clock; no transport, real player or client animation" }
local api, privateModule, fixture, characters, enemies, startedRun
local origin = Vector3.new(20000, 1000, 20000)
local nextId = 0

local function equal(actual, expected, label)
	report.checks += 1
	assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function near(actual, expected, label)
	report.checks += 1
	assert(math.abs(actual - expected) < 0.000001, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function waitFor(predicate, label)
	local deadline = os.clock() + 3
	while not predicate() and os.clock() < deadline do task.wait() end
	assert(predicate(), "Timed out: " .. label)
end
local function reset()
	if api then
		for _, state in pairs(api.playerStates) do api.clearAction(state) end
		table.clear(api.playerStates)
		table.clear(api.enemyStates)
		table.clear(api.activePlayers)
		table.clear(api.heroClasses)
		table.clear(api.pendingCharacters)
		api.setClock(0)
		api.setHitEffectRemote(nil)
	end
	if characters then characters:ClearAllChildren() end
	if enemies then enemies:ClearAllChildren() end
	if fixture then
		local wall = fixture:FindFirstChild("Wall")
		if wall then wall:Destroy() end
	end
end
local function case(name, body)
	reset()
	local before = report.checks
	local ok, err = xpcall(body, debug.traceback)
	table.insert(report.cases, { id = name, pass = ok, checks = report.checks - before, error = not ok and tostring(err) or nil })
	if not ok then table.insert(report.failures, name .. ": " .. tostring(err)) end
end
local function rig(name, parent, position, direction)
	local model = Instance.new("Model")
	model.Name = name
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = CFrame.lookAt(position, position + direction)
	root.Anchored = true
	root.CanCollide = false
	root.Parent = model
	model.PrimaryPart = root
	local humanoid = Instance.new("Humanoid")
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.MaxHealth = 10000
	humanoid.Health = 10000
	humanoid.Parent = model
	model.Parent = parent
	return model, humanoid, root
end
local function spawnPlayer(player, legacyResourceAttributes)
	local model = rig("MockCharacter", characters, origin, Vector3.new(0, 0, -1))
	if legacyResourceAttributes then
		model:SetAttribute("K0Stamina", 0)
		model:SetAttribute("K0MaxStamina", 100)
	end
	model:SetAttribute("K0SpawnReady", true)
	if not player then
		nextId += 1
		player = { Parent = Players, UserId = -nextId }
	end
	player.Character = model
	api.activePlayers[player] = true
	api.setupCharacter(player, model)
	waitFor(function()
		local state = api.playerStates[player]
		return state and state.character == model
	end, "server character setup")
	return api.playerStates[player], player
end
local function spawnEnemy(distance, kind)
	kind = kind or "Goblin"
	local model, humanoid, root = rig(kind, enemies, origin + Vector3.new(0, 0, -(distance or 3)), Vector3.new(0, 0, 1))
	local config = api.Config.Enemy[kind]
	local state = { id = 1, model = model, humanoid = humanoid, root = root, kind = kind, config = config,
		mode = "Idle", posture = config.posture, postureImmuneUntil = 0, lastPostureDamage = 0,
		lastPerfectResponse = -math.huge, pattern = 0, attackSeq = 0, pathToken = 0,
		pathPending = false, nextMoveAt = math.huge, nextPathAt = math.huge, reconsiderAt = math.huge,
		spawnPosition = root.Position, spawnPivot = model:GetPivot() }
	api.enemyStates[model] = state
	return state
end
local function action(state, name, time, direction, ...)
	api.setClock(time)
	api.remote(state.player, name, direction, ...)
end
local function sample(time)
	api.setClock(time)
	api.processCombatSamples(time)
end

local ok, fatal = xpcall(function()
	local original = production.Source
	local remoteExpression = assert(original:match("actionRemote%.OnServerEvent:Connect%((function.-\n\tend)%)\n\tRunService%.Heartbeat:Connect"), "remote callback boundary missing")
	local heartbeatExpression = assert(original:match("RunService%.Heartbeat:Connect%((function.-\n\tend)%)\nend%s+return CombatService%s*$"), "heartbeat callback boundary missing")
	local tail = "\nlocal qaRemote=" .. remoteExpression .. "\nlocal qaHeartbeat=" .. heartbeatExpression .. "\n" .. [[
return {
 Config=Config, playerStates=playerStates, enemyStates=enemyStates, activePlayers=activePlayers, heroClasses=heroClasses, pendingCharacters=pendingCharacters,
 setEnemyFolder=function(value) enemyFolder=value end,
 setHitEffectRemote=function(value) hitEffectRemote=value end,
 setClock=function(value) now=function() return value end end,
 injectResolver=function(value)
   contextResolver=function(player, character)
     local resolved=value(player, character)
     if type(resolved)=="string" then
       return { heroId="hero-" .. player.UserId, baseClassId=resolved, epoch=1, characterGeneration=1 }
     end
     return resolved
   end
 end,
 setupCharacter=setupCharacter, readCombatContext=readCombatContext,
 clearAction=clearAction, processCombatSamples=processCombatSamples, stepPlayer=stepPlayer, stepEnemy=stepEnemy, closestTarget=closestTarget,
 start=CombatService.start, startAttack=startAttack, beginEnemyAttack=beginEnemyAttack, registerEnemy=registerEnemy,
 refreshEquipment=CombatService.refreshEquipment, canUseInventoryItem=CombatService.canUseInventoryItem, applyInventoryItem=CombatService.applyInventoryItem,
 remote=qaRemote, heartbeat=qaHeartbeat
}
]]
	local instrumented, replacements = original:gsub("\nreturn CombatService%s*$", function() return tail end)
	assert(replacements == 1, "test may replace only final return")
	privateModule = Instance.new("ModuleScript")
	privateModule.Name = "K0BasicAttackQaPrivate"
	privateModule.Source = instrumented
	privateModule.Parent = production.Parent
	api = require(privateModule)
	fixture = Instance.new("Folder")
	fixture.Name = "K0BasicAttackQaFixture"
	fixture.Parent = workspace
	characters = Instance.new("Folder")
	characters.Name = "Characters"
	characters.Parent = fixture
	enemies = Instance.new("Folder")
	enemies.Name = "Enemies"
	enemies.Parent = fixture
	api.setEnemyFolder(enemies)
	if not RunService:IsRunning() then RunService:Run(); startedRun = true end

	case("server-selected-knight-and-forged-client-class", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy()
		equal(state.baseClassId, "knight", "server resolver class")
		equal(state.character:GetAttribute("K0ClassId"), "knight", "replicated class")
		equal(state.character:GetAttribute("K0AttackProfileId"), "knight.sword.basic", "replicated profile")
		state.character:SetAttribute("K0ClassId", "mage")
		state.character:SetAttribute("K0AttackProfileId", "mage.staff.basic")
		action(state, "Attack", 0, "mage")
		equal(state.attack, nil, "forged direction rejected")
		action(state, "Attack", 0, nil, "mage")
		equal(state.attack, nil, "extra class argument rejected")
		action(state, "Attack", 0)
		equal(state.attack.definition, api.Config.Attacks[1], "replicated claim cannot change Knight attack")
		sample(0.17)
		near(enemy.humanoid.Health, 9925, "Knight first hit remains 75")
	end)

	case("knight-can-hit-low-slime-once", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3, "Slime")
		local target = origin + Vector3.new(0, -1.6, -3)
		enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
		action(state, "Attack", 0)
		sample(0.17)
		near(enemy.humanoid.Health, 9925, "a low Slime receives the server-authoritative sword hit")
		sample(0.20)
		near(enemy.humanoid.Health, 9925, "the same sword window cannot hit Slime twice")
	end)
	case("inventory-equipment-projection-preserves-health-and-cooldowns", function()
		api.injectResolver(function(player)
			return {heroId="hero-"..player.UserId,baseClassId="knight",epoch=1,characterGeneration=1,inventoryManaged=true,
				equipment={power=0,armor=0,health=100,weapon="knight_weapon",offhand="knight_shield"},itemCounts={3,3},itemSlots={"health_potion","mana_potion"}}
		end)
		local state=spawnPlayer()
		equal(state.humanoid.MaxHealth,1100,"equipped HP bonus applied at spawn")
		state.humanoid.Health=500
		state.skillReadyAt["knight.common.whirlwind"]=20
		api.refreshEquipment(state.player,{power=10,armor=4,health=40,weapon="knight_weapon_fine",offhand="knight_shield"})
		equal(state.humanoid.MaxHealth,1040,"new maximum projected")
		equal(state.humanoid.Health,500,"changing gear never heals")
		equal(state.skillReadyAt["knight.common.whirlwind"],20,"changing gear preserves skill cooldown")
		local enemy=spawnEnemy(3,"Slime")
		action(state,"Attack",0); sample(.17)
		equal(enemy.humanoid.Health,9917,"server power bonus changes actual damage")
		action(state,"Item1",.2)
		equal(state.humanoid.Health,500,"legacy combat item route cannot grant free healing")
		equal(state.character:GetAttribute("K0Feedback"),"InventoryItemOnly","managed items require inventory transaction")
		local usable,reason=api.canUseInventoryItem(state.player,{restore="mana"})
		equal(usable,false,"knight has no mana potion target"); equal(reason,"NoManaPool","mana pool rejection")
		api.applyInventoryItem(state.player,{restore="health",amount=40},state.character)
		equal(state.humanoid.Health,540,"confirmed item effect restores only its server amount")
		api.applyInventoryItem(state.player,{restore="health",amount=40},Instance.new("Model"))
		equal(state.humanoid.Health,540,"old life cannot heal new life")
	end)
	case("unequipped-weapon-cannot-attack",function()
		api.injectResolver(function(player)
			return {heroId="hero-"..player.UserId,baseClassId="mage",epoch=1,characterGeneration=1,inventoryManaged=true,
				equipment={power=0,armor=0,health=0,weapon=false,offhand=false},itemCounts={3,3},itemSlots={"health_potion","mana_potion"}}
		end)
		local state=spawnPlayer()
		action(state,"Attack",0)
		equal(state.attack,nil,"no invisible equipped weapon attack")
		equal(state.character:GetAttribute("K0Feedback"),"EquipWeapon","equipment remedy shown")
		action(state,"Skill1",.1)
		equal(state.mana,100,"blocked unequipped spell does not cost MP")
		equal(state.skillReadyAt["mage.common.bolt"],nil,"blocked unequipped spell does not start cooldown")
	end)
	case("lethal-swing-does-not-hit-new-slime-children", function()
		for _, trial in ipairs({
			{ action = "Attack", firstSample = 0.17, laterSample = 0.20 },
			{ action = "Skill2", firstSample = 0.26, laterSample = 0.31 },
		}) do
			reset(); api.injectResolver(function() return "knight" end)
			local state = spawnPlayer()
			local model, humanoid = rig("Slime", enemies, origin + Vector3.new(0, 0, -3), Vector3.new(0, 0, 1))
			model:SetAttribute("EnemyKind", "Slime")
			assert(api.registerEnemy(model), "register production slime")
			humanoid.Health = 75
			action(state, trial.action, 0)
			local attack = assert(state.attack)
			sample(trial.firstSample)
			local children = {}
			waitFor(function()
				children = {}
				for _, child in ipairs(enemies:GetChildren()) do
					if child:GetAttribute("SlimeSplitGeneration") == 1 then table.insert(children, child) end
				end
				return #children == 2
			end, trial.action .. " creates both children")
			equal(humanoid.Health, 0, trial.action .. " kills the parent")
			sample(trial.laterSample)
			for _, child in ipairs(children) do
				near(child.Humanoid.Health, 55, trial.action .. " cannot damage a child in the same attack")
			end
			local nextStart = attack.definition.windup + attack.definition.active + attack.definition.recovery + 0.02
			action(state, "Attack", nextStart)
			local nextAttack = assert(state.attack)
			sample(nextStart + nextAttack.definition.windup + 0.01)
			local damaged = 0
			for _, child in ipairs(children) do if child.Humanoid.Health < 55 then damaged += 1 end end
			equal(damaged > 0, true, trial.action .. " does not protect children from the next attack")
		end
	end)
	case("another-player-can-hit-children-during-original-swing", function()
		api.injectResolver(function() return "knight" end)
		local first, ally = spawnPlayer(), spawnPlayer()
		local model, humanoid = rig("Slime", enemies, origin + Vector3.new(0, 0, -3), Vector3.new(0, 0, 1))
		model:SetAttribute("EnemyKind", "Slime")
		assert(api.registerEnemy(model), "register production slime")
		humanoid.Health = 75
		action(first, "Skill2", 0)
		sample(0.26)
		local children = {}
		waitFor(function()
			children = {}
			for _, child in ipairs(enemies:GetChildren()) do
				if child:GetAttribute("SlimeSplitGeneration") == 1 then table.insert(children, child) end
			end
			return #children == 2
		end, "whirlwind creates both children")
		action(ally, "Attack", 0.26)
		sample(0.31)
		for _, child in ipairs(children) do near(child.Humanoid.Health, 55, "original swing leaves child intact") end
		sample(0.425) -- ally's swing is active before the original Whirlwind ends at 0.43
		local damaged = 0
		for _, child in ipairs(children) do if child.Humanoid.Health < 55 then damaged += 1 end end
		equal(damaged > 0, true, "a separate player's attack can damage the children immediately")
	end)
	case("rapid-fire-later-arrow-can-hit-split-children", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local model, humanoid = rig("Slime", enemies, origin + Vector3.new(0, 0, -6), Vector3.new(0, 0, 1))
		model:SetAttribute("EnemyKind", "Slime")
		assert(api.registerEnemy(model), "register production slime")
		humanoid.Health = 50
		action(state, "Skill2", 0)
		sample(0.25)
		local children = {}
		waitFor(function()
			children = {}
			for _, child in ipairs(enemies:GetChildren()) do
				if child:GetAttribute("SlimeSplitGeneration") == 1 then table.insert(children, child) end
			end
			return #children == 2
		end, "first arrow creates both children")
		for _, child in ipairs(children) do near(child.Humanoid.Health, 55, "killing arrow does not damage the children") end
		sample(0.43)
		local damaged = 0
		for _, child in ipairs(children) do if child.Humanoid.Health < 55 then damaged += 1 end end
		equal(damaged > 0, true, "a later arrow in the burst has its own hit set")
	end)
	case("player-health-recovers-slowly-on-server", function()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			reset(); api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			state.humanoid.Health = 500
			state.mode = "Block"
			for tick = 1, 4 do api.stepPlayer(state, tick * 0.25, 0.25, true) end
			near(state.humanoid.Health, 501, classId .. " heals 0.1 percent per second even in combat")
			state.humanoid.Health = 999.9
			api.stepPlayer(state, 1.25, 0.25, true)
			near(state.humanoid.Health, 1000, classId .. " cannot exceed max health")
			state.humanoid.Health = 0
			api.stepPlayer(state, 1.5, 0.25, true)
			near(state.humanoid.Health, 0, classId .. " does not regenerate after death")
		end
	end)
	case("legacy-resource-attributes-cleared-on-spawn-and-respawn", function()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			reset(); api.injectResolver(function() return classId end)
			local state, player = spawnPlayer(nil, true)
			for life = 1, 2 do
				if life == 2 then state = spawnPlayer(player, true) end
				equal(state.stamina, nil, classId .. " has no server resource on life " .. life)
				equal(state.character:GetAttribute("K0Stamina"), nil, classId .. " clears old value on life " .. life)
				equal(state.character:GetAttribute("K0MaxStamina"), nil, classId .. " clears old maximum on life " .. life)
				api.stepPlayer(state, 1, 0.25, true)
				equal(state.character:GetAttribute("K0Stamina"), nil, classId .. " does not recreate resource on heartbeat")
			end
		end
	end)
	case("confirmed-hit-feedback-only-for-actual-health-loss", function()
		api.injectResolver(function() return "knight" end)
		local events = {}
		api.setHitEffectRemote({ FireAllClients = function(_, ...) table.insert(events, { ... }) end })
		local state = spawnPlayer()
		local enemy = spawnEnemy(3, "Slime")
		action(state, "Attack", 0)
		enemy.humanoid.Health = 50
		sample(0.17)
		equal(#events, 1, "server broadcasts one confirmed hit")
		equal(events[1][1], enemy.model, "feedback identifies the actual enemy")
		equal(events[1][2], enemy.root.Position, "feedback snapshots target position")
		near(events[1][3], 50, "lethal damage number is actual health lost")
		equal(events[1][4], "knight", "feedback class comes from trusted server state")
		equal(events[1][5], "Slime", "feedback identifies slime material")
		sample(0.20)
		equal(#events, 1, "one attack window cannot broadcast the hit twice")
	end)
	case("confirmed-hit-includes-server-skill-identity", function()
		api.injectResolver(function() return "dwarf" end)
		local events = {}
		api.setHitEffectRemote({ FireAllClients = function(_, ...) table.insert(events, { ... }) end })
		local state = spawnPlayer()
		spawnEnemy(3)
		action(state, "Skill1", 0)
		sample(0.72)
		equal(#events, 1, "actual damage produces one skill effect")
		equal(events[1][7], "dwarf.common.overhead", "effect ID comes from the accepted server skill")
	end)
	case("miss-and-forcefield-do-not-broadcast-hit-feedback", function()
		api.injectResolver(function() return "knight" end)
		local events = {}
		api.setHitEffectRemote({ FireAllClients = function(_, ...) table.insert(events, { ... }) end })
		local state = spawnPlayer()
		local enemy = spawnEnemy(3)
		local shield = Instance.new("ForceField")
		shield.Parent = enemy.model
		action(state, "Attack", 0)
		sample(0.17)
		near(enemy.humanoid.Health, 10000, "forcefield blocks health loss")
		equal(#events, 0, "blocked damage does not create hit feedback")
		shield:Destroy()
		reset()
		api.injectResolver(function() return "knight" end)
		api.setHitEffectRemote({ FireAllClients = function(_, ...) table.insert(events, { ... }) end })
		state = spawnPlayer()
		spawnEnemy(20)
		action(state, "Attack", 0)
		sample(0.17)
		equal(#events, 0, "miss does not create hit feedback")
	end)
	case("slime-melee-is-server-authoritative", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3, "Slime")
		local target = origin + Vector3.new(0, -1.6, -3)
		enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
		api.beginEnemyAttack(enemy, state, 0)
		sample(0.81)
		near(state.humanoid.Health, 960, "Slime deals its configured 40 server damage")
		sample(0.85)
		near(state.humanoid.Health, 960, "Slime cannot damage the player twice in one attack")
	end)
	case("mage-arcane-is-server-owned-and-cooldown-limited", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(20)
		action(state, "CastArcane", 0)
		equal(state.character:GetAttribute("K0AttackKind"), "Arcane", "Mage enters replicated cast pose")
		equal(state.character:GetAttribute("K0Stamina"), nil, "no stamina attribute is created")
		near(state.mana, 85, "server charges the configured mana cost")
		sample(0.46)
		near(enemy.humanoid.Health, 9900, "server resolves Arcane Bolt damage")
		equal(type(state.character:GetAttribute("K0SpellVisual")), "string", "server publishes spell visual snapshot")
		sample(0.50)
		near(enemy.humanoid.Health, 9900, "one spell cannot hit the same enemy twice")
		action(state, "CastArcane", 1.1)
		equal(state.character:GetAttribute("K0Feedback"), "SkillCooling", "early recast reports cooldown")
		equal(state.spellSeq, 1, "early recast emits no new spell")
		action(state, "CastArcane", 3.01)
		equal(state.character:GetAttribute("K0AttackKind"), "Arcane", "spell can be cast after cooldown")
	end)
	case("all-classes-have-independent-skill-cooldowns-and-magic-mana", function()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			reset()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			spawnEnemy(3)
			for slot = 1, 3 do
				local skill = api.Config.Skills[classId][slot]
				local t = (slot - 1) * 1.5
				local before = state.mana
				action(state, "Skill" .. slot, t)
				equal(state.attack and state.attack.definition, skill, classId .. " accepts its own skill " .. slot)
				equal(state.skillReadyAt[skill.id], t + skill.cooldown, classId .. " skill cooldown is independent")
				if skill.magic then
					near(state.mana, before - skill.manaCost, classId .. " spends the magic skill's MP")
				else
					equal(state.mana, nil, classId .. " physical skill needs no MP")
					equal(state.stamina, nil, classId .. " physical skill needs no stamina")
				end
			end
			if classId ~= "mage" then
				local first = api.Config.Skills[classId][1]
				action(state, "Skill1", 4.5)
				equal(state.attack, nil, classId .. " cannot reuse a cooling skill")
				equal(state.character:GetAttribute("K0Feedback"), "SkillCooling", classId .. " receives cooldown feedback")
				equal(state.skillReadyAt[first.id], first.cooldown, classId .. " rejected recast keeps its deadline")
				action(state, "Skill1", first.cooldown + 0.01)
				equal(state.attack and state.attack.definition, first, classId .. " can recast after its deadline")
			end
		end
	end)
	case("physical-resource-and-action-contract", function()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			reset(); api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			if classId == "mage" then state.mana = 0 end
			action(state, "SprintStart", 0)
			equal(state.humanoid.WalkSpeed, api.Config.SprintSpeed, classId .. " can sprint without a resource")
			action(state, "SprintEnd", 0.1)
			equal(state.humanoid.WalkSpeed, api.Config.WalkSpeed, classId .. " stops sprinting")
			action(state, "Attack", 0.2)
			equal(state.mode, "Attack", classId .. " can attack without a resource")
		end
	end)
	case("server-loadout-enforces-slots", function()
		api.injectResolver(function(player)
			return {heroId = "hero-" .. player.UserId, baseClassId = "knight", epoch = 1, characterGeneration = 1,
				skillSlots = {2, 1, 0, 3, 0}, slotCount = 5}
		end)
		local state = spawnPlayer()
		action(state, "Skill3", 0)
		equal(state.attack, nil, "empty skill is rejected")
		action(state, "Skill4", 0.1)
		equal(state.attack.definition.id, "knight.common.provoke", "equipped skill is used in slot 4")
		equal(state.skillReadyAt["knight.common.provoke"], 12.1, "cooldown follows skill identity")
		equal(state.character:GetAttribute("K0EquippedSkill1"), "knight.common.whirlwind", "replicated equipped skill matches trusted slot")
	end)
	case("gravity-slows-nearby-targets-and-expires", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local target = spawnEnemy(8)
		local other = spawnEnemy(12)
		local distant = spawnEnemy(16)
		action(state, "Skill3", 0, nil, target.model)
		near(state.mana, 80, "gravity consumes mana")
		sample(0.41)
		near(target.humanoid.Health, 9930, "gravity deals server damage")
		near(target.humanoid.WalkSpeed, target.config.walkSpeed * 0.5, "gravity slows target")
		near(other.humanoid.Health, 9930, "gravity damages nearby enemy")
		near(other.humanoid.WalkSpeed, other.config.walkSpeed * 0.5, "gravity slows nearby enemy")
		near(distant.humanoid.Health, 10000, "gravity does not hit outside radius")
		equal(type(state.character:GetAttribute("K0GravityAreaVisual")), "string", "gravity area published after valid target")
		equal(type(target.model:GetAttribute("K0GravityUntil")), "number", "gravity duration replicated")
		api.stepEnemy(target, 3.42, 0)
		near(target.humanoid.WalkSpeed, target.config.walkSpeed, "gravity expires and restores speed")
		equal(target.model:GetAttribute("K0GravityUntil"), nil, "gravity marker cleared")
	end)
	case("whirlwind-hits-around-knight-once", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local front = spawnEnemy(4)
		local behind = spawnEnemy(4)
		behind.root.Position = origin + Vector3.new(0, 0, 4)
		local outside = spawnEnemy(9)
		action(state, "Skill2", 0, nil, outside.model)
		sample(0.26)
		near(front.humanoid.Health, 9900, "front enemy hit")
		near(behind.humanoid.Health, 9900, "rear enemy hit")
		near(outside.humanoid.Health, 10000, "enemy outside radius missed")
		sample(0.30)
		near(front.humanoid.Health, 9900, "whirlwind hits only once")
	end)
	case("provoke-overrides-target-until-expiry", function()
		api.injectResolver(function() return "knight" end)
		local knight = spawnPlayer()
		local ally = spawnPlayer()
		local enemy = spawnEnemy(3)
		local farEnemy = spawnEnemy(20)
		enemy.attackers = { [ally] = 20 }
		enemy.target = ally
		action(knight, "Skill3", 0)
		sample(0.26)
		equal(enemy.provokedBy, knight, "provoke selects knight")
		equal(enemy.target, knight, "provoke changes current target")
		equal(api.closestTarget(enemy, 1), knight, "provoke takes priority over other attacker")
		equal(farEnemy.provokedBy, nil, "outside enemy unaffected")
		near(enemy.defenseBreakUntil, 4.26, "defense weakening lasts four seconds")
		equal(farEnemy.defenseBreakUntil, nil, "outside enemy is not weakened")
		near(enemy.humanoid.Health, 10000, "provoke causes no damage")
		action(ally, "Attack", 0.5)
		sample(0.67)
		equal(enemy.target, knight, "ally damage does not override active provoke")
		near(enemy.humanoid.Health, 9917, "ally damage benefits from defense weakening")
		equal(api.closestTarget(enemy, 4.27), ally, "target returns to attacker after provoke expires")
		equal(enemy.model:GetAttribute("K0ProvokeUntil"), nil, "provoke marker cleared")
	end)
	case("gravity-area-respects-cover", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local target, blocked = spawnEnemy(8), spawnEnemy(12)
		local wall = Instance.new("Part")
		wall.Name = "Wall"; wall.Anchored = true; wall.Size = Vector3.new(8, 8, 0.2)
		wall.Position = origin + Vector3.new(0, 0, -10); wall.Parent = fixture
		action(state, "Skill3", 0, nil, target.model)
		sample(0.41)
		near(target.humanoid.Health, 9930, "target hit before wall")
		near(blocked.humanoid.Health, 10000, "wall blocks gravity area")
	end)
	case("mana-rejection-does-not-spend-or-start-cooldown", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		state.mana = 0
		action(state, "Skill2", 0)
		equal(state.attack, nil, "insufficient mana rejects cast")
		equal(state.skillReadyAt[api.Config.Skills.mage[2].id], nil, "rejected cast starts no cooldown")
		equal(state.character:GetAttribute("K0Feedback"), "NeedMana", "mana failure is reported")
	end)
	case("mana-recovery-still-respects-delay-and-cap", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		action(state, "Skill1", 0)
		api.stepPlayer(state, 0.75, 0.25, true)
		near(state.mana, 85, "mana does not recover before delay")
		for tick = 0, 3 do api.stepPlayer(state, 1 + tick * 0.25, 0.25, true) end
		near(state.mana, 95, "mana recovers at configured rate")
		state.mana = 99
		api.stepPlayer(state, 2, 0.25, true)
		near(state.mana, 100, "mana cannot exceed maximum")
	end)
	case("physical-skill-cooldown-survives-respawn", function()
		local ready = {}
		api.injectResolver(function(player)
			return { heroId = "hero-" .. player.UserId, baseClassId = "knight", epoch = 1, characterGeneration = 1,
				skillReadyAt = table.clone(ready), setSkillReadyAt = function(id, time) ready[id] = time end }
		end)
		local first, player = spawnPlayer()
		action(first, "Skill1", 0)
		local skill = api.Config.Skills.knight[1]
		equal(ready[skill.id], skill.cooldown, "session records physical skill deadline")
		api.setClock(1)
		local respawned = spawnPlayer(player, true)
		action(respawned, "Skill1", 1.1)
		equal(respawned.attack, nil, "respawn does not reset cooldown")
		equal(respawned.character:GetAttribute("K0Feedback"), "SkillCooling", "respawned hero sees cooldown feedback")
		action(respawned, "Skill2", 1.2)
		equal(respawned.attack and respawned.attack.definition.id, api.Config.Skills.knight[2].id, "other physical skill is still available")
	end)
	case("skills-resolve-at-their-own-hit-window", function()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			for slot = 1, 3 do
				reset()
				api.injectResolver(function() return classId end)
				local state = spawnPlayer()
				local enemy = spawnEnemy(3)
				local skill = api.Config.Skills[classId][slot]
				if skill.effect == "recall" then state.thrownUntil = 4; state.thrownTarget = enemy.model end
				action(state, "Skill" .. slot, 0, nil, enemy.model)
				sample(skill.windup + (skill.hitDelay or 0) + 0.01)
				if skill.effect == "provoke" then
					assert(enemy.provokedBy == state and enemy.provokeUntil > 0, "provoke attracts enemy")
					report.checks += 1
				else
					assert(enemy.humanoid.Health < 10000, classId .. " skill " .. slot .. " damages target")
					report.checks += 1
				end
				if skill.effect == "mark" then equal(enemy.marks[state] ~= nil, true, "hunter mark applies") end
				if skill.effect == "water" then equal(enemy.model:GetAttribute("K0WetUntil") ~= nil, true, "water applies wet marker") end
			end
		end
	end)
	case("aimed-shot-hits-only-selected-target", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local first, second = spawnEnemy(4), spawnEnemy(8)
		action(state, "Skill1", 0, nil, second.model)
		sample(0.46)
		near(first.humanoid.Health, 10000, "aimed shot ignores nearer decoy")
		near(second.humanoid.Health, 9860, "aimed shot hits selected target")
	end)
	case("rapid-fire-shoots-three-timed-arrows", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local target = spawnEnemy(8)
		action(state, "Skill2", 0, nil, target.model)
		sample(0.25)
		near(target.humanoid.Health, 9945, "first arrow hits")
		equal(state.arrowSeq, 1, "first arrow emitted")
		sample(0.43)
		near(target.humanoid.Health, 9890, "second arrow hits same target")
		sample(0.61)
		near(target.humanoid.Health, 9835, "third arrow hits same target")
		equal(state.arrowSeq, 3, "three arrow snapshots emitted")
		sample(0.64)
		near(target.humanoid.Health, 9835, "no extra hit")
	end)
	case("rapid-fire-stops-on-interruption-and-does-not-backfill-stale-shots", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local target = spawnEnemy(8)
		action(state, "Skill2", 0, nil, target.model)
		sample(0.25)
		api.clearAction(state); state.mode = "Stunned"
		sample(0.61)
		near(target.humanoid.Health, 9945, "interruption cancels remaining shots")
		reset()
		api.injectResolver(function() return "elf" end)
		state = spawnPlayer(); target = spawnEnemy(8)
		action(state, "Skill2", 0, nil, target.model)
		sample(1.0)
		near(target.humanoid.Health, 10000, "stale shot windows do not fire")
	end)
	case("multi-shot-damages-forward-targets-once", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local first, second, behind = spawnEnemy(5), spawnEnemy(8), spawnEnemy(4)
		behind.root.Position = origin + Vector3.new(0, 0, 4)
		action(state, "Skill3", 0, nil, first.model)
		sample(0.31)
		near(first.humanoid.Health, 9925, "multi shot hits selected")
		near(second.humanoid.Health, 9925, "multi shot hits another forward enemy")
		near(behind.humanoid.Health, 10000, "multi shot ignores rear enemy")
		equal(type(state.character:GetAttribute("K0MultiShotVisual")), "string", "additional arrow endpoints replicated")
		sample(0.35)
		near(second.humanoid.Health, 9925, "multi shot does not repeat")
	end)
	case("multi-shot-miss-still-replicates-five-arrow-fan", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		action(state, "Skill3", 0)
		sample(0.31)
		equal(type(state.character:GetAttribute("K0ArrowVisual")), "string", "primary arrow replicated")
		local fields = string.split(state.character:GetAttribute("K0MultiShotVisual"), "|")
		equal(#fields, 16, "four secondary endpoints replicated without targets")
		equal(fields[5] ~= fields[14], true, "outer arrow endpoints spread apart")
	end)
	case("multi-shot-respects-cover", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local first, blocked = spawnEnemy(5), spawnEnemy(9)
		local wall = Instance.new("Part")
		wall.Name = "Wall"; wall.Anchored = true; wall.Size = Vector3.new(8, 8, 0.2)
		wall.Position = origin + Vector3.new(0, 0, -7); wall.Parent = fixture
		action(state, "Skill3", 0, nil, first.model)
		sample(0.31)
		near(first.humanoid.Health, 9925, "visible target hit")
		near(blocked.humanoid.Health, 10000, "wall protects secondary target")
		equal(#string.split(state.character:GetAttribute("K0MultiShotVisual"), "|"), 16, "four cosmetic arrows are replicated even when targets are blocked")
	end)
	case("dwarf-overhead-smash-is-a-single-hit", function()
		api.injectResolver(function() return "dwarf" end)
		local state = spawnPlayer()
		local target, other = spawnEnemy(3), spawnEnemy(4)
		action(state, "Skill1", 0, nil, target.model)
		sample(0.64)
		near(target.humanoid.Health, 10000, "overhead circle completes before damage")
		sample(0.72)
		near(target.humanoid.Health, 9860, "overhead smash hits target")
		near(other.humanoid.Health, 10000, "overhead smash hits only one enemy")
	end)
	case("dwarf-ground-slam-hits-around-player", function()
		api.injectResolver(function() return "dwarf" end)
		local state = spawnPlayer()
		local front, behind, distant = spawnEnemy(4), spawnEnemy(4), spawnEnemy(8)
		behind.root.Position = origin + Vector3.new(0, 0, 4)
		action(state, "Skill3", 0, nil, distant.model)
		sample(0.42)
		near(front.humanoid.Health, 9880, "slam hits front enemy")
		near(behind.humanoid.Health, 9880, "slam hits rear enemy")
		near(distant.humanoid.Health, 10000, "slam ignores outside enemy and distant selected target")
	end)
	case("magic-costs-and-cooldowns-are-independent", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		spawnEnemy(3)
		action(state, "Skill1", 0)
		sample(0.46)
		action(state, "Skill2", 1.1)
		equal(state.attack and state.attack.definition.id, "mage.common.water_ball", "second spell available while first cooling")
		near(state.mana, 73, "two spells spend their own MP costs")
		sample(1.46)
		action(state, "Skill1", 2.1)
		equal(state.character:GetAttribute("K0Feedback"), "SkillCooling", "first spell remains on its own cooldown")
		near(state.mana, 73, "cooldown rejection spends no MP")
	end)
	case("arcane-denies-other-classes-and-wall-damage", function()
		api.injectResolver(function() return "knight" end)
		local knight = spawnPlayer()
		action(knight, "CastArcane", 0)
		equal(knight.attack, nil, "non-Mage cannot request Arcane Bolt")
		equal(knight.mana, nil, "Knight has no mana before a magic path")
		reset()
		api.injectResolver(function() return "mage" end)
		local mage = spawnPlayer()
		local enemy = spawnEnemy(20)
		local wall = Instance.new("Part")
		wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(mage, "CastArcane", 0)
		sample(0.46)
		near(enemy.humanoid.Health, 10000, "wall blocks server Arcane Bolt damage")
	end)


	case("targeted-elf-shot-prefers-clicked-enemy", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local decoy = spawnEnemy(5)
		local selected = spawnEnemy(8, "Orc")
		selected.root.CFrame = CFrame.new(origin + Vector3.new(8, 0, 0))
		action(state, "Attack", 0, nil, selected.model)
		sample(0.23)
		near(selected.humanoid.Health, 9930, "server hits explicitly selected side target")
		near(decoy.humanoid.Health, 10000, "selected shot does not hit the nearer forward target")
	end)
	case("targeted-mage-checks-wall-range-and-forgery", function()
		api.injectResolver(function() return "mage" end)
		local state = spawnPlayer()
		local target = spawnEnemy(20)
		local fake = Instance.new("Model"); fake.Parent = fixture
		action(state, "CastArcane", 0, nil, fake)
		equal(state.attack, nil, "unregistered target is rejected")
		fake:Destroy()
		local wall = Instance.new("Part"); wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(state, "CastArcane", 0, nil, target.model)
		sample(0.46)
		near(target.humanoid.Health, 10000, "selected enemy behind wall takes no damage")
		equal(state.character:GetAttribute("K0Feedback"), "TargetBlocked", "blocked target is explained")
		reset(); api.injectResolver(function() return "mage" end)
		state = spawnPlayer(); target = spawnEnemy(45)
		action(state, "CastArcane", 0, nil, target.model); sample(0.46)
		near(target.humanoid.Health, 10000, "selected enemy outside server range takes no damage")
	end)
	case("dead-selected-target-does-not-retarget", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local other, selected = spawnEnemy(5), spawnEnemy(8)
		action(state, "Attack", 0, nil, selected.model)
		selected.humanoid.Health = 0
		sample(0.23)
		near(other.humanoid.Health, 10000, "dead target does not redirect damage to another enemy")
		equal(state.character:GetAttribute("K0Feedback"), "TargetUnavailable", "dead target is explained")
	end)
	for _, classId in ipairs({ "knight", "dwarf", "mage" }) do
		case("targeted-" .. classId .. "-turns-and-hits-selected", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local decoy, selected = spawnEnemy(3), spawnEnemy(3, "Orc")
			selected.root.CFrame = CFrame.new(origin + Vector3.new(3, 0, 0))
			action(state, "Attack", 0, nil, selected.model)
			equal(state.attack.targetModel, selected.model, "accepted attack retains selected target")
			near(state.attack.direction:Dot(Vector3.new(1, 0, 0)), 1, "server locks aim toward target")
			near(state.root.CFrame.LookVector:Dot(Vector3.new(1, 0, 0)), 1, "server turns character toward target")
			equal(state.humanoid.AutoRotate, false, "movement cannot turn a targeted swing away")
			local definition = state.attack.definition
			sample(definition.windup + (definition.hitDelay or 0) + 0.01)
			near(selected.humanoid.Health, 9925, "selected side enemy takes server damage")
			near(decoy.humanoid.Health, 10000, "enemy outside aimed cone is not hit")
			api.stepPlayer(state, 0.8, 0)
			equal(state.humanoid.AutoRotate, true, "normal auto rotation returns when the swing ends")
		end)
		case("targeted-" .. classId .. "-rejects-unregistered-and-out-of-range", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local fake = Instance.new("Model"); fake.Parent = fixture
			action(state, "Attack", 0, nil, fake)
			equal(state.attack, nil, "unregistered target rejected")
			fake:Destroy()
			local selected, decoy = spawnEnemy(8), spawnEnemy(3)
			action(state, "Attack", 0, nil, selected.model)
			local definition = state.attack.definition
			sample(definition.windup + (definition.hitDelay or 0) + 0.01)
			near(selected.humanoid.Health, 10000, "selected enemy outside range takes no damage")
			near(decoy.humanoid.Health, 10000, "invalid selected target never silently redirects")
			equal(state.character:GetAttribute("K0Feedback"), "TargetBlocked", "player receives move closer feedback")
		end)
		case("targeted-" .. classId .. "-checks-cover-and-target-death", function()
			api.injectResolver(function() return classId end)
			local state, selected = spawnPlayer(), spawnEnemy(3)
			local wall = Instance.new("Part"); wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(8, 8, 0.2)
			wall.Position, wall.Parent = origin + Vector3.new(0, 0, -1.5), fixture
			action(state, "Attack", 0, nil, selected.model)
			local definition = state.attack.definition
			sample(definition.windup + (definition.hitDelay or 0) + 0.01)
			near(selected.humanoid.Health, 10000, "wall blocks targeted melee")
			equal(state.character:GetAttribute("K0Feedback"), "TargetBlocked", "cover is explained")
			reset(); api.injectResolver(function() return classId end)
			state = spawnPlayer(); selected = spawnEnemy(3)
			local other = spawnEnemy(3)
			action(state, "Attack", 0, nil, selected.model)
			definition = state.attack.definition
			selected.humanoid.Health = 0
			sample(definition.windup + (definition.hitDelay or 0) + 0.01)
			near(other.humanoid.Health, 10000, "dead selected target cannot redirect attack")
			equal(state.character:GetAttribute("K0Feedback"), "TargetUnavailable", "dead target is explained")
		end)
	end
	case("buffered-melee-aims-when-it-actually-starts", function()
		api.injectResolver(function() return "knight" end)
		local state, selected = spawnPlayer(), spawnEnemy(3)
		selected.root.CFrame = CFrame.new(origin + Vector3.new(3, 0, 0))
		action(state, "Attack", 0)
		action(state, "Attack", 0.301, nil, selected.model)
		equal(state.queued and state.queued.targetModel, selected.model, "buffer keeps target")
		near(state.attack.direction:Dot(Vector3.new(0, 0, -1)), 1, "in-progress swing stays locked")
		action(state, "Attack", 0.433333333, nil, selected.model)
		equal(state.attack.targetModel, selected.model, "new swing uses queued target")
		near(state.attack.direction:Dot(Vector3.new(1, 0, 0)), 1, "new swing aims at selected target")
		sample(0.63)
		near(selected.humanoid.Health, 9910, "second combo hits selected target once")
	end)
	case("selected-melee-target-prioritized-within-cleave-limit", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local near1, near2, near3, selected = spawnEnemy(1), spawnEnemy(2), spawnEnemy(3), spawnEnemy(4)
		action(state, "Attack", 0, nil, selected.model)
		sample(0.17)
		near(selected.humanoid.Health, 9925, "selected target takes one of three cleave slots")
		near(near1.humanoid.Health, 9925, "nearest additional target is hit")
		near(near2.humanoid.Health, 9925, "second additional target is hit")
		near(near3.humanoid.Health, 10000, "cleave target limit remains enforced")
	end)
	case("target-moving-behind-locked-melee-aim-does-not-redirect", function()
		api.injectResolver(function() return "knight" end)
		local state, selected = spawnPlayer(), spawnEnemy(3)
		local other = spawnEnemy(2)
		action(state, "Attack", 0, nil, selected.model)
		selected.root.CFrame = CFrame.new(origin + Vector3.new(0, 0, 3))
		sample(0.17)
		near(selected.humanoid.Health, 10000, "selected enemy outside locked forward arc is missed")
		near(other.humanoid.Health, 10000, "invalid selected target does not redirect the swing")
		equal(state.character:GetAttribute("K0Feedback"), "TargetBlocked", "target movement explains the miss")
	end)
	case("targeted-melee-restores-existing-rotation-on-interruption", function()
		api.injectResolver(function() return "knight" end)
		local state, selected = spawnPlayer(), spawnEnemy(3)
		state.humanoid.AutoRotate = false
		action(state, "Attack", 0, nil, selected.model)
		api.clearAction(state)
		equal(state.humanoid.AutoRotate, false, "interruption preserves pre-existing disabled rotation")
		state.humanoid.AutoRotate = true
		state.mode = "Idle"
		action(state, "Attack", 0.6, nil, selected.model)
		equal(state.humanoid.AutoRotate, false, "second targeted swing owns facing")
		api.clearAction(state)
		equal(state.humanoid.AutoRotate, true, "interruption restores enabled rotation")
	end)


	for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
		for _, kind in ipairs({ "Slime", "Goblin", "Orc", "Ogre" }) do
			case("immediate-recognition-" .. classId .. "-" .. kind, function()
				api.injectResolver(function() return classId end)
				local state, enemy = spawnPlayer(), spawnEnemy(3, kind)
				action(state, "Attack", 0)
				local definition = api.Config.BasicAttackProfiles[classId].attacks[1]
				sample(definition.windup + (definition.hitDelay or 0) + 0.01)
				equal(enemy.target, state, "enemy recognizes the real attacker during the hit")
				equal(enemy.mode, "Chase", "surviving enemy immediately enters chase")
				assert(enemy.attackers and enemy.attackers[state], "attacker gets a bounded retaliation entry")
			end)
		end
	end
	case("immediate-recognition-mage-cast", function()
		api.injectResolver(function() return "mage" end)
		local state, enemy = spawnPlayer(), spawnEnemy(15)
		action(state, "CastArcane", 0)
		sample(0.46)
		equal(enemy.target, state, "enemy immediately recognizes the caster")
		equal(enemy.mode, "Chase", "surviving enemy reacts to spell damage")
	end)
	case("dwarf-impact-matches-downstroke", function()
		api.injectResolver(function() return "dwarf" end)
		local events = {}
		api.setHitEffectRemote({ FireAllClients = function(_, ...) table.insert(events, { ... }) end })
		local state, enemy = spawnPlayer(), spawnEnemy(3)
		action(state, "Attack", 0)
		sample(0.20)
		near(enemy.humanoid.Health, 10000, "dwarf does not hit during the early downswing")
		equal(#events, 0, "no hit feedback before the impact")
		sample(0.23)
		near(enemy.humanoid.Health, 9925, "dwarf hits within the existing active window")
		equal(#events, 1, "impact feedback fires once at the hit")
	end)

	for _, classId in { "dwarf", "mage" } do
		case(classId .. "-melee-hit-deduplicate-and-buffer", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			local profile = api.Config.BasicAttackProfiles[classId]
			equal(state.baseClassId, classId, "server injected class")
			equal(state.character:GetAttribute("K0AttackProfileId"), profile.id, "profile replicated for visuals")
			equal(#profile.attacks, 1, "experimental single melee attack")
			state.counter = { bonus = 100, expires = 5 }
			local beforeCount = #fixture:GetDescendants()
			action(state, "Attack", 0)
			equal(state.character:GetAttribute("K0AttackSeq"), 1, "first attack sequence")
			local impact = profile.attacks[1].windup + (profile.attacks[1].hitDelay or 0)
			sample(impact + 0.01)
			near(enemy.humanoid.Health, 9925, "melee hit and no Knight counter bonus")
			sample(impact + 0.02)
			near(enemy.humanoid.Health, 9925, "same window cannot hit twice")
			equal(#fixture:GetDescendants(), beforeCount, "melee does not create a projectile")
			action(state, "Attack", 0.301)
			equal(state.queued and state.queued.action, "Attack", "second attack buffers")
			action(state, "Attack", 0.433333333)
			equal(state.character:GetAttribute("K0AttackSeq"), 2, "valid buffer executes once")
			equal(state.combo, 1, "single-hit profile loops at one")
		end)
		case(classId .. "-range-and-wall", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy(6)
			action(state, "Attack", 0)
			local definition = api.Config.BasicAttackProfiles[classId].attacks[1]
			sample(definition.windup + (definition.hitDelay or 0) + 0.01)
			near(enemy.humanoid.Health, 10000, "out of melee range")
			local wall = Instance.new("Part")
			wall.Name = "Wall"
			wall.Anchored = true
			wall.Size = Vector3.new(8, 8, 0.2)
			wall.Position = origin + Vector3.new(0, 0, -1.5)
			wall.Parent = fixture
			enemy.model:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, -3), origin + Vector3.new(0, 0, -2)))
			action(state, "Attack", 0.43)
			near(state.attack.started, 0.43, "second melee actually starts behind wall")
			sample(0.43 + definition.windup + (definition.hitDelay or 0) + 0.01)
			near(enemy.humanoid.Health, 10000, "solid wall blocks melee")
		end)
		case(classId .. "-missed-active-window", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			action(state, "Attack", 0)
			sample(0.27)
			near(enemy.humanoid.Health, 9925, "one delayed sample recovers skipped active window")
			sample(0.28)
			near(enemy.humanoid.Health, 9925, "recovery cannot hit twice")
		end)
		case(classId .. "-common-guard", function()
			api.injectResolver(function() return classId end)
			local state = spawnPlayer()
			local enemy = spawnEnemy()
			action(state, "BlockStart", 0)
			equal(state.mode, "Block", "every class can guard")
			api.beginEnemyAttack(enemy, state, 0)
			sample(0.61)
			near(state.humanoid.Health, 984, "guard mitigates frontal Goblin attack")
		end)
	end

	case("elf-nearest-forward-target-one-server-shot", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local nearEnemy = spawnEnemy(15)
		local farEnemy = spawnEnemy(25)
		farEnemy.id = 2
		action(state, "Attack", 0)
		equal(state.character:GetAttribute("K0AttackProfileId"), "elf.bow.basic", "server chooses Elf bow profile")
		sample(0.23)
		near(nearEnemy.humanoid.Health, 9930, "nearest visible target receives 70 damage")
		near(farEnemy.humanoid.Health, 10000, "single shot does not hit a second target")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "server publishes one shot")
		equal(state.character:GetAttribute("K0ArrowTo"), nearEnemy.root.Position, "visual endpoint follows server target")
		sample(0.24)
		near(nearEnemy.humanoid.Health, 9930, "active window cannot deal duplicate damage")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "one arrow per attack window")
	end)
	case("elf-25-86-stud-shot-persists-and-provokes-goblin", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		enemy.nextMoveAt = 0
		action(state, "Attack", 0)
		api.setClock(0.23)
		api.heartbeat(1 / 60)
		near(enemy.humanoid.Health, 230, "real 25.86-stud hit survives the same heartbeat")
		near(enemy.attackers[state], 6.23, "actual attacking state recorded")
		equal(enemy.target, state, "goblin targets the ranged attacker inside its leash")
		equal(enemy.mode, "Chase", "goblin reacts rather than restoring health")
		near(enemy.aggroUntil, 6.23, "six-second retaliation lifetime")
		near((enemy.humanoid.WalkToPoint - state.root.Position).Magnitude, 0, "chase moves toward validated attacker")
	end)
	case("elf-outside-passive-range-is-recognized", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(50)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(state, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		near(enemy.humanoid.Health, 230, "outside leash damage is not immediately restored")
		equal(enemy.target, state, "attacker is recognized even outside the spawn-based player radius")
		equal(enemy.mode, "Chase", "enemy begins pursuing the attacker while its own leash remains enforced")
		action(state, "Attack", 0.61)
		api.setClock(0.84); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "another shot deals damage and refreshes grace")
		near(enemy.aggroUntil, 6.84, "latest hit extends the six-second timeout")
		api.setClock(6.3); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "earlier timeout cannot prematurely heal")
		api.setClock(6.85); api.heartbeat(0)
		near(enemy.humanoid.Health, 300, "enemy recovers after the final timeout")
		equal(enemy.attackers, nil, "reset clears retaliation identities")
	end)
	case("elf-retaliation-cannot-break-spawn-leash", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		enemy.nextMoveAt = 0
		action(state, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		equal(enemy.target, state, "attacker initially within leash")
		enemy.model:PivotTo(CFrame.lookAt(enemy.spawnPosition + Vector3.new(0, 0, 36.1), enemy.spawnPosition + Vector3.new(0, 0, 37.1)))
		enemy.nextMoveAt = 0
		api.setClock(0.24); api.heartbeat(0)
		equal(enemy.target, nil, "over-leash enemy stops chasing")
		near((enemy.humanoid.WalkToPoint - enemy.spawnPosition).Magnitude, 0, "over-leash enemy returns to spawn")
		near(enemy.humanoid.Health, 230, "health persists while returning")
	end)
	case("elf-old-hero-is-never-a-retaliation-target", function()
		local contexts = {}
		api.injectResolver(function(player) return contexts[player] end)
		local player = { Parent = Players, UserId = -2101 }
		contexts[player] = { heroId = "elf-old", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local elf = spawnPlayer(player)
		local otherPlayer = { Parent = Players, UserId = -2102 }
		contexts[otherPlayer] = { heroId = "other", baseClassId = "dwarf", epoch = 1, characterGeneration = 1 }
		spawnPlayer(otherPlayer)
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(elf, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		equal(enemy.target, elf, "live Elf is the initial target")
		contexts[player] = nil
		api.setClock(0.24); api.heartbeat(0)
		equal(enemy.target, nil, "revoked hero is not chased despite remaining grace")
		near(enemy.humanoid.Health, 230, "live second player leaves bounded damage grace intact")
	end)
	case("multiple-elf-hits-retain-each-valid-attacker", function()
		local contexts = {}
		api.injectResolver(function(player) return contexts[player] end)
		local nearPlayer = { Parent = Players, UserId = -2202 }
		contexts[nearPlayer] = { heroId = "near-elf", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local nearElf = spawnPlayer(nearPlayer)
		local farPlayer = { Parent = Players, UserId = -2201 }
		contexts[farPlayer] = { heroId = "far-elf", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		local farElf = spawnPlayer(farPlayer)
		local farPosition = origin + Vector3.new(0, 0, 24.14)
		farElf.character:PivotTo(CFrame.lookAt(farPosition, farPosition + Vector3.new(0, 0, -1)))
		farElf.lastMotionPosition, farElf.lastSafePivot = farElf.root.Position, farElf.character:GetPivot()
		local enemy = spawnEnemy(25.86)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(nearElf, "Attack", 0)
		action(farElf, "Attack", 0)
		api.setClock(0.23); api.heartbeat(0)
		near(enemy.humanoid.Health, 160, "both independent hits apply")
		near(enemy.attackers[nearElf], 6.23, "near attacker remains in threat table")
		near(enemy.attackers[farElf], 6.23, "far attacker is recorded separately")
		equal(enemy.target, nearElf, "farther outside-leash hit does not erase nearby valid target")
	end)
	case("knight-melee-is-recognized-until-timeout", function()
		api.injectResolver(function() return "knight" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(3)
		enemy.humanoid.MaxHealth, enemy.humanoid.Health = 300, 300
		action(state, "Attack", 0)
		sample(0.17)
		near(enemy.humanoid.Health, 225, "Knight hit remains 75")
		state.character:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, 30), origin + Vector3.new(0, 0, 29)))
		state.lastMotionPosition, state.lastSafePivot, state.lastMotionAt = state.root.Position, state.character:GetPivot(), 0.17
		api.setClock(0.18); api.heartbeat(0)
		near(enemy.humanoid.Health, 225, "melee damage is retained while attacker is recognized")
		equal(enemy.target, state, "melee attacker is recognized beyond passive aggro")
		near(enemy.attackers[state], 6.17, "melee attacker has a bounded recognition lifetime")
		api.setClock(6.18); api.heartbeat(0)
		near(enemy.humanoid.Health, 300, "enemy resets after recognition expires")
		equal(enemy.attackers, nil, "reset clears attacker identities")
	end)
	case("elf-range-and-facing-validated", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local tooFar = spawnEnemy(56)
		local behind = spawnEnemy(3)
		behind.id = 2
		behind.model:PivotTo(CFrame.lookAt(origin + Vector3.new(0, 0, 3), origin + Vector3.new(0, 0, 4)))
		action(state, "Attack", 0)
		sample(0.23)
		near(tooFar.humanoid.Health, 10000, "outside 55-stud range is rejected")
		near(behind.humanoid.Health, 10000, "target behind the server facing is rejected")
		equal(state.character:GetAttribute("K0ArrowTo"), origin + Vector3.new(0, 0, -55), "miss ends at maximum range")
	end)
	case("elf-wall-blocks-server-shot", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(20)
		local wall = Instance.new("Part")
		wall.Name, wall.Anchored, wall.Size = "Wall", true, Vector3.new(12, 8, 1)
		wall.Position, wall.Parent = origin + Vector3.new(0, 0, -10), fixture
		action(state, "Attack", 0)
		sample(0.23)
		near(enemy.humanoid.Health, 10000, "wall prevents ranged damage")
		local endpoint = state.character:GetAttribute("K0ArrowTo")
		near((endpoint - origin).Magnitude, 9.5, "miss visual stops on first wall")
	end)
	for _, angle in { 20, 23 } do
		case("elf-forward-cone-" .. angle, function()
			api.injectResolver(function() return "elf" end)
			local state = spawnPlayer()
			local enemy = spawnEnemy(15)
			local target = origin + Vector3.new(15 * math.sin(math.rad(angle)), 0, -15 * math.cos(math.rad(angle)))
			enemy.model:PivotTo(CFrame.lookAt(target, target + Vector3.new(0, 0, 1)))
			action(state, "Attack", 0)
			sample(0.23)
			near(enemy.humanoid.Health, angle == 20 and 9930 or 10000, "45-degree total cone boundary")
		end)
	end
	case("elf-server-facing-and-input-burst-limit", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(state, "Attack", 0, Vector3.new(0, 0, 1))
		for _ = 1, 50 do action(state, "Attack", 0) end
		equal(state.attackSeq, 1, "burst cannot start additional attacks")
		equal(state.tokens, 0, "repeated remote requests exhaust the server bucket")
		sample(0.23)
		near(enemy.humanoid.Health, 9930, "forged direction does not reverse server facing")
		equal(state.character:GetAttribute("K0ArrowSeq"), 1, "burst yields only one shot")
	end)
	case("elf-common-guard", function()
		api.injectResolver(function() return "elf" end)
		local state = spawnPlayer()
		local enemy = spawnEnemy()
		action(state, "BlockStart", 0)
		equal(state.mode, "Block", "Elf can block")
		api.beginEnemyAttack(enemy, state, 0)
		sample(0.61)
		near(state.humanoid.Health, 984, "Elf block reduces frontal damage")
	end)
	case("session-context-required-before-combat-setup", function()
		local ready = false
		api.injectResolver(function() return ready and "elf" or nil end)
		local model = rig("WaitingCharacter", characters, origin, Vector3.new(0, 0, -1))
		model:SetAttribute("K0SpawnReady", true)
		local player = { Parent = Players, Character = model, UserId = -2001 }
		api.activePlayers[player] = true
		api.setupCharacter(player, model)
		api.setupCharacter(player, model)
		equal(api.pendingCharacters[player], model, "duplicate setup shares a single pending character")
		task.wait(0.15)
		equal(api.playerStates[player], nil, "spawn alone does not activate combat")
		ready = true
		waitFor(function() return api.playerStates[player] ~= nil end, "session becomes ready")
		local state = api.playerStates[player]
		equal(state.baseClassId, "elf", "ready server context activates Elf")
		action(state, "Attack", 0)
		api.setupCharacter(player, model)
		task.wait(0.15)
		equal(api.playerStates[player], state, "duplicate ready setup cannot replace active state")
		equal(state.attackSeq, 1, "duplicate ready setup cannot reset attack sequence")
	end)
	case("hero-switch-invalidates-unfired-elf-attack", function()
		local context = { heroId = "elf-hero", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		api.injectResolver(function() return context end)
		local old, player = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(old, "Attack", 0)
		context = { heroId = "knight-hero", baseClassId = "knight", epoch = 2, characterGeneration = 2 }
		sample(0.23)
		near(enemy.humanoid.Health, 10000, "old windup cannot hit after epoch switch")
		equal(old.character:GetAttribute("K0ArrowSeq"), 0, "old epoch cannot publish a shot")
		local new = spawnPlayer(player)
		equal(new.baseClassId, "knight", "new hero may start Knight combat")
		equal(api.playerStates[player], new, "new hero owns combat state")
	end)
	case("stale-character-cannot-cancel-new-setup", function()
		local ready = false
		api.injectResolver(function() return ready and "elf" or nil end)
		local old = rig("OldCharacter", characters, origin, Vector3.new(0, 0, -1))
		local new = rig("NewCharacter", characters, origin, Vector3.new(0, 0, -1))
		old:SetAttribute("K0SpawnReady", true)
		new:SetAttribute("K0SpawnReady", true)
		local player = { Parent = Players, Character = old, UserId = -2002 }
		api.activePlayers[player] = true
		api.setupCharacter(player, old)
		player.Character = new
		api.setupCharacter(player, new)
		api.setupCharacter(player, old)
		equal(api.pendingCharacters[player], new, "late old callback cannot replace current pending life")
		ready = true
		waitFor(function() return api.playerStates[player] ~= nil end, "new character setup")
		equal(api.playerStates[player].character, new, "only new character becomes active")
	end)
	case("hero-switch-clears-fired-elf-visual-and-future-hits", function()
		local context = { heroId = "elf-hero", baseClassId = "elf", epoch = 1, characterGeneration = 1 }
		api.injectResolver(function() return context end)
		local old, player = spawnPlayer()
		local enemy = spawnEnemy(15)
		action(old, "Attack", 0)
		sample(0.23)
		near(enemy.humanoid.Health, 9930, "shot before switch lands once")
		equal(type(old.character:GetAttribute("K0ArrowVisual")), "string", "server publishes shot visual")
		context = { heroId = "mage-hero", baseClassId = "mage", epoch = 2, characterGeneration = 2 }
		sample(0.24)
		api.stepPlayer(old, 0.24, 0, false)
		near(enemy.humanoid.Health, 9930, "old shot cannot hit again after switch")
		equal(old.character:GetAttribute("K0ArrowVisual"), nil, "old visual is invalidated")
		local new = spawnPlayer(player)
		equal(new.baseClassId, "mage", "different hero enters with its own class")
	end)

	case("hero-class-stays-fixed-and-new-hero-can-differ", function()
		api.injectResolver(function() return "dwarf" end)
		local first, player = spawnPlayer()
		local second = spawnPlayer(player)
		equal(second.baseClassId, "dwarf", "respawn uses first server class")
		equal(second.character:GetAttribute("K0AttackProfileId"), "dwarf.axe.basic", "profile stays fixed")
		first.humanoid.Health = 0
		task.wait()
		equal(api.playerStates[player], second, "old death cannot replace new state")
		api.injectResolver(function() return "mage" end)
		equal(api.readCombatContext(player, second.character), nil, "same hero class cannot change")
		api.injectResolver(function() return { heroId = "other-hero", baseClassId = "mage", epoch = 2, characterGeneration = 2 } end)
		local third = spawnPlayer(player)
		equal(third.baseClassId, "mage", "different hero can have a different class")
	end)
	case("unsupported-class-fails-closed", function()
		api.injectResolver(function() return "priest" end)
		local player = { Parent = Players, UserId = -999 }
		api.activePlayers[player] = true
		equal(api.readCombatContext(player, nil), nil, "unsupported server class denied")
		api.injectResolver(function() return "knight" end)
		equal(api.readCombatContext(player, nil).baseClassId, "knight", "valid later context can become ready")
		equal(api.heroClasses[player], nil, "invalid context does not create a hero")
	end)
	case("yielding-resolver-fails-closed", function()
		local player = { Parent = Players, UserId = -1000 }
		api.activePlayers[player] = true
		local continued = false
		api.injectResolver(function() coroutine.yield(); continued = true; return "mage" end)
		equal(api.readCombatContext(player, nil), nil, "yielding resolver returns no context")
		equal(continued, false, "yielded resolver cannot later enable combat")
		equal(api.heroClasses[player], nil, "yielded resolver cannot create a hero")
	end)
	case("public-start-accepts-trusted-server-resolver", function()
		api.start(enemies, function() return { heroId = "mage-hero", baseClassId = "mage", epoch = 1, characterGeneration = 1 } end)
		local player = { Parent = Players, UserId = -1001 }
		api.activePlayers[player] = true
		equal(api.readCombatContext(player, nil).baseClassId, "mage", "actual public start installs server resolver")
	end)
end, debug.traceback)
if not ok then table.insert(report.failures, "fixture: " .. tostring(fatal)) end
local cleanupOk, cleanupError = pcall(function()
	reset()
	if fixture then fixture:Destroy() end
	if privateModule then privateModule:Destroy() end
	if startedRun then RunService:Stop() end
end)
if not cleanupOk then table.insert(report.failures, "cleanup: " .. tostring(cleanupError)) end
report.pass = #report.failures == 0
print("K0_BASIC_ATTACK_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 basic attack native QA failed; see K0_BASIC_ATTACK_NATIVE")
