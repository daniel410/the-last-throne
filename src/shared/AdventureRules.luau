local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local D,P,G,Content,F=load('Difficulty'),load('DeepwoodProgress'),load('HeroProgression'),load('CampaignContent'),load('EquipmentTransactions')
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
function A.selection(hero)
 local a=hero and hero.expeditions and hero.expeditions.active
 local current=currentMission(a)
 local frontier=Content.mainChapters[math.min(Content.mainCount,(hero and hero.deepwood and hero.deepwood.main or 0)+1)]
 -- Unfinished optional expeditions never pin Continue to an already completed epic.
 if current and current.side and frontier and hero.deepwood and hero.deepwood.main<Content.mainCount and ((frontier.epic or 1)>(current.epic or 1)or hero.deepwood.legacyMain~=nil and hero.deepwood.main<current.minMain)then
  return {missionId=frontier.id,difficultyId='Easy'}
 end
 if a and a.difficultyId=='Easy' and current and not current.side and frontier.number>current.number then current=frontier end
 return {missionId=(current or frontier).id,difficultyId=a and a.difficultyId or 'Easy'}
end
local function integer(n,min,max)return type(n)=='number'and n%1==0 and n>=min and n<=max end
function A.valid(hero)
 local e=hero.expeditions;if e==nil then return true end
 if type(e)~='table'or e.version~=1 or type(e.clears)~='table'or type(e.cacheProgress)~='table'then return false end
 for id,modes in pairs(e.clears)do if not Content.byId[id]or type(modes)~='table'then return false end;for mode,v in pairs(modes)do if not D.modes[mode]or v~=true then return false end end end
 for tier,n in pairs(e.cacheProgress)do if (tier~='1'and tier~='5'and tier~='10')or not integer(n,0,3)then return false end end
 local a=e.active
 if a~=nil then
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
 local view=P.copy(a.completed and a.returnToCampaign and hero.deepwood or a.journal)
 for id,cells in pairs(hero.deepwood and hero.deepwood.explored or {})do
  local zone=Content.zones[id]
  if zone and Content.accessible(view,zone.requiresMain,zone.legacyRequiresMain) then
   view.explored[id]=view.explored[id]or {}
   for cell,revealed in pairs(cells)do view.explored[id][cell]=revealed end
  end
 end
 local nextChapter=A.continuation(a)
 view.expeditionMission=nextChapter and nextChapter.id or currentMission(a).id
 view.expeditionFirstClear=not (hero.deepwood and hero.deepwood.clears[view.expeditionMission])
 view.seleneUnlocked=P.seleneUnlocked(hero.deepwood)
 view.seleneFollowing=hero.deepwood and hero.deepwood.seleneFollowing
 return view
end
local function resetJournal(base,c)
 if c.side then
  local s=P.copy(base);s.clears[c.id]=nil;s.accepted=s.accepted or {};s.accepted[c.id]=true
  for _,g in ipairs(c.goals)do
   local key=c.id..':'..g.id;s.flags[key]=nil
   for _,field in ipairs({'activities','clues'})do if s[field]then s[field][key]=nil end end
   for _,step in ipairs(g.activity and g.activity.steps or {})do if s.decisions then s.decisions[key..':'..step.id]=nil end end
  end
  s.coins=0;for id in pairs(s.clears)do s.coins=s.coins+Content.byId[id].reward.coins end
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
   s.clears[chapter.id]=true;s.coins=s.coins+chapter.reward.coins
   for _,g in ipairs(chapter.goals)do
    local key=chapter.id..':'..g.id
    if not g.optional or base.flags[key]then
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
function A.begin(profile,heroId,missionId,mode,runId,revision,R,C,version)
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
 h.expeditions=h.expeditions or {version=1,clears={},cacheProgress={}}
 local first=not (h.deepwood and h.deepwood.clears[missionId])
 local previous=currentMission(old)
 local resume=old and previous and previous.id==missionId and old.difficultyId==mode and not old.journal.clears[missionId]
 local journal=resume and P.copy(old.journal)or first and P.copy(h.deepwood or P.new())or resetJournal(h.deepwood or P.new(),c)
 if c.side then journal.accepted=journal.accepted or {};journal.accepted[c.id]=true;if first then h.deepwood=P.copy(journal)end end
 h.expeditions.active={version=1,balanceVersion=version,runId=runId,missionId=missionId,difficultyId=mode,journal=journal,completed=false,firstClear=first,kills={},completedChapters={}}
 local active=h.expeditions.active
 if not c.side and not first and h.deepwood and h.deepwood.main<c.number-1 then
  active.returnToCampaign=true;active.campaignMain=h.deepwood.main
 end
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
 local firstClear=not (hero.deepwood and hero.deepwood.clears[chapterId])
 if firstClear then
  p,why=R.story(profile,heroId,chapterId,goalId,choice,C,stepId)
  if not p then return nil,why end
  journal=P.copy(p.heroes[heroId].deepwood)
 else
  journal,why,reward=P.apply(active.journal,chapterId,goalId,choice,stepId)
  if not journal then return nil,why end
  if reward.repeated then return R.copy(profile),nil,true end
  p=R.copy(profile);p.revision=p.revision+1
 end
 local h=p.heroes[heroId];local e=h.expeditions;local a=e.active;a.journal=journal
 if a.returnToCampaign then a.campaignMain=h.deepwood.main end
 if journal.clears[chapterId]and not active.journal.clears[chapterId]then
  if not c.side then a.completedChapters=a.completedChapters or {};a.completedChapters[chapterId]=true end
  a.completed=true;e.clears[chapterId]=e.clears[chapterId]or {};e.clears[chapterId][a.difficultyId]=true
  local reward=D.completion(c,a.difficultyId,a.balanceVersion or 1)
  if not firstClear then
   local xp,gold=reward.xp,reward.gold
   h.progression.xp=h.progression.xp+xp
   while h.level<80 and h.progression.xp>=G.xpToNext(h.level)do h.progression.xp=h.progression.xp-G.xpToNext(h.level);h.level=h.level+1 end
   if h.level==80 then h.progression.xp=0 end
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
 end
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
return A
