-- Run in Studio on the local story world. Sample route-facing camera positions.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local Shared = game.ReplicatedStorage.Shared
local Content = require(Shared.CampaignContent)
local Route = require(Shared.CampaignNavigationRoute)
local world = existingWorld or require(game.ServerScriptService.Server.World.CampaignWorld).create()
local rows = {
    {3, 'FV-03', 'west_beacon', 'AvalancheSnowFence'},
    {3, 'FV-04', 'relay_east', 'EastArchiveConduitBed'},
    {5, 'HG-03', 'passage', 'KeeperDrainCulvert'},
}

local function array(v)
    return {v.X, v.Y, v.Z}
end

local function point(position)
    return V(table.unpack(position))
end

local ray = RaycastParams.new()
ray.RespectCanCollide = true
for _, row in ipairs(rows) do
    local epic, story, targetId, name = table.unpack(row)
    local model = world.folder.EpicWorldArt['EpicWorldArt_' .. epic][story][name]
    local center, size = model:GetBoundingBox()
    local chapter = Content.byId[story]
    local previous = array(world.spawns[chapter.zone].Position)
    for _, goal in ipairs(chapter.goals) do
        local steps = goal.activity and goal.activity.steps
        if goal.id == targetId then
            local path = Route.route(previous, steps and steps[1].position or goal.position)
            if story == 'HG-03' then
                local reversed = {}
                for i = #path, 1, -1 do table.insert(reversed, path[i]) end
                path = reversed
            end
            for i = 2, #path do
                local a, b = point(path[i - 1]), point(path[i])
                local delta = b - a
                local flat = V(delta.X, 0, delta.Z)
                if flat.Magnitude < .1 then continue end
                local forward = flat.Unit
                local count = math.ceil(flat.Magnitude / 8)
                for j = 0, count - 1 do
                    local at = a:Lerp(b, j / count)
                    local floor = workspace:Raycast(at + V(0, 5, 0), V(0, -14, 0), ray)
                    if not floor then continue end
                    local eye = floor.Position + V(0, 5, 0) - forward * 9
                    local aim = floor.Position + V(0, 3, 0) + forward * 22
                    local offset = center.Position - eye
                    local visible = 0
                    for _, fraction in ipairs({-.25, 0, .35}) do
                        local sample = center.Position + V(0, size.Y * fraction, 0) - eye
                        local hit = workspace:Raycast(eye, sample, ray)
                        if not hit or hit.Instance:IsDescendantOf(model) then
                            visible += 1
                        end
                    end
                    local cosine = forward:Dot(V(offset.X, 0, offset.Z).Unit)
                    print('TLT_ROUTE_VIEW ' .. game.HttpService:JSONEncode({
                        story = story, model = name, origin = array(eye), aim = array(aim),
                        distance = offset.Magnitude, angle = math.deg(math.acos(math.clamp(cosine, -1, 1))),
                        clearRays = visible, leg = i - 1, sample = j,
                    }))
                end
            end
            break
        end
        local combat = chapter.combatRoutes and chapter.combatRoutes[goal.id]
        local positions = combat and (combat.worldPoints or combat.points)
        previous = positions and positions[#positions] or steps and steps[#steps].position or goal.position
    end
end
print('TLT_ROUTE_VIEWS_DONE')
