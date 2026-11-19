-- Append in a do block after the inherited audit, or run against the baseline.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local World = game.ServerScriptService.Server.World
local Campaign = require(game.ReplicatedStorage.Shared.CampaignContent)
local world = existingWorld or require(World.CampaignWorld).create()
local checks = {
    {'DW-Q1', 'exp_1', 1, 'MarshDryPackShelf', 'Deepwood', 6},
    {'GW-03', 'exp_1', 2, 'RefugeScoutShelter', 'Gloamwood', 10},
    {'EC-06', 'exp_2', 4, 'HeatworksProtectionManifold', 'EmberCaldera', 11},
    {'HG-03', 'exp_2', 5, 'PassageDrainInspectionBox', 'HauntedGraveyard', 7},
}
local cameraRows = {}
local function array(point)
    return {point.X, point.Y, point.Z}
end
local ray = RaycastParams.new()
ray.RespectCanCollide = true

for _, row in ipairs(checks) do
    local chapterId, goalId, epic, name, theme, count = table.unpack(row)
    local chapter = Campaign.byId[chapterId]
    local goal
    for _, item in ipairs(chapter.goals) do
        if item.id == goalId then goal = item; break end
    end
    local steps = goal.activity.steps
    local target, from = 2, 1
    if chapterId == 'HG-03' then target, from = 1, 2 end
    local at = V(table.unpack(steps[target].position))
    local previous = V(table.unpack(steps[from].position))
    local towardPrevious = V(previous.X - at.X, 0, previous.Z - at.Z).Unit
    local frame = CFrame.lookAlong(at, towardPrevious) * CFrame.new(6, 0, -1.8)
    local scene = world.folder.CampaignExpansion['Epic' .. epic][chapterId .. '_' .. goalId]
    local model = scene:FindFirstChild(name)
    if expectStations then
        assert(model and #model:GetChildren() == count, name)
        assert(model:GetAttribute('ExpansionEvent') == chapterId .. ':' .. goalId, name)
        assert(model:GetAttribute('ExpansionMin') == 0 and model:GetAttribute('ExpansionMax') == 3, name)
        for _, part in ipairs(model:GetChildren()) do
            assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery, part.Name)
            assert(part.Position.Y >= at.Y and part.Transparency == 0, part.Name)
        end
        for _, x in ipairs(chapterId == 'HG-03' and {} or {-3.25, 3.25}) do
            local foot = frame * V(x, 2, 0)
            local hit = workspace:Raycast(foot, V(0, -4, 0), ray)
            assert(hit and math.abs(hit.Position.Y - at.Y) < .5, name .. ' footing')
        end
    else
        assert(not model, name)
    end
    local goals = {}
    for _, step in ipairs(steps) do
        table.insert(goals, step.position)
    end
    local origin = frame * V(-11, 5.8, -16)
    local aim = frame * V(0, 2.5, 0)
    local result = {
        name = name, scene = scene.Name, parts = model and count or 0,
        goals = goals, site = array(frame.Position),
    }
    if chapterId == 'HG-03' then
        origin = previous + V(0, 5.8, 0)
        aim = at + V(0, 2.5, 0)
        if model then
            local center = model:GetBoundingBox().Position
            local toModel = center - origin
            result.site = array(center)
            result.angle = math.deg(math.acos(math.clamp(toModel.Unit:Dot((aim - origin).Unit), -1, 1)))
            result.clearRay = workspace:Raycast(origin, toModel, ray) == nil
            local foot = workspace:Raycast(center + V(0, 2, 0), V(0, -9, 0), ray)
            assert(foot and math.abs(foot.Position.Y - at.Y) < .5, name .. ' footing')
        end
    end
    print('TLT_STATION ' .. game.HttpService:JSONEncode(result))
    table.insert(cameraRows, {
        id = chapterId .. '_station', theme = theme,
        origin = array(origin), aim = array(aim),
    })
end
for _, shot in ipairs(extraCameras) do table.insert(cameraRows, shot) end
local cameraPlan = game.HttpService:JSONEncode(cameraRows)
