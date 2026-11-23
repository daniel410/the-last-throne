-- Capture the production opening event and feed its exact arguments into the renderer.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Combat = game.ServerScriptService.Server.Combat
local Shared = game.ReplicatedStorage.Shared
local Config = require(Shared.K0Config)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
local at, dir = Vector3.new(0, 330, 0), -Vector3.zAxis
camera.CFrame = CFrame.lookAt(at + Vector3.new(2, 8, 18), at)

local fixture = Combat.CombatService:Clone()
fixture.Name = "ShieldGrantFixture"
fixture.Source = fixture.Source:gsub("\nreturn CombatService%s*$", function()
    return [[
return { players = playerStates, start = startSkill, connect = function(sink, context)
    advancedEffectRemote, contextResolver = sink, context
end }
]]
end)
fixture.Parent = Combat

local report = { checks = 0, shieldSkills = 0, partySkills = 0, failures = {} }
local function check(pass, name)
    report.checks += 1
    if not pass then table.insert(report.failures, name) end
end

local function state(classId, position, key, dead)
    local character = Instance.new("Model", stage)
    character.Name = key
    character:SetAttribute("K0SpawnReady", true)
    local root = Instance.new("Part", character)
    root.Name, root.Anchored, root.CanCollide = "HumanoidRootPart", true, false
    root.Size, root.CFrame = Vector3.new(2, 2, 1), CFrame.lookAt(position, position + dir)
    character.PrimaryPart = root
    local humanoid = Instance.new("Humanoid", character)
    humanoid.RequiresNeck, humanoid.MaxHealth, humanoid.Health = false, 200, dead and 0 or 200
    return {
        player = { Character = character, Parent = game.Players }, character = character,
        root = root, humanoid = humanoid, mode = "Idle", baseClassId = classId,
        heroId = key, heroEpoch = 1, characterGeneration = 1, slotCount = 5,
        skillSlots = {}, skillReadyAt = {}, mana = 1000, maxMana = 1000,
        attackProfile = Config.BasicAttackProfiles[classId], attackSeq = 0, feedbackSeq = 0,
    }
end

local function grants()
    local list = {}
    for _, node in workspace:GetChildren() do
        if node.Name == "HeroShieldGrant" then table.insert(list, node) end
    end
    return list
end

local function stylesNear(position, style)
    for _, model in grants() do
        if (model.VFXCarrier.Position - position).Magnitude < .02 and model:GetAttribute("GuardStyle") == style then
            return model
        end
    end
end

local function partsNamed(name)
    local count = 0
    for _, node in workspace:GetChildren() do if node.Name == name then count += 1 end end
    return count
end

local function checkPose(classId, id, contactStyle)
    local d
    for _, definition in Config.Skills[classId] do if definition.id == id then d = definition end end
    local generic = table.clone(d)
    generic.id = id .. "_fixture"
    Presentation.byId[generic.id] = Presentation.get(d)
    local function differ(a, b, joint, degrees)
        return (a.angles[joint] - b.angles[joint]).Magnitude > degrees
    end
    if classId == "elf" then
        local pose, baseline = { angles = {} }, { angles = {} }
        Ranged.bow(pose, d, d.windup + .05, .05, false, 1)
        Ranged.bow(baseline, generic, d.windup + .05, .05, false, 1)
        check(differ(pose, baseline, "elbow", 15), id .. " folds the draw elbow after release")
    elseif classId == "mage" then
        local age = d.windup + .064
        check(differ(Mage.sample(d, "ward", age), Mage.sample(generic, "ward", age), "left", 18),
            id .. " turns the guiding palm outward into the burst")
    else
        for _, rigType in Enum.HumanoidRigType:GetEnumItems() do
            check(differ(Melee.sample(classId, d, d.windup * .58, rigType),
                Melee.sample(classId, generic, d.windup * .58, rigType), "left", 18), id .. " braces on " .. rigType.Name)
            check(differ(Melee.sample(classId, d, d.windup + .055, rigType),
                Melee.sample(classId, generic, d.windup + .055, rigType), "leftKnee", 13), id .. " plants at contact on " .. rigType.Name)
        end
    end
    Presentation.byId[generic.id] = nil
    local model = FX.contact(at, classId, id, dir, 1, true)
    check(model and model:GetAttribute("ContactStyle") == contactStyle and select(2, FX.count()) == 2,
        id .. " has a distinct two-stroke compact impact")
    FX.clear()
end

local ok, err = xpcall(function()
    local api = require(fixture)
    local packet
    api.connect({ FireAllClients = function(_, ...) packet = table.pack(...) end }, function(player)
        local s = api.players[player]
        return { heroId = s.heroId, baseClassId = s.baseClassId, epoch = 1, characterGeneration = 1 }
    end)
    local wall = Instance.new("Part", stage)
    wall.Size, wall.Position, wall.Anchored = Vector3.new(3, 7, 1), at + Vector3.zAxis * 3, true
    local open = state("mage", at + Vector3.xAxis * 6, "Ally")
    local blocked = state("elf", at + Vector3.zAxis * 6, "BehindWall")
    local far = state("elf", at + Vector3.xAxis * 14, "OutOfRange")
    local dead = state("dwarf", at - Vector3.xAxis * 4, "Dead", true)
    for _, member in { open, blocked, far, dead } do api.players[member.player] = member end

    local floor = Instance.new("Part", stage)
    floor.Size, floor.Position, floor.Anchored = Vector3.new(40, 1, 40), at - Vector3.yAxis * 3, true
    local sample
    for classId, skills in Config.Skills do
        for index, d in skills do
            if not d.shield then continue end
            report.shieldSkills += 1
            if d.partyShield then report.partySkills += 1 end
            local actor = state(classId, at, d.id)
            actor.skillSlots[1] = index
            if d.ultimate then actor.growth = { level = 80, stage = 4, branch = d.branch, mastery = {} } end
            api.players[actor.player] = actor
            for _, member in { open, blocked, far, dead } do
                member.branchShield = nil
                member.character:SetAttribute("K0Shield", nil)
            end
            local now = 105
            actor.branchShield = { amount = 80, expires = now + 1 }
            packet = nil
            api.start(actor, d.ultimate and 0 or 1, now)
            check(packet and packet[1] == actor.character and packet[2] == d.id and packet[5] == 0
                and packet[7] == actor.attackSeq and packet[8] == packet[9], d.id .. " opens on the accepted server cast")
            local recipients = packet and packet[11]
            check(type(recipients) == "table" and table.find(recipients, actor.character) and
                #recipients == (d.partyShield and 2 or 1), d.id .. " sends the exact recipient count")
            check(type(recipients) == "table" and (table.find(recipients, open.character) ~= nil) == (d.partyShield == true),
                d.id .. " sends nearby ally only for a party shield")
            check(actor.branchShield.amount == 80 and actor.branchShield.expires == now + (d.shieldDuration or 4),
                d.id .. " refreshes the established shield rule")
            check((open.character:GetAttribute("K0Shield") or 0) == (d.partyShield and 200 * d.shield or 0)
                and blocked.character:GetAttribute("K0Shield") == nil and far.character:GetAttribute("K0Shield") == nil
                and dead.character:GetAttribute("K0Shield") == nil, d.id .. " preserves eligibility and amount")
            api.start(actor, d.ultimate and 0 or 1, now + .1)
            check(actor.attackSeq == 1, d.id .. " receives only one accepted cast")
            if packet then
                FX.isOtherHero = function(recipient) return recipient ~= actor.character end
                Visual.play(table.unpack(packet, 1, packet.n))
                check(#grants() == (d.partyShield and 2 or 1), d.id .. " marks recipients before contact")
                Visual.play(table.unpack(packet, 1, packet.n))
                check(#grants() == (d.partyShield and 2 or 1), d.id .. " deduplicates the opener")
                if d.id == "knight.steel_knight.guardian_counter" then
                    sample = packet
                    local effect = stylesNear(open.root.Position, "SteelGuardClasp")
                    check(effect ~= nil, "the party shield effect is centered on the ally")
                    if effect then
                        local beam = effect:FindFirstChild("SteelGuardClasp", true)
                        local before = beam.Attachment1.WorldPosition
                        open.root.Position += Vector3.xAxis
                        FX.step(workspace:GetServerTimeNow() + .08)
                        check((beam.Attachment1.WorldPosition - before).Magnitude > .7
                            and math.abs(beam.CurveSize0) > .1, "two curved edges follow the moving ally")
                    end
                    local time = workspace:GetServerTimeNow() + .10
                    Visual.play(actor.character, d.id, actor.root.Position, actor.root.Position + dir * 4,
                        1, {}, actor.attackSeq, time, packet[9], dir)
                    check(partsNamed("GuardGranted") == 0 and #grants() == 2, "contact does not repeat the grant as a caster ring")
                    open.root.Position -= Vector3.xAxis
                end
            end
            FX.step(workspace:GetServerTimeNow() + .7)
            check(#grants() == 0, d.id .. " clears the short-lived guard")
            FX.clear()
            api.players[actor.player] = nil
            actor.character:Destroy()
        end
    end

    local caster = state("knight", at, "LateCaster")
    local time = workspace:GetServerTimeNow()
    local id = "knight.steel_knight.guardian_counter"
    Visual.play(caster.character, id, at, at + dir, 0, nil, 1, time - .33, time - .33, nil, { open.character })
    check(sample and #grants() == 1 and not workspace:FindFirstChild("HeroSkillWindup"), "late accepted grant does not replay the opening animation")
    Visual.play(caster.character, id, at, at + dir, 0, nil, 1, time - .33, time - .33, nil, { open.character })
    check(#grants() == 1, "late grants still deduplicate")
    open.character.Parent = nil
    FX.step(time + .05)
    check(#grants() == 0, "streaming out the recipient clears the grant")
    open.character.Parent = stage
    Visual.play(caster.character, id, at, at + dir, 0, nil, 2, time - .49, time - .49, nil, { open.character })
    check(#grants() == 0, "stale grants are dropped")
    FX.shieldGrant(open.character, id)
    FX.shieldGrant(open.character, "knight.paladin.guardian_slash")
    check(#grants() == 1 and stylesNear(open.root.Position, "OathGuardWings"), "one fresh guard per recipient in overlapping casts")
    FX.clear()

    checkPose("knight", id, "GuardianCounterContact")
    checkPose("dwarf", "dwarf.iron_axe.tremor_guard", "TremorGuardContact")
    checkPose("elf", "elf.magic_archer.warden_arrow", "WardenArrowContact")
    checkPose("mage", "mage.cryo.ice_ward", "IceWardContact")
end, debug.traceback)

FX.isOtherHero = originalCompact
FX.clear()
camera.CFrame = originalCamera
fixture:Destroy()
stage:Destroy()
if not ok then table.insert(report.failures, err) end
report.pass = #report.failures == 0
print("SHIELD_GRANT " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero shield grant checks failed")
