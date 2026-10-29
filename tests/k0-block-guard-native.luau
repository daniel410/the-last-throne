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
			task.wait(1)
			local relative = character.Head.CFrame:PointToObjectSpace(weapon.grip.Position)
			check(relative.Z < -0.5, classId .. " grip in front of face")
			check(math.abs(relative.Y) < 0.8, classId .. " grip at face height")
			local shaft = weapon.grip.CFrame.UpVector
			check(math.abs(shaft.Y) < 0.1 and math.abs(shaft:Dot(root.CFrame.RightVector)) > 0.95, classId .. " weapon held horizontally across face")
			local side = classId == "elf" and "Right" or "Left"
			local hand = character:FindFirstChild(side .. (rigType == Enum.HumanoidRigType.R15 and "Hand" or " Arm"))
			local point = rigType == Enum.HumanoidRigType.R15 and hand.Position or hand.CFrame:PointToWorldSpace(Vector3.new(0, -hand.Size.Y * 0.5, 0))
			local target = assert(weapon.grip:FindFirstChild("K0BlockHandTarget"))
			local distance = (target.WorldPosition - point).Magnitude
			table.insert(result.samples, { rig = rigType.Name, class = classId, y = relative.Y, z = relative.Z, handDistance = distance })
			check(distance < 0.35, rigType.Name .. " " .. classId .. " free hand touches weapon: " .. tostring(distance))
			root.CFrame *= CFrame.Angles(0, math.rad(35), 0)
			task.wait(0.5)
			point = rigType == Enum.HumanoidRigType.R15 and hand.Position or hand.CFrame:PointToWorldSpace(Vector3.new(0, -hand.Size.Y * 0.5, 0))
			check((target.WorldPosition - point).Magnitude < 0.35, "hand tracks weapon when character turns")
			shaft = weapon.grip.CFrame.UpVector
			check(math.abs(shaft.Y) < 0.1 and math.abs(shaft:Dot(root.CFrame.RightVector)) > 0.95, "weapon remains horizontal when character turns")
			character:SetAttribute("K0State", "Idle"); task.wait(0.4)
			check(not weapon.grip:FindFirstChild("K0BlockHandTarget"), "contact target cleans up after guard")
			connection:Disconnect(); character:Destroy()
		end
	end
end, debug.traceback)
if not ok then table.insert(result.failures, tostring(err)) end
result.pass = #result.failures == 0
print("K0_BLOCK_GUARD_NATIVE " .. HttpService:JSONEncode(result))
assert(result.pass, "guard test failed")
