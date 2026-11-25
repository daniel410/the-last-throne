-- Verify authored releases through the client entry points in an isolated Studio Place.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Appearance = require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local nativeVisual = Client.K0SwordVisual:Clone()
nativeVisual.Source = nativeVisual.Source:gsub("return Visual%s*$", "Visual.advanceQA = advanceSpells\nreturn Visual")
nativeVisual.Parent = Client
local Flight = require(nativeVisual)

local sword = Catalog.byId["knight.paladin.oathbreaker_strike"].definition
local gun = Catalog.byId["dwarf.gunner.gunner_shot"].definition
local spark = Catalog.byId["elf.magic_archer.spark_volley"].definition
local mana = Catalog.byId["mage.common.mana_bolt"].definition
local origin = Vector3.new(0, 748, 0)
local forward = -Vector3.zAxis
local camera = workspace.CurrentCamera
local previousCamera, previousCompact = camera.CFrame, FX.isOtherHero
local stage = Instance.new("Folder", workspace)
local original = {}
for _, node in workspace:GetChildren() do original[node] = true end
local results = {checks=0, failures={}, budgets={}}

local function check(condition, label)
    results.checks += 1
    if not condition then table.insert(results.failures, label) end
end

local function part(parent, name, at, size, cover)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Size = name, at, size or Vector3.one
    p.Anchored, p.CanCollide, p.CanQuery = true, cover == true, cover == true
    p.Parent = parent
    return p
end

local function actorAt(at)
    local actor = Instance.new("Model", stage)
    part(actor, "HumanoidRootPart", at)
    return actor
end

local function model(id, pulse)
    for _, node in workspace:GetChildren() do
        if node.Name == "HeroVFX" and node:GetAttribute("SkillId") == id
            and node:GetAttribute("Pulse") == (pulse or 1) then
            return node
        end
    end
end

local function find(node, name)
    local found = {}
    if node then
        for _, child in node:GetDescendants() do
            if child.Name == name then table.insert(found, child) end
        end
    end
    return found
end

local function clearEffects()
    FX.clear()
    for _, node in workspace:GetChildren() do
        if not original[node] and node:IsA("BasePart") then node:Destroy() end
    end
end

local function serverProjectile(d, actor, pulse)
    local state = {character=actor, root=actor.HumanoidRootPart}
    local cast = Combat.snapshot(state, d, forward, nil, {})
    local endpoint
    Combat.resolve(state, {definition=d, direction=forward, advancedCast=cast}, workspace:GetServerTimeNow(), {
        enemies={},
        visual=function(_, _, _, point) endpoint=point end,
    }, pulse)
    return endpoint
end

local function near(a, b) return (a-b).Magnitude < .025 end

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(origin + Vector3.new(8, 8, 13), origin + forward*4)
    part(stage, "Floor", origin-Vector3.yAxis*3.1, Vector3.new(45, 1, 45), true)
    local swordActor, gunActor, bowActor = actorAt(origin), actorAt(origin), actorAt(origin)
    local prop = Instance.new("Model", gunActor)
    prop.Name = "BranchSkillProp"
    local barrel = part(prop, "Barrel", origin + Vector3.new(-.8, .25, -1.2))
    local muzzle = Instance.new("Attachment", barrel)
    muzzle.Name = "SkillMuzzle"
    local nock = part(bowActor, "NockedArrow", origin + Vector3.new(.6, .34, -.86))

    for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
        local guard = Melee.sample("knight", sword, sword.windup*.55, rig)
        local cut = Melee.sample("knight", sword, sword.windup+.055, rig)
        check(guard.angles.leftElbow.X-cut.angles.leftElbow.X > 15, rig.Name.." opens the shield into the cut")
        local aim = Melee.sample("dwarf", gun, gun.windup*.55, rig)
        local kick = Melee.sample("dwarf", gun, gun.windup+.041, rig)
        local settle = Melee.sample("dwarf", gun, gun.windup+.118, rig)
        check(aim.offhand and kick.offhand and settle.offhand, rig.Name.." uses the left-hand gun")
        check(kick.angles.left.X-settle.angles.left.X > 26, rig.Name.." recovers from one offhand recoil")
    end
    local first, last = {angles={}}, {angles={}}
    Bow.bow(first, spark, spark.windup+.035, .035, true, 1)
    Bow.bow(last, spark, spark.windup+2*spark.interval+.035, .035, false, 3)
    check(last.angles.leftKnee.X-first.angles.leftKnee.X>14, "Third arrow plants the lead knee")
    local gathered = Mage.sample(mana, Mage.profile(mana), mana.windup*.57)
    local cast = Mage.sample(mana, Mage.profile(mana), mana.windup+.065)
    check(gathered.angles.elbow.X-cast.angles.elbow.X>12, "Staff elbow closes during preparation and punches out at release")

    local wall = part(stage, "Cover", origin+forward*7, Vector3.new(8, 7, .5), true)
    local gunEnd = serverProjectile(gun,gunActor,1)
    local bowEnd = serverProjectile(spark,bowActor,1)
    check(gunEnd and bowEnd and near(gunEnd,bowEnd) and (gunEnd-origin).Magnitude<7, "Server clips both projectile paths")
    for _, compact in {false,true} do
        FX.isOtherHero = function() return compact end
        Visual.play(swordActor,sword.id,origin,origin+forward*3.8,1,{},nil,nil,nil,forward)
        Visual.play(gunActor,gun.id,origin,gunEnd,1,{})
        Visual.play(bowActor,spark.id,origin,bowEnd,1,{})
        FX.skill(swordActor,mana.id,gunEnd,gunEnd,1,nil,nil,forward)
        local cut = find(model(sword.id),"OathbreakerEdge")
        check(#cut==(compact and 4 or 6),"Oathbreaker uses a single descending edge")
        if #cut>1 then
            local top, bottom = cut[1].Attachment0.WorldPosition, cut[#cut].Attachment1.WorldPosition
            check(top.Y-bottom.Y>3.8 and (bottom-origin):Dot(forward)>1,"Cut drops from above the shoulder into the front sector")
        end
        check(#find(workspace,"BladeCrescent")==0,"No duplicate generic cut")
        local tracer = find(model(gun.id),"GunnerShotTracer")[1]
        if tracer then
            check(near(tracer.Attachment0.WorldPosition,muzzle.WorldPosition)
                and near(tracer.Attachment1.WorldPosition,gunEnd),"Gunner tracer reaches the wall from the left-hand muzzle")
        else
            check(false, "Gunner supplies one primary tracer")
        end
        check(#find(model(gun.id),"GunnerShotMuzzle")==(compact and 0 or 1),"Only the firing player gets the muzzle flash")
        check(#find(workspace,"RifleTracer")==0 and #find(workspace,"CompactMuzzleFlash")==0,"No duplicate rifle layer")
        local arrowWake = find(model(spark.id),"SparkVolleyWake")[1]
        check(arrowWake and near(arrowWake.Attachment0.WorldPosition,nock.Position)
            and near(arrowWake.Attachment1.WorldPosition,bowEnd),"Spark leaves the nock and stops at cover")
        check(#find(model(spark.id),"SparkVolleyFork")==2 and #find(workspace,"ArrowWake")==0,"Spark retains one fork and one trail")
        check(#find(workspace,"ArrowShaft")==1,"Missing TD arrow still renders one bounded arrow")
        local terminal = model(mana.id)
        check(#find(terminal,"ManaBoltEdge")==2 and #find(terminal,"ManaBoltWake")==0,"Mana arrival breaks only at the endpoint")
        local _,beams,_,glows,particles,faces = FX.count()
        results.budgets[compact and "ally" or "self"]={beams=beams,glows=glows,particles=particles,faces=faces}
        clearEffects()
    end

    FX.isOtherHero = function() return false end
    local seq = 5
    local now = workspace:GetServerTimeNow()
    Visual.play(bowActor,spark.id,origin,bowEnd,1,{},seq,now)
    Visual.play(bowActor,spark.id,origin,bowEnd,2,{},seq,now)
    Visual.play(bowActor,spark.id,origin,bowEnd,3,{},seq,now)
    Visual.play(bowActor,spark.id,origin,bowEnd,2,{},seq,now)
    local wires1 = find(model(spark.id,1),"SparkVolleyFork")
    local wires2 = find(model(spark.id,2),"SparkVolleyFork")
    if #wires1>0 and #wires2>0 then
        check(wires1[1].Attachment1.WorldPosition.X-wires2[1].Attachment1.WorldPosition.X>.55,
            "Second shot banks its spark opposite the first")
    else
        check(false, "First and second shots both have a fork")
    end
    check(FX.count()==3 and #find(model(spark.id,3),"SparkVolleyTip")==1,
        "Three distinct confirmed pulses, no duplicate and one finisher tip")
    clearEffects()

    wall.Position = origin+forward*.95
    local close = serverProjectile(gun,gunActor,1)
    Visual.play(gunActor,gun.id,origin,close,1,{})
    local tracer = find(model(gun.id),"GunnerShotTracer")[1]
    check(tracer and near(tracer.Attachment0.WorldPosition,origin) and near(tracer.Attachment1.WorldPosition,close),
        "Point-blank cover switches to the server origin when it sits before the muzzle")
    clearEffects()

    local description = Instance.new("HumanoidDescription")
    local mage = game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
    description:Destroy()
    mage.Parent=stage
    mage:PivotTo(CFrame.lookAt(origin,origin+forward))
    mage:SetAttribute("K0ClassId","mage")
    mage:SetAttribute("K0SkillId",mana.id)
    mage:SetAttribute("K0State","Idle")
    assert(Appearance.attachInto(Instance.new("Model",mage),mage,"mage"))
    local endpoint = origin+forward*8
    mage:SetAttribute("K0SpellVisual",string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f",
        origin.X,origin.Y,origin.Z,endpoint.X,endpoint.Y,endpoint.Z))
    Flight.renderCharacter(mage,1/60)
    local bolt = workspace:FindFirstChild("K0VisualSpell")
    check(bolt and bolt.Shape==Enum.PartType.Block and bolt.Material==Enum.Material.Neon and bolt.Size.Z>1,
        "Mana Bolt uses a solid rolling crystal in flight")
    check(bolt and not bolt:FindFirstChildOfClass("PointLight"),"The crystal lights itself without a movable glow")
    if bolt then
        local initial = bolt.CFrame
        Flight.advanceQA(.06)
        check(bolt.Parent and not near(bolt.CFrame.RightVector,initial.RightVector),"Crystal rolls along the flight path")
        Flight.advanceQA(.08)
        if bolt.Parent then
            local tip = bolt.CFrame:PointToWorldSpace(Vector3.new(0,0,-bolt.Size.Z*.5))
            check((tip-endpoint):Dot(forward)<0 and (tip-origin):Dot(forward)>5,"Leading point stays short of the confirmed stop before arrival")
        end
    end
    Flight.advanceQA(.10)
    check(not bolt or not bolt.Parent,"Flight cleans up after arrival")
    local burst = model(mana.id)
    check(burst and near(burst.VFXCarrier.Position,endpoint) and #find(burst,"ManaBoltEdge")==2,
        "Normal projectile arrival creates one short burst at the server stop")
end,debug.traceback)
clearEffects()
stage:Destroy()
nativeVisual:Destroy()
camera.CFrame, FX.isOtherHero = previousCamera, previousCompact
if not ok then table.insert(results.failures,err) end
results.pass = #results.failures==0
print("HERO_WEAPON_RELEASES_NATIVE "..game.HttpService:JSONEncode(results))
assert(results.pass,"Hero weapon release regression")
