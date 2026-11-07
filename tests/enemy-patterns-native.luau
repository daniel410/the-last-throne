assert(game.PlaceId==0,'Use isolated empty local Place')
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
for path,s in pairs(sources)do check(loadstring(s,'@'..path)~=nil,'compile '..path)end
local P,R,G=deps.EnemyPatterns,deps.EnemyPatternRuntime,deps.EnemyAttackGeometry
local folder=Instance.new('Folder');folder.Name='PatternQA';folder.Parent=workspace
local function actor(name,position)
 local m=Instance.new('Model');m.Name=name
 for _,name in ipairs({'HumanoidRootPart','Torso','Head','Left Arm','Right Arm','Left Leg','Right Leg'})do
  local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CanCollide=false;p.Size=Vector3.new(2,2,1);p.Position=position;p.Parent=m
 end
 local h=Instance.new('Humanoid');h.MaxHealth=1000;h.Health=1000;h.Parent=m;m.PrimaryPart=m.HumanoidRootPart;m.Parent=folder
 return {model=m,character=m,root=m.HumanoidRootPart,humanoid=h,config={attacks={{damage=120}},leashRange=65},spawnPosition=position,attackSeq=0}
end
local enemy=actor('Caster',Vector3.new(0,4,0));local target=actor('Hero',Vector3.new(0,4,-12))
local events,hits={},{}
local function emit(m)table.insert(events,m)end
local function hit(e,t,a,current)table.insert(hits,{target=t,pulse=a.pulse,damage=a.definition.damage});t.humanoid:TakeDamage(a.definition.damage)end
local wallEnabled=false;local allowed=true
local ctx={emit=emit,hit=hit,valid=function()return allowed end,
 raycast=function(from,to)if wallEnabled and from.Z>=-5 and to.Z<=-5 then return {Position=Vector3.new(from.X,from.Y,-5)}end end,
 floor=function(pos)return {Position=Vector3.new(pos.X,1,pos.Z)}end}
local function simulate(d,distance)
 target.root.Position=Vector3.new(0,4,-distance);target.humanoid.Health=1000;enemy.root.Position=Vector3.new(0,4,0)
 hits={};events={};enemy.attack=nil
 R.begin(enemy,target,d,10,emit)
 for frame=0,math.ceil((d.windup+d.active)*60)do R.step(enemy,10+frame/60,{target},ctx)end
 return #hits
end
for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear'})do
 for _,d in ipairs(P.get(kind).attacks)do
  check(simulate(d,4)==1,'melee connects up close: '..d.id)
  check(simulate(d,12)==0,'melee cannot hit distant target: '..d.id)
  for _,event in ipairs(events)do check(event.kind~='projectile','melee emits no projectile: '..d.id)end
  check(enemy.root.Position==Vector3.new(0,4,0),'melee has no ranged charge: '..d.id)
 end
 check(P.choose(kind,12,{},100)==nil,'no distant attack selection: '..kind)
end
for _,d in ipairs(P.get('IceElf').attacks)do
 check(simulate(d,20)==1,'Ice Elf retains ranged hit: '..d.id)
 local fired=false;for _,event in ipairs(events)do if event.kind=='projectile'then fired=true end end
 check(fired,'Ice Elf fires visible projectile: '..d.id)
end
local cast=P.get('Shaman').attacks[1]
check(simulate(cast,12)==1,'traveling magic hits exactly once')
check(target.humanoid.Health==880,'authoritative payload damage')
wallEnabled=true;check(simulate(cast,12)==0,'wall stops magic');wallEnabled=false
allowed=false;check(simulate(cast,12)==0,'different run target immune');allowed=true
local fan=P.get('KingShaman').attacks[2]
check(simulate(fan,12)<=fan.pulses,'fan cannot multiply damage on same target')
local ring=P.get('KingOgre').attacks[4]
check(simulate(ring,0)==0,'ring center safe');check(simulate(ring,5)==1,'ring band unsafe')
R.begin(enemy,target,cast,20,emit);R.step(enemy,24,{target},ctx);check(#enemy.attack.projectiles==0,'late magic release not replayed')
R.cancel(enemy,emit);check(events[#events].kind=='cancel' and enemy.model:GetAttribute('K0PatternId')==nil,'cancel clears client snapshot')
local classes,actions=0,0
for kind,profile in pairs(P.profiles)do
 classes+=1;enemy.kind=kind;enemy.model:SetAttribute('EnemyKind',kind)
 for _,d in ipairs(profile.attacks)do
  actions+=1;simulate(d,4)
  local sum=0;local seen={};for _,entry in ipairs(hits)do check(not seen[entry.pulse],'one hit per pulse');seen[entry.pulse]=true;sum+=entry.damage end
  check(sum<=123,'combo total stays near original budget')
  check(#enemy.attack.projectiles<=9,'bounded missiles')
  local pose=deps.EnemyPatternPose.phase(enemy.model,workspace:GetServerTimeNow(),{start=workspace:GetServerTimeNow()-.5,w=d.windup,a=d.active,r=d.recovery})
  check(type(pose)=='number' and pose>=0 and pose<=1,'finite native per-strike pose')
 end
end
local nativeKinds={'Webling','Silkweaver','Barkstalker','Gloambat','VenomcoilCentipede','AncientHollowbark','VenomcoilKing','WidowQueen'}
local modelParts=0
for _,kind in ipairs(nativeKinds)do
 local rig=actor(kind,Vector3.new(30,4,0)).model;rig:SetAttribute('EnemyKind',kind)
 local visual=deps.GloamwoodAppearance.attach(rig,kind,3,1)
 check(rig:GetAttribute('GloamwoodMeshyVersion')==1 and rig:GetAttribute('GloamwoodPrototypeVersion')==nil,'imported skinned geometry version')
 deps.EnemyModelDetails.attach(rig,kind,visual,3,rig:GetAttribute('TdMonsterTargetHeight'))
 for _,o in ipairs(visual:GetDescendants())do if o:IsA('BasePart')then modelParts+=1;check(not o.CanCollide and not o.CanTouch and not o.CanQuery and o.Massless,'visual-only geometry')end end
 check(rig:FindFirstChild('EnemyCastSocket',true)~=nil,'cast socket')
end
for _,kind in ipairs({'Warlord','Veyr','KingOgre','Shaman'})do
 local rig=actor(kind,Vector3.new(30,4,0)).model;local visual=Instance.new('Model');visual.Name='TdMonsterVisual';visual.Parent=rig
 local staff=Instance.new('Part');staff.Name='ArmR';staff.Size=Vector3.new(1,5,1);staff.Parent=visual
 deps.EnemyModelDetails.attach(rig,kind,visual,3,8)
 local n=#visual.CombatDetails:GetChildren();deps.EnemyModelDetails.attach(rig,kind,visual,3,8)
 check(#visual.CombatDetails:GetChildren()==n and n>0,'armor/focus idempotent')
end
-- Actual client geometry construction can run without a local Player for remote contacts.
local fx=deps.EnemyPatternEffects
local before=#workspace:GetDescendants()
check(pcall(fx.receive,{kind='projectile',id=cast.id,origin=Vector3.zero}),'streamed-out model ignored')
check(pcall(fx.receive,{kind='impact',position=Vector3.zero,target=target.model}),'streamed-out attacker ignored')
fx.receive({kind='projectile',model=enemy.model,sequence=555,id=cast.id,origin=Vector3.new(0,5,0),direction=Vector3.new(0,0,-1),pulse=1,shot=1,at=workspace:GetServerTimeNow()})
check(workspace:FindFirstChild('EnemyMagicProjectile')~=nil,'magic native geometry')
fx.receive({kind='projectileEnd',model=enemy.model,sequence=555,pulse=1,shot=1})
check(workspace:FindFirstChild('EnemyMagicProjectile')==nil,'magic stop removes actual projectile')
for i,result in ipairs({'Hit','Blocked','PerfectBlock','Absorbed','Dodged','Prevented'})do
 fx.receive({kind='impact',model=enemy.model,target=target.model,sequence=80,pulse=i,position=target.root.Position,source=enemy.root.Position,element='frost',result=result,damage=result=='Hit' and 10 or 0,absorbed=0,at=workspace:GetServerTimeNow()})
end
check(workspace:FindFirstChild('EnemyContactFX')~=nil,'native frost contact')
local hurt=deps.K0PlayerHitFeedback
local current=workspace:GetServerTimeNow();target.model:SetAttribute('K0HurtAt',current-.05)
target.model:SetAttribute('K0HurtSource',target.root.Position+Vector3.new(10,0,0))
local _,_,right=hurt.bodyPose(target.model,current):ToOrientation()
target.model:SetAttribute('K0HurtSource',target.root.Position-Vector3.new(10,0,0))
local _,_,left=hurt.bodyPose(target.model,current):ToOrientation()
check(right*left<0,'hit reaction distinguishes left/right')
check(hurt.bodyPose(target.model,current+.3)==nil,'hit body reaction ends')
local groundWorld=Instance.new('Folder');groundWorld.Name='DeepwoodCampaign';groundWorld.Parent=workspace
local floorPart=Instance.new('Part');floorPart.Name='Ground';floorPart.Anchored=true;floorPart.Size=Vector3.new(100,2,100);floorPart.Position=Vector3.new(0,-1,0);floorPart.Parent=groundWorld
local overhead=Instance.new('Part');overhead.Name='SceneryAboveGround';overhead.Anchored=true;overhead.Size=Vector3.new(100,1,100);overhead.Position=Vector3.new(0,5,0);overhead.Parent=groundWorld
local sampleShapes={}
for _,profile in pairs(P.profiles)do for _,d in ipairs(profile.attacks)do
 if not sampleShapes[d.shape]then
  sampleShapes[d.shape]=true
  enemy.model:SetAttribute('EnemyKind',d.id:match('^(.-)%.'))
  local at=workspace:GetServerTimeNow()
  R.begin(enemy,target,d,at,function(m)fx.receive(m)end)
  fx.render(at+.4)
  local warning=workspace:FindFirstChild('EnemyPatternWarning')
  check(warning~=nil and #warning:GetChildren()>0,'native warning shape '..d.shape)
  for _,o in ipairs(warning:GetChildren())do check(not o.CanCollide and not o.CanQuery,'nonblocking warning');check(math.abs(o.Position.Y-.12)<.01,'warning projects onto floor, not scenery or root height')end
  R.cancel(enemy,function(m)fx.receive(m)end)
  check(workspace:FindFirstChild('EnemyPatternWarning')==nil,'warning canceled '..d.shape)
 end
end end
-- Streaming floor absence must hide the warning, never fall back to root height.
local d=P.get('Orc').attacks[1];local at=workspace:GetServerTimeNow()
R.begin(enemy,target,d,at,function(m)fx.receive(m)end);fx.render(at+.4)
check(#workspace:FindFirstChild('EnemyPatternWarning'):GetChildren()>0,'warning starts on existing floor')
floorPart:Destroy();fx.render(at+.5)
local warning=workspace:FindFirstChild('EnemyPatternWarning')
check(warning and #warning:GetChildren()==0,'missing floor emits no airborne warning')
-- A streamed-in floor can restore this same warning.
local restored=Instance.new('Part');restored.Name='Ground';restored.Anchored=true;restored.Size=Vector3.new(100,2,100);restored.Position=Vector3.new(0,-1,0);restored.Parent=groundWorld
fx.render(at+.6);warning=workspace:FindFirstChild('EnemyPatternWarning');check(#warning:GetChildren()>0,'streamed floor restores warning')
R.cancel(enemy,function(m)fx.receive(m)end)
groundWorld:Destroy();folder:Destroy()
print('ENEMY_PATTERN_NATIVE '..game:GetService('HttpService'):JSONEncode({checks=checks,kinds=classes,actions=actions,modelParts=modelParts,scope='isolated engine modules; no accounts/normal gameplay/device acceptance'}))
