-- Isolated Studio audit with no player or persistent data.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local world = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local landing = assert(world.folder:FindFirstChild('FreightSledLanding', true))
local origin = V(-952.85, 130, -10847.9)
local near, restored = {}, {}
for _, part in ipairs(world.folder:GetDescendants()) do
    if part:IsA('BasePart') and (part.Position - origin).Magnitude < 100 and part.Transparency < .7 then
        if not part.CanQuery then
            part.CanQuery = true
            table.insert(restored, part)
        end
        table.insert(near, part)
    end
end
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = near
local results = {}
for _, part in ipairs(landing:GetChildren()) do
    if part.Name ~= 'SledStopCheek' then continue end
    local visible, lantern = 0, 0
    for _, x in ipairs({-.4, 0, .4}) do
        local at = part.CFrame:PointToWorldSpace(part.Size * V(x, .35, -.2))
        local hit = workspace:Raycast(origin, at - origin, ray)
        if hit and hit.Instance == part then visible += 1 end
        if hit and hit.Instance:FindFirstAncestor('RouteLantern') then lantern += 1 end
    end
    table.insert(results, {visible = visible, lantern = lantern})
end
for _, part in ipairs(restored) do part.CanQuery = false end
assert(#results == 2)
print('TLT_SLED_SIGHT ' .. game.HttpService:JSONEncode(results))
