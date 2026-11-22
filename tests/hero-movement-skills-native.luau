-- Verify movement skill silhouettes through the normal Studio presentation entry points.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Hits = require(Client.K0HitEffects)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local report = {checks = 0, failures = {}}

local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end

local function find(model, name, class)
    local matches = {}
    for _, node in model:GetDescendants() do
        if node.Name == name and node:IsA(class) then table.insert(matches, node) end
    end
    return matches
end

local function pulseModel(id, pulse)
    for _, node in workspace:GetChildren() do
        if node.Name == "HeroVFX" and node:GetAttribute("SkillId") == id and node:GetAttribute("Pulse") == pulse then
            return node
        end
    end
end

local stage = Instance.new("Folder", workspace)
local origin, heading = Vector3.new(0, 410, 0), Vector3.xAxis
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(9, 13, 19), origin)
local floor = Instance.new("Part", stage)
floor.Anchored, floor.Size, floor.Position = true, Vector3.new(90, 1, 90), origin - Vector3.yAxis*3.5
local actor = Instance.new("Model", stage)
local root = Instance.new("Part", actor)
root.Name, root.Anchored, root.CanCollide, root.Position = "HumanoidRootPart", true, false, origin
local target = actor:Clone()
target.Parent = stage
target.HumanoidRootPart.Position = origin + heading*8
Instance.new("Humanoid", actor)
local ids = {
    "knight.steel_knight.breaker_charge", "dwarf.iron_axe.iron_shoulder",
    "elf.magic_archer.gliding_shot", "mage.cryo.frost_step",
}
local styles = {"BreakerChargeContact", "IronShoulderContact", "GlidingShotContact", "FrostStepContact"}
local function definition(i)
    return Catalog.byId[ids[i]].definition
end
local function generic(d)
    local copy = table.clone(d)
    copy.id = "MovementFixtureGeneric"
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end

for _, mode in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
    local charge = definition(1)
    local age = charge.windup * .56
    local low = Melee.sample("knight", charge, age, mode)
    local bash = Melee.sample("knight", generic(charge), age, mode)
    check(low.angles.leftKnee.X > bash.angles.leftKnee.X + 18, "Breaker Charge lowers the lead leg " .. mode.Name)
    local first = Melee.sample("knight", charge, charge.windup + .045, mode)
    local second = Melee.sample("knight", charge, charge.windup + charge.interval + .045, mode)
    local genericSecond = Melee.sample("knight", generic(charge), charge.windup + charge.interval + .045, mode)
    check(first.angles.torso.X > second.angles.torso.X + 8 and second.angles.left.X > genericSecond.angles.left.X + 17,
        "Breaker Charge raises the second shield drive " .. mode.Name)
    local shoulder = definition(2)
    local plant = Melee.sample("dwarf", shoulder, shoulder.windup + .05, mode)
    local brace = Melee.sample("dwarf", generic(shoulder), shoulder.windup + .05, mode)
    check(plant.angles.left.X < brace.angles.left.X - 30 and plant.angles.leftKnee.X > brace.angles.leftKnee.X + 24,
        "Iron Shoulder tucks the left arm and loads the lead knee " .. mode.Name)
end

local arrow, ice = definition(3), definition(4)
local start = workspace:GetServerTimeNow() - arrow.windup
actor:SetAttribute("K0ClassId", "elf")
actor:SetAttribute("K0SkillId", arrow.id)
actor:SetAttribute("K0State", "Attack")
actor:SetAttribute("K0AttackSeq", 1)
actor:SetAttribute("K0AttackStartedAt", start)
local aim = Bow.forCharacter(actor, start + arrow.windup*.55)
local grip = Instance.new("Part", actor)
grip.Name, grip.Anchored, grip.CanCollide = "WeaponGrip", true, false
grip.Position = origin + Vector3.new(.5, .4, .45)
local nock = Instance.new("Attachment", grip)
nock.Name = "WeaponTip"
local arrowEnd = Vector3.new(0, 0, -22) + origin
check(aim.angles.weapon.Z > 16 and aim.angles.rightHip.X > 0, "Gliding Shot cants the bow and extends the trailing leg")
Visual.play(actor, arrow.id, origin, arrowEnd, 1, {}, 1, start + arrow.windup, start, -Vector3.zAxis)
local glide = pulseModel(arrow.id, 1)
local wake = glide and find(glide, "GlidingShotWake", "Beam")[1]
check(wake and (wake.Attachment0.WorldPosition - nock.WorldPosition).Magnitude < .002
    and (wake.Attachment1.WorldPosition - arrowEnd).Magnitude < .002, "Gliding Shot wake starts at the weapon socket and ends at the confirmed aim")
check(not workspace:FindFirstChild("ArrowWake") and workspace:FindFirstChild("ArrowShaft"), "Gliding Shot keeps one wake and one arrow")
local recoil = Bow.forCharacter(actor, start + arrow.windup + .05)
check(recoil.angles.leftKnee.X > 18 and recoil.draw < aim.draw, "Gliding Shot braces the lead leg while releasing the string")
FX.clear()

local frost = Mage.sample(ice, Mage.profile(ice), ice.windup + .062)
local ring = Mage.sample(generic(ice), Mage.profile(ice), ice.windup + .062)
check(frost.angles.left.Y > ring.angles.left.Y + 55 and frost.angles.leftKnee.X > ring.angles.leftKnee.X + 18,
    "Frost Step sweeps its palm to the rear and plants the lead foot")

for _, compact in {false, true} do
    FX.isOtherHero = function() return compact end
    for pulse = 1, 2 do
        local at = origin + heading*4
        local charge = FX.skill(actor, ids[1], at, origin - Vector3.zAxis*10, pulse, {}, nil, heading)
        local edges = find(charge, "BreakerChargeEdge", "Beam")
        local height = pulse == 1 and -.32 or .28
        check(#edges == 2 and math.abs(edges[1].Attachment0.WorldPosition.Y - at.Y - height) < .002
            and edges[1].Attachment0.WorldPosition.X > at.X + .9, "Breaker Charge projects distinct shield heights along the accepted heading")
        check(#find(charge, "GuardHalo", "Beam") == 0
            and (find(charge, "BreakerChargeFace", "WedgePart")[1] ~= nil) == not compact,
            "Breaker Charge uses the compact shield silhouette for allies")
        FX.clear()
    end
    local shoulder = FX.skill(actor, ids[2], origin, origin - Vector3.zAxis*10, 1, {}, nil, heading)
    local edges = find(shoulder, "IconShoulderDrive", "Beam")
    check(#edges == 2 and edges[1].Attachment0.WorldPosition.Z < origin.Z - .6
        and (edges[1].Attachment1.WorldPosition - edges[1].Attachment0.WorldPosition):Dot(heading) > 1.5,
        "Iron Shoulder pressure leaves the leading left shoulder in the accepted direction")
    check((find(shoulder, "IronShoulderPlate", "WedgePart")[1] ~= nil) == not compact, "The shoulder plate is reserved for the caster")
    FX.clear()

    local function frostStep(distance)
        root.Position = origin + heading*distance
        local startPosition, center
        Combat.resolve({character = actor, root = root}, {
            definition = ice, direction = heading, advancedCast = {origin = origin, direction = heading},
        }, 2, {enemies = {}, visual = function(_, _, a, b) startPosition, center = a, b end}, 1)
        check(startPosition == root.Position and center == origin, "Server submits the current origin and the departure damage center")
        return FX.skill(actor, ice.id, startPosition, center, 1, {}, nil, heading)
    end
    local step = frostStep(3.2)
    local tracks = find(step, "FrostStepHeelTrace", "Beam")
    check(#tracks == 2 and math.abs(tracks[1].Attachment0.WorldPosition.X - origin.X) < .002
        and tracks[1].Attachment1.WorldPosition.X <= root.Position.X, "Frost tracks span the server's shortened path")
    check(#find(step, "FrostBloom", "Beam") == 8 and #find(step, "FrostRimFacet", "WedgePart") <= 4,
        "Frost Step has a smaller departure burst")
    FX.clear()
    check(#find(frostStep(0), "FrostStepHeelTrace", "Beam") == 0, "Blocked Frost Step shows no travel")
    FX.clear()

    for i, id in ids do
        local row = Catalog.byId[id]
        local effect, distinct = FX.contact(origin, row.classId, id, heading, 1, compact)
        check(distinct and #find(effect, styles[i], "Beam") == 2 and not effect:FindFirstChild("ContactVolume"),
            id .. " has two authored contact edges and no generic volume")
        local _, beams, chips, glows, particles, faces = FX.count()
        check(beams == 2 and chips + glows + particles + faces == 0, id .. " contact stays within the two-beam budget")
        FX.clear()
        check(Hits.show(target, origin, 42, row.classId, "Goblin", heading, id, {pulse = 1}), id .. " reaches the confirmed hit handler")
        local holder = workspace:FindFirstChild("K0HitEffect")
        check(holder and holder.K0DamageNumber.Amount.Text == "42", id .. " preserves the confirmed damage number")
        if holder then holder:Destroy() end
        FX.clear()
    end
end

FX.isOtherHero = originalCompact
root.Position = origin
Visual.play(actor, ids[1], origin, origin - Vector3.zAxis*5, 1, {}, 2, nil, nil, heading)
check(not workspace:FindFirstChild("ShieldContact") and workspace:FindFirstChild("SkillSector"),
    "Breaker Charge keeps the range boundary and removes its redundant shield plate")
FX.clear()
check(select(1, FX.count()) == 0 and select(2, FX.count()) == 0, "Effects return their budget on cleanup")
Presentation.byId.MovementFixtureGeneric = nil
stage:Destroy()
camera.CFrame = originalCamera
report.pass = #report.failures == 0
print("HERO_MOVEMENT_SKILLS_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero movement skill regression")
