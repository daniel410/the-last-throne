-- Verify contact geometry, motion and budget fallback through the shipping receiver.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local origin, aim = Vector3.new(0, 893, 0), -Vector3.zAxis
local center = origin + aim*7
local stage = Instance.new("Folder", workspace)
local floor = Instance.new("Part", stage)
floor.Position, floor.Size, floor.Anchored = origin - Vector3.yAxis*3.5, Vector3.new(75, 1, 75), true
local actor = Instance.new("Model", stage)
local root = Instance.new("Part", actor)
root.Name, root.Position, root.Anchored, root.CanQuery, root.CanCollide = "HumanoidRootPart", origin, true, false, false
Instance.new("Humanoid", actor)

local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(10, 14, 13), center)
local initial = {}
for _, item in workspace:GetChildren() do initial[item] = true end
local report = {checks=0, failures={}}
local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end
local function named(rootInstance, name)
    local instances = {}
    if rootInstance then
        for _, item in rootInstance:GetDescendants() do
            if item.Name == name then table.insert(instances, item) end
        end
    end
    return instances
end
local function release(id)
    for _, item in workspace:GetChildren() do
        if item.Name == "HeroVFX" and item:GetAttribute("SkillId") == id then return item end
    end
end
local function reset()
    FX.clear()
    for _, item in workspace:GetChildren() do
        if not initial[item] then item:Destroy() end
    end
end

local cases = {
    {"knight.steel_knight.steel_sweep", "SteelSweepEdge", "SteelSweepContact", "SkillSector", 9, 6},
    {"dwarf.iron_axe.crag_cleave", "CragCleaveEdge", "CragCleaveContact", "SkillSector", 9, 6},
    {"elf.magic_archer.vine_burst", "RootingVine", "VineBurstContact", "ImpactBoundary", 12, 9},
    {"mage.pyro.lava_eruption", "EruptionJet", "LavaEruptionContact", "ImpactBoundary", 3, 2},
}
local ok, err = xpcall(function()
    for index, case in cases do
        local id, edge, contact, boundary, fullCount, smallCount = unpack(case)
        local row = Catalog.byId[id]
        local d, classId = row.definition, row.classId
        for _, compact in {false, true} do
            FX.isOtherHero = function() return compact end
            Visual.play(actor, id, origin, center, 0, {}, nil, nil, workspace:GetServerTimeNow(), aim)
            local pre = release(id)
            check(#named(pre, edge) == 0, id .. " has no attack shape before the confirmed pulse")
            reset()
            local at = workspace:GetServerTimeNow()
            Visual.play(actor, id, origin, center, 1, {center}, nil, nil, nil, aim)
            local model = release(id)
            local strokes = named(model, edge)
            check(#strokes == (compact and smallCount or fullCount), id .. " expected stroke count")
            local lower, upper = math.huge, -math.huge
            FX.step(at + .17)
            for _, beam in strokes do
                for _, endpoint in {beam.Attachment0.WorldPosition, beam.Attachment1.WorldPosition} do
                    lower, upper = math.min(lower, endpoint.Y), math.max(upper, endpoint.Y)
                    local anchor = d.form == "ground" and center or origin
                    local delta = endpoint - anchor
                    check(Vector3.new(delta.X, 0, delta.Z).Magnitude <= (d.form == "ground" and d.radius or d.range) + .01,
                        id .. " path stays inside server reach")
                end
            end
            if index == 1 then
                check(upper-lower < .6 and #strokes > 0, "Steel Sweep stays horizontal")
            elseif index == 2 then
                check(upper-lower > 3.9 and #named(model,"DescendingCleave") == 0, "Crag Cleave has one heavy diagonal")
            elseif index == 3 then
                local tips = named(model, "RootAscendingTip")
                check(#tips == (compact and 3 or 4) and tips[1].Position.Y > floor.Position.Y + 1.65,
                    "Vine Burst roots rise at their outer tips")
            else
                check(upper-lower > 3 and #named(model,"MoltenSeam") == #strokes and #named(model,"EarthFissure") == 0,
                    "Lava Eruption opens molten seams below tall vents")
            end
            local boundaryCount, genericCount = 0, 0
            for _, item in workspace:GetChildren() do
                if not initial[item] then
                    if item.Name == boundary then boundaryCount += 1 end
                    if item.Name == "SkillContact" or item.Name == "BladeCrescent" then genericCount += 1 end
                end
            end
            check(boundaryCount > 0 and genericCount == 0, id .. " keeps the range boundary with no duplicate flash or edge")
            local hit, distinct = FX.contact(center, classId, id, aim, 1, compact)
            check(distinct and #named(hit, contact) == 2, id .. " distinct confirmed target contact")
            FX.step(at + 1)
            check(model and not model.Parent and hit and not hit.Parent, id .. " release and contact expire")
            reset()
        end
        FX.isOtherHero = function() return true end
        for _ = 1, 6 do assert(FX.skill(actor, id, origin, center, 1, {}, nil, aim)) end
        local before = {}
        for _, item in workspace:GetChildren() do before[item] = true end
        Visual.play(actor, id, origin, center, 1, {}, nil, nil, nil, aim)
        local fallback = 0
        for _, item in workspace:GetChildren() do
            if not before[item] and item.Name == boundary then fallback += 1 end
        end
        check(FX.count() == 6 and fallback > 0, id .. " only bounded range cue survives primary budget pressure")
        reset()
    end

    for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local steel = Catalog.byId[cases[1][1]].definition
        local wind = Melee.sample("knight", steel, steel.windup*.52, rig)
        local strike = Melee.sample("knight", steel, steel.windup+.052, rig)
        check(wind.angles.torso.Y < strike.angles.torso.Y-15 and strike.angles.leftKnee.X > wind.angles.leftKnee.X+12,
            "Steel Sweep transfers stance into the cut " .. rig.Name)
        local crag = Catalog.byId[cases[2][1]].definition
        local plant = Melee.sample("dwarf", crag, crag.windup+.055, rig)
        local pull = Melee.sample("dwarf", crag, crag.windup+.15, rig)
        check(plant.angles.leftKnee.X > pull.angles.leftKnee.X+12 and pull.angles.elbow.X < plant.angles.elbow.X-12,
            "Crag Cleave braces, then tucks the axe " .. rig.Name)
    end
    local vine = Catalog.byId[cases[3][1]].definition
    local eruption = Catalog.byId[cases[4][1]].definition
    local started = workspace:GetServerTimeNow()
    actor:SetAttribute("K0ClassId", "elf")
    actor:SetAttribute("K0AttackStartedAt", started)
    actor:SetAttribute("K0AttackSeq", 1)
    actor:SetAttribute("K0State", "Attack")
    actor:SetAttribute("K0SkillId", vine.id)
    local ready = Bow.forCharacter(actor, started+vine.windup*.52)
    local fireAt = started+vine.windup
    Bow.confirmPulse(actor, vine.id, 1, 1, fireAt, started, fireAt)
    local fired = Bow.forCharacter(actor, fireAt+.052)
    check(fired.angles.elbow.X > ready.angles.elbow.X+20 and fired.angles.leftKnee.X > ready.angles.leftKnee.X+5,
        "Vine Burst opens the draw elbow and plants after release")
    local profile = Mage.profile(eruption)
    local gathers = Mage.sample(eruption, profile, eruption.windup*.58)
    local lifts = Mage.sample(eruption, profile, eruption.windup+.066)
    check(lifts.angles.left.X > gathers.angles.left.X+38 and lifts.angles.rightKnee.X < gathers.angles.rightKnee.X-15,
        "Lava Eruption pulls up from a distinct crouch")
end, debug.traceback)

reset()
FX.isOtherHero = originalCompact
camera.CFrame = originalCamera
stage:Destroy()
if not ok then table.insert(report.failures, err) end
report.pass = #report.failures == 0
print("HERO_IMPACT_SILHOUETTES_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Impact silhouette regression")
