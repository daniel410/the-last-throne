-- Same-world controls for the representative landmark models.
local world = assert(_G.TLTStoryLandmarkReviewWorld)
local client = game.StarterPlayer.StarterPlayerScripts.Client
local mood = require(client.DeepwoodAtmosphere)
for _, service in ipairs({game.ServerScriptService, game.StarterPlayer, game.ReplicatedFirst, game.StarterGui}) do
    for _, child in ipairs(service:GetDescendants()) do
        if child:IsA('BaseScript') then child.Enabled = false end
    end
end
local baseplate = workspace:FindFirstChild('Baseplate')
if baseplate then baseplate:Destroy() end
for _, child in ipairs(world.folder:GetDescendants()) do
    if child:IsA('BillboardGui') or child:IsA('ProximityPrompt') then child.Enabled = false end
end
game.RunService:Run()
task.wait(1)
local camera = workspace.CurrentCamera
local V = Vector3.new
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 55
for epic, id in ipairs({'DW-02','GW-01','FV-03','EC-03','HG-03'}) do
    local site = world.folder.EpicWorldArt['EpicWorldArt_' .. epic][id]
    local model
    for _, child in ipairs(site:GetChildren()) do
        if child:GetAttribute('SourceKind') == 'NewNativeGeometry' then model = child; break end
    end
    local bounds, size = assert(model):GetBoundingBox()
    local aim = bounds.Position
    local approach = model:GetAttribute('ApproachPosition') - aim
    local forward = V(approach.X,0,approach.Z).Unit
    local side = V(-forward.Z,0,forward.X)
    local floor = model:GetAttribute('GroundPosition')
    local origin = floor + forward * math.max(27,size.X*.96) + side * 14 + V(0,math.max(10,size.Y*.68),0)
    camera.CFrame = CFrame.lookAt(origin,aim)
    camera.Focus = CFrame.new(aim)
    local point, within = camera:WorldToViewportPoint(aim)
    assert(within and point.Z > 0, 'landmark center outside frame')
    mood.update(site:GetAttribute('Theme'))
    print('LANDMARK_CAMERA ' .. game.HttpService:JSONEncode({story=id,theme=site:GetAttribute('Theme'),
        origin={origin.X,origin.Y,origin.Z}, aim={aim.X,aim.Y,aim.Z}, centerDepth=point.Z, fov=camera.FieldOfView}))
    for _, variant in ipairs({'control','candidate'}) do
        model.Parent = variant == 'candidate' and site or nil
        task.wait(2)
        local done, failure = false, nil
        game.CaptureService:CaptureScreenshot(function(content)
            local ok, err = pcall(function()
                local image = game.AssetService:CreateEditableImageAsync(Content.fromUri(content))
                local size = image.Size
                local pixels = image:ReadPixelsBuffer(Vector2.zero,size)
                image:Destroy()
                local width, height = 480,270
                local cropX = math.min(size.X,size.Y*width/height)
                local cropY = math.min(size.Y,size.X*height/width)
                for y=0,height-1 do
                    local row = math.floor((size.Y-cropY)/2+(y+.5)*cropY/height)*size.X
                    local hex = table.create(width)
                    for x=0,width-1 do
                        local col = math.floor((size.X-cropX)/2+(x+.5)*cropX/width)
                        local pos = 4*(row+col)
                        hex[x+1] = string.format('%02x%02x%02x',buffer.readu8(pixels,pos),buffer.readu8(pixels,pos+1),buffer.readu8(pixels,pos+2))
                    end
                    print('LANDMARK_ROW',id,variant,y,table.concat(hex))
                    if y%45==44 then task.wait() end
                end
            end)
            if not ok then failure = err end
            done = true
        end)
        local deadline = os.clock()+20
        repeat task.wait(.05) until done or os.clock()>deadline
        assert(done and not failure,failure or 'Studio screenshot timed out')
    end
end
mood.update(nil)
