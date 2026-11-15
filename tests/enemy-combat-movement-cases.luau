 -- Appended inside the isolated CombatService fixture by the service assembler.
 local TacticalProfiles=require(game.ReplicatedStorage.Shared.EnemyCombatProfiles)
 local TacticalDecisions=require(game.ReplicatedStorage.Shared.EnemyCombatTactics)
 local function withTacticalSurface(body)
  local folder=Instance.new('Folder');folder.Name='TacticalSurface';folder.Parent=fixture
  local function platform(position,size)
   local part=Instance.new('Part');part.Name='Support';part.Anchored=true
   part.Size=size or Vector3.new(80,1,80);part.Position=position-Vector3.new(0,3.5,0);part.Parent=folder
   return part
  end
  local ok,err=xpcall(function()body(platform,folder)end,debug.traceback)
  folder:Destroy()
  assert(ok,err)
 end
 local function horizontal(v)return Vector3.new(v.X,0,v.Z)end
 local function retreatCandidate(e,target,current)
  local distance=horizontal(target.root.Position-e.root.Position).Magnitude
  local radial,tangent=TacticalDecisions.movement(e.kind,distance,e.model:GetAttribute('StoryDifficulty')or 'Easy',e.model:GetAttribute('K0EnemyMotionSeed')or 0,current)
  local forward=horizontal(target.root.Position-e.root.Position).Unit
  local right=Vector3.new(-forward.Z,0,forward.X)
  return e.root.Position+(forward*radial+right*tangent).Unit*math.min(5,math.max(2,distance))
 end
 case('service-caster-bounded-retreat',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('Shaman',4,9)
  e.model:SetAttribute('K0EnemyMotionSeed',0);e.model:SetAttribute('StoryDifficulty','Easy')
  withTacticalSurface(function(platform)
   platform(e.root.Position)
   local destination,intent=api.tacticalDestination(e,target,4,0,true)
   local travel=horizontal(destination-e.root.Position)
   local forward=horizontal(target.root.Position-e.root.Position).Unit
   equal(intent,'Retreat','close caster declares finite retreat')
   equal(travel:Dot(forward)<0,true,'retreat moves away from the threat')
   equal(travel.Magnitude>0 and travel.Magnitude<=5.001,true,'one decision has bounded travel')
   equal(horizontal(destination-e.spawnPosition).Magnitude<e.config.leashRange-2,true,'retreat stays inside encounter leash')
   equal(destination.Y,e.root.Position.Y,'tactical destination preserves supported floor height')
   local held,holdIntent=api.tacticalDestination(e,target,4,0,false)
   equal(holdIntent,'Hold','expired retreat budget changes intent')
   equal(horizontal(held-e.root.Position):Dot(forward)>=-.001,true,'expired retreat budget prevents backward travel')
   equal(horizontal(held-e.root.Position).Magnitude<travel.Magnitude,true,'small hold strafe retains its movement weight')
  end)
 end)
 case('service-retreat-rejects-midpath-gap',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('Shaman',4,9)
  e.model:SetAttribute('K0EnemyMotionSeed',0)
  withTacticalSurface(function(platform,folder)
   local candidate=retreatCandidate(e,target,0)
   platform(e.root.Position,Vector3.new(1,1,1));platform(candidate,Vector3.new(1,1,1))
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={folder}
   equal(workspace:Raycast(candidate+Vector3.new(0,4,0),Vector3.new(0,-16,0),ray)~=nil,true,'retreat endpoint has actual support')
   local middle=e.root.Position:Lerp(candidate,.5)
   equal(workspace:Raycast(middle+Vector3.new(0,4,0),Vector3.new(0,-16,0),ray),nil,'middle of retreat crosses an actual gap')
   local destination,intent=api.tacticalDestination(e,target,4,0,true)
   equal(destination,e.root.Position,'supported endpoint cannot bypass missing intermediate ground')
   equal(intent,'Hold','gap turns retreat into a stand-and-fight')
  end)
 end)
 case('service-retreat-respects-leash',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('IceElf',4,9)
  e.model:SetAttribute('K0EnemyMotionSeed',0)
  e.config=table.clone(e.config);e.config.leashRange=4
  withTacticalSurface(function(platform)
   platform(e.root.Position)
   local destination,intent=api.tacticalDestination(e,target,4,0,true)
   equal(destination,e.root.Position,'retreat cannot leave its encounter bounds')
   equal(intent,'Hold','leash edge remains combat-capable')
  end)
 end)
 for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear','SkeletonKnight','VenomcoilCentipede'})do
  case('service-resolved-melee-boundary-'..kind,function()
   api.injectResolver(function()return 'knight'end)
   local target=spawnPlayer();local e=storyEnemy(kind,12,9)
   for _,difficulty in ipairs({'Easy','Hard','Insane','Hell'})do
    e.model:SetAttribute('StoryDifficulty',difficulty)
    equal(api.chooseEnemyPattern(e,target,0),nil,'final '..difficulty..' melee definition rejects distant target')
   end
   e.root.Position=origin+Vector3.new(0,0,-5)
   local selected=api.chooseEnemyPattern(e,target,0)
   equal(selected~=nil,true,'melee can select a supported close attack')
   equal(selected.range<=6 and selected.maxRange<=6,true,'server selection returns final weapon reach')
   equal(selected.combatProfileVersion,TacticalProfiles.version,'server selection resolved the combat profile')
  end)
 end
 case('service-resolved-difficulty-clones',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('Shaman',20,9)
  e.model:SetAttribute('StoryDifficulty','Easy');local easy=api.chooseEnemyPattern(e,target,0)
  e.model:SetAttribute('StoryDifficulty','Hell');local hell=api.chooseEnemyPattern(e,target,0)
  equal(easy.id,hell.id,'same distance uses the same authored spell identity')
  equal(easy.windup>hell.windup and easy.recovery>hell.recovery,true,'server resolves difficulty teaching windows')
  equal(easy.cooldown>hell.cooldown,true,'server resolves difficulty action cadence')
  equal(easy~=hell,true,'each selection owns its final definition')
  hell.windup=99
  local again=api.chooseEnemyPattern(e,target,0)
  equal(again.windup<99,true,'a selected attack cannot mutate future casts')
  equal(again.windup,Patterns.get('Shaman').attacks[1].windup,'authored spell windup survives clone mutation')
 end)
 case('service-resolved-boss-phase',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('LichSovereign',20,9)
  e.model:SetAttribute('StoryDifficulty','Hell')
  local first=api.chooseEnemyPattern(e,target,0)
  e.humanoid.Health=e.humanoid.MaxHealth*.5
  local second=api.chooseEnemyPattern(e,target,0)
  equal(first.phase,1,'healthy boss opens in its first phase')
  equal(second.phase,2,'actual server boss health selects second phase')
  equal(second.phaseName~=first.phaseName,true,'second phase changes attack combinations without resetting health')
 end)

 case('service-consumed-waypoints-hold-position',function()
  local e=storyEnemy('Goblin',4,9)
  e.nextMoveAt=0;e.nextPathAt=math.huge;e.pathPending=false
  e.waypoints={{Position=e.root.Position}};e.waypointIndex=1
  local goal=e.root.Position+Vector3.new(0,0,-12)
  e.humanoid:MoveTo(goal)
  api.moveEnemy(e,goal,0,true)
  equal(e.waypointIndex,2,'last supported path waypoint is consumed')
  equal(e.humanoid.WalkToPoint,e.root.Position,'exhausted path waits at its current supported point')
  equal(e.pathPending,false,'path retry cooldown does not start another asynchronous request')
 end)

 case('service-retreat-expiry-stops-old-goal',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('Shaman',4,9)
  e.model:SetAttribute('K0EnemyMotionSeed',0)
  e.repositionUntil=.5;e.repositionReady=5;e.nextMoveAt=10
  e.tacticalGoal=e.root.Position+Vector3.new(0,0,-4);e.tacticalIntent='Retreat'
  e.patternHistory.ready={};for _,d in ipairs(Patterns.get('Shaman').attacks)do e.patternHistory.ready[d.id]=100 end
  withTacticalSurface(function(platform)
   platform(e.root.Position)
   api.stepEnemy(e,.51,1/60)
   local forward=horizontal(target.root.Position-e.root.Position).Unit
   equal(horizontal(e.humanoid.WalkToPoint-e.root.Position):Dot(forward)>=-.001,true,'expired retreat immediately drops its cached backward goal')
   equal(e.repositionUntil,nil,'expired retreat is cleared before its retry window')
  end)
 end)

 case('service-facing-resumes-approved-movement',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer();local e=storyEnemy('Goblin',18,18)
  local human=e.humanoid;local commands={}
  e.humanoid=setmetatable({MoveTo=function(_,point)
   commands[#commands+1]=point;human:MoveTo(point)
  end},{__index=function(_,key)return human[key]end,__newindex=function(_,key,value)human[key]=value end})
  withTacticalSurface(function(platform)
   platform(e.root.Position)
   api.stepEnemy(e,0,1/60)
   local approved=e.moveDestination
   equal(approved~=nil,true,'chase resolves a safe movement point')
   local nextDecision=e.nextMoveAt
   for frame=1,10 do
    local before=#commands
    api.stepEnemy(e,frame/60,1/60)
    equal(#commands,before+1,'each facing update resumes native MoveTo')
    equal(commands[#commands],approved,'turning reuses the approved goal')
    equal(e.nextMoveAt,nextDecision,'facing does not bypass navigation cadence')
   end
   e.root.Position=target.root.Position+Vector3.new(0,0,-4)
   api.stepEnemy(e,.2,1/60)
   equal(e.attack~=nil,true,'approach reaches an actual attack windup')
   equal(e.moveDestination,nil,'attack clears cached movement')
   local before=#commands
   api.moveEnemy(e,approved,.21,false,true)
   equal(#commands,before,'stopped attack cannot revive stale chase movement')
  end)
  e.humanoid=human
 end)
 case('service-facing-keeps-blocked-path-stopped',function()
  local e=storyEnemy('Goblin',12,18)
  local goal=e.root.Position+Vector3.new(0,0,-12)
  api.moveEnemy(e,goal,0,false)
  equal(e.moveDestination,goal,'unblocked move records approved goal')
  e.nextMoveAt=0;e.nextPathAt=math.huge;e.waypoints=nil
  api.moveEnemy(e,goal,1,true,true)
  equal(e.moveDestination,nil,'blocked path discards previous goal')
  api.moveEnemy(e,goal,1.01,true,true)
  equal(e.humanoid.WalkToPoint,e.root.Position,'facing retry cannot walk through blocked cover')
 end)

 case('service-real-r15-chases-and-attacks',function()
  api.injectResolver(function()return 'knight'end)
  local target=spawnPlayer()
  withTacticalSurface(function(platform)
   platform(origin)
   local description=Instance.new('HumanoidDescription')
   local model=Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15)
   description:Destroy()
   model.Name='ChaseQA';model:PivotTo(CFrame.new(origin+Vector3.new(0,0,-18)))
   model:SetAttribute('EnemyKind','Goblin');model:SetAttribute('DeepwoodEncounter','qa')
   model:SetAttribute('StoryRulesVersion',18);model:SetAttribute('StoryDifficulty','Hard')
   model:SetAttribute('StoryHealth',10000);model:SetAttribute('StoryDamage',120)
   model.Parent=enemies
   local e=api.registerEnemy(model)
   local initial=horizontal(e.root.Position-target.root.Position).Magnitude
   local start=os.clock();local attacked=false
   while os.clock()-start<6 do
    local dt=RunService.Heartbeat:Wait();local current=100+os.clock()-start
    api.setClock(current);api.stepEnemy(e,current,dt)
    if e.attack then attacked=true;break end
   end
   local final=horizontal(e.root.Position-target.root.Position).Magnitude
   print('ENEMY_REAL_CHASE '..HttpService:JSONEncode({initial=initial,final=final,attacked=attacked,elapsed=os.clock()-start}))
   equal(initial-final>8,true,'native R15 physically closes melee distance')
   equal(attacked,true,'native R15 starts an attack without target teleport or forced begin')
  end)
 end)
