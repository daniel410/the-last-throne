-- Use the fixed local Place. Sample stamped server actions on the actual game rigs.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,node in game:GetDescendants() do
    if node:IsA("BaseScript") then node.Enabled=false end
end
local run=game.RunService
if not run:IsRunning() then run:Run() end
task.wait(.35)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local motion=require(client.K0EnemyMotion)
local snapshot=require(client.EnemyPatternDefinition)
local shared=game.ReplicatedStorage.Shared
local profiles=require(shared.EnemyCombatProfiles)
local patterns=require(shared.EnemyPatterns)
local field=require(game.ServerScriptService.Server.World.TrainingField)
local stage=Instance.new("Folder",workspace)
local camera=workspace.CurrentCamera
local surface=Instance.new("Part",stage)
surface.Size=Vector3.new(180,1,180)
surface.Position=Vector3.new(0,999.5,0)
surface.Anchored=true
surface.Color=Color3.fromRGB(57,68,76)
surface.Material=Enum.Material.Slate
game.Lighting.ClockTime=14
game.Lighting.Ambient=Color3.fromRGB(130,138,151)
local function framing(visual)
    local lo=Vector3.one*math.huge
    local hi=-lo
    for _,p in visual:GetDescendants() do
        if p:IsA("BasePart") and p.Transparency<.95 then
            for _,x in {-.5,.5} do for _,y in {-.5,.5} do for _,z in {-.5,.5} do
                local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z))
                lo=lo:Min(v)
                hi=hi:Max(v)
            end end end
        end
    end
    return (lo+hi)/2,hi-lo
end
local function capture(kind,frame)
    local done=false
    game.CaptureService:CaptureScreenshot(function(id)
        local img=game.AssetService:CreateEditableImageAsync(Content.fromUri(id))
        local raw=img:ReadPixelsBuffer(Vector2.zero,img.Size)
        local side=math.min(img.Size.X,img.Size.Y)
        local n=if _G.ReviewVeyrSwing then 384 elseif _G.ReviewWeaponHands then 320 else 240
        local rgb=buffer.create(n*n*3)
        for y=0,n-1 do for x=0,n-1 do
            local sx=math.floor((img.Size.X-side)/2+(x+.5)*side/n)
            local sy=math.floor((img.Size.Y-side)/2+(y+.5)*side/n)
            buffer.copy(rgb,(y*n+x)*3,raw,(sy*img.Size.X+sx)*4,3)
        end end
        local bytes=game.EncodingService:CompressBuffer(rgb,Enum.CompressionAlgorithm.Zstd,4)
        local encoded=game.EncodingService:Base64Encode(bytes)
        local data=buffer.tostring(encoded)
        assert(_G.MonsterCaptureURL,"Use tools/collect-monster-actions.py")
        game.HttpService:PostAsync(_G.MonsterCaptureURL,game.HttpService:JSONEncode({
            kind=kind,frame=frame,data=data}),Enum.HttpContentType.ApplicationJson,false)
        img:Destroy()
        done=true
    end)
    local deadline=os.clock()+20
    repeat task.wait(.03) until done or os.clock()>deadline
    assert(done,"Capture timeout "..kind)
end
local cases = {{"Goblin",2},{"Ogre",1},{"Gloambat",1},{"IceWolf",2},{"VolcanoShaman",1},{"Veyr",2}}
if _G.ReviewVeyrSwing then
    cases = {{"Veyr",2}}
elseif _G.ReviewWeaponHands then
    cases = {{"Veyr",2},{"DreadCommander",1},{"DeathKnight",1},{"EnragedWarlord",1}}
end
for _,case in cases do
    local kind,index=unpack(case)
    local d=profiles.resolve(kind,patterns.get(kind).attacks[index],"Hard",.65)
    local actor=field.makeEnemy(stage,kind,0,0,1,1)
    actor:SetAttribute("K0EnemyMotionSeed",0)
    local root=actor.HumanoidRootPart
    root.Anchored=true
    actor:PivotTo(actor:GetPivot()+Vector3.new(0,1000,0))
    actor.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    local s=assert(motion.bind(actor),kind)
    game.ContentProvider:PreloadAsync(actor:GetDescendants())
    run.Heartbeat:Wait()
    local target,size=framing(actor.TdMonsterVisual)
    local extent=math.max(size.X,size.Y,size.Z,s.height)
    local view=Vector3.new(.83,.29,-1)
    if _G.ReviewWeaponHands then
        target=Vector3.new(root.Position.X,target.Y,root.Position.Z)
        extent=s.height*1.17
        view=Vector3.new(.43,.24,-1)
    end
    if _G.ReviewVeyrSwing then
        target=Vector3.new(root.Position.X,target.Y+s.height*.15,root.Position.Z)
        extent=s.height*1.28
        view=Vector3.new(-.18,.13,-1)
        actor:SetAttribute("K0EnemyState","Idle")
        for i=1,30 do motion.step(s,1/60,99+i/60) end
    end
    camera.CameraType=Enum.CameraType.Scriptable
    camera.FieldOfView=27
    local shot=CFrame.lookAt(target+view.Unit*extent*3.15,target)
    camera.CFrame=shot
    if _G.ReviewWeaponHands or _G.ReviewVeyrSwing then
        -- Mesh assets can finish downloading before their first rendered frame.
        -- Let the fixed camera see the complete rig before sampling the windup.
        task.wait(2)
    end
    local duration=d.windup+d.active+d.recovery
    actor:SetAttribute("K0EnemyAttackClock",string.format("%d|100|%.7f|%.7f|%.7f|%d",index,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
    actor:SetAttribute("K0AttackSeq",index)
    actor:SetAttribute("K0PatternId",d.id)
    snapshot.message({kind="begin",id=d.id,sequence=index,model=actor,definition=d,
        origin=root.Position,direction=-Vector3.zAxis,aim=root.Position-Vector3.zAxis*12})
    print("MONSTER_ACTION",kind,index,d.name,duration)
    local count=if _G.ReviewVeyrSwing then 54 else 16
    for i=0,count-1 do
        local age=duration*i/count
        if _G.ReviewWeaponHands then
            age=if i<8 then d.windup*i/8 elseif i<=11 then d.windup+math.min(.22,d.active)*(i-8)/3 else d.windup+d.active+d.recovery*(i-12)/3
        end
        actor:SetAttribute("K0EnemyState",age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery")
        motion.step(s,1/60,100+age)
        run.Heartbeat:Wait()
        run.Heartbeat:Wait()
        camera.CFrame=shot
        task.wait(.07)
        capture(kind,i)
    end
    motion.unbind(s)
    actor:Destroy()
end
stage:Destroy()
print("MONSTER_CAPTURE_PASS")
