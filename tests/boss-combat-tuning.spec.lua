local D=dofile('src/shared/Difficulty.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local S=dofile('src/shared/EncounterSummary.luau')
local T=dofile('src/shared/BossCombatTuning.luau')
local n,bosses=0,{}
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b,m)check(math.abs(a-b)<1e-8,m)end
for _,chapter in ipairs(C.chapters)do for _,mode in ipairs(D.order)do for party=1,4 do
 local sample={}
 for _,goal in ipairs(chapter.goals)do
  for _,wave in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(wave)do
   local boss=B.isBoss(spec.kind)
   local hp,damage,level,elite=B.unitStats(spec,party,mode,7,index)
   local h,d,l,e=B.unitStats(spec,party,mode,6,index)
   check(hp==h and level==l and elite==e,'health/level/elite unchanged')
   if boss then
    bosses[spec.kind]=true
    check(damage>d and math.abs(damage-d*1.1)<=1.000001,'boss attacks up 10 percent with integer rounding')
   else check(damage==d,'ordinary enemy damage unchanged')end
   local tempo=B.tempo(spec.kind,7)
   near(tempo.attackSpeed,boss and 1.1 or 1,'only bosses gain attack speed')
   near(tempo.moveSpeed,boss and 1.1 or 1,'only bosses gain move speed')
   for version=1,6 do
    local old=B.tempo(spec.kind,version)
    check(old.damage==1 and old.attackSpeed==1 and old.moveSpeed==1,'saved rules retain boss power and tempo')
   end
   local xp,gold=B.rewards(spec,mode,7);local x,y=B.rewards(spec,mode,6)
   check(xp==x and gold==y,'kill rewards unchanged')
   local key=boss and 'boss'or 'normal'
   local row=sample[key]or {lo=math.huge,hi=0};sample[key]=row
   row.lo=math.min(row.lo,damage);row.hi=math.max(row.hi,damage)
  end end
 end
 local preview=S.mission(chapter,mode,party,7)
 for key,row in pairs(sample)do check(preview[key].damageMin==row.lo and preview[key].damageMax==row.hi,'preview matches spawned damage')end
 local a,b=D.completion(chapter,mode,7),D.completion(chapter,mode,6)
 for key,value in pairs(a)do check(value==b[key],'completion rewards unchanged')end
end end end
local profiles={}
for _,name in ipairs({'FrozenValeCombat','EmberCalderaCombat','LateEpicCombat'})do
 for kind,profile in pairs(dofile('src/shared/'..name..'.luau').profiles)do profiles[kind]=profile end
end
local config=dofile('src/shared/K0Config.luau')
local count=0
for kind in pairs(bosses)do
 count=count+1
 local profile=profiles[kind]or config.Enemy[kind]or config.Enemy.Orc
 local c={walkSpeed=profile.speed or 9,attacks={}}
 for _,a in ipairs(profile.attacks)do
  local copy={};for k,v in pairs(a)do copy[k]=v end;table.insert(c.attacks,copy)
 end
 local before=c.walkSpeed;T.apply(c,1.1,1.1)
 near(c.walkSpeed,before*1.1,'boss movement increases 10 percent')
 for i,a in ipairs(c.attacks)do
  local old=profile.attacks[i]
  check(a.windup==old.windup and a.active==old.active,'warning and hit window preserved')
  near((old.windup+old.active+old.recovery)/(a.windup+a.active+a.recovery),1.1,'base attack cycle frequency up 10 percent')
  check(a.recovery>=0,'recovery remains valid')
 end
 local h,d=B.unitStats({kind=kind,level=30,epic=3},1,nil,6,1)
 local hp,damage=B.unitStats({kind=kind,level=30,epic=3},1,nil,7,1)
 check(h==hp and math.abs(damage-d*1.1)<=1.000001,'local boss damage boosted once')
end
check(count>0,'spawned bosses exercised')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local p=assert(R.addHero(R.new(75),'hero','knight',Items))
p=assert(A.begin(p,'hero','DW-01','Easy','v6',p.revision,R,Items,6))
check(R.validate(p,Items),'v6 profile still loads')
check(D.verifyRun(p.heroes.hero,{id='v6',missionId='DW-01',difficultyId='Easy',rulesVersion=6}),'v6 run rejoins')
check(not D.verifyRun(p.heroes.hero,{id='v6',missionId='DW-01',difficultyId='Easy',rulesVersion=7}),'rejoin cannot silently upgrade')
p=assert(A.begin(p,'hero','DW-01','Easy','v7',p.revision,R,Items))
check(p.heroes.hero.expeditions.active.balanceVersion==D.version,'new run pins current rules')
print('Boss combat tuning: '..n..' checks passed; '..count..' boss kinds')
