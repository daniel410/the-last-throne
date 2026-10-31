-- Real imported TD meshes, authored sockets and server rig; no live Place.
assert(game.PlaceId==0,'Unpublished fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run();task.wait(1)end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion)
local Clips=require(Client.K0EnemyClips)
local Sockets=require(game.ReplicatedStorage.Shared.EnemyRigSockets)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local report={kind='DEEPWOOD_REFINEMENT_NATIVE',checks=0,failures={},weapons={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='DeepwoodRefinementQA';folder.Parent=workspace
local ok,err=xpcall(function()
 for index,kind in ipairs({'Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','EnragedWarlord','KingShaman','Slime'})do
  local model=Field.makeEnemy(folder,kind,14000+index*30,10000,1,1)
  local root=model.HumanoidRootPart;root.Anchored=true
  local s=assert(Motion.bind(model));local health=model.Humanoid.Health;local initial=root.CFrame
  local visual=model.TdMonsterVisual;local mesh=visual:FindFirstChild('ArmR')
  local meshOffset=mesh and s.joints.weapon.Part1.CFrame:ToObjectSpace(mesh.CFrame)
  local function tip()
   local fx=s.weaponFX
   local torso=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
   local motor=s.joints.weapon
   return (torso*motor.C0*motor.Transform*motor.C1:Inverse()*meshOffset):PointToWorldSpace(fx.a.Position)
  end
  if Sockets[kind]then
   local spec=Sockets[kind]
   local pivot=root.CFrame:PointToObjectSpace((s.torso.CFrame*s.joints.weapon.C0).Position)
   -- Measure against the actual feet convention rather than model pivot.
   local sourceHeight=model:GetAttribute('TdMonsterTargetHeight')
   check(math.abs(pivot.X+spec.shoulders.weapon[1]*sourceHeight)<.003,kind..' shoulder X uses anatomical source '..pivot.X..' / '..sourceHeight)
   check(s.weaponFX.a.Parent==mesh and s.weaponFX.b.Parent==mesh,kind..' sockets follow original mesh')
   for _,v in ipairs({s.weaponFX.a.Position,s.weaponFX.b.Position})do
    check(math.abs(v.X)<=mesh.Size.X*.501 and math.abs(v.Y)<=mesh.Size.Y*.501 and math.abs(v.Z)<=mesh.Size.Z*.501,kind..' sockets stay within source mesh bounds')
   end
  end
  for _,hz in ipairs({30,60,144})do
   for seq=1,4 do
    local heavy=seq>=3;local clip=(heavy and 'Heavy' or 'Attack')..(seq%2==0 and 'Alt' or '')
    local clock=seq..'|500|1.2|0.15|1.4|'..(heavy and '1' or '0')
    model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock',clock)
    Motion.step(s,1/hz,500+1.2*.8)
    local before=mesh and tip()
    Motion.step(s,1/hz,501.2)
    for _,channel in ipairs(Clips.channels)do
     local authored=Motion.sample(kind,clip,.62)[channel]
     for i,v in ipairs(authored)do check(math.abs(s.pose[channel][i]-v)<.0001,kind..' exact '..clip..' contact at '..hz..'Hz')end
    end
    if mesh then
     local strike=tip();local advance=(before.Z-strike.Z)/s.height
     table.insert(report.weapons,{kind=kind,clip=clip,hz=hz,advance=advance,height=(strike.Y+3)/s.height})
     check(advance>.015,kind..' '..clip..' weapon head advances toward target, '..advance)
     check(strike.Y>=-3-.04*s.height,kind..' weapon does not strike below feet')
     check(s.weaponFX.trail.Enabled,kind..' only actual swing draws edge')
    end
    Motion.step(s,1/hz,502.7)
    if s.weaponFX then check(not s.weaponFX.trail.Enabled,kind..' no trail during recovery')end
    check(root.CFrame==initial and model.Humanoid.Health==health,kind..' presentation preserves server authority')
   end
  end
  if s.weaponFX then
   if #s.weaponFX.shards>0 then
    model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock','7|650|1.2|0.15|1.4|0')
    Motion.step(s,1/30,650.96)
    local focus=root.CFrame:PointToWorldSpace(tip())
    for _,shard in ipairs(s.weaponFX.shards)do
     check(shard.Transparency<1 and math.abs((shard.Position-focus).Magnitude-mesh.Size.Y*.09)<.003,kind..' charge follows current authored focus without one-frame lag')
    end
   end
   model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock','5|600|1.2|0.15|1.4|0')
   Motion.step(s,1/60,601.2);s.viewDistance=150;Motion.step(s,1/60,601.2)
   check(not s.weaponFX.trail.Enabled,kind..' distant weapon accents disabled')
   s.viewDistance=0;model:SetAttribute('K0EnemyStunUntil',610);model:SetAttribute('K0EnemyState','Stunned');Motion.step(s,1/60,601.2)
   check(not s.weaponFX.trail.Enabled,kind..' stun hides edge');for _,shard in ipairs(s.weaponFX.shards)do check(shard.Transparency==1,kind..' stun hides spell charge')end
   model:SetAttribute('K0EnemyStunUntil',nil);model:SetAttribute('K0EnemyState','Windup');Motion.step(s,1/60,601.2)
   root.CFrame+=Vector3.new(100,0,0);task.wait();Motion.step(s,1/60,601.2)
   check(not s.weaponFX.trail.Enabled,kind..' teleport cannot leave a long trail')
   model:SetAttribute('K0EnemyState','Dead');Motion.step(s,1/60,601.2);check(not s.weaponFX.trail.Enabled,kind..' death clears accents')
  end
  Motion.unbind(s)
  check(s.joint.Transform==CFrame.identity and s.body.Size==s.bodySize,kind..' unbind restores source pose')
  if mesh then check(not mesh:FindFirstChild('K0WeaponPresentation') and not mesh:FindFirstChild('K0BladeTip'),kind..' teardown removes local objects')end
  model:Destroy()
 end
 -- Species differentiation is an authored result, not a timing/damage change.
 check(Motion.sample('Goblin','Attack',.62).weapon[1]>0,'goblin uses forward blade slash')
 check(Motion.sample('Ogre','Attack',.62).weapon[1]<-50,'ogre uses forward club crush')
 check(Motion.sample('Shaman','Attack',.62).weapon[1]>-30,'shaman keeps ritual focus upright')
 check(math.abs(Motion.sample('Goblin','Attack',.62).weapon[1]-12)<.0001,'authored impact is an exact sample, not interpolated around the contact key')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();if started then Run:Stop()end
report.pass=#report.failures==0;print('DEEPWOOD_REFINEMENT_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Refinement native failed')
