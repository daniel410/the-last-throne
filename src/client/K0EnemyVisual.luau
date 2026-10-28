-- Temporary poses for the blockout R6 enemies. Server state remains authoritative.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EnemyVisual = {}

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
				local armAngle, offArmAngle, legAngle = 0, 0, 0
				local velocity = root.AssemblyLinearVelocity
				if state == "Chase" and Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 0.6 then
					legAngle = math.sin(os.clock() * 8) * 0.55
					armAngle, offArmAngle = -legAngle * 0.7, legAngle * 0.7
				elseif state == "Windup" then
					armAngle = 1.15
					offArmAngle = if model:GetAttribute("K0Telegraph") == "Unblockable" then 0.8 else 0.15
				elseif state == "Active" then
					armAngle = -1.35
					offArmAngle = if model:GetAttribute("K0Telegraph") == "Unblockable" then -0.9 else 0
				end
				rightArm.Transform = rightArm.Transform:Lerp(CFrame.Angles(armAngle, 0, 0), alpha)
				leftArm.Transform = leftArm.Transform:Lerp(CFrame.Angles(offArmAngle, 0, 0), alpha)
				rightLeg.Transform = rightLeg.Transform:Lerp(CFrame.Angles(legAngle, 0, 0), alpha)
				leftLeg.Transform = leftLeg.Transform:Lerp(CFrame.Angles(-legAngle, 0, 0), alpha)
			end
		end)
	end)
end

return EnemyVisual
