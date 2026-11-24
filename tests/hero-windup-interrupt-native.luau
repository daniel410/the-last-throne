assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local client = game.StarterPlayer.StarterPlayerScripts.Client
local catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
local FX = require(client.HeroVFX)
local Hits = require(client.K0HitEffects)
local Melee = require(client.AdvancedSkillMotion)
local Ranged = require(client.RangedActionPoses)
local Mage = require(client.K0MageMotion)
local combat = game.ServerScriptService.Server.Combat
local camera = workspace.CurrentCamera
local previousCamera = camera.CFrame
local at = Vector3.new(0, 750, 0)
local aim = -Vector3.zAxis
local stage = Instance.new("Folder", workspace)
camera.CFrame = CFrame.lookAt(at + Vector3.new(10, 7, 12), at)

local report = {checks = 0, failures = {}}
local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end

-- Use the shipping module with a fixture-only endpoint and event sink.
local probe = Instance.new("ModuleScript")
probe.Name = "WindupImpactProbe"
local exports = [[return function(folder, sink)
    enemyFolder, hitEffectRemote = folder, sink
    return damageEnemy
end]]
local source, substitutions = combat.CombatService.Source:gsub("return CombatService%s*$", exports)
assert(substitutions == 1)
probe.Source = source
probe.Parent = combat
local events = {}
local damageEnemy = require(probe)(stage, {
    FireAllClients = function(_, model, position, damage, class, kind, direction, id, impact)
        table.insert(events, {model, position, damage, class, kind, direction, id, impact})
    end,
})

local function modelAt(position)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, position
    return model, root
end
local character, characterRoot = modelAt(at - aim * 5)
local function enemy(kind, pending, health, absorbed)
    local model, root = modelAt(at)
    local human = {Health = health or 1000, WalkSpeed = 10, HipHeight = 2, MaxSlopeAngle = 45, MoveTo = function() end}
    function human:TakeDamage(amount)
        if not absorbed then self.Health = math.max(0, self.Health - amount) end
    end
    return {
        model = model, root = root, humanoid = human, attack = pending, kind = kind,
        pathToken = 0, posture = 1000, postureImmuneUntil = 0, mode = "Windup", config = {exposeTime = 1},
    }
end
local function pending(committed)
    return {started = 10, definition = {windup = .4}, sampledActive = committed}
end
local function hit(target, row, sample, isBasic)
    local player = {character = character, root = characterRoot, baseClassId = row.classId,
        feedbackSeq = 0, attackSeq = 1, heroId = "fixture"}
    local attack = {hits = {}, hitCount = 0, attackPower = 50, definition = row.definition,
        isSkill = not isBasic, direction = aim, resolvedSampleAt = sample}
    table.clear(events)
    damageEnemy(player, target, attack, 10.6, aim, 1)
    damageEnemy(player, target, attack, 10.6, aim, 1)
    check(#events <= 1, "Retried sample sends at most one event")
    return events[1]
end

local cases = {
    {"knight.steel_knight.challenging_strike", "ChallengingStrikeContact", "SwordWindupCut"},
    {"dwarf.iron_axe.mountain_sweep", "MountainSweepContact", "AxeWindupBreak"},
    {"elf.marksman.precision_volley", "PrecisionVolleyContact", "ArrowWindupSplit"},
    {"mage.pyro.flame_dart", "FlameDartContact", "SpellWindupDispel"},
}
local function style(model, name)
    return model and model:GetAttribute("ContactStyle") == name
end
for _, case in cases do
    local id, normalStyle, interruptStyle = unpack(case)
    local row = assert(catalog.byId[id])
    local class, d = row.classId, row.definition
    local target = enemy("Goblin", pending(false))
    local event = hit(target, row, 10.2)
    check(event and event[3] > 0 and event[8].windupInterrupted == true, id .. " confirms the ordered windup interrupt")
    check(target.attack == nil and target.hitReactUntil > 10.6, id .. " preserves stagger transition")
    if event then
        check(Hits.show(unpack(event)), id .. " renders the server event")
        local effect = workspace:FindFirstChild("HeroVFX")
        check(style(effect, interruptStyle), id .. " selects its interrupt shape")
        local holder = workspace:FindFirstChild("K0HitEffect")
        check(holder and holder.K0DamageNumber.Amount.Text == tostring(event[3]), id .. " keeps damage digits")
        check(holder and not holder:FindFirstChild("K0ImpactFlash"), id .. " avoids a duplicate burst")
        if holder then holder:Destroy() end
        FX.clear()
    end
    for _, compact in {false, true} do
        local normal, distinct = FX.contact(at, class, id, aim, 1, compact)
        check(distinct and style(normal, normalStyle), id .. " retains its normal hit shape")
        FX.clear()
        for _, heading in {aim, Vector3.xAxis} do
            local effect = FX.contact(at, class, id, heading, 1, compact, nil, nil, false, true)
            check(style(effect, interruptStyle), id .. " keeps the readable interrupt in both densities")
            local _, beams, chips, glows, particles, faces = FX.count()
            check(beams == 2 and chips + glows + particles + faces == 0, id .. " spends two bare beams")
            local right = heading:Cross(Vector3.yAxis)
            local initial = {}
            for _, beam in effect:GetDescendants() do
                if beam:IsA("Beam") then
                    local a = beam.Attachment0.WorldPosition - at
                    local b = beam.Attachment1.WorldPosition - at
                    initial[beam] = math.abs(b:Dot(right))
                    check(a:Dot(heading) < -.1 and b:Dot(heading) < -.7, id .. " shows the interrupted edge on the incoming face")
                    check(beam.Width0 >= .1 and math.abs(beam.CurveSize0) > .01, id .. " keeps its tapered shape")
                end
            end
            FX.step(workspace:GetServerTimeNow() + .05)
            for beam, width in initial do
                local b = beam.Attachment1.WorldPosition - at
                check(math.abs(b:Dot(right)) > width + .30, id .. " opens the interrupted silhouette")
            end
            FX.step(workspace:GetServerTimeNow() + .21)
            check(FX.count() == 0, id .. " expires within 210 ms")
        end
    end
    if class == "knight" or class == "dwarf" then
        local neutral = table.clone(d)
        neutral.id = "fixture:" .. id
        presentation.byId[neutral.id] = presentation.get(d)
        local loadAge = d.windup * .62
        local recoveryAge = d.windup + .07
        for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
            local load = Melee.sample(class, d, loadAge, rig).angles.left
            local neutralLoad = Melee.sample(class, neutral, loadAge, rig).angles.left
            local follow = Melee.sample(class, d, recoveryAge, rig).angles.leftKnee
            local neutralFollow = Melee.sample(class, neutral, recoveryAge, rig).angles.leftKnee
            check((load.Z - neutralLoad.Z) * (class == "knight" and -1 or 1) > 12, id .. " prepares off-hand " .. rig.Name)
            check(follow.X - neutralFollow.X > 20, id .. " checks the swing on the lead knee " .. rig.Name)
        end
        presentation.byId[neutral.id] = nil
    elseif class == "elf" then
        local first, last, redraw = {angles = {}}, {angles = {}}, {angles = {}}
        Ranged.bow(first, d, d.windup + .035, .035, true, 1)
        Ranged.bow(last, d, d.windup + 2 * d.interval + .035, .035, false, 3)
        Ranged.bow(redraw, d, d.windup + .56 * d.interval, .56 * d.interval, true, 1)
        check(last.angles.leftKnee.X - first.angles.leftKnee.X > 15, "Precision Volley plants on the last release")
        check(first.angles.elbow.X - redraw.angles.elbow.X > 30, "Precision Volley redraws between releases")
        check((last.angles.left - first.angles.left).Magnitude < .01, "Bow hand stays on the shot line")
    else
        local load, follow = {angles = {}}, {angles = {}}
        local profile = Mage.profile(d)
        Ranged.mage(load, d, profile, d.windup * .58)
        Ranged.mage(follow, d, profile, d.windup + .062)
        check(follow.angles.leftElbow.X - load.angles.leftElbow.X > 50, "Flame Dart opens the casting elbow")
        check(follow.angles.left.Z - load.angles.left.Z > 10, "Flame Dart turns the casting palm out")
    end
end

local row = catalog.byId["elf.marksman.precision_volley"]
for _, fixture in {
    {enemy("Goblin", nil), 10.2, "Idle target"},
    {enemy("Goblin", pending(true)), 10.2, "Committed strike"},
    {enemy("Goblin", pending()), 10.41, "Late hit"},
    {enemy("Goblin", pending()), 9.99, "Predates windup"},
    {enemy("Ogre", pending()), 10.2, "Resistant enemy"},
    {enemy("Goblin", pending(), 1), 10.2, "Lethal hit"},
} do
    local event = hit(fixture[1], row, fixture[2])
    check(event and event[8].windupInterrupted == nil, fixture[3] .. " has no interruption cue")
end
local absorbed = enemy("Goblin", pending(), nil, true)
check(hit(absorbed, row, 10.2) == nil and absorbed.attack ~= nil, "Absorbed hit does not confirm an interrupt")
local immune = enemy("Goblin", pending())
immune.hitInterruptImmuneUntil = 11
local immuneEvent = hit(immune, row, 10.2)
check(immuneEvent and immuneEvent[8].windupInterrupted == nil and immune.attack ~= nil, "Interrupt immunity stays authoritative")
local support = enemy("Shaman", nil)
support.supportCast = {started = 10, definition = {windup = .4}, sequence = 1}
local supportEvent = hit(support, row, 10.21)
check(supportEvent and supportEvent[8].windupInterrupted == true and support.supportCast == nil, "Interrupted pack support confirms once")
local released = enemy("Shaman", nil)
released.supportCast = {started = 10, definition = {windup = .4}, sequence = 1, released = true}
local releasedEvent = hit(released, row, 10.21)
check(releasedEvent and releasedEvent[8].windupInterrupted == nil and released.supportCast ~= nil, "Released support emits no interrupt")
local basic = hit(enemy("Goblin", pending()), row, 10.2, true)
check(basic and basic[7] == nil and basic[8].windupInterrupted == nil, "Basic attacks keep their existing presentation")

local stylePriority = FX.contact(at, "elf", row.definition.id, aim, 1, true, "weakpoint", nil, false, true)
check(style(stylePriority, "WeakpointBracketBreak"), "Mark consumption takes visual priority")
FX.clear()
local posture = FX.contact(at, "elf", row.definition.id, aim, 1, true, nil, nil, true, true)
check(style(posture, "PostureBreak"), "Posture collapse takes visual priority")
FX.clear()
probe:Destroy()
stage:Destroy()
camera.CFrame = previousCamera
report.pass = #report.failures == 0
print("HERO_WINDUP_INTERRUPT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero windup interruption regression")
