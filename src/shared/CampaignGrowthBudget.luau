-- Rules 16 campaign XP. Budgets describe complete main campaigns, not guaranteed
-- levels after deaths, optional quests, farming, or starting above the baseline.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local C,P,G=load('CampaignContent'),load('EncounterPopulation'),load('HeroProgression')
local M={rulesVersion=16,targets={Easy={10,17,23,27,30},Hard={36,42,48,54,60},Insane={64,68,72,76,80},Hell={82,84,86,88,90}},starts={Easy=1,Hard=30,Insane=60,Hell=80},hellEnds={90,95,97,98,99}}
local cache={}
function M.enabled(version)return type(version)=='number'and version>=M.rulesVersion end
function M.cycle(hero,mode)
 local progress=hero and hero.expeditions and hero.expeditions.campaignProgress
 return (progress and progress[mode]and progress[mode].clears or 0)+1
end
function M.enemyLevel(level,mode)
 local authored={5,12,18,27,37,44};local targets={M.starts[mode]}
 for _,v in ipairs(M.targets[mode])do targets[#targets+1]=v end
 if level<=authored[1]then return targets[1]end
 for i=2,#authored do if level<=authored[i]then
  return math.floor(targets[i-1]+(targets[i]-targets[i-1])*(level-authored[i-1])/(authored[i]-authored[i-1])+.5)
 end end
 return targets[#targets]
end
local function baseXP(spec)return (8+2*spec.level)*(P.isBoss(spec.kind)and 5 or 1)end
local function schedule(mode,cycle)
 cycle=cycle or 1;local key=mode..':'..cycle;if cache[key]then return cache[key]end
 local epicBudgets={};local previous=G.xpAtLevel(M.starts[mode])
 if mode=='Hell'and cycle>1 then
  local first=G.xpAtLevel(M.hellEnds[math.min(cycle-1,5)])
  local last=G.xpAtLevel(M.hellEnds[math.min(cycle,5)])
  local allocated=0
  for epic=1,5 do local cumulative=math.floor((last-first)*epic/5);epicBudgets[epic]=cumulative-allocated;allocated=cumulative end
 else
  for epic,level in ipairs(M.targets[mode])do local nextXP=G.xpAtLevel(level);epicBudgets[epic]=nextXP-previous;previous=nextXP end
 end
 local rows={}
 for epic=1,5 do
  local chapters,weight={},0
  for _,c in ipairs(C.mainChapters)do if c.epic==epic then
   local units={};local combat=0
   for _,g in ipairs(c.goals)do for _,wave in ipairs(P.encounterWaves(c,g,1))do for _,s in ipairs(wave)do
    units[#units+1]=s;combat=combat+baseXP(s)/(s.rewardCopies or 1)
   end end end
   -- Safe hubs require no separate upper-mode entry and pay no XP in this schedule.
   if #units>0 then
    local value=c.reward.xp+math.floor(combat+.5);weight=weight+value
    chapters[#chapters+1]={chapter=c,units=units,weight=value}
   else rows[c.id]={factor=0,quest=0,total=0}end
  end end
  local seen,allocated=0,0
  for _,row in ipairs(chapters)do
   seen=seen+row.weight;local cumulative=math.floor(epicBudgets[epic]*seen/weight)
   local budget=cumulative-allocated;allocated=cumulative
   local factor=budget/row.weight;local kills=0
   for _,s in ipairs(row.units)do
    local whole=math.floor(baseXP(s)*factor)
    local copies=s.rewardCopies or 1
    kills=kills+math.floor(whole/copies)+((s.rewardIndex or 1)<=whole%copies and 1 or 0)
   end
   rows[row.chapter.id]={factor=factor,quest=budget-kills,total=budget}
   assert(budget>=kills,'Campaign XP allocation must cover all kills')
  end
 end
 cache[key]=rows;return rows
end
function M.row(id,mode,cycle)return schedule(mode,cycle)[id]end
function M.entryLevel(c)
 if c.side then return 1 end
 local total=0
 for _,chapter in ipairs(C.mainChapters)do if chapter.number<c.number then total=total+M.row(chapter.id,'Easy',1).total end end
 local level=1;while level<G.maxLevel and G.xpAtLevel(level+1)<=total do level=level+1 end
 return level
end
function M.questXP(id,mode,version,cycle)
 if not M.enabled(version)then return nil end
 local row=M.row(id,mode,cycle);return row and row.quest
end
function M.killXP(spec,mode,version,cycle)
 if not M.enabled(version)or not spec.chapterId then return nil end
 local row=M.row(spec.chapterId,mode,cycle)
 return row and math.floor(baseXP(spec)*row.factor)
end
function M.record(hero,id,mode,cycle)
 local c=C.byId[id];if not c or c.side or M.row(id,mode,cycle).total==0 then return end
 local e=hero.expeditions;e.campaignProgress=e.campaignProgress or {}
 local progress=e.campaignProgress[mode]or {clears=0,chapters={}};e.campaignProgress[mode]=progress
 if cycle~=progress.clears+1 then return end
 progress.chapters[id]=true
 for _,chapter in ipairs(C.mainChapters)do
  if M.row(chapter.id,mode,cycle).total>0 and not progress.chapters[chapter.id]then return end
 end
 progress.clears=progress.clears+1;progress.chapters={}
end
return M
