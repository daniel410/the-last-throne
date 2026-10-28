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

assert(game.PlaceId == 0, "K0 smoke requires an unpublished local test place")
assert(not RunService:IsRunning(), "K0 smoke requires an idle isolated Studio")
assert(ReplicatedStorage:FindFirstChild("Shared") and ReplicatedStorage.Shared:FindFirstChild("K0Config"), "K0 shared sources missing")
assert(ServerScriptService:FindFirstChild("Server"), "K0 server bootstrap missing")

local report = { kind = "K0_NATIVE_SMOKE", checks = 0, failures = {}, compiledModules = {}, runtimeErrors = {}, players = 0, enemies = {}, spawnCoverage = "Spawn instance only; initial Player placement and respawn require real Play" }
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
local errorsConnection = LogService.MessageOut:Connect(function(message, messageType)
	if messageType == Enum.MessageType.MessageError then table.insert(report.runtimeErrors, message) end
end)
local started = false
local ok, err = xpcall(function()
	check(Players.CharacterAutoLoads == false, "CharacterAutoLoads=false is serialized before players can join")
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
	task.wait(2)
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
	end
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
