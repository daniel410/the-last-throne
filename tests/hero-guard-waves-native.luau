-- Run the four attacks through the shipped renderer in an isolated Studio Place.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Motion = require(Client.AdvancedSkillMotion)
local Poses = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local ids = {
    "knight.paladin.radiant_sweep",
    "dwarf.iron_axe.tremor_guard",
    "elf.magic_archer.warden_arrow",
    "mage.pyro.searing_ward",
}
local origin, aim = Vector3.new(0, 742, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local oldCamera, oldCompact = camera.CFrame, FX.isOtherHero
local stage = Instance.new("Folder", workspace)
local original = {}
for _, node in workspace:GetChildren() do original[node] = true end
local result = {checks=0, failures={}, counts={}}

local function check(pass, label)
    result.checks += 1
    if not pass then table.insert(result.failures, label) end
end

local function part(parent, name, at, size, collidable)
    local node = Instance.new("Part")
    node.Name, node.Position, node.Size = name, at, size or Vector3.one
    node.Anchored, node.CanCollide, node.CanQuery = true, collidable == true, collidable == true
    node.Parent = parent
    return node
end

local function find(parent, name)
    local nodes = {}
    if parent then
        for _, node in parent:GetDescendants() do
            if node.Name == name then table.insert(nodes, node) end
        end
    end
    return nodes
end

local function effect(id)
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

local function resolve(archer, d)
    local state = {character=archer, root=archer.HumanoidRootPart}
    local endpoint
    Combat.resolve(state, {definition=d, direction=aim, advancedCast=Combat.snapshot(state,d,aim,nil,{})},
        workspace:GetServerTimeNow(), {enemies={}, visual=function(_,_,_,at) endpoint=at end}, 1)
    return endpoint
end

local function planarDistance(a,b)
    return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude
end

local function farthest(strokes)
    local distance = 0
    for _, edge in strokes do
        distance = math.max(distance,planarDistance(edge.Attachment1.WorldPosition,origin))
    end
    return distance
end

local function near(a,b) return (a-b).Magnitude < .025 end

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(origin+Vector3.new(12,9,16),origin+aim*3)
    local floor = part(stage,"Floor",origin-Vector3.yAxis*3.1,Vector3.new(50,1,50),true)
    local wall = part(stage,"Cover",origin+aim*8,Vector3.new(8,6,.6),true)
    local actors = {}
    for i in ids do
        local model = Instance.new("Model",stage)
        part(model,"HumanoidRootPart",origin)
        table.insert(actors,model)
    end
    local nock = part(actors[3],"NockedArrow",origin+Vector3.new(.67,.39,-1.32))
    local knight, dwarf, elf, mage = table.unpack(ids)
    local arrow = Catalog.byId[elf].definition
    local endpoint = resolve(actors[3],arrow)
    check(endpoint and near(endpoint,origin+aim*7.5), "Server stop includes the published cover clearance")
    assert(endpoint, "Projectile must provide a confirmed endpoint")
    local gold = Catalog.byId[knight].definition
    local tremor = Catalog.byId[dwarf].definition
    local searing = Catalog.byId[mage].definition

    for _, compact in {false,true} do
        FX.isOtherHero = function() return compact end
        for i,id in ids do
            local point = i == 1 and origin+aim*5 or i == 3 and endpoint or origin
            Visual.play(actors[i],id,origin,point,1,{},nil,nil,nil,aim)
        end
        local radiant = find(effect(knight),"RadiantOpeningFan")
        local fault = find(effect(dwarf),"TremorGuardFault")
        local heat = find(effect(mage),"SearingWardFront")
        local wake = find(effect(elf),"WardenArrowStem")[1]
        check(#radiant == (compact and 5 or 7), "Radiant Sweep uses one rising edge")
        check(#radiant>0 and radiant[#radiant].Attachment1.WorldPosition.Y-radiant[1].Attachment0.WorldPosition.Y>2,
            "Radiant Sweep rises from the hip into its follow-through")
        for _, edge in radiant do
            local delta = edge.Attachment1.WorldPosition-origin
            check(delta:Dot(aim)>0 and planarDistance(edge.Attachment1.WorldPosition,origin)<gold.range,
                "Radiant Sweep stays within its forward reach")
        end
        check(#fault == 6 and #find(effect(dwarf),"TremorGuardStrike")==2, "Tremor has a strike and two opening fault fronts")
        check(#heat == (compact and 6 or 8), "Searing Ward has two low flame fronts")
        check(#find(effect(mage),"SearingWardEmber")== (compact and 0 or 2), "Only the local caster gets secondary embers")
        check(#find(effect(dwarf),"TremorGuardSlate")== (compact and 0 or 2), "Only the local caster gets ground debris")
        check(wake and near(wake.Attachment0.WorldPosition,nock.Position)
            and near(wake.Attachment1.WorldPosition,endpoint), "Warden trail joins the nock to confirmed cover")
        check(#find(effect(elf),"WardenArrowVein")==2, "An arrow carries one pair of green vanes")
        check(#find(workspace,"ArrowShaft")==1 and #find(workspace,"ArrowWake")==0, "Keep one bounded shaft and one wake")
        check(#find(workspace,"BladeCrescent")==0 and #find(workspace,"SkillSector")>0, "Keep the range cue beside the authored blade")
        check(#find(workspace,"FlameTongue")==0 and #find(workspace,"SearingWardDome")==0, "Release does not mask a shield grant or target with tall effects")
        local beforeFault, beforeHeat = farthest(fault), farthest(heat)
        FX.step(workspace:GetServerTimeNow()+.13)
        local afterFault, afterHeat = farthest(fault), farthest(heat)
        check(afterFault-beforeFault>2 and afterFault<tremor.range, "Fault spreads inside the resolved radius")
        check(afterHeat-beforeHeat>2 and afterHeat<searing.range, "Flame front spreads inside the resolved radius")
        for _, edge in heat do
            check(edge.Attachment1.WorldPosition.Y < floor.Position.Y+floor.Size.Y*.5+.95, "Heat stays close to the floor")
        end
        local active, beams, _, glows, particles, surfaces = FX.count()
        result.counts[compact and "ally" or "self"] = {active=active,beams=beams,glows=glows,particles=particles,surfaces=surfaces}
        check(active==4 and glows==0 and particles==0, "All four attacks fit without secondary glow or particles")
        clear()
    end

    FX.isOtherHero = function() return false end
    wall.Position = origin+aim*1
    local close = assert(resolve(actors[3],arrow))
    Visual.play(actors[3],elf,origin,close,1,{})
    local wake = find(effect(elf),"WardenArrowStem")[1]
    check(wake and near(wake.Attachment0.WorldPosition,origin) and near(wake.Attachment1.WorldPosition,close),
        "Close cover uses the server origin before the visible nock")
    clear()

    local now = workspace:GetServerTimeNow()
    Visual.play(actors[4],mage,origin,origin,0,{},1,nil,now,aim,{})
    check(#find(workspace,"HeroShieldGrant")==0 and not effect(mage), "Empty server recipients do not create a shield or early attack")
    Visual.play(actors[4],mage,origin,origin,0,{},2,nil,now,aim,{actors[4]})
    check(#find(workspace,"HeroShieldGrant")==1 and not effect(mage), "Confirmed grant displays independently before attack")
    Visual.play(actors[4],mage,origin,origin,1,{},2,now,now,aim)
    Visual.play(actors[4],mage,origin,origin,1,{},2,now,now,aim)
    check(#find(workspace,"SearingWardFront")==8 and #find(workspace,"HeroShieldGrant")==1,
        "A repeated pulse cannot duplicate either presentation")
    clear()
    check(FX.count()==0 and select(2,FX.count())==0 and select(6,FX.count())==0, "Release budgets return to zero")

    -- Let the secondary presentation pool release its prior boundary and arrow slots.
    task.wait(.45)
    for _=1,12 do FX.skill(actors[1],knight,origin,origin+aim*5,1,nil,nil,aim) end
    Visual.play(actors[3],elf,origin,endpoint,1,{})
    Visual.play(actors[4],mage,origin,origin,1,{})
    check(not effect(elf) and #find(workspace,"ArrowWake")==1, "Budget fallback still shows the confirmed arrow")
    check(not effect(mage) and #find(workspace,"SkillSector")>0, "Budget fallback keeps the area boundary")
    clear()

    for _, rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
        local load = Motion.sample("knight",gold,gold.windup*.56,rig)
        local swing = Motion.sample("knight",gold,gold.windup+.061,rig)
        check(load.angles.torso.X-swing.angles.torso.X>15,rig.Name.." rises through the gold sweep")
        local strike = Motion.sample("dwarf",tremor,tremor.windup+.050,rig)
        local lift = Motion.sample("dwarf",tremor,tremor.windup+.147,rig)
        check(strike.angles.torso.X-lift.angles.torso.X>12,rig.Name.." releases the braced ground strike")
    end
    local archerLaunch, archerRecover = {angles={}}, {angles={}}
    Poses.bow(archerLaunch,arrow,arrow.windup+.025,.025,false,1)
    Poses.bow(archerRecover,arrow,arrow.windup+.126,.126,false,1)
    check(archerLaunch.angles.elbow.X-archerRecover.angles.elbow.X>19, "Bow draw hand folds after the arrow leaves")
    local ward = Mage.profile(searing)
    local gather = Mage.sample(searing,ward,searing.windup*.58)
    local release = Mage.sample(searing,ward,searing.windup+.061)
    local rawGather = Mage.raw(ward,gather.time)
    local rawRelease = Mage.raw(ward,release.time)
    local open = (release.angles.leftElbow.X-rawRelease.angles.leftElbow.X)
        - (gather.angles.leftElbow.X-rawGather.angles.leftElbow.X)
    check(open>60, "Searing Ward articulates the guiding elbow beyond the original clip")
end, debug.traceback)
clear()
stage:Destroy()
camera.CFrame, FX.isOtherHero = oldCamera, oldCompact
if not ok then table.insert(result.failures,err) end
result.pass = #result.failures==0
print("HERO_GUARD_WAVES_NATIVE "..game.HttpService:JSONEncode(result))
assert(result.pass,table.concat(result.failures,"\n"))
