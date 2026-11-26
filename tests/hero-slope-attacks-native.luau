assert(game.PlaceId==0 and #game.Players:GetPlayers()==0, "Isolated Studio Place required")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Visual=require(Client.AdvancedSkillVisual)
local FX=require(Client.HeroVFX)
local Motion=require(Client.AdvancedSkillMotion)
local Poses=require(Client.RangedActionPoses)
local Telegraphs=require(Client.K0Telegraphs)
local Hits=require(Client.K0HitEffects)
local camera=workspace.CurrentCamera
local origin=Vector3.new(0,745,0)
local aim=-Vector3.zAxis
local oldCamera,oldCompact=camera.CFrame,FX.isOtherHero
local stage=Instance.new("Folder",workspace)
local originals={}
for _,item in workspace:GetChildren() do originals[item]=true end
local ids={"knight.steel_knight.sweeping_break","dwarf.iron_axe.mountain_sweep",
    "elf.marksman.arrow_rain","mage.pyro.earth_rise"}
local names={"SweepingBreakEdge","MountainSweepRidge","ArrowRainLanding","EarthRiseFault"}
local report={checks=0,failures={},observations={}}
local warnings,temporaryWorld,temporaryBlockout
local function check(ok,message)
    report.checks+=1
    if not ok then table.insert(report.failures,message) end
end
local function part(parent,name,size,cf,solid)
    local p=Instance.new("Part")
    p.Name,p.Size,p.CFrame=name,size,cf
    p.Anchored,p.CanCollide,p.CanQuery=true,solid,solid
    p.Parent=parent
    return p
end
local function named(name,root)
    local found={}
    for _,item in (root or workspace):GetDescendants() do
        if item.Name==name then table.insert(found,item) end
    end
    return found
end
local function clear()
    FX.clear()
    for _,item in workspace:GetChildren() do
        if not originals[item] then item:Destroy() end
    end
end

local ok,err=xpcall(function()
    local world=workspace:FindFirstChild("DeepwoodK0")
    if not world then
        world=Instance.new("Folder",workspace)
        world.Name="DeepwoodK0"
        originals[world]=true
        temporaryWorld=world
    end
    local blockout=world:FindFirstChild("TerrainBlockout")
    if not blockout then
        blockout=Instance.new("Folder",world)
        blockout.Name="TerrainBlockout"
        temporaryBlockout=blockout
    end
    local base=(CFrame.new(origin-Vector3.yAxis*2.65)*CFrame.Angles(0,0,math.rad(23)))
    local slope=part(stage,"Slope",Vector3.new(76,1,62),base*CFrame.new(0,-.5,0),true)
    camera.CFrame=CFrame.lookAt(origin+Vector3.new(15,15,20),origin+aim*3)
    local actors,castPoints={},{}
    for i,id in ids do
        local actor=Instance.new("Model",stage)
        actor:SetAttribute("K0AttackSeq",i)
        actor:SetAttribute("K0State","Attack")
        actor:SetAttribute("K0SkillId",id)
        part(actor,"HumanoidRootPart",Vector3.one,CFrame.new(origin+Vector3.new(i*.12,0,0)),false)
        actors[i]=actor
        castPoints[i]=i>2 and origin+aim*(i==3 and 7 or 4) or origin
    end
    local direct=RaycastParams.new()
    direct.FilterType=Enum.RaycastFilterType.Include
    direct.FilterDescendantsInstances={slope}
    local function slopeAt(point)
        return workspace:Raycast(point+Vector3.yAxis*15,-Vector3.yAxis*30,direct).Position.Y
    end
    local function outline(name,center,radius,expected,label)
        local edges=named(name)
        local above,below,off=0,0,0
        for _,edge in edges do
            for _,z in {-edge.Size.Z/2,edge.Size.Z/2} do
                local tip=edge.CFrame:PointToWorldSpace(Vector3.new(0,0,z))
                local delta=tip.Y-slopeAt(tip)
                if delta>.165 then above+=1 elseif delta<.055 then below+=1 end
                if math.abs(Vector3.new(tip.X-center.X,0,tip.Z-center.Z).Magnitude-radius)>.03 then off+=1 end
            end
        end
        check(#edges==expected,label.." complete outline")
        check(above==0 and below==0,label.." follows both sides of the incline")
        check(off==0,label.." retains the horizontal radius")
        report.observations[label]={segments=#edges,above=above,below=below,offRadius=off}
    end

    local function play(i,pulse)
        local row=Catalog.byId[ids[i]]
        local now=workspace:GetServerTimeNow()
        Visual.play(actors[i],ids[i],origin,castPoints[i],pulse,{},nil,pulse>0 and now or nil,now,aim)
        return row.definition
    end
    for _,compact in {false,true} do
        FX.isOtherHero=function() return compact end
        local label=compact and "Ally" or "Self"
        for i,id in ids do
            local d=Catalog.byId[id].definition
            if i>=3 then
                play(i,0)
                outline("SkillTelegraph",castPoints[i],d.radius,compact and 12 or 24,label.." windup "..i)
                clear()
            end
            play(i,1)
            outline(i<3 and "SkillSector" or "ImpactBoundary",castPoints[i],i<3 and d.range or d.radius,
                compact and 12 or 24,label.." contact "..i)
            check(#named(names[i])>0,label.." authored contact "..i)
            check(#named("BladeCrescent")==0 and #named("LandingRipple")==0 and #named("RuptureShockwave")==0,
                label.." uses one release silhouette "..i)
            if i==2 then
                check(#named("MountainSweepSlate")== (compact and 0 or 3),label.." slate accents respect the party budget")
            end
            if i==4 then
                FX.step(workspace:GetServerTimeNow()+.105)
                local crags=named("RisingCrag")
                check(#crags==3 and crags[1].Size.Y>crags[2].Size.Y and crags[2].Size.Y>crags[3].Size.Y,
                    label.." three staged crags")
                for _,crag in crags do
                    local foot=crag.Position.Y-crag.Size.Y*.5
                    check(math.abs(foot-slopeAt(crag.Position))<.065,label.." crag starts at its own surface")
                end
            end
            clear()
            task.wait(.46)
        end

        local rain=Catalog.byId[ids[3]].definition
        for pulse=1,rain.pulses do
            local now=workspace:GetServerTimeNow()
            local contact=now+.13
            local incoming=FX.incoming(actors[3],rain,castPoints[3],3,pulse,contact,function()return true end)
            local landed=FX.skill(actors[3],ids[3],origin,castPoints[3],pulse,{},nil,aim)
            local flight=named("ArrowRain",incoming)
            local tails=named("ArrowRainLanding",landed)
            check(#flight>0 and #flight==#tails,label.." matching descent/landing count "..pulse)
            for index,tail in tails do
                local a,b=flight[index].Attachment0.WorldPosition,tail.Attachment1.WorldPosition
                check(Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude<.015
                    and math.abs(b.Y-slopeAt(b))<.14,label.." arrow reaches its descent position "..pulse.."/"..index)
            end
            clear()
        end
    end

    for i=1,2 do
        local row=Catalog.byId[ids[i]]
        local d=row.definition
        local plain=table.clone(d)
        plain.id="Fixture_"..d.id
        local presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
        presentation.byId[plain.id]=presentation.get(d)
        for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
            local at=d.windup+(d.hitDelay or 0)+.141
            local pose=Motion.sample(row.classId,d,at,rig)
            local generic=Motion.sample(row.classId,plain,at,rig)
            check(pose.angles.elbow.X-generic.angles.elbow.X>17,ids[i].." folds the weapon elbow "..rig.Name)
        end
    end
    local rain=Catalog.byId[ids[3]].definition
    local first,last,redraw={angles={}},{angles={}},{angles={}}
    Poses.bow(first,rain,rain.windup+.052,.052,true,1)
    Poses.bow(last,rain,rain.windup+(rain.pulses-1)*rain.interval+.052,.052,false,rain.pulses)
    Poses.bow(redraw,rain,rain.windup+rain.interval*.56,rain.interval*.56,true,1)
    check(last.angles.leftKnee.X-first.angles.leftKnee.X>14 and last.angles.elbow.X<first.angles.elbow.X-16,
        "Arrow Rain lowers bow on the last shot")
    check(redraw.angles.elbow.X>15 and redraw.angles.neck.X~=first.angles.neck.X,"Arrow Rain redraws between volleys")
    local earth=Catalog.byId[ids[4]].definition
    local lift,generic={angles={}},{angles={}}
    local other=table.clone(earth)
    other.id="Fixture_EarthRise"
    local presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
    presentation.byId[other.id]=presentation.get(earth)
    Poses.mage(lift,earth,"earth",earth.windup+.065)
    Poses.mage(generic,other,"earth",earth.windup+.065)
    check(lift.angles.left.X>generic.angles.left.X+28 and lift.angles.leftKnee.X>generic.angles.leftKnee.X+12,
        "Earth Rise lifts palm and braces the front leg")

    slope.Parent=blockout
    local player=Instance.new("Folder",stage)
    player:SetAttribute("K0SessionPhase","Tutorial")
    actors[1].Parent,actors[1].Name=player,"Character"
    Instance.new("Humanoid",actors[1]).RequiresNeck=false
    local enemies=Instance.new("Folder",stage)
    local enemy=Instance.new("Model",enemies)
    local root=part(enemy,"HumanoidRootPart",Vector3.one,CFrame.new(origin+aim*3),false)
    for key,value in {K0EnemyState="Windup",K0Telegraph="Unblockable",K0AttackOrigin=root.Position,
        K0AttackDirection=aim,K0AttackRange=8,K0AttackAngle=360} do enemy:SetAttribute(key,value) end
    warnings=Telegraphs.create(enemies,player)
    FX.isOtherHero=function(character) return character~=actors[1] end
    for i=1,4 do play(i,1) end
    warnings.update()
    local red=0
    for _,edge in workspace.K0LocalTelegraphs:GetDescendants() do
        if edge:IsA("BasePart") and edge.Transparency<1 and edge.Color==Color3.fromRGB(255,73,58) then red+=1 end
    end
    check(red==16,"Four hero releases preserve the hostile warning")
    Hits.show(enemy,root.Position,42,"elf","Goblin",aim,ids[3],{attacker=actors[3]})
    local hit=workspace:FindFirstChild("K0HitEffect")
    check(hit and hit.K0DamageNumber.Amount.Text=="42","Damage number retained")
    local active,beams,_,glows,particles,surfaces=FX.count()
    report.overlap={active=active,beams=beams,glows=glows,particles=particles,surfaces=surfaces,warningSegments=red}
    warnings.destroy();warnings=nil
    slope.Parent=stage
    clear()

    -- A cliff/void is not drawn as a suspended line on the supported floor.
    slope:Destroy()
    local ledge=part(stage,"Ledge",Vector3.new(32,1,60),CFrame.new(origin+Vector3.new(-13,-3,0)),true)
    task.wait(.5)
    FX.isOtherHero=function() return false end
    play(4,0)
    local edges=named("SkillTelegraph")
    check(#edges>0 and #edges<24,"Partial support clips the outline at a ledge")
    for _,edge in edges do
        check(edge.Position.X<=ledge.Position.X+ledge.Size.X*.5+.04,"No outline over the void")
    end
    clear()

    task.wait(.50)
    local lower=part(stage,"LowerLedge",Vector3.new(24,1,60),CFrame.new(origin+Vector3.new(15,-4.45,0)),true)
    play(4,0)
    local upperCount,lowerCount,crossing=0,0,0
    for _,edge in named("SkillTelegraph") do
        if math.abs(edge.CFrame.LookVector.Y)>.05 then crossing+=1
        elseif edge.Position.Y<ledge.Position.Y then lowerCount+=1
        else upperCount+=1 end
    end
    check(upperCount>0 and lowerCount>0 and crossing==0,"Two supported levels do not produce a floating bridge")
    clear()
    lower:Destroy()

    task.wait(.50)
    local before=workspace:GetServerTimeNow()
    local actor=actors[4]
    Visual.play(actor,ids[4],origin,castPoints[4],0,{},4,nil,before,aim)
    check(#named("SkillTelegraph")>0,"Ground windup is shown before cancellation")
    actor:SetAttribute("K0State","Dodge")
    task.wait()
    check(#named("SkillTelegraph")==0,"Dodge removes supported windup segments")
    task.wait(.46)
    camera.CFrame=CFrame.lookAt(origin+Vector3.zAxis*145,origin)
    play(1,1)
    play(3,0)
    check(#named("SkillSector")==0 and #named("SkillTelegraph")==0,
        "Distant casts skip terrain projection and boundary parts")
end,debug.traceback)

if warnings then warnings.destroy() end
clear()
if temporaryBlockout then temporaryBlockout:Destroy() end
if temporaryWorld then temporaryWorld:Destroy() end
stage:Destroy()
camera.CFrame,FX.isOtherHero=oldCamera,oldCompact
if not ok then table.insert(report.failures,err) end
report.pass=#report.failures==0
print("HERO_SLOPE_ATTACKS_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass,table.concat(report.failures,"\n"))
