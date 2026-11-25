-- Non-queryable decorative landmarks must also be checked against each other.
local landmarks = {}
for _, model in ipairs(existingWorld.folder.CampaignExpansion:GetDescendants()) do
    if model:GetAttribute('QuestLandmarkVersion') then
        table.insert(landmarks, model)
    end
end

local function overlaps(a, aSize, b, bSize)
    local delta = b.Position - a.Position
    if math.abs(delta.Y) >= (aSize.Y + bSize.Y) / 2 then return false end
    local function extent(frame, size, axis)
        return (math.abs(frame.RightVector:Dot(axis)) * size.X
            + math.abs(frame.LookVector:Dot(axis)) * size.Z) / 2
    end
    for _, axis in ipairs({a.RightVector, a.LookVector, b.RightVector, b.LookVector}) do
        if math.abs(delta:Dot(axis)) >= extent(a, aSize, axis) + extent(b, bSize, axis) then
            return false
        end
    end
    return true
end

for _, model in ipairs(landmarks) do
    if not targets[model.Name] then continue end
    local box, size = model:GetBoundingBox()
    for _, other in ipairs(landmarks) do
        if other == model then continue end
        local otherBox, otherSize = other:GetBoundingBox()
        assert(not overlaps(box, size, otherBox, otherSize), model.Name .. ' intersects ' .. other.Name)
    end
    print('FOURTH_CHAPTER_LANDMARK_OVERLAP_CLEAR ' .. model.Name)
end
