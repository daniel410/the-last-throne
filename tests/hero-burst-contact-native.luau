assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Hits = require(Client.K0HitEffects)

local dawn = Catalog.byId["knight.paladin.dawn_burst"].definition
local shell = Catalog.byId["dwarf.gunner.shell_burst"].definition
local bloom = Catalog.byId["elf.magic_archer.bloom_shot"].definition
local ice = Catalog.byId["mage.cryo.ice_shard"].definition
local at, aim = Vector3.new(0, 736, 0), -Vector3.zAxis
local target = at + aim*8
local camera = workspace.CurrentCamera
local oldCamera = camera.CFrame
camera.CFrame = CFrame.lookAt(at+Vector3.new(10,12,15),target)
local oldCompact = FX.isOtherHero
local report = {checks=0, failures={}, castBudgets={}}
local original = {}
for _, item in workspace:GetChildren() do original[item] = true end

local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end

local function part(parent, name, position, size, collide)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Size = name, position, size or Vector3.one
    p.Anchored, p.CanCollide, p.CanQuery = true, collide == true, collide == true
    p.Parent = parent
    return p
end

local function named(model, name)
    local result = {}
    for _, node in model and model:GetDescendants() or {} do
        if node.Name == name then table.insert(result, node) end
    end
    return result
end

local function castModel(id)
    for _, node in workspace:GetChildren() do
        if node.Name == "HeroVFX" and node:GetAttribute("SkillId") == id then return node end
    end
end

local function clear()
    FX.clear()
    for _, node in workspace:GetChildren() do
        if not original[node] then node:Destroy() end
    end
end

local ok, err = xpcall(function()
    for _, rig in Enum.HumanoidRigType:GetEnumItems() do
        local load = Melee.sample("knight", dawn, dawn.windup*.50, rig)
        local strike = Melee.sample("knight", dawn, dawn.windup+.047, rig)
        check(not strike.root or strike.root.LookVector:Dot(aim) > .9,
            rig.Name.." Dawn Burst stays forward through contact")
        check(load.angles.leftElbow.X - strike.angles.leftElbow.X > 15,
            rig.Name.." Dawn Burst draws the shield in during preparation")
        check(strike.angles.leftKnee.X > 27, rig.Name.." Dawn Burst plants the front knee")

        local ready = Melee.sample("dwarf", shell, shell.windup*.61, rig)
        local recoil = Melee.sample("dwarf", shell, shell.windup+.034, rig)
        local settle = Melee.sample("dwarf", shell, shell.windup+.111, rig)
        check(ready.offhand and recoil.offhand and settle.offhand, rig.Name.." Shell Burst uses the off hand")
        check(recoil.angles.leftElbow.X < settle.angles.leftElbow.X-20,
            rig.Name.." Shell Burst lowers the tube after recoil")
        check(recoil.angles.rightKnee.X > settle.angles.rightKnee.X+12,
            rig.Name.." Shell Burst braces the rear leg on contact")
    end

    local draw, release = {angles={}}, {angles={}}
    Bow.bow(draw,bloom,bloom.windup*.53,nil,false,0)
    Bow.bow(release,bloom,bloom.windup+.052,.052,false,1)
    check(release.angles.elbow.X - draw.angles.elbow.X > 56, "Bloom Shot opens the draw elbow")
    local load = Mage.sample(ice,Mage.profile(ice),ice.windup*.54)
    local cast = Mage.sample(ice,Mage.profile(ice),ice.windup+.062)
    check(cast.angles.leftElbow.X - load.angles.leftElbow.X > 42, "Ice Shard snaps the casting elbow open")

    for _, compact in {false, true} do
        FX.isOtherHero = function() return compact end
        local stage = Instance.new("Folder",workspace)
        local caster = Instance.new("Model",stage)
        local root = part(caster,"HumanoidRootPart",at)
        local palm = part(caster,"LeftHand",at + Vector3.new(-.8,.33,-1.1))
        local nock = part(caster,"NockedArrow",at + Vector3.new(.32,.72,-.86))
        local world = workspace:FindFirstChild("DeepwoodK0")
        local blockout = world and world:FindFirstChild("TerrainBlockout")
        local floor = part(blockout or stage,"BurstTestFloor",at-Vector3.yAxis*3,Vector3.new(60,1,60),true)
        local wall = part(blockout or stage,"BurstTestCover",at+aim*.55,Vector3.new(5,5,.5),true)
        local wallEnd
        local state = {character=caster,root=root}
        local snapshot = Combat.snapshot(state,ice,aim,nil,{})
        local attack = {definition=ice,direction=aim,advancedCast=snapshot}
        Combat.resolve(state,attack,workspace:GetServerTimeNow(),
            {enemies={},visual=function(_,_,_,endpoint) wallEnd=endpoint end},1)
        wall:Destroy()
        assert(wallEnd, "Server supplied no endpoint")
        check((wallEnd-at):Dot(aim) < .5, "Server clips the test projectile before the wall")

        Visual.play(caster,dawn.id,at,at,1,{},nil,nil,nil,aim)
        local dawnFX = castModel(dawn.id)
        local rays = named(dawnFX,"DawnBurstRay")
        check(#rays == (compact and 4 or 6), "Dawn Burst has one set of outward rays")
        if rays[1] then
            local pre = (rays[1].Attachment1.WorldPosition-at):Dot(aim)
            FX.step(workspace:GetServerTimeNow()+.10)
            local post = (rays[1].Attachment1.WorldPosition-at):Dot(aim)
            check(post > pre+1 and post < dawn.range, "Dawn Burst advances within the server radius")
        end
        check(workspace:FindFirstChild("SkillSector") and not workspace:FindFirstChild("ElementalWave"),
            "Dawn Burst keeps the range line without a second wave")

        local now = workspace:GetServerTimeNow()
        local landingAt = now+.15
        local round = FX.incoming(caster,shell,target,17,1,landingAt,function() return true end)
        check(#named(round,"MortarShellBody")==1, "Shell Burst has one falling metal shell")
        check(#named(round,"ShellBurstJet")==0, "Shell Burst has no early detonation")
        Visual.play(caster,shell.id,at,target,1,{},17,nil,nil,aim)
        check(not round or not round.Parent,"The shell clears at confirmed impact")
        local shellFX = castModel(shell.id)
        local jet = named(shellFX,"ShellBurstJet")
        check(#jet==1 and #named(shellFX,"ShellBurstPressure")==2,"Shell Burst reads as one upward jet and two low wings")
        check(#named(shellFX,"ShellBurstCasing")== (compact and 0 or 2),"Only the local caster sees casing")
        if jet[1] then
            local tip=jet[1].Attachment1.WorldPosition
            FX.step(workspace:GetServerTimeNow()+.075)
            local expanded=jet[1].Attachment1.WorldPosition
            check(math.abs((tip-target):Dot(aim))<.05 and expanded.Y-floor.Position.Y>4.5
                and (expanded-target):Dot(camera.CFrame.RightVector)>1.35,
                "Shell Burst rises from confirmed coordinates alongside the target")
        end
        check(workspace:FindFirstChild("ImpactBoundary") and not workspace:FindFirstChild("SkillContact"),
            "Shell Burst preserves its boundary without a second explosion")

        Visual.play(caster,bloom.id,at,target,1,{},nil,nil,nil,aim)
        local bowFX = castModel(bloom.id)
        local wake = named(bowFX,"BloomShotWake")[1]
        check(wake and (wake.Attachment0.WorldPosition-nock.Position).Magnitude<.01
            and (wake.Attachment1.WorldPosition-target).Magnitude<.01,"Bloom Shot draws one line from the nock")
        check(#named(bowFX,"BloomShotPetal")==0 and #named(bowFX,"NatureArrowLeaf")==0,
            "Bloom Shot release does not imply a mark consumption")
        local bare = FX.contact(target,"elf",bloom.id,aim,1,compact)
        local marked = FX.contact(target,"elf",bloom.id,aim,1,compact,"nature")
        local mixed = FX.contact(target,"elf",bloom.id,aim,1,compact,"nature",nil,true)
        check(#named(bare,"BloomShotPetal")==0 and #named(marked,"BloomShotPetal")== (compact and 4 or 20)
            and #named(marked,"NatureBudBreak")==2,"Only a confirmed nature spend opens petals")
        check(#named(mixed,"BloomShotPetal")>0 and #named(mixed,"PostureBreakEdge")==2,
            "Bloom Shot can show a simultaneous posture break and spend")
        local hit = Hits.show(nil,target,42,"elf","Goblin",aim,bloom.id,{attacker=caster,consumedMark="nature"})
        local feedback = workspace:FindFirstChild("K0HitEffect")
        check(hit and feedback and feedback.K0DamageNumber.Amount.Text=="42","Bloom Shot retains the damage number")

        Visual.play(caster,ice.id,at,wallEnd,1,{},nil,nil,nil,aim)
        local iceFX = castModel(ice.id)
        local frost = named(iceFX,"IceShardWake")[1]
        check(frost and (frost.Attachment0.WorldPosition-at).Magnitude<.01
            and (frost.Attachment1.WorldPosition-wallEnd).Magnitude<.01,"Ice Shard falls back before point-blank cover")
        local crystalLength = iceFX and iceFX:GetAttribute("CrystalLength")
        check(crystalLength and crystalLength <= (wallEnd-at).Magnitude+.01,
            "Ice Shard clamps the crystal to the visible path")
        if iceFX then iceFX:Destroy() end
        Visual.play(caster,ice.id,at,target,1,{},nil,nil,nil,aim)
        iceFX = castModel(ice.id)
        frost = named(iceFX,"IceShardWake")[1]
        check(frost and (frost.Attachment0.WorldPosition-palm.Position).Magnitude<.01
            and (frost.Attachment1.WorldPosition-target).Magnitude<.01,"Ice Shard connects the palm to the confirmed endpoint")
        check(#named(iceFX,"IceShardFacet")==16 and #named(iceFX,"IconCrystalEdge")==0,
            "Ice Shard renders one faceted crystal")

        local budget = {beams=0,surfaces=0,particles=0,glows=0}
        for _, effect in {dawnFX,shellFX,bowFX,iceFX} do
            for _, node in effect:GetDescendants() do
                if node:IsA("Beam") then budget.beams += 1 end
                if node.Name=="SoftGlow" then budget.glows += 1 end
                if node:IsA("BasePart") and node.Name~="VFXCarrier" then budget.surfaces += 1 end
                if node:IsA("ParticleEmitter") then budget.particles += node:GetAttribute("ReviewBurstCount") or 0 end
            end
        end
        report.castBudgets[compact and "ally" or "self"]=budget
        check(budget.glows==0 and budget.particles==0 and budget.beams<=(compact and 9 or 11),
            "Four releases stay within the Beam cap without particle or glow layers")
        floor:Destroy()
        clear()
    end
end,debug.traceback)
FX.isOtherHero = oldCompact
camera.CFrame = oldCamera
clear()
if not ok then table.insert(report.failures,err) end
report.pass=#report.failures==0
print("HERO_BURST_CONTACT_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass,"Burst/contact regression")
