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
 source=source:gsub('return Service\n','function Service.qa(o)options=o;return enqueuePersonal end\nreturn Service\n')
 local chunk=assert(loadstring(source,'ProductionStoryPhaseFixture'))
 setfenv(chunk,setmetatable({script=story,fixturePlayers={player},recordNotice=function(_,_,notice,completed)
  if notice then table.insert(notices,notice)end
  if completed then completion=completed end
 end},{__index=getfenv()}))
 local service=chunk()
 local enqueue=service.qa({world=world,enemies=enemies,
  inventory={storyState=function()return journal end,expedition=function()return run end,storyEvent=function()return save()end},
  heroSession={getActiveHero=function()return {heroId='hero'}end,getCombatContext=function()return {heroId='hero'}end},
  combat={addStoryEnemy=function(model)
   check(model.Parent==enemies and model:GetAttribute('StoryKillId')~=nil,'only a configured enemy is published')
  end},
  prepareStory=function(id)return prepare(id)end})
 return service,enqueue
end

-- A successful objective write can trigger the nearby next pack before the
-- periodic story update runs. The same path must never activate it early.
local dw=content.byId['DW-01']
local supplies=progress.goal(dw,'supplies')
local guards=progress.goal(dw,'supply_guards')
local marker=Instance.new('Part')
marker.Parent=folder
local world={nodes={['DW-01:supply_guards']={part=marker,chapter=dw,goal=guards}},spawns={},readyEpics={[1]=true}}
local _,enqueue=makeService(world)
run={runId='same-region',missionId=dw.id,difficultyId='Easy',balanceVersion=19,kills={}}
journal={version=2,main=0,flags={['DW-01:trail_guards']=true},clears={},expeditionMission=dw.id}
local entry=Vector3.new(table.unpack(routes.entry(dw,guards,run,1)))
root.Position=entry+Vector3.new(routes.approach-1,0,0)
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
