-- A locally authored apprentice staff. Its parts are presentation only.
-- The grip is the origin so the class adapter can attach it to either rig.
local Builder = {}

local WOOD = Color3.fromRGB(105, 66, 41)
local WOOD_LIGHT = Color3.fromRGB(137, 90, 52)
local LEATHER = Color3.fromRGB(64, 43, 34)
local BRASS = Color3.fromRGB(154, 119, 64)
local CRYSTAL = Color3.fromRGB(148, 105, 187)

local function visualPart(model, grip, name, shape, size, frame, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape
	part.Size = size
	part.CFrame = frame
	part.Color = color
	part.Material = material
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Name = name .. "Weld"
	weld.Part0 = grip
	weld.Part1 = part
	weld.Parent = part
	return part
end

local function woodenBranch(model, grip, name, startPoint, endPoint, width)
	local midpoint = (startPoint + endPoint) * 0.5
	local frame = CFrame.lookAt(midpoint, endPoint) * CFrame.Angles(0, math.pi / 2, 0)
	return visualPart(model, grip, name, Enum.PartType.Cylinder,
		Vector3.new((endPoint - startPoint).Magnitude, width, width), frame, WOOD_LIGHT, Enum.Material.Wood)
end

function Builder.build()
	local model = Instance.new("Model")
	model.Name = "WoodenStaff"
	model:SetAttribute("SourceKind", "AuthoredWoodenStaff")
	model:SetAttribute("VisualVersion", 1)

	local grip = Instance.new("Part")
	grip.Name = "Grip"
	grip.Size = Vector3.new(0.12, 0.12, 0.12)
	grip.CFrame = CFrame.new()
	grip.Transparency = 1
	grip.CastShadow = false
	grip.Anchored = false
	grip.Massless = true
	grip.CanCollide = false
	grip.CanTouch = false
	grip.CanQuery = false
	grip.Parent = model
	model.PrimaryPart = grip

	local vertical = CFrame.Angles(0, 0, math.pi / 2)
	visualPart(model, grip, "WoodenShaft", Enum.PartType.Cylinder,
		Vector3.new(3.4, 0.18, 0.18), CFrame.new(0, 0.6, 0) * vertical, WOOD, Enum.Material.Wood)
	visualPart(model, grip, "HandWrap", Enum.PartType.Cylinder,
		Vector3.new(0.58, 0.22, 0.22), CFrame.new(0, 0, 0) * vertical, LEATHER, Enum.Material.Fabric)
	for index, y in ipairs({ -0.24, 0, 0.24 }) do
		visualPart(model, grip, "WrapBand" .. index, Enum.PartType.Cylinder,
			Vector3.new(0.035, 0.235, 0.235), CFrame.new(0, y, 0) * vertical, BRASS, Enum.Material.Metal)
	end
	visualPart(model, grip, "FootCap", Enum.PartType.Cylinder,
		Vector3.new(0.12, 0.19, 0.19), CFrame.new(0, -1.12, 0) * vertical, LEATHER, Enum.Material.SmoothPlastic)
	visualPart(model, grip, "WoodKnot", Enum.PartType.Ball,
		Vector3.new(0.13, 0.13, 0.09), CFrame.new(0.07, 1.13, -0.04), WOOD_LIGHT, Enum.Material.Wood)

	-- A small forked crown keeps the apprentice silhouette recognizably wooden.
	woodenBranch(model, grip, "LeftFork", Vector3.new(-0.03, 2.12, 0), Vector3.new(-0.24, 2.65, 0), 0.13)
	woodenBranch(model, grip, "RightFork", Vector3.new(0.03, 2.12, 0), Vector3.new(0.24, 2.65, 0), 0.13)
	woodenBranch(model, grip, "LeftProng", Vector3.new(-0.24, 2.65, 0), Vector3.new(-0.13, 2.83, 0), 0.10)
	woodenBranch(model, grip, "RightProng", Vector3.new(0.24, 2.65, 0), Vector3.new(0.13, 2.83, 0), 0.10)
	local stone = visualPart(model, grip, "SmallCrystal", Enum.PartType.Ball,
		Vector3.new(0.25, 0.28, 0.25), CFrame.new(0, 2.69, 0), CRYSTAL, Enum.Material.Glass)
	stone.Transparency = 0.15

	local tip = Instance.new("Attachment")
	tip.Name = "WeaponTip"
	tip.Position = Vector3.new(0, 2.86, 0)
	tip.Parent = grip
	return model
end

return Builder
