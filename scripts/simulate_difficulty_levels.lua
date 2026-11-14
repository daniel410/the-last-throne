-- Read-only TSV calculation over the runtime campaign. Run from the source root.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,D,S,G=load('CampaignContent'),load('Difficulty'),load('EncounterSummary'),load('HeroProgression')
local function locate(total)
 local level=1
 while level<G.maxLevel and total>=G.xpAtLevel(level+1)do level=level+1 end
 return level,level==G.maxLevel and 0 or total-G.xpAtLevel(level),G.xpToNext(level)
end
local function missionXP(c,mode,players,allGoals)
 local chapter={};for k,v in pairs(c)do chapter[k]=v end;chapter.goals={}
 for _,g in ipairs(c.goals)do if allGoals or not g.optional then table.insert(chapter.goals,g)end end
 local encounter=S.mission(chapter,mode,players,D.version)
 return encounter.xp
end
print('scenario\tmode\tepic\tmission\tkillXP\tquestXP\ttotalXP\tlevel\txpInLevel\txpToNext\tentryShortfall')
-- Main: required goals only. Other cases include every optional main encounter;
-- side_once adds side quests on Easy, all_each_mode adds them on every mode.
for _,scenario in ipairs({'main','side_once','all_each_mode'})do
 for _,players in ipairs({1,4})do
  local total=0
  local heroes={};for _,class in ipairs({'knight','dwarf','elf','mage'})do heroes[class]=G.new()end
  local sequence=0
  local function verifyGrowth(amount)
   if amount==0 then return end
   sequence=sequence+1
   local expected,xp=locate(total)
   for class,hero in pairs(heroes)do
    heroes[class]=assert(G.apply(hero,{action='AwardXP',stream='difficulty-estimate',sequence=sequence,amount=amount},class))
    assert(heroes[class].level==expected and heroes[class].xp==xp,'XP curve disagrees with hero reducer: '..class)
   end
  end
  for _,mode in ipairs(D.order)do
   local sumKill,sumQuest=0,0
   for _,c in ipairs(C.mainChapters)do
    local shortfall=mode=='Easy' and math.max(0,G.xpAtLevel(D.requiredLevel(c,mode))-total)or 0
    local kill=missionXP(c,mode,players,scenario~='main')
    local quest=mode=='Easy'and c.reward.xp or D.completion(c,mode,D.version).xp
    total=total+kill+quest;verifyGrowth(kill+quest);sumKill=sumKill+kill;sumQuest=sumQuest+quest
    local level,xp,nextXP=locate(total)
    print(table.concat({scenario..'_p'..players,mode,c.epic,c.id,kill,quest,total,level,xp,nextXP,shortfall},'\t'))
    if scenario~='main'and (mode=='Easy'or scenario=='all_each_mode')then
     for _,side in ipairs(C.chapters)do if side.side and D.requiredMain(side)==c.number then
      local sideKill=missionXP(side,mode,players,true)
      local sideQuest=mode=='Easy'and side.reward.xp or D.completion(side,mode,D.version).xp
      total=total+sideKill+sideQuest;verifyGrowth(sideKill+sideQuest);sumKill=sumKill+sideKill;sumQuest=sumQuest+sideQuest
      level,xp,nextXP=locate(total)
      print(table.concat({scenario..'_p'..players,mode,side.epic,side.id,sideKill,sideQuest,total,level,xp,nextXP,0},'\t'))
     end end
    end
   end
   local level,xp,nextXP=locate(total)
   print(table.concat({scenario..'_p'..players,mode,'ALL','SUMMARY',sumKill,sumQuest,total,level,xp,nextXP,0},'\t'))
  end
 end
end
