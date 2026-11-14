local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,D,M,G,P,Routes=load('CampaignContent'),load('DeepwoodEncounterBalance'),load('Difficulty'),load('CampaignGrowthBudget'),load('HeroProgression'),load('DeepwoodProgress'),load('CampaignCombatRoutes')
local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=load('ItemCatalog');local A=load('AdventureRules')
local Areas=load('CampaignAreas')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local easyTargets={10,17,23,27,30}
for epic,level in ipairs(easyTargets)do check(M.targets.Easy[epic]==level,'approved Easy epic endpoint')end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
local previousTotal=0
for _,mode in ipairs(D.order)do for cycle=1,(mode=='Hell'and 5 or 1)do
 local expected=mode=='Hell'and M.hellEnds[cycle]or M.targets[mode][5]
 local amount
 for party=1,4 do
  local xp=0
  for _,c in ipairs(C.mainChapters)do
   xp=xp+M.questXP(c.id,mode,16,cycle)
   for _,g in ipairs(c.goals)do
    local old=B.encounterWaves(c,g,party,mode,15);local waves=B.encounterWaves(c,g,party,mode,16)
    local oldUnits,newUnits={},{}
    for _,wave in ipairs(old)do for _,s in ipairs(wave)do oldUnits[s.killIndex]=s end end
    for _,wave in ipairs(waves)do
     check(#wave<=B.packCapacity(c,g,party,mode,16),'live cap '..c.id)
     for i,s in ipairs(wave)do
      check(not newUnits[s.killIndex],'unique receipt');newUnits[s.killIndex]=s
      local oldSpec=oldUnits[s.killIndex]
      check(oldSpec and s.kind==oldSpec.kind and s.level==oldSpec.level,'receipt identity preserved')
      local x,gold=B.rewards(s,mode,16,cycle);local _,oldGold=B.rewards(oldSpec,mode,15)
      check(gold==oldGold,'Gold unaffected by growth curve');xp=xp+x
      local hp,damage,level=B.unitStats(s,party,mode,16,i)
      check(hp>0 and damage>0 and level>=M.starts[mode]and level<=M.targets[mode][5],'bounded combat level')
     end
    end
    for id in pairs(oldUnits)do check(newUnits[id]~=nil,'all original enemies retained')end
    if #waves>0 then
     local points=Routes.points(c,g,#waves,16,mode)
     check(#points==#waves,'route for every actual pack')
     for i,at in ipairs(points)do
      check(Areas.contains(C.zones[c.zone],at[1],at[3],-35),'real supported ground after overland translation')
      for j=1,i-1 do check(Routes.distance(at,points[j])>=79.9,'distinct supported clearings')end
     end
     local run={missionId='DW-01',difficultyId=mode,balanceVersion=16,kills={}}
     for _,s in ipairs(waves[1])do run.kills[Routes.killId(c,g,run.missionId,s)]=true end
     check(Routes.clearedPrefix(c,g,waves,run)>=1,'confirmed pack recovery')
     check(same(Routes.entry(c,g,run,party),points[math.min(2,#points)]),'rejoin destination uses mode and version')
    end
   end
  end
  amount=amount or xp;check(xp==amount,'party-independent full-campaign XP')
 end
 previousTotal=previousTotal+amount
 check(previousTotal==G.xpAtLevel(expected),'exact ordered campaign milestone '..mode..cycle)
 print(string.format('%s pass %d: +%d XP, total %d, Lv%d',mode,cycle,amount,previousTotal,expected))
end end
-- Full runtime reducers: chapter receipts, no-death growth, reconnect, and all eight campaigns.
local profile=assert(R.addHero(R.new(161699),'hero','knight',Items));local sequence=0
for _,mode in ipairs(D.order)do for cycle=1,(mode=='Hell'and 5 or 1)do
 local runId=mode..'_'..cycle
 profile=assert(A.begin(profile,'hero','DW-01',mode,runId,profile.revision,R,Items))
 check(profile.heroes.hero.expeditions.active.growthCycle==cycle,'server pins personal campaign pass')
 for _,c in ipairs(C.mainChapters)do
  for _,g in ipairs(c.goals)do if P.required(A.projection(profile.heroes.hero),g)then
   local xp=0
   for _,wave in ipairs(B.encounterWaves(c,g,1,mode,16))do for _,s in ipairs(wave)do xp=xp+B.rewards(s,mode,16,cycle)end end
   if #g.enemies>0 then
    sequence=sequence+1
    local command={action='AwardXP',heroId='hero',amount=xp,runId=runId,killId=c.id..':'..g.id,stream='growth-test',sequence=sequence,requestId='growth_'..sequence}
    profile=assert(R.progress(profile,command,{serverReward=true},Items))
    local replay=assert(R.progress(profile,command,{serverReward=true},Items))
    check(G.totalXP(replay.heroes.hero.progression)==G.totalXP(profile.heroes.hero.progression),'kill response retry never pays twice')
   end
   for _,step in ipairs(g.activity and g.activity.steps or {false})do
    local choice=step and(step.solution or step.choices and step.choices[1].id)or g.choice and 'sanctuary'or nil
    profile=assert(A.event(profile,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,runId))
   end
  end end
  check(R.validate(profile,Items),'persisted progress valid at '..c.id)
  if mode=='Easy'and c.number%7==0 then check(profile.heroes.hero.level==easyTargets[c.epic],'actual reducer reaches approved Easy epic level')end
 end
 local hero=profile.heroes.hero
 local expected=mode=='Hell'and M.hellEnds[cycle]or M.targets[mode][5]
 check(hero.level==expected and hero.progression.xp==0,'runtime account hits milestone')
 check(hero.expeditions.campaignProgress[mode].clears==cycle,'full campaign recorded once')
 local again=assert(A.begin(profile,'hero','DW-01',mode,runId,profile.revision,R,Items))
 check(same(again,profile),'rejoin keeps pinned pass and receipts')
end end
local partial=R.copy(profile);partial.heroes.hero.expeditions.campaignProgress.Hell={clears=0,chapters={}}
M.record(partial.heroes.hero,'HG-07','Hell',1)
check(M.cycle(partial.heroes.hero,'Hell')==1,'last boss alone never advances whole-campaign pass')
local invalid=R.copy(profile);invalid.heroes.hero.level=100;invalid.heroes.hero.progression.level=100
check(not R.validate(invalid,Items),'Lv100 rejected')
invalid=R.copy(profile);invalid.heroes.hero.expeditions.campaignProgress.Hell.chapters['HG-Q1']=true
check(not R.validate(invalid,Items),'unknown campaign chapter rejected')
invalid=R.copy(profile);invalid.heroes.hero.expeditions.active.growthCycle=nil
check(not R.validate(invalid,Items),'current run requires pinned pass')
check(same(R.upgrade(R.copy(profile),Items),profile),'load preserves earned levels and campaign receipts')
local g=G.new(99);check(G.validate(g,'knight'),'Lv99 accepted');local stats,skills=G.points(g)
check(stats==392 and skills==98,'new cap budgets');check(G.xpToNext(99)==0 and G.xpToNext(80)>0,'old cap can grow')
local granted=assert(G.apply(g,{action='AwardXP',stream='cap',sequence=1,amount=1000},'knight'))
check(granted.level==99 and granted.xp==0,'new cap discards XP but accepts reward receipt')
local old=assert(A.begin(profile,'hero','DW-01','Easy','legacy15',profile.revision,R,Items,15))
check(old.heroes.hero.expeditions.active.growthCycle==nil and R.validate(old,Items),'old run keeps original contract')
print('Campaign growth v16: '..checks..' checks passed')
