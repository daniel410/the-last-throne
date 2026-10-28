-- Isolated Studio fixture: evaluate real R6/R15 joint transforms and authored
-- weapon offsets. This is forward kinematics, not a Player/rendering test.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local visual = require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.K0SwordVisual)
local appearance = require(game:GetService("ServerScriptService").Server.Cosmetics.WeaponAppearance)
assert(game.PlaceId == 0, "Melee motion fixture requires an unpublished place")
local report = { kind = "K0_MELEE_MOTION_NATIVE", checks = 0, samples = {}, failures = {},
	coverage = "Native R6/R15 joint and weapon forward kinematics with production poses and 60Hz smoothing; no real Player, physics, rendering or latency" }
local function check(condition, message)
	report.checks += 1
	assert(condition, message)
end
local function vector(v) return { x = v.X, y = v.Y, z = v.Z } end
for _, rig in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
	for _, classId in ipairs({ "knight", "dwarf", "mage" }) do
		for _, combo in ipairs(classId == "knight" and { 1, 2, 3 } or { 1 }) do
			local character
			local ok, message = xpcall(function()
				local description = Instance.new("HumanoidDescription")
				character = Players:CreateHumanoidModelFromDescriptionAsync(description, rig)
				description:Destroy()
				character.Parent = workspace
				character:PivotTo(CFrame.new(0, 500, 0))
				local model = Instance.new("Model"); model.Name = "MotionAppearance"; model.Parent = character
				local weapon = assert(appearance.attachInto(model, character, classId))
				character:SetAttribute("K0ClassId", classId)
				character:SetAttribute("K0State", "Attack")
				character:SetAttribute("K0AttackKind", "Basic")
				character:SetAttribute("K0Combo", combo)
				local joints = {}
				for _, joint in ipairs(character:GetDescendants()) do
					if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) and joint.Part0 and joint.Part1 then
						joints[joint.Part1] = joint
					end
				end
				local function frame(part)
					local joint = joints[part]
					if not joint then return part.CFrame end
					return frame(joint.Part0) * joint.C0 * joint.Transform * joint.C1:Inverse()
				end
				local bladeOffset = classId == "knight" and weapon.grip.CFrame:ToObjectSpace(weapon.trailPart.CFrame) or nil
				local function sample(phase, frames)
					character:SetAttribute("K0AttackPhase", phase)
					for _ = 1, frames do
						visual.renderArms(character, 1 / 60)
						visual.renderCharacter(character, 1 / 60)
					end
					local grip = frame(weapon.grip)
					local tip = classId == "knight" and (grip * bladeOffset):PointToWorldSpace(Vector3.new(0, weapon.trailPart.Size.Y / 2, 0))
						or grip:PointToWorldSpace(weapon.tip.Position)
					return character.HumanoidRootPart.CFrame:PointToObjectSpace(tip)
				end
				local windup, active = sample("Windup", 10), sample("Active", 6)
				table.insert(report.samples, { rig = rig.Name, class = classId, combo = combo, windup = vector(windup), active = vector(active) })
				check(windup.Z < 0 and active.Z < -1, classId .. " weapon stays in front during attack")
				if classId == "knight" then
					local direction = combo == 2 and -1 or 1
					check((active.X - windup.X) * direction > 6, "knight sweeps widely and alternates direction")
					check(math.abs(active.Y - windup.Y) < 1, "knight stroke remains broadly horizontal")
				elseif classId == "dwarf" then
					check(windup.Y - active.Y > 2, "dwarf axe descends substantially from above")
					check(math.abs(active.X - windup.X) < 1, "dwarf stroke remains broadly vertical")
				else
					check(windup.Y - active.Y > 2 and windup.X - active.X > 2, "mage staff moves down and across diagonally")
				end
			end, debug.traceback)
			if character then character:Destroy() end
			if not ok then table.insert(report.failures, rig.Name .. "/" .. classId .. "/" .. combo .. ": " .. tostring(message)) end
		end
	end
end
report.pass = #report.failures == 0
print("K0_MELEE_MOTION_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "Melee motion fixture failed; see K0_MELEE_MOTION_NATIVE report")
