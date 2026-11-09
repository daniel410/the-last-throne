-- Native modules + actual private damage path; synthetic clock/owner, no transport.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated local fixture only")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Combat = game.ServerScriptService.Server.Combat
local Config = require(game.ReplicatedStorage.Shared.K0Config)
local Stop = require(Client.K0HitStop)
local Knockback = require(Combat.EnemyKnockback)
local Audio = require(Client.K0CombatAudio)
local report = {kind = "HERO_HIT_FEEDBACK_NATIVE", checks = 0, pass = false}
local function check(v, label) report.checks += 1; assert(v, label) end
local function near(a, b, label) check(math.abs(a-b) < .00001, label .. " " .. a .. "/" .. b) end
local fixture = Instance.new("Folder"); fixture.Name = "HeroFeedbackQA"; fixture.Parent = workspace
local function rig(name, position)
    local c = Instance.new("Model"); c.Name = name
    local root = Instance.new("Part"); root.Name = "HumanoidRootPart"; root.Size = Vector3.new(2,2,2)
    root.CFrame = CFrame.new(position); root.Anchored = true; root.CanCollide = false; root.Parent = c
    local h = Instance.new("Humanoid"); h.RequiresNeck = false; h.MaxHealth = 100000; h.Health = 100000; h.Parent = c
    c.PrimaryPart = root; c.Parent = fixture
    return c, root, h
end
local owner, root, human = rig("Owner", Vector3.new(20000,1000,20000))
local other = rig("Other", root.Position + Vector3.xAxis * 8)
local clock = Stop.new(function() return owner end)
local seq = 0
local function attack(classId, skillId, combo, rate)
    seq += 1
    owner:SetAttribute("K0State", "Attack"); owner:SetAttribute("K0ClassId", classId)
    owner:SetAttribute("K0SkillId", skillId); owner:SetAttribute("K0Combo", combo or 1)
    owner:SetAttribute("K0BasicAttackRate", rate or 1)
    owner:SetAttribute("K0AttackSeq", seq); owner:SetAttribute("K0AttackStartedAt", 100)
    owner:SetAttribute("TLTDeathFalling", nil)
    local d = skillId and nil or Config.BasicAttackProfiles[classId].attacks[combo or 1]
    if skillId then for _, v in Config.Skills[classId] do if v.id == skillId then d = v end end end
    assert(d, "fixture definition")
    local at = 100 + (d.windup + (d.hitDelay or 0)) / (rate or 1) + .001
    return {attacker=owner, seq=seq, startedAt=100, confirmedAt=at, classId=classId, skillId=skillId}, at, d
end
local function cleanAudio()
    for _, h in workspace:GetChildren() do if h.Name == "K0CombatAudioEmitter" then h:Destroy() end end
end
local private, stopClone, visualClone
local ok, err = xpcall(function()
    for _, row in {{"knight",nil,1,.03},{"knight",nil,3,.045},{"dwarf",nil,1,.05},
        {"mage",nil,1,.025},{"dwarf","dwarf.common.overhead",1,.065},
        {"dwarf","dwarf.common.ground",1,.065},{"knight","knight.common.bash",1,.045}} do
        for _, fps in {30,60,144} do for _, rate in {1,2} do
            local meta, at, d = attack(row[1], row[2], row[3], row[2] and 1 or rate)
            local ending = 100 + (d.windup+d.active+d.recovery)/(row[2] and 1 or rate)
            check(clock.record(owner, meta, at), "owner confirmed melee starts hold")
            check(not clock.record(owner, meta, at+.001), "AoE/multi hit cannot extend hold")
            near(clock.sample(owner, at+row[4]*.5), at, "fixed contact pose")
            near(clock.sample(other, at+.01), at+.01, "other rig unaffected")
            near(clock.sample(owner, at+row[4]*.5), at, "other rig cannot clear hold")
            local last = at
            for frame=1,math.ceil((ending-at)*fps) do
                local now = math.min(ending,at+frame/fps)
                local sampled = clock.sample(owner, now)
                check(sampled >= last-.000001 and sampled <= now+.000001, "monotonic bounded clock")
                last = sampled
            end
            near(clock.sample(owner, ending), ending, "no accumulated delay at action end")
            check(root.Position == Vector3.new(20000,1000,20000) and human.Health==100000, "presentation never moves or damages owner")
        end end
    end
    for _, row in {{"elf",nil},{"elf","elf.common.rapid"},{"mage","mage.common.water_ball"},
        {"dwarf","dwarf.common.throw"},{"dwarf","dwarf.gunner.bomb_toss"}} do
        local meta, at = attack(row[1],row[2])
        check(not clock.record(owner,meta,at), "ranged attacks never stop shooter")
    end
    local meta, at, d = attack("dwarf")
    check(not clock.record(other,meta,at), "nonowner rejected")
    check(not clock.record(owner,meta,at+.181), "late confirmation rejected")
    check(not clock.record(owner,meta,at-.06), "future confirmation rejected")
    check(clock.record(owner,meta,at), "fresh confirmation accepted")
    owner:SetAttribute("K0State","Dodge")
    near(clock.sample(owner,at+.01),at+.01,"dodge cancels immediately")
    meta,at=attack("dwarf");check(clock.record(owner,meta,at),"new attack hold")
    owner:SetAttribute("TLTDeathFalling",true)
    near(clock.sample(owner,at+.01),at+.01,"death cancels immediately")
    meta,at=attack("dwarf");owner:SetAttribute("K0AttackSeq",meta.seq+1)
    check(not clock.record(owner,meta,at),"old seq cannot stop new attack")
    meta,at,d=attack("dwarf")
    local late=100+d.windup+d.active+d.recovery-.015;meta.confirmedAt=late
    check(not clock.record(owner,meta,late),"no hold spilling into next action")

    -- Exercise the actual arms + held weapon renderer with a native R6 fixture.
    -- Only LocalPlayer identity is substituted, not pose sampling or clock behavior.
    stopClone=Client.K0HitStop:Clone();stopClone.Name="QAHitStop"
    stopClone.Source=stopClone.Source:gsub("Players.LocalPlayer and Players.LocalPlayer.Character", "workspace.HeroFeedbackQA.Owner")
    stopClone.Parent=Client
    visualClone=Client.K0SwordVisual:Clone();visualClone.Name="QAStopVisual"
    visualClone.Source=visualClone.Source:gsub("script.Parent.K0HitStop", "script.Parent.QAHitStop")
    visualClone.Parent=Client
    local liveStop,visual=require(stopClone),require(visualClone)
    local function bodyPart(name)
        local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=false;p.CFrame=root.CFrame;p.Parent=owner;return p
    end
    local torso,right,left=bodyPart("Torso"),bodyPart("Right Arm"),bodyPart("Left Arm")
    local function joint(name,a,b)
        local j=Instance.new("Motor6D");j.Name=name;j.Part0=a;j.Part1=b;j.Parent=a;return j
    end
    local shoulder=joint("Right Shoulder",torso,right);joint("Left Shoulder",torso,left)
    joint("RootJoint",root,torso)
    local weapon=Instance.new("Model");weapon:SetAttribute("WeaponClassId","knight");weapon.Parent=owner
    local grip=Instance.new("Part");grip.Name="SwordGrip";grip.CanCollide=false;grip.Parent=weapon
    local held=joint("K0SwordJoint",right,grip);held.Parent=grip
    meta,at=attack("knight");owner:SetAttribute("K0AttackPhase","Active")
    check(liveStop.record(owner,meta,at),"renderer uses owner confirmation")
    local origin=root.CFrame
    visual.renderArms(owner,1/60,at+.005);visual.render(weapon,"Active",1,1/60,"Basic",at+.005)
    local armPose,weaponPose=shoulder.Transform,held.Transform
    visual.renderArms(owner,1/60,at+.025);visual.render(weapon,"Active",1,1/60,"Basic",at+.025)
    check(shoulder.Transform==armPose and held.Transform==weaponPose,"arm and weapon hold the same contact pose")
    visual.renderArms(owner,1/60,at+.10);visual.render(weapon,"Active",1,1/60,"Basic",at+.10)
    check(shoulder.Transform~=armPose and held.Transform~=weaponPose,"arm and weapon resume together")
    owner:SetAttribute("K0State","Dodge")
    near(liveStop.sample(owner,at+.011),at+.011,"renderer releases on dodge")
    check(root.CFrame==origin,"renderer never pauses or displaces physics root")

    -- Real geometry, not mocked ray hits. Footprint must remain on walkable ground.
    local base=Vector3.new(21000,1000,21000)
    local floor=Instance.new("Part");floor.Name="Floor";floor.Anchored=true;floor.Size=Vector3.new(30,1,30)
    floor.Position=base-Vector3.yAxis*3.5;floor.Parent=fixture
    local ec,er,eh=rig("Enemy",base)
    local enemy={model=ec,root=er,humanoid=eh,kind="Goblin",config={leashRange=30},spawnPosition=base,pathToken=0}
    local function reset(position)
        ec:PivotTo(CFrame.new(position or base));enemy.knockback=nil;enemy.knockbackImmuneUntil=nil
        ec:SetAttribute("StoryBoss",nil);ec:SetAttribute("KnockbackImmune",nil);enemy.kind="Goblin"
    end
    task.wait(.1)
    check(Knockback.start(enemy,Vector3.xAxis,2,10,{ec,owner}),"push starts on floor")
    near(er.Position.X,base.X,"no instantaneous teleport")
    check(not Knockback.start(enemy,Vector3.xAxis,3,10.01,{ec,owner}),"party pushes cannot stack")
    Knockback.step(enemy,10.04)
    check(er.Position.X>base.X and er.Position.X<base.X+2,"push moves over time")
    Knockback.step(enemy,10.13);check(math.abs(er.Position.X-base.X-2)<.01,"authored push distance within native position precision")
    check(enemy.knockback==nil,"motion expires")
    for _, kind in {"boss","ogre","immune"} do
        reset();if kind=="boss" then ec:SetAttribute("StoryBoss",true)
        elseif kind=="ogre" then enemy.kind="Ogre" else ec:SetAttribute("KnockbackImmune",true) end
        check(not Knockback.start(enemy,Vector3.xAxis,3,20,{ec}),"immune target fixed "..kind)
    end
    reset();local wall=Instance.new("Part");wall.Anchored=true;wall.Size=Vector3.new(.5,8,8)
    wall.Position=base+Vector3.xAxis*2;wall.Parent=fixture;task.wait(.05)
    check(Knockback.start(enemy,Vector3.xAxis,3,30,{ec}),"wall push starts")
    Knockback.step(enemy,30.2)
    check(er.Position.X < wall.Position.X-1 and enemy.knockback==nil,"swept body stops before wall")
    wall:Destroy()
    reset(base+Vector3.xAxis*13.5)
    check(Knockback.start(enemy,Vector3.xAxis,3,40,{ec}),"edge starts supported")
    Knockback.step(enemy,40.2)
    check(er.Position.X+.8<=base.X+15 and enemy.knockback==nil,"whole footprint stays off cliff")
    reset(base+Vector3.xAxis*40)
    check(not Knockback.start(enemy,Vector3.xAxis,3,50,{ec}),"airborne push rejected")
    reset();enemy.config.leashRange=1
    check(Knockback.start(enemy,Vector3.xAxis,3,60,{ec}),"leash push starts")
    Knockback.step(enemy,60.2);check(er.Position.X<=base.X+1,"push respects spawn leash")
    enemy.config.leashRange=30
    reset()
    local stair=Instance.new("Part");stair.Anchored=true;stair.Size=Vector3.new(3,.25,10)
    stair.Position=base+Vector3.new(2,-2.875,0);stair.Parent=fixture;task.wait(.05)
    check(Knockback.start(enemy,Vector3.xAxis,2,70,{ec}),"low stair push starts")
    Knockback.step(enemy,70.2)
    check(er.Position.X>base.X+1.9 and math.abs(er.Position.Y-base.Y-.25)<.01,"small stair follows ground height")
    stair:Destroy()
    reset();check(Knockback.start(enemy,Vector3.xAxis,99,80,{ec}),"authored displacement accepted with cap")
    Knockback.step(enemy,80.2);check(er.Position.X<=base.X+3.01,"distance is bounded to three studs")
    reset();check(Knockback.start(enemy,Vector3.xAxis,2,90,{ec}),"live target motion starts")
    eh.Health=0;check(not Knockback.step(enemy,90.05) and enemy.knockback==nil,"death cancels pending displacement")
    ec:Destroy();ec,er,eh=rig("Enemy",base)
    enemy.model,enemy.root,enemy.humanoid=ec,er,eh

    -- Native Sound instances: own contact survives same-source peer bursts.
    local camera=workspace.CurrentCamera
    local cam=Instance.new("Camera");cam.CFrame=CFrame.new(0,0,10);cam.Parent=workspace;workspace.CurrentCamera=cam
    cleanAudio()
    local played,peer=Audio.play("impact",Vector3.zero,"dwarf",nil,other,false)
    check(played,"peer contact")
    local ownPlayed,own=Audio.play("impact",Vector3.zero,"dwarf",nil,owner,true)
    check(ownPlayed,"own contact not suppressed by peer using same sample/cell")
    check(not Audio.play("impact",Vector3.zero,"dwarf",nil,owner,true),"own AoE still collapses")
    for i=1,20 do Audio.play("impact",Vector3.new(i%3*9,0,0),"dwarf",nil,"peer-"..i,false) end
    check(own.Parent~=nil,"peer saturation never evicts own contact")
    local count=0;for _,h in workspace:GetChildren()do if h.Name=="K0CombatAudioEmitter"then count+=1 end end
    check(count<=8,"impact voice cap preserved")
    cleanAudio();task.wait(.08)
    for i=1,8 do check(Audio.play("impact",Vector3.zero,"dwarf",nil,"own-"..i,true),"fill owner reserve")end
    check(not Audio.play("impact",Vector3.zero,"dwarf",nil,"peer-overflow",false),"peer dropped instead of own")
    check(Audio.play("impact",Vector3.zero,"dwarf",nil,"new-own",true),"new own contact can replace old own")
    cleanAudio();workspace.CurrentCamera=camera;cam:Destroy()

    -- Actual damage function appends identity only after HP loss; mocks only the sink.
    private=Combat.CombatService:Clone();private.Name="FeedbackDamagePrivate"
    private.Source=private.Source:gsub("\nreturn CombatService%s*$",function()return [[
return {damage=damageEnemy,setFolder=function(v)enemyFolder=v end,
 setSink=function(v)hitEffectRemote=v end}
]]end);private.Parent=Combat
    local api=require(private);api.setFolder(fixture)
    local received
    api.setSink({FireAllClients=function(_,...)received=table.pack(...)end})
    reset();local m,t=attack("dwarf")
    local state={character=owner,root=root,baseClassId="dwarf",heroId="qa",attackSeq=m.seq,feedbackSeq=0}
    local a={hits={},hitCount=0,definition={damage=1,posture=0},attackPower=10,
        direction=Vector3.xAxis,resolvedSampleAt=99.9}
    enemy.posture=100;enemy.postureImmuneUntil=0;enemy.mode="Idle"
    api.damage(state,enemy,a,100)
    check(received and received.n==8,"backward compatible event appends metadata")
    check(received[3]==10 and received[4]=="dwarf","actual applied damage and class retained")
    local identity=received[8]
    check(identity.attacker==owner and identity.seq==m.seq and identity.startedAt==100,"accepted attacker/action identity")
    check(math.abs(identity.confirmedAt-(workspace:GetServerTimeNow()-.1))<.05,"sample age retained through server stall")
    received=nil;api.damage(state,enemy,a,100.1);check(not received,"duplicate damage emits no feedback")
end,debug.traceback)
if private then private:Destroy() end
if visualClone then visualClone:Destroy() end
if stopClone then stopClone:Destroy() end
cleanAudio();fixture:Destroy()
report.pass=ok;report.error=not ok and err or nil
print("HERO_HIT_FEEDBACK_NATIVE "..game.HttpService:JSONEncode(report))
assert(ok,err)
