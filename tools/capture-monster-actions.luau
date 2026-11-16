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
local function capture(kind,frame)
    local done=false
    game.CaptureService:CaptureScreenshot(function(id)
        local img=game.AssetService:CreateEditableImageAsync(Content.fromUri(id))
        local raw=img:ReadPixelsBuffer(Vector2.zero,img.Size)
        local side=math.min(img.Size.X,img.Size.Y)
        local n=240
        local rgb=buffer.create(n*n*3)
        for y=0,n-1 do for x=0,n-1 do
            local sx=math.floor((img.Size.X-side)/2+(x+.5)*side/n)
            local sy=math.floor((img.Size.Y-side)/2+(y+.5)*side/n)
            buffer.copy(rgb,(y*n+x)*3,raw,(sy*img.Size.X+sx)*4,3)
        end end
        local bytes=game.EncodingService:CompressBuffer(rgb,Enum.CompressionAlgorithm.Zstd,4)
        local encoded=game.EncodingService:Base64Encode(bytes)
        local data=buffer.tostring(encoded)
        for i=1,#data,5000 do print("MONSTER_PIXELS",kind,frame,data:sub(i,i+4999)) end
        img:Destroy()
        done=true
    end)
    local deadline=os.clock()+20
    repeat task.wait(.03) until done or os.clock()>deadline
    assert(done,"Capture timeout "..kind)
end
for _,case in {{"Goblin",2},{"Ogre",1},{"Gloambat",1},{"IceWolf",2},{"VolcanoShaman",1},{"Veyr",2}} do
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
    local center,size=actor.TdMonsterVisual:GetBoundingBox()
    local target=center.Position
    local extent=math.max(size.X,size.Y,size.Z,s.height)
    camera.CameraType=Enum.CameraType.Scriptable
    camera.FieldOfView=27
    local shot=CFrame.lookAt(target+Vector3.new(.83,.29,-1).Unit*extent*3.15,target)
    camera.CFrame=shot
    local duration=d.windup+d.active+d.recovery
    actor:SetAttribute("K0EnemyAttackClock",string.format("%d|100|%.7f|%.7f|%.7f|%d",index,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
    actor:SetAttribute("K0AttackSeq",index)
    actor:SetAttribute("K0PatternId",d.id)
    snapshot.message({kind="begin",id=d.id,sequence=index,model=actor,definition=d,
        origin=root.Position,direction=-Vector3.zAxis,aim=root.Position-Vector3.zAxis*12})
    print("MONSTER_ACTION",kind,index,d.name,duration)
    for i=0,15 do
        local age=duration*i/16
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
