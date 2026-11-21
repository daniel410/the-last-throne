assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Reaction = require(Client.K0EnemyHitReaction)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Hits = require(Client.K0HitEffects)
local Telegraphs = require(Client.K0Telegraphs)
local AdvancedCombat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local at, dir = Vector3.new(0, 320, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local originalCamera, isOtherHero = camera.CFrame, FX.isOtherHero
local report = {checks = 0, skills = 0, failures = {}}
local models = Instance.new("Folder")
models.Parent = workspace
local world, warnings
local function check(value, label)
    report.checks += 1
    assert(value, label)
end
local function actor(name, position)
    local model = Instance.new("Model")
    model.Name = name
    local root = Instance.new("Part")
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, position
    root.Parent, model.Parent = model, models
    return model, root
end

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(at + Vector3.new(0, 13, 19), at)
    local target, root = actor("ImpactTarget", at)
    local function motion(id, time, peak)
        Reaction.record(target, dir, time, assert(Catalog.byId[id]))
        return Reaction.sample(target, time + peak)
    end
    local shield = motion("knight.paladin.shield_verdict", 10, .036)
    local axe = motion("dwarf.iron_axe.armor_splitter", 11, .045)
    local arrow = motion("elf.common.aimed", 12, .018)
    local gravity = motion("mage.common.gravity", 13, .05)
    check(shield.Position.Z < -.2, "Shield drives straight through the target")
    check(axe.Position.Y < -.12, "Axe compresses downward")
    check(arrow.Position.Magnitude < .07, "Arrow makes a short directional flinch")
    check(gravity.Position.Z > .09, "Gravity pulls inward")
    Reaction.record(target, dir, 13.05, Catalog.byId["mage.cryo.frost_lance"])
    check((Reaction.sample(target, 13.05).Position - gravity.Position).Magnitude < .001, "Back-to-back hit starts from current pose")
    check(Reaction.sample(target, 13.3) == CFrame.identity and root.Position == at, "Flinch recovers without moving the root")
    target:SetAttribute("K0EnemyState", "Windup")
    target:SetAttribute("StoryBoss", true)
    local boss = motion("knight.paladin.shield_verdict", 14, .036)
    check(boss.Position.Magnitude < shield.Position.Magnitude * .25, "Boss windup remains readable")
    target:SetAttribute("K0EnemyState", "Idle")
    target:SetAttribute("StoryBoss", nil)
    local heavy = motion("elf.marksman.heavy_draw", 15, .026)
    check(heavy.Position.Z < -arrow.Position.Magnitude * 1.8, "Heavy Draw makes a deeper recoil than aimed shot")

    for _, example in ipairs({
        {"dwarf.gunner.siege_barrage", "ShellContactBurst", .036},
        {"elf.magic_archer.spirit_arrowfall", "ArrowfallContactFletches", .021},
        {"mage.pyro.ashfall", "AshContactCinders", .032},
        {"mage.cryo.hailfall", "HailContactShards", .027},
    }) do
        local id, style, peak = unpack(example)
        local row = Catalog.byId[id]
        Reaction.record(target, dir, 16, row, true)
        local early = Reaction.sample(target, 16+peak)
        Reaction.record(target, dir, 17, row, true, true)
        local final = Reaction.sample(target, 17+peak)
        check(early.Position.Y < -.07 and final.Position.Y < early.Position.Y * 1.2, id .. " compresses further on the final hit")
        check(Reaction.sample(target, 17.3) == CFrame.identity and root.Position == at, id .. " recovers without moving the root")

        local firstWidth
        for _, pulse in ipairs({1, row.definition.pulses}) do
            check(Hits.show(target, at, 42, row.classId, "Goblin", dir, id, {pulse=pulse}), id .. " reaches the live hit handler")
            local holder = assert(workspace:FindFirstChild("K0HitEffect"))
            check(holder.Position == at+Vector3.yAxis*1.1 and holder.K0DamageNumber.Amount.Text == "42", id .. " shows the contact above the target with confirmed damage")
            check(not holder:FindFirstChild("K0SkillImpact") and not holder:FindFirstChild("K0ImpactSpark"), id .. " uses one clear contact effect")
            local impact = assert(workspace:FindFirstChild("HeroVFX"))
            local stroke = assert(impact:FindFirstChild(style, true))
            local height = (stroke.Attachment0.WorldPosition-stroke.Attachment1.WorldPosition).Y
            check(impact:GetAttribute("ContactStyle") == style and (id == "mage.pyro.ashfall" and height < 0 or id ~= "mage.pyro.ashfall" and height > 0), id .. " has the expected vertical contact silhouette")
            height = math.abs(height)
            if firstWidth then check(height > firstWidth * 1.15, id .. " final hit reads larger") end
            firstWidth = height
            holder:Destroy()
            FX.clear()
        end
    end

    local attacker, attackerRoot = actor("DirectionSource", at)
    local first, firstRoot = actor("FirstContact", at+dir*5)
    local second, secondRoot = actor("SecondContact", firstRoot.Position+Vector3.xAxis*6)
    local enemies = {
        [first]={id=1,model=first,root=firstRoot,humanoid=Instance.new("Humanoid",first)},
        [second]={id=2,model=second,root=secondRoot,humanoid=Instance.new("Humanoid",second)},
    }
    local function confirmed(id, pulse, center)
        local hits = {}
        local state = {character=attacker, root=attackerRoot}
        local d = Catalog.byId[id].definition
        local attack = {definition=d, direction=dir, advancedCast={origin=at,center=center,target=first}}
        AdvancedCombat.resolve(state,attack,0,{
            enemies=enemies, clear=function() return true end, visual=function() end,
            damage=function(_,enemy,_,_,heading,index)
                check(index==pulse,"Resolved damage carries its confirmed pulse")
                hits[enemy.id]=heading
            end,
        },pulse)
        return hits
    end
    local chain = confirmed("mage.cryo.chain_lightning", 1, firstRoot.Position)
    check(chain[1]==dir and chain[2]==Vector3.xAxis,"Chain contact follows the previous link")
    local ground = confirmed("dwarf.gunner.bomb_toss",1,(firstRoot.Position+secondRoot.Position)*.5)
    check(ground[1]==-Vector3.xAxis and ground[2]==Vector3.xAxis,"Explosion sends contacts away from its confirmed center")
    local axeOut = confirmed("dwarf.iron_axe.returning_echo",1,at+dir*12)
    local axeBack = confirmed("dwarf.iron_axe.returning_echo",2,at+dir*12)
    check(axeOut[1]==dir and axeBack[1]==-dir,"Returning axe reverses the direction of its second contact")

    local thrust = assert(FX.contact(at,"knight","knight_driving_thrust",dir,1))
    check(thrust:GetAttribute("ContactStyle")=="ArcadePierce" and thrust:FindFirstChild("PiercingContactWake",true), "Driving Thrust uses a narrow piercing contact")
    FX.clear()

    for id, row in pairs(Catalog.byId) do
        report.skills += 1
        for _, compact in ipairs({false, true}) do
            local contact = assert(FX.contact(at, row.classId, id, dir, 1, compact))
            local _, beams, chips, glows, particles, faces = FX.count()
            check(beams + faces > 0, id .. " has a visible confirmed contact")
            if compact then
                check(glows + particles + chips == 0 and faces <= 1 and beams <= 5, id .. " compact impact budget")
            end
            FX.step(workspace:GetServerTimeNow() + .4)
            check(contact.Parent == nil and FX.count() == 0 and select(6, FX.count()) == 0, id .. " releases its budget")
        end
    end
    for id, name in pairs({
        ["mage.pyro.cinder_ring"] = "HeatContactRise",
        ["mage.cryo.frost_lance"] = "FrostContactFacet",
        ["mage.cryo.thunder_spear"] = "LightningContactFork",
        ["dwarf.iron_axe.armor_splitter"] = "AxeCutContact",
        ["elf.marksman.heavy_draw"] = "PiercingContactWake",
        ["knight.paladin.shield_verdict"] = "VerdictContactRay",
    }) do
        local contact = assert(FX.contact(at, Catalog.byId[id].classId, id, dir, 1))
        check(contact:FindFirstChild(name, true) ~= nil, id .. " has its authored impact")
        FX.clear()
    end

    local owner = actor("Character", at)
    Instance.new("Humanoid", owner)
    local player = Instance.new("Folder", models)
    owner.Parent = player
    player:SetAttribute("K0SessionPhase", "Tutorial")
    world = Instance.new("Folder", workspace)
    world.Name = "DeepwoodK0"
    local blockout = Instance.new("Folder", world)
    blockout.Name = "TerrainBlockout"
    local floor = Instance.new("Part", blockout)
    floor.Size, floor.Position, floor.Anchored = Vector3.new(60, 1, 60), at - Vector3.yAxis * 3, true
    local enemies = Instance.new("Folder", world)
    target.Parent = enemies
    target:SetAttribute("K0EnemyState", "Windup")
    target:SetAttribute("K0Telegraph", "Unblockable")
    target:SetAttribute("K0AttackOrigin", at)
    target:SetAttribute("K0AttackDirection", dir)
    target:SetAttribute("K0AttackRange", 9)
    target:SetAttribute("K0AttackAngle", 360)
    warnings = Telegraphs.create(enemies, player)
    FX.isOtherHero = function(character) return character ~= nil and character ~= owner end
    for i, id in ipairs({
        "dwarf.gunner.gunner_shot", "elf.marksman.heavy_draw", "knight.paladin.shield_verdict",
    }) do
        local ally = actor("Ally", at + Vector3.xAxis * i * 3)
        Visual.play(ally, id, at, at + dir * 5, 1, {})
    end
    local records, _, _, glows, particles = FX.count()
    check(records == 3 and glows + particles == 0, "Three allies retain release shapes with no extra glow or particles")
    Visual.play(owner, "mage.pyro.cinder_ring", at, at, 1, {})
    check(FX.count() == 4 and select(5, FX.count()) > 0, "Fourth cast keeps full local impact")
    warnings.update()
    local edges = 0
    for _, edge in workspace.K0LocalTelegraphs:GetDescendants() do
        if edge:IsA("BasePart") and edge.Transparency < 1 and edge.Color == Color3.fromRGB(255, 73, 58) then
            edges += 1
        end
    end
    check(edges == 16, "Four simultaneous casts preserve all enemy warning segments")
    local ally = models:FindFirstChild("Ally")
    check(Hits.show(target, at, 42, "elf", "Goblin", dir, "elf.marksman.heavy_draw", {attacker = ally}), "Ally hit reaches normal handler")
    local holder = assert(workspace:FindFirstChild("K0HitEffect"))
    check(holder.K0DamageNumber.Amount.Text == "42" and holder:FindFirstChild("K0HitFlash") == nil, "Compact ally hit keeps damage text")
    holder:Destroy()
    FX.clear()
    for _ = 1, 20 do FX.contact(at, "elf", nil, dir, 1, true) end
    check(FX.contact(at, "knight", nil, dir, 1) ~= nil, "Ally contact flood leaves a full local slot")
end, debug.traceback)
if warnings then warnings.destroy() end
if world then world:Destroy() end
models:Destroy()
FX.clear()
FX.isOtherHero, camera.CFrame = isOtherHero, originalCamera
if not ok then report.failures[1] = err end
report.pass = ok
print("HERO_SKILL_IMPACT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(ok, err)
