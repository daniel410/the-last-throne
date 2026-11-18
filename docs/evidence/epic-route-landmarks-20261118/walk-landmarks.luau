-- R15 runs on the final guide approach and on the known Deepwood overlap windows.
local Shared = game.ReplicatedStorage.Shared
local CampaignContent = require(Shared.CampaignContent)
local Nav = require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local Run = game:GetService('RunService')
local physics = game:GetService('PhysicsService')
local group = 'LandmarkReviewR15'
physics:RegisterCollisionGroup(group)
physics:CollisionGroupSetCollidable(group, group, false)

local function horizontal(point)
    return V(point.X, 0, point.Z)
end

local function leadIn(from, to)
    local route = Nav.route(from, to)
    assert(#route >= 2, 'guidance missing')
    local remaining = 64
    for i = #route, 2, -1 do
        local length = horizontal(route[i] - route[i-1]).Magnitude
        if length >= remaining then
            return route[i]:Lerp(route[i-1], remaining / length)
        end
        remaining -= length
    end
    return route[1]
end

local function endpoints(row)
    if row.lane then
        local lane = overlapLanes[row.lane]
        local first, last = #lane.samples, 1
        for _, contact in ipairs(assert(lane.contacts, 'contact samples missing')) do
            local nearest, gap = 1, math.huge
            for i, point in ipairs(lane.samples) do
                local distance = horizontal(point - contact).Magnitude
                if distance < gap then nearest, gap = i, distance end
            end
            assert(gap < 1, 'contact is outside sampled lane')
            first, last = math.min(first, nearest), math.max(last, nearest)
        end
        return lane.samples[math.max(1, first-5)], lane.samples[math.min(#lane.samples, last+5)], lane.contacts
    end
    local chapter = CampaignContent.byId[row.story]
    local previous = reviewWorld.spawns[chapter.zone].Position
    for _, goal in ipairs(chapter.goals) do
        if goal.id == row.goal then
            for _, step in ipairs(goal.activity and goal.activity.steps or {}) do
                if not row.step or step.id == row.step then
                    local target = V(table.unpack(step.position))
                    return leadIn(previous, target), target
                end
                previous = V(table.unpack(step.position))
            end
            assert(not row.step, 'missing guide step ' .. tostring(row.step))
            local target = V(table.unpack(goal.position))
            return leadIn(previous, target), target
        end
        local combat = chapter.combatRoutes and chapter.combatRoutes[goal.id]
        local positions = combat and (combat.worldPoints or combat.points)
        local steps = goal.activity and goal.activity.steps
        previous = V(table.unpack(positions and positions[#positions] or steps and steps[#steps].position or goal.position))
    end
    error('missing guide goal ' .. row.goal)
end

local function walk(rig, goal, contacts)
    local root, human = rig.HumanoidRootPart, rig.Humanoid
    local started, lastMoved, last = os.clock(), os.clock(), root.Position
    local distances = {}
    while os.clock() - started < 28 do
        for i, contact in ipairs(contacts or {}) do
            distances[i] = math.min(distances[i] or math.huge, horizontal(root.Position - contact).Magnitude)
        end
        local range = horizontal(root.Position - goal).Magnitude
        if range < 6 then
            return {arrived = true, gap = range, elapsed = os.clock() - started, closestToContacts = distances}
        end
        local route = Nav.route(root.Position, goal)
        if #route < 2 then return {arrived = false, reason = 'route', gap = range} end
        local i = 2
        while i < #route and horizontal(root.Position - route[i]).Magnitude < 3 do i += 1 end
        human:MoveTo(route[i])
        if horizontal(root.Position - last).Magnitude > .8 then
            last, lastMoved = root.Position, os.clock()
        elseif os.clock() - lastMoved > 7 then
            return {arrived = false, reason = 'stalled', gap = range, at = asArray(root.Position), closestToContacts = distances}
        end
        task.wait(.12)
    end
    return {arrived = false, reason = 'timeout', at = asArray(root.Position)}
end

local floorRay = RaycastParams.new()
floorRay.FilterType = Enum.RaycastFilterType.Include
floorRay.FilterDescendantsInstances = {workspace.Terrain, reviewWorld.folder}
floorRay.RespectCanCollide = true
local cases = {}
local walking = table.clone(expected)
table.insert(walking, {story = 'DW-02', goal = 'survivors', lane = 'DW-02:survivors:shelter', name = 'DeepwoodShelterPriorOverlap'})
table.insert(walking, {story = 'DW-Q1', goal = 'marsh_report', lane = 'DW-Q1:marsh_report', name = 'DeepwoodMarshPriorOverlap'})
for _, row in ipairs(walking) do
    local from, to, contacts = endpoints(row)
    local hit = assert(workspace:Raycast(from + V(0,8,0), V(0,-28,0), floorRay), row.name)
    local fromFloor = V(from.X, hit.Position.Y, from.Z)
    local desc = Instance.new('HumanoidDescription')
    local rig = game.Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
    desc:Destroy()
    rig.Name = 'LandmarkWalk_' .. row.name
    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA('BasePart') then part.CollisionGroup = group end
    end
    rig.Humanoid.WalkSpeed = 16
    rig.Humanoid.AutoJumpEnabled = false
    rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    rig.Parent = workspace
    rig:PivotTo(CFrame.new(fromFloor + V(0,5,0)))
    cases[row.name] = {rig = rig, from = fromFloor, target = to, contacts = contacts}
end

for _, service in ipairs({game.ServerScriptService, game.StarterPlayer, game.ReplicatedFirst, game.StarterGui}) do
    for _, child in ipairs(service:GetDescendants()) do
        if child:IsA('BaseScript') then child.Enabled = false end
    end
end
Run:Run()
task.wait(1)
local finished = 0
for _, row in ipairs(walking) do
    task.spawn(function()
        local case = cases[row.name]
        local ok, result = xpcall(function()
            local approach = walk(case.rig, case.target, case.contacts)
            local retreat = walk(case.rig, case.from, case.contacts)
            return {name = row.name, story = row.story, goal = row.goal, from = asArray(case.from),
                target = asArray(case.target), approach = approach, retreat = retreat}
        end, debug.traceback)
        case.rig:Destroy()
        finished += 1
        print('TLT_ROUTE_WALK '..game.HttpService:JSONEncode(ok and result or {name = row.name, error = result}))
    end)
end
while finished < #walking do task.wait(.15) end
