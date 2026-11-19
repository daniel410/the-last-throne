local function journal(kind, value)
    print('TLT_APPROACH_' .. kind .. ' ' .. game.HttpService:JSONEncode(value))
end

local expansion = reviewWorld.folder.CampaignExpansion.Epic1['DW-Q1_exp_1']
local arch = expansion.IncidentEntranceArch
local feet = {}
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Exclude
ray.FilterDescendantsInstances = {arch}
ray.RespectCanCollide = true
for _, part in ipairs(arch:GetChildren()) do
    if part.Name == 'ArchFoot' then
        local foot = part.Position - V(0, part.Size.Y / 2, 0)
        local hit = workspace:Raycast(foot + V(0, 2, 0), V(0, -5, 0), ray)
        assert(hit and math.abs(hit.Position.Y - foot.Y) < .6 and part.CanCollide, 'arch foot unsupported')
        table.insert(feet, asArray(foot))
    end
end
assert(#feet == 2)
journal('ARCH', {pivot = asArray(arch:GetPivot().Position), feet = feet})

local allModels = table.clone(expected)
table.insert(allModels, {epic = 3, story = 'FV-03', name = 'AvalancheSnowFence'})
table.insert(allModels, {epic = 5, story = 'HG-03', name = 'KeeperDrainCulvert'})
for _, row in ipairs(allModels) do
    local model = findModel(reviewWorld, row)
    local pivot = model:GetPivot().Position
    local approach = model:GetAttribute('ApproachPosition')
    local bounds, size = model:GetBoundingBox()
    journal('PLACEMENT', {name = row.name, ground = asArray(pivot), approach = asArray(approach),
        center = asArray(bounds.Position), bounds = asArray(size), distance = (pivot - approach).Magnitude,
        parts = #model:GetChildren()})
end
