assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Geometry = require(Client.SkillEffectGeometry)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local origin, direction = Vector3.new(0, 891, 6), -Vector3.zAxis
local target = origin + direction*5
local stage = Instance.new("Folder", workspace)
local floor = Instance.new("Part", stage)
floor.Position, floor.Size, floor.Anchored = origin-Vector3.yAxis*3.5, Vector3.new(70,1,70), true
local actor = Instance.new("Model", stage)
local root = Instance.new("Part", actor)
root.Name, root.Position, root.Anchored, root.CanCollide = "HumanoidRootPart", origin, true, false
local grip = Instance.new("Part", actor)
grip.Name, grip.Position, grip.Anchored, grip.CanCollide = "WeaponGrip", origin+direction*.9+Vector3.xAxis, true, false
local tip = Instance.new("Attachment", grip)
tip.Name = "WeaponTip"
local enemy = Instance.new("Model", stage)
Instance.new("Humanoid", enemy)
local blocker = Instance.new("Part", enemy)
blocker.Name, blocker.Position, blocker.Size, blocker.Anchored = "HumanoidRootPart", target, Vector3.new(2,2,2), true

local camera = workspace.CurrentCamera
local cameraBefore, compactBefore = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(10,12,16), target)
local initial = {}
for _, item in workspace:GetChildren() do initial[item] = true end
local report = {checks=0, failures={}}
local function check(state, label)
    report.checks += 1
    if not state then table.insert(report.failures, label) end
end
local function named(container, name)
    local found = {}
    for _, item in container and container:GetDescendants() or {} do
        if item.Name == name then table.insert(found,item) end
    end
    return found
end
local function reset()
    FX.clear()
    for _, item in workspace:GetChildren() do
        if not initial[item] then item:Destroy() end
    end
    -- Shared boundary slots retire on their scheduled cleanup even if the fixture removes parts.
    task.wait(.50)
end
local function cast(d, pulse)
    local center = d.form == "area" and origin or target
    Visual.play(actor, d.id, origin, center, pulse, {target}, nil, nil, nil, direction)
    for _, item in workspace:GetChildren() do
        if item.Name == "HeroVFX" and item:GetAttribute("SkillId") == d.id then return item end
    end
end
local function extent(strokes, center)
    local radius, height = 0, -math.huge
    for _, stroke in strokes do
        for _, attachment in {stroke.Attachment0, stroke.Attachment1} do
            local offset = attachment.WorldPosition-center
            radius = math.max(radius, Vector3.new(offset.X,0,offset.Z).Magnitude)
            height = math.max(height, offset.Y)
        end
    end
    return radius, height
end
local function bind(d)
    local copy = table.clone(d)
    copy.id = "Fixture_"..d.id
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end
local dawn = Catalog.byId["knight.paladin.dawn_spiral"].definition
local shatter = Catalog.byId["dwarf.iron_axe.shatter_blow"].definition
local trap = Catalog.byId["elf.magic_archer.vine_trap"].definition
local frost = Catalog.byId["mage.cryo.frost_ring"].definition
local floorY = floor.Position.Y+floor.Size.Y*.5

local ok, err = xpcall(function()
    check(Geometry.floor and math.abs(Geometry.floor(target,actor).Y-floorY-.12)<.02,
        "Actor bodies do not cover the ground")
    local platform = Instance.new("Part", stage)
    platform.Position,platform.Size,platform.Anchored = target-Vector3.yAxis*1.8,Vector3.new(3,.4,3),true
    check(Geometry.floor and math.abs(Geometry.floor(target,actor).Y-platform.Position.Y-.32)<.02,
        "Solid scenery is a valid effect surface")
    platform:Destroy()
    for _, compact in {false,true} do
        FX.isOtherHero = function() return compact end
        local lastReach, lastHeight = 0, -math.huge
        for pulse=1,dawn.pulses do
            local model = cast(dawn,pulse)
            local beams = named(model,"DawnSpiralSweep")
            local reach, height = extent(beams,origin)
            check(#beams==(compact and 6 or 10) and reach>lastReach+.4 and height>lastHeight+.27,
                "Dawn Spiral increases reach and lift on each of three beats")
            check(reach<=dawn.range and #named(workspace,"SkillSector")==(compact and 12 or 24),
                "Dawn Spiral keeps the server range boundary")
            check(#named(model,"DawnSeal")==0 and #named(workspace,"ElementalWave")==0,
                "Dawn Spiral uses one spiral and one boundary")
            lastReach,lastHeight = reach,height
            reset()
        end

        local model = cast(shatter,1)
        local cracks = named(model,"ShatterBlowCrack")
        local early = extent(cracks,target)
        local now = workspace:GetServerTimeNow()
        FX.step(now+.15)
        local reach, height = extent(cracks,target)
        check(#cracks==9 and reach>early+.8 and reach<shatter.radius and height+target.Y<floorY+.35,
            "Shatter Blow fractures outward along the floor at the packet center")
        check(#named(model,"ShatterBlowSlab")==(compact and 2 or 3) and #named(model,"GroundPressure")==0,
            "Shatter Blow replaces the generic pressure ring with staggered rock slabs")
        check(#named(workspace,"ImpactBoundary")==(compact and 12 or 24),
            "Shatter Blow preserves the confirmed ground radius")
        for _, edge in named(workspace,"ImpactBoundary") do
            check(math.abs(edge.Position.Y-floorY-.08)<.02, "The ground boundary stays below collider bodies")
        end
        reset()

        local firstRoot
        for pulse=1,trap.pulses do
            local model = cast(trap,pulse)
            local seed = named(model,"VineTrapSeed")
            check(#seed==(pulse==1 and (compact and 3 or 4) or 0), "Vine Trap plants once")
            if #seed>0 then
                local start = seed[1].Attachment0.WorldPosition
                local ending = seed[#seed].Attachment1.WorldPosition
                check((start-tip.WorldPosition).Magnitude<.03 and (ending-target).Magnitude<3.2
                    and math.abs(ending.Y-floorY)<.4, "The seed connects the bow socket to the locked ground center")
                FX.step(workspace:GetServerTimeNow()+.14)
                check(seed[1].Transparency.Keypoints[1].Value==1, "The seed trail clears before later pulses")
            end
            local stems = named(model,"RootAscendingTip")
            check(#stems==(compact and 2 or 3) and #named(model,"VineTrapLoop")==0,
                "The trap snaps grounded roots inward")
            if stems[1] then
                if pulse==1 then firstRoot=stems[1].Position end
                if pulse==3 and firstRoot then
                    check((stems[1].Position-firstRoot).Magnitude>1, "The final trap pulse changes bearing")
                end
            end
            reset()
        end

        local modelFrost = cast(frost,1)
        local fronts = named(modelFrost,"FrostRingFront")
        local start = extent(fronts,origin)
        FX.step(workspace:GetServerTimeNow()+.12)
        local finish, crest = extent(fronts,origin)
        check(#fronts==(compact and 8 or 12) and finish>start+frost.range*.25 and finish<frost.range,
            "Frost Ring fronts expand before the outer ice finishes growing")
        check(crest+origin.Y<floorY+.65 and #named(modelFrost,"FrostRimFacet")==(compact and 4 or 8),
            "Ice stays low and the compact cast keeps separated rim facets")
        check(#named(modelFrost,"FrostBloom")==0 and #named(workspace,"SkillSector")>0,
            "Frost Ring uses open fronts and retains the range boundary")
        reset()
    end

    FX.isOtherHero = function() return true end
    for _, d in {dawn,shatter,trap,frost} do
        local count = 0
        while FX.skill(actor,d.id,origin,target,1,{},tip.WorldPosition,direction) do count+=1 end
        Visual.play(actor,d.id,origin,d.form=="area" and origin or target,1,{},nil,nil,nil,direction)
        check(count>=4 and FX.count()==count
            and #named(workspace,d.form=="area" and "SkillSector" or "ImpactBoundary")>0,
            d.id.." keeps its confirmed boundary when the primary budget fills")
        reset()
    end

    local plainDawn, plainShatter, plainFrost = bind(dawn), bind(shatter), bind(frost)
    for _, rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
        for pulse=1,3 do
            local age = dawn.windup+(pulse-1)*dawn.interval+.047
            local pose, plain = Melee.sample("knight",dawn,age,rig), Melee.sample("knight",plainDawn,age,rig)
            check(pose.angles.leftKnee.X>plain.angles.leftKnee.X+14
                and pose.angles.right.X>=plain.angles.right.X+(pulse-1)*18, "Paladin banks and lifts each cut "..rig.Name)
        end
        local age = shatter.windup+.16
        local pose, plain = Melee.sample("dwarf",shatter,age,rig), Melee.sample("dwarf",plainShatter,age,rig)
        check(pose.angles.elbow.X<plain.angles.elbow.X-19, "Dwarf checks the axe rebound "..rig.Name)
    end
    local mageProfile = Mage.profile(frost)
    local magePose = Mage.sample(frost,mageProfile,frost.windup+.062)
    local magePlain = Mage.sample(plainFrost,mageProfile,frost.windup+.062)
    check((magePose.angles.left-magePlain.angles.left).Magnitude>25 and magePose.angles.leftKnee.X>magePlain.angles.leftKnee.X+12,
        "Mage drives the release through the palm and front leg")

    actor:SetAttribute("K0ClassId","elf")
    actor:SetAttribute("K0SkillId",trap.id)
    actor:SetAttribute("K0State","Attack")
    actor:SetAttribute("K0AttackSeq",31)
    actor:SetAttribute("K0AttackStartedAt",100)
    actor:SetAttribute("K0ArrowReleaseProtocol",1)
    local at = 100+trap.windup
    local held = Bow.forCharacter(actor,at+.02)
    check(held.nocked and held.ikWeight==1 and held.aimPitch<=12.01, "Trap holds its low nock until server confirmation")
    Bow.confirmPulse(actor,trap.id,1,31,at,100,at+.02)
    local placed = Bow.forCharacter(actor,at+.05)
    check(not placed.nocked and placed.time>.8, "The first confirmation releases the trap")
    for pulse=2,trap.pulses do
        local beat = at+(pulse-1)*trap.interval
        local ready = Bow.forCharacter(actor,beat-.06)
        Bow.confirmPulse(actor,trap.id,pulse,31,beat,100,beat+.02)
        local after = Bow.forCharacter(actor,beat+.05)
        check(not ready.nocked and not after.nocked and after.ikWeight==0 and after.aimPitch<.1,
            "Trap ticks leave the bow at rest")
    end
end,debug.traceback)

FX.isOtherHero = compactBefore
camera.CFrame = cameraBefore
reset()
stage:Destroy()
if not ok then table.insert(report.failures,err) end
print("HERO_GROUND_BEATS "..game.HttpService:JSONEncode(report))
return report
