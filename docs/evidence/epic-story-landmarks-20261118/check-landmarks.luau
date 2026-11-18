assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated Studio place required')
local World = game.ServerScriptService.Server.World
local CampaignWorld = require(World.CampaignWorld)
local Collision = require(World.CampaignSceneryCollision)
local C = require(game.ReplicatedStorage.Shared.CampaignContent)
local expected = {
    ['DW-02'] = 'ConvoyRecoveryShelter',
    ['GW-01'] = 'SplitTrailRootButtress',
    ['FV-03'] = 'AvalancheSnowFence',
    ['EC-03'] = 'OreSortingBay',
    ['HG-03'] = 'KeeperDrainCulvert',
}
local arrivals = {}
local order = {'DW-02', 'GW-01', 'FV-03', 'EC-03', 'HG-03'}
for epic, story in ipairs(order) do
    local standalone = CampaignWorld.create(epic)
    local name = expected[story]
    local site = standalone.folder.EpicWorldArt['EpicWorldArt_' .. epic][story]
    local model = assert(site:FindFirstChild(name), 'missing landmark on direct entry: ' .. story)
    local point = assert(model:GetAttribute('GroundPosition'))
    arrivals[story] = {point.X,point.Y,point.Z}
    standalone.folder:Destroy()
    workspace.Terrain:Clear()
end
print('EPIC_STORY_LANDMARK_DIRECT_ENTRY ' .. game.HttpService:JSONEncode(arrivals))
local world = CampaignWorld.create()
local report = {}
local partsBefore = #world.folder:GetDescendants()
for epic = 1, #C.epics do
    CampaignWorld.create(epic, world)
    local epicArt = world.folder.EpicWorldArt['EpicWorldArt_' .. epic]
    for _, site in ipairs(epicArt:GetChildren()) do
        for _, model in ipairs(site:GetChildren()) do
            if model:GetAttribute('SourceKind') ~= 'NewNativeGeometry' then continue end
            assert(expected[site.Name] == model.Name and not report[site.Name], 'unexpected landmark ' .. model:GetFullName())
            assert(model:IsA('Model') and model.ModelStreamingMode == Enum.ModelStreamingMode.Atomic)
            assert(model:GetAttribute('StoryZone') == site.Name)
            local ground = assert(model:GetAttribute('GroundPosition'))
            local approach = assert(model:GetAttribute('ApproachPosition'))
            local bounds, size = model:GetBoundingBox()
            local bottom = bounds.Y - size.Y / 2
            assert(math.abs(bottom - ground.Y) <= 1.25, 'model base drifts from its ground pivot')
            local ray = RaycastParams.new()
            ray.FilterType = Enum.RaycastFilterType.Exclude
            ray.FilterDescendantsInstances = {model}
            ray.RespectCanCollide = true
            local foot = workspace:Raycast(ground+Vector3.new(0,1,0), Vector3.new(0,-3,0),ray)
            assert(foot and math.abs(foot.Position.Y-ground.Y) < .75, 'final scene lacks support '..site.Name)
            local parts, solids = 0, 0
            for _, item in ipairs(model:GetDescendants()) do
                assert(item:IsA('BasePart'), 'unexpected instance ' .. item:GetFullName())
                local solid = Collision.isSolid(item, epicArt)
                assert(item.Anchored and not item.CanTouch)
                assert(item.CanCollide == solid and item.CanQuery == solid, 'scenery collision mismatch')
                if solid then solids += 1 end
                assert(item:GetAttribute('TLTSceneryDistance'), 'missing existing client cull distance')
                parts += 1
            end
            assert(solids > 0 and solids < parts)
            report[site.Name] = {name = model.Name, parts = parts, solids = solids, size = {size.X,size.Y,size.Z},
                ground = {ground.X,ground.Y,ground.Z}, approach = {approach.X,approach.Y,approach.Z}}
        end
    end
end
assert(partsBefore == #world.folder:GetDescendants(), 'cached create duplicated geometry')
for id in pairs(expected) do assert(report[id], 'missing landmark in ' .. id) end
print('EPIC_STORY_LANDMARKS ' .. game.HttpService:JSONEncode(report))
_G.TLTStoryLandmarkReviewWorld = world
