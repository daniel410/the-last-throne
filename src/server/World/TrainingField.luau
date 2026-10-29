-- Deepwood K0 is an isolated combat blockout, not the finished story map.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage.Shared.K0Text)
local TdMonsterAppearance = require(script.Parent.TdMonsterAppearance)

local TrainingField = {}

local COLORS = {
	grass = Color3.fromRGB(89, 143, 70),
	path = Color3.fromRGB(175, 153, 105),
	stone = Color3.fromRGB(133, 139, 118),
	moss = Color3.fromRGB(101, 127, 79),
	trunk = Color3.fromRGB(104, 76, 49),
	leaf = Color3.fromRGB(65, 132, 63),
	leafLight = Color3.fromRGB(100, 165, 76),
	wood = Color3.fromRGB(106, 73, 44),
	blue = Color3.fromRGB(32, 77, 156),
	gold = Color3.fromRGB(229, 185, 75),
}

local function anchoredPart(parent, name, size, position, color, material, collision)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = collision
	part.CanTouch = false
	part.CanQuery = collision
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function tree(parent, x, z, scale)
	local model = Instance.new("Model")
	model.Name = "BlockoutTree"
	model.Parent = parent

	anchoredPart(model, "Trunk", Vector3.new(3 * scale, 11 * scale, 3 * scale),
		Vector3.new(x, 5.5 * scale, z), COLORS.trunk, Enum.Material.Wood, true)

	-- The canopy is visible but does not become an invisible attack or camera wall.
	local crown = anchoredPart(model, "Crown", Vector3.new(11 * scale, 8 * scale, 11 * scale),
		Vector3.new(x, 12.5 * scale, z), COLORS.leaf, Enum.Material.SmoothPlastic, false)
	crown.Shape = Enum.PartType.Ball
	local crownTop = anchoredPart(model, "CrownTop", Vector3.new(8 * scale, 7 * scale, 8 * scale),
		Vector3.new(x + 1.5 * scale, 16 * scale, z), COLORS.leafLight, Enum.Material.SmoothPlastic, false)
	crownTop.Shape = Enum.PartType.Ball
end

local function makeSign(parent)
	local sign = Instance.new("Model")
	sign.Name = "TrailSign"
	sign.Parent = parent
	-- Keep the post behind the printed face so it cannot cover the lettering.
	anchoredPart(sign, "Post", Vector3.new(0.8, 6, 0.8), Vector3.new(-30, 3, 52.3),
		COLORS.wood, Enum.Material.Wood, true)
	local board = anchoredPart(sign, "Board", Vector3.new(10, 3.5, 0.5), Vector3.new(-30, 5, 53),
		COLORS.wood, Enum.Material.Wood, false)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "TrailLabel"
	surface.Face = Enum.NormalId.Back
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 45
	surface.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = Text.TrailSign
	label.TextColor3 = Color3.fromRGB(255, 239, 192)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = surface
end

local function bodyPart(parent, name, size, position, color, transparency, collision)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(position)
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = transparency
	part.Anchored = false
	part.CanCollide = collision
	part.CanTouch = true
	part.CanQuery = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function motor(parent, name, part0, part1, c0, c1)
	local joint = Instance.new("Motor6D")
	joint.Name = name
	joint.Part0 = part0
	joint.Part1 = part1
	joint.C0 = c0
	joint.C1 = c1
	joint.Parent = parent
end

local function makeEnemy(parent, kind, x, z, scale, visualMultiplier)
	local model = Instance.new("Model")
	model.Name = kind
	model:SetAttribute("EnemyKind", kind)
	local isGoblin = kind == "Goblin"
	local skin = if isGoblin then Color3.fromRGB(160, 177, 57) else Color3.fromRGB(120, 150, 89)
	local armor = if isGoblin then Color3.fromRGB(127, 75, 45) else Color3.fromRGB(104, 78, 56)
	local dark = Color3.fromRGB(71, 53, 40)
	local origin = Vector3.new(x, 0, z)
	local function at(dx, dy, dz)
		return origin + Vector3.new(dx * scale, dy * scale, dz * scale)
	end
	local function size(dx, dy, dz)
		return Vector3.new(dx * scale, dy * scale, dz * scale)
	end

	-- This R6 skeleton is the K0 movement/combat rig. The separate visible
	-- pieces come from the pinned Throne Defense Meshy runtime models.
	local root = bodyPart(model, "HumanoidRootPart", size(2, 2, 1), at(0, 3, 0), skin, 1, true)
	local torso = bodyPart(model, "Torso", size(2, 2, 1), at(0, 3, 0), armor, 0, false)
	local head = bodyPart(model, "Head", size(2, 1, 1), at(0, 4.5, 0), skin, 0, false)
	local leftArm = bodyPart(model, "Left Arm", size(1, 2, 1), at(-1.5, 3, 0), skin, 0, false)
	local rightArm = bodyPart(model, "Right Arm", size(1, 2, 1), at(1.5, 3, 0), skin, 0, false)
	local leftLeg = bodyPart(model, "Left Leg", size(1, 2, 1), at(-0.5, 1, 0), dark, 0, false)
	local rightLeg = bodyPart(model, "Right Leg", size(1, 2, 1), at(0.5, 1, 0), dark, 0, false)
	model.PrimaryPart = root

	motor(root, "RootJoint", root, torso, CFrame.new(), CFrame.new())
	motor(torso, "Neck", torso, head, CFrame.new(0, scale, 0), CFrame.new(0, -0.5 * scale, 0))
	motor(torso, "Left Shoulder", torso, leftArm, CFrame.new(-scale, 0.5 * scale, 0), CFrame.new(0.5 * scale, 0.5 * scale, 0))
	motor(torso, "Right Shoulder", torso, rightArm, CFrame.new(scale, 0.5 * scale, 0), CFrame.new(-0.5 * scale, 0.5 * scale, 0))
	motor(torso, "Left Hip", torso, leftLeg, CFrame.new(-0.5 * scale, -scale, 0), CFrame.new(0, scale, 0))
	motor(torso, "Right Hip", torso, rightLeg, CFrame.new(0.5 * scale, -scale, 0), CFrame.new(0, scale, 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayName = Text.Enemy[kind] or kind
	humanoid.MaxHealth = 100 -- K0 combat service applies the experiment preset.
	humanoid.Health = humanoid.MaxHealth
	humanoid.WalkSpeed = 10
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.Parent = model
	TdMonsterAppearance.attach(model, kind, 3 * scale, visualMultiplier)
	model.Parent = parent
	root:SetNetworkOwner(nil)
	return model
end

local function makeTerrain(folder)
	local terrain = Instance.new("Folder")
	terrain.Name = "TerrainBlockout"
	terrain.Parent = folder

	-- The upper face of this continuous walkable ground is Y=0.
	anchoredPart(terrain, "Ground", Vector3.new(160, 4, 160), Vector3.new(0, -2, 0),
		COLORS.grass, Enum.Material.Grass, true)
	anchoredPart(terrain, "Trail", Vector3.new(22, 0.08, 50), Vector3.new(9, 0.04, 32),
		COLORS.path, Enum.Material.Ground, false)
	anchoredPart(terrain, "ArrivalTrail", Vector3.new(32, 0.09, 12), Vector3.new(-8, 0.045, 56),
		COLORS.path, Enum.Material.Ground, false)
	for index = 0, 8 do
		local offset = if index % 2 == 0 then -3 else 3
		anchoredPart(terrain, "TrailStone", Vector3.new(5, 0.12, 3.5), Vector3.new(9 + offset, 0.07, 12 + index * 4.5),
			COLORS.stone, Enum.Material.Slate, false)
	end

	-- Solid 6-stud cover blocks the two initial sight lines into the spawn pad.
	-- Its right end leaves a 22-stud-wide passage before the right-hand wall.
	anchoredPart(terrain, "SpawnCover", Vector3.new(34, 6, 3), Vector3.new(-19, 3, 40),
		COLORS.stone, Enum.Material.Slate, true)
	anchoredPart(terrain, "PassageEastWall", Vector3.new(3, 4, 20), Vector3.new(21.5, 2, 33),
		COLORS.moss, Enum.Material.Slate, true)

	-- Edge barriers keep the prototype bounded without filling the combat floor.
	local boundaries = {
		{ "WestBoundary", Vector3.new(2, 18, 160), Vector3.new(-80, 9, 0) },
		{ "EastBoundary", Vector3.new(2, 18, 160), Vector3.new(80, 9, 0) },
		{ "NorthBoundary", Vector3.new(160, 18, 2), Vector3.new(0, 9, -80) },
		{ "SouthBoundary", Vector3.new(160, 18, 2), Vector3.new(0, 9, 80) },
	}
	for _, entry in boundaries do
		local boundary = anchoredPart(terrain, entry[1], entry[2], entry[3], COLORS.grass, Enum.Material.SmoothPlastic, true)
		boundary.Transparency = 1
	end

	local trees = {
		{ -65, -65, 1.25 }, { -64, -43, 1.05 }, { -67, -17, 1.25 }, { -65, 10, 1.0 },
		{ -62, 32, 1.1 }, { -65, 70, 1.15 }, { 64, -62, 1.15 }, { 66, -38, 1.05 },
		{ 65, -10, 1.25 }, { 62, 18, 1.0 }, { 65, 43, 1.1 }, { 64, 70, 1.2 },
	}
	for _, entry in trees do
		tree(terrain, entry[1], entry[2], entry[3])
	end
	makeSign(terrain)
end

function TrainingField.create()
	-- Check all imported K0 template contracts before changing Workspace.
	for _, kind in ipairs({ "Goblin", "Orc", "Ogre", "Slime" }) do
		TdMonsterAppearance.describe(kind)
	end
	local existing = Workspace:FindFirstChild("DeepwoodK0")
	if existing then
		assert(existing:IsA("Model"), "DeepwoodK0 must be a Model")
		local enemies = existing:FindFirstChild("Enemies")
		local spawn = existing:FindFirstChild("Spawn")
		assert(enemies and enemies:IsA("Folder"), "DeepwoodK0 is missing its Enemies folder")
		assert(spawn and spawn:IsA("SpawnLocation"), "DeepwoodK0 is missing its SpawnLocation")
		return { folder = existing, enemies = enemies, spawn = spawn }
	end

	-- The Rojo scaffold has a default slab at the same elevation. Retain the
	-- instance but disable it so it neither z-fights nor extends the field.
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate.Transparency = 1
		baseplate.CanCollide = false
		baseplate.CanTouch = false
		baseplate.CanQuery = false
	end

	Lighting.Brightness = 2.5
	Lighting.ClockTime = 14
	Lighting.Ambient = Color3.fromRGB(118, 122, 105)
	Lighting.OutdoorAmbient = Color3.fromRGB(154, 166, 137)
	Lighting.GlobalShadows = true

	local folder = Instance.new("Model")
	folder.Name = "DeepwoodK0"
	folder.Parent = Workspace
	makeTerrain(folder)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 0.2, 8)
	spawn.Position = Vector3.new(-20, 0.1, 56)
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CanQuery = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = COLORS.blue
	spawn.Material = Enum.Material.Slate
	spawn.Parent = folder
	anchoredPart(folder, "SpawnMarker", Vector3.new(10, 0.08, 10), Vector3.new(-20, 0.05, 56),
		COLORS.gold, Enum.Material.Slate, false)

	local enemies = Instance.new("Folder")
	enemies.Name = "Enemies"
	enemies.Parent = folder
	makeEnemy(enemies, "Goblin", -18, -10, 1.02, 1.2)
	makeEnemy(enemies, "Slime", -4, 24, 0.60, 1.2)
	-- Preserve each TD visual and its control rig at the same relative scale.
	makeEnemy(enemies, "Orc", 42, 17, 1.65, 1.5)
	makeEnemy(enemies, "Ogre", 20, -30, 2.475, 2.475 / 1.45)

	return { folder = folder, enemies = enemies, spawn = spawn }
end

return TrainingField
