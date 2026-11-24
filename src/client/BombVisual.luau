local Bomb = {radius = .48}
local profiles = {
    ["dwarf.gunner.bomb_toss"] = {path = "lob", flight = .36},
    ["dwarf.gunner.shrapnel_toss"] = {path = "scatter", flight = .22},
    ["dwarf.gunner.skipping_charge"] = {path = "bounce", flight = .25},
    ["dwarf.gunner.rolling_charge"] = {path = "roll", flight = .20},
}
function Bomb.get(id)
    return profiles[id]
end

local iron = Color3.fromRGB(54, 59, 65)
local brass = Color3.fromRGB(181, 123, 62)
local cord = Color3.fromRGB(124, 87, 54)

local function piece(model, name, shape, size, frame, color, material)
    local part = Instance.new("Part")
    part.Name, part.Shape, part.Size, part.CFrame = name, shape, size, frame
    part.Color, part.Material = color, material
    part.Anchored, part.Massless = true, true
    part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
    part.Parent = model
    return part
end

function Bomb.mount(model, frame, hand)
    local body = piece(model, "BombBody", Enum.PartType.Ball, Vector3.one * (2 * Bomb.radius),
        frame, iron, Enum.Material.Metal)
    model.PrimaryPart = body
    piece(model, "BombCollar", Enum.PartType.Cylinder, Vector3.new(.20, .37, .37),
        frame * CFrame.new(0, .43, 0) * CFrame.Angles(0, 0, math.pi / 2), brass, Enum.Material.Metal)
    piece(model, "BombFuse", Enum.PartType.Block, Vector3.new(.075, .22, .075),
        frame * CFrame.new(.025, .61, 0) * CFrame.Angles(0, 0, -.26), cord, Enum.Material.Fabric)
    piece(model, "BombFuse", Enum.PartType.Block, Vector3.new(.075, .16, .075),
        frame * CFrame.new(.11, .74, 0) * CFrame.Angles(0, 0, -1), cord, Enum.Material.Fabric)
    local ember = piece(model, "BombFuseEmber", Enum.PartType.Ball, Vector3.one * .13,
        frame * CFrame.new(.18, .78, 0), Color3.fromRGB(255, 187, 73), Enum.Material.Neon)
    if hand then
        for _, part in model:GetChildren() do
            local weld = Instance.new("WeldConstraint")
            weld.Part0, weld.Part1, weld.Parent = hand, part, part
            part.Anchored = false
        end
    end
    return body, ember
end

function Bomb.handFrame(hand)
    return hand.CFrame * CFrame.new(-.22, -hand.Size.Y * .5 - .26, -.15)
        * CFrame.Angles(0, 0, math.rad(38))
end

Bomb.floor = require(script.Parent.SkillEffectGeometry).floor

local function arc(start, finish, height, u)
    return start:Lerp(finish, u) + Vector3.yAxis * (4 * height * u * (1 - u))
end

function Bomb.flightFrame(path, launch, landing, groundPoint, u)
    local start = launch.Position
    local delta = landing - start
    local distance = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local center, turn
    if path == "bounce" then
        if u < .56 then
            center = arc(start, groundPoint, math.clamp(distance * .09, 1, 2.8), u / .56)
        else
            center = arc(groundPoint, landing, math.clamp(distance * .05, .7, 1.7), (u - .56) / .44)
        end
        turn = -math.pi * 3 * u
    elseif path == "roll" then
        if u < .18 then
            center = arc(start, groundPoint, .06, u / .18)
        else
            center = groundPoint:Lerp(landing, (u - .18) / .82)
        end
        turn = -math.min(distance / Bomb.radius, 20) * u
    else
        local height = path == "scatter" and math.clamp(distance * .12, 1.5, 4) or math.clamp(distance * .17, 2, 5.5)
        center, turn = arc(start, landing, height, u), -math.pi * 1.7 * u
    end
    local forward = Vector3.new(delta.X, 0, delta.Z)
    local axis = forward.Magnitude > .01 and forward.Unit:Cross(Vector3.yAxis) or Vector3.xAxis
    return CFrame.new(center) * CFrame.fromAxisAngle(axis, turn) * launch.Rotation
end

return Bomb
