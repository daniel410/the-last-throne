-- Exercise the real damage producer and confirmed hit presenter in Studio.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Combat = game.ServerScriptService.Server.Combat
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Hits = require(Client.K0HitEffects)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)

local stage = Instance.new("Folder", workspace)
local at, heading = Vector3.new(0, 330, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(at + Vector3.new(7, 9, 14), at)
local private = Combat.CombatService:Clone()
private.Name = "HeroMarkFixture"
private.Source = private.Source:gsub("\nreturn CombatService%s*$", function()
    return [[
return { damage = damageEnemy, setSink = function(sink) hitEffectRemote = sink end, setFolder = function(folder) enemyFolder = folder end }
]]
end)
private.Parent = Combat

local styles = {
    oath = "OathSealBreak",
    fracture = "ArmorFaultBreak",
    weakpoint = "WeakpointBracketBreak",
    nature = "NatureBudBreak",
    ember = "EmberVentBreak",
    frost = "FrostSealBreak",
}
local report = { checks = 0, skills = 0, failures = {} }
local function check(value, name)
    report.checks += 1
    if not value then table.insert(report.failures, name) end
end
local function rig(pos)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.CanCollide, root.Position = "HumanoidRootPart", true, false, pos
    local humanoid = Instance.new("Humanoid", model)
    humanoid.RequiresNeck, humanoid.MaxHealth, humanoid.Health = false, 10000, 10000
    return model, root, humanoid
end
local function enemy()
    local model, root, humanoid = rig(at)
    return {model = model, root = root, humanoid = humanoid, config = {leashRange = 35},
        spawnPosition = at, kind = "Goblin", mode = "Idle", posture = 1000, postureImmuneUntil = 0, pathToken = 0}
end
local function generic(d)
    local copy = table.clone(d)
    copy.id = "Fixture_" .. d.id
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end
local function contactTime(d)
    return d.windup + (d.hitDelay or 0)
end

local ok, err = xpcall(function()
    local service = require(private)
    local received
    service.setFolder(stage)
    service.setSink({FireAllClients = function(_, ...) received = table.pack(...) end})
    local actor, root = rig(at - heading * 6)
    local state = { character = actor, root = root, heroId = "owner", attackSeq = 1, feedbackSeq = 0 }
    local now = 105
    local function hit(target, attack, pulse)
        received = nil
        service.damage(state, target, attack, now, heading, pulse)
        return received
    end
    for id, row in Catalog.byId do
        local d, classId = row.definition, row.classId
        if not d.consume then continue end
        report.skills += 1
        state.baseClassId = classId
        local attack = { hits = {}, hitCount = 0, definition = d, isSkill = true, attackPower = 100, direction = heading }
        local marked, other, expired = enemy(), enemy(), enemy()
        marked.branchMarks = {owner = {kind = d.consume, expires = now + 2}}
        other.branchMarks = {peer = {kind = d.consume, expires = now + 2}}
        expired.branchMarks = {owner = {kind = d.consume, expires = now}}
        other.model:SetAttribute("K0BranchMark", d.consume)
        local markedHit = hit(marked, attack, 1)
        local otherHit = hit(other, attack, 1)
        local expiredHit = hit(expired, attack, 1)
        check(markedHit and markedHit.n == 8 and markedHit[8].consumedMark == d.consume and markedHit[8].pulse == 1,
            id .. " emits the consumed mark on the actual target's hit")
        check(markedHit and markedHit[3] == math.floor(100*d.damage*(1+(d.markBonus or 0))+.5)
            and otherHit and otherHit[3] == math.floor(100*d.damage+.5), id .. " preserves normal and enhanced damage")
        check(marked.posture == 1000 - d.posture - (d.markPosture or 0), id .. " preserves posture damage")
        check(marked.branchMarks.owner == nil and other.branchMarks.peer ~= nil
            and otherHit and not otherHit[8].consumedMark and expiredHit and not expiredHit[8].consumedMark,
            id .. " keeps other targets, owners, and expired marks distinct")
        check(not hit(marked, attack, 1), id .. " duplicate target emits no hit")
        attack.hits = {}
        local nextHit = hit(marked, attack, 2)
        check(nextHit and nextHit[8].pulse == 2 and not nextHit[8].consumedMark, id .. " follow-up has no stale cue")
        for _, compact in {false, true} do
            FX.isOtherHero = function() return compact end
            check(Hits.show(marked.model, at, markedHit[3], classId, "Goblin", heading, id, markedHit[8]), id .. " reaches the hit renderer")
            local effect = workspace:FindFirstChild("HeroVFX")
            local holder = workspace:FindFirstChild("K0HitEffect")
            local style, count, spread = styles[d.consume], 0, false
            if effect then
                local maxOffset = 0
                for _, beam in effect:GetDescendants() do
                    if beam:IsA("Beam") and beam.Name == style then
                        count += 1
                        maxOffset = math.max(maxOffset, math.abs(beam.Attachment1.WorldPosition.X))
                    end
                end
                FX.step(workspace:GetServerTimeNow() + .045)
                for _, beam in effect:GetDescendants() do
                    if beam:IsA("Beam") and beam.Name == style then
                        spread = spread or math.abs(beam.Attachment1.WorldPosition.X) > maxOffset + .09
                    end
                end
            end
            local _, beams, chips, glows, particles, faces = FX.count()
            check(effect and effect:GetAttribute("ContactStyle") == style and count == 2 and spread
                and beams == 2 and chips + glows + particles + faces == 0, id .. " splits into two bounded strokes")
            check(holder and holder.K0DamageNumber.Amount.Text == tostring(markedHit[3])
                and not holder:FindFirstChild("K0ImpactFlash"), id .. " keeps damage legible without a duplicate flash")
            FX.step(workspace:GetServerTimeNow() + .24)
            check(not effect or not effect.Parent, id .. " clears the short contact")
            if holder then holder:Destroy() end
            FX.clear()
        end
        local normal = FX.contact(at, classId, id, heading, 1, true, "Fixture_WrongMark")
        check(normal and normal:GetAttribute("ContactStyle") ~= styles[d.consume], id .. " unrelated metadata keeps regular contact")
        FX.clear()
        marked.model:Destroy()
        other.model:Destroy()
        expired.model:Destroy()
    end
    local d = Catalog.byId["elf.marksman.mark_breaker"].definition
    state.baseClassId = "elf"
    local immune = enemy()
    immune.branchMarks = {owner = {kind = "weakpoint", expires = now + 2}}
    Instance.new("ForceField", immune.model)
    check(not hit(immune, {hits={}, hitCount=0, definition=d, isSkill=true, attackPower=100, direction=heading}, 1),
        "prevented health loss emits no cue")
    local lethal = enemy()
    lethal.humanoid.Health = 5
    lethal.branchMarks = {owner = {kind = "weakpoint", expires = now + 2}}
    local lastHit = hit(lethal, {hits={}, hitCount=0, definition=d, isSkill=true, attackPower=100, direction=heading}, 1)
    check(lastHit and lastHit[2] == at and lastHit[3] == 5 and lastHit[8].consumedMark == "weakpoint",
        "lethal damage retains the consumed mark and position snapshot")

    local ordinary = Catalog.byId["elf.marksman.weakpoint_shot"].definition
    local mismatched = enemy()
    mismatched.branchMarks = {owner = {kind = "frost", expires = now + 2}}
    local wrongHit = hit(mismatched, {hits={}, hitCount=0, definition=d, isSkill=true, attackPower=100, direction=heading}, 1)
    check(wrongHit and not wrongHit[8].consumedMark and mismatched.branchMarks.owner.kind == "frost",
        "the owner's unrelated mark survives")
    local appliedMark = hit(enemy(), {hits={}, hitCount=0, definition=ordinary, isSkill=true, attackPower=100, direction=heading}, 1)
    check(appliedMark and not appliedMark[8].consumedMark, "applying a mark does not render it as consumed")

    FX.isOtherHero = function() return true end
    for _ = 1, 12 do FX.contact(at, "elf", d.id, heading, 1, true) end
    local fullCount = FX.count()
    Hits.show(lethal.model, at, lastHit[3], "elf", "Goblin", heading, d.id, lastHit[8])
    local fallback = workspace:FindFirstChild("K0HitEffect")
    check(fullCount > 0 and FX.count() == fullCount and fallback and fallback.K0DamageNumber.Amount.Text == tostring(lastHit[3]),
        "a saturated contact budget retains the confirmed damage number")
    if fallback then fallback:Destroy() end
    FX.clear()

    local sun = Catalog.byId["knight.paladin.sunward_cross"].definition
    local shatter = Catalog.byId["dwarf.iron_axe.shatter_blow"].definition
    for _, rigType in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local first = contactTime(sun) + .06
        local second = first + sun.interval
        local genericSun = generic(sun)
        local left = Melee.sample("knight", sun, first, rigType)
        local right = Melee.sample("knight", sun, second, rigType)
        check(left.angles.leftKnee.X > Melee.sample("knight", genericSun, first, rigType).angles.leftKnee.X + 18
            and right.angles.rightKnee.X > Melee.sample("knight", genericSun, second, rigType).angles.rightKnee.X + 18,
            "Sunward Cross changes planted leg between cuts " .. rigType.Name)
        local contact = contactTime(shatter) + .067
        local planted = Melee.sample("dwarf", shatter, contact, rigType)
        local standard = Melee.sample("dwarf", generic(shatter), contact, rigType)
        check(planted.angles.torso.X > standard.angles.torso.X + 17
            and planted.angles.rightKnee.X > standard.angles.rightKnee.X + 17, "Shatter Blow settles through the knees " .. rigType.Name)
    end
    local bowPose, normalBow = {angles = {}}, {angles = {}}
    Ranged.bow(bowPose, d, d.windup+.052, .052, false, 1)
    Ranged.bow(normalBow, generic(d), d.windup+.052, .052, false, 1)
    check(bowPose.angles.elbow.X > normalBow.angles.elbow.X + 17 and bowPose.angles.leftKnee.X > normalBow.angles.leftKnee.X + 13,
        "Mark Breaker braces and opens the draw elbow after release")
    local magma = Catalog.byId["mage.pyro.magma_spear"].definition
    local profile, sample = Mage.profile(magma), contactTime(magma)+.062
    local cast, normalCast = Mage.sample(magma, profile, sample), Mage.sample(generic(magma), profile, sample)
    check(cast.angles.leftElbow.X > normalCast.angles.leftElbow.X + 17
        and cast.angles.leftKnee.X > normalCast.angles.leftKnee.X + 15, "Magma Spear drives the release through the palm and lead leg")
end, debug.traceback)

FX.clear()
FX.isOtherHero = originalCompact
camera.CFrame = originalCamera
private:Destroy()
stage:Destroy()
report.pass = ok and #report.failures == 0
report.error = not ok and err or nil
print("HERO_MARK_IMPACT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, err or table.concat(report.failures, "\n"))
