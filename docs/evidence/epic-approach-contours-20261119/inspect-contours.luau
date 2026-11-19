local function inspectContours(world, onlyEpic)
    local V = Vector3.new
    local rows = {
        {1, 'DW-Q1', 'exp_1', 'MarshFloodcut', 4},
        {2, 'GW-03', 'exp_1', 'RefugeRootShelf', 7},
        {3, 'FV-03', 'west_beacon', 'AvalancheBendWindcut', 5},
        {4, 'EC-06', 'exp_2', 'HeatworksBasaltCutbank', 8},
        {5, 'HG-03', 'exp_2', 'FortressDrainRetainingRuin', 6},
    }
    local ray = RaycastParams.new()
    ray.RespectCanCollide = true
    for _, row in ipairs(rows) do
        local epic, story, goal, name, expected = table.unpack(row)
        if onlyEpic and onlyEpic ~= epic then continue end
        local folder = world.folder
        local parent = if epic == 3 then folder.EpicWorldArt.EpicWorldArt_3[story]
            else folder.CampaignExpansion['Epic' .. epic][story .. '_' .. goal]
        local model = assert(parent:FindFirstChild(name), name)
        assert(model.ModelStreamingMode == Enum.ModelStreamingMode.Atomic, name)
        assert(model:GetAttribute('StoryZone') == story and model:GetAttribute('StoryGoal') == goal, name)
        local ground = model:GetAttribute('GroundPosition')
        assert(ground and (model:GetPivot().Position - ground).Magnitude < .01, name)
        local cf, size = model:GetBoundingBox()
        local parts = #model:GetChildren()
        assert(parts == model:GetAttribute('PartCount') and parts == expected, name)
        for _, part in ipairs(model:GetChildren()) do
            assert(part:IsA('BasePart') and part.Anchored and part.Transparency == 0
                and not part.CanCollide and not part.CanQuery and not part.CanTouch, part:GetFullName())
        end
        local samples = {}
        for _, offset in ipairs({0, -.3, .3}) do
            local point = cf * V(size.X * offset, 0, 0)
            local hit = workspace:Raycast(V(point.X, ground.Y + 1, point.Z), V(0, -4, 0), ray)
            assert(hit and math.abs(hit.Position.Y - ground.Y) < 1.25, name .. ' footing')
            table.insert(samples, hit.Position.Y - ground.Y)
        end
        if not onlyEpic then
            print('TLT_CONTOUR ' .. game.HttpService:JSONEncode({
                story = story, name = name, parts = parts,
                position = {ground.X, ground.Y, ground.Z}, bounds = {size.X, size.Y, size.Z},
                groundDeltas = samples,
            }))
        end
    end
end
-- WORLD READY
inspectContours(reviewWorld, nil)
