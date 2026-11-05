local D=dofile('src/shared/Difficulty.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local S=dofile('src/shared/EncounterSummary.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b,m)check(math.abs(a-b)<1e-8,m)end
local old={{1,1},{1.15,1.1},{1.3,1.2},{1.5,1.35}}
for i,mode in ipairs(D.order)do
 local before,after=D.mode(mode,2),D.mode(mode,3)
 near(before.damage,old[i][1],'existing v2 normal damage remains pinned')
 near(before.bossDamage,old[i][2],'existing v2 boss damage remains pinned')
 near(after.damage/before.damage,1.25,'new normal attacks up 25 percent')
 near(after.bossDamage/before.bossDamage,1.25,'new boss attacks up 25 percent')
 check(after~=before,'new rules cannot mutate old mode row')
 for _,field in ipairs({'hp','bossHP','level','levelShift','xp','gold','cache'})do check(after[field]==before[field],'only outgoing damage changes')end
 for _,chapter in ipairs(C.chapters)do
  local reward,prior=D.completion(chapter,mode,3),D.completion(chapter,mode,2)
  for key,value in pairs(prior)do check(reward[key]==value,'reward unchanged across rule generations')end
  for party=1,4 do
   local preview=S.mission(chapter,mode,party,3)
   local sample={}
   for _,goal in ipairs(chapter.goals)do
    for _,group in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(group)do
     local hp,damage,level,elite=B.unitStats(spec,party,mode,3,index)
     local oldHP,oldDamage,oldLevel,oldElite=B.unitStats(spec,party,mode,2,index)
     check(hp==oldHP and level==oldLevel and elite==oldElite,'health/level/elite unchanged')
     check(damage>=oldDamage and math.abs(damage-oldDamage*1.25)<=(elite=='Empowered'and 2.4 or 1.125),'single damage increase with bounded integer/elite rounding')
     local kind=B.isBoss(spec.kind)and 'boss'or 'normal'
     local row=sample[kind]or {lo=math.huge,hi=0};sample[kind]=row
     row.lo=math.min(row.lo,damage);row.hi=math.max(row.hi,damage)
    end end
   end
   for kind,row in pairs(sample)do check(preview[kind].damageMin==row.lo and preview[kind].damageMax==row.hi,'entry preview matches actual finite waves')end
  end
 end
end
check(D.compatible(1)and D.compatible(2)and D.compatible(3)and not D.compatible(4),'old journals remain supported, unknown versions rejected')
near(D.mode('Hell',1).damage,1.65,'legacy v1 normal preserved')
near(D.mode('Hell',1).bossDamage,1.5,'legacy v1 boss preserved')
-- Exercise persisted v2 rejoin/complete separately from current-v3 departures.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local profile=assert(R.addHero(R.new(72),'hero','knight',Items))
profile.heroes.hero.progression=G.new(80);profile.heroes.hero.level=80
profile=assert(A.begin(profile,'hero','DW-01','Easy','v2',profile.revision,R,Items,2))
check(R.validate(profile,Items),'v2 journal loads')
check(D.verifyRun(profile.heroes.hero,{id='v2',missionId='DW-01',difficultyId='Easy',rulesVersion=2}),'v2 run rejoins safely')
check(not D.verifyRun(profile.heroes.hero,{id='v2',missionId='DW-01',difficultyId='Easy',rulesVersion=3}),'rejoin cannot silently switch damage version')
profile=assert(A.begin(profile,'hero','DW-01','Easy','v3',profile.revision,R,Items))
check(profile.heroes.hero.expeditions.active.balanceVersion==3,'new departures persist damage generation')
print('Monster damage tuning: '..n..' checks passed')
