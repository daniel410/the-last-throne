-- Run against a built place in a fresh, isolated Studio session.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local server=game.ServerScriptService.Server
local shared=game.ReplicatedStorage.Shared
local content=require(shared.CampaignContent)
local progress=require(shared.DeepwoodProgress)
local routes=require(shared.CampaignCombatRoutes)
local text=require(shared.K0Text)
local rig=require(server.World.TrainingField)
local story=server.Story.DeepwoodService
local checks=0
local function check(condition,message)
 checks+=1
 assert(condition,message)
end

local folder=Instance.new('Folder')
folder.Parent=game.ServerStorage
local enemies=Instance.new('Folder')
enemies.Parent=folder
local character=Instance.new('Model')
character.Parent=folder
local root=Instance.new('Part')
root.Name='HumanoidRootPart'
root.Parent=character
Instance.new('Humanoid',character)
local locked=false
local player={Parent=game.Players,Character=character,GetAttribute=function(_,name)
 if name=='K0SessionPhase' then return 'Tutorial' end
 if name=='TLTTravelLock' then return locked end
end}
local notices,completion={},nil
local journal,run,save,prepare
local function makeService(world)
 local source=story.Source
 local first=assert(source:find('local function publish',1,true))
 local last=assert(source:find('function Service.destination',first,true))
 source=source:sub(1,first-1)..'local publish=recordNotice\n'..source:sub(last)
 source=source:gsub('Players:GetPlayers%(%)','fixturePlayers ')
 source=source:gsub('return Service\n','function Service.qa(o)options=o;return enqueuePersonal,warmStoryEnemies,stagedEnemies end\nreturn Service\n')
 local chunk=assert(loadstring(source,'ProductionStoryPhaseFixture'))
 setfenv(chunk,setmetatable({script=story,fixturePlayers={player},recordNotice=function(_,_,notice,completed)
  if notice then table.insert(notices,notice)end
  if completed then completion=completed end
 end},{__index=getfenv()}))
 local service=chunk()
 local enqueue,warm,staged=service.qa({world=world,enemies=enemies,
  inventory={storyState=function()return journal end,expedition=function()return run end,storyEvent=function()return save()end,awardXP=function()end},
  heroSession={getActiveHero=function()return {heroId='hero'}end,getCombatContext=function()return {heroId='hero'}end},
  combat={addStoryEnemy=function(model)
   check(model.Parent==enemies and model:GetAttribute('StoryKillId')~=nil,'only a configured enemy is published')
  end},
  prepareStory=function(id)return prepare(id)end})
 return service,enqueue,warm,staged
end
local function stagedModels(staged,key,count)
 local deadline=os.clock()+3
 repeat
  local pack=staged.keep(key)
  local models={}
  if pack and pack.models then
   for _,bucket in pairs(pack.models)do for _,model in ipairs(bucket)do table.insert(models,model)end end
  end
  if #models==count then return models end
  task.wait()
 until os.clock()>=deadline
 error('Prepared wave did not reach its expected size: '..key)
end

-- A successful objective write can trigger the nearby next pack before the
-- periodic story update runs. The same path must never activate it early.
local dw=content.byId['DW-01']
local supplies=progress.goal(dw,'supplies')
local guards=progress.goal(dw,'supply_guards')
local marker=Instance.new('Part')
marker.Parent=folder
local world={nodes={['DW-01:supply_guards']={part=marker,chapter=dw,goal=guards}},spawns={},readyEpics={[1]=true}}
local _,enqueue,warmPhase,stagePhase=makeService(world)
run={runId='same-region',missionId=dw.id,difficultyId='Easy',balanceVersion=19,kills={}}
journal={version=2,main=0,flags={['DW-01:trail_guards']=true},clears={},expeditionMission=dw.id}
local entry=Vector3.new(table.unpack(routes.entry(dw,guards,run,1)))
root.Position=entry+Vector3.new(routes.approach-1,0,0)
local phaseClient=Instance.new('Folder',folder)
warmPhase(phaseClient,journal,run,1)
local phaseBatch=require(shared.DeepwoodEncounterBalance).encounterWaves(dw,guards,1,run.difficultyId,run.balanceVersion)[1]
local readyPhase={}
for _,model in ipairs(stagedModels(stagePhase,'DW-01:supply_guards:same-region:1',#phaseBatch))do readyPhase[model]=true end
local saveReleased=false
save=function()
 while not saveReleased do task.wait() end
 journal.flags['DW-01:supplies']=true
end
enqueue(player,'hero',dw,supplies)
task.wait()
check(#enemies:GetChildren()==0,'unconfirmed objective cannot open the next pack')
saveReleased=true
task.wait(.1)
local pack=enemies:GetChildren()
check(#pack>0,'confirmed goal triggers a nearby pack without the periodic update')
for _,model in ipairs(pack)do
 check(readyPhase[model],'the next objective uses its staged models after the save')
 check(model:FindFirstChild('TdMonsterVisual')~=nil,'cloned story enemy preserves the real visual')
 model:Destroy()
end
local arrivalService=makeService(world)
locked=true
arrivalService.onBattleReady(player)
check(#enemies:GetChildren()==0,'the arrival callback cannot bypass the travel lock')
locked=false
root.Position=entry+Vector3.new(routes.approach+1,0,0)
arrivalService.onBattleReady(player)
check(#enemies:GetChildren()==0,'first pack remains gated outside the route approach radius')
root.Position=entry+Vector3.new(routes.approach-1,0,0)
arrivalService.onBattleReady(player)
check(#enemies:GetChildren()>0,'the first eligible pack starts on arrival without a polling cycle')
for _,model in ipairs(enemies:GetChildren())do model:Destroy()end

-- Completing the last chapter publishes its receipt while the next region
-- is still loading. A stale completion must not notify a replacement run.
local lastChapter=content.byId['DW-07']
local firstChapter=content.byId['GW-01']
local final=progress.goal(lastChapter,'restoration')
local regionReady=false
local function testTransition(replaceRun)
 notices,completion={},nil
 regionReady=false
 world.readyEpics[2]=nil
 world.spawns[firstChapter.zone]=nil
 local prepareStarted,prepareFinished=false,false
 run={runId='outgoing',missionId=lastChapter.id,difficultyId='Easy',balanceVersion=19,kills={}}
 journal={version=2,main=6,flags={},clears={},expeditionMission=lastChapter.id}
 local _,transition=makeService(world)
 save=function()
  journal={version=2,main=7,flags={},clears={[lastChapter.id]=true},expeditionMission=firstChapter.id}
 end
 prepare=function(id)
  check(id==firstChapter.id,'prepare the authorized next region')
  prepareStarted=true
  while not regionReady do task.wait()end
  world.readyEpics[2]=true
  world.spawns[firstChapter.zone]=marker
  prepareFinished=true
 end
 transition(player,'hero',lastChapter,final)
 task.wait(.1)
 check(prepareStarted and not prepareFinished,'next region is still preparing')
 check(completion and completion.id==lastChapter.id,'confirmed phase reaches the client before region readiness')
 check(notices[1]==text.StoryPreparingRegion,'pending region is reported alongside completion')
 if replaceRun then run.runId='replacement'end
 regionReady=true
 task.wait(.1)
 check(prepareFinished,'deferred preparation completes')
 if replaceRun then
  check(#notices==1,'late readiness cannot notify a replacement run')
 else
  check(notices[2] and notices[2]:find('is open',1,true),'current run receives the road-ready notice')
 end
end
testTransition(false)
testTransition(true)

-- Engine check for first/repeat clone parity and independent runtime state.
local species={}
for _,chapter in ipairs(content.chapters)do
 for _,goal in ipairs(chapter.goals)do
  for _,spec in ipairs(goal.enemies)do species[spec.kind]=true end
 end
end
local sizing=require(server.World.StoryMonsterSizing)
local balance=require(shared.DeepwoodEncounterBalance)
local count=0
local enemyAssets=require(server.Story.StoryEnemyAssets)
for kind in pairs(species)do
 count+=1
 local scale,visual=sizing.forStory(kind,balance.isBoss(kind))
 local prototype=rig.makeEnemy(nil,kind,0,0,scale,visual)
 local template=enemyAssets.template(kind)
 local clone=template:Clone()
 local position=Vector3.new(83,15,-106)
 clone:PivotTo(clone:GetPivot()+position)
 check(clone.Parent==nil and prototype.Parent==nil,'templates and clones can be configured off-world')
 check(#prototype:GetDescendants()==#clone:GetDescendants(),'clone preserves every rig descendant')
 check(enemyAssets.template(kind)==template,'warmup and spawn reuse the same rig template')
 check((clone.PrimaryPart.Position-prototype.PrimaryPart.Position-position).Magnitude<1e-4,'clone preserves translated foot placement')
 local limb=clone.Torso:FindFirstChild('Neck')
 check(limb.Part0==clone.Torso and limb.Part1==clone.Head,'rig joints point to the clone')
 clone:SetAttribute('StoryKillId','fixture')
 check(template:GetAttribute('StoryKillId')==nil,'encounter state cannot leak to the template')
 clone:Destroy()
 prototype:Destroy()
end

-- The next chapter's first models are assembled during the preceding story,
-- then moved into the live encounter only through the normal entry checks.
local outgoing,nextChapter=content.byId['DW-07'],content.byId['GW-01']
local nextGoal=enemyAssets.combatGoals(nextChapter,nil,1)[1]
local nextKey=nextChapter.id..':'..nextGoal.id
local ready={[1]=true,[2]=false}
local nextWorld={nodes={[nextKey]={part=marker,chapter=nextChapter,goal=nextGoal}},spawns={},readyEpics=ready}
local stagedService,_,warm,staged=makeService(nextWorld)
local stagingClient=Instance.new('Folder',folder)
run={runId='prefetched-run',missionId=outgoing.id,difficultyId='Easy',balanceVersion=19,kills={}}
journal={version=2,main=6,flags={},clears={},expeditionMission=outgoing.id,expansionVersion=1,combatPacingVersion=1}
local waves=balance.encounterWaves(nextChapter,nextGoal,1,run.difficultyId,run.balanceVersion)
local key=nextKey..':'..run.runId
warm(stagingClient,journal,run,1)
warm(stagingClient,journal,run,1)
local prepared={}
for _,model in ipairs(stagedModels(staged,key..':1',#waves[1]))do
 check(model.Parent==nil and model:GetAttribute('StoryKillId')==nil,'staged model is off-world without combat state')
 prepared[model]=true
end
check(#enemies:GetChildren()==0,'preparation cannot register monsters in the outgoing chapter')
local stagedPayload=game.HttpService:JSONDecode(stagingClient:GetAttribute('TLTStoryEnemyWarmup'))
local nextVisual=Instance.new('Folder',folder)
enemyAssets.prepare(nextVisual,nil,nil,{waves[1]})
task.wait()
local nextPayload=game.HttpService:JSONDecode(nextVisual:GetAttribute('TLTStoryEnemyWarmup'))
local requestedMeshes={}
for _,mesh in ipairs(stagedPayload.meshes)do requestedMeshes[mesh]=true end
for _,mesh in ipairs(nextPayload.meshes)do check(requestedMeshes[mesh],'previous chapter downloads the next wave mesh')end

root.Position=Vector3.new(table.unpack(routes.entry(nextChapter,nextGoal,run,1)))
stagedService.onBattleReady(player)
check(#enemies:GetChildren()==0,'standing at the next clearing does not bypass story progress')
journal={version=2,main=7,flags={['GW-01:maeve']=true},clears={[outgoing.id]=true},expeditionMission=nextChapter.id,expansionVersion=1,combatPacingVersion=1}
check(progress.available(journal,nextChapter,nextGoal),'fixture has confirmed preceding story and arrival objective')
stagedService.onBattleReady(player)
check(#enemies:GetChildren()==0,'confirmed story does not bypass region preparation')
ready[2]=true
locked=true;stagedService.onBattleReady(player);locked=false
check(#enemies:GetChildren()==0,'prepared models cannot bypass the travel lock')
run.runId='replacement'
stagedService.onBattleReady(player)
local replacements=enemies:GetChildren()
check(#replacements==#waves[1],'replacement run still spawns without waiting for speculative work')
for _,model in ipairs(replacements)do
 check(not prepared[model],'different runs cannot consume each other’s prepared models')
 model:Destroy()
end
run.runId='prefetched-run'
stagedService.onBattleReady(player)
local activated=enemies:GetChildren()
check(#activated==#waves[1],'full staged first wave activates when eligibility is confirmed')
for _,model in ipairs(activated)do
 check(prepared[model] and model:GetAttribute('StoryWave')==1,'activation uses the exact earlier model instance')
 check(model:GetAttribute('StoryKillId'):find('^GW%-01:'),'continuation keeps chapter-prefixed kill receipts')
end
check(not staged.claim(key..':1'),'a wave can only claim its prepared models once')
local readySecond={}
for _,model in ipairs(stagedModels(staged,key..':2',#waves[2]))do readySecond[model]=true end
check(#enemies:GetChildren()==#activated,'staged reinforcements stay off-world during the first wave')
for _,model in ipairs(activated)do
 stagedService.defeated(model,player)
 model:Destroy()
end
check(#enemies:GetChildren()==0,'route reinforcements still wait for approach')
local points=routes.points(nextChapter,nextGoal,#waves,run.balanceVersion,run.difficultyId)
root.Position=Vector3.new(table.unpack(points[2]))
stagedService.stepEncounters()
local second=enemies:GetChildren()
check(#second==#waves[2],'the second wave starts at its normal route clearing')
for _,model in ipairs(second)do
 check(readySecond[model] and model:GetAttribute('StoryWave')==2,'follow-up wave uses models made during the first wave')
 model:Destroy()
end

-- An abandoned run releases its off-world instances after the retention window.
local clock=0
local stagingModule=assert(loadstring(server.Story.StoryEnemyStaging.Source))
setfenv(stagingModule,setmetatable({os={clock=function()return clock end}},{__index=getfenv()}))
local expiring=stagingModule().create(enemyAssets.template)
expiring.request('abandoned',function()return {{kind='Goblin'}}end)
local abandoned=stagedModels(expiring,'abandoned',1)[1]
clock=60;expiring.sweep()
check(not expiring.keep('abandoned'),'abandoned run no longer holds a prepared wave')
check(not pcall(function()abandoned.Parent=folder end),'unused prepared model was destroyed')

-- Exercise the exact server asset payload and client request without timing
-- assertions about the network cache in this Studio session.
local http=game:GetService('HttpService')
local attribute='TLTStoryEnemyWarmup'
local stub=Instance.new('Folder',folder)
local warmup=game.StarterPlayer.StarterPlayerScripts.Client.StoryEnemyWarmup
local chunks,requested={},{}
local provider={PreloadAsync=function(_,batch)
 check(#batch<=12,'warmup requests have bounded batches')
 table.insert(chunks,#batch)
 for _,item in ipairs(batch)do
  local isMesh=item:IsA('SpecialMesh')
  local key=isMesh and 'mesh:'..item.MeshId or 'texture:'..item.Texture
  check(isMesh and item.MeshType==Enum.MeshType.FileMesh or item:IsA('Decal'),'mesh and texture requests retain their asset types')
  check(not requested[key],'repeated appearances share one fetch per representation')
  requested[key]=true
 end
 task.wait()
end}
local loader=assert(loadstring(warmup.Source))
setfenv(loader,setmetatable({game={GetService=function(_,name)return name=='HttpService' and http or provider end}},{__index=getfenv()}))
loader().start(stub)
enemyAssets.prepare(stub,dw,{flags={}})
task.wait(.2)
local payload=http:JSONDecode(stub:GetAttribute(attribute))
check(#chunks>0 and #payload.meshes>0 and #payload.textures>0,'real DW-01 rig references reach client preload')
for _,uri in ipairs(payload.meshes)do check(requested['mesh:'..uri],'each authored mesh is queued')end
for _,uri in ipairs(payload.textures)do check(requested['texture:'..uri],'each authored texture is queued')end
local numChunks=#chunks
enemyAssets.prepare(stub,dw,{flags={}})
task.wait()
check(#chunks==numChunks,'the same chapter and goals do not queue repeat downloads')
local flags={}
for _,goal in ipairs(dw.goals)do flags[dw.id..':'..goal.id]=true end
enemyAssets.prepare(stub,dw,{flags=flags})
check(stub:GetAttribute(attribute)==nil,'cleared encounters leave no assets queued')

local fetched=0
local meshReference=Instance.new('SpecialMesh');meshReference.MeshType=Enum.MeshType.FileMesh;meshReference.MeshId=payload.meshes[1]
local textureReference=Instance.new('Decal');textureReference.Texture=payload.textures[1]
game:GetService('ContentProvider'):PreloadAsync({meshReference,textureReference},function(_,status)
 if status==Enum.AssetFetchStatus.Success then fetched+=1 end
end)
check(fetched==2,'Roblox fetches the authored mesh and texture with typed references')
meshReference:Destroy();textureReference:Destroy()
folder:Destroy()
print('STORY_PHASE_SPEED '..game.HttpService:JSONEncode({checks=checks,species=count}))
