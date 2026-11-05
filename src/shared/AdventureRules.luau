local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local D,P,G,Content,F=load('Difficulty'),load('DeepwoodProgress'),load('HeroProgression'),load('CampaignContent'),load('EquipmentTransactions')
local A={}
-- Admission stays bound to the launch mission; every main story in the run
-- follows the journal, including replays, higher difficulties and epic borders.
function A.continuation(a)
 local start=a and Content.byId[a.missionId]
 local nextChapter=a and a.journal and Content.mainChapters[a.journal.main+1]
 if a and a.completed and start and not start.side and nextChapter
  and nextChapter.number>start.number then return nextChapter end
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
  local n=0;for key,v in pairs(a.kills)do if type(key)~='string'or #key>100 or v~=true then return false end;n=n+1 end;if n>4096 then return false end
  if a.completed~=(a.journal.clears[a.missionId]==true)then return false end
 end
 return true
end
-- Fog is hero-wide; replay objective journals must not hide newly saved discovery.
function A.projection(hero)
 local a=hero and hero.expeditions and hero.expeditions.active
 if not a then return nil end
 local view=P.copy(a.journal)
 for id,cells in pairs(hero.deepwood and hero.deepwood.explored or {})do
  local zone=Content.zones[id]
  if zone and zone.requiresMain<=view.main then
   view.explored[id]=view.explored[id]or {}
   for cell,revealed in pairs(cells)do view.explored[id][cell]=revealed end
  end
 end
 local nextChapter=A.continuation(a)
 view.expeditionMission=nextChapter and nextChapter.id or a.missionId
 view.expeditionFirstClear=not (hero.deepwood and hero.deepwood.clears[view.expeditionMission])
 view.seleneUnlocked=P.seleneUnlocked(hero.deepwood)
 view.seleneFollowing=hero.deepwood and hero.deepwood.seleneFollowing
 return view
end
local function resetJournal(base,c)
 local s=P.copy(base)
 for _,key in ipairs({'accepted','activities','decisions','explored','clues'})do s[key]=s[key]or {}end
 local main=c.side and s.main or c.number-1
 for _,chapter in ipairs(Content.chapters)do
  if chapter.id==c.id or not chapter.side and chapter.number>main or chapter.side and chapter.minMain>main then
   s.clears[chapter.id]=nil;s.accepted[chapter.id]=nil
   for _,g in ipairs(chapter.goals)do local key=chapter.id..':'..g.id;s.flags[key]=nil;s.activities[key]=nil;s.clues[key]=nil
    for _,step in ipairs(g.activity and g.activity.steps or {})do s.decisions[key..':'..step.id]=nil end
   end
  end
 end
 s.main=main;s.coins=0
 for id in pairs(s.clears)do s.coins=s.coins+Content.byId[id].reward.coins end
 for id in pairs(s.explored)do if Content.zones[id].requiresMain>main then s.explored[id]=nil end end
 if not s.flags['DW-07:restoration']then s.choice=''end
 if not P.seleneUnlocked(s)then s.seleneFollowing=nil end
 if c.side then s.accepted[c.id]=true end
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
 local journal=first and P.copy(h.deepwood or P.new())or resetJournal(h.deepwood or P.new(),c)
 if c.side then journal.accepted=journal.accepted or {};journal.accepted[c.id]=true;if first then h.deepwood=P.copy(journal)end end
 h.expeditions.active={version=1,balanceVersion=version,runId=runId,missionId=missionId,difficultyId=mode,journal=journal,completed=false,firstClear=first,kills={}}
 p.revision=p.revision+1
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
function A.event(profile,heroId,chapterId,goalId,choice,stepId,R,C,runId)
 local hero=profile.heroes[heroId];local active=hero and hero.expeditions and hero.expeditions.active
 if not active or active.runId~=runId then return nil,'AdventureChanged'end
 local nextChapter=A.continuation(active)
 if active.missionId~=chapterId and (not nextChapter or nextChapter.id~=chapterId)then
  -- A lost save response may retry the final event after its continuation opened.
  local start,c=Content.byId[active.missionId],Content.byId[chapterId]
  if start and not start.side and c and not c.side
   and c.number>=start.number and active.journal.flags[chapterId..':'..goalId]then
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
 if journal.clears[chapterId]and not active.journal.clears[chapterId]then
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
