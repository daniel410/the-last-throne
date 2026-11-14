-- Campaign checkpoints are estimates for a baseline route, never XP or level setters.
-- Fixed quest/kill awards live in CampaignXPRewards; repetition never reduces them.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local C,P,G=load('CampaignContent'),load('EncounterPopulation'),load('HeroProgression')
local M={rulesVersion=16,targets={Easy={10,17,23,27,30},Hard={36,42,48,54,60},Insane={64,68,72,76,80},Hell={82,84,86,88,90}},starts={Easy=1,Hard=30,Insane=60,Hell=80},hellEnds={90,95,97,98,99}}
local Rewards=load('CampaignXPRewards')
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
function M.row(id,mode,cycle)return assert(Rewards[mode],'Unsupported XP mode')[id]end
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
 return row and math.floor(baseXP(spec)*row.factor)*row.killMultiplier
end
local function combat(c)
 for _,g in ipairs(c.goals)do if #g.enemies>0 then return true end end
 return false
end
function M.record(hero,id,mode,cycle)
 local c=C.byId[id];if not c or c.side or not combat(c)then return end
 local e=hero.expeditions;e.campaignProgress=e.campaignProgress or {}
 local progress=e.campaignProgress[mode]or {clears=0,chapters={}};e.campaignProgress[mode]=progress
 if cycle~=progress.clears+1 then return end
 progress.chapters[id]=true
 for _,chapter in ipairs(C.mainChapters)do
  if combat(chapter)and not progress.chapters[chapter.id]then return end
 end
 progress.clears=progress.clears+1;progress.chapters={}
end
return M
