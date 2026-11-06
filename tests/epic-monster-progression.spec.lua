local D=dofile('src/shared/Difficulty.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local S=dofile('src/shared/EncounterSummary.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local count={0,0,0,0,0}
for _,chapter in ipairs(C.chapters)do for _,mode in ipairs(D.order)do for party=1,4 do
 local sample={}
 for _,goal in ipairs(chapter.goals)do
  for _,wave in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(wave)do
   local epic=chapter.epic or 1
   count[epic]=count[epic]+1
   check(spec.epic==epic,'authored epic survives expansion and finite wave splitting')
   local hp,damage,level,elite=B.unitStats(spec,party,mode,4,index)
   local oldHP,oldDamage,oldLevel,oldElite=B.unitStats(spec,party,mode,3,index)
   check(level==oldLevel and elite==oldElite,'level and elite contract preserved')
   if epic==1 then check(hp==oldHP and damage==oldDamage,'Deepwood unchanged')
   else check(hp>oldHP and damage>oldDamage,'every later-epic unit grows on every difficulty/party size')end
   for version=1,3 do
    local priorHP,priorDamage=B.unitStats(spec,party,mode,version,index)
    local neutral={kind=spec.kind,level=spec.level,epic=1}
    local baseHP,baseDamage=B.unitStats(neutral,party,mode,version,index)
    check(priorHP==baseHP and priorDamage==baseDamage,'saved rules 1-3 retain pre-region stats')
   end
   local xp,gold=B.rewards(spec,mode,4);local x,y=B.rewards(spec,mode,3)
   check(xp==x and gold==y,'regional progression cannot change rewards')
   local key=B.isBoss(spec.kind)and 'boss'or 'normal'
   local row=sample[key]or {hpMin=math.huge,hpMax=0,damageMin=math.huge,damageMax=0};sample[key]=row
   row.hpMin=math.min(row.hpMin,hp);row.hpMax=math.max(row.hpMax,hp)
   row.damageMin=math.min(row.damageMin,damage);row.damageMax=math.max(row.damageMax,damage)
  end end
 end
 local preview=S.mission(chapter,mode,party,4)
 for key,row in pairs(sample)do for field,value in pairs(row)do check(preview[key][field]==value,'entry preview matches spawned '..field)end end
 local a,b=D.completion(chapter,mode,4),D.completion(chapter,mode,3)
 for key,value in pairs(a)do check(value==b[key],'completion rewards remain pinned')end
end end end
for epic=1,5 do check(count[epic]>0,'all five epics exercised')end
-- Same role/level/difficulty isolates epic growth from family and level growth.
for _,mode in ipairs(D.order)do for party=1,4 do for _,kind in ipairs({'Goblin','Warlord'})do
 local lastHP,lastDamage=0,0
 for epic=1,5 do
  local hp,damage=B.unitStats({kind=kind,level=20,epic=epic},party,mode,4,1)
  check(hp>lastHP and damage>lastDamage,'strict progression for equivalent role')
  lastHP,lastDamage=hp,damage
 end
end end end
local hp,damage=B.unitStats({kind='IceWolf',level=12,epic=2},1,'Easy',4,1)
check(hp==486 and damage==33,'Frozen Vale opening wolf has measurable extra threat')
local h,d=B.unitStats({kind='Imp',level=20,epic=3},1,'Easy',4,1)
check(h==893 and d==49,'Ember opening imp has measurable extra threat')
local localHP,localDamage=B.unitStats({kind='Imp',level=20,epic=3},1,nil,nil,1)
local oldHP,oldDamage=B.unitStats({kind='Imp',level=20,epic=3},1,nil,3,1)
check(localHP>oldHP and localDamage>oldDamage,'local adventure uses same regional scaling')
-- A persisted v3 journal rejoins without silently acquiring the new region boost.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local profile=assert(R.addHero(R.new(73),'hero','knight',Items))
profile.heroes.hero.progression=G.new(80);profile.heroes.hero.level=80
profile=assert(A.begin(profile,'hero','DW-01','Easy','saved-v3',profile.revision,R,Items,3))
check(R.validate(profile,Items),'persisted v3 profile still loads')
check(D.verifyRun(profile.heroes.hero,{id='saved-v3',missionId='DW-01',difficultyId='Easy',rulesVersion=3}),'v3 rejoin remains supported')
check(not D.verifyRun(profile.heroes.hero,{id='saved-v3',missionId='DW-01',difficultyId='Easy',rulesVersion=4}),'rejoin cannot silently upgrade')
profile=assert(A.begin(profile,'hero','DW-01','Easy','new-v4',profile.revision,R,Items))
check(profile.heroes.hero.expeditions.active.balanceVersion==4,'new regional run persists v4')
print('Epic monster progression: '..n..' checks passed')
