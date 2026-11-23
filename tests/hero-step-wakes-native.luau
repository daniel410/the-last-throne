-- Run with plugin security in an isolated built Place in Studio Edit mode.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Combat = game.ServerScriptService.Server.Combat
local Shared = game.ReplicatedStorage.Shared
local Config = require(Shared.K0Config)
local Presentation = require(Shared.SkillPresentation)
local AdvancedCombat = require(Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local previousCamera, previousCompact = camera.CFrame, FX.isOtherHero
local at, aim = Vector3.new(0, 330, 0), -Vector3.zAxis
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 10, 16), at)

local fixture = Combat.CombatService:Clone()
fixture.Name = "StepWakeFixture"
fixture.Source = fixture.Source:gsub("\nreturn CombatService%s*$", function()
    return [[
return { start = startSkill, connect = function(sink)
    advancedEffectRemote = sink
end }
]]
end)
fixture.Parent = Combat

local cases = {
    {"knight", "knight.paladin.valiant_advance", "ValiantBootWake"},
    {"dwarf", "dwarf.gunner.blast_step", "BlastRecoilSkid"},
    {"elf", "elf.marksman.retreating_fire", "RetreatFletchedWake"},
    {"mage", "mage.pyro.ember_step", "EmberStepWake"},
}
local function part(name, size, cf, parent)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Anchored = name, size, cf, true
    p.Parent = parent
    return p
end

local function actor(classId, index)
    local model = Instance.new("Model", stage)
    local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.lookAt(at, at + aim), model)
    root.CanCollide = false
    model.PrimaryPart = root
    model:SetAttribute("K0SpawnReady", true)
    local humanoid = Instance.new("Humanoid", model)
    humanoid.RequiresNeck = false
    return {
        player = { Character = model, Parent = game.Players }, character = model,
        root = root, humanoid = humanoid, mode = "Idle", baseClassId = classId,
        slotCount = 5, skillSlots = { index }, skillReadyAt = {}, mana = 1000, maxMana = 1000,
        attackProfile = Config.BasicAttackProfiles[classId], attackSeq = 0, feedbackSeq = 0,
    }
end

local function wake()
    return workspace:FindFirstChild("HeroStepWake")
end

local checks = 0
local function check(ok, message)
    checks += 1
    assert(ok, message)
end

local function checkPose(classId, d)
    local other = table.clone(d)
    other.id = d.id .. "_fixture"
    Presentation.byId[other.id] = Presentation.get(d)
    if classId == "knight" or classId == "dwarf" then
        for _, rig in Enum.HumanoidRigType:GetEnumItems() do
            local age = d.windup * .6
            local a, b = Melee.sample(classId, d, age, rig), Melee.sample(classId, other, age, rig)
            if classId == "knight" then
                check(a.angles.leftElbow.X - b.angles.leftElbow.X > 20, d.id .. " tucks the shield on " .. rig.Name)
            else
                check(a.offhand and a.angles.leftKnee.X - b.angles.leftKnee.X > 9, d.id .. " loads the rear knee on " .. rig.Name)
            end
        end
    elseif classId == "elf" then
        local a, b = {angles = {}}, {angles = {}}
        Ranged.bow(a, d, d.windup + .055, .055, false, 1)
        Ranged.bow(b, other, d.windup + .055, .055, false, 1)
        check(a.angles.rightKnee.X - b.angles.rightKnee.X > 22, d.id .. " checks the retreat on the rear leg")
        check((a.angles.left - b.angles.left).Magnitude < .01, d.id .. " keeps the bow shoulder on aim")
    else
        local a, b = Mage.sample(d, Mage.profile(d), d.windup + .062), Mage.sample(other, Mage.profile(other), d.windup + .062)
        check((a.angles.left - b.angles.left).Magnitude > 30, d.id .. " sweeps the guiding palm back")
    end
    Presentation.byId[other.id] = nil
end

local ok, err = xpcall(function()
    local api = require(fixture)
    local packet
    api.connect({ FireAllClients = function(_, ...) packet = table.pack(...) end })
    local floor = part("TestFloor", Vector3.new(40, 1, 40), CFrame.new(at - Vector3.yAxis * 3), stage)
    for _, case in cases do
        local classId, id, style = table.unpack(case)
        local index, d
        for i, definition in Config.Skills[classId] do
            if definition.id == id then index, d = i, definition; break end
        end
        checkPose(classId, d)
        for _, scenario in {"open", "clipped", "blocked", "ledge"} do
            for _, compact in {false, true} do
                FX.clear()
                FX.isOtherHero = function() return compact end
                local direction = aim * math.sign(d.move)
                floor.Size = scenario == "ledge" and Vector3.new(3, 1, 3) or Vector3.new(40, 1, 40)
                local wallDistance = scenario == "clipped" and 1.5 or scenario == "blocked" and .6
                local wall = wallDistance and part("TestWall", Vector3.new(4, 6, .2),
                    CFrame.new(at + direction * wallDistance), stage)
                local s = actor(classId, index)
                packet = nil
                api.start(s, 1, 100)
                check(packet and packet[5] == 0 and packet[3] == s.root.Position, id .. " sends the actual arrival")
                if d.originArea then
                    local pulseCenter
                    AdvancedCombat.resolve(s, s.attack, 101, {
                        enemies = {},
                        visual = function(_, _, _, center) pulseCenter = center end,
                    }, 1)
                    check(pulseCenter == at, id .. " keeps the departure as the attack center")
                end
                Visual.play(table.unpack(packet, 1, packet.n))
                local m = wake()
                local distance = (packet[3] - at).Magnitude
                if scenario == "ledge" or scenario == "blocked" then
                    check(distance == 0 and packet[12] == nil and not m, id .. " omits a blocked movement wake")
                else
                    check(packet[12] == at and (packet[3] - at):Dot(direction) > .25, id .. " confirms move direction")
                    check(scenario == "clipped" and distance < math.abs(d.move) or
                        scenario == "open" and math.abs(distance - math.abs(d.move)) < .02, id .. " keeps server travel length")
                    check(m and m:GetAttribute("Style") == style, id .. " selects its own silhouette")
                    local beams = 0
                    for _, node in m:GetDescendants() do
                        check(not node:IsA("Light") and not node:IsA("ParticleEmitter"), id .. " keeps a clear floor")
                        if node:IsA("Beam") then
                            beams += 1
                            local a, b = node.Attachment0.WorldPosition, node.Attachment1.WorldPosition
                            check(node.Name == style and node.Segments == 4, id .. " uses its curved wake")
                            check((a - at):Dot(direction) >= -.02 and math.abs((b - packet[3]):Dot(direction)) < .02,
                                id .. " trace remains on the confirmed segment")
                        end
                    end
                    check(beams == 2, id .. " fits the two-beam budget")
                    Visual.play(table.unpack(packet, 1, packet.n))
                    check(wake() == m, id .. " ignores the duplicate opening")
                    FX.step(packet[9] + .23)
                    check(m.Parent == nil and not wake(), id .. " clears the short wake")
                end
                if wall then wall:Destroy() end
                s.character:Destroy()
            end
        end
    end
end, debug.traceback)
FX.clear()
FX.isOtherHero = previousCompact
camera.CFrame = previousCamera
fixture:Destroy()
stage:Destroy()
assert(ok, err)
print("HERO_STEP_WAKES_NATIVE " .. checks .. " checks passed")
