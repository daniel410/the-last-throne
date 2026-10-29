-- Native simulated-frame guard geometry. This does not claim real Player input,
-- network replication, touch UX, or subjective visual acceptance.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "isolated place required")
local visual = require(StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local appearance = require(ServerScriptService.Server.Cosmetics.WeaponAppearance)
local result = { kind = "K0_BLOCK_GUARD_NATIVE", checks = 0, failures = {}, samples = {} }
local function check(value, label) result.checks += 1; assert(value, label) end
local ok, err = xpcall(function()
	if not RunService:IsRunning() then RunService:Run() end
	for _, rigType in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
		for _, classId in ipairs({ "dwarf", "elf", "mage" }) do
			local character = Players:CreateHumanoidModelFromDescriptionAsync(Instance.new("HumanoidDescription"), rigType)
			character.Parent = workspace
			local root = character.HumanoidRootPart
			character:PivotTo(CFrame.new(0, 100, 0)); root.Anchored = true
			for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
			local model = Instance.new("Model"); model.Parent = character
			local weapon = assert(appearance.attachInto(model, character, classId))
			character:SetAttribute("K0ClassId", classId); character:SetAttribute("K0State", "Block")
			character:SetAttribute("K0AttackPhase", "None")
			local connection = RunService.PreSimulation:Connect(function(dt) visual.renderArms(character, dt); visual.renderCharacter(character, dt) end)
			task.wait(0.4)
			local relative = character.Head.CFrame:PointToObjectSpace(weapon.grip.Position)
			check(relative.Z < -0.5, classId .. " grip in front of face")
			check(math.abs(relative.Y) < 0.8, classId .. " grip at face height")
			if rigType == Enum.HumanoidRigType.R15 then
				local ik = character.Humanoid:FindFirstChild("K0BlockHandIK")
				check(ik and ik.Enabled and ik.Target.Parent == weapon.grip, "free hand tracks equipped weapon")
			end
			table.insert(result.samples, { rig = rigType.Name, class = classId, y = relative.Y, z = relative.Z })
			connection:Disconnect(); character:Destroy()
		end
	end
end, debug.traceback)
if not ok then table.insert(result.failures, tostring(err)) end
result.pass = #result.failures == 0
print("K0_BLOCK_GUARD_NATIVE " .. HttpService:JSONEncode(result))
assert(result.pass, "guard test failed")
