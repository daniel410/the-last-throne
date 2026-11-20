-- Local flinch composes with server-owned interruption; it never moves roots.
local Workspace = game:GetService("Workspace")
local Presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
local Reaction = {}
local hits = setmetatable({}, {__mode = "k"})
-- Rise, duration, horizontal yield, vertical yield, pitch and turn (degrees).
local idleHit = {.025, .18, .12, 0, 6, 0}
local profiles = {
    cut = {.028, .19, .12, 0, 5, 9},
    crush = {.045, .24, .16, -.13, 9, 0},
    shove = {.036, .21, .22, .035, 12, 0},
    pierce = {.018, .12, .065, 0, 4, 0},
    burst = {.029, .19, .14, .065, 8, 0},
    frost = {.025, .16, .045, 0, 4, 0},
    lightning = {.015, .105, .055, .018, 5, -6},
    gravity = {.05, .22, -.10, -.07, -6, 0},
}
local function profile(row)
    if not row then return idleHit end
    local d, key = row.definition, row.key
    local motion = d and Presentation.get(d).motion
    if key == "shield" or motion == "shield" then return profiles.shove end
    if key == "earth" or motion == "chop" or motion == "slam" then return profiles.crush end
    if key == "bomb" or key == "fire" or key == "wind" or key == "water" then return profiles.burst end
    if profiles[key] then return profiles[key] end
    if key == "arrow" or key == "gun" or motion == "thrust" or motion == "draw" then return profiles.pierce end
    return (row.classId == "knight" or row.classId == "dwarf") and profiles.cut or idleHit
end

function Reaction.record(model, direction, current, row)
    if not model or not model:IsA("Model") or not model:IsDescendantOf(Workspace) then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local flat = typeof(direction) == "Vector3" and Vector3.new(direction.X, 0, direction.Z) or root.CFrame.LookVector
    if flat.Magnitude < .001 then flat = root.CFrame.LookVector end
    local at = current or Workspace:GetServerTimeNow()
    local entry = Reaction.sample(model, at)
    local boneDirection = root.CFrame:VectorToObjectSpace(flat.Unit)
    hits[model] = {at = at, direction = boneDirection, profile = profile(row), entry = entry}
end
function Reaction.sample(model, current)
    local hit = hits[model]
    if not hit then return CFrame.identity end
    local age = current - hit.at
    local rise, duration, push, dip, pitch, turn = unpack(hit.profile)
    if age < 0 then return CFrame.identity end
    if age >= duration then hits[model] = nil; return CFrame.identity end
    local weight = (1 - math.max(0, age - rise) / (duration - rise)) ^ 2
    local state = model:GetAttribute("K0EnemyState")
    if state == "Windup" or state == "Active" then weight *= .4 end
    if model:GetAttribute("StoryBoss") then weight *= .5 end
    local d = hit.direction
    local pose = CFrame.new(d.X * push * weight, dip * weight, d.Z * push * weight)
        * CFrame.Angles(math.rad(-d.Z * pitch * weight), math.rad(turn * weight), math.rad(d.X * pitch * .67 * weight))
    if age >= rise then return pose end
    local phase = age / rise
    return hit.entry:Lerp(pose, phase * phase * (3 - 2 * phase))
end
return Reaction
