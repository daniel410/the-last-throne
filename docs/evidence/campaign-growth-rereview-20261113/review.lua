-- Read-only local audit. Run from repository root; no Studio/live account writes.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,M,G,D,P,A=load('CampaignContent'),load('DeepwoodEncounterBalance'),load('CampaignGrowthBudget'),load('HeroProgression'),load('Difficulty'),load('DeepwoodProgress'),load('AdventureRules')
local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=load('ItemCatalog')
local function locate(x)
 x=math.min(x,G.xpAtLevel(G.maxLevel))
 local level=1;while level<G.maxLevel and G.xpAtLevel(level+1)<=x do level=level+1 end
 return {level=level,xp=x-G.xpAtLevel(level),totalXP=x}
end
local result={rules=D.version,maxLevel=G.maxLevel,baseline={},withAllEasySideCombat={},zeroXP={},edgeCases={}}
local total=0
for _,mode in ipairs(D.order)do for cycle=1,(mode=='Hell'and 5 or 1)do
 local entry={mode=mode,cycle=cycle,epics={},questXP=0,killXP=0}
 for epic=1,5 do
  local quest,kill=0,0
  for _,c in ipairs(C.mainChapters)do if c.epic==epic then
   quest=quest+M.questXP(c.id,mode,16,cycle)
   for _,g in ipairs(c.goals)do for _,wave in ipairs(B.encounterWaves(c,g,1,mode,16))do for _,s in ipairs(wave)do kill=kill+B.rewards(s,mode,16,cycle)end end end
  end end
  total=total+quest+kill;entry.questXP=entry.questXP+quest;entry.killXP=entry.killXP+kill
  entry.epics[#entry.epics+1]={epic=epic,questXP=quest,killXP=kill,xp=quest+kill,finish=locate(total)}
 end
 entry.finish=locate(total);result.baseline[#result.baseline+1]=entry
end end
total=0
for epic=1,5 do
 local side=0
 for _,c in ipairs(C.chapters)do if c.epic==epic then
  if c.side then
   side=side+c.reward.xp
   for _,g in ipairs(c.goals)do for _,wave in ipairs(B.encounterWaves(c,g,1,'Easy',16))do for _,s in ipairs(wave)do side=side+B.rewards(s,'Easy',16,1)end end end
  else total=total+M.row(c.id,'Easy',1).total end
 end end
 total=total+side;result.withAllEasySideCombat[#result.withAllEasySideCombat+1]={epic=epic,additionalXP=side,finish=locate(total)}
end
for party=1,4 do for cycle=1,6 do
 local zero,count,xp=0,0,0
 for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do for _,wave in ipairs(B.encounterWaves(c,g,party,'Hell',16))do for _,s in ipairs(wave)do
  local amount=B.rewards(s,'Hell',16,cycle);count=count+1;xp=xp+amount;if amount==0 then zero=zero+1 end
 end end end end
 result.zeroXP[#result.zeroXP+1]={party=party,cycle=cycle,zero=zero,count=count,killXP=xp}
end end
local hardXP=0;for _,c in ipairs(C.mainChapters)do hardXP=hardXP+M.row(c.id,'Hard',1).total end
result.edgeCases.hardFrom47=locate(G.xpAtLevel(47)+hardXP)
local skipped=0
for _,mode in ipairs({'Hard','Insane','Hell'})do for cycle=1,(mode=='Hell'and 5 or 1)do for _,c in ipairs(C.mainChapters)do skipped=skipped+M.row(c.id,mode,cycle).total end end end
result.edgeCases.skipEasyThroughHell5=locate(skipped)
result.edgeCases.repeatLowerModesFrom80={}
for _,mode in ipairs({'Hard','Insane'})do
 local growth=G.new(80);local rows={}
 for cycle=2,3 do
  local amount=0;for _,c in ipairs(C.mainChapters)do amount=amount+M.row(c.id,mode,cycle).total end
  growth=assert(G.apply(growth,{action='AwardXP',stream='lower-repeat',sequence=cycle-1,amount=amount},'knight'))
  rows[#rows+1]={cycle=cycle,xpAward=amount,level=growth.level,xp=growth.xp}
 end
 result.edgeCases.repeatLowerModesFrom80[mode]=rows
end

-- Seed a valid, previously completed hero at the start of Hell pass 5.
local profile=assert(R.addHero(R.new(161613),'hero','knight',Items))
profile.heroes.hero.level=98;profile.heroes.hero.progression=G.new(98)
for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do
 if P.required(profile.heroes.hero.deepwood or P.new(),g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   profile=assert(R.story(profile,'hero',c.id,g.id,step and(step.solution or step.choices and step.choices[1].id)or g.choice and 'sanctuary',Items,step and step.id or nil))
  end
 end
end end
local hero=profile.heroes.hero;hero.level=98;hero.progression=G.new(98)
local prior=G.xpAtLevel(80)
for cycle=1,4 do for _,c in ipairs(C.mainChapters)do prior=prior+M.row(c.id,'Hell',cycle).total end end
hero.progression.xp=prior-G.xpAtLevel(98)
hero.expeditions={version=1,clears={},cacheProgress={},campaignProgress={Hell={clears=4,chapters={}}}}
for _,c in ipairs(C.mainChapters)do hero.expeditions.clears[c.id]={Easy=true,Hard=true,Insane=true,Hell=true}end
assert(R.validate(profile,Items))
local sequence,loss=0,0
for cycle=5,6 do
 local run='audit_hell_'..cycle
 profile=assert(A.begin(profile,'hero','DW-01','Hell',run,profile.revision,R,Items))
 assert(profile.heroes.hero.expeditions.active.growthCycle==cycle)
 local before=G.totalXP(profile.heroes.hero.progression)
 for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do if P.required(A.projection(profile.heroes.hero),g)then
  local xp=0
  for _,wave in ipairs(B.encounterWaves(c,g,1,'Hell',16))do for _,s in ipairs(wave)do xp=xp+B.rewards(s,'Hell',16,cycle)end end
  if #g.enemies>0 then
   sequence=sequence+1
   profile=assert(R.progress(profile,{action='AwardXP',heroId='hero',amount=xp,runId=run,killId=c.id..':'..g.id,stream='audit',sequence=sequence,requestId='xp_'..sequence},{serverReward=true},Items))
   if cycle==5 and loss==0 and profile.heroes.hero.progression.xp>=40000 then
    local old=G.totalXP(profile.heroes.hero.progression)
    profile=assert(R.progress(profile,{action='DeathPenalty',heroId='hero',requestId='audit_death',training=false},{serverReward=true},Items))
    loss=old-G.totalXP(profile.heroes.hero.progression)
   end
  end
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   profile=assert(A.event(profile,'hero',c.id,g.id,step and(step.solution or step.choices and step.choices[1].id)or g.choice and 'sanctuary',step and step.id or nil,R,Items,run))
  end
 end end end
 local after=G.totalXP(profile.heroes.hero.progression)
 result.edgeCases['hell'..cycle..'AfterDeath']={lostXP=loss,earnedXP=after-before,finish=locate(after),completedPasses=profile.heroes.hero.expeditions.campaignProgress.Hell.clears}
 assert(R.validate(profile,Items))
end
result.edgeCases.growthBlockedAfterDeath=result.edgeCases.hell5AfterDeath.finish.level<G.maxLevel and result.edgeCases.hell6AfterDeath.earnedXP==0
local function json(value)
 if type(value)=='number'then return tostring(value)end
 if type(value)=='string'then return string.format('%q',value)end
 if type(value)=='boolean'then return tostring(value)end
 local array=#value>0;local rows={}
 if array then for _,v in ipairs(value)do rows[#rows+1]=json(v)end
 else local keys={};for key in pairs(value)do keys[#keys+1]=key end;table.sort(keys);for _,key in ipairs(keys)do rows[#rows+1]=json(key)..':'..json(value[key])end end
 return (array and '['or '{')..table.concat(rows,',')..(array and ']'or '}')
end
print(json(result))
