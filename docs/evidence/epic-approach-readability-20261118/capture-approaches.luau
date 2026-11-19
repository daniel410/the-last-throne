assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local World = game.ServerScriptService.Server.World
local world = existingWorld or require(World.CampaignWorld).create()
local mood = require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere)
local cameras = game.HttpService:JSONDecode(cameraPlan)
local baseplate = workspace:FindFirstChild('Baseplate')
if baseplate then baseplate:Destroy() end

for _, service in ipairs({game.ServerScriptService, game.StarterPlayer, game.ReplicatedFirst, game.StarterGui}) do
    for _, child in ipairs(service:GetDescendants()) do
        if child:IsA('BaseScript') then child.Enabled = false end
    end
end
for _, child in ipairs(world.folder:GetDescendants()) do
    if child:IsA('BillboardGui') or child:IsA('ProximityPrompt') then child.Enabled = false end
end
if not game.RunService:IsRunning() then game.RunService:Run() end

local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 55
for _, shot in ipairs(cameras) do
    local aim = V(table.unpack(shot.aim))
    camera.CFrame = CFrame.lookAt(V(table.unpack(shot.origin)), aim)
    camera.Focus = CFrame.new(aim)
    mood.update(shot.theme)
    task.wait(1.25)
    local done, failure = false, nil
    game.CaptureService:CaptureScreenshot(function(content)
        local ok, err = pcall(function()
            local image = game.AssetService:CreateEditableImageAsync(Content.fromUri(content))
            local size = image.Size
            local pixels = image:ReadPixelsBuffer(Vector2.zero, size)
            image:Destroy()
            local width, height = 400, 225
            local cropX = math.min(size.X, size.Y * width / height)
            local cropY = math.min(size.Y, size.X * height / width)
            for y = 0, height - 1 do
                local row = math.floor((size.Y - cropY) / 2 + (y + .5) * cropY / height) * size.X
                local hex = table.create(width)
                for x = 0, width - 1 do
                    local col = math.floor((size.X - cropX) / 2 + (x + .5) * cropX / width)
                    local pos = 4 * (row + col)
                    hex[x + 1] = string.format('%02x%02x%02x', buffer.readu8(pixels, pos),
                        buffer.readu8(pixels, pos + 1), buffer.readu8(pixels, pos + 2))
                end
                print('TLT_APPROACH_FRAME', shot.id, y, table.concat(hex))
                if y % 45 == 44 then task.wait() end
            end
        end)
        if not ok then failure = err end
        done = true
    end)
    local deadline = os.clock() + 20
    repeat task.wait(.05) until done or os.clock() > deadline
    assert(done and not failure, failure or 'Studio screenshot timed out')
end
mood.update(nil)
print('TLT_APPROACH_FRAMES_DONE')
