-- Held melee-weapon presentation driven by server combat attributes. Dwarf
-- axes and Mage staves stay in the hand; this module never spawns projectiles,
-- chooses a class or determines the server's hit geometry.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Visual = {}
local started = false
local effects = {}
local MELEE = {
	knight = { grip = "SwordGrip", joint = "K0SwordJoint", windup = 38, active = -85, recovery = -10, side = 45 },
	dwarf = { grip = "WeaponGrip", joint = "PlayerWeaponJoint", windup = 58, active = -105, recovery = -15, side = 60 },
	mage = { grip = "WeaponGrip", joint = "PlayerWeaponJoint", windup = 32, active = -92, recovery = -8, side = 48 },
}


local function classFor(model)
	local classId = model:GetAttribute("WeaponClassId")
	-- The explicitly marked temporary Knight fallback predates class metadata.
	if classId == nil and model.Name == "TLT_K0_KnightAppearance" then classId = "knight" end
	return classId
end

local function clearEffect(model)
	local previous = effects[model]
	if previous then
		previous.trail:Destroy()
		effects[model] = nil
	end
end

local function swordEffect(model, joint)
	local blade = model:FindFirstChild("SwordBlade")
	if not blade or not blade:IsA("BasePart") then clearEffect(model); return nil end
	local previous = effects[model]
	if previous and previous.joint == joint and previous.blade == blade and previous.trail.Parent == blade then return previous end
	clearEffect(model)
	local bottom = blade:FindFirstChild("K0TrailBottom")
	if not bottom or not bottom:IsA("Attachment") then
		bottom = Instance.new("Attachment")
		bottom.Name = "K0TrailBottom"
		bottom.Position = Vector3.new(0, -blade.Size.Y / 2, 0)
		bottom.Parent = blade
	end
	local top = blade:FindFirstChild("K0TrailTop")
	if not top or not top:IsA("Attachment") then
		top = Instance.new("Attachment")
		top.Name = "K0TrailTop"
		top.Position = Vector3.new(0, blade.Size.Y / 2, 0)
		top.Parent = blade
	end
	local trail = Instance.new("Trail")
	trail.Name = "K0SwordTrail"
	trail.Attachment0, trail.Attachment1 = bottom, top
	trail.Lifetime = 0.15
	trail.LightEmission = 0.6
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 235, 171), Color3.fromRGB(114, 183, 255))
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 1) })
	trail.Enabled = false
	trail.Parent = blade
	local effect = { joint = joint, blade = blade, trail = trail }
	effects[model] = effect
	return effect
end

function Visual.samplePose(classId, phase, combo)
	local spec = MELEE[classId]
	if not spec then return nil end
	local side = combo == 2 and -1 or 1
	if phase == "Windup" then
		return CFrame.Angles(math.rad(spec.windup), 0, math.rad(-25 * side))
	elseif phase == "Active" then
		return CFrame.Angles(math.rad(spec.active), 0, math.rad(spec.side * side))
	elseif phase == "Recovery" then
		return CFrame.Angles(math.rad(spec.recovery), 0, 0)
	end
	return CFrame.new()
end

-- Native fixtures may call this directly without installing a class-selection
-- flow or making a preview character a persistent RPG character.
function Visual.render(model, phase, combo, dt)
	local classId = classFor(model)
	local spec = MELEE[classId]
	if not spec then clearEffect(model); return false end
	local grip = model:FindFirstChild(spec.grip)
	local joint = grip and grip:FindFirstChild(spec.joint)
	if not grip or not grip:IsA("BasePart") or not joint or not joint:IsA("Motor6D") or joint.Part1 ~= grip then
		clearEffect(model)
		return false
	end
	local elapsed = type(dt) == "number" and dt == dt and dt > 0 and dt < math.huge and dt or 1 / 60
	local target = Visual.samplePose(classId, phase, combo)
	joint.Transform = joint.Transform:Lerp(target, math.clamp(elapsed * 22, 0, 1))
	if classId == "knight" then
		local effect = swordEffect(model, joint)
		if effect then effect.trail.Enabled = phase == "Active" end
	else
		clearEffect(model)
	end
	return true
end

function Visual.renderCharacter(character, dt)
	local classId = character:GetAttribute("K0ClassId") or "knight"
	local rendered = 0
	for _, model in ipairs(character:GetChildren()) do
		if model:IsA("Model") and classFor(model) == classId then
			if Visual.render(model, character:GetAttribute("K0AttackPhase"), character:GetAttribute("K0Combo"), dt) then
				rendered = rendered + 1
			end
		elseif model:IsA("Model") and effects[model] then
			clearEffect(model)
		end
	end
	return rendered
end

function Visual.start()
	if started then return end
	started = true
	RunService.RenderStepped:Connect(function(dt)
		for model in pairs(effects) do
			if not model:IsDescendantOf(game) then clearEffect(model) end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then Visual.renderCharacter(player.Character, dt) end
		end
	end)
end

return Visual
