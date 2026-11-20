assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated local place only')
local World = game.ServerScriptService.Server.World
local Shared = game.ReplicatedStorage.Shared
local content = require(Shared.CampaignContent)
local bounds = require(Shared.CampaignBounds)
local CampaignWorld = require(World.CampaignWorld)
local existingWorld
for epic = 1, 5 do existingWorld = CampaignWorld.create(epic, existingWorld) end

local V = Vector3.new
local sites = {
    {'DW-02', 'Deepwood', 2, 2},
    {'GW-02', 'Gloamwood', 1, 2},
    {'FV-02', 'FrozenVale', 2, 1},
    {'EC-02', 'EmberCaldera', 2, 2},
    {'HG-02', 'HauntedGraveyard', 2, 3},
}
local shots, approaches = {}, {}
for _, site in ipairs(sites) do
    local id, theme, goalIndex, index = table.unpack(site)
    local chapter = content.byId[id]
    local goal = chapter.expansionGoals[goalIndex]
    local activity = goal.activity
    local area
    for _, candidate in ipairs(content.zones[chapter.zone].expansionAreas) do
        if candidate.id == goal.area then area = candidate; break end
    end
    assert(area, id)
    local at = V(table.unpack(activity.steps[index].position))
    local previous = V(table.unpack(index == 1 and area.connector.rampEnd or activity.steps[index - 1].position))
    local nextStep = activity.steps[index + 1] or activity.finish
    local following = nextStep and V(table.unpack(nextStep.position)) or previous
    local delta = previous - at
    local front = V(delta.X, 0, delta.Z).Unit
    local right = V(-front.Z, 0, front.X)
    local function shot(suffix, offset)
        local eye = at + offset
        eye = V(eye.X, (bounds.surface(eye.X, eye.Z) or at.Y) + 7, eye.Z)
        table.insert(shots, {
            id = id .. suffix, theme = theme, aim = {at.X - 2 * right.X, at.Y + 1, at.Z - 2 * right.Z},
            origin = {eye.X, eye.Y, eye.Z},
        })
    end
    approaches[id] = {from = previous:Lerp(at, math.max(0, 1 - 32 / delta.Magnitude)),
        previous = previous, target = at, following = following, goal = goal.id, step = activity.steps[index].id}
    local approachEye = front * math.min(26, delta.Magnitude * .85)
    if id == 'FV-02' then approachEye = front * 15 + right * 7 end
    shot('-approach', approachEye)
    shot('-side', front * 10 + right * 20)
end
local cameraPlan = game.HttpService:JSONEncode(shots)
print('SECOND_CHAPTER_CAMERA_PLAN ' .. cameraPlan)

local solid = RaycastParams.new()
solid.FilterType = Enum.RaycastFilterType.Include
solid.FilterDescendantsInstances = {existingWorld.terrain, workspace.Terrain}
solid.RespectCanCollide = true
local models = {}
for _, model in ipairs(existingWorld.folder.CampaignExpansion:GetDescendants()) do
    if not model:GetAttribute('QuestLandmarkVersion') then continue end
    local id = model:GetAttribute('StoryZone')
    assert(not models[model.Name], 'duplicate landmark: ' .. model.Name)
    models[model.Name] = true
    local goal = model:GetAttribute('StoryGoal')
    local step = model:GetAttribute('StoryStep')
    local target = model:GetAttribute('ApproachPosition')
    local ground = model:GetAttribute('GroundPosition')
    local node = existingWorld.activityNodes[id .. ':' .. goal .. ':' .. (step or 'resolve')]
    assert(node and node.part.Position == target + V(0, 1, 0), id .. ' existing interaction')
    assert(model.ModelStreamingMode == Enum.ModelStreamingMode.Atomic, id)
    assert((model:GetPivot().Position - ground).Magnitude < .01, id .. ' pivot')
    local box, size = model:GetBoundingBox()
    local bottom = box.Y - size.Y / 2
    assert(math.abs(bottom - ground.Y) < .8, id .. ' ground contact')

    local floorError = 0
    for _, point in ipairs({V(0, 0, 0), V(-1, 0, -1), V(1, 0, -1), V(-1, 0, 1), V(1, 0, 1)}) do
        local xy = box:PointToWorldSpace(V(point.X * size.X / 2, 0, point.Z * size.Z / 2))
        local hit = assert(workspace:Raycast(V(xy.X, ground.Y + 5, xy.Z), V(0, -12, 0), solid), id)
        floorError = math.max(floorError, math.abs(hit.Position.Y - ground.Y))
    end
    assert(floorError < .2, id .. ' solid floor')
    local parts = model:GetDescendants()
    assert(#parts == model:GetAttribute('PartCount'), id)
    for _, part in ipairs(parts) do
        assert(part:IsA('BasePart') and part.Anchored and not part.CanCollide
            and not part.CanTouch and not part.CanQuery, part:GetFullName())
    end
    local epic = tonumber(model:FindFirstAncestorWhichIsA('Folder').Name:match('^Epic(%d)$'))
    if not epic then
        epic = tonumber(model.Parent.Parent.Name:match('^Epic(%d)$'))
    end
    assert(epic and CampaignWorld.create(epic, existingWorld) == existingWorld, id .. ' cache')
    assert(model.Parent:FindFirstChild(model.Name) == model, id .. ' cached model')
    local clearance
    local route = approaches[id]
    if route and route.goal == goal and route.step == step then
        clearance = math.huge
        for _, point in ipairs({route.previous, route.following}) do
            local samples = math.max(1, math.ceil((target - point).Magnitude))
            for i = 0, samples do
                local rel = box:PointToObjectSpace(target:Lerp(point, i / samples))
                local dx = math.max(0, math.abs(rel.X) - size.X / 2)
                local dz = math.max(0, math.abs(rel.Z) - size.Z / 2)
                clearance = math.min(clearance, Vector2.new(dx, dz).Magnitude)
            end
        end
        assert(clearance >= 3, id .. ' authored route clearance: ' .. clearance)
    end
    print('SECOND_CHAPTER_LANDMARK ' .. game.HttpService:JSONEncode({
        chapter = id, model = model.Name, goal = goal, step = step,
        ground = {ground.X, ground.Y, ground.Z}, anchor = {target.X, target.Y, target.Z},
        parts = #parts, clearance = clearance, maxFloorError = floorError, height = size.Y,
        bounds = {size.X, size.Y, size.Z}, version = model:GetAttribute('QuestLandmarkVersion'),
    }))
end
