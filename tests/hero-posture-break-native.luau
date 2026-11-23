-- Local Studio fixture. Exercise the shipping server producer and client presenter.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Server = game.ServerScriptService.Server.Combat
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Motion = require(Client.AdvancedSkillMotion)
local Poses = require(Client.RangedActionPoses)
local Hit = require(Client.K0HitEffects)
local Reaction = require(Client.K0EnemyHitReaction)
local FX = require(Client.HeroVFX)

local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
local at, direction = Vector3.new(0, 340, 0), -Vector3.zAxis
camera.CFrame = CFrame.lookAt(at + Vector3.new(5, 7, 11), at)
local original = {}
for _, child in workspace:GetChildren() do original[child] = true end
local serviceModule = Server.CombatService:Clone()
serviceModule.Name = "PostureBreakFixtureService"
serviceModule.Source = serviceModule.Source:gsub("\nreturn CombatService%s*$", [[
return {
    damage = damageEnemy,
    attach = function(folder, sink) enemyFolder, hitEffectRemote = folder, sink end,
}
]])
serviceModule.Parent = Server

local report = {checks = 0, failures = {}}
local function check(result, name)
    report.checks += 1
    if not result then table.insert(report.failures, name) end
end
local function rig(position)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.CanCollide, root.Position = "HumanoidRootPart", true, false, position
    local humanoid = Instance.new("Humanoid", model)
    humanoid.RequiresNeck, humanoid.MaxHealth, humanoid.Health = false, 10000, 10000
    return model, root, humanoid
end
local function enemy(posture)
    local model, root, humanoid = rig(at)
    return {model = model, root = root, humanoid = humanoid, kind = "Goblin", mode = "Idle",
        config = {leashRange = 35, exposeTime = 2}, spawnPosition = at,
        posture = posture, postureImmuneUntil = 0, pathToken = 0}
end
local function current(name)
    for _, child in workspace:GetChildren() do
        if child.Name == name and not original[child] then return child end
    end
end
local function clear()
    for _, child in workspace:GetChildren() do
        if not original[child] and (child.Name == "K0HitEffect" or child.Name == "K0CombatAudioEmitter") then child:Destroy() end
    end
    FX.clear()
end
local ids = {
    "knight.steel_knight.shield_breaker", "dwarf.iron_axe.crag_cleave",
    "elf.marksman.piercing_line", "mage.pyro.stone_lance",
}
local function pose(class, d, age, rigType)
    if class == "knight" or class == "dwarf" then return Motion.sample(class, d, age, rigType) end
    local p = {angles = {}}
    local since = age >= d.windup and age - d.windup or nil
    if class == "elf" then Poses.bow(p, d, age, since, false, 1) else Poses.mage(p, d, "cast", age) end
    return p
end
local ok, err = xpcall(function()
    local service = require(serviceModule)
    local actor, root = rig(at - direction * 5)
    local state = {character = actor, root = root, heroId = "test", attackSeq = 8, feedbackSeq = 0}
    local time, packet = 100, nil
    service.attach(stage, {FireAllClients = function(_, ...) packet = table.pack(...) end})
    local function strike(target, d, class, previousAttack)
        state.baseClassId = class
        local attack = previousAttack or {definition = d, isSkill = true, attackPower = 100, direction = direction, hits = {}, hitCount = 0}
        packet = nil
        service.damage(state, target, attack, time, direction, 1)
        return packet, attack
    end
    for _, id in ids do
        local row = Catalog.byId[id]
        local d, class = row.definition, row.classId
        local ordinary, broken, immune, lethal = enemy(d.posture + 1), enemy(d.posture), enemy(1), enemy(1)
        immune.postureImmuneUntil = time + 1
        lethal.humanoid.Health = 1
        local basic = strike(ordinary, d, class)
        local effect, attack = strike(broken, d, class)
        check(basic and basic[8].postureBroken == nil and ordinary.posture == 1, id .. " ordinary damage does not break posture")
        check(effect and effect[8].postureBroken == true and effect[8].pulse == 1 and broken.posture == 0,
            id .. " final point emits one confirmed break")
        check(effect and basic and effect[3] == basic[3] and effect[2] == at and effect[6] == direction,
            id .. " transition carries original damage, direction, and position")
        check(not strike(broken, d, class, attack), id .. " duplicate from the same pulse is ignored")
        for _, target in {broken, immune, lethal} do
            local follow = strike(target, d, class)
            check(follow and follow[8].postureBroken == nil, id .. " already empty, immune, or lethal hit has no break")
        end
        if not effect then continue end
        for _, compact in {false, true} do
            FX.isOtherHero = function() return compact end
            clear()
            check(Hit.show(table.unpack(basic, 1, basic.n)), id .. " ordinary hit displays")
            local art = current("HeroVFX")
            check(not art or not art:GetAttribute("PostureBroken"), id .. " ordinary rendering lacks break")
            clear()
            check(Hit.show(table.unpack(effect, 1, effect.n)), id .. " break hit displays")
            art = current("HeroVFX")
            local holder = current("K0HitEffect")
            check(art and art:GetAttribute("PostureBroken") and art:GetAttribute("ContactStyle") == "PostureBreak",
                id .. " distinct authored fracture")
            check(holder and holder:FindFirstChild("K0DamageNumber") and not holder:FindFirstChild("K0ImpactFlash"),
                id .. " keeps exactly one damage number and replaces common flash")
            if not art then continue end
            local strokes = {}
            for _, child in art:GetDescendants() do
                if child:IsA("Beam") and child.Name == "PostureBreakEdge" then
                    strokes[child] = math.abs(child.Attachment0.WorldPosition.X)
                    check(child.CurveSize0 > .10 and child.CurveSize1 > .10, id .. " curved fracture silhouette")
                end
            end
            local _, beams, chips, glows, particles = FX.count()
            check(beams == 2 and chips == 0 and glows == 0 and particles == 0, id .. " fits compact effect budget")
            FX.step(workspace:GetServerTimeNow() + .055)
            for stroke, initial in strokes do
                check(math.abs(stroke.Attachment0.WorldPosition.X) > initial + .15, id .. " opens away from the point of impact")
            end
            for _, node in art:GetDescendants() do
                check(not node:IsA("PointLight"), id .. " no lighting overlap")
            end
            FX.step(workspace:GetServerTimeNow() + .40)
            check(art.Parent == nil, id .. " short-lived")
        end
        for _, rigType in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
            local prep, follow = pose(class, d, d.windup * .55, rigType), pose(class, d, d.windup + .06, rigType)
            check(prep and follow and (prep.angles.torso - follow.angles.torso).Magnitude > 3, id .. " load and follow-through differ")
        end
    end
    clear()
    local marked = enemy(1)
    local markId = "mage.pyro.ember_lance"
    local mark = strike(marked, Catalog.byId[markId].definition, "mage")
    check(mark and mark[8].appliedMark == "ember" and mark[8].postureBroken, "mark and break on the same confirmed hit")
    if mark then Hit.show(table.unpack(mark, 1, mark.n)) end
    local markArt = current("HeroVFX")
    check(markArt and markArt:FindFirstChild("EmberSealSet", true) and markArt:FindFirstChild("PostureBreakEdge", true),
        "mark and break retain both silhouettes")

    clear()
    local protected = enemy(1)
    Instance.new("ForceField", protected.model)
    local stone = Catalog.byId["mage.pyro.stone_lance"].definition
    local zero = strike(protected, stone, "mage")
    check(zero and zero[3] == 0 and zero[8].postureBroken == true, "server reports absorbed hit that still breaks posture")
    if zero then Hit.show(table.unpack(zero, 1, zero.n)) end
    check(current("HeroVFX") and not current("K0HitEffect"), "break without health loss shows no damage number")
    check(not Hit.show(protected.model, at, 0, "mage", "Goblin", direction, stone.id), "zero damage alone has no hit feedback")
    local model = enemy(1).model
    Reaction.record(model, direction, time, Catalog.byId[stone.id], nil, nil, true)
    Reaction.record(model, direction, time + .02, Catalog.byId[stone.id])
    check(Reaction.sample(model, time + .052).Position.Y < -.20, "nearby follow-up preserves break dip")
    check(Reaction.sample(model, time + .31) == CFrame.identity, "break reaction returns to neutral")
end, debug.traceback)
if not ok then table.insert(report.failures, err) end
clear()
FX.isOtherHero, camera.CFrame = originalCompact, originalCamera
serviceModule:Destroy()
stage:Destroy()
print("HERO_POSTURE_BREAK_NATIVE", game:GetService("HttpService"):JSONEncode(report))
assert(#report.failures == 0, "posture break fixture failed")
