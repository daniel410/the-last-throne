-- Bake north-up images from the actual rendered geometry of a disposable local Place.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0 and not game.RunService:IsRunning())
-- Start the renderer without starting profiles, remotes, or gameplay.
for _, service in ipairs({game.ServerScriptService, game.StarterPlayer, game.ReplicatedFirst, game.StarterGui}) do
 for _, child in ipairs(service:GetDescendants()) do
  if child:IsA("BaseScript") then child.Enabled = false end
 end
end
game.RunService:Run()
task.wait(1)
local shared = game.ReplicatedStorage.Shared
local campaign = require(shared.CampaignContent)
local areas = require(shared.CampaignAreas)
local worldBuilder = require(game.ServerScriptService.Server.World.CampaignWorld)
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then baseplate.Transparency = 1 end
local function prepareEpic(epic)
 local world = worldBuilder.create(epic)
 for _, child in ipairs(world.folder:GetDescendants()) do
  if child:IsA("BillboardGui") or child:IsA("ProximityPrompt") then child.Enabled = false
  elseif child:IsA("BasePart") and (child:IsA("SpawnLocation") or child:FindFirstAncestor("NPCActors") or child:FindFirstAncestor("Objectives")) then
   child.Transparency = 1
  end
 end
 return world
end

local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
camera.FieldOfView = 10
local backing = Instance.new("Part")
backing.Name = "SurveyBackdrop"
backing.Anchored = true
backing.CanCollide = false
backing.CastShadow = false
backing.Material = Enum.Material.SmoothPlastic
backing.Parent = workspace
local function capture(width, height, first, last)
 local done, pixels, failure = false, nil, nil
 game.CaptureService:CaptureScreenshot(function(content)
  local ok, result = pcall(function()
   local image = game.AssetService:CreateEditableImageAsync(Content.fromUri(content))
   local size = image.Size
   local source = image:ReadPixelsBuffer(Vector2.zero, size)
   image:Destroy()
   local output = buffer.create(width*height*4)
   for y = 0, height-1 do
    local v = first.Y + (y+.5)/height*(last.Y-first.Y)
    local row = math.clamp(math.floor(v*size.Y),0,size.Y-1)*size.X
    for x = 0, width-1 do
     local u = first.X + (x+.5)/width*(last.X-first.X)
     local column = math.clamp(math.floor(u*size.X),0,size.X-1)
     buffer.writeu32(output,(y*width+x)*4,buffer.readu32(source,(row+column)*4))
    end
   end
   return output
  end)
  if ok then pixels = result else failure = result end
  done = true
 end)
 local deadline = os.clock()+20
 repeat task.wait(.05) until done or os.clock() > deadline
 return assert(pixels,failure or "Studio screenshot timed out")
end

local ids = {}
for id in pairs(campaign.zones) do table.insert(ids,id) end
table.sort(ids,function(a,b)
 local first,second = campaign.zones[a].epic,campaign.zones[b].epic
 if first == second then return a < b end
 return first < second
end)
local currentEpic, world
for _, id in ipairs(ids) do
 local zone = campaign.zones[id]
 if currentEpic ~= zone.epic then
  if world then world.folder:Destroy();workspace.Terrain:Clear() end
  currentEpic = zone.epic
  world = prepareEpic(currentEpic)
 end
 local x0,z0,x1,z1 = areas.surveyExtent(zone)
 local dx,dz = x1-x0,z1-z0
 local center = Vector3.new((x0+x1)/2, zone.center[2], (z0+z1)/2)
 local viewport = camera.ViewportSize
 local span = math.max(dz,dx*viewport.Y/viewport.X)*1.1
 local elevation = span*.5/math.tan(math.rad(camera.FieldOfView*.5))
 camera.CFrame = CFrame.lookAt(center+Vector3.new(0,elevation,0),center,Vector3.new(0,0,-1))
 camera.Focus = CFrame.new(center)
 local ul = camera:WorldToViewportPoint(Vector3.new(x0,center.Y,z0))
 local lr = camera:WorldToViewportPoint(Vector3.new(x1,center.Y,z1))
 local first = Vector2.new(ul.X/viewport.X,ul.Y/viewport.Y)
 local last = Vector2.new(lr.X/viewport.X,lr.Y/viewport.Y)
 assert(first.X>=0 and first.Y>=0 and last.X<=1 and last.Y<=1, id.." crop")
 local width = math.max(1,math.round(448*dx/math.max(dx,dz)))
 local height = math.max(1,math.round(448*dz/math.max(dx,dz)))
 backing.Size = Vector3.new(dx*3,1,dz*3)
 backing.Position = center-Vector3.new(0,200,0)
 backing.Color = Color3.fromRGB(17,22,29)
 task.wait(1)
 local pixels = capture(width,height,first,last)
 backing.Color = Color3.fromRGB(0,255,0)
 task.wait(.4)
 local alternate = capture(width,height,first,last)
 -- Two backgrounds distinguish empty sky from similarly coloured world meshes.
 for i = 0, width*height-1 do
  local offset = i*4
  local dg = buffer.readu8(alternate,offset+1)-buffer.readu8(pixels,offset+1)
  local green = buffer.readu8(alternate,offset+1)-buffer.readu8(alternate,offset)
  if green>30 and dg>25 then buffer.writeu32(pixels,offset,0) end
 end
 local compressed = game.EncodingService:CompressBuffer(pixels,Enum.CompressionAlgorithm.Zstd)
 local hex = buffer.tostring(compressed):gsub(".",function(c) return string.format("%02x",string.byte(c)) end)
 print("SURVEY_SIZE",id,width,height)
 for i = 1,#hex,8000 do print("SURVEY_RGBA",id,hex:sub(i,i+7999)) end
end
print("ATLAS_RENDER_COMPLETE")
