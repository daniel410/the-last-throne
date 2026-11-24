local expected = {
    {epic = 1, story = 'DW-07', goal = 'core_record', name = 'ConvoyRoadLoadingSill',
        fixture = 'AltarRoadWaitingBay', theme = 'Deepwood'},
    {epic = 2, story = 'GW-07', goal = 'exit', name = 'NorthernWindgapStrata',
        fixture = 'NorthernRoadWitnessStones', theme = 'Gloamwood'},
    {epic = 3, story = 'FV-07', goal = 'reunion', name = 'FreightSledLanding',
        fixture = 'ReunionTerraceBench', theme = 'FrozenVale'},
    {epic = 4, story = 'EC-07', goal = 'courier', name = 'DispatchCarrierCradle',
        fixture = 'DispatchMapRail', theme = 'EmberCaldera'},
    {epic = 5, story = 'HG-07', goal = 'portal', name = 'AlliedReturnParapet',
        fixture = 'AlliedExitWaymarker', theme = 'HauntedGraveyard'},
}
local function report(tag, data)
    print('TLT_' .. tag .. ' ' .. game.HttpService:JSONEncode(data))
end
local reviewWorld = Campaign.create()
local before = #reviewWorld.folder:GetDescendants()
local shots = {}
local Nav = require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
for _, row in ipairs(expected) do
    assert(Campaign.create(row.epic, reviewWorld) == reviewWorld)
    local old = checkModel(reviewWorld, row)
    local landmark = findModel(reviewWorld, row)
    local site = landmark.Parent
    local fixture = site:FindFirstChild(row.fixture)
    assert((fixture ~= nil) == candidate, 'fixture presence ' .. row.story)
    report('FINALE_EXISTING', old)
    if not candidate then continue end
    local check = table.clone(row)
    check.name = row.fixture
    local measured = checkModel(reviewWorld, check)
    assert((fixture:GetPivot().Position - fixture:GetAttribute('GroundPosition')).Magnitude < .01, row.story)
    assert(measured.bounds[2] <= 5, 'fixture height ' .. row.story)
    local separation = fixture:GetPivot().Position - landmark:GetPivot().Position
    measured.landmarkClearance = V(separation.X, 0, separation.Z).Magnitude
        - fixture:GetAttribute('PlacementRadius') - landmark:GetAttribute('PlacementRadius')
    assert(measured.landmarkClearance >= 1.99, 'primary landmark clearance ' .. row.story)
    local box, size = fixture:GetBoundingBox()
    local previous = reviewWorld.spawns[row.story].Position
    local content = require(game.ReplicatedStorage.Shared.CampaignContent).byId[row.story]
    for _, goal in ipairs(content.goals) do
        local target = V(table.unpack(goal.position))
        if goal.id ~= row.goal then
            local battle = content.combatRoutes and content.combatRoutes[goal.id]
            local points = battle and (battle.worldPoints or battle.points)
            local steps = goal.activity and goal.activity.steps
            previous = V(table.unpack(points and points[#points] or steps and steps[#steps].position or goal.position))
            continue
        end
        local route = Nav.route(previous, target)
        local minimum = math.huge
        for i = 2, #route do
            local a, b = route[i - 1], route[i]
            local samples = math.max(1, math.ceil((b - a).Magnitude))
            for j = 0, samples do
                local rel = box:PointToObjectSpace(a:Lerp(b, j / samples))
                local dx = math.max(0, math.abs(rel.X) - size.X / 2)
                local dz = math.max(0, math.abs(rel.Z) - size.Z / 2)
                minimum = math.min(minimum, Vector2.new(dx, dz).Magnitude)
            end
        end
        assert(minimum >= 8 and minimum < math.huge, 'approach clearance ' .. row.story)
        measured.routeClearance = minimum
        break
    end
    assert(measured.routeClearance, row.story)
    report('FINALE_FIXTURE', measured)
    local pivot = fixture:GetPivot()
    for _, view in ipairs({
        {'goal-side', V(-9, 6, -21)},
        {'return-side', V(12, 6, 16)},
    }) do
        table.insert(shots, {
            id = row.story .. '_' .. view[1], theme = row.theme,
            origin = asArray(pivot:PointToWorldSpace(view[2])),
            aim = asArray(box.Position + V(0, .5, 0)),
        })
    end
end
assert(before == #reviewWorld.folder:GetDescendants(), 'cached create duplicated geometry')
if candidate then report('FINALE_CAMERAS', shots) end
