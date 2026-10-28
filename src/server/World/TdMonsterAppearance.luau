-- TD Meshy runtime templates, mounted as presentation on K0's independent R6 rig.
-- No MeshId or texture is assigned at runtime: validated MeshParts are cloned.
local ServerStorage = game:GetService("ServerStorage")

local Appearance = {}
local SPECS = {
	Goblin = { template = "goblin", parts = { "Body", "ArmL", "ArmR", "LegL", "LegR" } },
	Orc = { template = "orc", parts = { "Body", "ArmL", "ArmR", "LegL", "LegR" } },
	Ogre = { template = "ogre", parts = { "Body", "ArmL", "ArmR", "LegL", "LegR" } },
	Slime = { template = "slime", parts = { "Body" } },
}

local function templateFor(kind)
	local spec = SPECS[kind]
	assert(spec, "Unsupported TD monster kind: " .. tostring(kind))
	local folder = ServerStorage:FindFirstChild("TdMonsterModels")
	assert(folder and folder:IsA("Folder"), "Missing ServerStorage.TdMonsterModels runtime folder")
	local template = folder:FindFirstChild(spec.template)
	assert(template and template:IsA("Model"), "Missing TD monster template: " .. spec.template)
	local target = template:FindFirstChild("TargetHeight")
	assert(target and target:IsA("NumberValue") and target.Value > 0 and target.Value < math.huge and target.Value == target.Value,
		"Missing or invalid TargetHeight: " .. spec.template)
	local expected = {}
	for _, partName in ipairs(spec.parts) do expected[partName] = true end
	local found = {}
	local count = 0
	for _, child in ipairs(template:GetChildren()) do
		if child:IsA("MeshPart") then
			assert(expected[child.Name] and not found[child.Name], "Unexpected or duplicate mesh part in " .. spec.template .. ": " .. child.Name)
			assert(child.Archivable and child.MeshId ~= "", "Missing or uncloneable mesh in " .. spec.template .. ": " .. child.Name)
			assert(child.Size.X > 0 and child.Size.Y > 0 and child.Size.Z > 0
				and child.Size.X < math.huge and child.Size.Y < math.huge and child.Size.Z < math.huge,
				"Invalid mesh size in " .. spec.template .. ": " .. child.Name)
			found[child.Name] = child
			count = count + 1
		end
	end
	assert(count == #spec.parts, "Missing TD mesh parts in " .. spec.template)
	local _, bounds = template:GetBoundingBox()
	assert(bounds.Y > 0 and bounds.Y < math.huge and bounds.Y == bounds.Y, "Invalid TD monster bounds: " .. spec.template)
	return spec, target.Value, found, target.Value / bounds.Y
end

function Appearance.describe(kind)
	local spec, height, _, scale = templateFor(kind)
	local names = {}
	for _, name in ipairs(spec.parts) do table.insert(names, name) end
	return { template = spec.template, targetHeight = height, sourceToStudScale = scale, parts = names }
end

function Appearance.attach(rig, kind, footOffset)
	assert(rig and rig:IsA("Model"), "TD monster visual requires a Model rig")
	assert(not rig:FindFirstChild("TdMonsterVisual"), "TD monster visual already attached")
	local root = rig:FindFirstChild("HumanoidRootPart")
	assert(root and root:IsA("BasePart"), "TD monster rig needs HumanoidRootPart")
	local spec, height, sources, scale = templateFor(kind)
	local offset = footOffset or root.Size.Y * 1.5
	assert(type(offset) == "number" and offset >= 0 and offset == offset and offset < math.huge,
		"Invalid TD monster foot offset")
	local torso = rig:FindFirstChild("Torso")
	local anchors = { Body = torso and torso:IsA("BasePart") and torso or root }
	local joints = {}
	if kind ~= "Slime" then
		-- TD templates face +Z; the Roblox humanoid faces -Z. Rotating the
		-- template 180 degrees swaps which R6-side controls each source limb.
		anchors.ArmL = rig:FindFirstChild("Right Arm")
		anchors.ArmR = rig:FindFirstChild("Left Arm")
		anchors.LegL = rig:FindFirstChild("Right Leg")
		anchors.LegR = rig:FindFirstChild("Left Leg")
		for _, name in ipairs(spec.parts) do
			assert(anchors[name] and anchors[name]:IsA("BasePart"), "Missing R6 visual anchor for " .. kind .. ": " .. name)
		end
		assert(torso and torso:IsA("BasePart"), "Missing R6 torso for " .. kind)
		local jointNames = { ArmL = "Right Shoulder", ArmR = "Left Shoulder", LegL = "Right Hip", LegR = "Left Hip" }
		for partName, jointName in pairs(jointNames) do
			local joint = torso:FindFirstChild(jointName)
			assert(joint and joint:IsA("Motor6D") and joint.Part0 == torso and joint.Part1 == anchors[partName],
				"Missing R6 joint for " .. kind .. ": " .. jointName)
			joints[partName] = joint
		end
	end
	local feet = root.CFrame * CFrame.new(0, -offset, 0) * CFrame.Angles(0, math.pi, 0)
	local visual = Instance.new("Model")
	visual.Name = "TdMonsterVisual"
	local ok, err = pcall(function()
		for _, name in ipairs(spec.parts) do
			local source = sources[name]
			local part = source:Clone()
			assert(part and part:IsA("MeshPart"), "Could not clone TD mesh part: " .. name)
			-- Preserve the source mesh, texture and SurfaceAppearance. Metadata,
			-- constraints and scripts from the source do not enter the rig.
			for _, child in ipairs(part:GetChildren()) do
				if not child:IsA("SurfaceAppearance") then child:Destroy() end
			end
			part.Name = name
			part.Size = source.Size * scale
			part.CFrame = feet * CFrame.new(source.CFrame.Position * scale) * source.CFrame.Rotation
			part.Anchored = false
			part.Massless = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Parent = visual
			local weld = Instance.new("WeldConstraint")
			weld.Name = "TdVisualWeld"
			weld.Part0 = anchors[name]
			weld.Part1 = part
			weld.Parent = part
		end
	end)
	if not ok then
		visual:Destroy()
		error("Could not attach TD " .. kind .. " appearance: " .. tostring(err))
	end
	-- Rotate around the source limb's actual upper bound, like TD's split-mesh
	-- pivots. Recomputing both C0 and C1 keeps the existing R6 rest pose intact.
	for partName, joint in pairs(joints) do
		local part = visual:FindFirstChild(partName)
		local pivotPosition = part.Position + part.CFrame.UpVector * (part.Size.Y / 2)
		local pivot = CFrame.new(pivotPosition) * root.CFrame.Rotation
		joint.C0 = joint.Part0.CFrame:ToObjectSpace(pivot)
		joint.C1 = joint.Part1.CFrame:ToObjectSpace(pivot)
	end
	-- These parts remain available for Humanoid, Motor6D and server hit logic.
	for _, name in ipairs({ "HumanoidRootPart", "Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }) do
		local part = rig:FindFirstChild(name)
		if part and part:IsA("BasePart") then part.Transparency = 1 end
	end
	visual.Parent = rig
	rig:SetAttribute("TdMonsterTemplate", spec.template)
	rig:SetAttribute("TdMonsterTargetHeight", height)
	rig:SetAttribute("TdMonsterScale", scale)
	rig:SetAttribute("TdWeaponShoulder", kind == "Slime" and "None" or "Left Shoulder")
	return visual
end

return Appearance
