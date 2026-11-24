assert(game.PlaceId == 0, "Use a local review place")

local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)

local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local originalCamera = camera.CFrame
local origin = Vector3.new(0, 124, 0)
local straight = -Vector3.zAxis
local angled = CFrame.Angles(0, math.rad(18), 0):VectorToWorldSpace(straight)
camera.CFrame = CFrame.lookAt(origin + Vector3.new(11, 9, 14), origin)

local report = {checks = 0, failures = {}}
local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end
local function objects(model, name)
    local found = {}
    if model then
        for _, child in model:GetDescendants() do
            if child.Name == name then table.insert(found, child) end
        end
    end
    return found
end
local function near(a, b, tolerance)
    return (a - b).Magnitude < (tolerance or .01)
end
local function actor(name, position, parent)
    local part = Instance.new("Part", parent)
    part.Name = name
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    return part
end

local sword = Catalog.byId["knight.paladin.sunward_cross"].definition
local axe = Catalog.byId["dwarf.iron_axe.crosscut_axe"].definition
local bow = Catalog.byId["elf.marksman.crossfire"].definition
local ice = Catalog.byId["mage.cryo.glacial_spike"].definition

local ok, err = xpcall(function()
    local endPoint = origin + straight * 6
    local before = {}
    for _, child in workspace:GetChildren() do before[child] = true end
    Visual.play(nil, sword.id, origin, endPoint, 2, {}, nil, nil, nil, straight)
    local sector, wave = 0, 0
    for _, child in workspace:GetChildren() do
        if not before[child] then
            if child.Name == "SkillSector" then sector += 1 end
            if child.Name == "ElementalWave" then wave += 1 end
        end
    end
    check(sector == 12, "Sunward Cross retains the range boundary")
    check(wave == 0, "Sunward Cross does not add a second release wave")
    FX.clear()

    local rises = {}
    for pulse = 1, 2 do
        local model = FX.skill(nil, sword.id, origin, endPoint, pulse, {}, nil, straight)
        local edges = objects(model, "SunwardCross")
        check(#edges == 8, "Sunward Cross has one continuous edge at pulse " .. pulse)
        if #edges > 0 then
            rises[pulse] = edges[#edges].Attachment1.WorldPosition.Y - edges[1].Attachment0.WorldPosition.Y
            for _, beam in edges do
                check((beam.Attachment0.WorldPosition - origin).Magnitude <= sword.range + .01, "Sword edge stays in the sector")
            end
        end
        FX.clear()
    end
    check((rises[1] or 0) < -2 and (rises[2] or 0) > 3, "The first sword cut descends and the second climbs higher")
    for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local reset = Melee.sample("knight", sword, sword.windup + sword.interval*.51, rig)
        local first = Melee.sample("knight", sword, sword.windup + .058, rig)
        local second = Melee.sample("knight", sword, sword.windup + sword.interval + .058, rig)
        check(reset.angles.rightKnee.X > first.angles.rightKnee.X + 10, "Knight loads the other leg " .. rig.Name)
        check(second.angles.torso.Z < first.angles.torso.Z - 8, "Knight opens into the second cut " .. rig.Name)
    end

    local dwarf = Instance.new("Model", stage)
    local hand = actor("RightHand", origin + Vector3.new(.8, .4, -.25), dwarf)
    local weapon = Instance.new("Model", dwarf)
    weapon:SetAttribute("WeaponClassId", "dwarf")
    actor("Weapon", hand.Position, weapon)
    local clipped = origin + angled * 11
    local outgoing = FX.skill(dwarf, axe.id, origin, origin + straight*10, 1, {}, hand.Position)
    local throwWake = objects(outgoing, "CrosscutThrowWake")[1]
    check(throwWake and near(throwWake.Attachment0.WorldPosition, hand.Position), "Throw wake begins at equipped axe")
    local returning = FX.skill(dwarf, axe.id, origin, clipped, 2, {})
    check(outgoing and not outgoing.Parent, "Recall retires the outgoing axe")
    local catchWake = objects(returning, "CrosscutReturnWake")[1]
    local flightAxe = objects(returning, "ThrownAxeSource")[1]
    check(catchWake and flightAxe and near(catchWake.Attachment1.WorldPosition, flightAxe.Position), "Recall and axe share the start of the approach")
    FX.step(workspace:GetServerTimeNow() + .10)
    check(catchWake and flightAxe and near(catchWake.Attachment1.WorldPosition, hand.Position)
        and near(flightAxe.Position, hand.Position), "Recall settles on the actual hand")
    FX.clear()

    for pulse, heading in {straight, angled} do
        local wallEnd = origin + heading * (pulse == 1 and 13 or 8)
        local muzzle = origin + Vector3.new(.55, .32, -.77)
        local shot = FX.skill(nil, bow.id, origin, wallEnd, pulse, {}, muzzle)
        local trace = objects(shot, "IconCrossfireTrace")[1]
        check(trace and near(trace.Attachment0.WorldPosition, muzzle) and near(trace.Attachment1.WorldPosition, wallEnd),
            "Crossfire joins bow to the confirmed endpoint " .. pulse)
        FX.step(workspace:GetServerTimeNow() + .12)
        check(trace and (trace.Attachment0.WorldPosition - muzzle).Magnitude > 1
            and near(trace.Attachment1.WorldPosition, wallEnd), "Crossfire wake retracts to its endpoint " .. pulse)
        FX.clear()
    end
    local early, late = {angles = {}}, {angles = {}}
    Ranged.bow(early, bow, bow.windup + .05, .05, true, 1)
    Ranged.bow(late, bow, bow.windup + bow.interval + .05, .05, false, 2)
    check(late.angles.weapon.Z < early.angles.weapon.Z - 18, "Second shot banks the bow the other way")
    check(late.angles.rightKnee.X > early.angles.rightKnee.X + 15, "Second shot plants the other foot")

    local muzzle = origin + Vector3.new(.7, .8, -.45)
    local strike = FX.skill(nil, ice.id, origin, clipped, 1, {clipped}, muzzle)
    local wake = objects(strike, "GlacialSpikeWake")[1]
    local split = objects(strike, "GlacialSideCrystal")[1]
    local initial = split and split.Position
    check(wake and near(wake.Attachment0.WorldPosition, muzzle) and near(wake.Attachment1.WorldPosition, clipped),
        "Ice release links staff and confirmed contact")
    FX.step(workspace:GetServerTimeNow() + .14)
    check(split and (split.Position - initial).Magnitude > .3 and split.Position.Y > initial.Y, "Glacial splinters peel upward and outward")
    local load, push = {angles = {}}, {angles = {}}
    Ranged.mage(load, ice, Mage.profile(ice), ice.windup*.58)
    Ranged.mage(push, ice, Mage.profile(ice), ice.windup + .063)
    check(push.angles.leftElbow.X > load.angles.leftElbow.X + 75, "Mage gathers and opens the casting elbow")
end, debug.traceback)

FX.clear()
stage:Destroy()
camera.CFrame = originalCamera
if not ok then table.insert(report.failures, err) end
report.pass = #report.failures == 0
print("HERO_CROSSED_RELEASES_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero crossed release regression")
