-- A temporary client-side pose and trail for the server-timed training sword.
-- The joint and effects never define the server's hit geometry.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SwordVisual = {}

function SwordVisual.start()
	local effects = {}
	local function effectFor(model)
		if effects[model] then return effects[model] end
		local grip = model:FindFirstChild("SwordGrip")
		local blade = model:FindFirstChild("SwordBlade")
		local joint = grip and grip:FindFirstChild("K0SwordJoint")
		if not joint or not joint:IsA("Motor6D") or not blade or not blade:IsA("BasePart") then return nil end
		local bottom = Instance.new("Attachment")
		bottom.Name = "K0TrailBottom"
		bottom.Position = Vector3.new(0, -blade.Size.Y / 2, 0)
		bottom.Parent = blade
		local top = Instance.new("Attachment")
		top.Name = "K0TrailTop"
		top.Position = Vector3.new(0, blade.Size.Y / 2, 0)
		top.Parent = blade
		local trail = Instance.new("Trail")
		trail.Name = "K0SwordTrail"
		trail.Attachment0, trail.Attachment1 = bottom, top
		trail.Lifetime = 0.15
		trail.LightEmission = 0.6
		trail.Color = ColorSequence.new(Color3.fromRGB(255, 235, 171), Color3.fromRGB(114, 183, 255))
		trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 1) })
		trail.Enabled = false
		trail.Parent = blade
		effects[model] = { joint = joint, trail = trail }
		return effects[model]
	end
	RunService.RenderStepped:Connect(function(dt)
		for model in effects do
			if not model:IsDescendantOf(game) then effects[model] = nil end
		end
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local model = character and character:FindFirstChild("TLT_K0_KnightAppearance")
			local effect = model and effectFor(model)
			if effect then
				local phase = character:GetAttribute("K0AttackPhase")
				local combo = character:GetAttribute("K0Combo") or 1
				local side = if combo == 2 then -1 else 1
				local target = CFrame.new()
				if phase == "Windup" then
					target = CFrame.Angles(math.rad(38), 0, math.rad(-25 * side))
				elseif phase == "Active" then
					target = CFrame.Angles(math.rad(-85), 0, math.rad(45 * side))
				elseif phase == "Recovery" then
					target = CFrame.Angles(math.rad(-10), 0, 0)
				end
				effect.joint.Transform = effect.joint.Transform:Lerp(target, math.clamp(dt * 22, 0, 1))
				effect.trail.Enabled = phase == "Active"
			end
		end
	end)
end

return SwordVisual
