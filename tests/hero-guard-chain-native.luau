assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)

local guardian = Catalog.byId["knight.steel_knight.guardian_counter"].definition
local rifle = Catalog.byId["dwarf.gunner.piercing_round"].definition
local roots = Catalog.byId["elf.magic_archer.rooting_fan"].definition
local chain = Catalog.byId["mage.cryo.chain_lightning"].definition
local origin = Vector3.new(0, 741, 0)
local forward = -Vector3.zAxis
local camera = workspace.CurrentCamera
local oldCamera, oldCompact = camera.CFrame, FX.isOtherHero
local original = {}
for _, item in workspace:GetChildren() do original[item] = true end
local report = {checks=0, failures={}, budget={}}
local function check(value, text)
    report.checks += 1
    if not value then table.insert(report.failures,text) end
end
local function find(parent, name)
    local found = {}
    for _, item in parent:GetDescendants() do
        if item.Name == name then table.insert(found,item) end
    end
    return found
end
local function part(parent, name, position, size, collidable)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Size = name, position, size or Vector3.one
    p.Anchored, p.CanCollide, p.CanQuery = true, collidable == true, collidable == true
    p.Parent = parent
    return p
end
local function model(id)
    for _, item in workspace:GetChildren() do
        if item.Name == "HeroVFX" and item:GetAttribute("SkillId") == id then return item end
    end
end
local function resolve(definition, actor)
    local state = {character=actor,root=actor.HumanoidRootPart}
    local snapshot = Combat.snapshot(state,definition,forward,nil,{})
    local attack = {definition=definition,direction=forward,advancedCast=snapshot}
    local center, lanes
    Combat.resolve(state,attack,workspace:GetServerTimeNow(),{
        enemies={},
        visual=function(_,_,_,point,_,_,_,endpoints) center,lanes=point,endpoints end,
    },1)
    return center,lanes
end
local function near(a,b) return (a-b).Magnitude < .02 end

local ok, err = xpcall(function()
    for _, rig in Enum.HumanoidRigType:GetEnumItems() do
        local ready = Melee.sample("knight",guardian,guardian.windup*.58,rig)
        local swing = Melee.sample("knight",guardian,guardian.windup+.055,rig)
        check(ready.angles.leftElbow.X-swing.angles.leftElbow.X>25,rig.Name.." counter retracts its shield")
        local kick = Melee.sample("dwarf",rifle,rifle.windup+.04,rig)
        local lower = Melee.sample("dwarf",rifle,rifle.windup+.11,rig)
        check(kick.offhand and lower.offhand,rig.Name.." rifle remains equipped in the off hand")
        check(kick.angles.left.X-lower.angles.left.X>23,rig.Name.." rifle lowers after firing")
    end
    local draw, sweep = {angles={}},{angles={}}
    Bow.bow(draw,roots,roots.windup*.54,nil,false,0)
    Bow.bow(sweep,roots,roots.windup+.096,.096,false,1)
    check(sweep.angles.torso.X>7 and sweep.angles.leftKnee.X>18,"rooting release follows through over the lead foot")
    local wind = Mage.sample(chain,Mage.profile(chain),chain.windup*.53)
    local cast = Mage.sample(chain,Mage.profile(chain),chain.windup+.062)
    check(cast.angles.leftElbow.X-wind.angles.leftElbow.X>45,"chain closes and extends the free elbow")

    local stage = Instance.new("Folder",workspace)
    local actor = Instance.new("Model",stage)
    local root = part(actor,"HumanoidRootPart",origin)
    part(stage,"Ground",origin-Vector3.yAxis*3.2,Vector3.new(100,1,100),true)
    local prop = Instance.new("Model",actor)
    prop.Name = "BranchSkillProp"
    local barrel = part(prop,"Barrel",origin+Vector3.new(-.7,.2,-1.15))
    local muzzle = Instance.new("Attachment",barrel)
    muzzle.Name = "SkillMuzzle"
    camera.CFrame = CFrame.lookAt(origin+Vector3.new(11,11,16),origin+forward*7)
    local wall = part(stage,"Cover",origin+forward*5,Vector3.new(2.25,6,.7),true)
    local stop = resolve(rifle,actor)
    local center, lanes = resolve(roots,actor)
    check(stop and (stop-origin).Magnitude < 5,"server stops the rifle in front of cover")
    check(lanes and #lanes==5 and (lanes[3]-origin).Magnitude < 5 and
        (lanes[1]-origin).Magnitude > 10,"server sends independently clipped root lanes")
    local nearWall = part(stage,"NearCover",origin+forward*.80,Vector3.new(4,6,.30),true)
    local closeStop = resolve(rifle,actor)
    nearWall:Destroy()
    check(closeStop and (closeStop-origin).Magnitude<(barrel.Position-origin):Dot(forward),"test cover intersects before the barrel")

    for _, compact in {false,true} do
        FX.isOtherHero = function() return compact end
        Visual.play(actor,guardian.id,origin,origin+forward*4,1,{},nil,nil,nil,forward)
        local guard = assert(model(guardian.id))
        local edge, shield = find(guard,"GuardianCounterEdge"), find(guard,"GuardianCounterGuard")
        check(#edge==(compact and 4 or 6) and #shield==2,"counter has one rising cut and a brief shield edge")
        check(#find(workspace,"ShieldContact")==0,"counter avoids stacking the legacy shield plate")
        if #edge>0 then
            check(edge[#edge].Attachment1.WorldPosition.Y-edge[1].Attachment0.WorldPosition.Y>2.4,
                "counter cut climbs from hip to shoulder height")
        end

        Visual.play(actor,rifle.id,origin,stop,1,{})
        local round = assert(model(rifle.id))
        local tracer = find(round,"PiercingRoundTracer")[1]
        check(#find(round,"PiercingRoundTracer")==1 and #find(round,"PiercingRoundMuzzle")==(compact and 0 or 1),
            "rifle has a single tracer and a local muzzle accent")
        check(#find(workspace,"RifleTracer")==0,"rifle avoids a second legacy tracer")
        if tracer then
            check(near(tracer.Attachment0.WorldPosition,muzzle.WorldPosition)
                and near(tracer.Attachment1.WorldPosition,stop),"rifle starts at the muzzle and ends at the server wall stop")
        end

        local now = workspace:GetServerTimeNow()
        Visual.play(actor,roots.id,origin,center,1,{},nil,nil,nil,forward,nil,nil,lanes)
        local fan = assert(model(roots.id))
        local runners = find(fan,"RootingFanRunner")
        local groupSize = compact and 3 or 5
        check(#runners==groupSize*2,"rooting fan has two growing spans per visible lane")
        if #runners==groupSize*2 and lanes then
            local leadIndex=2*math.ceil(groupSize/2)
            check(not runners[leadIndex].Enabled,"second root span waits for the first")
            FX.step(now+.108)
            check(runners[leadIndex].Enabled and (runners[leadIndex].Attachment1.WorldPosition-origin):Dot(forward)<5,
                "center root rises before cover")
            check((runners[2].Attachment1.WorldPosition-origin).Magnitude>10,"open outer root keeps its reach")
        end

        local targets = {origin+Vector3.new(0,0,-7), origin+Vector3.new(4,1,-11),
            origin+Vector3.new(-1,0,-14), origin+Vector3.new(3,0,-18)}
        now = workspace:GetServerTimeNow()
        Visual.play(actor,chain.id,origin,origin+forward*chain.range,1,targets)
        local electric = assert(model(chain.id))
        local arcs = find(electric,"ElectricCore")
        local segments = compact and 4 or 6
        check(electric:GetAttribute("ChainCore") and #arcs==4*segments,"each server target has a complete arc")
        if #arcs==4*segments then
            check(arcs[1].Enabled and not arcs[segments+1].Enabled,"the first connection lights before the second")
            FX.step(now+.046)
            check(arcs[segments+1].Enabled and arcs[2*segments+1].Enabled and not arcs[3*segments+1].Enabled,
                "chain advances in server order")
            FX.step(now+.079)
            for hop,to in targets do
                check(arcs[hop*segments].Enabled and near(arcs[hop*segments].Attachment1.WorldPosition,to),
                    "confirmed arc reaches target "..hop)
            end
        end
        check(#find(electric,"LightningSurface")==0 and #find(electric,"SoftGlow")==0,
            "staggered chain uses a single set of world strokes")
        check(#find(electric,"ReflectedFlash")==0 and #find(electric,"ElementalSparks")==0,
            "chain skips generic muzzle flash and particles")
        local _,beams,_,glows,particles,faces = FX.count()
        report.budget[compact and "ally" or "self"]={beams=beams,glows=glows,particles=particles,faces=faces}
        FX.clear()
        for _, item in workspace:GetChildren() do
            if item:IsA("BasePart") and not original[item] then item:Destroy() end
        end

        local close = FX.skill(actor,rifle.id,origin,closeStop,1,{},muzzle.WorldPosition)
        local closeTracer = find(assert(close),"PiercingRoundTracer")[1]
        check(closeTracer and near(closeTracer.Attachment0.WorldPosition,root.Position)
            and near(closeTracer.Attachment1.WorldPosition,closeStop),"point-blank cover clips the visible rifle line safely")
        FX.clear()
        local empty = FX.skill(actor,chain.id,origin,origin+forward*chain.range,1,{})
        check(empty and #find(empty,"ElectricCore")==0,"empty chain casts draw no invented connection")
        FX.clear()
    end
end,debug.traceback)
FX.clear()
FX.isOtherHero, camera.CFrame = oldCompact, oldCamera
for _, item in workspace:GetChildren() do
    if not original[item] then item:Destroy() end
end
if not ok then table.insert(report.failures,err) end
report.pass = #report.failures==0
print("HERO_GUARD_CHAIN_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass, "Guard and chain presentation checks failed")
