local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local D,P,G,Content,F=load('Difficulty'),load('DeepwoodProgress'),load('HeroProgression'),load('CampaignContent'),load('EquipmentTransactions')
local Economy=load('EconomyRules')
local GrowthBudget=load('CampaignGrowthBudget')
local Modes=load('CampaignModeProgress')
local A={}
-- Admission stays bound to the launch mission; every main story in the run
-- follows the journal, including replays, higher difficulties and epic borders.
function A.continuation(a)
 local start=a and Content.byId[a.missionId]
 local main=a and (a.returnToCampaign and a.campaignMain or a.journal and a.journal.main)
 local nextChapter=main and Content.mainChapters[main+1]
 if a and a.completed and start and not start.side and nextChapter then return nextChapter end
end
local function currentMission(a)
 local start=a and Content.byId[a.missionId]
 if a and a.completed and start and not start.side then
  return A.continuation(a)or Content.mainChapters[Content.mainCount]
 end
 return start
end
-- Continue prioritizes permanent first-clear progress over an older Easy replay.
function A.selection(hero,mode)
 local e=hero and hero.expeditions
 local a=e and e.active
 mode=mode or a and a.difficultyId or 'Easy'
 if a and (a.difficultyId~=mode or a.partyAssist) then a=e.runsByMode and e.runsByMode[mode]end
 local current=currentMission(a)
 local journal=Modes.journal(hero,mode)
 local frontier=Content.mainChapters[math.min(Content.mainCount,journal.main+1)]
 -- An explicit replay retains its own checkpoint. Unmarked legacy accidental
 -- replays still recover to the permanent frontier.
 if current and current.side and(a.completed or not a.replay and journal.main<Content.mainCount and (frontier.epic or 1)>(current.epic or 1))then
  current=nil
 end
 if current and not current.side and not a.replay then current=frontier end
 return {missionId=(current or frontier).id,difficultyId=mode}
end
function A.upgradeHero(hero,paidClaims)
 local changed=Modes.ensure(hero,paidClaims);local e=hero.expeditions;local a=e.active
 if a and not a.modeProgressVersion then
  a.journal=Modes.journal(hero,a.difficultyId);a.returnToCampaign=nil;a.campaignMain=nil
  a.completed=a.journal.clears[a.missionId]==true;a.firstClear=not Modes.claimed(hero,a.missionId,a.difficultyId)
  a.completedChapters={};a.modeProgressVersion=1;changed=true
 end
 return changed
end
local function integer(n,min,max)return type(n)=='number'and n%1==0 and n>=min and n<=max end
function A.valid(hero)
 local e=hero.expeditions;if e==nil then return true end
 if type(e)~='table'or e.version~=1 or type(e.clears)~='table'or type(e.cacheProgress)~='table'then return false end
 if e.modeJournals~=nil then
  if type(e.modeJournals)~='table'or type(e.modeRewardClaims)~='table'or type(e.runsByMode)~='table'then return false end
  for _,mode in ipairs(D.order)do if type(e.modeJournals[mode])~='table'or type(e.modeRewardClaims[mode])~='table'then return false end end
  for mode,journal in pairs(e.modeJournals)do if not D.modes[mode]or not P.validate(journal)then return false end end
  for mode,claims in pairs(e.modeRewardClaims)do
   if not D.modes[mode]or type(claims)~='table'then return false end
   for id,claimed in pairs(claims)do
    if not Content.byId[id]or claimed~=true or not(e.modeJournals[mode].clears[id]or e.clears[id]and e.clears[id][mode])then return false end
   end
  end
  for mode,saved in pairs(e.runsByMode)do
   if not D.modes[mode]or type(saved)~='table'or saved.difficultyId~=mode
    or not A.valid({expeditions={version=1,clears={},cacheProgress={},active=saved}})then return false end
  end
 elseif e.modeRewardClaims~=nil or e.runsByMode~=nil then return false end
 if e.campaignProgress~=nil then
  if type(e.campaignProgress)~='table'then return false end
  for mode,progress in pairs(e.campaignProgress)do
   if not D.modes[mode]or type(progress)~='table'or not integer(progress.clears,0,1e9)or type(progress.chapters)~='table'then return false end
   for id,value in pairs(progress.chapters)do
    local chapter=Content.byId[id]
    if value~=true or not chapter or chapter.side or not D.combat(chapter)then return false end
   end
  end
 end
 for id,modes in pairs(e.clears)do if not Content.byId[id]or type(modes)~='table'then return false end;for mode,v in pairs(modes)do if not D.modes[mode]or v~=true then return false end end end
 for tier,n in pairs(e.cacheProgress)do if (tier~='1'and tier~='5'and tier~='10')or not integer(n,0,3)then return false end end
 local a=e.active
 if a~=nil then
  if type(a)~='table'then return false end
  if a.modeProgressVersion~=nil and a.modeProgressVersion~=1 then return false end
  if a.partyAssist~=nil and (a.partyAssist~=true or not a.replay)then return false end
  if a.replay~=nil and type(a.replay)~='boolean'then return false end
  if a.growthCycle~=nil and(not integer(a.growthCycle,1,1e9)or not GrowthBudget.enabled(a.balanceVersion))then return false end
  if GrowthBudget.enabled(a.balanceVersion)and a.growthCycle==nil then return false end
  if type(a)~='table'or type(a.runId)~='string'or #a.runId<1 or #a.runId>64 or not a.runId:match('^[%w_-]+$')or not Content.byId[a.missionId]or not D.modes[a.difficultyId]or a.version~=1 or (a.balanceVersion~=nil and not D.compatible(a.balanceVersion)) or type(a.completed)~='boolean'or type(a.firstClear)~='boolean'or not P.validate(a.journal)or type(a.kills)~='table'then return false end
  if a.returnToCampaign~=nil and type(a.returnToCampaign)~='boolean'or a.returnToCampaign and not integer(a.campaignMain,0,Content.mainCount)then return false end
  if a.completedChapters~=nil then
   if type(a.completedChapters)~='table'then return false end
   for id,value in pairs(a.completedChapters)do
    local chapter=Content.byId[id]
    if value~=true or not chapter or chapter.side or not a.journal.clears[id]then return false end
   end
  end
  local n=0;for key,v in pairs(a.kills)do if type(key)~='string'or #key>100 or v~=true then return false end;n=n+1 end;if n>4096 then return false end
  if a.completed~=(a.journal.clears[a.missionId]==true)then return false end
 end
 return true
end
-- Fog is hero-wide; replay objective journals must not hide newly saved discovery.
function A.projection(hero)
 local a=hero and hero.expeditions and hero.expeditions.active
 if not a then return nil end
 local view=P.copy(a.modeProgressVersion and a.journal or Modes.journal(hero,a.difficultyId))
 if (a.balanceVersion or 1)>=13 and (view.expansionVersion~=1 or view.combatPacingVersion~=1) then view=assert(P.enableExpansion(view))end
 for id,cells in pairs(hero.deepwood and hero.deepwood.explored or {})do
  local zone=Content.zones[id]
  if zone and Content.accessible(view,zone.requiresMain,zone.legacyRequiresMain) then
   view.explored[id]=view.explored[id]or {}
   for cell,revealed in pairs(cells)do view.explored[id][cell]=revealed end
  end
 end
 local nextChapter=A.continuation(a)
 -- A replay can have synthetic clears and a party helper can be ahead of this run.
 local journals=hero.expeditions.modeJournals
 local saved=journals and journals[a.difficultyId]
 view.checkpointClears=P.copy((saved or Modes.journal(hero,a.difficultyId)).clears)
 view.expeditionRunId=a.runId
 view.expeditionMission=nextChapter and nextChapter.id or currentMission(a).id
 view.expeditionFirstClear=not Modes.claimed(hero,view.expeditionMission,a.difficultyId)
 view.expeditionBalanceVersion=a.balanceVersion or 1
 view.seleneUnlocked=P.seleneUnlocked(hero.deepwood)
 view.seleneFollowing=hero.deepwood and hero.deepwood.seleneFollowing
 return view
end
local function resetJournal(base,c)
 if c.side then
  local s=P.copy(base);s.clears[c.id]=nil;s.accepted=s.accepted or {};s.accepted[c.id]=true
  for _,g in ipairs(c.goals)do
   local key=c.id..':'..g.id;s.flags[key]=nil;if s.expansionWaivers then s.expansionWaivers[key]=nil end;if s.pacingWaivers then s.pacingWaivers[key]=nil end
   for _,field in ipairs({'activities','clues'})do if s[field]then s[field][key]=nil end end
   for _,step in ipairs(g.activity and g.activity.steps or {})do if s.decisions then s.decisions[key..':'..step.id]=nil end end
  end
  s.coins=0;for id in pairs(s.clears)do s.coins=s.coins+(Content.byId[id].journalCoins or Content.byId[id].reward.coins) end
  assert(P.validate(s),'Invalid side replay journal');return s
 end
 -- A replay projection has a synthetic completed prefix, never paid into the hero.
 -- This also supports replaying FV/EC before a migrated hero fills the new GW gap.
 local s=P.new();s.killCoins=base.killCoins or 0
 local main=c.side and base.main or c.number-1
 for _,chapter in ipairs(Content.chapters)do
  local retain=not chapter.side and chapter.number<=main
   or chapter.side and chapter.id~=c.id and chapter.minMain<=main and base.clears[chapter.id]
  if retain then
   s.clears[chapter.id]=true;s.coins=s.coins+(chapter.journalCoins or chapter.reward.coins)
   for _,g in ipairs(chapter.goals)do
    local key=chapter.id..':'..g.id
    if not g.expansion and not g.pacing and (not g.optional or base.flags[key])then
     s.flags[key]=true
     local steps=g.activity and g.activity.steps
     if steps then
      s.activities[key]=#steps
      for _,step in ipairs(steps)do
       if g.activity.mode=='investigate'then s.clues[key]=s.clues[key]or {};s.clues[key][step.id]=true end
       if step.choices then s.decisions[key..':'..step.id]=(base.decisions or {})[key..':'..step.id]or step.choices[1].id end
      end
     end
     if g.choice then s.choice=base.choice~=''and base.choice or 'sanctuary'end
    end
   end
  end
 end
 s.main=main
 for id,cells in pairs(base.explored or {})do if Content.zones[id].requiresMain<=main then s.explored[id]=P.copy(cells)end end
 if P.seleneUnlocked(s)then s.seleneFollowing=base.seleneFollowing end
 if c.side then s.accepted[c.id]=true end
 assert(P.validate(s),'Invalid replay prefix')
 return s
end
local function pinnedRun(hero,missionId,mode)
 local saved=hero.expeditions.runsByMode[mode]
 local previous=currentMission(saved)
 if saved and previous and previous.id==missionId and not saved.journal.clears[missionId]then return saved end
end
-- Store only compact, server-derived chapter eligibility in the lobby roster.
function A.partyRoutes(hero)
 local routes={}
 for _,mode in ipairs(D.order) do
  local journal=Modes.journal(hero,mode)
  local expedition=hero.expeditions
  local saved=expedition and expedition.runsByMode and expedition.runsByMode[mode]
  local active=expedition and expedition.active
  if active and active.difficultyId==mode and not active.partyAssist then saved=active end
  local checkpoint=currentMission(saved)
  local versions={}
  for i,chapter in ipairs(Content.mainChapters) do
   local version=0
   if D.allowed(hero,chapter.id,mode,journal) then
    version=D.version
    if checkpoint==chapter and not saved.journal.clears[chapter.id] then version=saved.balanceVersion or 1 end
   end
   versions[i]=version
  end
  routes[mode]={next=math.min(journal.main+1,Content.mainCount),versions=versions}
 end
 return routes
end
-- Match destination resume semantics without changing the source account.
function A.departureVersion(hero,missionId,mode)
 local h=P.copy(hero)
 A.upgradeHero(h)
 if h.expeditions.active then Modes.save(h,h.expeditions.active)end
 local saved=pinnedRun(h,missionId,mode)
 return saved and (saved.balanceVersion or 1)or D.version
end
function A.begin(profile,heroId,missionId,mode,runId,revision,R,C,version,party)
 local hero=profile.heroes[heroId];if not hero then return nil,'HeroNotOwned'end
 local old=hero.expeditions and hero.expeditions.active
 if old and old.runId==runId then
  if old.missionId~=missionId or old.difficultyId~=mode then return nil,'RequestConflict'end
  return R.copy(profile),nil,true
 end
 if revision~=profile.revision then return nil,'Changed'end
 if type(runId)~='string'or #runId==0 or #runId>64 or not runId:match('^[%w_-]+$')then return nil,'InvalidRequest'end
 version=version or D.version;if not D.compatible(version)then return nil,'AdventureChanged'end
 local ok,why=D.allowed(hero,missionId,mode);if not ok then return nil,why end
 local p=R.copy(profile);local h=p.heroes[heroId];local c=Content.byId[missionId]
 A.upgradeHero(h)
 if h.expeditions.active then Modes.save(h,h.expeditions.active)end
 local saved=h.expeditions.runsByMode[mode]
 local previous=currentMission(saved)
 local resume=saved and saved.modeProgressVersion==1 and previous and previous.id==missionId and not saved.journal.clears[missionId]
 -- Resuming an unfinished run never changes its pinned reward/combat budget.
 local pinned=pinnedRun(h,missionId,mode)
 if pinned then version=saved.balanceVersion or 1 end
 local base=Modes.journal(h,mode);local first=not Modes.claimed(h,missionId,mode)
 local journal=resume and P.copy(saved.journal)or base.clears[missionId]and resetJournal(base,c)or base
 if version>=13 then journal=assert(P.enableExpansion(journal))end
 if c.side then journal.accepted=journal.accepted or {};journal.accepted[c.id]=true end
 local kills={}
 if resume then for id,value in pairs(saved.kills)do
  if saved.missionId==missionId then kills[id]=value
  elseif id:sub(1,#missionId+1)==missionId..':'then kills[id:sub(#missionId+2)]=value end
 end end
 h.expeditions.active={version=1,modeProgressVersion=1,replay=resume and saved.replay==true or base.clears[missionId]==true,balanceVersion=version,runId=runId,missionId=missionId,difficultyId=mode,journal=journal,completed=false,firstClear=first,kills=kills,completedChapters={}}
 local active=h.expeditions.active
 if party and base.clears[missionId] then
  active.partyAssist=true
  -- Keep receipts for the helper's unfinished chapter if the party reaches it.
  if saved and previous and not saved.journal.clears[previous.id] and previous.id~=missionId then
   for key,value in pairs(saved.kills) do
    local prefix=previous.id..':'
    if saved.missionId==previous.id and not key:find(':',1,true) then active.kills[prefix..key]=value
    elseif key:sub(1,#prefix)==prefix then active.kills[key]=value end
   end
  end
 end
 if GrowthBudget.enabled(version)then active.growthCycle=pinned and saved.growthCycle or GrowthBudget.cycle(h,mode)end
 Modes.save(h,active)
 p.revision=p.revision+1
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
function A.event(profile,heroId,chapterId,goalId,choice,stepId,R,C,runId)
 local hero=profile.heroes[heroId];local active=hero and hero.expeditions and hero.expeditions.active
 if not active or active.runId~=runId then return nil,'AdventureChanged'end
 local nextChapter=A.continuation(active)
 if active.missionId~=chapterId and (not nextChapter or nextChapter.id~=chapterId)then
  -- A lost response may retry a completed chapter after the frontier moved.
  -- Explicit run receipts also cover EC/FV -> GW backward transitions.
  local start,c=Content.byId[active.missionId],Content.byId[chapterId]
  if start and not start.side and c and not c.side
   and (active.completedChapters and active.completedChapters[chapterId]or c.number>=start.number)
   and active.journal.flags[chapterId..':'..goalId]then
   return R.copy(profile),nil,true
  end
  return nil,'AdventureChanged'
 end
 local c=Content.byId[chapterId];local p,why,journal,reward
 local allowed,entryError=D.allowed(hero,chapterId,active.difficultyId)
 if not allowed then return nil,entryError end
 local firstClear=not Modes.claimed(hero,chapterId,active.difficultyId)
 if firstClear then
  p,why=R.story(profile,heroId,chapterId,goalId,choice,C,stepId,active.difficultyId,active.balanceVersion or 1,active.growthCycle,active.journal)
  if not p then return nil,why end
  journal=P.copy(p.heroes[heroId].expeditions.active.journal)
 else
  local source=active.journal
  if (active.balanceVersion or 1)>=13 then source=assert(P.enableExpansion(source))end
  journal,why,reward=P.apply(source,chapterId,goalId,choice,stepId)
  if not journal then return nil,why end
  if reward.repeated then return R.copy(profile),nil,true end
  p=R.copy(profile);p.revision=p.revision+1
 end
 local h=p.heroes[heroId];local e=h.expeditions;local a=e.active;a.journal=journal
 if journal.clears[chapterId]and not active.journal.clears[chapterId]then
  if not c.side then a.completedChapters=a.completedChapters or {};a.completedChapters[chapterId]=true end
  a.completed=true;e.clears[chapterId]=e.clears[chapterId]or {};e.clears[chapterId][a.difficultyId]=true
  Economy.claimDifficulty(p,chapterId,a.difficultyId,heroId)
  local reward=D.completion(c,a.difficultyId,a.balanceVersion or 1,a.growthCycle)
  if not firstClear then
   local xp,gold=reward.xp,reward.gold
   h.progression.xp=h.progression.xp+xp
   while h.level<G.maxLevel and h.progression.xp>=G.xpToNext(h.level)do h.progression.xp=h.progression.xp-G.xpToNext(h.level);h.level=h.level+1 end
   if h.level==G.maxLevel then h.progression.xp=0 end
   h.progression.level=h.level;h.progression.revision=h.progression.revision+1;p.wallet.gold=p.wallet.gold+gold
  end
  if D.combat(c)then
   local prefix='run-'..a.runId..'-'..heroId..(chapterId~=a.missionId and '-'..chapterId or '')
   F.grant(p,R,C,heroId,'iron_ore',reward.ore,prefix..'-ore')
   F.grant(p,R,C,heroId,'forge_core',reward.cores,prefix..'-core')
   F.grant(p,R,C,heroId,'enhancement_gem',reward.gems,prefix..'-gem')
   F.grant(p,R,C,heroId,'magic_stone',reward.stones,prefix..'-stone')
   local tier=tostring(D.tier(c));local progress=(e.cacheProgress[tier]or 0)+reward.cache
   local caches=math.floor(progress/4);e.cacheProgress[tier]=progress%4
   F.grant(p,R,C,heroId,'equipment_cache_'..tier,caches,prefix..'-cache')
  end
  if GrowthBudget.enabled(a.balanceVersion)then GrowthBudget.record(h,c.id,a.difficultyId,a.growthCycle)end
 end
 if a.partyAssist and journal.clears[chapterId] then
  local nextChapter=A.continuation(a)
  local personal=Modes.journal(h,a.difficultyId)
  if nextChapter and nextChapter.number==personal.main+1 then
   a.journal=Modes.merge(a.journal,personal,nextChapter.id)
  end
 end
 if a.partyAssist and firstClear and not c.side then
  local parked=e.runsByMode[a.difficultyId]
  local checkpoint=currentMission(parked)
  if not checkpoint or not checkpoint.side then a.partyAssist=nil end
 end
 Modes.save(h,a,chapterId)
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
function A.accept(profile,heroId,chapterId,discovery,R,C,runId)
 local h=profile.heroes[heroId];local a=h and h.expeditions and h.expeditions.active
 if not a or a.runId~=runId then return nil,'AdventureChanged'end
 local journal,why,repeated=P.accept(a.journal,chapterId,discovery)
 if not journal then return nil,why end
 if repeated then return R.copy(profile),nil,true end
 local p=R.copy(profile);h=p.heroes[heroId];a=h.expeditions.active;a.journal=journal
 Modes.save(h,a,chapterId);h.deepwood=Modes.merge(h.deepwood,journal,chapterId);p.revision=p.revision+1
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
return A
