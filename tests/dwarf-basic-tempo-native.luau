-- Actual server start, sampling, damage and buffering for both melee classes.
-- Native Humanoids with a mock trusted hero identity; no RemoteEvent transport.
local report={kind='MELEE_BASIC_TEMPO_NATIVE',checks=0,failures={},cases={},maxRoundedDPSDifference=0}
local function check(v,label)report.checks+=1;assert(v,label)end
local function near(a,b,label)check(math.abs(a-b)<.000001,label..' '..a..'/'..b)end
local folder=Instance.new('Folder');folder.Name='MeleeTempoQA';folder.Parent=workspace
local module=game.ServerScriptService.Server.Combat.CombatService:Clone();module.Name='MeleeTempoPrivate'
module.Source=module.Source:gsub('\nreturn CombatService%s*$',function()return [[
return {start=startAttack,sample=processCombatSamples,step=stepPlayer,accept=acceptAction,clear=clearAction,
 players=playerStates,enemies=enemyStates,
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
 local expected={knight={periods={.588,.644,.868},oldPeriods={.42,.46,.62},oldDamage={.75,.9,1.2},posture={12,14,24},oldHit={.16,.18,.26}},
  dwarf={periods={.8},oldPeriods={.42},oldDamage={.75},posture={12},oldHit={.22}}}
 local c,root,h=rig('Hero',Vector3.new(20000,1000,20000));c:SetAttribute('K0SpawnReady',true)
 local target,tr,th=rig('Target',root.Position+Vector3.new(0,0,-3))
 local player={Parent=game.Players,Character=c,UserId=-9876}
 for _,classId in {'knight','dwarf'}do
  local reference=expected[classId];local profile=Config.BasicAttackProfiles[classId]
  local mean=0
  for combo,d in profile.attacks do
   local period=reference.periods[combo];mean+=period/#profile.attacks
   near(d.windup+d.active+d.recovery,period,'Accepted base cadence '..classId..'/'..combo)
   near(d.damage/period,reference.oldDamage[combo]/reference.oldPeriods[combo],'Unrounded sustained basic DPS preserved')
  end
  near(mean,classId=='knight'and .70 or .80,'Class mean period')
  c:SetAttribute('K0ClassId',classId)
  api.context(function()return {heroId='tempo',baseClassId=classId,epoch=1,characterGeneration=1}end)
  for combo,d in profile.attacks do for _,dex in {0,40,100,200,300,316}do for _,fps in {30,60,144}do
   local g=Growth.new(80);g.stats.DEX=dex;local derived=Growth.derived(classId,g)
   near(derived.attackRate,1+math.min(1,dex*.005),'DEX attack coefficient/cap preserved')
   near(derived.moveRate,1+math.min(.3,dex*.001),'DEX movement coefficient/cap preserved')
   for _,power in {100,337,969}do
    derived.physicalPower=power
    local state={player=player,character=c,root=root,humanoid=h,heroId='tempo',heroEpoch=1,characterGeneration=1,
     baseClassId=classId,attackProfile=profile,derived=derived,combo=combo-1,lastAttackFinished=100,attackSeq=0,feedbackSeq=0,mode='Idle',
     lastMotionAt=100,lastMotionPosition=root.Position,lastSafePivot=c:GetPivot(),movementBudget=Config.MovementBudget}
    api.players[player]=state;th.Health=100000
    local enemy={id=1,model=target,root=tr,humanoid=th,mode='Idle',kind='Goblin',config=Config.Enemy.Goblin,
     posture=100000,postureImmuneUntil=0,lastPostureDamage=0,spawnPosition=tr.Position}
    api.enemies[target]=enemy;api.start(state,100,nil)
    local attack=state.attack;local duration=reference.periods[combo]/derived.attackRate
    local impact=reference.oldHit[combo]*reference.periods[combo]/reference.oldPeriods[combo]/derived.attackRate
    near(state.combo,combo,'Server selected the requested combo')
    near(attack.definition.windup+attack.definition.active+attack.definition.recovery,duration,'Server uses DEX-scaled cadence')
    near(attack.definition.windup+(attack.definition.hitDelay or 0),impact,'Contact clock scales with motion')
    api.sample(100+impact-.00001);near(th.Health,100000,'No damage before visible impact')
    local firstHit
    for frame=0,math.ceil(duration*fps)-1 do
     local current=100+frame/fps;local before=th.Health;api.sample(current)
     if th.Health<before then firstHit=firstHit or current-100 end
     local after=th.Health;api.sample(current);near(th.Health,after,'Repeated server sample cannot duplicate damage')
    end
    check(firstHit~=nil and firstHit>=impact-.000001 and firstHit<=impact+1/fps+.000001,'First due server frame applies the hit')
    local actualDamage=100000-th.Health
    near(actualDamage,math.floor(power*d.damage+.5),'Actual compensated server damage')
    near(attack.hitCount,1,'One damage event per target/action')
    near(enemy.posture,100000-reference.posture[combo],'Posture per hit preserved')
    local beforeDPS=math.floor(power*reference.oldDamage[combo]+.5)/(reference.oldPeriods[combo]/derived.attackRate)
    local difference=math.abs((actualDamage/duration)/beforeDPS-1)
    report.maxRoundedDPSDifference=math.max(report.maxRoundedDPSDifference,difference)
    check(difference<.01,'Rounded basic DPS remains within 1% at sampled powers')
    api.accept(state,'Attack',nil,100+duration-.00001,nil)
    check(state.attack==attack and state.attackSeq==1,'Repeated input cannot accelerate cadence')
    api.step(state,100+duration+.000001,0,true)
    check(state.attackSeq==2 and state.attack.started>=100+duration,'Buffer waits for the new cadence')
    near(state.combo,combo%#profile.attacks+1,'Buffered combo advances correctly')
    table.insert(report.cases,{classId=classId,combo=combo,dex=dex,fps=fps,power=power,period=duration,impact=impact,damage=actualDamage,dpsDifference=difference})
    api.clear(state)
   end
  end end end
 end
end,debug.traceback)
module:Destroy();folder:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;print('MELEE_BASIC_TEMPO_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,'Melee tempo regression failed')
