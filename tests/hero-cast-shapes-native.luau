-- Native receiver, motion and visual-budget regression for four hero skills.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local origin, forward = Vector3.new(0, 893, 0), -Vector3.zAxis
local target = origin + forward*7
local stage = Instance.new("Folder", workspace)
local floor = Instance.new("Part", stage)
floor.Position, floor.Size, floor.Anchored = origin - Vector3.yAxis*3.5, Vector3.new(80, 1, 80), true
local actor = Instance.new("Model", stage)
local root = Instance.new("Part", actor)
root.Name, root.Position, root.Anchored, root.CanQuery, root.CanCollide = "HumanoidRootPart", origin, true, false, false
local grip = Instance.new("Part", actor)
grip.Name, grip.Position, grip.Anchored, grip.CanCollide = "WeaponGrip", origin+Vector3.new(.7,.9,-.8), true, false
local muzzle = Instance.new("Attachment", grip)
muzzle.Name = "WeaponTip"
Instance.new("Humanoid", actor)

local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(10, 10, 13), target)
local initial = {}
for _, item in workspace:GetChildren() do initial[item] = true end
local report = {checks=0, failures={}}
local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end
local function named(container, name)
    local instances = {}
    for _, item in container and container:GetDescendants() or {} do
        if item.Name == name then table.insert(instances, item) end
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
local function cast(d, pulse, at)
    Visual.play(actor, d.id, origin, at or target, pulse, {}, nil, nil, nil, forward)
    return release(d.id)
end
local function span(strokes)
    local points = {}
    for _, beam in strokes do
        table.insert(points, beam.Attachment0.WorldPosition)
        table.insert(points, beam.Attachment1.WorldPosition)
    end
    return points
end
local function maximum(points, measure)
    local result = -math.huge
    for _, point in points do result = math.max(result, measure(point)) end
    return result
end
local function depth(point)
    return (point-origin):Dot(forward)
end
local function height(point)
    return point.Y
end
local function radius(point)
    local delta = point-target
    return Vector3.new(delta.X, 0, delta.Z).Magnitude
end
local function plain(d)
    local copy = table.clone(d)
    copy.id = "Fixture_"..d.id
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end

local warcry = Catalog.byId["knight.steel_knight.warcry_assault"].definition
local twin = Catalog.byId["dwarf.iron_axe.twin_axe_path"].definition
local arrow = Catalog.byId["elf.magic_archer.storm_arrow"].definition
local frost = Catalog.byId["mage.cryo.froststorm"].definition
local ok, err = xpcall(function()
    for _, compact in {false, true} do
        FX.isOtherHero = function() return compact end
        local waveHeights, waveDepths = {}, {}
        for pulse=1,warcry.pulses do
            local now = workspace:GetServerTimeNow()
            local model = cast(warcry, pulse, origin-Vector3.xAxis*4)
            local strokes = named(model,"WarcryWave")
            check(#strokes == (compact and 4 or 6), "Warcry retains one main wave per pulse")
            local early = maximum(span(strokes), depth)
            FX.step(now+.12)
            local points = span(strokes)
            waveHeights[pulse], waveDepths[pulse] = maximum(points,height), maximum(points,depth)
            check(waveDepths[pulse] > early+.4, "Warcry propagates forward on each pulse")
            for _, point in points do
                local delta = Vector3.new(point.X-origin.X, 0, point.Z-origin.Z)
                check(delta.Magnitude <= warcry.range+.01 and delta:Dot(forward) > 0
                    and delta.Unit:Dot(forward) >= math.cos(math.rad(warcry.angle*.5)),
                    "Wave stays inside the locked sector even when the target is off-axis")
            end
            check(#named(model,"WarcryGroundEcho") == (pulse==3 and not compact and 4 or 0), "Warcry ground echo marks the caster's final beat")
            check(#named(workspace,"SkillSector") > 0 and #named(workspace,"BladeCrescent") == 0, "Warcry keeps its sector with one effect")
            reset()
        end
        check(waveDepths[3]>waveDepths[2] and waveDepths[2]>waveDepths[1]
            and waveHeights[3]>waveHeights[2] and waveHeights[2]>waveHeights[1], "Warcry gains reach and height across all three beats")

        local banks = {}
        for pulse=1,twin.pulses do
            local now = workspace:GetServerTimeNow()
            local model = cast(twin, pulse)
            local wake = named(model,"TwinAxeFlight")
            check(#wake == (compact and 4 or 6) and #named(model,"AxeRotation")==0, "Twin Axe Path has only one visible path per throw")
            if #wake>0 then
                local first, last = wake[1].Attachment0.WorldPosition, wake[#wake].Attachment1.WorldPosition
                check((first-muzzle.WorldPosition).Magnitude < .12 and (last-target).Magnitude < .02, "Each axe wake connects the weapon to the confirmed endpoint")
                local midpoint = wake[#wake/2].Attachment1.WorldPosition
                banks[pulse] = midpoint - first:Lerp(last,.5)
            end
            FX.step(now+.24)
            check(model and (model.Parent~=nil) == (pulse==2), "First axe effect retires while the second throw reads")
            reset()
        end
        check(banks[1] and banks[2] and banks[1].X>.2 and banks[2].X<-.2
            and banks[1].Y>0 and banks[2].Y<0, "Twin Axe Path reverses its bank and lowers the second throw")
        local covered = origin+forward*.26
        local shortWake = named(cast(twin,1,covered),"TwinAxeFlight")
        check(shortWake[1] and (shortWake[1].Attachment0.WorldPosition-origin).Magnitude < .02
            and (shortWake[#shortWake].Attachment1.WorldPosition-covered).Magnitude < .02, "Axe wake uses the server origin if the socket is past the hit")
        reset()

        for _, d in {arrow,frost} do
            cast(d,0)
            check(not release(d.id), d.id.." creates no strike before the confirmed pulse")
            reset()
            task.wait(.75) -- Let the ground preview release its shared part slots.
            local now = workspace:GetServerTimeNow()
            local model = cast(d,1)
            check(#named(workspace,"ImpactBoundary") == (compact and 12 or 24), d.id.." retains the confirmed area")
            check(#named(workspace,"LightningFork") == 0 and #named(workspace,"SkillContact") == 0, d.id.." skips the generic duplicate")
            if d==arrow then
                local bolt = named(model,"StormArrowBolt")
                check(#bolt == (compact and 4 or 5) and #named(model,"StormArrowFork") == (compact and 1 or 2), "Storm Arrow keeps the bolt and ground spread")
                check(#bolt>0 and (bolt[#bolt].Attachment1.WorldPosition-target).Magnitude < .02, "Bolt ends at the server center")
                check(#named(model,"StormArrowLaunch") == (compact and 0 or 1), "Nearby bow release cue is reserved for its caster")
            else
                local flow = named(model,"FroststormFlow")
                check(#flow == (compact and 5 or 12), "Froststorm keeps a compact or full spiral")
                local before = maximum(span(flow),radius)
                local shard = named(model,"FroststormFallingCrystal")
                local y = shard[1] and shard[1].Position.Y
                FX.step(now+.19)
                check(maximum(span(flow),radius) < before*.7, "Froststorm contracts toward its confirmed center")
                check(#shard == (compact and 2 or 3) and y and shard[1].Position.Y < y-.7, "Froststorm ice descends into the curl")
            end
            FX.step(now+1)
            check(model and not model.Parent, d.id.." expires")
            reset()
        end
        task.wait(.5)
    end

    FX.isOtherHero = function() return true end
    for _, d in {arrow,frost,twin} do
        local occupied = 0
        while FX.skill(actor,d.id,origin,target,1,{},muzzle.WorldPosition,forward) do occupied += 1 end
        cast(d,1)
        local fallback = d==arrow and "LightningFork" or d==frost and "IceCrystal" or "ThrownAxeBlade"
        check(occupied>=6 and FX.count()==occupied and #named(workspace,fallback)>0, d.id.." has a bounded fallback under primary effect pressure")
        reset()
        task.wait(.5)
    end

    local warcryPlain, twinPlain, frostPlain = plain(warcry), plain(twin), plain(frost)
    for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local contact = warcry.windup+(warcry.hitDelay or 0)
        for pulse=1,warcry.pulses do
            local age = contact+(pulse-1)*warcry.interval+.055
            local pose, generic = Melee.sample("knight",warcry,age,rig), Melee.sample("knight",warcryPlain,age,rig)
            local knee = pulse==2 and "rightKnee" or "leftKnee"
            check(pose.angles[knee].X-generic.angles[knee].X > (pulse==3 and 29 or 20), "Warcry alternates braced legs and plants strongly on the last beat "..rig.Name)
        end
        local releaseAt = twin.windup+(twin.hitDelay or 0)
        local reload = releaseAt+.135
        local pose, generic = Melee.sample("dwarf",twin,reload,rig), Melee.sample("dwarf",twinPlain,reload,rig)
        check(pose.angles.elbow.X < generic.angles.elbow.X-22, "Axe elbow folds across the body between throws "..rig.Name)
        for pulse=1,twin.pulses do
            local age = releaseAt+(pulse-1)*twin.interval+.045
            local attack, base = Melee.sample("dwarf",twin,age,rig), Melee.sample("dwarf",twinPlain,age,rig)
            check((attack.angles.torso.Z-base.angles.torso.Z)*(pulse==1 and 1 or -1)>11, "Each axe release banks the torso in the matching direction "..rig.Name)
        end
    end
    local started = workspace:GetServerTimeNow()
    actor:SetAttribute("K0ClassId","elf")
    actor:SetAttribute("K0AttackStartedAt",started)
    actor:SetAttribute("K0AttackSeq",1)
    actor:SetAttribute("K0ArrowReleaseProtocol",1)
    actor:SetAttribute("K0State","Attack")
    actor:SetAttribute("K0SkillId",arrow.id)
    local fireAt = started+arrow.windup
    local held = Bow.forCharacter(actor,fireAt+.04)
    check(held.time==.8 and held.nocked and held.aimPitch>49, "Storm Arrow holds high until server confirmation")
    Bow.confirmPulse(actor,arrow.id,1,1,fireAt,started,fireAt)
    local fired = Bow.forCharacter(actor,fireAt+.055)
    check(not fired.nocked and fired.time>.8 and fired.aimPitch>49, "Storm Arrow releases with the bow still elevated")
    local profile = Mage.profile(frost)
    local age = frost.windup+.062
    local strike, generic = Mage.sample(frost,profile,age), Mage.sample(frostPlain,profile,age)
    check(strike.angles.leftElbow.X < generic.angles.leftElbow.X-22
        and strike.angles.leftKnee.X > generic.angles.leftKnee.X+15, "Froststorm pulls down and loads the front leg")
    for _, d in {warcryPlain,twinPlain,frostPlain} do Presentation.byId[d.id]=nil end
end, debug.traceback)

reset()
FX.isOtherHero = originalCompact
camera.CFrame = originalCamera
stage:Destroy()
if not ok then table.insert(report.failures, err) end
report.pass = #report.failures == 0
print("HERO_CAST_SHAPES_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass, table.concat(report.failures,"\n"))
