-- Full journal migration and account reward paths; no DataStore or live account writes.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,P,A,D,B,G=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('Difficulty'),load('DeepwoodEncounterBalance'),load('HeroProgression')
local Access,Log,Travel=load('CampaignAccess'),load('DeepwoodQuestLog'),load('CheckpointTravel')
local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=load('ItemCatalog')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function events(c,fn)
 for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do fn(g,step.choices and step.choices[1].id,step.id)end
  else fn(g,g.choice and 'sanctuary',nil)end
 end end
end
local function finish(s,c)
 events(c,function(g,choice,step)s=assert(P.apply(s,c.id,g.id,choice,step))end);return s
end
local legacy=P.new();legacy.version=1
local snapshots={P.copy(legacy)}
for i=1,35 do legacy=finish(legacy,C.legacyMainChapters[i]);check(P.validate(legacy),'old order validates at '..i);snapshots[i+1]=P.copy(legacy)end
for oldMain=0,35 do
 local old=snapshots[oldMain+1]
 local nextChapter=C.legacyMainChapters[oldMain+1]
 if nextChapter then
  local g=nextChapter.goals[1];local step=g.activity and g.activity.steps and g.activity.steps[1]
  old=assert(P.apply(old,nextChapter.id,g.id,step and step.choices and step.choices[1].id,step and step.id))
 end
 for id,z in pairs(C.zones)do if z.legacyRequiresMain<=old.main then old.explored[id]={['1']=true}end end
 for _,c in ipairs(C.chapters)do if c.side and old.main>=c.legacyMinMain then old=assert(P.accept(old,c.id))end end
 check(P.validate(old),'old partial/discovery data valid')
 local upgraded=assert(P.upgrade(old));check(P.validate(upgraded)and upgraded.version==2,'migrated journal valid at '..oldMain)
 for _,key in ipairs({'flags','clears','activities','decisions','clues','accepted','explored','choice','coins','killCoins'})do
  check(equal(old[key],upgraded[key]),'migration preserves '..key..' at '..oldMain)
 end
 local frontier=0;while frontier<35 and old.clears[C.mainChapters[frontier+1].id]do frontier=frontier+1 end
 check(upgraded.main==frontier,'new frontier is exact clear prefix')
 check(equal(P.upgrade(upgraded),upgraded),'migration is idempotent')
 if nextChapter and not upgraded.clears[nextChapter.id]then check(P.eligible(upgraded,nextChapter),'old in-progress mission remains playable')end
 for id,z in pairs(C.zones)do if z.legacyRequiresMain<=old.main then check(Access.allowed(upgraded,id),'old region remains unlocked '..id)end end
 local malformed=P.copy(old);malformed.coins=malformed.coins+1;check(not P.upgrade(malformed),'invalid old reward totals fail closed')
end
-- Backward EC -> GW completion must recover both immediate retry and SaveUnknown.
for _,losses in ipairs({1,3})do
 local p=assert(R.addHero(R.new(332+losses),'hero','knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
 p.heroes.hero.deepwood=P.copy(snapshots[22])
 p.heroes.hero.expeditions={version=1,clears={},cacheProgress={},active={version=1,balanceVersion=9,runId='caldera',missionId='EC-07',difficultyId='Easy',journal=P.copy(snapshots[22]),completed=true,firstClear=true,kills={}}}
 p=R.upgrade(p)
 local c=C.byId['GW-01'];local last=c.goals[#c.goals]
 for i,g in ipairs(c.coreGoals)do if i<#c.coreGoals then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(A.event(p,'hero',c.id,g.id,nil,step and step.id or nil,R,Items,'caldera'))end
 end end
 local db=P.copy(p);local remaining=0;local committed
 local adapter={UpdateAsync=function(_,_,transform)
  local value=transform(P.copy(db));if value then db=P.copy(value)end
  if remaining>0 then remaining=remaining-1;committed=committed or P.copy(db);error('response lost after write')end
  return value and P.copy(value)or nil
 end}
 local store=Store.new(adapter,R,Items,function()return 100 end,function()end,'backward')
 assert(store:open(p.userId));remaining=losses
 local function event(current)return A.event(current,'hero','GW-01',last.id,nil,'confirmed',R,Items,'caldera')end
 local saved,reason=store:transact(p.userId,event)
 if losses==3 then check(not saved and reason=='SaveUnknown','three lost responses leave a recoverable unknown');saved,reason=store:transact(p.userId,event)end
 check(saved and not reason and saved.heroes.hero.deepwood.main==8,'backward completion retry recovers exact frontier')
 check(equal(saved.items,committed.items)and saved.wallet.gold==committed.wallet.gold and saved.revision==committed.revision,'response retries cannot regrant materials/cache/Gold or advance revision')
 check(saved.heroes.hero.expeditions.active.completedChapters['GW-01'],'completion receipt belongs to this run')
 local foreign,why=A.event(saved,'hero','FV-07','reunion',nil,nil,R,Items,'caldera')
 check(not foreign and why=='AdventureChanged','unprocessed historical clear is not a run receipt')
 check(not A.event(saved,'hero','GW-01',last.id,nil,'confirmed',R,Items,'foreign'),'foreign run still rejected')
 local bad=P.copy(saved);bad.heroes.hero.expeditions.active.completedChapters['GW-07']=true
 check(not R.validate(bad,Items),'uncompleted chapter cannot be forged into run receipts')
end
local Scope=load('CampaignMapScope')
local mapJournal=assert(P.upgrade(snapshots[22]))
check(Scope.progress(mapJournal,3)==7 and Scope.progress(mapJournal,4)==7,'migrated completed FV/EC show seven clears')
check(Scope.progress(mapJournal,2)==0 and Scope.status(mapJournal,'GW-01')=='Current','missing GW stays current and zero of seven')
check(Scope.status(mapJournal,'EC-07')=='Complete'and Scope.status(mapJournal,'HG-01')=='Locked','map distinguishes actual clears from future locks')
check(Scope.status({main=0},'DW-01')=='Locked','pre-snapshot map is safe')
local partialMap=assert(P.upgrade(snapshots[19]));partialMap.expeditionMission='EC-05'
check(Scope.progress(partialMap,4)==4 and Scope.status(partialMap,'EC-05')=='Current','partial migrated Caldera shows four completed and its active story')
local entrance=P.goal(C.byId['GW-07'],'entrance')
check(entrance.title=='Ask Tali where the convoy went'and entrance.activity.steps[1].title==entrance.title,'HUD objective and step both use new route')
for _,phase in ipairs(C.byId['GW-07'].quest.phases)do if phase.goals[1]=='entrance'then check(phase.title==entrance.title,'phase shares the current route instruction')end end
check(Log.target({main=13,version=2,clears={},flags={['GW-07:nest']=true,['GW-07:queen']=true,['GW-07:exit']=true}},C.byId['GW-07']).goal.title==entrance.title,'actual tracked goal uses current Tali instruction')
local gaps=assert(P.upgrade(snapshots[22])) -- old EC-07 complete, no GW
check(gaps.main==7 and gaps.clears['FV-07']and gaps.clears['EC-07'],'old late clears preserved behind GW gap')
local before=gaps.coins
for i=8,14 do gaps=finish(gaps,C.mainChapters[i])end
check(gaps.main==28 and gaps.coins==before,'GW fills gap without paying completed FV/EC again')
check(Log.main(gaps).id=='HG-01','continue skips already cleared regions after gap')
local oldPartial=P.copy(snapshots[8]);oldPartial=assert(P.apply(oldPartial,'FV-01','pathfinder',nil,'confirmed'))
local migratedPartial=assert(P.upgrade(oldPartial));migratedPartial.expeditionMission='FV-01'
check(Log.tracked(migratedPartial).chapter.id=='FV-01','old admitted mission has a visible objective')
check(Travel.list(migratedPartial)['DW-01']==nil,'checkpoint list follows active region')
-- Upgrade through real account UpdateAsync, including a lost write response.
local profile=assert(R.addHero(R.new(456),'hero','knight',Items));profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
profile.heroes.hero.deepwood=P.copy(oldPartial)
profile.heroes.hero.expeditions={version=1,clears={},cacheProgress={},active={version=1,balanceVersion=9,runId='oldRun',missionId='FV-01',difficultyId='Easy',journal=P.copy(oldPartial),completed=false,firstClear=true,kills={one=true}}}
profile.supportPasses={version=1,credits=3,trials={hero=true},active={hero={id='paid',story=8,scope='run:oldRun:FV-01',ended=false,trial=false}}}
local original=P.copy(profile);local db=P.copy(profile);local unknown=true
local adapter={UpdateAsync=function(_,_,fn)
 local nextProfile=fn(P.copy(db));if nextProfile then db=P.copy(nextProfile)end
 if unknown then unknown=false;error('response lost after write')end
 return P.copy(db)
end}
local store=Store.new(adapter,R,Items,function()return 100 end,function()end,'migration')
local opened=assert(store:open(456));check(R.validate(opened,Items),'migrated account validates after response loss')
check(opened.heroes.hero.deepwood.version==2 and opened.heroes.hero.expeditions.active.journal.version==2,'both durable and active journal migrate')
check(opened.supportPasses.active.hero.story==15 and opened.supportPasses.active.hero.scope=='run:oldRun:FV-01','paid support follows stable mission identity')
check(opened.supportPasses.credits==3 and opened.wallet.gold==original.wallet.gold and equal(opened.items,original.items),'migration never consumes credit, issues gear or changes wallet')
check(opened.heroes.hero.expeditions.active.kills.one and opened.heroes.hero.expeditions.active.balanceVersion==9,'old kill receipts/rules pinned')
local revision=opened.revision;local reopened=assert(store:open(456));check(reopened.revision==revision,'retry/reopen cannot repeat migration')
check(load('SupportPassRules').view(reopened,'hero').active,'paid old mission support stays active')
-- Historical replay and permanent first clears use separate journals.
local p=assert(R.addHero(R.new(789),'hero','knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
p.heroes.hero.deepwood=assert(P.upgrade(snapshots[22]));local oldGold=p.heroes.hero.deepwood.coins
p=assert(A.begin(p,'hero','FV-07','Easy','oldReplay',p.revision,R,Items,12))
check(P.validate(p.heroes.hero.expeditions.active.journal),'replay has valid prefix despite permanent GW gap')
check(p.heroes.hero.deepwood.main==7 and not p.heroes.hero.deepwood.clears['GW-01'],'synthetic prefix never enters permanent progress')
events(C.byId['FV-07'],function(g,choice,step)p=assert(A.event(p,'hero','FV-07',g.id,choice,step,R,Items,'oldReplay'))end)
check(p.heroes.hero.deepwood.coins==oldGold and p.heroes.hero.deepwood.main==7,'replay cannot pay fixed rewards or fill gap')
check(A.selection(p.heroes.hero).missionId=='GW-01'and Log.tracked(A.projection(p.heroes.hero)).chapter.id=='GW-01','historical replay returns to real missing frontier, never a synthetic unlock')
events(C.byId['GW-01'],function(g,choice,step)p=assert(A.event(p,'hero','GW-01',g.id,choice,step,R,Items,'oldReplay'))end)
check(p.heroes.hero.deepwood.main==8 and A.continuation(p.heroes.hero.expeditions.active).id=='GW-02','same replay run can continue the actual missing campaign')
-- A completed old run can continue backward to the new missing GW frontier.
local active={missionId='EC-07',completed=true,journal=assert(P.upgrade(snapshots[22]))}
check(A.continuation(active).id=='GW-01','completed legacy run reaches missing new frontier')
-- Previously completed optional quests remain replayable behind the GW gap.
local oldSide=assert(P.accept(snapshots[22],'FV-Q1',true));oldSide=finish(oldSide,C.byId['FV-Q1'])
local sideProfile=assert(R.addHero(R.new(812),'hero','elf',Items));sideProfile.heroes.hero.level=80;sideProfile.heroes.hero.progression=G.new(80)
sideProfile.heroes.hero.deepwood=assert(P.upgrade(oldSide))
sideProfile=assert(A.begin(sideProfile,'hero','FV-Q1','Easy','legacySide',sideProfile.revision,R,Items,12))
check(P.validate(sideProfile.heroes.hero.expeditions.active.journal),'old side replay valid before filling GW')
events(C.byId['FV-Q1'],function(g,choice,step)sideProfile=assert(A.event(sideProfile,'hero','FV-Q1',g.id,choice,step,R,Items,'legacySide'))end)
check(sideProfile.heroes.hero.deepwood.main==7 and sideProfile.heroes.hero.deepwood.clears['FV-Q1'],'old side replay preserves permanent clears and frontier')
-- New heroes complete the actual account reducer in the approved order.
p=assert(R.addHero(R.new(890),'hero','mage',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
local fixed=0
for i,c in ipairs(C.mainChapters)do
 check(c.epic==math.ceil(i/7)and c.number==i,'ordered episode metadata')
 p=assert(A.begin(p,'hero',c.id,'Easy','route'..i,p.revision,R,Items,12));local run='route'..i
 local gold=p.wallet.gold
 events(c,function(g,choice,step)
  p=assert(A.event(p,'hero',c.id,g.id,choice,step,R,Items,run))
  local retry=assert(A.event(p,'hero',c.id,g.id,choice,step,R,Items,run))
  check(retry.revision==p.revision and retry.wallet.gold==p.wallet.gold,'event retry preserves reward/receipt')
 end)
 fixed=fixed+c.reward.coins
 check(p.wallet.gold-gold==c.reward.coins and p.heroes.hero.deepwood.main==i,'one first-clear reward and exact frontier')
 check(A.selection(p.heroes.hero).missionId==(C.mainChapters[math.min(35,i+1)]).id,'Continue points to correct mission')
end
check(fixed==19170 and p.heroes.hero.deepwood.coins==16570 and p.heroes.hero.deepwood.clears['HG-07'],'original ledger and ending preserved; GW adds 2600 account Gold')
check(not D.allowed({level=80,deepwood=P.new()},'FV-01','Easy'),'new player cannot skip Gloamwood')
check(C.byId['DW-07'].quest.outcome:find('Gloamwood',1,true)and C.byId['GW-07'].quest.outcome:find('Frozen Vale',1,true)and C.byId['EC-07'].quest.outcome:find('Haunted Graveyard',1,true),'English outcomes match exits')
-- New Easy route must not require side quests, replay XP, purchases or support.
local Summary=load('EncounterSummary');local level,xp=1,0
for _,c in ipairs(C.mainChapters)do
 check(level>=D.requiredLevel(c,'Easy'),'mandatory route meets gate '..c.id)
 local total=Summary.mission(c,'Easy',1);xp=xp+total.xp+c.reward.xp
 while level<80 and xp>=G.xpToNext(level)do xp=xp-G.xpToNext(level);level=level+1 end
end
print('CAMPAIGN_REORDER '..n..' checks passed; mandatory solo final level '..level)
