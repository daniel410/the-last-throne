-- Evaluate the authored part recipes against the static campaign floor and route.
local Content = dofile('src/shared/CampaignContent.luau')
local Bounds = dofile('src/shared/CampaignBounds.luau')
local world = 'src/server/World/'
local function vector(...) return {...} end
local color = {Lerp = function(self) return self end}
Vector3 = {new = vector}
Color3 = {fromRGB = function() return color end}
Enum = {Material = setmetatable({}, {__index = function(_, name) return name end})}
local profiles = dofile(world .. 'EpicFourthChapterRouteLandmarks.luau')
local existing = dofile(world .. 'EpicFourthChapterLandmarks.luau')

local function planarDistance(ax, az, bx, bz)
    return math.sqrt((ax - bx)^2 + (az - bz)^2)
end

local total = 0
for _, id in ipairs({'DW-04', 'GW-04', 'FV-04', 'EC-04', 'HG-04'}) do
    local profile = assert(profiles[id])
    assert(profile.goal ~= existing[id].goal and profile.step == 2, id)
    local chapter = assert(Content.byId[id])
    local goal, area
    for _, entry in ipairs(chapter.expansionGoals) do
        if entry.id == profile.goal then goal = entry end
    end
    for _, entry in ipairs(Content.zones[chapter.zone].expansionAreas) do
        if entry.id == goal.area then area = entry end
    end
    local target = goal.activity.steps[profile.step].position
    local previous = goal.activity.steps[profile.step - 1].position
    local dx, dz = previous[1] - target[1], previous[3] - target[3]
    local length = planarDistance(dx, dz, 0, 0)
    local x = target[1] - dz / length * profile.side
    local z = target[3] + dx / length * profile.side
    local y = assert(Bounds.surface(x, z))
    assert(math.abs(y - target[2]) <= .5, id)

    local radius, parts = 0, 0
    profile.compose({ground = color, rock = color, trim = color, wood = color},
        function(name, size, at, tint, material)
            assert(tint and material and size[1] > 0 and size[2] > 0 and size[3] > 0, name)
            local halfDiagonal = math.sqrt(size[1]^2 + size[2]^2 + size[3]^2) / 2
            radius = math.max(radius, planarDistance(at[1], at[3], 0, 0) + halfDiagonal)
            parts = parts + 1
        end,
        function(name, a, b, width, tint, material)
            assert(tint and material and width > 0, name)
            radius = math.max(radius, planarDistance(a[1], a[3], 0, 0) + width,
                planarDistance(b[1], b[3], 0, 0) + width)
            parts = parts + 1
        end)
    for ix = -4, 4 do
        for iz = -4, 4 do
            local floor = assert(Bounds.surface(x + radius * ix / 4, z + radius * iz / 4))
            assert(math.abs(floor - y) <= .12, id .. ' fixture floor')
        end
    end

    local points = {assert(area).entry}
    for _, step in ipairs(goal.activity.steps) do table.insert(points, step.position) end
    if goal.activity.finish then table.insert(points, goal.activity.finish.position) end
    local clearance = math.huge
    for index = 2, #points do
        local a, b = points[index - 1], points[index]
        local vx, vz = b[1] - a[1], b[3] - a[3]
        local square = vx^2 + vz^2
        local t = square > 0 and math.max(0, math.min(1, ((x - a[1]) * vx + (z - a[3]) * vz) / square)) or 0
        clearance = math.min(clearance, planarDistance(x, z, a[1] + vx * t, a[3] + vz * t) - radius)
    end
    assert(clearance >= 3 and parts > 0, id .. ' route clearance')
    print(('%s %s: %d parts, floor %.2f, route clearance >= %.2f studs'):format(id, profile.name, parts, y, clearance))
    total = total + parts
end
print(('%d authored parts; 405 static floor samples passed'):format(total))
