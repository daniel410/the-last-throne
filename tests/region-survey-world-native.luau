-- Compare the atlas to independently generated gameplay instances in a local Place.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local shared = game.ReplicatedStorage.Shared
local client = game.StarterPlayer.StarterPlayerScripts.Client
local content = require(shared.CampaignContent)
local areas = require(shared.CampaignAreas)
local fieldMap = require(client.RegionFieldMap)
local world = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local gui = Instance.new("ScreenGui")
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui
local field = fieldMap.create(gui, function() end)
local journal = require(shared.DeepwoodProgress).new()
local zones, sites, arrivals = 0, 0, 0
for id, zone in pairs(content.zones) do
 field.open(id, journal)
 local scene = field.panel.Chart.Survey
 local relief = scene.Relief
 local x0, z0, x1, z1 = areas.surveyExtent(zone)
 local function expectPosition(marker, actual)
  local u = (marker.Position.X.Scale - relief.Position.X.Scale) / relief.Size.X.Scale
  local v = (marker.Position.Y.Scale - relief.Position.Y.Scale) / relief.Size.Y.Scale
  local offset = Vector2.new(x0 + u*(x1-x0) - actual.X, z0 + v*(z1-z0) - actual.Z)
  assert(offset.Magnitude < .1, id.." "..marker.Name.." offset "..tostring(offset.Magnitude))
 end
 expectPosition(scene.Checkpoint, world.spawns[id].Position)
 arrivals += 1
 for i, area in ipairs(zone.expansionAreas or {}) do
  local node = world.nodes[area.chapterId..":"..area.goalId]
  expectPosition(scene["SitePin"..(i+1)], node.part.Position)
  sites += 1
 end
 zones += 1
 task.wait()
end
gui:Destroy()
assert(zones == 44 and arrivals == zones and sites > zones)
print("SURVEY_WORLD_PASS",zones,arrivals,sites)
