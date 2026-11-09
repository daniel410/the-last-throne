-- Server-owned, short displacement with swept body and footprint support checks.
-- Ordinary attacks have no displacement; only authored push skills call start.
local Knockback = {}
local DURATION, IMMUNITY, MAX_DISTANCE, STEP = .12, .20, 3, .35
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < 1e7 end
local function eligible(enemy)
    return enemy.kind ~= "Ogre" and not enemy.model:GetAttribute("StoryBoss")
        and not enemy.model:GetAttribute("KnockbackImmune") and enemy.humanoid.Health > 0
        and enemy.model.Parent ~= nil and enemy.root.Parent ~= nil
end
local function support(enemy, position, params)
    local root, human = enemy.root, enemy.humanoid
    local depth = math.max(root.Size.Y * 1.5, root.Size.Y * .5 + human.HipHeight) + .5
    local floor = workspace:Raycast(position + Vector3.yAxis * .4, -Vector3.yAxis * (depth + .4), params)
    if not floor or floor.Material == Enum.Material.Water
        or floor.Normal.Y < math.cos(math.rad(math.min(45, human.MaxSlopeAngle))) then return nil end
    -- A center ray alone can leave most of the body over an edge.
    for _, x in ipairs({-.4, .4}) do for _, z in ipairs({-.4, .4}) do
        local offset = root.CFrame:VectorToWorldSpace(Vector3.new(root.Size.X * x, 0, root.Size.Z * z))
        local hit = workspace:Raycast(position + offset + Vector3.yAxis * .4, -Vector3.yAxis * (depth + .4), params)
        if not hit or hit.Material == Enum.Material.Water or math.abs(hit.Position.Y - floor.Position.Y) > .4
            or hit.Normal.Y < math.cos(math.rad(math.min(45, human.MaxSlopeAngle))) then return nil end
    end end
    return floor.Position.Y
end
function Knockback.start(enemy, direction, distance, current, exclusions)
    if not eligible(enemy) or not finite(distance) or distance <= 0 or not finite(current)
        or typeof(direction) ~= "Vector3" or not finite(direction.X) or not finite(direction.Z)
        or current < (enemy.knockbackImmuneUntil or 0) then return false end
    direction = Vector3.new(direction.X, 0, direction.Z)
    if direction.Magnitude < .001 then return false end
    local params = RaycastParams.new()
    params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, exclusions
    params.RespectCanCollide, params.IgnoreWater = true, false
    if not support(enemy, enemy.root.Position, params) then return false end
    enemy.knockback = {direction = direction.Unit, distance = math.min(distance, MAX_DISTANCE),
        moved = 0, started = current, params = params}
    enemy.knockbackImmuneUntil = current + IMMUNITY
    enemy.pathToken = (enemy.pathToken or 0) + 1
    enemy.pathPending, enemy.waypoints = false, nil
    enemy.humanoid:MoveTo(enemy.root.Position)
    return true
end
function Knockback.step(enemy, current)
    local motion = enemy.knockback
    if not motion then return false end
    if not eligible(enemy) then enemy.knockback = nil; return false end
    local fraction = math.clamp((current - motion.started) / DURATION, 0, 1)
    local desired = motion.distance * (1 - (1 - fraction) ^ 2)
    local remaining = desired - motion.moved
    while remaining > .0001 do
        local distance = math.min(STEP, remaining)
        local position = enemy.root.Position
        local target = position + motion.direction * distance
        local before, after = support(enemy, position, motion.params), support(enemy, target, motion.params)
        if not before or not after or math.abs(after - before) > .35 then enemy.knockback = nil; break end
        target += Vector3.yAxis * (after - before)
        if enemy.spawnPosition and enemy.config and enemy.config.leashRange
            and (Vector3.new(target.X, 0, target.Z) - Vector3.new(enemy.spawnPosition.X, 0, enemy.spawnPosition.Z)).Magnitude > enemy.config.leashRange then
            enemy.knockback = nil; break
        end
        local delta = target - position
        if workspace:Blockcast(enemy.root.CFrame, enemy.root.Size * .9, delta, motion.params) then
            enemy.knockback = nil; break
        end
        enemy.model:PivotTo(enemy.model:GetPivot() + delta)
        local velocity = enemy.root.AssemblyLinearVelocity
        enemy.root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
        motion.moved += distance
        remaining -= distance
    end
    enemy.humanoid:MoveTo(enemy.root.Position)
    if fraction >= 1 then enemy.knockback = nil end
    return true
end
return Knockback
