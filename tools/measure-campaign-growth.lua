-- Run from repository root. Optional argument "combat" emits Easy enemy ranges.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,M,G,D=load('CampaignContent'),load('DeepwoodEncounterBalance'),load('CampaignGrowthBudget'),load('HeroProgression'),load('Difficulty')
if arg and arg[1]=='combat'then
 print('epic,levelMin,levelMax,normalHPMin,normalHPMax,normalDamageMin,normalDamageMax,bossHPMin,bossHPMax,bossDamageMin,bossDamageMax,count,peak')
 for epic=1,5 do
  local row={epic,math.huge,0,math.huge,0,math.huge,0,math.huge,0,math.huge,0,0,0}
  for _,c in ipairs(C.mainChapters)do if c.epic==epic then for _,g in ipairs(c.goals)do
   for _,wave in ipairs(B.encounterWaves(c,g,1,'Easy',16))do
    row[13]=math.max(row[13],#wave)
    for i,s in ipairs(wave)do
     local hp,damage,level=B.unitStats(s,1,'Easy',16,i);row[2]=math.min(row[2],level);row[3]=math.max(row[3],level)
     local offset=B.isBoss(s.kind)and 8 or 4
     row[offset]=math.min(row[offset],hp);row[offset+1]=math.max(row[offset+1],hp)
     row[offset+2]=math.min(row[offset+2],damage);row[offset+3]=math.max(row[offset+3],damage);row[12]=row[12]+1
    end
   end
  end end end
  print(table.concat(row,','))
 end
 return
end
print('mode,pass,epic,questXP,killXP,epicXP,totalXP,heroLevel,xpInLevel')
local total=0
for _,mode in ipairs(D.order)do for cycle=1,(mode=='Hell'and 5 or 1)do for epic=1,5 do
 local quests,kills=0,0
 for _,c in ipairs(C.mainChapters)do if c.epic==epic then
  quests=quests+M.questXP(c.id,mode,16,cycle)
  for _,g in ipairs(c.goals)do for _,wave in ipairs(B.encounterWaves(c,g,1,mode,16))do for _,s in ipairs(wave)do kills=kills+B.rewards(s,mode,16,cycle)end end end
 end end
 total=math.min(G.xpAtLevel(G.maxLevel),total+quests+kills)
 local level=1;while level<G.maxLevel and G.xpAtLevel(level+1)<=total do level=level+1 end
 print(table.concat({mode,cycle,epic,quests,kills,quests+kills,total,level,total-G.xpAtLevel(level)},','))
end end end
