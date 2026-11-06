 local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
 local messages={}
 api.setPatternRemote({FireAllClients=function(_,m)table.insert(messages,m)end})
 api.setStoryTargetValidator(function()return true end)
 local function storyEnemy(kind,distance,version)
  local model=rig(kind,enemies,origin+Vector3.new(0,0,-distance),Vector3.new(0,0,1))
  model:SetAttribute('EnemyKind',kind);model:SetAttribute('DeepwoodEncounter','qa');model:SetAttribute('StoryRulesVersion',version)
  model:SetAttribute('StoryHealth',10000);model:SetAttribute('StoryDamage',120)
  model:SetAttribute('StoryAttackSpeed',1.265);model:SetAttribute('StoryMoveSpeed',1.265)
  return api.registerEnemy(model)
 end
 for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear'})do
  case('service-melee-only-'..kind,function()
   api.injectResolver(function()return 'knight'end);local player=spawnPlayer();local e=storyEnemy(kind,12,9)
   api.beginEnemyAttack(e,player,0);equal(e.attack,nil,'distant melee attack is not selected')
   e.root.Position=origin+Vector3.new(0,0,-4);api.beginEnemyAttack(e,player,10)
   equal(e.attack~=nil,true,'close melee attack starts')
   equal(e.attack.pattern.range<=6,true,'server uses melee geometry')
  end)
 end
 case('service-ice-elf-ranged',function()
  api.injectResolver(function()return 'knight'end);local player=spawnPlayer();player.humanoid.MaxHealth=10000;player.humanoid.Health=10000
  local e=storyEnemy('IceElf',20,9);messages={};api.beginEnemyAttack(e,player,0)
  equal(e.attack.pattern.shape,'projectile','Ice Elf keeps ranged profile')
  for frame=0,240 do sample(frame/60)end
  equal(player.humanoid.Health<10000,true,'Ice Elf hits from twenty studs')
 end)
 for _,classId in ipairs({'knight','elf','dwarf','mage'})do
  case('service-projectile-'..classId,function()
   api.injectResolver(function()return classId end);local player=spawnPlayer();player.humanoid.MaxHealth=10000;player.humanoid.Health=10000
   local e=storyEnemy('Shaman',12,9);equal(e.patternProfile~=nil,true,'new run selects pattern')
   messages={};api.beginEnemyAttack(e,player,0)
   for frame=0,200 do sample(frame/60)end
   local outcomes=0;for _,m in ipairs(messages)do if m.kind=='impact'then outcomes+=1;equal(m.target,player.character,'actual target');equal(m.result,'Hit','server result')end end
   equal(outcomes,1,'one actual projectile outcome')
   equal(player.humanoid.Health<10000,true,'actual service damage');equal(type(player.character:GetAttribute('K0HurtAt')),'number','existing hurt pulse retained')
   equal(type(player.character:GetAttribute('K0PatternHurtAt')),'number','common contact suppressed for specific outcome')
  end)
 end
 case('service-old-run-preserved',function()
  local e=storyEnemy('Shaman',12,8);equal(e.patternProfile,nil,'old run has old attacks')
 end)
 case('service-wall-cover',function()
  api.injectResolver(function()return 'knight'end);local player=spawnPlayer();local e=storyEnemy('Shaman',12,9)
  local wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(20,20,1);wall.Position=origin+Vector3.new(0,0,-6);wall.Parent=fixture
  local hp=player.humanoid.Health;api.beginEnemyAttack(e,player,0)
  for frame=0,200 do sample(frame/60)end
  equal(player.humanoid.Health,hp,'actual world wall blocks projectile')
  wall:Destroy()
 end)
 case('service-run-isolation',function()
  api.injectResolver(function()return 'knight'end);local player=spawnPlayer();local e=storyEnemy('Shaman',12,9)
  api.setStoryTargetValidator(function()return false end)
  local hp=player.humanoid.Health;api.beginEnemyAttack(e,player,0)
  for frame=0,200 do sample(frame/60)end
  equal(player.humanoid.Health,hp,'other run immune');api.setStoryTargetValidator(function()return true end)
 end)
 case('service-cancel-pause',function()
  api.injectResolver(function()return 'knight'end);local player=spawnPlayer();local e=storyEnemy('Shaman',12,9)
  local hp=player.humanoid.Health;api.beginEnemyAttack(e,player,0);e.model:SetAttribute('StoryPauseUntil',workspace:GetServerTimeNow()+30)
  sample(1.2);equal(e.attack,nil,'story phase cancels pending cast');sample(2);equal(player.humanoid.Health,hp,'cancel has no late damage')
 end)
 for _,result in ipairs({'Hit','Blocked','PerfectBlock','Absorbed','Dodged'})do
  case('service-outcome-'..result,function()
   api.injectResolver(function()return 'knight'end);local state=spawnPlayer();local e=storyEnemy('Goblin',3,9)
   messages={};state.mode='Idle';state.guardStarted=0
   if result=='Blocked'then state.mode='Block' end
   if result=='PerfectBlock'then state.mode='Block';state.guardStarted=.85 end
   if result=='Absorbed'then state.branchShield={amount=1000,expires=10}end
   if result=='Dodged'then state.mode='Dodge';state.dodge={started=.9}end
   local before=state.humanoid.Health
   api.applyPlayerHit(e,state,{origin=e.root.Position,direction=Vector3.new(0,0,1),definition={damage=120,blockable=true},hits={},geometryChecked=true,pattern={element='frost'},impact=state.root.Position,sequence=1,pulse=1,extraRecovery=0},1)
   local m=messages[#messages];equal(m.result,result,'exact defense result')
   equal(m.damage,before-state.humanoid.Health,'confirmed health loss in event')
   if result~='Hit' and result~='Blocked'then equal(state.character:GetAttribute('K0HurtAt'),nil,'no zero-damage hurt pulse')end
  end)
 end
 case('service-ground-uses-defense',function()
  api.injectResolver(function()return 'knight'end);local state=spawnPlayer();local e=storyEnemy('KingShaman',3,9)
  state.branchShield={amount=1000,expires=10};api.setClock(1);messages={}
  api.applyStoryHazard(e.model,state.root.Position,7,32)
  equal(state.humanoid.Health,state.humanoid.MaxHealth,'hazard absorbed by actual shield')
  equal(messages[#messages].result,'Absorbed','hazard publishes defense')
 end)

 case('service-partial-shield',function()
  api.injectResolver(function()return 'knight'end);local state=spawnPlayer();local e=storyEnemy('Goblin',3,9)
  state.branchShield={amount=10,expires=10};messages={}
  api.applyPlayerHit(e,state,{origin=e.root.Position,direction=Vector3.new(0,0,1),definition={damage=120,blockable=true},hits={},geometryChecked=true,pattern={element='fire'},impact=state.root.Position,sequence=2,pulse=1,extraRecovery=0},1)
  local m=messages[#messages];equal(m.absorbed,10,'partial absorption');equal(m.damage>0,true,'overflow HP loss');equal(m.result,'Hit','one overflow contact')
 end)
 case('service-ForceField-zero-hurt',function()
  api.injectResolver(function()return 'knight'end);local state=spawnPlayer();local e=storyEnemy('Goblin',3,9)
  local field=Instance.new('ForceField');field.Parent=state.character;messages={}
  api.applyPlayerHit(e,state,{origin=e.root.Position,direction=Vector3.new(0,0,1),definition={damage=120,blockable=true},hits={},geometryChecked=true,pattern={element='frost'},impact=state.root.Position,sequence=3,pulse=1,extraRecovery=0},1)
  equal(messages[#messages].result,'Prevented','ForceField does not claim health loss');equal(state.character:GetAttribute('K0HurtAt'),nil,'ForceField has no hurt pulse')
 end)

 case('service-front-guard-has-side-counter',function()
  api.injectResolver(function()return 'knight'end);local state=spawnPlayer()
  local front=storyEnemy('SkeletonKnight',3,9);api.beginEnemyAttack(front,state,0)
  local before=front.humanoid.Health
  api.damageEnemy(state,front,{hits={},hitCount=0,attackPower=100,direction=Vector3.new(0,0,-1),definition={damage=1,posture=0}},.2)
  equal(before-front.humanoid.Health,70,'frontal windup guard reduces thirty percent')
  local side=storyEnemy('SkeletonKnight',3,9);api.beginEnemyAttack(side,state,0)
  state.root.Position=origin+Vector3.new(5,0,-3);before=side.humanoid.Health
  api.damageEnemy(state,side,{hits={},hitCount=0,attackPower=100,direction=Vector3.new(-1,0,0),definition={damage=1,posture=0}},.2)
  equal(before-side.humanoid.Health,100,'side attack bypasses temporary guard')
 end)
