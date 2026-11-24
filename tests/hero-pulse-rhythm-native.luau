-- Distinct pulse presentations at the same server-authored contact times.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Shared=game.ReplicatedStorage.Shared
local Catalog=require(Shared.PixelFXCatalog)
local Presentation=require(Shared.SkillPresentation)
local Motion=require(Client.AdvancedSkillMotion)
local Mage=require(Client.K0MageMotion)
local Bow=require(Client.K0BowMotion)
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)

local first=Vector3.new(0,303,0)
local heading=Vector3.xAxis
local last=first+heading*12
local socket=first+Vector3.new(1,0,-.75)
local stage=Instance.new("Folder",workspace)
local floor=Instance.new("Part",stage)
floor.Anchored,floor.Size,floor.Position=true,Vector3.new(80,1,80),first-Vector3.yAxis*3.5
local camera=workspace.CurrentCamera
local originalCamera,originalCompact=camera.CFrame,FX.isOtherHero
camera.CFrame=CFrame.lookAt(first+Vector3.new(8,15,17),first)
local ids={
    "knight.paladin.oathblade", "dwarf.gunner.quickfire",
    "elf.magic_archer.echo_arrows", "mage.pyro.molten_line",
    "knight.steel_knight.twin_cyclone", "dwarf.iron_axe.returning_echo", "mage.pyro.cinder_ring",
}
local report={checks=0,failures={},beamCounts={}}
local function check(ok,message)
    report.checks+=1
    if not ok then table.insert(report.failures,message) end
end
local function get(i)
    return Catalog.byId[ids[i]].definition
end
local function generic(d)
    local other=table.clone(d)
    other.id="Fixture_"..d.id
    Presentation.byId[other.id]=Presentation.get(d)
    return other
end
local function find(model,name,class)
    local matches={}
    for _,node in model:GetDescendants() do
        if node.Name==name and node:IsA(class) then table.insert(matches,node) end
    end
    return matches
end
local function cast(i,pulse,finish)
    FX.clear()
    return assert(FX.skill(nil,ids[i],first,finish or last,pulse,{},socket,heading))
end

local ok,err=xpcall(function()
    local oath,gun,echo,molten=get(1),get(2),get(3),get(4)
    local cyclone,axe,cinder=get(5),get(6),get(7)
    for _,rigType in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
        local opening=Motion.sample("knight",oath,oath.windup+.05,rigType)
        local returning=Motion.sample("knight",oath,oath.windup+oath.interval+.05,rigType)
        check((opening.angles.right-returning.angles.right).Magnitude>15,"Oathblade reverses sword pose "..rigType.Name)
        check(opening.angles.rightKnee.X>Motion.sample("knight",generic(oath),oath.windup+.05,rigType).angles.rightKnee.X+10
            and returning.angles.leftKnee.X>Motion.sample("knight",generic(oath),oath.windup+oath.interval+.05,rigType).angles.leftKnee.X+16,
            "Oathblade transfers the brace between feet "..rigType.Name)
        for pulse=1,3 do
            local at=gun.windup+(pulse-1)*gun.interval
            local held=Motion.sample("dwarf",gun,at,rigType)
            local kick=Motion.sample("dwarf",gun,at+.024,rigType)
            check(kick.offhand and kick.angles.leftElbow.X < held.angles.leftElbow.X-12
                and kick.angles.rightKnee.X > Motion.sample("dwarf",generic(gun),at+.024,rigType).angles.rightKnee.X+10,"Quickfire left elbow kicks from a low stance "..rigType.Name..pulse)
        end
        local firstTurn=Motion.sample("knight",cyclone,cyclone.windup+.055,rigType)
        local secondTurn=Motion.sample("knight",cyclone,cyclone.windup+cyclone.interval+.055,rigType)
        check(firstTurn.angles.torso.Z>15 and secondTurn.angles.torso.Z< -15,
            "Twin Cyclone banks into each pulse on opposing sides "..rigType.Name)
        local catchAge=axe.windup+axe.interval+.055
        local catch=Motion.sample("dwarf",axe,catchAge,rigType)
        local plainCatch=Motion.sample("dwarf",generic(axe),catchAge,rigType)
        check(catch.angles.leftKnee.X>plainCatch.angles.leftKnee.X+20 and catch.angles.right.Z>plainCatch.angles.right.Z+14,
            "Returning Echo plants and tucks the receiving arm "..rigType.Name)
    end
    local actor=Instance.new("Model",stage)
    Instance.new("Humanoid",actor)
    actor:SetAttribute("K0ClassId","elf")
    actor:SetAttribute("K0SkillId",echo.id)
    actor:SetAttribute("K0State","Attack")
    actor:SetAttribute("K0AttackSeq",1)
    local started=workspace:GetServerTimeNow()
    actor:SetAttribute("K0AttackStartedAt",started)
    local draw=Bow.forCharacter(actor,started+echo.windup*.53)
    check(draw.angles.weapon.Z>13,"Echo Arrows opens with a canted bow")
    local follow={}
    for pulse=1,3 do
        local at=started+echo.windup+(pulse-1)*echo.interval
        Bow.confirmPulse(actor,echo.id,pulse,1,at,started,at)
        local pose=Bow.forCharacter(actor,at+.05)
        check(pulse==3 and pose.time>=.9 or pulse<3 and pose.time<.3,"Echo " .. pulse .. " recovers after the confirmed release")
        follow[pulse]=pose
    end
    check(follow[3].angles.elbow.X>follow[1].angles.elbow.X+4,"Echo Arrows extends the final draw-elbow follow-through")
    check(follow[3].angles.leftKnee.X>follow[1].angles.leftKnee.X+12
        and follow[1].angles.torso.Z>follow[3].angles.torso.Z+12,"Echo Arrows banks and plants on the final shot")
    for pulse=1,3 do
        local at=molten.windup+(pulse-1)*molten.interval+.062
        local pose=Mage.sample(molten,Mage.profile(molten),at)
        local other=Mage.sample(generic(molten),Mage.profile(molten),at)
        check(pose.angles.leftElbow.X>other.angles.leftElbow.X+18 and pose.angles.leftKnee.X>other.angles.leftKnee.X+17,
            "Molten Line presses down through the palm and front knee on pulse "..pulse)
    end
    local firstHeat=Mage.sample(cinder,Mage.profile(cinder),cinder.windup+.062)
    local lastHeat=Mage.sample(cinder,Mage.profile(cinder),cinder.windup+2*cinder.interval+.062)
    check(lastHeat.angles.left.X>firstHeat.angles.left.X+24 and lastHeat.angles.leftKnee.X>firstHeat.angles.leftKnee.X+13,
        "Cinder Ring lifts the palm through the final flame")

    for _,compact in {false,true} do
        FX.isOtherHero=function() return compact end
        local key=compact and "ally" or "caster"
        report.beamCounts[key]={}
        local highToLow,lowToHigh
        for pulse=1,2 do
            local model=cast(1,pulse,first-Vector3.zAxis*5)
            local edges=find(model,"OathbladeEdge","Beam")
            local firstPoint=edges[1] and edges[1].Attachment0.WorldPosition
            local lastPoint=edges[#edges] and edges[#edges].Attachment1.WorldPosition
            check(#edges==(compact and 5 or 8) and firstPoint.X>first.X and lastPoint.X>first.X,
                "Oathblade follows confirmed heading "..key..pulse)
            if firstPoint and lastPoint then
                if pulse==1 then highToLow=lastPoint-firstPoint else lowToHigh=lastPoint-firstPoint end
            end
            check((#find(model,"CrossSurface","WedgePart")>0)==not compact,"Optional blade face "..key..pulse)
        end
        check(highToLow and lowToHigh and highToLow.Y< -1 and lowToHigh.Y>.7 and highToLow.Z*lowToHigh.Z<0,
            "Oathblade traces downward and rising return in opposite directions "..key)

        for i,name in {[2]="QuickfireTracer",[3]="EchoArrowWake"} do
            for pulse=1,3 do
                local model=cast(i,pulse)
                local traces=find(model,name,"Beam")
                local trace=traces[1]
                check(#traces==1 and (trace.Attachment0.WorldPosition-socket).Magnitude<.005
                    and (trace.Attachment1.WorldPosition-last).Magnitude<.005,"One socket-to-target trace "..key..name..pulse)
                check(#find(model,"NatureArrowLeaf","WedgePart")==0 and #find(model,"ShotPelletBody","BasePart")==0,
                    "No duplicate projectile shapes "..key..name..pulse)
                if i==3 then
                    check((#find(model,"EchoArrowLeaf","WedgePart")>0)==not compact,"Echo leaf is a caster detail "..key..pulse)
                    check(trace and trace.Segments==4 and math.abs(trace.CurveSize0)>.5,
                        "Echo uses a single continuous bow-to-target curve "..key..pulse)
                end
            end
        end

        local far=first+heading*5
        for pulse=1,3 do
            local now=workspace:GetServerTimeNow()
            local model=cast(4,pulse,far)
            local front=find(model,"MoltenPulseFront","Beam")[1]
            local cores=find(model,"MoltenFlowCore","BasePart")
            check(front and #cores==(compact and 3 or 6) and front.Attachment1.WorldPosition.X<first.X+1,"Molten starts near the caster "..key..pulse)
            if front and #cores>0 then
                FX.step(now+.045)
                check(front.Attachment1.WorldPosition.X>first.X+1.8 and front.Attachment1.WorldPosition.X<far.X
                    and cores[1].Size.Z>cores[#cores].Size.Z*2,"Molten seam ignites in order "..key..pulse)
                FX.step(now+.12)
                check(math.abs(front.Attachment1.WorldPosition.X-far.X)<.002 and cores[#cores].Size.Z>.6,
                    "Molten seam terminates at the shortened endpoint "..key..pulse)
                report.beamCounts[key][pulse]=select(2,FX.count())
            end
        end
        check(#find(cast(4,1,first),"MoltenFlowCore","BasePart")==0,"Blocked zero-length line cannot leave a burning seam")

        for pulse=1,2 do
            local blades=find(cast(5,pulse,first),"BladeRibbon","Beam")
            check(#blades==(compact and 8 or 12),"One steel ribbon represents one pulse "..key..pulse)
            local sign=pulse==1 and 1 or -1
            for _,blade in blades do
                local offset=blade.Attachment0.WorldPosition-first
                check(math.abs(offset.Y+offset.Z*math.tan(.4)*sign)<.01,"Only the active blade plane renders "..key..pulse)
            end
        end
        FX.clear()
        local hand=Instance.new("Part",actor)
        hand.Name,hand.Anchored,hand.Position="RightHand",true,first+Vector3.zAxis*.85
        local catchTime=workspace:GetServerTimeNow()
        local outbound=assert(FX.skill(actor,axe.id,first,last,1,{},socket,heading))
        local thrown=assert(FX.skill(actor,axe.id,first,last,2,{},socket,heading))
        check(not outbound.Parent,"Second pulse retires the outgoing copy of the same axe "..key)
        local wake=find(thrown,"ReturningEchoWake","Beam")[1]
        local hub=thrown:FindFirstChild("ThrownAxeBronzeHub",true)
        check(wake and hub and (wake.Attachment1.WorldPosition-hub.Position).Magnitude<.5
            and wake.Attachment1.WorldPosition.X>first.X+2,"Axe head and wake share the incoming approach "..key)
        FX.step(catchTime+.10)
        check(wake and hub and (wake.Attachment1.WorldPosition-hand.Position).Magnitude<.01
            and (hub.Position-hand.Position).Magnitude<.5,"Wake and axe finish at the right hand "..key)
        hand:Destroy()

        local previousHeight=0
        for pulse=1,3 do
            local at=workspace:GetServerTimeNow()
            local heat=cast(7,pulse,first)
            local edges=find(heat,"CinderRing","Beam")
            FX.step(at+.12)
            check(#edges==(compact and 8 or 12) and #find(heat,"FlameTongue","Beam")==0,
                "One flame front with no duplicate helix "..key..pulse)
            local high=0
            for _,edge in edges do
                local offset=edge.Attachment0.WorldPosition-Vector3.new(first.X,floor.Position.Y+.5,first.Z)
                high=math.max(high,offset.Y)
                local reach=Vector3.new(offset.X,0,offset.Z).Magnitude
                check(reach>cinder.range*.85 and reach<=cinder.range+.01,"The flame front stays inside the server radius "..key..pulse)
            end
            check(high>previousHeight+.1,"Each flame front climbs higher "..key..pulse)
            previousHeight=high
        end
    end

    FX.clear()
    FX.isOtherHero=function() return false end
    local seen={}
    for _,node in workspace:GetChildren() do seen[node]=true end
    Visual.play(nil,gun.id,first,last,1,{},nil,workspace:GetServerTimeNow())
    Visual.play(nil,echo.id,first,last,1,{},nil,workspace:GetServerTimeNow())
    local arrowCount=0
    for _,node in workspace:GetChildren() do
        if not seen[node] then
            check(node.Name~="RifleTracer" and node.Name~="ArrowWake","Composed release avoids a second legacy tracer")
            if node.Name=="ArrowShaft" then arrowCount+=1 end
        end
    end
    check(arrowCount==1,"Echo keeps one physical arrow fallback")
end,debug.traceback)

FX.clear()
FX.isOtherHero=originalCompact
camera.CFrame=originalCamera
stage:Destroy()
if not ok then table.insert(report.failures,err) end
report.pass=#report.failures==0
print("HERO_PULSE_RHYTHM_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass,"Pulse rhythm regression")
