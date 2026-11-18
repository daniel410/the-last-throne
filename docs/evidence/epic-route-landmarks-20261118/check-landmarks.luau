local World = game.ServerScriptService.Server.World
local Campaign = require(World.CampaignWorld)
local V = Vector3.new
local expected = {
    {epic = 1, story = 'DW-04', goal = 'link_record', name = 'WatchtowerSignalFooting'},
    {epic = 2, story = 'GW-04', goal = 'lantern', name = 'RootwayBankCut'},
    {epic = 3, story = 'FV-04', goal = 'relay_west', name = 'WestArchiveConduitBed'},
    {epic = 3, story = 'FV-04', goal = 'relay_east', name = 'EastArchiveConduitBed'},
    {epic = 4, story = 'EC-04', goal = 'west_valve', name = 'WesternIntakeSluice'},
    {epic = 4, story = 'EC-04', goal = 'east_valve', name = 'EasternReturnRace'},
    {epic = 5, story = 'HG-01', goal = 'shelter', name = 'KeeperLanternRevetment'},
}
local function asArray(point)
    return {point.X, point.Y, point.Z}
end
local function findModel(world, row)
    local site = world.folder.EpicWorldArt['EpicWorldArt_' .. row.epic][row.story]
    return assert(site:FindFirstChild(row.name), 'missing landmark ' .. row.name)
end
local function checkModel(world, row)
    local model = findModel(world, row)
    assert(model:IsA('Model') and model.ModelStreamingMode == Enum.ModelStreamingMode.Atomic)
    assert(model:GetAttribute('StoryZone') == row.story and model:GetAttribute('StoryGoal') == row.goal)
    assert(model:GetAttribute('LandmarkVersion') == 2 and model:GetAttribute('SourceKind') == 'NewNativeGeometry')
    local ground = assert(model:GetAttribute('GroundPosition'))
    local approach = assert(model:GetAttribute('ApproachPosition'))
    local bounds, size = model:GetBoundingBox()
    local burial = ground.Y - (bounds.Y - size.Y / 2)
    assert(burial >= 0 and burial < 2.8, 'base drifts from ground ' .. row.name)

    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {model}
    ray.RespectCanCollide = true
    local slopes = {}
    for _, pair in ipairs({{0,0},{-.4,-.4},{-.4,.4},{.4,-.4},{.4,.4}}) do
        local foot = bounds:PointToWorldSpace(V(size.X * pair[1], ground.Y - bounds.Y, size.Z * pair[2]))
        local hit = workspace:Raycast(foot + V(0,1,0), V(0,-3,0), ray)
        assert(hit and math.abs(hit.Position.Y - ground.Y) < .75, 'unsupported footprint ' .. row.name)
        table.insert(slopes, hit.Position.Y - ground.Y)
    end

    local parts = 0
    for _, part in ipairs(model:GetDescendants()) do
        assert(part:IsA('BasePart') and part.Anchored and not part.CanTouch and not part.CanQuery and not part.CanCollide,
            'decorative part changed physical state ' .. part:GetFullName())
        assert(part:GetAttribute('TLTSceneryDistance') == 480 and part.Material ~= Enum.Material.Neon)
        parts += 1
    end
    assert(parts == model:GetAttribute('PartCount'))
    return {story = row.story, goal = row.goal, name = model.Name, parts = parts, ground = asArray(ground),
        approach = asArray(approach), bounds = asArray(size), footprintHeightDeltas = slopes, buriedDepth = burial}
end
if not baseline and not sideFrames then
    for epic = 1,5 do
        local standalone = Campaign.create(epic)
        for _, row in ipairs(expected) do
            if row.epic == epic then
                print('TLT_ROUTE_DIRECT '..game.HttpService:JSONEncode(checkModel(standalone, row)))
            end
        end
        standalone.folder:Destroy()
        workspace.Terrain:Clear()
    end
end
local reviewWorld = Campaign.create()
if not baseline and not sideFrames then
    local before = #reviewWorld.folder:GetDescendants()
    for epic = 1,5 do
        Campaign.create(epic, reviewWorld)
        for _, row in ipairs(expected) do
            if row.epic == epic then
                print('TLT_ROUTE_MODEL '..game.HttpService:JSONEncode(checkModel(reviewWorld, row)))
            end
        end
    end
    assert(before == #reviewWorld.folder:GetDescendants(), 'cached create duplicated geometry')
end
