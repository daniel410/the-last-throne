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

local report = { kind = "K0_NATIVE_SMOKE", checks = 0, failures = {}, compiledModules = {}, runtimeErrors = {}, players = 0, enemies = {}, assetLoads = {}, spawnCoverage = "Spawn instance only; initial Player placement and respawn require real Play", assetCoverage = "Actual TD MeshParts in isolated Studio; published RPG permissions and visible Play presentation require separate evidence" }
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
	Goblin = { template = "goblin", height = 3.6, texture = "134919664038207", meshes = {
		Body = "77403549111699", ArmL = "127402469282462", ArmR = "106102430341786", LegL = "78392327157438", LegR = "100268725310905",
	} },
	Ogre = { template = "ogre", height = 6.05, texture = "90412861785322", meshes = {
		Body = "98618217378067", ArmL = "108622715572697", ArmR = "98353562560509", LegL = "76243711635467", LegR = "77089513742534",
	} },
	Slime = { template = "slime", height = 1.1, texture = "75994104212849", meshes = { Body = "84245584635347" } },
}
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
	check(math.abs((rig:GetAttribute("TdMonsterTargetHeight") or 0) - spec.height) < 0.0001, label .. " source TargetHeight recorded")
	local scale = rig:GetAttribute("TdMonsterScale")
	check(type(scale) == "number" and scale > 0 and scale < math.huge, label .. " finite positive visual scale")
	for name, id in pairs(spec.meshes) do
		local part = visual:FindFirstChild(name)
		check(part and part:IsA("MeshPart"), label .. " source part " .. name)
		if part and part:IsA("MeshPart") then
			check(numericId(part.MeshId) == id and numericId(part.TextureID) == spec.texture, label .. " original mesh/texture IDs " .. name)
			check(not part.Anchored and part.Massless and not part.CanCollide and not part.CanTouch and not part.CanQuery and part.Transparency == 0,
				label .. " presentation-only physics " .. name)
			local anchorName = if kind == "Slime" then "HumanoidRootPart" else ANCHORS[name]
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
	if kind ~= "Slime" then
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
	-- One 45-second deadline covers all 11 real MeshParts and their textures.
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
	check(field:FindFirstChild("Spawn") and field.Spawn:IsA("SpawnLocation"), "safe spawn exists")
	local config = require(ReplicatedStorage.Shared.K0Config)
	check(#enemies:GetChildren() == 2, "exactly two initial enemies")
	check(enemies:FindFirstChild("Slime") == nil, "Slime is not added to combat")
	task.wait(2)
	local actualParts = {}
	local firstVisuals = {}
	for _, kind in { "Goblin", "Ogre" } do
		local model = enemies:FindFirstChild(kind)
		local humanoid = model and model:FindFirstChildOfClass("Humanoid")
		local root = model and model:FindFirstChild("HumanoidRootPart")
		check(model and humanoid and root, kind .. " has native rig")
		if humanoid and root then
			check(humanoid.Health == config.Enemy[kind].health, kind .. " server health preset")
			check(model:GetAttribute("K0Posture") == config.Enemy[kind].posture, kind .. " posture initialized")
			check(model:GetAttribute("K0EnemyState") == "Idle", kind .. " idle without Players")
			check(root.Position.Y > 0 and root.Position.Y < 12, kind .. " stays above continuous ground")
			check(root.AssemblyLinearVelocity.Magnitude < 2, kind .. " settles physically")
			report.enemies[kind] = { health = humanoid.Health, y = root.Position.Y, speed = root.AssemblyLinearVelocity.Magnitude }
		end
		local visual = checkVisual(model, kind, kind)
		firstVisuals[kind] = visual
		for _, part in meshParts(visual) do table.insert(actualParts, { name = kind .. "." .. part.Name, part = part }) end
	end
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
	local slimeVisual = appearance.attach(slimeRig, "Slime", 0)
	check(checkVisual(slimeRig, "Slime", "Slime adapter fixture") == slimeVisual, "Slime adapter returns its attached model")
	check(slimeRig:FindFirstChildOfClass("Humanoid") == nil and slimeRig:GetAttribute("EnemyKind") == nil and #enemies:GetChildren() == 2,
		"Slime visual-only fixture does not enter combat")
	for _, part in meshParts(slimeVisual) do table.insert(actualParts, { name = "Slime." .. part.Name, part = part }) end
	check(#actualParts == 11, "preload exercises all ten enemy parts plus one Slime part")
	preloadActualParts(actualParts)
	slimeRig:Destroy()
	local oldGoblin = assert(enemies:FindFirstChild("Goblin"))
	oldGoblin:FindFirstChildOfClass("Humanoid").Health = 0
	local replacement = waitFor(function()
		local model = enemies:FindFirstChild("Goblin")
		return model and model ~= oldGoblin and model
	end, config.Enemy.Goblin.respawnTime + 3)
	check(replacement ~= nil, "dead Goblin replaced after configured respawn")
	if replacement then
		local humanoid = replacement:FindFirstChildOfClass("Humanoid")
		check(humanoid and humanoid.Health == config.Enemy.Goblin.health, "respawn restores server health")
		check(replacement:GetAttribute("K0EnemyState") == "Idle", "respawn initializes AI state")
		check(#enemies:GetChildren() == 2, "respawn does not duplicate enemy")
		local replacementVisual = checkVisual(replacement, "Goblin", "Goblin respawn")
		check(replacementVisual and replacementVisual ~= firstVisuals.Goblin, "respawn creates a fresh TD visual model")
		if replacementVisual and firstVisuals.Goblin then
			check(replacementVisual:FindFirstChild("Body") ~= firstVisuals.Goblin:FindFirstChild("Body"), "respawn clones fresh MeshParts")
		end
		check(enemies:FindFirstChild("Ogre"):FindFirstChild("TdMonsterVisual") == firstVisuals.Ogre, "Goblin respawn preserves Ogre appearance")
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
