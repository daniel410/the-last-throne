assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Hits = require(Client.K0HitEffects)
local Reaction = require(Client.K0EnemyHitReaction)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local stage = Instance.new("Folder", workspace)
local at, heading = Vector3.new(0, 320, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local original = camera.CFrame
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 12, 18), at)
local report = {checks = 0, failures = {}}

local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end

local function target()
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, at
    return model, root
end

local cases = {
    {"knight.steel_knight.vanguard_strike", "VanguardContactFins", .032, 1.4, -.2},
    {"dwarf.iron_axe.stonebound_leap", "StoneboundContactRupture", .044, .15, .7},
    {"elf.marksman.fan_break", "FanBreakContactSpread", .024, .5, .12},
    {"mage.pyro.stone_lance", "StoneLanceContactSplinters", .034, 1.2, -.45},
}
local weak = Catalog.byId["elf.common.aimed"]
for _, case in cases do
    local id, style, peak, depth, height = unpack(case)
    local row = Catalog.byId[id]
    local model, root = target()
    Reaction.record(model, heading, 10, row)
    local single = Reaction.sample(model, 10 + peak)
    check(single.Position.Magnitude >= .15, id .. " has a heavy reaction")
    if row.classId == "dwarf" then
        check(single.Position.Y < -.14, id .. " drives the target downward")
    else
        check(single.Position:Dot(heading) >= .15, id .. " carries the target along the confirmed direction")
    end
    for _, reverse in ipairs({false, true}) do
        local crowded = target()
        if reverse then Reaction.record(crowded, Vector3.xAxis, 10, weak) end
        Reaction.record(crowded, heading, 10, row)
        if not reverse then Reaction.record(crowded, Vector3.xAxis, 10.008, weak) end
        check((Reaction.sample(crowded, 10 + peak).Position - single.Position).Magnitude < .002,
            id .. " remains legible with a nearly simultaneous light hit")
    end
    local transition = Reaction.sample(model, 10.08)
    Reaction.record(model, Vector3.xAxis, 10.08, weak)
    check((Reaction.sample(model, 10.08).Position - transition.Position).Magnitude < .002, id .. " blends the next hit from the current pose")
    check(Reaction.sample(model, 10.10).Position.X > .05, id .. " lets the next attack take over after the brief rise")
    check(Reaction.sample(model, 10.4) == CFrame.identity and root.Position == at, id .. " releases the render pose")
    model:SetAttribute("K0EnemyState", "Active")
    model:SetAttribute("StoryBoss", true)
    Reaction.record(model, heading, 11, row)
    check(Reaction.sample(model, 11 + peak).Position.Magnitude <= single.Position.Magnitude * .21, id .. " preserves boss attack poses")

    for _, compact in ipairs({false, true}) do
        local effect = FX.contact(at, row.classId, id, heading, 1, compact)
        check(effect and effect:GetAttribute("ContactStyle") == style, id .. " retains a distinct contact for both views")
        local count, left, right, axis = 0, false, false, true
        for _, beam in effect:GetDescendants() do
            if beam:IsA("Beam") and beam.Name == style then
                count += 1
                local delta = beam.Attachment1.WorldPosition - beam.Attachment0.WorldPosition
                left, right = left or delta.X < -.1, right or delta.X > .1
                axis = axis and delta:Dot(heading) > depth and (height < 0 and delta.Y < height or height > 0 and delta.Y > height)
            end
        end
        check(count == 2 and left and right, id .. " separates its two edges")
        check(count == 2 and axis, id .. " preserves its authored impact axis")
        local _, beams, chips, glows, particles, faces = FX.count()
        check(beams == 2 and chips + glows + particles == 0 and faces <= 1, id .. " fits the two-beam impact budget")
        FX.clear()
    end
    check(Hits.show(model, at, 42, row.classId, "Goblin", heading, id, {pulse = 1}), id .. " uses the confirmed hit handler")
    local holder = assert(workspace:FindFirstChild("K0HitEffect"))
    check(holder.K0DamageNumber.Amount.Text == "42" and not holder:FindFirstChild("K0ImpactFlash")
        and not holder:FindFirstChild("K0SkillImpact"), id .. " keeps damage text and avoids the generic burst")
    holder:Destroy()
    FX.clear()
end

local vanguard = Catalog.byId[cases[1][1]].definition
local leap = Catalog.byId[cases[2][1]].definition
for _, rig in ipairs({Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15}) do
    local ready = Melee.sample("knight", vanguard, vanguard.windup * .55, rig)
    local drive = Melee.sample("knight", vanguard, vanguard.windup + .055, rig)
    check(ready.angles.left.Z < drive.angles.left.Z - 10, "Vanguard Strike retracts the guard before the drive " .. rig.Name)
    local airborne = Melee.sample("dwarf", leap, leap.windup * .61, rig)
    local landed = Melee.sample("dwarf", leap, leap.windup + .055, rig)
    check(airborne.root.Position.Y > 1 and landed.root.Position.Y < -.2, "Stonebound Leap lands on the approved contact " .. rig.Name)
    check(airborne.angles.rightKnee.X > 20 and airborne.angles.leftKnee.X > 20, "Stonebound Leap visibly tucks both knees " .. rig.Name)
end
local fan = Catalog.byId[cases[3][1]].definition
local otherFan = Catalog.byId["elf.marksman.piercing_volley"].definition
local spread, piercing = {angles = {}}, {angles = {}}
Ranged.bow(spread, fan, fan.windup + .05, .05, false, 1)
Ranged.bow(piercing, otherFan, otherFan.windup + .05, .05, false, 1)
check(spread.angles.leftKnee.X > piercing.angles.leftKnee.X + 12, "Fan Break braces the lead leg on release")
check(spread.angles.right.Y > piercing.angles.right.Y + 12, "Fan Break has a broader draw-hand follow-through")
local lance = Catalog.byId[cases[4][1]].definition
local earth = Catalog.byId["mage.pyro.earth_rise"].definition
local staff, raise = {angles = {}}, {angles = {}}
Ranged.mage(staff, lance, Mage.profile(lance), lance.windup + .06)
Ranged.mage(raise, earth, Mage.profile(earth), earth.windup + .06)
check(staff.angles.leftElbow.X > raise.angles.leftElbow.X + 12, "Stone Lance extends the guiding elbow on release")

stage:Destroy()
camera.CFrame = original
report.pass = #report.failures == 0
print("HERO_FORCE_FEEDBACK_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero force feedback regression")
