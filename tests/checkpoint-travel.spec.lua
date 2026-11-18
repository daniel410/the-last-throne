local T=dofile('src/shared/CheckpointTravel.luau')
local S=dofile('src/server/Story/CheckpointTravelService.luau')
local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local G=dofile('src/shared/HeroProgression.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local p=assert(R.addHero(R.new(720),'hero','knight',C));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
p=assert(A.begin(p,'hero','DW-01','Easy','travel',p.revision,R,C,12))
check(next(T.list(A.projection(p.heroes.hero)))==nil,'no travel before any saved completion')
local readySave
for _,c in ipairs(Content.mainChapters)do
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   p=assert(A.event(p,'hero',c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,step and step.id or nil,R,C,'travel'))
   local s=A.projection(p.heroes.hero)
   if c.id=='DW-07'and not s.flags['DW-07:separate']then check(not T.report(s),'boss kill or partial supplies cannot unlock return early')end
   if c.id=='DW-07'and g.id=='separate'and s.flags['DW-07:separate']then readySave=R.copy(p)end
   for id,target in pairs(T.list(s))do
    check(T.allowed(s,id)~=nil,'every shown destination is authorized')
    if target.id~='DW-07:restoration'then
     check(s.clears[target.chapterId],'checkpoint requires the entire saved story')
     check(T.completed(s,target.zone),'every destination zone has a saved clear')
    end
   end
  end
 end end
end
local s=A.projection(readySave.heroes.hero);local target=T.report(s)
check(target.id=='DW-07:restoration'and target.zone=='DW-03','altar map offers Eryn report shortcut')
check(T.preferred(s,'DW-07')==nil and T.preferred(s,'DW-03').id=='DW-03','region selection returns only that cleared region checkpoint')
local report=Content.byId['DW-07'].goals[#Content.byId['DW-07'].goals]
check(target.position[1]==report.position[1]and target.position[2]==report.position[2]and target.position[3]==report.position[3],'report uses authoritative NPC objective coordinates')
local old={revision=readySave.revision,gold=readySave.wallet.gold,main=s.main}
local valid,ready,pending,fighting,loaded,heroId=true,true,false,false,true,'hero'
local moves=0
local travel=S.create({rules=T,context=function()return valid and {heroId='hero'}end,
 active=function()return {heroId=heroId}end,ready=function()return ready end,pending=function()return pending end,inEncounter=function()return fighting end,
 state=function()return s end,destination=function(t)return loaded and {id=t.id,position=t.position}end,
 relocate=function(_,pivot)check(pivot.id==target.id,'server chooses destination from saved rules');moves=moves+1;return true end})
for i=1,4 do check(travel(i,target.id),'each eligible party member can choose travel independently')end
check(moves==4 and readySave.revision==old.revision and readySave.wallet.gold==old.gold and s.main==old.main,'travel neither advances objectives nor awards or resets progression')
for _,id in ipairs({'DW-07','HG-07','unknown','DW-07:king_shaman'})do check(not travel(1,id),'locked or arbitrary target rejected')end
check(not travel(1,{position={1,2,3}}),'client coordinates are not accepted')
valid=false;check(not travel(1,target.id),'downed/no combat context rejected');valid=true
ready=false;check(not travel(1,target.id),'lobby/travel/account lock rejected');ready=true
pending=true;check(not travel(1,target.id),'unconfirmed progress must finish saving');pending=false
fighting=true;check(not travel(1,target.id),'unfinished encounter cannot be skipped');fighting=false
loaded=false;check(not travel(1,target.id),'missing destination cannot move into an unloaded world');loaded=true
heroId='other';check(not travel(1,target.id),'hero switch cannot use stale entitlement');heroId='hero'
s=A.projection(p.heroes.hero);check(not T.allowed(s,target.id),'finished report/epic removes the old report shortcut')
check(R.validate(readySave,C),'travel source checkpoint remains a valid durable profile')
-- Durable clears survive an earlier replay and are isolated by difficulty.
local hero=p.heroes.hero
local replay=R.copy(hero)
replay.expeditions.active.journal.clears={}
replay.expeditions.active.journal.clears['GW-01']=true
replay.expeditions.modeJournals.Easy.clears['GW-01']=nil
local view=A.projection(replay)
check(T.allowed(view,'HG-07') and not T.allowed(view,'GW-01'),'real later clear survives replay, synthetic prefix cannot grant travel')
replay.expeditions.active.difficultyId='Hard'
check(not T.allowed(A.projection(replay),'HG-07'),'other difficulty cannot borrow Easy clear')
local saved={main=0,flags={},clears={},checkpointClears={}}
for _,chapter in ipairs(Content.chapters)do saved.checkpointClears[chapter.id]=true end
for zone in pairs(Content.zones)do
 local target=T.region(saved,zone)
 check(target and target.id==zone,'each of the 44 completed story regions maps to its own spawn')
 saved.checkpointClears[target.chapterId]=nil
 check(not T.allowed(saved,zone),'incomplete owning story blocks '..zone)
 saved.checkpointClears[target.chapterId]=true
end
-- Never move a different life/run, reward undecided work or accept a duplicate during a yield.
local state={main=0,clears={},checkpointClears={['HG-07']=true},expeditionRunId='one'}
local life={heroId='a',epoch=1,characterGeneration=1}
local during,requests,relocations,hasWorld=nil,0,0,false
local teleport
teleport=S.create({rules=T,context=function()return life end,active=function()return {heroId='a'}end,
 ready=function()return true end,pending=function()return false end,inEncounter=function()return false end,
 state=function()return state end,loaded=function()return hasWorld end,
 prepare=function()
  requests=requests+1
  check(not teleport(1,'HG-07'),'duplicate rejected while loading')
  hasWorld=true
  if during then during()end
 end,
 destination=function(target)return target.zone end,relocate=function()relocations=relocations+1;return true end})
check(not teleport(1,'HG-06') and requests==0,'locked request cannot load terrain')
during=function()state.expeditionRunId='two'end
check(not teleport(1,'HG-07') and relocations==0,'run changed during preparation')
hasWorld=false;during=function()life={heroId='a',epoch=1,characterGeneration=2}end
check(not teleport(1,'HG-07') and relocations==0,'respawn while loading')
hasWorld=false;during=function()state.checkpointClears={}end
check(not teleport(1,'HG-07') and relocations==0,'entitlement rechecked after loading')
hasWorld=false;state.checkpointClears['HG-07']=true;during=function()error('simulated world failure')end
check(not teleport(1,'HG-07') and relocations==0,'failed load does not relocate')
hasWorld=false;during=nil
check(teleport(1,'HG-07') and relocations==1,'successful retry uses completed region')
-- A partially-created spawn cannot satisfy the real service readiness predicate.
local f=assert(io.open('src/server/Story/DeepwoodService.luau'));local source=f:read('*a');f:close()
local predicate=assert(source:match('loaded=(function%(target%).-end),'))
local world={spawns={['HG-07']={}},loadedEpics={[5]=true},readyEpics={}}
local loaded=assert(load('return '..predicate,'checkpoint-readiness','t',{options={world=world},Content=Content}))()
local messages={};local moves,prepares=0,0
local state={main=0,clears={},checkpointClears={['HG-07']=true},expeditionRunId='cold'}
local cold=S.create({rules=T,context=function()return {heroId='qa',epoch=1,characterGeneration=1}end,
 active=function()return {heroId='qa'}end,ready=function()return true end,pending=function()return false end,inEncounter=function()return false end,
 state=function()return state end,loaded=loaded,loading=function(_,stage,id,pivot)messages[#messages+1]={stage,id,pivot}end,
 prepare=function()prepares=prepares+1;check(#messages==1 and messages[1][1]=='Begin','cover starts before load');world.readyEpics[5]=true end,
 destination=function()return 'destination'end,relocate=function()moves=moves+1;return true end})
check(cold(1,'HG-07')and prepares==1 and moves==1,'partial geometry waits for services and readiness')
check(messages[2][1]=='Arrived'and messages[1][2]==messages[2][2]and messages[2][3]=='destination','matching completion supplies destination')
check(cold(1,'HG-07')and prepares==1 and #messages==2,'warm checkpoint never shows cover')
for _,reason in ipairs({'error','revoked','incomplete'})do
 messages={};world.readyEpics[5]=nil;state.checkpointClears['HG-07']=true
 local interrupted=S.create({rules=T,context=function()return {heroId='qa'}end,active=function()return {heroId='qa'}end,
  ready=function()return true end,pending=function()return false end,inEncounter=function()return false end,state=function()return state end,
  loaded=loaded,loading=function(_,stage)messages[#messages+1]=stage end,
  prepare=function()if reason=='error'then error('load failure')end;if reason=='revoked'then state.checkpointClears={}end end,
  destination=function()error('unfinished travel must not reach destination')end,relocate=function()error('must not move')end})
 check(not interrupted(1,'HG-07')and table.concat(messages,',')=='Begin,Cancelled','failure closes cover: '..reason)
end
print('Checkpoint travel: '..checks..' checks passed')
