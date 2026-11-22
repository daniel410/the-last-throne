assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local Reaction = require(Client.K0EnemyHitReaction)
local FX = require(Client.HeroVFX)
local Hits = require(Client.K0HitEffects)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local report = {checks = 0, failures = {}}

local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end

local stage = Instance.new("Folder", workspace)
local at, heading = Vector3.new(0, 320, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local originalCamera = camera.CFrame
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 12, 18), at)
local function target()
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, at
    return model, root
end

local cases = {
    {id = "knight.paladin.oathbreaker_strike", style = "OathbreakerContactCleft", peak = .038, vertical = -1.3, push = .12, lift = -.14},
    {id = "dwarf.gunner.piercing_round", style = "RifleContactWake", peak = .016, depth = 1.05, push = .17, lift = 0},
    {id = "elf.magic_archer.elemental_pierce", style = "ElementalContactRibbons", peak = .025, depth = 1.45, crosses = true, push = .115, lift = .045},
    {id = "mage.cryo.glacial_spike", style = "GlacialContactShards", peak = .034, vertical = 1.5, push = .10, lift = .12},
}

for _, case in cases do
    local row = Catalog.byId[case.id]
    local model, root = target()
    Reaction.record(model, heading, 10, row)
    local pose = Reaction.sample(model, 10 + case.peak)
    check((pose.Position - (heading * case.push + Vector3.yAxis * case.lift)).Magnitude < .002, case.id .. " has its authored yield")
    check(Reaction.sample(model, 10.35) == CFrame.identity and root.Position == at, case.id .. " recovers without moving the root")

    local crowded = target()
    Reaction.record(crowded, heading, 11, row)
    local impulse = Reaction.sample(crowded, 11 + case.peak)
    Reaction.record(crowded, Vector3.xAxis, 11 + case.peak * .2, row)
    Reaction.record(crowded, -heading, 11 + case.peak * .7, row)
    check((Reaction.sample(crowded, 11 + case.peak).Position - impulse.Position).Magnitude < .002, case.id .. " reaches its first peak under equal hits")

    for _, compact in {false, true} do
        local effect, distinct = FX.contact(at, row.classId, case.id, heading, 1, compact)
        check(distinct and effect:GetAttribute("ContactStyle") == case.style, case.id .. " has a distinct contact in both views")
        local axis, count = true, 0
        for _, node in effect:GetDescendants() do
            if node:IsA("Beam") and node.Name == case.style then
                local from, to = node.Attachment0.WorldPosition, node.Attachment1.WorldPosition
                local delta = to - from
                local vertical = case.vertical
                axis = axis and delta:Dot(heading) > (case.depth or .15)
                    and (not vertical or vertical < 0 and delta.Y < vertical or vertical > 0 and delta.Y > vertical)
                    and (not case.crosses or from.X * to.X < 0)
                count += 1
            end
        end
        check(axis and count == 2, case.id .. " has two edges in the authored directions")
        local _, beams, chips, glows, particles, faces = FX.count()
        check(beams == 2 and chips + glows + particles + faces == 0, case.id .. " uses only two beams")
        FX.clear()
    end

    check(Hits.show(model, at, 42, row.classId, "Goblin", heading, case.id, {pulse = 1}), case.id .. " reaches the confirmed hit handler")
    local holder = workspace:FindFirstChild("K0HitEffect")
    check(holder.K0DamageNumber.Amount.Text == "42" and not holder:FindFirstChild("K0ImpactFlash")
        and not holder:FindFirstChild("K0SkillImpact"), case.id .. " keeps the damage amount beside the single authored effect")
    holder:Destroy()
    FX.clear()
end

local weak, heavy = Catalog.byId["elf.common.aimed"], Catalog.byId[cases[1].id]
local model = target()
Reaction.record(model, Vector3.xAxis, 20, weak)
Reaction.record(model, heading, 20.01, heavy)
check(Reaction.sample(model, 20.048).Position.Y < -.13, "Heavy contact can interrupt a light rise")
local entry = Reaction.sample(model, 20.09)
Reaction.record(model, Vector3.xAxis, 20.09, weak)
check((Reaction.sample(model, 20.09).Position - entry.Position).Magnitude < .002, "Later follow-up starts at the current pose")
check(Reaction.sample(model, 20.108).Position.X > .06, "Later follow-up reaches its own peak")

local knight, dwarf, elf, mage = table.unpack(cases)
local function definition(case) return Catalog.byId[case.id].definition end
local function withoutAuthoredPose(d)
    local copy = table.clone(d)
    copy.id = "FixtureUnauthoredPose"
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end
for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
    local sword = definition(knight)
    local age = sword.windup + .055
    local cleave = Melee.sample("knight", sword, age, rig)
    local normal = Melee.sample("knight", withoutAuthoredPose(sword), age, rig)
    check(cleave.angles.leftKnee.X > normal.angles.leftKnee.X + 16, "Oathbreaker Strike plants the lead leg " .. rig.Name)
    local rifle = definition(dwarf)
    local aim = rifle.windup * .55
    local braced = Melee.sample("dwarf", rifle, aim, rig)
    local standing = Melee.sample("dwarf", withoutAuthoredPose(rifle), aim, rig)
    check(braced.angles.leftKnee.X > standing.angles.leftKnee.X + 8, "Piercing Round braces before release " .. rig.Name)
end
local arrow, ice = definition(elf), definition(mage)
local weave, straight = {angles = {}}, {angles = {}}
Ranged.bow(weave, arrow, arrow.windup * .55)
Ranged.bow(straight, withoutAuthoredPose(arrow), arrow.windup * .55)
check(weave.angles.weapon.Z > straight.angles.weapon.Z + 18, "Elemental Pierce holds a distinct bow cant")
local spike, frost = {angles = {}}, {angles = {}}
Ranged.mage(spike, ice, Mage.profile(ice), ice.windup + .062)
Ranged.mage(frost, withoutAuthoredPose(ice), Mage.profile(ice), ice.windup + .062)
check(spike.angles.left.X > frost.angles.left.X + 32, "Glacial Spike carries the guiding palm upward")
Presentation.byId.FixtureUnauthoredPose = nil

stage:Destroy()
camera.CFrame = originalCamera
report.pass = #report.failures == 0
print("HERO_CONTACT_WEIGHT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero contact weight regression")
