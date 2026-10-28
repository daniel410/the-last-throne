-- Native rig joint/foot kinematics for the local dodge presentation. This does
-- not test actual player movement, network, rendering, or invulnerability.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local visual = require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.K0SwordVisual)
local appearance = require(game:GetService("ServerScriptService").Server.Cosmetics.WeaponAppearance)
assert(game.PlaceId == 0, "Dodge pose fixture requires an unpublished local place")
local report = { kind = "K0_DODGE_POSE_NATIVE", checks = 0, samples = {}, failures = {},
	coverage = "Native R6/R15 joint and foot forward kinematics using production pose smoothing; no real Player, physics or rendering" }
local function check(value, label) report.checks += 1; assert(value, label) end
for _, rig in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
	for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
		local character
		local ok, err = xpcall(function()
			local description = Instance.new("HumanoidDescription")
			character = Players:CreateHumanoidModelFromDescriptionAsync(description, rig)
			description:Destroy()
			character.Parent = workspace
			character:PivotTo(CFrame.new(0, 500, 0))
			character:SetAttribute("K0ClassId", classId)
			character:SetAttribute("K0State", "Idle")
			local joints = {}
			for _, joint in ipairs(character:GetDescendants()) do
				if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) and joint.Part0 and joint.Part1 then joints[joint.Part1] = joint end
			end
			local function frame(part)
				local joint = joints[part]
				return joint and (frame(joint.Part0) * joint.C0 * joint.Transform * joint.C1:Inverse()) or part.CFrame
			end
			local root = character.HumanoidRootPart.CFrame
			local right = assert(character:FindFirstChild(rig == Enum.HumanoidRigType.R6 and "Right Leg" or "RightFoot"))
			local left = assert(character:FindFirstChild(rig == Enum.HumanoidRigType.R6 and "Left Leg" or "LeftFoot"))
			local rightBefore, leftBefore = root:PointToObjectSpace(frame(right).Position), root:PointToObjectSpace(frame(left).Position)
			character:SetAttribute("K0DodgeSeq", 1)
			character:SetAttribute("K0State", "Dodge")
			for _ = 1, 10 do visual.renderArms(character, 1 / 60) end
			local rightAfter, leftAfter = root:PointToObjectSpace(frame(right).Position), root:PointToObjectSpace(frame(left).Position)
			table.insert(report.samples, { rig = rig.Name, class = classId, rightBack = rightAfter.Z - rightBefore.Z, leftMovement = (leftAfter - leftBefore).Magnitude })
			check(rightAfter.Z - rightBefore.Z > 0.25, "right foot moves behind its idle position")
			check((leftAfter - leftBefore).Magnitude < 0.01, "left leg remains in its original pose")
			character:SetAttribute("K0State", "Idle")
			for _ = 1, 20 do visual.renderArms(character, 1 / 60) end
			local rightRestored = root:PointToObjectSpace(frame(right).Position)
			check((rightRestored - rightBefore).Magnitude < 0.01, "right leg returns to idle after dodge")
			character:SetAttribute("K0DodgeSeq", 2)
			character:SetAttribute("K0State", "Dodge")
			for _ = 1, 10 do visual.renderArms(character, 1 / 60) end
			local rightSecond, leftSecond = root:PointToObjectSpace(frame(right).Position), root:PointToObjectSpace(frame(left).Position)
			check(leftSecond.Z - leftBefore.Z > 0.25, "second dodge moves left foot backward")
			check((rightSecond - rightBefore).Magnitude < 0.01, "second dodge leaves right foot neutral")
			character:SetAttribute("K0State", "Idle")
			for _ = 1, 20 do visual.renderArms(character, 1 / 60) end
			check((root:PointToObjectSpace(frame(left).Position) - leftBefore).Magnitude < 0.01, "left leg returns after second dodge")
			character:SetAttribute("K0DodgeSeq", 3)
			character:SetAttribute("K0State", "Dodge")
			for _ = 1, 10 do visual.renderArms(character, 1 / 60) end
			check(root:PointToObjectSpace(frame(right).Position).Z - rightBefore.Z > 0.25, "third dodge returns to right foot")
		end, debug.traceback)
		if character then character:Destroy() end
		if not ok then table.insert(report.failures, rig.Name .. "/" .. classId .. ": " .. tostring(err)) end
	end
end
for _, rig in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
	local character
	local ok, err = xpcall(function()
		local description = Instance.new("HumanoidDescription")
		character = Players:CreateHumanoidModelFromDescriptionAsync(description, rig)
		description:Destroy()
		character.Parent = workspace
		character:PivotTo(CFrame.new(0, 500, 0))
		character:SetAttribute("K0ClassId", "knight")
		character:SetAttribute("K0State", "Idle")
		character:SetAttribute("K0AttackPhase", "None")
		local model = Instance.new("Model"); model.Parent = character
		local weapon = assert(appearance.attachInto(model, character, "knight"))
		local offset = weapon.grip.CFrame:ToObjectSpace(weapon.trailPart.CFrame)
		local joints = {}
		for _, joint in ipairs(character:GetDescendants()) do
			if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) and joint.Part0 and joint.Part1 then joints[joint.Part1] = joint end
		end
		local function frame(part)
			local joint = joints[part]
			return joint and (frame(joint.Part0) * joint.C0 * joint.Transform * joint.C1:Inverse()) or part.CFrame
		end
		local function bladeAxis()
			return character.HumanoidRootPart.CFrame:VectorToObjectSpace((frame(weapon.grip) * offset).UpVector)
		end
		local before = bladeAxis()
		for _ = 1, 15 do visual.renderCharacter(character, 1 / 60) end
		local after = bladeAxis()
		table.insert(report.samples, { rig = rig.Name, class = "knight", idleSwordBefore = tostring(before), idleSwordAfter = tostring(after) })
		check(after.Z < before.Z - 0.15, "idle knight blade tilts further forward")
		check(after.Z < -0.3, "idle knight blade points toward character front")
	end, debug.traceback)
	if character then character:Destroy() end
	if not ok then table.insert(report.failures, rig.Name .. "/idle-sword: " .. tostring(err)) end
end
report.pass = #report.failures == 0
print("K0_DODGE_POSE_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "Dodge pose fixture failed; see K0_DODGE_POSE_NATIVE")
