-- A disposable Dawnspire courtyard for class selection and training.
-- Geometry is authored from native Parts only. This module does not select a
-- class, start combat, move players, alter lighting, or load external assets.
local Workspace = game:GetService("Workspace")

local LobbyWorld = {}
local MODEL_NAME = "DawnspireLobbyPrototype"
local OWNER_ATTRIBUTE = "TLTLobbyWorld"
local VERSION = 2
local ORIGIN = Vector3.new(0, 96, 512)
local SPAWN_OFFSET = Vector3.new(0, 0.1, 24)
local FLOOR_SIZE = Vector3.new(160, 4, 160)
local BOUNDARY_HEIGHT = 32

local COLORS = {
	stone = Color3.fromRGB(154, 159, 171),
	stoneLight = Color3.fromRGB(192, 195, 198),
	stoneDark = Color3.fromRGB(91, 106, 131),
	plaza = Color3.fromRGB(188, 174, 143),
	grass = Color3.fromRGB(77, 122, 80),
	gold = Color3.fromRGB(216, 174, 76),
	blue = Color3.fromRGB(40, 85, 176),
	green = Color3.fromRGB(47, 131, 82),
	copper = Color3.fromRGB(174, 102, 49),
	violet = Color3.fromRGB(112, 74, 166),
	warmLight = Color3.fromRGB(255, 213, 143),
	text = Color3.fromRGB(255, 245, 214),
}

-- These local en-US strings have stable keys for later shared text integration.
-- They label scenery only and never imply a clickable selector or a teleport.
local LABELS = {
	title = { key = "lobby.world.title", text = "DAWNSPIRE" },
	subtitle = { key = "lobby.world.subtitle", text = "Adventures / Training / Blacksmith" },
	knight = { key = "lobby.world.knight", text = "Knight" },
	elf = { key = "lobby.world.elf", text = "Elf Archer" },
	dwarf = { key = "lobby.world.dwarf", text = "Dwarf Axe Thrower" },
	mage = { key = "lobby.world.mage", text = "Mage" },
}

local function position(x, y, z)
	return ORIGIN + Vector3.new(x, y, z)
end

local function part(parent, name, size, offset, color, material, collision)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = ORIGIN + offset
	item.Color = color
	item.Material = material or Enum.Material.Slate
	item.Anchored = true
	item.CanCollide = collision == true
	item.CanQuery = collision == true
	item.CanTouch = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("LobbyGeometry", true)
	item.Parent = parent
	return item
end

local function label(board, name, content)
	local surface = Instance.new("SurfaceGui")
	surface.Name = name
	surface.Face = Enum.NormalId.Back -- +Z, toward the arrival/spawn side.
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 36
	surface.LightInfluence = 0
	surface.AlwaysOnTop = false
	surface.AutoLocalize = false
	surface:SetAttribute("TextKey", content.key)
	surface:SetAttribute("Locale", "en-US")
	surface.Parent = board
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = content.text
	text.TextColor3 = COLORS.text
	text.TextScaled = true
	text.TextWrapped = true
	text.Font = Enum.Font.GothamBold
	text.AutoLocalize = false
	text.Parent = surface
end

local function safetySpecs()
	return {
		{ name = "West", size = Vector3.new(4, BOUNDARY_HEIGHT, 160), offset = Vector3.new(-78, BOUNDARY_HEIGHT / 2, 0) },
		{ name = "East", size = Vector3.new(4, BOUNDARY_HEIGHT, 160), offset = Vector3.new(78, BOUNDARY_HEIGHT / 2, 0) },
		{ name = "North", size = Vector3.new(160, BOUNDARY_HEIGHT, 4), offset = Vector3.new(0, BOUNDARY_HEIGHT / 2, -78) },
		{ name = "South", size = Vector3.new(160, BOUNDARY_HEIGHT, 4), offset = Vector3.new(0, BOUNDARY_HEIGHT / 2, 78) },
	}
end

local function enclosure(model)
	local bounds = Instance.new("Folder")
	bounds.Name = "SafetyBounds"
	bounds.Parent = model
	for _, spec in ipairs(safetySpecs()) do
		local barrier = part(bounds, spec.name, spec.size, spec.offset, COLORS.stone, Enum.Material.Slate, true)
		barrier.Transparency = 1
		barrier.CastShadow = false
		barrier:SetAttribute("SafetyBoundary", true)
	end

	local walls = Instance.new("Folder")
	walls.Name = "CitadelWalls"
	walls.Parent = model
	for _, spec in ipairs({
		{ "WestWall", Vector3.new(4, 14, 152), Vector3.new(-76, 7, 0) },
		{ "EastWall", Vector3.new(4, 14, 152), Vector3.new(76, 7, 0) },
		{ "NorthWall", Vector3.new(152, 14, 4), Vector3.new(0, 7, -76) },
		{ "SouthWall", Vector3.new(152, 14, 4), Vector3.new(0, 7, 76) },
	}) do
		-- The transparent enclosure owns the continuous collision contract.
		-- Ornamenting a visible wall never opens a gap in that enclosure.
		part(walls, spec[1], spec[2], spec[3], COLORS.stoneDark, Enum.Material.Slate, false)
	end
	for _, x in ipairs({ -71, 71 }) do
		for _, z in ipairs({ -71, 71 }) do
			part(walls, "CornerTower", Vector3.new(10, 17, 10), Vector3.new(x, 8.5, z), COLORS.stone, Enum.Material.Slate, false)
			part(walls, "TowerCap", Vector3.new(11, 1, 11), Vector3.new(x, 17.5, z), COLORS.stoneLight, Enum.Material.Slate, false)
		end
	end
end

local function lamp(parent, x, z)
	local stand = part(parent, "LanternStand", Vector3.new(1.2, 6, 1.2), Vector3.new(x, 3, z), COLORS.stoneDark, Enum.Material.Metal, false)
	stand:SetAttribute("DecorativeOnly", true)
	part(parent, "LanternFoot", Vector3.new(2.5, 0.7, 2.5), Vector3.new(x, 0.35, z), COLORS.stoneLight, Enum.Material.Slate, false)
	local glow = part(parent, "LanternGlow", Vector3.new(1.1, 1.6, 1.1), Vector3.new(x, 6.3, z), COLORS.warmLight, Enum.Material.Neon, false)
	glow.Shape = Enum.PartType.Ball
	part(parent, "LanternCap", Vector3.new(2, 0.3, 2), Vector3.new(x, 7.25, z), COLORS.gold, Enum.Material.Metal, false)
	local light = Instance.new("PointLight")
	light.Name = "CourtyardLight"
	light.Color = COLORS.warmLight
	light.Brightness = 0.7
	light.Range = 18
	light.Shadows = false
	light.Parent = glow
end

local function banner(parent, x, color, content)
	local display = Instance.new("Model")
	display.Name = "Banner_" .. content.text:gsub(" ", "")
	display:SetAttribute("DecorativeOnly", true)
	display.Parent = parent
	part(display, "Foot", Vector3.new(8, 0.12, 7), Vector3.new(x, 0.06, -35), COLORS.stoneDark, Enum.Material.Slate, false)
	part(display, "Pole", Vector3.new(0.45, 13, 0.45), Vector3.new(x, 6.5, -38), COLORS.gold, Enum.Material.Metal, false)
	part(display, "Crossbar", Vector3.new(7, 0.3, 0.5), Vector3.new(x, 12.5, -38), COLORS.gold, Enum.Material.Metal, false)
	part(display, "Cloth", Vector3.new(6.2, 7, 0.2), Vector3.new(x, 8.7, -37.9), color, Enum.Material.Fabric, false)
	local gem = part(display, "Emblem", Vector3.new(1.3, 1.7, 0.35), Vector3.new(x, 9, -37.65), COLORS.gold, Enum.Material.Metal, false)
	gem.Shape = Enum.PartType.Ball
	local board = part(display, "Nameplate", Vector3.new(10, 2, 0.3), Vector3.new(x, 2.2, -34), COLORS.stoneDark, Enum.Material.Slate, false)
	label(board, "ClassLabel", content)
end

local function courtyard(model)
	local scenery = Instance.new("Folder")
	scenery.Name = "CourtyardScenery"
	scenery.Parent = model
	part(scenery, "InnerPlaza", Vector3.new(104, 0.08, 104), Vector3.new(0, 0.04, 0), COLORS.plaza, Enum.Material.Cobblestone, false)
	part(scenery, "ArrivalCarpet", Vector3.new(12, 0.04, 65), Vector3.new(0, 0.1, 11.5), COLORS.blue, Enum.Material.Fabric, false)
	for _, x in ipairs({ -6.3, 6.3 }) do
		part(scenery, "CarpetBorder", Vector3.new(0.35, 0.03, 65), Vector3.new(x, 0.13, 11.5), COLORS.gold, Enum.Material.Metal, false)
	end
	for _, x in ipairs({ -28, 28 }) do
		for _, z in ipairs({ -14, 24 }) do
			local bed = part(scenery, "GardenBorder", Vector3.new(12, 0.6, 10), Vector3.new(x, 0.3, z), COLORS.stoneLight, Enum.Material.Slate, false)
			bed:SetAttribute("DecorativeOnly", true)
			part(scenery, "GardenLawn", Vector3.new(10.6, 0.7, 8.6), Vector3.new(x, 0.6, z), COLORS.grass, Enum.Material.Grass, false)
			local shrub = part(scenery, "Shrub", Vector3.new(7, 2.2, 5.5), Vector3.new(x, 1.8, z), COLORS.green, Enum.Material.SmoothPlastic, false)
			shrub.Shape = Enum.PartType.Ball
		end
	end
	for _, x in ipairs({ -18, 18 }) do
		lamp(scenery, x, 5)
		lamp(scenery, x, 42)
	end
	-- Class banners frame the rear porch, leaving the facility approaches clear.
	banner(scenery, -39, COLORS.blue, LABELS.knight)
	banner(scenery, -13, COLORS.green, LABELS.elf)
	banner(scenery, 13, COLORS.copper, LABELS.dwarf)
	banner(scenery, 39, COLORS.violet, LABELS.mage)
	for _,child in ipairs(scenery:GetChildren()) do
		if child:IsA('Model') and child.Name:sub(1,7)=='Banner_' then child:PivotTo(child:GetPivot()+Vector3.new(0,0,-27)) end
	end
	for _,spec in ipairs({{'PortalPath',Vector3.new(43,.05,9),Vector3.new(-22,.18,-20)},
		{'TrainingPath',Vector3.new(42,.05,9),Vector3.new(-23,.18,44)},
		{'SmithPath',Vector3.new(37,.05,9),Vector3.new(24,.18,23)}}) do
		part(scenery,spec[1],spec[2],spec[3],COLORS.stoneLight,Enum.Material.Cobblestone,false)
	end

	-- An open, purely decorative porch gives the arrival view a focal point.
	for _, x in ipairs({ -42, 42 }) do
		part(scenery, "PorchColumnFoot", Vector3.new(7, 0.6, 7), Vector3.new(x, 0.3, -55), COLORS.stoneLight, Enum.Material.Slate, false)
		part(scenery, "PorchColumn", Vector3.new(4, 17, 4), Vector3.new(x, 8.5, -55), COLORS.stone, Enum.Material.Slate, false)
		part(scenery, "PorchCapital", Vector3.new(7, 1, 7), Vector3.new(x, 17.5, -55), COLORS.gold, Enum.Material.Metal, false)
	end
	part(scenery, "PorchLintel", Vector3.new(91, 3, 7), Vector3.new(0, 19.5, -55), COLORS.stoneLight, Enum.Material.Slate, false)
	local title = part(scenery, "TitleBoard", Vector3.new(35, 4, 0.5), Vector3.new(0, 14.7, -54), COLORS.stoneDark, Enum.Material.Slate, false)
	label(title, "LobbyTitle", LABELS.title)
	local subtitle = part(scenery, "SubtitleBoard", Vector3.new(35, 2, 0.5), Vector3.new(0, 11.3, -54), COLORS.stoneDark, Enum.Material.Slate, false)
	label(subtitle, "LobbySubtitle", LABELS.subtitle)
end

local function resultFor(model)
	assert(model:IsA("Model") and model:GetAttribute(OWNER_ATTRIBUTE) == true, "Lobby name is occupied by an unrelated instance")
	assert(model:GetAttribute("LobbyWorldVersion") == VERSION, "Lobby world version does not match this module")
	local ground = model:FindFirstChild("Ground")
	assert(ground and ground:IsA("Part") and ground.Anchored and ground.CanCollide, "Lobby requires its anchored solid floor")
	assert(ground.Size == FLOOR_SIZE and ground.Position == position(0, -2, 0), "Lobby floor dimensions or origin were changed")
	local bounds = model:FindFirstChild("SafetyBounds")
	assert(bounds and bounds:IsA("Folder"), "Lobby is missing its safety enclosure")
	for _, spec in ipairs(safetySpecs()) do
		local barrier = bounds:FindFirstChild(spec.name)
		assert(barrier and barrier:IsA("Part") and barrier.Anchored and barrier.CanCollide and barrier.CanQuery,
			"Lobby safety boundary is unavailable: " .. spec.name)
		assert(barrier.Size == spec.size and barrier.Position == ORIGIN + spec.offset, "Lobby safety boundary was moved: " .. spec.name)
	end
	local spawn = model:FindFirstChild("Spawn")
	assert(spawn and spawn:IsA("SpawnLocation") and spawn.Anchored and spawn.Enabled and spawn.Neutral,
		"Lobby requires an enabled neutral SpawnLocation")
	assert(spawn.Position == ORIGIN + SPAWN_OFFSET, "Lobby spawn was moved away from its reviewed clear area")
	return {
		folder = model,
		spawn = spawn,
		origin = ORIGIN,
		bounds = { center = ORIGIN, size = Vector3.new(160, 40, 160) },
	}
end

function LobbyWorld.create()
	local existing
	for _, item in ipairs(Workspace:GetChildren()) do
		if item.Name == MODEL_NAME then
			assert(existing == nil, "Multiple lobby models share the reserved name")
			existing = item
		end
	end
	if existing then return resultFor(existing) end

	-- Build privately and publish only after all required floor/boundary/spawn
	-- contracts pass. A failed creation never leaves half a lobby in Workspace.
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	model:SetAttribute(OWNER_ATTRIBUTE, true)
	model:SetAttribute("LobbyWorldVersion", VERSION)
	model:SetAttribute("PrototypeOnly", true)
	model:SetAttribute("WorldOrigin", ORIGIN)
	model:SetAttribute("FloorTopY", ORIGIN.Y)
	model:SetAttribute("SafeBoundaryHeight", BOUNDARY_HEIGHT)
	local ok, result = pcall(function()
		part(model, "Ground", FLOOR_SIZE, Vector3.new(0, -2, 0), COLORS.stone, Enum.Material.Slate, true)
		enclosure(model)
		courtyard(model)
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn"
		spawn.Size = Vector3.new(8, 0.2, 8)
		spawn.Position = ORIGIN + SPAWN_OFFSET
		spawn.Color = COLORS.blue
		spawn.Material = Enum.Material.Slate
		spawn.Anchored = true
		spawn.CanCollide = false
		spawn.CanQuery = false
		spawn.CanTouch = false
		spawn.Enabled = true
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.AllowTeamChangeOnTouch = false
		spawn:SetAttribute("TLTLobbySpawn", true)
		spawn.Parent = model
		local value = resultFor(model)
		model.Parent = Workspace
		return value
	end)
	if not ok then
		model:Destroy()
		error("Lobby world creation failed: " .. tostring(result))
	end
	return result
end

return LobbyWorld
