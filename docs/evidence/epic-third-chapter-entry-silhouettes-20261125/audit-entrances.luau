assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated local place only')
local Shared = game.ReplicatedStorage.Shared
local content = require(Shared.CampaignContent)
local bounds = require(Shared.CampaignBounds)
local World = game.ServerScriptService.Server.World
local existingWorld = require(World.CampaignWorld).create()
local V = Vector3.new
local sites = {
    {'DW-03', 'Deepwood', 2},
    {'GW-03', 'Gloamwood', 1},
    {'FV-03', 'FrozenVale', 1},
    {'EC-03', 'EmberCaldera', 1},
    {'HG-03', 'HauntedGraveyard', 2},
}
local function tuple(vector)
    return {vector.X, vector.Y, vector.Z}
end

local function onFloor(point)
    local height = assert(bounds.surface(point.X, point.Z), 'entrance route surface')
    return V(point.X, height, point.Z)
end

local function geometry(part)
    return {
        name = part.Name,
        class = part.ClassName,
        shape = part:IsA('Part') and tostring(part.Shape) or nil,
        frame = {part.CFrame:GetComponents()},
        size = tuple(part.Size),
        color = {part.Color.R, part.Color.G, part.Color.B},
        material = tostring(part.Material),
        alpha = part.Transparency,
        solid = part.CanCollide,
    }
end

local function emit(label, data)
    print(label .. ' ' .. game.HttpService:JSONEncode(data))
end

local shots, approaches, targets = {}, {}, {}
local rays = RaycastParams.new()
rays.FilterType = Enum.RaycastFilterType.Include
rays.FilterDescendantsInstances = {existingWorld.terrain, workspace.Terrain}
rays.RespectCanCollide = true

for _, site in ipairs(sites) do
    local id, theme, goalIndex = table.unpack(site)
    local chapter = content.byId[id]
    local goal = chapter.expansionGoals[goalIndex]
    local area
    for _, candidate in ipairs(content.zones[chapter.zone].expansionAreas) do
        if candidate.id == goal.area then
            area = candidate
            break
        end
    end
    assert(area, id)
    local entry = V(table.unpack(area.entry))
    local rampStart = V(table.unpack(area.connector.rampStart))
    local rampEnd = V(table.unpack(area.connector.rampEnd))
    local inward = ((rampEnd - rampStart) * V(1, 0, 1)).Unit
    local side = V(inward.Z, 0, -inward.X)
    local from, target = onFloor(entry - inward * 16), onFloor(entry + inward * 16)
    approaches[id] = {from = from, target = target}

    local function shot(suffix, direction)
        local offset = suffix == '-approach' and 6 or -6
        local eye = onFloor(entry + inward * (54 * direction) + side * offset) + V(0, 7, 0)
        table.insert(shots, {id = id .. suffix, theme = theme,
            origin = tuple(eye), aim = tuple(entry + V(0, 10, 0))})
    end
    shot('-approach', -1)
    shot('-return', 1)

    local sceneName = id .. '_' .. goal.id
    targets[sceneName] = true
    local scene = existingWorld.folder.CampaignExpansion['Epic' .. chapter.epic][sceneName]
    assert(scene.ModelStreamingMode == Enum.ModelStreamingMode.Atomic, sceneName)
    local arch = scene.IncidentEntranceArch
    assert((arch:GetPivot().Position - entry).Magnitude < .01, id .. ' entrance pivot')
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Include
    overlap.FilterDescendantsInstances = {arch}
    overlap.RespectCanCollide = true

    local floorError, samples = 0, 65
    for i = 0, samples - 1 do
        local point = onFloor(from:Lerp(target, i / (samples - 1)))
        local hit = assert(workspace:Raycast(point + V(0, 8, 0), V(0, -24, 0), rays), id .. ' missing floor')
        floorError = math.max(floorError, math.abs(point.Y - hit.Position.Y))
        local probe = CFrame.lookAt(point + V(0, 3.5, 0), point + V(0, 3.5, 0) + inward)
        local crossing = workspace:GetPartBoundsInBox(probe, V(4, 5.5, 4), overlap)
        assert(#crossing == 0, id .. ' entrance body contact: ' .. (crossing[1] and crossing[1].Name or ''))
    end
    assert(floorError < 1, id .. ' entrance floor height')
    local foundations = {}
    local board = scene.IncidentBoard
    assert(board.IncidentName.TextLabel.Text == area.name, id .. ' board text')
    for _, child in ipairs(scene:GetChildren()) do
        if child:IsA('BasePart') and child.Name == 'ExpansionWalkingLine' then
            table.insert(foundations, geometry(child))
        end
    end
    assert(#foundations == 3, id .. ' route markers')
    local objective = existingWorld.nodes[id .. ':' .. goal.id]
    local steps = {}
    for _, step in ipairs(goal.activity.steps) do
        local node = existingWorld.activityNodes[id .. ':' .. goal.id .. ':' .. step.id]
        table.insert(steps, tuple(node.part.Position))
    end
    emit('ENTRY_ROUTE', {
        id = id, scene = sceneName, pivot = {arch:GetPivot():GetComponents()},
        board = geometry(board), boardText = area.name, path = foundations,
        objective = tuple(objective.part.Position), steps = steps,
        floorError = floorError, samples = samples, distance = ((target - from) * V(1, 0, 1)).Magnitude,
    })
end

for _, epic in ipairs(existingWorld.folder.CampaignExpansion:GetChildren()) do
    for _, scene in ipairs(epic:GetChildren()) do
        local arch = scene:FindFirstChild('IncidentEntranceArch')
        if not arch then continue end
        local _, size = arch:GetBoundingBox()
        local parts, solid = {}, 0
        for _, part in ipairs(arch:GetDescendants()) do
            if targets[scene.Name] then
                assert(not part:IsA('Light'), part:GetFullName())
            end
            if not part:IsA('BasePart') then continue end
            assert(part.Anchored and not part.CanTouch and part.CanQuery == part.CanCollide, part:GetFullName())
            if part.CanCollide then solid += 1 end
            table.insert(parts, geometry(part))
        end
        assert(solid > 0, scene.Name .. ' permanent supports')
        emit('ENTRY_MODEL', {scene = scene.Name, size = tuple(size), solid = solid, parts = parts})
    end
end

local cameraPlan = game.HttpService:JSONEncode(shots)
print('INFRASTRUCTURE_CAMERA_PLAN ' .. cameraPlan)
