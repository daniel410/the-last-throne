-- Run only in the isolated rbxlx fixture; never in a player's published session.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated player-free fixture required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local report={kind='CAMPAIGN_REORDER_NATIVE',checks=0,worlds={},pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
-- Exercise the actual service's SaveUnknown recovery, not just its reducer.
local P=require(Shared.DeepwoodProgress);local A=require(Shared.AdventureRules)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules);local Items=require(Shared.ItemCatalog)
local journal=P.new();journal.version=1
local function finishChapter(c,fn)
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do fn(g,step and step.choices and step.choices[1].id or g.choice and 'sanctuary',step and step.id or nil)end
 end end
end
for i=1,21 do local c=C.legacyMainChapters[i];finishChapter(c,function(g,choice,step)journal=assert(P.apply(journal,c.id,g.id,choice,step))end)end
local profile=assert(R.addHero(R.new(481),'hero','knight',Items));profile.heroes.hero.level=80;profile.heroes.hero.progression=require(Shared.HeroProgression).new(80)
profile.heroes.hero.deepwood=P.copy(journal)
profile.heroes.hero.expeditions={version=1,clears={},cacheProgress={},active={version=1,balanceVersion=9,runId='caldera',missionId='EC-07',difficultyId='Easy',journal=P.copy(journal),completed=true,firstClear=true,kills={}}}
profile=R.upgrade(profile)
local c=C.byId['GW-01'];local last=c.goals[#c.goals]
for i,g in ipairs(c.goals)do if i<#c.goals then
 for _,step in ipairs(g.activity and g.activity.steps or {false})do profile=assert(A.event(profile,'hero',c.id,g.id,nil,step and step.id or nil,R,Items,'caldera'))end
end end
local db=P.copy(profile);local lost=0
local adapter={UpdateAsync=function(_,_,transform)
 local value=transform(P.copy(db));if value then db=P.copy(value)end
 if lost>0 then lost-=1;error('response lost after commit')end
 return value and P.copy(value)or nil
end}
local store=require(game.ServerScriptService.Server.Inventory.AccountStore).new(adapter,R,Items,function()return 100 end,function()end,'serviceReview')
local player={UserId=481};local accounts={[player]={valid=true,profile=assert(store:open(481))}}
local service={refreshCharacter=function()end};local options={heroSession={refresh=function()end}}
local serviceSource=game.ServerScriptService.Server.Inventory.InventoryService.Source
local body=assert(serviceSource:match('(function Service.storyEvent.-)\n%-%- Monotonic fog'))
local factory=assert(loadstring('return function(accounts,store,Rules,Catalog,Service,options,publish,ReplicatedStorage,require)\n'..body..'\nreturn Service.storyEvent end'))()
local event=factory(accounts,store,R,Items,service,options,function()end,game.ReplicatedStorage,require)
lost=3
check(event(player,'hero','GW-01',last.id,nil,'confirmed','caldera')=='SaveUnknown','actual service retains unknown write')
check(not accounts[player].valid and accounts[player].storyPending~=nil,'unknown response keeps the exact pending event')
check(event(player,'hero','GW-01',last.id,nil,'confirmed','caldera')==nil,'actual service recovers backward completion retry')
check(accounts[player].valid and accounts[player].storyPending==nil and accounts[player].profile.heroes.hero.deepwood.main==8,'service restores ready state and committed progress')
-- Render the real refreshEpic function against a migrated noncontiguous journal.
local client=game.StarterPlayer.StarterPlayerScripts.Client
local uiSource=client.DeepwoodMap.Source
local refreshBody=assert(uiSource:match('(local function refreshEpic%(%).- +end)\n local function selectEpic'))
local holder=Instance.new('Folder');holder.Name='CampaignMapReview'
local function label(parent,name)local x=Instance.new('TextLabel');x.Name=name;x.Parent=parent;return x end
local chapters={}
for i=1,35 do local button=Instance.new('TextButton');button.Parent=holder;chapters[i]={button=button,name=label(button,'Name'),status=label(button,'Status')}end
local categories={}
for i=1,5 do local b=Instance.new('TextButton');b.Parent=holder;label(b,'Caption');categories[i]=b end
local progress=label(holder,'Progress');local text=require(Shared.K0Text)
local theme=require(client.TDInventoryTheme)
local refresh=assert(loadstring(refreshBody..'\nreturn refreshEpic'))
setfenv(refresh,setmetatable({State={current={journal=profile.heroes.hero.deepwood}},Scope=require(Shared.CampaignMapScope),atlas={rows={}},epic=4,progress=progress,subtitle=label(holder,'Subtitle'),journeyHint=label(holder,'Hint'),chapters=chapters,Content=C,Text=text,Theme=theme,epicButtons=categories},{__index=getfenv()}))
refresh()()
check(progress.Text==string.format(text.Map.EpicProgress,7,7,0),'actual map renders Caldera seven of seven despite main seven')
for i=22,28 do check(chapters[i].status.Text==text.Map.Complete,'actual completed map badge '..i)end
holder:Destroy()
local entrance=P.goal(C.byId['GW-07'],'entrance')
check(entrance.title==entrance.activity.steps[1].title and not entrance.title:lower():find('graveyard',1,true),'actual shared HUD goal has the new Tali instruction')
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local world
for epic=1,5 do
 world=World.create(epic,world)
 check(world.loadedEpics[epic],'world ready '..epic)
 local scope=World.scope(epic);local count=0
 for id in pairs(scope.content.zones)do
  count+=1
  local spawn=assert(world.spawns[id],'missing region spawn '..id)
  check(spawn.Parent==world.folder and spawn.Enabled,'enabled spawn '..id)
 end
 local prefix=C.epics[epic].hub:sub(1,2)
 for _,c in ipairs(scope.content.chapters)do
  check(c.id:sub(1,2)==prefix,'no wrong theme in loaded epic')
  for _,g in ipairs(c.goals)do
   local node=world.nodes[c.id..':'..g.id]
   check(node~=nil,'actual objective exists '..c.id..':'..g.id)
  end
 end
 table.insert(report.worlds,{epic=epic,region=C.epics[epic].region,zones=count})
 task.wait()
end
local props=world.folder:FindFirstChild('LateEpicProps')
local count=0;for _,child in ipairs(world.folder:GetChildren())do if child.Name=='LateEpicProps'then count+=1 end end
check(count==1,'GW/HG share the streamed completion prop container')
check(props:FindFirstChild('Crownheart')and props:FindFirstChild('InvasionPortal'),'finale props survive two late region builds')
check(world.folder:FindFirstChild('GW-01_SP')and world.folder:FindFirstChild('FV-01_SP'),'GW second and FV third have actual spawns')
local region=world.terrain:FindFirstChild('GW-01')
check(region and region:GetAttribute('EpicId')=='Gloamwood','epic2 remains Gloamwood, never winter')
local _,size=region:GetBoundingBox();check(size.Magnitude>0,'actual forest geometry built')
-- Verify the actual runtime uses region identity for calm/hazard behavior.
local source=game.ServerScriptService.Server.Story.DeepwoodService.Source
check(source:find("e.chapter.id:sub(1,2)=='FV' and model",1,true)~=nil,'winter-only nonlethal guardian rule')
check(source:find("e.chapter.id:sub(1,2)=='EC' and 'FurnaceHeatWarning'",1,true)~=nil,'furnace hazard remains volcanic')
local D=require(Shared.Difficulty);local B=require(Shared.DeepwoodEncounterBalance)
local model=Instance.new('Model')
local body=assert(source:match('(local function applyBalance.-)\nlocal spawnWave'))
local apply=assert(loadstring('return function(Balance)\n'..body..'\nreturn applyBalance end'))()(B)
for _,id in ipairs({'GW-01','GW-07','FV-01','EC-07','HG-07'})do
 local c=C.byId[id]
 for _,g in ipairs(c.goals)do for _,batch in ipairs(B.encounterWaves(c,g,1))do for index,spec in ipairs(batch)do
  for _,version in ipairs({9,10})do
   apply(model,spec,1,'Easy',version,index)
   local hp,damage,level=B.unitStats(spec,1,'Easy',version,index)
   local xp,gold=B.rewards(spec,'Easy',version)
   check(model:GetAttribute('StoryLevel')==level and model:GetAttribute('StoryHealth')==hp and model:GetAttribute('StoryDamage')==damage,'server bridge applies pinned/current stat contract')
   check(model:GetAttribute('StoryRewardXP')==xp and model:GetAttribute('StoryRewardGold')==gold,'server bridge applies pinned/current reward contract')
  end
 end end end
end
model:Destroy()
report.pass=true
print('CAMPAIGN_REORDER_NATIVE '..game.HttpService:JSONEncode(report));return report
