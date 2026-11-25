-- Isolate obstruction by the existing canopy and its posts.
do
    local fixture = targets.RefugeLanternReturn
    local scene = existingWorld.folder.CampaignExpansion
    local shelter = assert(scene:FindFirstChild('RefugeScoutShelter', true))
    local shelf = assert(scene:FindFirstChild('RefugeLanternReturn', true))
    local plank = assert(shelf:FindFirstChild('LanternReturnShelf'))
    local queryable = {}
    for _, part in ipairs(shelter:GetDescendants()) do
        if part:IsA('BasePart') then
            queryable[part] = part.CanQuery
            part.CanQuery = true
        end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {shelter}
    local approaches = {
        fromPrevious = fixture.previous,
        fromNext = V(table.unpack(fixture.activity.steps[3].position)),
    }
    local results = {}
    for name, start in pairs(approaches) do
        local direction = ((start - fixture.at) * V(1, 0, 1)).Unit
        results[name] = {}
        for _, distance in ipairs({8, 16, 24, 32}) do
            local eye = fixture.at + direction * distance + V(0, 5.5, 0)
            local blocked = 0
            for _, x in ipairs({-1, -.5, 0, .5, 1}) do
                local target = plank.CFrame:PointToWorldSpace(V(x, 0, 0))
                if workspace:Raycast(eye, target - eye, params) then blocked += 1 end
            end
            table.insert(results[name], {distance = distance, blocked = blocked, samples = 5})
        end
    end
    for part, original in pairs(queryable) do part.CanQuery = original end
    print('GW_SHELTER_SIGHTLINES ' .. game.HttpService:JSONEncode(results))
end
