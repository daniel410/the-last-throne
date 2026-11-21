assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
for _, service in ipairs({game.ServerScriptService, game.StarterPlayer, game.ReplicatedFirst, game.StarterGui}) do
	for _, item in ipairs(service:GetDescendants()) do
		if item:IsA('BaseScript') then item.Enabled = false end
	end
end
local baseplate = workspace:FindFirstChild('Baseplate')
if baseplate then baseplate:Destroy() end
local World = game.ServerScriptService.Server.World
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local V = Vector3.new
local mood = require(Client.DeepwoodAtmosphere)
local outline = require(Client.GloamwoodEnemyOutline)
local bounds = require(Shared.CampaignBounds)
local biome = require(Shared.CampaignBiome)
local world = require(World.CampaignWorld).create(2)
for _, item in ipairs(world.folder:GetDescendants()) do
	if item:IsA('BillboardGui') or item:IsA('ProximityPrompt') then item.Enabled = false end
end
local enemies = Instance.new('Folder')
enemies.Name = 'GloamwoodCaptureEnemies'
enemies.Parent = workspace
local camera = workspace.CurrentCamera
local focus = V(-234,63,-4531)
local cameraPosition = V(-258,76,-4539)
local function addEnemy(kind, x, z)
	local region, story = biome.at(x,z)
	assert(region == 'Gloamwood' and story == 'GW-02')
	local y = assert(bounds.surface(x,z))
	local enemy = require(World.TrainingField).makeEnemy(nil, kind, x, z, 1)
	local pivot = enemy:GetPivot().Position + V(0,y,0)
	enemy:PivotTo(CFrame.lookAt(pivot,V(cameraPosition.X,pivot.Y,cameraPosition.Z)))
	enemy.HumanoidRootPart.Anchored = true
	enemy.Parent = enemies
	local body = enemy.TdMonsterVisual.Body
	assert(body.MeshId ~= '' and body.TextureID ~= '')
	return enemy
end
local web = addEnemy('Webling',-229,-4536)
local silk = addEnemy('Silkweaver',-223,-4525)
game.ContentProvider:PreloadAsync({web.TdMonsterVisual.Body,silk.TdMonsterVisual.Body})
if not game.RunService:IsRunning() then game.RunService:Run() end
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 70
camera.CFrame = require(Client.AdventureCamera).constrain(focus,cameraPosition,{workspace.Terrain,world.terrain})
camera.Focus = CFrame.new(focus)
local position = camera.CFrame.Position
print('TLT_GLOAMWOOD_FIXTURE', position, focus, 'Webling', web.HumanoidRootPart.Position, 'Silkweaver', silk.HumanoidRootPart.Position, 'GlobalShadows', game.Lighting.GlobalShadows)
local function capture(key)
	task.wait(1.0)
	local finished, failure = false, nil
	game.CaptureService:CaptureScreenshot(function(content)
		local ok, err = pcall(function()
			local captured = game.AssetService:CreateEditableImageAsync(Content.fromUri(content))
			local size = captured.Size
			local pixels = captured:ReadPixelsBuffer(Vector2.zero, size)
			captured:Destroy()
			local width, height = 640, 360
			local cropWidth = math.min(size.X, size.Y * width / height)
			local cropHeight = math.min(size.Y, size.X * height / width)
			for y = 0, height - 1 do
				local row = math.floor((size.Y - cropHeight) / 2 + (y + .5) * cropHeight / height) * size.X
				local hex = table.create(width)
				for x = 0, width - 1 do
					local col = math.floor((size.X - cropWidth) / 2 + (x + .5) * cropWidth / width)
					local offset = 4 * (row + col)
					hex[x + 1] = string.format('%02x%02x%02x', buffer.readu8(pixels,offset), buffer.readu8(pixels,offset+1), buffer.readu8(pixels,offset+2))
				end
				print('TLT_GLOAMWOOD_FRAME', key, y, table.concat(hex))
				if y % 45 == 44 then task.wait() end
			end
		end)
		if not ok then failure = err end
		finished = true
	end)
	local deadline = os.clock() + 18
	repeat task.wait(.05) until finished or os.clock() > deadline
	assert(finished and not failure, failure or 'Capture timed out')
end
mood.update('Gloamwood')
local ambient = game.Lighting.Ambient
local atmosphere = game.Lighting.TLTRegionalAtmosphere
local decay = atmosphere.Decay
local old = Color3.fromRGB(108,124,150)
game.Lighting.Ambient = old
atmosphere.Decay = old
task.wait(4)
capture('before')
game.Lighting.Ambient = ambient
atmosphere.Decay = decay
capture('ambient')
local highlights = {}
outline.update(highlights,enemies:GetChildren(),focus)
assert(highlights[web] and highlights[silk])
capture('after')
outline.clear(highlights)
local obstruction = Instance.new('Part')
obstruction.Name = 'CaptureOccluder'
obstruction.Material = Enum.Material.Slate
obstruction.Color = Color3.fromRGB(70,75,94)
obstruction.Anchored = true
obstruction.Size = V(9,9,1)
local webCenter = web.TdMonsterVisual.Body.Position
local midpoint = (camera.CFrame.Position + webCenter) * 0.5
obstruction.CFrame = CFrame.lookAt(midpoint,webCenter)
obstruction.Parent = workspace
capture('occluded_baseline')
outline.update(highlights,{web},focus)
assert(highlights[web])
capture('occluded')
outline.clear(highlights)
print('TLT_GLOAMWOOD_CAPTURE_COMPLETE')
