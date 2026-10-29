-- Run with: run-in-roblox --place <fixed local build> --script tests/k0-build-smoke.luau
-- Native ModuleScript/server/physics smoke only. No Player, client input, network,
-- saving, purchases, performance acceptance, publishing, or release claim.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

assert(game.PlaceId == 0, "K0 smoke requires an unpublished local test place")
assert(not RunService:IsRunning(), "K0 smoke requires an idle isolated Studio")
assert(ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("K0Config"), "K0 shared sources missing")
assert(ServerScriptService:FindFirstChild("Server"), "K0 server bootstrap missing")
local healthOverride = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts"):FindFirstChild("Health")
assert(healthOverride and healthOverride:IsA("Script"), "player default health regeneration must be overridden")

local report = { kind = "K0_NATIVE_SMOKE", checks = 0, failures = {}, compiledModules = {}, runtimeErrors = {}, players = 0, enemies = {}, respawns = {}, assetLoads = {}, spawnCoverage = "Spawn instance only; initial Player placement and respawn require real Play", lobbyCoverage = "Dawnspire scene floor/bounds/spawn and native request/state remote creation only; actual Player lobby selection/start/UI and combat safety require separate evidence", combatCoverage = "Four idle enemy presets and death/respawn only; real Player aggro, attacks and damage require Play", assetCoverage = "Actual TD MeshParts in isolated Studio; published RPG permissions and visible Play presentation require separate evidence" }
local function check(condition, label)
	report.checks += 1
	if not condition then table.insert(report.failures, label) end
end
local function waitFor(predicate, seconds)
	local deadline = os.clock() + seconds
	repeat
		local result = predicate()
		if result then return result end
		task.wait(0.1)
	until os.clock() >= deadline
	return nil
end
local TD_EXPECTED = {
	Goblin = { template = "goblin", height = 3.6, visualHeight = 3.6 * 1.2, texture = "134919664038207", meshes = {
		Body = "77403549111699", ArmL = "127402469282462", ArmR = "106102430341786", LegL = "78392327157438", LegR = "100268725310905",
	} },
	Ogre = { template = "ogre", height = 6.05, visualHeight = 6.05 * 2.475 / 1.45, texture = "90412861785322", meshes = {
		Body = "98618217378067", ArmL = "108622715572697", ArmR = "98353562560509", LegL = "76243711635467", LegR = "77089513742534",
	} },
	Orc = { template = "orc", height = 4.6, visualHeight = 4.6 * 1.5, texture = "140427201929012", meshes = {
		Body = "91974284442570", ArmL = "80036546875989", ArmR = "126087041396792", LegL = "122434686618387", LegR = "108357424176147",
	} },
	Slime = { template = "slime", height = 1.1, visualHeight = 1.1 * 1.44, texture = "75994104212849", meshes = { Body = "84245584635347" } },
}
local COMBAT_KINDS = { "Goblin", "Slime", "Ogre", "Orc" }
local ANCHORS = { Body = "Torso", ArmL = "Right Arm", ArmR = "Left Arm", LegL = "Right Leg", LegR = "Left Leg" }
local function numericId(uri)
	return tostring(uri):match("rbxassetid://(%d+)") or tostring(uri):match("[?&]id=(%d+)")
end
local function meshParts(model)
	local parts = {}
	if model then
		for _, item in model:GetDescendants() do
			if item:IsA("MeshPart") then table.insert(parts, item) end
		end
	end
	return parts
end
local function checkVisual(rig, kind, label)
	local spec = TD_EXPECTED[kind]
	local visual = rig and rig:FindFirstChild("TdMonsterVisual")
	local expectedCount = if kind == "Slime" then 1 else 5
	check(visual and visual:IsA("Model"), label .. " has TD appearance model")
	if not visual then return nil end
	check(#meshParts(rig) == expectedCount and #meshParts(visual) == expectedCount, label .. " exact visible MeshPart count")
	check(rig:GetAttribute("TdMonsterTemplate") == spec.template, label .. " source template recorded")
	check(math.abs((rig:GetAttribute("TdMonsterSourceHeight") or 0) - spec.height) < 0.0001, label .. " source TargetHeight recorded")
	check(math.abs((rig:GetAttribute("TdMonsterTargetHeight") or 0) - (spec.visualHeight or spec.height)) < 0.0001, label .. " applied visual height recorded")
	local scale = rig:GetAttribute("TdMonsterScale")
	check(type(scale) == "number" and scale > 0 and scale < math.huge, label .. " finite positive visual scale")
	for name, id in pairs(spec.meshes) do
		local part = visual:FindFirstChild(name)
		check(part and part:IsA("MeshPart"), label .. " source part " .. name)
		if part and part:IsA("MeshPart") then
			check(numericId(part.MeshId) == id and numericId(part.TextureID) == spec.texture, label .. " original mesh/texture IDs " .. name)
			check(not part.Anchored and part.Massless and not part.CanCollide and not part.CanTouch and not part.CanQuery and part.Transparency == 0,
				label .. " presentation-only physics " .. name)
			local anchorName = if kind == "Slime" and not rig:FindFirstChild("Torso") then "HumanoidRootPart" else ANCHORS[name]
			local weld = part:FindFirstChild("TdVisualWeld")
			check(weld and weld:IsA("WeldConstraint") and weld.Part0 == rig:FindFirstChild(anchorName) and weld.Part1 == part,
				label .. " weld attached to independent rig " .. name)
		end
	end
	for _, item in rig:GetDescendants() do
		if item:IsA("BasePart") and not item:IsDescendantOf(visual) then
			check(item.Transparency == 1, label .. " invisible combat rig " .. item.Name)
		elseif item:IsA("LuaSourceContainer") then
			check(false, label .. " appearance must not import executable scripts")
		end
	end
	if kind ~= "Slime" or rig:FindFirstChildOfClass("Humanoid") then
		local root = rig:FindFirstChild("HumanoidRootPart")
		check(root and rig.PrimaryPart == root and root.CanCollide and root.CanQuery and not root.Anchored,
			label .. " independent moving collision/query root preserved")
		local motors = 0
		for _, item in rig:GetDescendants() do
			if item:IsA("Motor6D") and item.Part0 and item.Part1 then motors += 1 end
		end
		check(motors == 6, label .. " six connected R6 Motor6Ds preserved")
	end
	return visual
end
local function preloadActualParts(definitions)
	local threads = {}
	for _, definition in ipairs(definitions) do
		local row = { name = definition.name, meshId = numericId(definition.part.MeshId), textureId = numericId(definition.part.TextureID), callbacks = {}, done = false }
		table.insert(report.assetLoads, row)
		threads[row] = task.spawn(function()
			local success, message = pcall(function()
				ContentProvider:PreloadAsync({ definition.part }, function(uri, status)
					table.insert(row.callbacks, { uri = tostring(uri), id = numericId(uri), status = tostring(status) })
				end)
			end)
			if not success then row.error = tostring(message) end
			row.done = true
		end)
	end
	-- One 45-second deadline covers all 16 real MeshParts and their textures.
	waitFor(function()
		for _, row in ipairs(report.assetLoads) do if not row.done then return false end end
		return true
	end, 45)
	for _, row in ipairs(report.assetLoads) do
		local successful = {}
		local failed = false
		for _, callback in ipairs(row.callbacks) do
			if callback.id == row.meshId or callback.id == row.textureId then
				if callback.status == "Enum.AssetFetchStatus.Success" then successful[callback.id] = true
				else failed = true end
			end
		end
		if not row.done then
			row.outcome = "timeout"
			pcall(task.cancel, threads[row])
		elseif row.error then row.outcome = "error"
		elseif failed then row.outcome = "failure"
		elseif not successful[row.meshId] or not successful[row.textureId] then row.outcome = "missing_callback"
		else row.outcome = "success" end
		check(row.outcome == "success", "actual mesh and texture preload: " .. row.name .. ": " .. row.outcome)
	end
end
local errorsConnection = LogService.MessageOut:Connect(function(message, messageType)
	if messageType == Enum.MessageType.MessageError then table.insert(report.runtimeErrors, message) end
end)
local started = false
local ok, err = xpcall(function()
	check(Players.CharacterAutoLoads == false, "CharacterAutoLoads=false is serialized before players can join")
	local templates = ServerStorage:FindFirstChild("TdMonsterModels")
	check(templates and templates:IsA("Folder"), "vendored TD runtime folder is serialized in ServerStorage")
	assert(templates, "missing actual TD runtime templates")
	for kind, spec in pairs(TD_EXPECTED) do
		local template = templates:FindFirstChild(spec.template)
		check(template and template:IsA("Model") and #meshParts(template) == (if kind == "Slime" then 1 else 5), kind .. " source template part count")
	end
	for _, item in templates:GetDescendants() do
		if item:IsA("LuaSourceContainer") then check(false, "vendored templates contain executable scripts") end
	end
	-- Module bodies are required in Edit; presentation start/create methods are
	-- intentionally not called because this is not a LocalPlayer client.
	for _, container in { ReplicatedStorage.Shared, ServerScriptService.Server, game:GetService("StarterPlayer").StarterPlayerScripts } do
		for _, item in container:GetDescendants() do
			if item:IsA("ModuleScript") then
				local success, result = pcall(require, item)
				check(success, "ModuleScript require: " .. item:GetFullName() .. ": " .. tostring(result))
				if success then table.insert(report.compiledModules, item:GetFullName()) end
			end
		end
	end
	-- Parse the complete entry sources through the native compiler without
	-- executing either bootstrap in Edit or faking Players.LocalPlayer.
	for _, source in { ServerScriptService.Server, game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("Client") } do
		assert(source and source:IsA("LuaSourceContainer"), "entry source missing")
		local wrapper = Instance.new("ModuleScript")
		wrapper.Name = "K0CompileOnly"
		wrapper.Source = "if true then return true end\n" .. source.Source
		wrapper.Parent = ServerStorage
		local success, result = pcall(require, wrapper)
		check(success and result == true, "Entry compilation: " .. source:GetFullName() .. ": " .. tostring(result))
		wrapper:Destroy()
	end
	RunService:Run()
	started = true
	check(RunService:IsRunning(), "RunService entered simulation")
	local field = waitFor(function() return workspace:FindFirstChild("DeepwoodK0") end, 10)
	check(field ~= nil, "server creates DeepwoodK0")
	assert(field, "no training field after server startup")
	local enemies = field:FindFirstChild("Enemies")
	check(enemies and enemies:IsA("Folder"), "enemy folder exists")
	assert(enemies, "no enemies")
	local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("K0Action")
	check(remote and remote:IsA("RemoteEvent"), "server creates K0Action RemoteEvent")
	local hitRemote = ReplicatedStorage.Remotes:FindFirstChild("K0HitEffect")
	check(hitRemote and hitRemote:IsA("RemoteEvent"), "server creates confirmed-hit presentation RemoteEvent")
	check(field:FindFirstChild("Spawn") and field.Spawn:IsA("SpawnLocation"), "safe spawn exists")
	local lobby = waitFor(function() return workspace:FindFirstChild("DawnspireLobbyPrototype") end, 10)
	check(lobby and lobby:IsA("Model") and lobby:GetAttribute("TLTLobbyWorld") == true, "server creates owned Dawnspire lobby")
	assert(lobby, "no Dawnspire lobby after server startup")
	local lobbySpawn = lobby:FindFirstChild("Spawn")
	check(lobbySpawn and lobbySpawn:IsA("SpawnLocation") and lobbySpawn.Enabled and lobbySpawn.Neutral and lobbySpawn.Anchored,
		"lobby has enabled anchored neutral safe spawn")
	local ground = lobby:FindFirstChild("Ground")
	check(ground and ground:IsA("BasePart") and ground.Anchored and ground.CanCollide, "lobby has solid anchored ground")
	if ground and lobbySpawn then
		local ray = RaycastParams.new()
		ray.FilterType, ray.FilterDescendantsInstances = Enum.RaycastFilterType.Include, { ground }
		local support = workspace:Raycast(lobbySpawn.Position + Vector3.new(0, 8, 0), Vector3.new(0, -20, 0), ray)
		check(support and support.Instance == ground, "lobby spawn stands above its continuous ground")
		check((lobbySpawn.Position - field.Spawn.Position).Magnitude > 100, "lobby is spatially separated from training enemies")
		report.lobby = { spawnX = lobbySpawn.Position.X, spawnY = lobbySpawn.Position.Y, spawnZ = lobbySpawn.Position.Z,
			trainingDistance = (lobbySpawn.Position - field.Spawn.Position).Magnitude }
	end
	local bounds = lobby:FindFirstChild("SafetyBounds")
	check(bounds and bounds:IsA("Folder") and #bounds:GetChildren() == 4, "lobby has four safety boundaries")
	if bounds then
		for _, barrier in ipairs(bounds:GetChildren()) do
			check(barrier:IsA("BasePart") and barrier.Anchored and barrier.CanCollide and barrier.CanQuery, "solid lobby safety boundary " .. barrier.Name)
		end
	end
	for _, name in ipairs({ "K0HeroRequest", "K0HeroState" }) do
		local lobbyRemote = ReplicatedStorage.Remotes:FindFirstChild(name)
		check(lobbyRemote and lobbyRemote:IsA("RemoteEvent"), "server creates lobby remote " .. name)
	end
	local sameLobby = require(ServerScriptService.Server.World.LobbyWorld).create()
	check(sameLobby.folder == lobby and sameLobby.spawn == lobbySpawn, "repeated lobby create returns same validated scene/spawn")
	local config = require(ReplicatedStorage.Shared.K0Config)
	check(#enemies:GetChildren() == 4, "exactly four initial enemies")
	check(enemies:FindFirstChild("Slime") ~= nil, "Slime enters tutorial combat")
	task.wait(2)
	local actualParts = {}
	local firstVisuals = {}
	for _, kind in COMBAT_KINDS do
		local model = enemies:FindFirstChild(kind)
		local humanoid = model and model:FindFirstChildOfClass("Humanoid")
		local root = model and model:FindFirstChild("HumanoidRootPart")
		check(model and humanoid and root, kind .. " has native rig")
		if humanoid and root then
			check(humanoid.Health == config.Enemy[kind].health and humanoid.MaxHealth == config.Enemy[kind].health, kind .. " server health preset")
			check(model:GetAttribute("EnemyKind") == kind, kind .. " explicit combat identity without fallback")
			check(model:GetAttribute("K0Posture") == config.Enemy[kind].posture, kind .. " posture initialized")
			check(model:GetAttribute("K0EnemyState") == "Idle", kind .. " idle without Players")
			check(root.Position.Y > 0 and root.Position.Y < 12, kind .. " stays above continuous ground")
			check(root.AssemblyLinearVelocity.Magnitude < 2, kind .. " settles physically")
			report.enemies[kind] = { health = humanoid.Health, posture = model:GetAttribute("K0Posture"), y = root.Position.Y, speed = root.AssemblyLinearVelocity.Magnitude }
			local bar = model:FindFirstChild("EnemyHealthBar")
			local background = bar and bar:FindFirstChild("HpBg")
			local value = background and background:FindFirstChild("HpValue")
			check(bar and bar:IsA("BillboardGui") and bar.Adornee == root and bar.Enabled, kind .. " has a visible overhead health bar")
			local visualHeight = model:GetAttribute("TdMonsterTargetHeight")
			check(bar and root and visualHeight and math.abs(bar.StudsOffsetWorldSpace.Y - (visualHeight - root.Size.Y * 1.5 + 1.45)) < 0.001, kind .. " health bar tracks scaled visual height")
			check(value and value.Text == string.format("%d / %d", config.Enemy[kind].health, config.Enemy[kind].health), kind .. " health bar shows authoritative numeric HP")
		end
		local visual = checkVisual(model, kind, kind)
		firstVisuals[kind] = visual
		for _, part in meshParts(visual) do table.insert(actualParts, { name = kind .. "." .. part.Name, part = part }) end
	end
	local ogreVisual = firstVisuals.Ogre
	local orcVisual = firstVisuals.Orc
	assert(ogreVisual and orcVisual, "both original TD visuals required for scale comparison")
	local _, ogreBounds = ogreVisual:GetBoundingBox()
	local _, orcBounds = orcVisual:GetBoundingBox()
	check(ogreBounds.Y >= orcBounds.Y * 1.4, "Ogre visual remains substantially taller than Orc")
	local ogreRoot = enemies.Ogre:FindFirstChild("HumanoidRootPart")
	local orcRoot = enemies.Orc:FindFirstChild("HumanoidRootPart")
	check(ogreRoot and orcRoot and ogreRoot.Size.Y >= orcRoot.Size.Y * 1.4, "Ogre collision rig scales with its appearance")
	report.sizeComparison = { ogreHeight = ogreBounds.Y, orcHeight = orcBounds.Y,
		ogreRootHeight = ogreRoot and ogreRoot.Size.Y, orcRootHeight = orcRoot and orcRoot.Size.Y }
	local appearance = require(ServerScriptService.Server.World.TdMonsterAppearance)
	for kind, spec in pairs(TD_EXPECTED) do
		local description = appearance.describe(kind)
		check(description.template == spec.template and math.abs(description.targetHeight - spec.height) < 0.0001
			and #description.parts == (if kind == "Slime" then 1 else 5), kind .. " adapter description matches source")
	end
	-- A root-only Slime fixture exercises the same adapter without Humanoid,
	-- EnemyKind or an enemy-folder parent, and therefore never enters combat.
	local slimeRig = Instance.new("Model")
	slimeRig.Name = "QA_SlimeAppearanceOnly"
	local slimeRoot = Instance.new("Part")
	slimeRoot.Name = "HumanoidRootPart"
	slimeRoot.Anchored = true
	slimeRoot.Parent = slimeRig
	slimeRig.PrimaryPart = slimeRoot
	slimeRig.Parent = ServerStorage
	local slimeVisual = appearance.attach(slimeRig, "Slime", 0, 1.44)
	check(checkVisual(slimeRig, "Slime", "Slime adapter fixture") == slimeVisual, "Slime adapter returns its attached model")
	check(slimeRig:FindFirstChildOfClass("Humanoid") == nil and slimeRig:GetAttribute("EnemyKind") == nil and #enemies:GetChildren() == 4,
		"Slime visual-only fixture does not enter combat")
	check(#actualParts == 16, "preload exercises all fifteen humanoid enemy parts plus the live Slime part")
	preloadActualParts(actualParts)
	slimeRig:Destroy()
	-- A separate native Humanoid cannot be reset by the training enemy AI.
	local healthRig = Instance.new("Model"); healthRig.Name = "QA_EnemyHealth"; healthRig.Parent = workspace
	local healthRoot = Instance.new("Part"); healthRoot.Name = "HumanoidRootPart"; healthRoot.Anchored = true; healthRoot.Parent = healthRig
	local healthHumanoid = Instance.new("Humanoid"); healthHumanoid.MaxHealth = 100; healthHumanoid.Health = 100; healthHumanoid.Parent = healthRig
	local healthBar = require(ServerScriptService.Server.World.EnemyHealthBar).attach(healthRig, healthHumanoid)
	check(healthBar.Size == UDim2.fromOffset(96, 30) and healthBar.HpBg.Size.Y.Offset == 14, "overhead bar uses compact dimensions")
	check(math.abs(healthBar.StudsOffsetWorldSpace.Y - (4 - healthRoot.Size.Y * 1.5 + 1.45)) < 0.001, "health bar has additional clearance above the head")
	local fill, value = healthBar.HpBg.HpFill, healthBar.HpBg.HpValue
	for _, sample in ipairs({ { 75, Color3.fromRGB(90, 220, 90) }, { 50, Color3.fromRGB(230, 200, 70) }, { 25, Color3.fromRGB(230, 80, 80) } }) do
		healthHumanoid.Health = sample[1]
		check(waitFor(function() return value.Text == string.format("%d / 100", sample[1]) end, 2), "health value updates at " .. sample[1])
		check(math.abs(fill.Size.X.Scale - sample[1] / 100) < 0.001 and fill.BackgroundColor3 == sample[2], "TD color/fill at " .. sample[1])
	end
	healthHumanoid.Health = 0
	check(waitFor(function() return not healthBar.Enabled end, 2), "overhead health bar disappears when enemy dies")
	healthRig:Destroy()
	for _, kind in COMBAT_KINDS do
		local original = assert(enemies:FindFirstChild(kind))
		local originalVisual = assert(original:FindFirstChild("TdMonsterVisual"))
		local originalParts = {}
		for _, part in meshParts(originalVisual) do originalParts[part.Name] = part end
		local deathAt = os.clock()
		local originalRoot = original:FindFirstChild("HumanoidRootPart")
		local originalRootSize = originalRoot.Size
		local originalSlimeSize = kind == "Slime" and originalVisual.Body.Size or nil
		original:FindFirstChildOfClass("Humanoid").Health = 0
		if kind == "Slime" then
			local function children()
				local list = {}
				for _, child in ipairs(enemies:GetChildren()) do
					if child:GetAttribute("SlimeSplitGeneration") == 1 then table.insert(list, child) end
				end
				return list
			end
			local split = waitFor(function() local list = children(); return #list == 2 and list end, 3)
			check(split ~= nil, "Slime splits into exactly two children")
			if split then
				for _, child in ipairs(split) do
					local h = child:FindFirstChildOfClass("Humanoid")
					local r = child:FindFirstChild("HumanoidRootPart")
					local visual = child:FindFirstChild("TdMonsterVisual")
					check(h and h.Health == 55 and h.MaxHealth == 55 and h.DisplayName == "Small Slime", "child has quarter parent health and English label")
					check(r and math.abs(r.Size.Y / originalRootSize.Y - 0.5) < 0.001, "child control rig has half height")
					check((visual.Body.Size - originalSlimeSize * 0.5).Magnitude < 0.001, "child TD mesh has half dimensions")
					local bar = child:FindFirstChild("EnemyHealthBar")
					check(bar and bar.Enabled and bar.HpBg.HpValue.Text == "55 / 55", "child health bar uses its own health")
					check(bar and r and math.abs(bar.StudsOffsetWorldSpace.Y - (child:GetAttribute("TdMonsterTargetHeight") - r.Size.Y * 1.5 + 1.45)) < 0.001, "split health bar tracks scaled child visual")
				end
				task.wait(config.Enemy.Slime.respawnTime + 0.2)
				check(enemies:FindFirstChild("Slime") == original, "parent does not respawn while split children live")
				split[1].Humanoid.Health = 0
				waitFor(function() return not split[1].Parent end, 3)
				check(#children() == 1, "first child death produces no further split")
				check(enemies:FindFirstChild("Slime") == original, "parent still waits for the surviving child")
				split[2].Humanoid.Health = 0
				check(waitFor(function() return #children() == 0 end, 3), "both split children retire without respawning")
			end
		end
		local replacement = waitFor(function()
			local model = enemies:FindFirstChild(kind)
			return model and model ~= original and model
		end, config.Enemy[kind].respawnTime + 3)
		check(replacement ~= nil, "dead " .. kind .. " replaced after configured respawn")
		if replacement then
			local humanoid = replacement:FindFirstChildOfClass("Humanoid")
			check(humanoid and humanoid.Health == config.Enemy[kind].health and humanoid.MaxHealth == config.Enemy[kind].health, kind .. " respawn restores server health")
			check(replacement:GetAttribute("K0EnemyState") == "Idle" and replacement:GetAttribute("K0Posture") == config.Enemy[kind].posture, kind .. " respawn initializes AI and posture")
			check(replacement:FindFirstChild("EnemyHealthBar") ~= nil, kind .. " respawn has a new overhead health display")
			check(#enemies:GetChildren() == 4, kind .. " respawn does not duplicate enemy")
			local replacementVisual = checkVisual(replacement, kind, kind .. " respawn")
			check(replacementVisual and replacementVisual ~= originalVisual, kind .. " respawn creates a fresh TD visual model")
			if replacementVisual then
				for name, part in pairs(originalParts) do
					check(replacementVisual:FindFirstChild(name) ~= part, kind .. " respawn clones fresh MeshPart " .. name)
				end
			end
			firstVisuals[kind] = replacementVisual
			for _, otherKind in COMBAT_KINDS do
				if otherKind ~= kind then
					local other = enemies:FindFirstChild(otherKind)
					check(other and other:FindFirstChild("TdMonsterVisual") == firstVisuals[otherKind], kind .. " respawn preserves " .. otherKind .. " appearance")
				end
			end
			task.wait(1)
			local root = replacement:FindFirstChild("HumanoidRootPart")
			check(root and root.Position.Y > 0 and root.Position.Y < 12 and root.AssemblyLinearVelocity.Magnitude < 2, kind .. " respawn settles on continuous ground")
			report.respawns[kind] = { seconds = os.clock() - deathAt, health = humanoid and humanoid.Health, y = root and root.Position.Y }
		end
	end
	report.players = #Players:GetPlayers()
	check(report.players == 0, "native Run has no Player; it cannot detect the 0.1.0 initial-spawn defect or validate the spawn fix")
	check(#report.runtimeErrors == 0, "no native runtime errors during smoke")
end, debug.traceback)
if not ok then table.insert(report.failures, tostring(err)) end
if started then RunService:Stop() end
errorsConnection:Disconnect()
report.pass = #report.failures == 0
print("K0_NATIVE_SMOKE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 native smoke failed; see K0_NATIVE_SMOKE report")
