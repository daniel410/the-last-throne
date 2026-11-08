-- Actual server start, sampling, damage, input buffering and next-action gate.
-- Native Humanoids with a mock trusted hero identity; no real RemoteEvent transport.
local report={kind='DWARF_BASIC_TEMPO_NATIVE',checks=0,failures={},cases={},maxRoundedDPSDifference=0}
local function check(v,label)report.checks+=1;assert(v,label)end
local function near(a,b,label)check(math.abs(a-b)<.000001,label..' '..a..'/'..b)end
local folder=Instance.new('Folder');folder.Name='DwarfTempoQA';folder.Parent=workspace
local module=game.ServerScriptService.Server.Combat.CombatService:Clone();module.Name='DwarfTempoPrivate'
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
 local d=Config.BasicAttackProfiles.dwarf.attacks[1]
 near(d.windup+d.active+d.recovery,.65,'Dwarf has a 0.65s base cadence')
 near(d.damage/.65,.75/.42,'Unrounded sustained basic DPS is preserved')
 for i,period in {.42,.46,.62}do local k=Config.BasicAttackProfiles.knight.attacks[i];near(k.windup+k.active+k.recovery,period,'Knight cadence preserved')end
 for i,value in {.75,.9,1.2}do near(Config.BasicAttackProfiles.knight.attacks[i].damage,value,'Knight damage preserved')end
 local c,root,h=rig('Dwarf',Vector3.new(20000,1000,20000));c:SetAttribute('K0SpawnReady',true);c:SetAttribute('K0ClassId','dwarf')
 local target,tr,th=rig('Target',root.Position+Vector3.new(0,0,-3))
 local player={Parent=game.Players,Character=c,UserId=-9876}
 api.context(function()return {heroId='tempo',baseClassId='dwarf',epoch=1,characterGeneration=1}end)
 for _,dex in {0,40,100,200,300,316}do for _,fps in {30,60,144}do
  local g=Growth.new(80);g.stats.DEX=dex;local derived=Growth.derived('dwarf',g)
  near(derived.attackRate,1+math.min(1,dex*.005),'DEX attack coefficient and cap preserved')
  near(derived.moveRate,1+math.min(.3,dex*.001),'DEX movement coefficient and cap preserved')
  for _,power in {100,337,969}do
   derived.physicalPower=power
   local state={player=player,character=c,root=root,humanoid=h,heroId='tempo',heroEpoch=1,characterGeneration=1,
    baseClassId='dwarf',attackProfile=Config.BasicAttackProfiles.dwarf,derived=derived,
    combo=0,lastAttackFinished=-math.huge,attackSeq=0,feedbackSeq=0,mode='Idle',
    lastMotionAt=100,lastMotionPosition=root.Position,lastSafePivot=c:GetPivot(),movementBudget=Config.MovementBudget}
   api.players[player]=state
   th.Health=100000
   local enemy={id=1,model=target,root=tr,humanoid=th,mode='Idle',kind='Goblin',config=Config.Enemy.Goblin,
    posture=100000,postureImmuneUntil=0,lastPostureDamage=0,spawnPosition=tr.Position}
   api.enemies[target]=enemy
   api.start(state,100,nil)
   local attack=state.attack;local duration=.65/derived.attackRate;local impact=(.22*.65/.42)/derived.attackRate
   near(attack.definition.windup+attack.definition.active+attack.definition.recovery,duration,'Server uses DEX-scaled cadence')
   near(attack.definition.windup+attack.definition.hitDelay,impact,'Contact clock scales with full motion')
   api.sample(100+impact-.00001);near(th.Health,100000,'No damage before visible impact')
   local firstHit
   for frame=0,math.ceil(duration*fps)-1 do
    local current=100+frame/fps;local before=th.Health
    api.sample(current)
    if th.Health<before then firstHit=firstHit or current-100 end
    local after=th.Health;api.sample(current);near(th.Health,after,'Repeated server sample cannot duplicate damage')
   end
   check(firstHit~=nil and firstHit>=impact-.000001 and firstHit<=impact+1/fps+.000001,'First hit occurs on first due server frame')
   local actualDamage=100000-th.Health
   near(actualDamage,math.floor(power*d.damage+.5),'Actual server damage uses compensated per-hit coefficient')
   near(attack.hitCount,1,'One damage event per target and action')
   near(enemy.posture,99988,'Posture remains 12 per hit')
   local beforeDPS=math.floor(power*.75+.5)/(.42/derived.attackRate)
   local afterDPS=actualDamage/duration
   local difference=math.abs(afterDPS/beforeDPS-1);report.maxRoundedDPSDifference=math.max(report.maxRoundedDPSDifference,difference)
   check(difference<.01,'Actual rounded basic DPS remains within 1% at sampled powers')
   api.accept(state,'Attack',nil,100+duration-.00001,nil)
   check(state.attack==attack and state.attackSeq==1,'Repeated input cannot start a faster attack')
   api.step(state,100+duration+.000001,0,true)
   check(state.attackSeq==2 and state.attack.started>=100+duration,'Buffered next attack waits for the new full cadence')
   table.insert(report.cases,{dex=dex,fps=fps,power=power,period=duration,impact=impact,damage=actualDamage,dpsDifference=difference})
   api.clear(state)
  end
 end end
end,debug.traceback)
module:Destroy();folder:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;print('DWARF_BASIC_TEMPO_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,'Dwarf tempo regression failed')
