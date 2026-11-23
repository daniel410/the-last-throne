-- Reflect each detail view across the placed landmark's local XY plane.
local rearViews = {}
for _, shot in ipairs(cameras) do
    local story = string.match(shot.id, '^(%u%u%-%d%d)_detail$')
    local name = story and finaleModels[story]
    if name then
        local model = assert(world.folder:FindFirstChild(name, true), name)
        local pivot = model:GetPivot()
        local localOrigin = pivot:PointToObjectSpace(V(table.unpack(shot.origin)))
        assert(localOrigin.Z < 0, shot.id .. ' must face the front of the landmark')
        local rearOrigin = pivot:PointToWorldSpace(V(localOrigin.X, localOrigin.Y, -localOrigin.Z))
        table.insert(rearViews, {
            id = story .. '_rear_diagnostic',
            origin = {rearOrigin.X, rearOrigin.Y, rearOrigin.Z},
            aim = shot.aim,
            theme = shot.theme,
        })
    end
end
assert(#rearViews == 5, 'expected one rear view per finale')
for _, shot in ipairs(rearViews) do
    table.insert(cameras, shot)
end
