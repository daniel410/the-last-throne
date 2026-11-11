-- A disposable Dawnspire courtyard for class selection and training.
-- Geometry is authored from native Parts only. This module does not select a
-- class, start combat, move players, alter lighting, or load external assets.
local Workspace = game:GetService("Workspace")

local LobbyWorld = {}
local MODEL_NAME = "DawnspireLobbyPrototype"
local OWNER_ATTRIBUTE = "TLTLobbyWorld"
local VERSION = 4
local ORIGIN = Vector3.new(0, 96, 512)
local SPAWN_OFFSET = Vector3.new(0, 0.1, 24)
local FLOOR_SIZE = Vector3.new(200, 4, 200)
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
		{ name = "West", size = Vector3.new(4, BOUNDARY_HEIGHT, FLOOR_SIZE.Z), offset = Vector3.new(-98, BOUNDARY_HEIGHT / 2, 0) },
		{ name = "East", size = Vector3.new(4, BOUNDARY_HEIGHT, FLOOR_SIZE.Z), offset = Vector3.new(98, BOUNDARY_HEIGHT / 2, 0) },
		{ name = "North", size = Vector3.new(FLOOR_SIZE.X, BOUNDARY_HEIGHT, 4), offset = Vector3.new(0, BOUNDARY_HEIGHT / 2, -98) },
		{ name = "South", size = Vector3.new(FLOOR_SIZE.X, BOUNDARY_HEIGHT, 4), offset = Vector3.new(0, BOUNDARY_HEIGHT / 2, 98) },
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
		{ "WestWall", Vector3.new(4, 14, 192), Vector3.new(-96, 7, 0) },
		{ "EastWall", Vector3.new(4, 14, 192), Vector3.new(96, 7, 0) },
		{ "NorthWall", Vector3.new(192, 14, 4), Vector3.new(0, 7, -96) },
		{ "SouthWall", Vector3.new(192, 14, 4), Vector3.new(0, 7, 96) },
	}) do
		-- The transparent enclosure owns the continuous collision contract.
		-- Ornamenting a visible wall never opens a gap in that enclosure.
		part(walls, spec[1], spec[2], spec[3], COLORS.stone, Enum.Material.Slate, false)
	end
	for _, x in ipairs({ -91, 91 }) do
		for _, z in ipairs({ -91, 91 }) do
			part(walls, "CornerTower", Vector3.new(10, 17, 10), Vector3.new(x, 8.5, z), COLORS.stone, Enum.Material.Slate, false)
			part(walls, "TowerCap", Vector3.new(11, 1, 11), Vector3.new(x, 17.5, z), COLORS.stoneLight, Enum.Material.Slate, false)
		end
	end
 -- Pale battlements and two taller rear towers give the sanctuary a citadel silhouette.
 for n = -11, 11 do
  for _, z in ipairs({-96, 96}) do
   part(walls, "Battlement", Vector3.new(3.5, 2.5, 4.5), Vector3.new(n * 8, 15.25, z), COLORS.stoneLight, Enum.Material.Slate, false)
  end
  for _, x in ipairs({-96, 96}) do
   part(walls, "Battlement", Vector3.new(4.5, 2.5, 3.5), Vector3.new(x, 15.25, n * 8), COLORS.stoneLight, Enum.Material.Slate, false)
  end
 end
 for _, x in ipairs({-36, 36}) do
  part(walls, "SanctuaryTower", Vector3.new(13, 33, 13), Vector3.new(x, 16.5, -86), COLORS.stoneLight, Enum.Material.Slate, false)
  for _, y in ipairs({8, 23, 33}) do
   part(walls, "TowerCornice", Vector3.new(14, .6, 14), Vector3.new(x, y, -86), COLORS.gold, Enum.Material.Metal, false)
  end
  part(walls, "TowerWindow", Vector3.new(3, 8, .2), Vector3.new(x, 23, -79.4), COLORS.stoneDark, Enum.Material.Glass, false)
  for _, dx in ipairs({-5, 0, 5}) do
   part(walls, "TowerMerlon", Vector3.new(3, 3, 3), Vector3.new(x + dx, 35, -80.5), COLORS.stone, Enum.Material.Slate, false)
  end
  part(walls, "TowerBanner", Vector3.new(5, 10, .2), Vector3.new(x, 13, -79.3), COLORS.blue, Enum.Material.Fabric, false)
  part(walls, "TowerBannerEmblem", Vector3.new(1.4, 2.4, .25), Vector3.new(x, 14, -79.1), COLORS.gold, Enum.Material.Metal, false)
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
 part(scenery, "InnerPlaza", Vector3.new(184, .08, 180), Vector3.new(0, .04, 0), COLORS.plaza, Enum.Material.Cobblestone, false)
 -- A long, clear sightline joins arrival, gathering court and the empty throne.
 part(scenery, "RoyalProcessional", Vector3.new(14, .04, 144), Vector3.new(0, .1, -8), COLORS.blue, Enum.Material.Fabric, false)
 for _, x in ipairs({-7.3, 7.3}) do
  part(scenery, "ProcessionalGoldBorder", Vector3.new(.22, .04, 144), Vector3.new(x, .13, -8), COLORS.gold, Enum.Material.Metal, false)
 end
 for i = 0, 31 do
  local angle = i * math.pi * 2 / 32
  local segment = part(scenery, "GatheringCourtInlay", Vector3.new(.3, .04, 4.2), Vector3.new(math.cos(angle) * 21, .16, math.sin(angle) * 21), COLORS.gold, Enum.Material.Metal, false)
  segment.CFrame = CFrame.new(segment.Position) * CFrame.Angles(0, -angle, 0)
 end
 for _, x in ipairs({-82, 82}) do
  for _, z in ipairs({-65, -5, 55}) do
   part(scenery, "GardenBorder", Vector3.new(12, .6, 16), Vector3.new(x, .3, z), COLORS.stoneLight, Enum.Material.Slate, false)
   part(scenery, "GardenLawn", Vector3.new(10.6, .7, 14.6), Vector3.new(x, .6, z), COLORS.grass, Enum.Material.Grass, false)
   local shrub = part(scenery, "CypressCanopy", Vector3.new(5, 10, 5), Vector3.new(x, 6, z), COLORS.green, Enum.Material.SmoothPlastic, false)
   shrub.Shape = Enum.PartType.Ball
   part(scenery, "CypressTrunk", Vector3.new(1.3, 4, 1.3), Vector3.new(x, 2, z), COLORS.copper, Enum.Material.Wood, false)
  end
 end
 for _, x in ipairs({-12, 12}) do
  for _, z in ipairs({-47, -7, 58}) do lamp(scenery, x, z) end
 end
 -- Class standards sit in the rear wings, outside service approaches.
 for _, spec in ipairs({{-70, COLORS.blue, LABELS.knight}, {-48, COLORS.green, LABELS.elf}, {48, COLORS.copper, LABELS.dwarf}, {70, COLORS.violet, LABELS.mage}}) do
  banner(scenery, spec[1], spec[2], spec[3])
 end
 for _, child in ipairs(scenery:GetChildren()) do
  if child:IsA('Model') and child.Name:sub(1,7) == 'Banner_' then child:PivotTo(child:GetPivot() + Vector3.new(0,0,-38)) end
 end
 for _, spec in ipairs({
  {'PortalPath',Vector3.new(43,.05,9),Vector3.new(-22,.18,-20)},
  {'DefensePath',Vector3.new(36,.05,9),Vector3.new(22,.18,-20)},
  {'TrainingPath',Vector3.new(42,.05,9),Vector3.new(-23,.18,56)},
  {'TrainingApproach',Vector3.new(12,.05,16),Vector3.new(0,.18,50)},
  {'PotionShopPath',Vector3.new(46,.05,8),Vector3.new(-23,.18,15)},
  {'SmithPath',Vector3.new(37,.05,9),Vector3.new(24,.18,23)},
 }) do part(scenery,spec[1],spec[2],spec[3],COLORS.stoneLight,Enum.Material.Cobblestone,false) end
 require(script.Parent.DawnspireThrone).create({folder=model, origin=ORIGIN})
 local title = part(scenery, "ArrivalWelcome", Vector3.new(23, 3, .4), Vector3.new(0, 5, 78), COLORS.stoneDark, Enum.Material.Slate, false)
 label(title, "LobbyTitle", LABELS.title)
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
		bounds = { center = ORIGIN, size = Vector3.new(FLOOR_SIZE.X, 40, FLOOR_SIZE.Z) },
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
