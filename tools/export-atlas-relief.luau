-- Offline topographic plates. Only the throwaway survey world is made queryable.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Shared = game.ReplicatedStorage.Shared
local campaign = require(Shared.CampaignContent)
local areas = require(Shared.CampaignAreas)
local world = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local include = {workspace.Terrain}
for _, part in ipairs(world.folder:GetDescendants()) do
 if part:IsA("BasePart") and part.Transparency < .5 and not part:IsA("SpawnLocation")
  and not part:FindFirstAncestor("NPCActors") and not part:FindFirstAncestor("Objectives") then
  part.CanQuery = true
  table.insert(include, part)
 end
end
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = include
local encoding = game:GetService("EncodingService")
local width = 160
for id, zone in pairs(campaign.zones) do
 local x0, z0, x1, z1 = areas.extent(zone)
 local height = math.clamp(math.round(width * (z1 - z0) / (x1 - x0)), 64, 224)
 local pixels = buffer.create(width * height * 6)
 for y = 0, height - 1 do
  for x = 0, width - 1 do
   local wx, wz = x0 + (x + .5) / width * (x1 - x0), z0 + (y + .5) / height * (z1 - z0)
   if areas.containsZone(zone, wx, wz, 1) then
    local hit = workspace:Raycast(Vector3.new(wx, zone.center[2] + 650, wz), Vector3.new(0, -1100, 0), ray)
    if hit then
     local color = hit.Instance == workspace.Terrain and workspace.Terrain:GetMaterialColor(hit.Material) or hit.Instance.Color
     local offset = (y * width + x) * 6
     buffer.writeu8(pixels, offset, math.round(color.R * 255))
     buffer.writeu8(pixels, offset + 1, math.round(color.G * 255))
     buffer.writeu8(pixels, offset + 2, math.round(color.B * 255))
     buffer.writei16(pixels, offset + 3, math.clamp(math.round((hit.Position.Y - zone.center[2]) * 8), -32768, 32767))
     buffer.writeu8(pixels, offset + 5, 1 + math.round(125 * (1 + hit.Normal:Dot(Vector3.new(-.55,.6,-.58).Unit))))
    end
   end
  end
  if y % 32 == 0 then task.wait() end
 end
 local raw = buffer.tostring(encoding:Base64Encode(pixels))
 print("RELIEF_SIZE", id, width, height)
 for i = 1, #raw, 8000 do print("RELIEF_ROW", id, raw:sub(i,i+7999)) end
end
print("ATLAS_RELIEF_COMPLETE")
