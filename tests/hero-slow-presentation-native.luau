-- Local Studio fixture for server-owned slow timing and observer-local effects.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Server = game.ServerScriptService.Server.Combat
local Config = require(game.ReplicatedStorage.Shared.K0Config)
local Motion = require(Client.AdvancedSkillMotion)
local Poses = require(Client.RangedActionPoses)
local Effects = require(Client.K0EnemyControlEffects)
local report = {checks = 0, failures = {}}
local function check(result, name)
    report.checks += 1
    if not result then table.insert(report.failures, name) end
end

local stage = Instance.new("Folder", workspace)
local module = Server.CombatService:Clone()
module.Name = "SlowPresentationFixture"
module.Source = module.Source:gsub("\nreturn CombatService%s*$", [[
return {damage = damageEnemy, step = stepEnemy, reset = resetEnemy,
    mount = function(folder, sink) enemyFolder, hitEffectRemote = folder, sink end}
]])
module.Parent = Server
local at = Vector3.new(0, 350, 0)
local aim = -Vector3.zAxis
local function rig(position)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.CanCollide, root.Position = "HumanoidRootPart", true, false, position
    local humanoid = Instance.new("Humanoid", model)
    humanoid.RequiresNeck, humanoid.MaxHealth, humanoid.Health = false, 10000, 10000
    return model, root, humanoid
end
local function target(kind)
    local model, root, humanoid = rig(at)
    return {model = model, root = root, humanoid = humanoid, kind = kind or "Goblin", mode = "Idle",
        config = {leashRange = 35, exposeTime = 2, walkSpeed = 12, posture = 200},
        spawnPosition = at, spawnPivot = root.CFrame, posture = 200, postureImmuneUntil = 0, pathToken = 0}
end
local function skill(class, id)
    for _, d in Config.Skills[class] do
        if d.id == id then return d end
    end
    error(id)
end
local cases = {
    {"knight", "knight.steel_knight.sweeping_break", "steel", "leftKnee", 20, 45},
    {"dwarf", "dwarf_low_sweep", "earth", "elbow", -22, 8},
    {"elf", "elf.magic_archer.vine_trap", "nature", "leftKnee", 19, 38},
    {"mage", "mage_tidal_ring", "water", "leftElbow", 20, 39},
    {"elf", "elf_pinning_shot", "arrow"},
    {"mage", "mage.cryo.frost_ring", "frost"},
    {"mage", "mage.pyro.earth_rise", "earth"},
    {"mage", "mage.pyro.cinder_ring", "fire"},
    {"mage", "mage.common.gravity", "gravity"},
}
local ok, reason = xpcall(function()
    local service = require(module)
    local actor, root = rig(at - aim * 3)
    local state = {character = actor, root = root, heroId = "test", attackSeq = 8, feedbackSeq = 0}
    local packet
    service.mount(stage, {FireAllClients = function(_, ...) packet = table.pack(...) end})
    local function strike(e, class, d, current, repeated)
        state.baseClassId = class
        local attack = repeated or {definition = d, isSkill = true, attackPower = 100, direction = aim, hits = {}, hitCount = 0}
        packet = nil
        service.damage(state, e, attack, current, aim, 1)
        return packet, attack
    end
    local canRender = type(Effects.updateSlow) == "function"
    check(canRender, "slow visuals render through the client control presenter")
    local profiles = {}
    for _, row in cases do
        local class, id, kind = unpack(row)
        local d, e = skill(class, id), target()
        local packetAfter, attack = strike(e, class, d, 100)
        local expiry = e.model:GetAttribute("K0GravityUntil")
        local now = workspace:GetServerTimeNow()
        local duration = d.slowDuration or 2
        check(packetAfter and packetAfter[3] > 0 and packetAfter[7] == id, id .. " original damage packet")
        check(e.gravityUntil == 100 + duration and e.gravityMultiplier == (d.slow or d.slowMultiplier)
            and math.abs(expiry - now - duration) < .5, id .. " original slow timing and strength")
        check(e.model:GetAttribute("K0SlowStyle") == kind, id .. " server selects visual style")
        check(not strike(e, class, d, 100.1, attack) and expiry == e.model:GetAttribute("K0GravityUntil"), id .. " duplicate")
        if row[4] then
            for _, rigType in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
                local age = d.windup + (d.hitDelay or 0) + .064
                local pose
                if class == "knight" or class == "dwarf" then
                    pose = Motion.sample(class, d, age, rigType)
                else
                    pose = {angles = {}}
                    if class == "elf" then Poses.bow(pose, d, age, .064, false, 1)
                    else Poses.mage(pose, d, "cast", age) end
                end
                local value = pose.angles[row[4]].X
                check(value >= row[5] and value <= row[6], id .. " recovery pose " .. rigType.Name .. " = " .. value)
            end
        end
        if canRender then
            local visual = Effects.bind(e.model)
            check(Effects.updateSlow(visual, now, at), id .. " active visual")
            local beams, glow = {}, e.model:FindFirstChild("GravityEffect")
            for _, node in e.root:GetDescendants() do
                if node:IsA("Beam") then table.insert(beams, node) end
            end
            if kind == "gravity" then
                check(glow and glow.DepthMode == Enum.HighlightDepthMode.Occluded and #beams == 0, id .. " legacy gravity highlight")
            else
                check(not glow and #beams == 2, id .. " two open strokes")
                for _, beam in beams do
                    check(beam.FaceCamera and beam.Segments == 5 and beam:GetAttribute("Style") == kind,
                        id .. " bounded, identifiable beam")
                    check(beam.Attachment0.Parent == e.root and beam.Attachment1.Parent == e.root, id .. " follows target")
                end
                local beam = beams[1]
                if beam then
                    local old = beam.Attachment0.WorldPosition
                    local shift = Vector3.new(2, 0, 1)
                    e.model:PivotTo(e.model:GetPivot() + shift)
                    check((beam.Attachment0.WorldPosition - old - shift).Magnitude < .001, id .. " moving target")
                    local startingWidth = beam.Width0
                    Effects.updateSlow(visual, now + .24, at)
                    check(startingWidth > beam.Width0 and beam.Width0 > .18, id .. " contact settles into a thin trace")
                    profiles[kind] = tostring(beam.Attachment0.Position) .. "/" .. tostring(beam.Attachment1.Position)
                    Effects.updateSlow(visual, expiry - .06, at)
                    check(beam.Width0 < .08, id .. " end fades")
                end
            end
            check(not Effects.updateSlow(visual, expiry, at) and not visual.slow, id .. " expiry cleanup")
            check(not e.model:FindFirstChild("GravityEffect") and not e.root:FindFirstChild("SlowContactStart"), id .. " no instances remain")
        end
    end
    if canRender then
        local seen = {}
        for kind, points in profiles do
            check(not seen[points], kind .. " distinct shape")
            seen[points] = true
        end
        local low = target()
        strike(low, "dwarf", skill("dwarf", "dwarf_low_sweep"), 100)
        local visual, now = Effects.bind(low.model), workspace:GetServerTimeNow()
        check(Effects.update(visual, now) and Effects.updateSlow(visual, now, at), "stun and slow coexist")
        local layer = visual.slow
        strike(low, "dwarf", skill("dwarf", "dwarf_low_sweep"), 100.5)
        check(Effects.updateSlow(visual, now + .25, at) and visual.slow == layer, "same-style refresh reuses attachments")
        strike(low, "mage", skill("mage", "mage_tidal_ring"), 100.6)
        check(Effects.updateSlow(visual, now + .3, at) and visual.slow.kind == "water" and not layer.nodes[1].Parent,
            "latest applied style replaces the existing trace")
        check(not Effects.updateSlow(visual, now + .35, at + Vector3.xAxis * 100) and not visual.slow, "distance culling")
        check(Effects.updateSlow(visual, now + .4, at), "near observer restores active trace")
        low.humanoid.Health = 0
        check(not Effects.updateSlow(visual, now + .45, at) and not visual.slow, "dead targets clear immediately")
        Effects.clear(visual)
        local resetting = target()
        strike(resetting, "mage", skill("mage", "mage_tidal_ring"), 100)
        service.reset(resetting, false)
        check(not resetting.model:GetAttribute("K0SlowStyle") and not resetting.model:GetAttribute("K0GravityUntil"), "reset clears both attributes")
        local expiring = target()
        strike(expiring, "mage", skill("mage", "mage_tidal_ring"), 100)
        expiring.mode, expiring.exposedUntil = "Exposed", 104
        service.step(expiring, 103, 1 / 30)
        check(not expiring.model:GetAttribute("K0SlowStyle") and not expiring.model:GetAttribute("K0GravityUntil"), "server expiry clears both attributes")
    end
    local d = skill("elf", "elf.magic_archer.vine_trap")
    local ogre, boss, lethal = target("Ogre"), target(), target()
    boss.model:SetAttribute("StoryBoss", true)
    lethal.humanoid.Health = 1
    for _, e in {ogre, boss, lethal} do
        strike(e, "elf", d, 100)
        check(e.model:GetAttribute("K0SlowStyle") == nil and e.model:GetAttribute("K0GravityUntil") == nil,
            "immune and lethal targets have no slow")
    end
end, debug.traceback)
stage:Destroy()
module:Destroy()
check(ok, "fixture runtime")
if not ok then table.insert(report.failures, reason) end
print("HERO_SLOW_PRESENTATION " .. game:GetService("HttpService"):JSONEncode(report))
return report
