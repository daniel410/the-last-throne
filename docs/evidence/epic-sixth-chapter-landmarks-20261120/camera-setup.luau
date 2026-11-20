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
    {'DW-06', 'Deepwood', 1, 2, -11},
    {'GW-06', 'Gloamwood', 1, false, 12},
    {'FV-06', 'FrozenVale', 1, 3, -11},
    {'EC-06', 'EmberCaldera', 1, 2, 11},
    {'HG-06', 'HauntedGraveyard', 2, 2, -11},
}
local shots, approaches = {}, {}
for _, site in ipairs(sites) do
    local id, theme, goalIndex, index, side = table.unpack(site)
    local chapter = content.byId[id]
    local goal = chapter.expansionGoals[goalIndex]
    local activity = goal.activity
    local area
    for _, candidate in ipairs(content.zones[chapter.zone].expansionAreas) do
        if candidate.id == goal.area then area = candidate; break end
    end
    assert(area, id)
    local step = index and activity.steps[index] or assert(activity.finish)
    local at = V(table.unpack(step.position))
    local previous, following
    if index then
        previous = V(table.unpack(index == 1 and area.connector.rampEnd or activity.steps[index - 1].position))
        local nextStep = activity.steps[index + 1] or activity.finish
        following = nextStep and V(table.unpack(nextStep.position)) or previous
    else
        previous = at + V(0, 0, 32)
        following = at - V(0, 0, 20)
    end
    local delta = previous - at
    local facing = index == 1 and (V(table.unpack(area.entry)) - at) or delta
    local front = V(facing.X, 0, facing.Z).Unit
    local right = V(-front.Z, 0, front.X)
    local function shot(suffix, offset)
        local eye = at + offset
        eye = V(eye.X, (bounds.surface(eye.X, eye.Z) or at.Y) + 7, eye.Z)
        table.insert(shots, {
            id = id .. suffix, theme = theme, aim = {at.X + side * .53 * right.X, at.Y + 1.1, at.Z + (index and side * .53 * right.Z or -2.65)},
            origin = {eye.X, eye.Y, eye.Z},
        })
    end
    approaches[id] = {from = previous:Lerp(at, math.max(0, 1 - 32 / delta.Magnitude)),
        previous = previous, target = at, following = following, goal = goal.id, step = step.id}
    local approachEye = front * math.min(26, delta.Magnitude * .85)
    shot('-approach', approachEye)
    shot('-return-side', -front * 12 + right * math.sign(side) * 17)
end
local cameraPlan = game.HttpService:JSONEncode(shots)
print('SIXTH_CHAPTER_CAMERA_PLAN ' .. cameraPlan)

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
    if route and route.goal == goal and route.step == (step or 'resolve') then
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
    local actorClearance
    if clearance then
        for _, actor in ipairs(model.Parent:GetChildren()) do
            local stageMin = actor:GetAttribute('ExpansionMin')
            local stageMax = actor:GetAttribute('ExpansionMax')
            if not stageMin or not stageMax then continue end
            for stage = stageMin, stageMax do
                local pose = actor:GetAttribute('ExpansionPose' .. stage)
                if not pose then continue end
                local rel = box:PointToObjectSpace(pose.Position)
                local dx = math.max(0, math.abs(rel.X) - size.X / 2)
                local dz = math.max(0, math.abs(rel.Z) - size.Z / 2)
                actorClearance = math.min(actorClearance or math.huge, Vector2.new(dx, dz).Magnitude)
            end
        end
        assert(not actorClearance or actorClearance >= 3, id .. ' actor pose clearance: ' .. tostring(actorClearance))
    end
    print('SIXTH_CHAPTER_LANDMARK ' .. game.HttpService:JSONEncode({
        chapter = id, model = model.Name, goal = goal, step = step,
        ground = {ground.X, ground.Y, ground.Z}, anchor = {target.X, target.Y, target.Z},
        parts = #parts, clearance = clearance, actorClearance = actorClearance, maxFloorError = floorError, height = size.Y,
        bounds = {size.X, size.Y, size.Z}, version = model:GetAttribute('QuestLandmarkVersion'),
    }))
end
