assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Use an isolated Studio place")

local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Motion = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Bomb = require(Client.BombVisual)

local sword = Catalog.byId["knight.steel_knight.challenging_strike"].definition
local roll = Catalog.byId["dwarf.gunner.rolling_charge"].definition
local bounce = Catalog.byId["dwarf.gunner.skipping_charge"].definition
local bow = Catalog.byId["elf.marksman.heavy_draw"].definition
local ice = Catalog.byId["mage.cryo.shatter_dart"].definition
local report = {checks = 0, failures = {}}
local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end
local function named(model, name)
    local result = {}
    if model then
        for _, item in model:GetDescendants() do
            if item.Name == name then table.insert(result, item) end
        end
    end
    return result
end
local function near(a, b)
    return (a - b).Magnitude < .02
end

local stage = Instance.new("Folder", workspace)
local origin = Vector3.new(0, 164, 0)
local direction = -Vector3.zAxis
local ground = Instance.new("Part", stage)
ground.Size, ground.Position = Vector3.new(48, 2, 48), origin - Vector3.yAxis*4
ground.Anchored = true
local camera = workspace.CurrentCamera
local savedCamera, savedCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(9, 7, 14), origin)

local ok, errorText = xpcall(function()
    for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local load = Motion.sample("knight", sword, sword.windup*.55, rig)
        local hit = Motion.sample("knight", sword, sword.windup+.053, rig)
        local rest = Motion.sample("knight", sword, sword.windup+sword.active+sword.recovery, rig)
        check(load.angles.leftElbow.X > rest.angles.leftElbow.X+20, "Knight winds up behind the shield "..rig.Name)
        check(hit.angles.leftKnee.X > rest.angles.leftKnee.X+26, "Knight catches the strike on the lead leg "..rig.Name)
        local launch = roll.windup-Bomb.get(roll.id).flight
        local low = Motion.sample("dwarf", roll, launch, rig)
        local skip = Motion.sample("dwarf", bounce, bounce.windup-Bomb.get(bounce.id).flight, rig)
        check(low.offhand and low.angles.left.X < skip.angles.left.X-12, "Dwarf rolls from the lower offhand "..rig.Name)
        check(low.angles.rightKnee.X > skip.angles.rightKnee.X+13, "Dwarf catches the roll on a deeper lead knee "..rig.Name)
    end
    local draw, snap = {angles = {}}, {angles = {}}
    Ranged.bow(draw, bow, bow.windup*.55)
    Ranged.bow(snap, bow, bow.windup+.064, .064, false, 1)
    check(draw.angles.rightKnee.X > draw.angles.leftKnee.X+19, "Heavy Draw holds weight on the rear heel")
    check(snap.angles.elbow.X > 39, "Heavy Draw snaps the draw elbow rearward")
    local gather, flick = {angles = {}}, {angles = {}}
    Ranged.mage(gather, ice, Mage.profile(ice), ice.windup*.58)
    Ranged.mage(flick, ice, Mage.profile(ice), ice.windup+.062)
    check(gather.angles.leftElbow.X < -44 and flick.angles.leftElbow.X > 32, "Shatter Dart folds then snaps the free elbow")

    local before = {}
    for _, item in workspace:GetChildren() do before[item] = true end
    Visual.play(nil, sword.id, origin, origin+Vector3.xAxis*4, 1, {}, nil, nil, nil, direction)
    local model, sector, duplicate = nil, 0, false
    for _, item in workspace:GetChildren() do
        if not before[item] then
            if item.Name == "HeroVFX" then model = item end
            if item.Name == "SkillSector" then sector += 1 end
            if item.Name == "BladeCrescent" then duplicate = true end
        end
    end
    local cut = named(model, "ChallengingStrikeEdge")
    check(#cut == 7 and #named(model, "ChallengingStrikeRibbon") > 0, "One authored sword edge and ribbon")
    check(sector == 12 and not duplicate, "Sword keeps its sector and omits the duplicate crescent")
    check(model and not model:FindFirstChild("ElementalFlare", true), "Sword omits the generic flash")
    if #cut > 0 then
        local high, low = cut[1].Attachment0.WorldPosition, cut[#cut].Attachment1.WorldPosition
        check(high.Y-low.Y > 3, "Sword cuts from high to low")
        for _, beam in cut do
            local point = beam.Attachment1.WorldPosition-origin
            check(point:Dot(direction) > 0 and point.Magnitude <= sword.range, "Sword follows the supplied heading within range")
        end
    else
        check(false, "Sword cuts from high to low")
        for _ = 1, 7 do check(false, "Sword follows the supplied heading within range") end
    end
    FX.clear()

    local target = origin+direction*12
    local launch = CFrame.lookAt(origin+Vector3.new(-.7, -1.25, 0), target)
    local landing = workspace:GetServerTimeNow()+.19
    local valid = true
    local flight = FX.bombFlight(nil, roll, Bomb.get(roll.id), launch, target, 1, 1, landing, function() return valid end)
    local skid = named(flight, "RollingFuseSkid")
    check(#skid == 2, "Rolling Charge leaves two low fuse traces")
    FX.step(landing-.10)
    local body = flight and flight:FindFirstChild("BombBody", true)
    local strip = skid[1]
    check(body and strip and math.abs(strip.Attachment1.WorldPosition.Y-(Bomb.floor(target).Y+.10)) < .02
        and math.abs(body.Position.Y-strip.Attachment1.WorldPosition.Y-(Bomb.radius-.10)) < .02,
        "Fuse trace travels on the floor with the charge")
    valid = false
    FX.step(landing-.08)
    check(flight and not flight.Parent, "Cancelled roll cleans up its payload and trace")
    local confirmed = target+Vector3.xAxis*2
    local blast = FX.skill(nil, roll.id, origin, confirmed, 1, {})
    local wings = named(blast, "RollingChargeBlastWing")
    check(#wings == 2 and not blast:FindFirstChild("GroundPressure", true), "Impact has an open two-sided shape")
    FX.step(workspace:GetServerTimeNow()+.12)
    local heading = (confirmed-origin).Unit
    for _, wing in wings do
        local base = wing.Attachment0.WorldPosition-confirmed
        local edge = wing.Attachment1.WorldPosition-confirmed
        check(base:Dot(heading) > 0 and base:Dot(heading) < .4 and edge:Dot(heading) > 1,
            "Blast starts at the confirmed ground point and opens forward")
        check(Vector3.new(edge.X, 0, edge.Z).Magnitude < roll.radius, "Blast visual remains inside the blast radius")
    end
    if #wings == 0 then
        for _ = 1, 2 do
            check(false, "Blast starts at the confirmed ground point and opens forward")
            check(false, "Blast visual remains inside the blast radius")
        end
    end
    FX.clear()

    for _, entry in {{bow, "HeavyDrawPressure"}, {ice, "ShatterDartWake"}} do
        local skill, name = unpack(entry)
        local muzzle = origin+Vector3.new(.70,.44,-1.04)
        for _, point in {target, origin+direction*.35} do
            local begin = point == target and muzzle or origin
            local release = FX.skill(nil, skill.id, origin, point, 1, {}, muzzle)
            local wake = named(release, name)[1]
            check(wake and near(wake.Attachment0.WorldPosition, begin), name.." starts at a usable socket")
            check(wake and near(wake.Attachment1.WorldPosition, point), name.." stops at the confirmed endpoint")
            FX.step(workspace:GetServerTimeNow()+.073)
            check(wake and (wake.Attachment0.WorldPosition-begin).Magnitude > .04
                and near(wake.Attachment1.WorldPosition, point), name.." retracts toward the confirmed endpoint")
            check(release and not release:FindFirstChild("ElementalFlare", true), name.." omits the generic flash")
            FX.clear()
        end
    end

    FX.isOtherHero = function() return true end
    local shot = FX.skill(nil, bow.id, origin, target, 1, {}, origin+direction)
    check(shot and shot:GetAttribute("ReleaseTrace") and #named(shot, "HeavyDrawFletching")==0,
        "Party view preserves the arrow path with one beam")
    local hit = FX.contact(target, "mage", ice.id, direction, 1, true)
    local splits = named(hit, "ShatterDartSplinters")
    check(#splits == 2, "Party view preserves the paired Shatter Dart splinters")
    check(#splits == 2 and math.abs(splits[1].Attachment1.WorldPosition.Y-splits[2].Attachment1.WorldPosition.Y) > .2,
        "Shatter Dart splinters leave the impact at different heights")
end, debug.traceback)

FX.clear()
FX.isOtherHero, camera.CFrame = savedCompact, savedCamera
stage:Destroy()
if not ok then table.insert(report.failures, errorText) end
report.pass = #report.failures == 0
print("HERO_WEIGHTED_RELEASES_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass, "Hero weighted release regression")
