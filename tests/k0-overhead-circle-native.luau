-- Simulated physical frame evidence; actual Player/latency/visual acceptance are separate.
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Http = game:GetService("HttpService")
local visual = require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local appearance = require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "isolated place required")
local report = {kind = "K0_OVERHEAD_CIRCLE_NATIVE", checks = 0, failures = {}, samples = {}}
local function check(value, label) report.checks += 1; assert(value, label) end
local ok, err = xpcall(function()
	if not Run:IsRunning() then Run:Run() end
	for _, rig in ipairs({Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15}) do
		local desc = Instance.new("HumanoidDescription")
		local character = Players:CreateHumanoidModelFromDescriptionAsync(desc, rig); desc:Destroy()
		character.Parent = workspace; character:PivotTo(CFrame.new(0, 100, 0)); character.HumanoidRootPart.Anchored = true
		for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
		local model = Instance.new("Model"); model.Parent = character
		local weapon = assert(appearance.attachInto(model, character, "dwarf"))
		character:SetAttribute("K0ClassId", "dwarf"); character:SetAttribute("K0State", "Attack")
		character:SetAttribute("K0AttackPhase", "Windup"); character:SetAttribute("K0AttackKind", "Basic")
		character:SetAttribute("K0SkillId", "dwarf.common.overhead"); character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow())
		local connection = Run.PreSimulation:Connect(function(dt) visual.renderArms(character, dt); visual.renderCharacter(character, dt) end)
		local minX, maxX, minZ, maxZ, minY = math.huge, -math.huge, math.huge, -math.huge, math.huge
		for _ = 1, 5 do
			task.wait(0.12)
			local point = character.Head.CFrame:PointToObjectSpace(weapon.tip.WorldPosition)
			minX, maxX, minZ, maxZ, minY = math.min(minX, point.X), math.max(maxX, point.X), math.min(minZ, point.Z), math.max(maxZ, point.Z), math.min(minY, point.Y)
		end
		check(minY > 0.5, rig.Name .. " axe tip remains above head")
		check(minX < -0.3 and maxX > 1.5, rig.Name .. " axe tip travels left and right")
		check(minZ < -0.5 and maxZ > 0.5, rig.Name .. " axe tip travels front and back")
		table.insert(report.samples, {rig = rig.Name, minY = minY, xSpan = maxX-minX, zSpan = maxZ-minZ})
		connection:Disconnect(); character:Destroy()
	end
end, debug.traceback)
if not ok then table.insert(report.failures, tostring(err)) end
report.pass = #report.failures == 0
print("K0_OVERHEAD_CIRCLE_NATIVE " .. Http:JSONEncode(report))
assert(report.pass, "overhead circle fixture failed")
