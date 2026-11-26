assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local Visual = require(Client.AdvancedSkillVisual)
local FX = require(Client.HeroVFX)
local Telegraphs = require(Client.K0Telegraphs)
local Hits = require(Client.K0HitEffects)

local ids = {"knight.steel_knight.vanguard_strike", "dwarf.iron_axe.stonebound_leap",
    "elf.marksman.piercing_line", "mage.pyro.stone_lance"}
local names = {"VanguardStrikeWake", "StoneboundImpact", "PiercingLineWake", "StoneLanceWake"}
local origin, aim = Vector3.new(0, 742, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local oldCamera, oldCompact = camera.CFrame, FX.isOtherHero
local stage = Instance.new("Folder", workspace)
local original = {}
for _, node in workspace:GetChildren() do original[node] = true end
local report = {checks=0, failures={}, counts={}}
local warnings
local temporaryWorld, temporaryBlockout

local function check(ok, label)
    report.checks += 1
    if not ok then table.insert(report.failures, label) end
end

local function part(parent, name, at, size, solid)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Size = name, at, size or Vector3.one
    p.Anchored, p.CanCollide, p.CanQuery = true, solid == true, solid == true
    p.Parent = parent
    return p
end

local function byName(name, parent)
    local matches = {}
    for _, node in (parent or workspace):GetDescendants() do
        if node.Name == name then table.insert(matches, node) end
    end
    return matches
end

local function clear()
    FX.clear()
    for _, node in workspace:GetChildren() do
        if not original[node] then node:Destroy() end
    end
end

local function close(a,b)
    return (a-b).Magnitude < .025
end

local function resolve(actor, id)
    local d = Catalog.byId[id].definition
    local state = {character=actor, root=actor.HumanoidRootPart}
    local attack = {definition=d, direction=aim, advancedCast=Combat.snapshot(state,d,aim,nil,{})}
    local endpoint
    Combat.resolve(state,attack,workspace:GetServerTimeNow(),{enemies={},
        visual=function(_,_,_,center) endpoint=center end},1)
    return assert(endpoint)
end

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(origin+Vector3.new(12,9,15),origin+aim*3)
    local floor = part(stage,"Floor",origin-Vector3.yAxis*3.1,Vector3.new(60,1,60),true)
    local wall = part(stage,"Cover",origin+aim*8,Vector3.new(14,7,.6),true)
    local actors, sockets, endpoints = {},{},{}
    for i,id in ids do
        local model = Instance.new("Model",stage)
        local start = origin+Vector3.xAxis*((i-2.5)*2.5)
        part(model,"HumanoidRootPart",start)
        if i==1 then
            local grip = part(model,"WeaponGrip",start+Vector3.new(.45,.45,-2.2))
            local tip = Instance.new("Attachment",grip)
            tip.Name = "WeaponTip"
            sockets[i] = tip.WorldPosition
        elseif i==3 then sockets[i] = part(model,"NockedArrow",start+Vector3.new(.45,.35,-1.25)).Position
        elseif i==4 then sockets[i] = part(model,"LeftHand",start+Vector3.new(-.52,-.23,-1.1)).Position end
        actors[i] = model
        endpoints[i] = resolve(model,id)
        check(close(endpoints[i],i==2 and start or start+aim*7.5),id.." uses the resolved center")
    end

    local function playFour()
        for i,id in ids do
            Visual.play(actors[i],id,actors[i].HumanoidRootPart.Position,endpoints[i],1,{},nil,nil,nil,aim)
        end
    end

    for _, compact in {false,true} do
        FX.isOtherHero=function() return compact end
        playFour()
        for _, i in {1,3,4} do
            local wake = byName(names[i])[1]
            check(wake and close(wake.Attachment0.WorldPosition,sockets[i]),ids[i].." starts on the equipped socket")
            check(wake and close(wake.Attachment1.WorldPosition,endpoints[i]),ids[i].." stops at server cover")
        end
        local faults = byName("StoneboundFault")
        check(#byName(names[2])==3 and #faults==3,"Landing spreads from one point in three directions")
        check(#byName("StoneboundChip")== (compact and 0 or 2),"Only local impact has slate fragments")
        check(#byName("StoneLanceVolume")== (compact and 0 or 1),"Only local Stone Lance shows a slate core")
        check(#byName("ArrowWake")==0 and #byName("ThrustPressure")==0 and #byName("EarthFissure")==0,
            "Fallback duplicates are absent with sufficient VFX budget")
        local now = workspace:GetServerTimeNow()
        FX.step(now+.10)
        for _, i in {1,3,4} do
            local wake = byName(names[i])[1]
            check(wake and (wake.Attachment0.WorldPosition-sockets[i]).Magnitude>2
                and close(wake.Attachment1.WorldPosition,endpoints[i]),ids[i].." retracts from behind its endpoint")
        end
        local landing = endpoints[2]
        for _, beam in faults do
            local tip=beam.Attachment1.WorldPosition
            local radius=Vector3.new(tip.X-landing.X,0,tip.Z-landing.Z).Magnitude
            check(radius>2 and radius<Catalog.byId[ids[2]].definition.range,"Fault stays inside actual landing radius")
            check(math.abs(tip.Y-(floor.Position.Y+floor.Size.Y/2))<.20,"Fault hugs the floor")
        end
        local active, beams, _, glows, particles, surfaces = FX.count()
        report.counts[compact and "ally" or "self"]={active=active,beams=beams,glows=glows,particles=particles,surfaces=surfaces}
        check(active==4 and beams==13 and glows==0 and particles==0,"Four releases fit into thirteen beams")
        clear()
    end

    wall.Position=origin+aim*1
    for _, i in {1,3,4} do
        local start=actors[i].HumanoidRootPart.Position
        local endpoint=resolve(actors[i],ids[i])
        Visual.play(actors[i],ids[i],start,endpoint,1,{},nil,nil,nil,aim)
        local wake=byName(names[i])[1]
        check(close(endpoint,start+aim*.5) and wake and close(wake.Attachment0.WorldPosition,start)
            and close(wake.Attachment1.WorldPosition,endpoint),ids[i].." uses the server origin when the socket is past cover")
    end
    clear()

    local player=Instance.new("Folder",stage)
    player:SetAttribute("K0SessionPhase","Tutorial")
    local caster=actors[1]
    caster.Name,caster.Parent="Character",player
    Instance.new("Humanoid",caster).RequiresNeck=false
    local enemies=Instance.new("Folder",stage)
    local target=Instance.new("Model",enemies)
    local root=part(target,"HumanoidRootPart",origin+aim*4)
    target:SetAttribute("K0EnemyState","Windup")
    target:SetAttribute("K0Telegraph","Unblockable")
    target:SetAttribute("K0AttackOrigin",root.Position)
    target:SetAttribute("K0AttackDirection",aim)
    target:SetAttribute("K0AttackRange",9)
    target:SetAttribute("K0AttackAngle",360)
    local world=workspace:FindFirstChild("DeepwoodK0")
    if not world then
        world=Instance.new("Folder",workspace)
        world.Name="DeepwoodK0"
        temporaryWorld=world
        original[world]=true
    end
    local floorGroup=world:FindFirstChild("TerrainBlockout")
    if not floorGroup then
        floorGroup=Instance.new("Folder",world)
        floorGroup.Name="TerrainBlockout"
        temporaryBlockout=floorGroup
    end
    floor.Parent=floorGroup
    warnings=Telegraphs.create(enemies,player)
    FX.isOtherHero=function(character) return character~=caster end
    playFour()
    warnings.update()
    local red=0
    for _, edge in workspace.K0LocalTelegraphs:GetDescendants() do
        if edge:IsA("BasePart") and edge.Transparency<1 and edge.Color==Color3.fromRGB(255,73,58) then red+=1 end
    end
    local active,beams,_,glows,particles,surfaces=FX.count()
    report.overlap={active=active,beams=beams,glows=glows,particles=particles,surfaces=surfaces,warningSegments=red}
    check(red==16,"Enemy danger retains all sixteen segments")
    Hits.show(target,root.Position,42,"elf","Goblin",aim,ids[3],{attacker=actors[3]})
    local number=workspace:FindFirstChild("K0HitEffect")
    check(number and number.K0DamageNumber.Amount.Text=="42","The confirmed damage number remains visible")
    warnings.destroy()
    warnings=nil
    floor.Parent=stage
    clear()
    check(FX.count()==0 and select(2,FX.count())==0,"All beams and releases are cleaned up")

    task.wait(.40)
    FX.isOtherHero=function() return false end
    for _=1,12 do FX.skill(actors[2],ids[2],endpoints[2],endpoints[2],1,{},nil,aim) end
    for i=1,#ids do Visual.play(actors[i],ids[i],actors[i].HumanoidRootPart.Position,endpoints[i],1,{},nil,nil,nil,aim) end
    check(#byName("ElementalTrail")==2 and #byName("ArrowWake")==1 and #byName("SkillSector")>0,
        "Capped VFX budget retains both lines, the arrow and the area boundary")
end,debug.traceback)
if warnings then warnings.destroy() end
clear()
if temporaryBlockout then temporaryBlockout:Destroy() end
if temporaryWorld then temporaryWorld:Destroy() end
stage:Destroy()
camera.CFrame,FX.isOtherHero=oldCamera,oldCompact
if not ok then table.insert(report.failures,err) end
report.pass=#report.failures==0
print("HERO_FORWARD_IMPACT_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass,table.concat(report.failures,"\n"))
