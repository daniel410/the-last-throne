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
local player={Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
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
root.Position=Vector3.new(table.unpack(routes.entry(dw,guards,run,1)))
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
for kind in pairs(species)do
 count+=1
 local scale,visual=sizing.forStory(kind,balance.isBoss(kind))
 local prototype=rig.makeEnemy(nil,kind,0,0,scale,visual)
 local clone=prototype:Clone()
 local position=Vector3.new(83,15,-106)
 clone:PivotTo(clone:GetPivot()+position)
 check(clone.Parent==nil and prototype.Parent==nil,'templates and clones can be configured off-world')
 check(#prototype:GetDescendants()==#clone:GetDescendants(),'clone preserves every rig descendant')
 check((clone.PrimaryPart.Position-prototype.PrimaryPart.Position-position).Magnitude<1e-4,'clone preserves translated foot placement')
 local limb=clone.Torso:FindFirstChild('Neck')
 check(limb.Part0==clone.Torso and limb.Part1==clone.Head,'rig joints point to the clone')
 clone:SetAttribute('StoryKillId','fixture')
 check(prototype:GetAttribute('StoryKillId')==nil,'encounter state cannot leak to the template')
 clone:Destroy()
 prototype:Destroy()
end
folder:Destroy()
print('STORY_PHASE_SPEED '..game.HttpService:JSONEncode({checks=checks,species=count}))
