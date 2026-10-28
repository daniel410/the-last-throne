-- Temporary poses for the R6 control rig and its welded TD visual pieces.
-- Server state remains authoritative.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EnemyVisual = {}

local function legTransform(angle, part)
	-- Conservative clearance of the source mesh's bounding box during its
	-- hip rotation. Presentation only; server position and collision stay put.
	local lift = 0
	if part and part:IsA("MeshPart") then
		lift = math.max(0, part.Size.Z * 0.5 * math.abs(math.sin(angle)) - part.Size.Y * (1 - math.cos(angle)))
	end
	return CFrame.new(0, lift, 0) * CFrame.Angles(angle, 0, 0)
end

function EnemyVisual.start()
	task.spawn(function()
		local field = Workspace:WaitForChild("DeepwoodK0", 30)
		local enemies = field and field:WaitForChild("Enemies", 10)
		if not enemies then return end
		RunService.RenderStepped:Connect(function(dt)
			local alpha = math.clamp(dt * 15, 0, 1)
			for _, model in enemies:GetChildren() do
				local torso = model:FindFirstChild("Torso")
				local root = model:FindFirstChild("HumanoidRootPart")
				if not torso or not root then continue end
				local rightArm = torso:FindFirstChild("Right Shoulder")
				local leftArm = torso:FindFirstChild("Left Shoulder")
				local rightLeg = torso:FindFirstChild("Right Hip")
				local leftLeg = torso:FindFirstChild("Left Hip")
				if not rightArm or not leftArm or not rightLeg or not leftLeg then continue end
				local state = model:GetAttribute("K0EnemyState")
				local rightAngle, leftAngle, legAngle = 0, 0, 0
				local velocity = root.AssemblyLinearVelocity
				if state == "Chase" and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.6 then
					legAngle = math.sin(os.clock() * 8) * 0.35
					rightAngle, leftAngle = -legAngle * 0.7, legAngle * 0.7
				elseif state == "Windup" or state == "Active" then
					local weapon = if state == "Windup" then 1.15 else -1.35
					local offHand = if model:GetAttribute("K0Telegraph") == "Unblockable"
						then (if state == "Windup" then 0.8 else -0.9) else (if state == "Windup" then 0.15 else 0)
					if model:GetAttribute("TdWeaponShoulder") == "Left Shoulder" then
						leftAngle, rightAngle = weapon, offHand
					else
						rightAngle, leftAngle = weapon, offHand
					end
				end
				rightArm.Transform = rightArm.Transform:Lerp(CFrame.Angles(rightAngle, 0, 0), alpha)
				leftArm.Transform = leftArm.Transform:Lerp(CFrame.Angles(leftAngle, 0, 0), alpha)
				local visual = model:FindFirstChild("TdMonsterVisual")
				local meshRight = visual and visual:FindFirstChild("LegL")
				local meshLeft = visual and visual:FindFirstChild("LegR")
				rightLeg.Transform = rightLeg.Transform:Lerp(legTransform(legAngle, meshRight), alpha)
				leftLeg.Transform = leftLeg.Transform:Lerp(legTransform(-legAngle, meshLeft), alpha)
			end
		end)
	end)
end

return EnemyVisual
