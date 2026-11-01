-- Local flinch composes with server-owned interruption; it never moves roots.
local Workspace = game:GetService("Workspace")
local Reaction = {}
local hits = setmetatable({}, {__mode = "k"})
function Reaction.record(model, direction, current)
    if not model or not model:IsA("Model") or not model:IsDescendantOf(Workspace) then return end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local flat = typeof(direction) == "Vector3" and Vector3.new(direction.X, 0, direction.Z) or root.CFrame.LookVector
    if flat.Magnitude < .001 then flat = root.CFrame.LookVector end
    hits[model] = {at = current or Workspace:GetServerTimeNow(), direction = root.CFrame:VectorToObjectSpace(flat.Unit)}
end
function Reaction.sample(model, current)
    local hit = hits[model]
    if not hit then return CFrame.identity end
    local age = current - hit.at
    if age < 0 or age >= .18 then hits[model] = nil; return CFrame.identity end
    local weight = age < .025 and age / .025 or (1 - (age - .025) / .155) ^ 2
    if model:GetAttribute("StoryBoss") then weight *= .5 end
    local d = hit.direction
    return CFrame.new(d.X * .12 * weight, 0, d.Z * .12 * weight)
        * CFrame.Angles(math.rad(-d.Z * 6 * weight), 0, math.rad(d.X * 4 * weight))
end
return Reaction
