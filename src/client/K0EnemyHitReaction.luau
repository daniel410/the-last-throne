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
    heavyPierce = {.026, .17, .13, 0, 7, 0},
    burst = {.029, .19, .14, .065, 8, 0},
    frost = {.025, .16, .045, 0, 4, 0},
    lightning = {.015, .105, .055, .018, 5, -6},
    gravity = {.05, .22, -.10, -.07, -6, 0},
    arrowfall = {.021, .14, .035, -.08, 4, 0},
    hailfall = {.027, .17, .035, -.12, 6, 0},
    ashfall = {.032, .18, .05, -.085, 5, 0},
    shell = {.036, .22, .12, -.15, 8, 0},
}
local skillProfiles = {
    ["knight.steel_knight.vanguard_strike"] = {.032, .19, .20, 0, 9, 2},
    ["dwarf.iron_axe.stonebound_leap"] = {.044, .23, .095, -.16, 8, 0},
    ["elf.marksman.fan_break"] = {.024, .16, .19, .025, 7, 0},
    ["mage.pyro.stone_lance"] = {.034, .19, .16, -.035, 8, 0},
    ["elf.marksman.heavy_draw"] = profiles.heavyPierce,
}
local function profile(row, descending)
    if not row then return idleHit end
    local d, key = row.definition, row.key
    if descending then
        return key == "bomb" and profiles.shell or key == "frost" and profiles.hailfall
            or key == "fire" and profiles.ashfall or profiles.arrowfall
    end
    local authored = d and skillProfiles[d.id]
    if authored then return authored end
    local motion = d and Presentation.get(d).motion
    if key == "shield" or motion == "shield" then return profiles.shove end
    if key == "earth" or motion == "chop" or motion == "slam" then return profiles.crush end
    if key == "bomb" or key == "fire" or key == "wind" or key == "water" then return profiles.burst end
    if profiles[key] then return profiles[key] end
    if key == "arrow" or key == "gun" or motion == "thrust" or motion == "draw" then return profiles.pierce end
    return (row.classId == "knight" or row.classId == "dwarf") and profiles.cut or idleHit
end

function Reaction.record(model, direction, current, row, descending, final)
    if not model or not model:IsA("Model") or not model:IsDescendantOf(Workspace) then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local flat = typeof(direction) == "Vector3" and Vector3.new(direction.X, 0, direction.Z) or root.CFrame.LookVector
    if flat.Magnitude < .001 then flat = root.CFrame.LookVector end
    local at = current or Workspace:GetServerTimeNow()
    local response = profile(row, descending)
    local strength = final and 1.25 or 1
    local impulse = (math.abs(response[3]) + math.abs(response[4])) * strength
    local previous = hits[model]
    -- Rapid party hits can share a render frame. Let the larger displacement
    -- reach its first readable pose, then allow the next hit to take over.
    if previous and at - previous.at < previous.profile[1] + .02 and previous.impulse >= impulse * 1.2 then return end
    local entry = Reaction.sample(model, at)
    local boneDirection = root.CFrame:VectorToObjectSpace(flat.Unit)
    hits[model] = {at = at, direction = boneDirection, profile = response, entry = entry, strength = strength, impulse = impulse}
end
function Reaction.sample(model, current)
    local hit = hits[model]
    if not hit then return CFrame.identity end
    local age = current - hit.at
    local rise, duration, push, dip, pitch, turn = unpack(hit.profile)
    if age < 0 then return CFrame.identity end
    if age >= duration then hits[model] = nil; return CFrame.identity end
    local weight = hit.strength * (1 - math.max(0, age - rise) / (duration - rise)) ^ 2
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
