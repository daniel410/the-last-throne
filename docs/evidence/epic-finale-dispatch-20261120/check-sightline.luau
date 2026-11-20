assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local world = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local model = assert(world.folder:FindFirstChild('DispatchCarrierCradle', true))
local views = {
    detail = V(-910.16394, 180, -14691.13867),
    goal = V(-912.84998, 178, -14679.40039),
    leftOfSuri = V(-913.416, 178, -14683.360),
    rightOfSuri = V(-912.284, 178, -14675.440),
    overShoulder = V(-921.567, 178.6, -14684.600),
    middle = V(-911.507, 179, -14685.27),
}
local geometry = {}
local restored = {}
for _, part in ipairs(world.folder:GetDescendants()) do
    if part:IsA('BasePart') and (part.Position - model:GetPivot().Position).Magnitude < 100 and part.Transparency < .7 then
        if not part.CanQuery then
            part.CanQuery = true
            table.insert(restored, part)
        end
        table.insert(geometry, part)
    end
end
for _, p in ipairs(geometry) do
    if (p.Position - views.goal).Magnitude < 8 then
        print('TLT_EC_FOREGROUND', p:GetFullName(), p.Position, p.Size, p.Color)
    end
end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = geometry
for key, origin in pairs(views) do
    local blockers = {}
    local visible = 0
    local samples = 0
    for _, p in ipairs(model:GetChildren()) do
        if p.Name ~= 'BasaltDispatchFooting' and p.Name ~= 'CarrierSaddle' then continue end
        for _, z in ipairs({-.4, 0, .4}) do
            for _, y in ipairs({0, .3, .48}) do
                samples += 1
                local at = p.CFrame:PointToWorldSpace(p.Size * V(-.49, y, z))
                local hit = workspace:Raycast(origin, at - origin, params)
                if hit then
                    if hit.Instance:IsDescendantOf(model) then
                        visible += 1
                    else
                        local path = hit.Instance:GetFullName()
                        if blockers[path] then blockers[path].count += 1 else
                            blockers[path] = {count = 1, position = tostring(hit.Instance.Position), size = tostring(hit.Instance.Size)}
                        end
                    end
                end
            end
        end
    end
    print('TLT_EC_DISPATCH ' .. game.HttpService:JSONEncode({view=key, visible=visible, samples=samples, blockers=blockers}))
end
for _, p in ipairs(restored) do p.CanQuery = false end
