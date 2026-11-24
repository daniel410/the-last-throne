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
    {'DW-01', 'Deepwood', 1, 10, 'CreekCrossingShoulder'},
    {'GW-01', 'Gloamwood', 2, -10, 'ScoutCrouchNotch'},
    {'FV-01', 'FrozenVale', 1, 12, 'RefugeWindbreakPocket'},
    {'EC-01', 'EmberCaldera', 1, -11, 'LiftLandingGuide'},
    {'HG-01', 'HauntedGraveyard', 3, -11, 'KeeperRailAnchor'},
}
local shots = {}
local approaches, targets = {}, {}
for _, site in ipairs(sites) do
    local id, theme, index, side, name = table.unpack(site)
    local chapter = content.byId[id]
    local goal = chapter.expansionGoals[2]
    local activity = goal.activity
    local area
    for _, candidate in ipairs(content.zones[chapter.zone].expansionAreas) do
        if candidate.id == goal.area then area = candidate; break end
    end
    assert(area, id)
    local at = V(table.unpack(activity.steps[index].position))
    local previous = V(table.unpack(index == 1 and area.entry or activity.steps[index - 1].position))
    local delta = previous - at
    local front = V(delta.X, 0, delta.Z).Unit
    local right = V(-front.Z, 0, front.X)
    local against = at + right * side
    targets[name] = {origin = against, at = at, previous = previous, activity = activity, area = area}
    local function shot(suffix, offset)
        local eye = at + offset
        eye = V(eye.X, (bounds.surface(eye.X, eye.Z) or at.Y) + 7, eye.Z)
        table.insert(shots, {
            id = id .. suffix, theme = theme, aim = {against.X, against.Y + 1, against.Z},
            origin = {eye.X, eye.Y, eye.Z},
        })
    end
    approaches[id] = {from = at + front * 16, target = at}
    shot('-approach', front * math.min(20, delta.Magnitude * .8))
    shot('-return-side', -front * 12 + right * (side + math.sign(side) * 14))
end
local cameraPlan = game.HttpService:JSONEncode(shots)
print('OPENING_CAMERA_PLAN ' .. cameraPlan)

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
    local fixture = targets[model.Name]
    if fixture then
        assert((ground - fixture.origin).Magnitude < .51 and target == fixture.at, id .. ' fixture position')
        clearance = math.huge
        local function measure(from, to)
            local samples = math.max(1, math.ceil((to - from).Magnitude * 2))
            for i = 0, samples do
                local localPoint = box:PointToObjectSpace(from:Lerp(to, i / samples))
                local x = math.max(0, math.abs(localPoint.X) - size.X / 2)
                local z = math.max(0, math.abs(localPoint.Z) - size.Z / 2)
                clearance = math.min(clearance, Vector2.new(x, z).Magnitude)
            end
        end
        local previous = V(table.unpack(fixture.area.entry))
        for _, routeStep in ipairs(fixture.activity.steps) do
            local nextPoint = V(table.unpack(routeStep.position))
            measure(previous, nextPoint)
            previous = nextPoint
        end
        if fixture.activity.finish then
            measure(previous, V(table.unpack(fixture.activity.finish.position)))
        end
        assert(clearance >= 3, id .. ' route clearance ' .. clearance)
    end
    print('OPENING_LANDMARK ' .. game.HttpService:JSONEncode({
        chapter = id, model = model.Name, goal = goal, step = step,
        ground = {ground.X, ground.Y, ground.Z}, anchor = {target.X, target.Y, target.Z},
        parts = #parts, routeClearance = clearance, maxFloorError = floorError, height = size.Y,
        bounds = {size.X, size.Y, size.Z}, version = model:GetAttribute('QuestLandmarkVersion'),
    }))
end
