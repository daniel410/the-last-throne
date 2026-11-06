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
   local hp,damage,level,elite=B.unitStats(spec,party,mode,6,index)
   local oldHP,oldDamage,oldLevel,oldElite=B.unitStats(spec,party,mode,5,index)
   check(damage==oldDamage and level==oldLevel and elite==oldElite,'damage/level/elite preserved')
   check(hp>oldHP and math.abs(hp-oldHP*1.1)<=2,'10 percent health increase with bounded elite/integer rounding')
   local xp,gold=B.rewards(spec,mode,6);local x,y=B.rewards(spec,mode,5)
   check(xp==x and gold==y,'kill reward unchanged')
   local key=B.isBoss(spec.kind)and 'boss'or 'normal'
   local row=sample[key]or {lo=math.huge,hi=0};sample[key]=row
   row.lo=math.min(row.lo,hp);row.hi=math.max(row.hi,hp)
  end end
 end
 local preview=S.mission(chapter,mode,party,6)
 for key,row in pairs(sample)do check(preview[key].hpMin==row.lo and preview[key].hpMax==row.hi,'preview matches spawned health')end
 local a,b=D.completion(chapter,mode,6),D.completion(chapter,mode,5)
 for key,value in pairs(a)do check(value==b[key],'completion reward unchanged')end
end end end
for epic=1,5 do
 local before,after=D.epicScale(epic,5),D.epicScale(epic,6)
 check(after.damage==before.damage and math.abs(after.hp/before.hp-1.1)<1e-8,'all epics get 10 percent health boost')
 local a,b=B.unitStats({kind='Imp',level=20,epic=epic},1,nil,5,1)
 local c,d=B.unitStats({kind='Imp',level=20,epic=epic},1,nil,nil,1)
 check(b==d and c>a and math.abs(c-a*1.1)<=1,'local adventure health boosted once')
end
-- Current departures and rejoin versions are checked by the journal reducer.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local profile=assert(R.addHero(R.new(74),'hero','knight',Items))
profile=assert(A.begin(profile,'hero','DW-01','Easy','v5',profile.revision,R,Items,5))
check(R.validate(profile,Items),'v5 profile still loads')
check(D.verifyRun(profile.heroes.hero,{id='v5',missionId='DW-01',difficultyId='Easy',rulesVersion=5}),'v5 run rejoins without new health')
check(not D.verifyRun(profile.heroes.hero,{id='v5',missionId='DW-01',difficultyId='Easy',rulesVersion=6}),'v5 cannot silently switch to v6')
profile=assert(A.begin(profile,'hero','DW-01','Easy','v6',profile.revision,R,Items))
check(profile.heroes.hero.expeditions.active.balanceVersion==D.version,'new run pins current rules')
print('Monster health boost: '..n..' checks passed')
