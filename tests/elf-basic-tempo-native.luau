-- Native server release, motion visibility and cadence at several DEX rates.
-- Trusted identity is mocked; damage, sampling and bow motion use real modules.
local report={kind='ELF_BASIC_TEMPO_NATIVE',checks=0,cases=0,failures={}}
local function check(v,label)report.checks+=1;assert(v,label)end
local function near(a,b,label)check(math.abs(a-b)<.000001,label)end
local folder=Instance.new('Folder');folder.Name='ElfTempoQA';folder.Parent=workspace
local module=game.ServerScriptService.Server.Combat.CombatService:Clone()
module.Name='ElfTempoPrivate'
module.Source=module.Source:gsub('\nreturn CombatService%s*$',function()return [[
return {start=startAttack,sample=processCombatSamples,clear=clearAction,players=playerStates,enemies=enemyStates,
 context=function(fn)contextResolver=fn end,setFolder=function(v)enemyFolder=v end}
]]end);module.Parent=game.ServerScriptService.Server.Combat
local function rig(name,position)
 local c=Instance.new('Model');c.Name=name
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.CFrame=CFrame.new(position);root.Anchored=true;root.CanCollide=false;root.Parent=c
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=100000;h.Health=100000;h.Parent=c
 c.PrimaryPart=root;c.Parent=folder;return c,root,h
end
local ok,err=xpcall(function()
 local api=require(module);api.setFolder(folder)
 local Config=require(game.ReplicatedStorage.Shared.K0Config)
 local Growth=require(game.ReplicatedStorage.Shared.HeroProgression)
 local Bow=require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
 local profile=Config.BasicAttackProfiles.elf;local d=profile.attacks[1]
 near(d.windup+d.active+d.recovery,1.2,'Sustained cadence remains 1.2s')
 check(d.windup>=.75 and d.active+d.recovery<=.45,'Draw occupies most of the cycle')
 local c,root,h=rig('Archer',Vector3.new(20000,1000,20000))
 c:SetAttribute('K0ClassId','elf');c:SetAttribute('K0SpawnReady',true)
 local target,tr,th=rig('Target',root.Position+Vector3.new(0,0,-12))
 local player={Parent=game.Players,Character=c,UserId=-9877}
 api.context(function()return {heroId='tempo',baseClassId='elf',epoch=1,characterGeneration=1}end)
 for _,dex in {0,100,200,316}do for _,fps in {30,60,144}do
  local growth=Growth.new(80);growth.stats.DEX=dex
  local derived=Growth.derived('elf',growth);derived.physicalPower=100
  local rate=derived.attackRate;local release=d.windup/rate;local duration=1.2/rate
  local state={player=player,character=c,root=root,humanoid=h,heroId='tempo',heroEpoch=1,characterGeneration=1,
   baseClassId='elf',attackProfile=profile,derived=derived,combo=0,lastAttackFinished=100,attackSeq=0,feedbackSeq=0,
   arrowSeq=0,mode='Idle',lastMotionAt=100,lastMotionPosition=root.Position,lastSafePivot=c:GetPivot(),movementBudget=Config.MovementBudget}
  api.players[player]=state;th.Health=100000
  api.enemies[target]={id=1,model=target,root=tr,humanoid=th,mode='Idle',kind='Goblin',config=Config.Enemy.Goblin,
   posture=100000,postureImmuneUntil=0,lastPostureDamage=0,spawnPosition=tr.Position}
  c:SetAttribute('K0State','Dodge');Bow.forCharacter(c,99)
  c:SetAttribute('K0ArrowReleaseProtocol',1);c:SetAttribute('K0ArrowRelease',nil);c:SetAttribute('K0ArrowVisual',nil)
  api.start(state,100,target);c:SetAttribute('K0AttackStartedAt',100)
  near(state.attack.definition.windup,release,'Server release respects DEX')
  near(state.attack.definition.windup+state.attack.definition.active+state.attack.definition.recovery,duration,'Server cadence respects DEX')
  api.sample(100+release-.00001)
  near(th.Health,100000,'No damage before the visible release')
  check(Bow.forCharacter(c,100+release-.00001).nocked,'Arrow is still nocked immediately before server release')
  check(Bow.forCharacter(c,100+release+.00001).nocked,'Arrow waits for the actual due server sample')
  local firstHit
  for frame=0,math.ceil(duration*fps)-1 do
   local now=100+frame/fps;local before=th.Health;api.sample(now)
   if th.Health<before then firstHit=firstHit or now-100;check(not Bow.forCharacter(c,now+.00001).nocked,'Confirmed server shot releases the visible arrow')end
   local after=th.Health;api.sample(now);near(th.Health,after,'Repeated sample cannot duplicate damage')
  end
  check(firstHit and firstHit>=release-.000001 and firstHit<=release+1/fps+.000001,'Damage occurs on first due server frame')
  near(100000-th.Health,70,'Basic damage per cycle is preserved')
  near(state.arrowSeq,1,'Only one arrow per attack')
  check(Bow.forCharacter(c,100+duration+.00001).time==0,'Hands return to idle by next attack')
  api.clear(state);report.cases+=1
 end end
end,debug.traceback)
module:Destroy();folder:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;print('ELF_BASIC_TEMPO_NATIVE '..game.HttpService:JSONEncode(report))
assert(ok,'Elf basic tempo regression failed')
