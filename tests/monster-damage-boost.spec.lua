local D=dofile('src/shared/Difficulty.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local S=dofile('src/shared/EncounterSummary.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
for _,chapter in ipairs(C.chapters)do for _,mode in ipairs(D.order)do for party=1,4 do
 local sample={}
 for _,goal in ipairs(chapter.goals)do
  for _,wave in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(wave)do
   local hp,damage,level,elite=B.unitStats(spec,party,mode,5,index)
   local oldHP,oldDamage,oldLevel,oldElite=B.unitStats(spec,party,mode,4,index)
   check(hp==oldHP and level==oldLevel and elite==oldElite,'health/level/elite preserved')
   check(damage>oldDamage and math.abs(damage-oldDamage*1.2)<=2,'20 percent increase with bounded elite/integer rounding')
   local xp,gold=B.rewards(spec,mode,5);local x,y=B.rewards(spec,mode,4)
   check(xp==x and gold==y,'kill reward unchanged')
   local key=B.isBoss(spec.kind)and 'boss'or 'normal'
   local row=sample[key]or {lo=math.huge,hi=0};sample[key]=row
   row.lo=math.min(row.lo,damage);row.hi=math.max(row.hi,damage)
  end end
 end
 local preview=S.mission(chapter,mode,party,5)
 for key,row in pairs(sample)do check(preview[key].damageMin==row.lo and preview[key].damageMax==row.hi,'preview matches spawned damage')end
 local a,b=D.completion(chapter,mode,5),D.completion(chapter,mode,4)
 for key,value in pairs(a)do check(value==b[key],'completion reward unchanged')end
end end end
for epic=1,5 do
 local before,after=D.epicScale(epic,4),D.epicScale(epic,5)
 check(after.hp==before.hp and math.abs(after.damage/before.damage-1.2)<1e-8,'all epics get 20 percent outgoing boost')
 local a,b=B.unitStats({kind='Imp',level=20,epic=epic},1,nil,4,1)
 local c,d=B.unitStats({kind='Imp',level=20,epic=epic},1,nil,5,1)
 check(a==c and d>b and math.abs(d-b*1.2)<=1,'local adventure damage boosted once')
end
-- Current departures and rejoin versions are checked by the journal reducer.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local profile=assert(R.addHero(R.new(74),'hero','knight',Items))
profile=assert(A.begin(profile,'hero','DW-01','Easy','v4',profile.revision,R,Items,4))
check(R.validate(profile,Items),'v4 profile still loads')
check(D.verifyRun(profile.heroes.hero,{id='v4',missionId='DW-01',difficultyId='Easy',rulesVersion=4}),'v4 run rejoins without new damage')
check(not D.verifyRun(profile.heroes.hero,{id='v4',missionId='DW-01',difficultyId='Easy',rulesVersion=5}),'v4 cannot silently switch to v5')
profile=assert(A.begin(profile,'hero','DW-01','Easy','v5',profile.revision,R,Items))
check(profile.heroes.hero.expeditions.active.balanceVersion==D.version,'new run pins current rules')
print('Monster damage boost: '..n..' checks passed')
