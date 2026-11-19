-- Check generated models and their underlying solid floor in the capture world.
local floor = RaycastParams.new()
floor.FilterType = Enum.RaycastFilterType.Include
floor.FilterDescendantsInstances = {existingWorld.terrain, workspace.Terrain}
floor.RespectCanCollide = true

local count = 0
local found = {}
for _, model in ipairs(existingWorld.folder.CampaignExpansion:GetDescendants()) do
    if model:GetAttribute('QuestLandmarkVersion') == 1 then
        local id = model:GetAttribute('StoryZone')
        assert(not found[id], 'Duplicate quest landmark: ' .. id)
        found[id] = model
        count += 1
    end
end
assert(count == #targets, 'Expected one quest landmark per epic')

for epic, target in ipairs(targets) do
    local id, index = table.unpack(target)
    local chapter = content.byId[id]
    local goal = chapter.expansionGoals[index]
    local at = V(table.unpack(goal.activity.finish.position))
    local model = assert(found[id])
    local ground = model:GetAttribute('GroundPosition')
    local base = existingWorld.folder.CampaignExpansion['Epic' .. epic]
    local parent = goal.activity.finish.rearguard and base or base[id .. '_' .. goal.id]
    assert(model.Parent == parent and model.ModelStreamingMode == Enum.ModelStreamingMode.Atomic, id)
    assert(model:GetAttribute('ApproachPosition') == at and model:GetAttribute('StoryGoal') == goal.id, id)
    local anchor = existingWorld.activityNodes[id .. ':' .. goal.id .. ':resolve']
    assert(anchor.part.Position == at + V(0, 1, 0), id)
    assert((anchor.prompt ~= nil) == (goal.activity.finish.prompt ~= nil), id)

    local frame, size = model:GetBoundingBox()
    local low = frame.Y - size.Y / 2
    assert((model:GetPivot().Position - ground).Magnitude < .01 and math.abs(low - ground.Y) < .8, id)
    local floorError = 0
    for _, corner in ipairs({V(0,0,0), V(-1,0,-1), V(1,0,-1), V(-1,0,1), V(1,0,1)}) do
        local xy = frame:PointToWorldSpace(V(corner.X * size.X / 2, 0, corner.Z * size.Z / 2))
        local hit = assert(workspace:Raycast(V(xy.X, ground.Y + 5, xy.Z), V(0,-12,0), floor), id)
        floorError = math.max(floorError, math.abs(hit.Position.Y - ground.Y))
    end
    assert(floorError < .2, id .. ' floor mismatch')
    local parts = model:GetDescendants()
    assert(#parts == model:GetAttribute('PartCount'), id)
    for _, part in ipairs(parts) do
        assert(part:IsA('BasePart') and part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery, part:GetFullName())
    end
    local worldAgain = require(World.CampaignWorld).create(epic, existingWorld)
    assert(worldAgain == existingWorld and parent:FindFirstChild(model.Name) == model, id .. ' cache')
    print('QUEST_LANDMARK ' .. game.HttpService:JSONEncode({
        id = id,
        model = model.Name,
        ground = {ground.X, ground.Y, ground.Z},
        approach = {at.X, at.Y, at.Z},
        floorError = floorError,
        parts = #parts,
    }))
end
