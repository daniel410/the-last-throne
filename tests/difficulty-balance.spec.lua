local D=dofile('src/shared/Difficulty.luau');local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local S=dofile('src/shared/EncounterSummary.luau');local C=dofile('src/shared/CampaignContent.luau')
local A=dofile('src/shared/AdventureRules.luau');local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=dofile('src/shared/ItemCatalog.luau');local G=dofile('src/shared/HeroProgression.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
for kind in pairs(D.families)do for _,level in ipairs({5,12,30})do
 local lastHP,lastDamage,lastLevel=0,0,0
 for _,mode in ipairs(D.order)do
  local hp,damage,effective=D.stats(kind,level,1,B.isBoss(kind),mode)
  check(hp>lastHP and damage>=lastDamage and effective>=lastLevel,'mode progression for '..kind)
  lastHP,lastDamage,lastLevel=hp,damage,effective
  for players=1,4 do
   local groupHP,groupDamage,groupLevel=D.stats(kind,level,players,B.isBoss(kind),mode)
   check(groupHP>=hp and groupDamage>=damage and groupLevel==effective,'party increases HP and damage')
  end
 end
end end
for _,row in ipairs({{'Orc',450,924},{'Ogre',600,1134}})do
 check(D.stats(row[1],9,1,false,'Easy',2)==row[2],'approved Easy Lv9 solo HP for '..row[1])
 check(D.stats(row[1],9,1,false,'Hard',2)==row[3],'Hard HP unchanged for '..row[1])
 check(D.stats(row[1],9,4,false,'Easy',2)==row[2]*2.5,'Easy party scaling retained for '..row[1])
 check(D.stats(row[1],9,1,false,'Easy',1)==325,'legacy Easy rules retained for '..row[1])
end
local hp,damage,level=D.stats('Goblin',5,1,false,'Hell',5)
check(hp==3465 and damage==203 and level==80,'reference Hell guard')
local hp2,damage2,level2=D.stats('Goblin',12,1,false,'Hell')
check(level2==87 and hp2>hp and damage2>damage,'later mission retains level progression inside Hell')
local oldHP,oldDamage,oldLevel=D.stats('Goblin',5,1,false,'Hell',1)
check(oldHP==4410 and oldDamage==149 and oldLevel==80,'old run keeps original combat rules')
check(D.stats('Ogre',12,1,false,'Easy')>D.stats('Goblin',12,1,false,'Easy'),'ogre tank distinct from guard')
check(D.stats('Shaman',12,1,false,'Easy')<D.stats('Goblin',12,1,false,'Easy'),'caster health distinct from guard')
for _,mode in ipairs(D.order)do for _,boss in ipairs({false,true})do
 local kind=boss and 'Warlord'or 'Goblin'
 local specs=B.expand({{kind=kind,level=5,count=1}})
 local xp,gold=0,0;local oldXP,oldGold=0,0
 for _,s in ipairs(specs)do local x,y=B.rewards(s,mode);xp=xp+x;gold=gold+y;local a,b=B.rewards(s,mode,1);oldXP=oldXP+a;oldGold=oldGold+b end
 check(xp==math.floor(18*(boss and 5 or 1)*D.modes[mode].xp),'scaled XP whole budget survives six-copy split')
 check(gold==math.floor(5*(boss and 10 or 1)*D.goldMultiplier(5,mode)),'scaled Gold whole budget survives six-copy split')
 check(oldXP==18*(boss and 5 or 1)and oldGold==5*(boss and 10 or 1),'legacy rewards remain unscaled')
end end
for _,c in ipairs(C.chapters)do for _,mode in ipairs(D.order)do
 local solo=S.mission(c,mode,1);local party=S.mission(c,mode,4)
 check(solo.xp==party.xp and solo.gold==party.gold and solo.count<=party.count,'party preserves personal reward amount')
 check(party.health>=solo.health,'preview includes party health scaling')
 if solo.normal then check(solo.normal.levelMin>=D.modes[mode].level,'normal level floor shown')end
 if solo.boss then check(solo.boss.levelMin>=D.modes[mode].level,'boss level floor shown')end
 local reward=D.completion(c,mode)
 check((reward.gems>0)==D.combat(c) and reward.ore==0,'noncombat cannot farm forge materials')
end end
local first=S.mission(C.byId['DW-01'],'Easy',1,5)
check(first.normal.hpMin==180 and first.normal.hpMax==250,'preview includes authored Slime replacement')
local hard=S.mission(C.byId['DW-01'],'Hard',1)
check(hard.xp==144 and hard.gold==61,'whole first mission scales kill budgets')
local hell=S.mission(C.byId['DW-01'],'Hell',1)
check(hell.xp==288 and hell.gold==242,'Hell kill XP/Gold actually increase')
local plain=D.stats('Goblin',5,1,false,'Hell');local elite=B.unitStats({kind='Goblin',level=5},1,'Hell',nil,1)
check(elite==math.floor(plain*1.15+.5),'armored elite applied once')
-- Persisted v1 checkpoints migrate by omission; new departures pin v2 separately
-- from the stable journal schema understood by previous account readers.
local p=assert(R.addHero(R.new(42),'hero','knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
local function finish(profile,id)
 for _,g in ipairs(C.byId['DW-01'].goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do profile=assert(A.event(profile,'hero','DW-01',g.id,step.choices and step.choices[1].id,step.id,R,Items,id))end
  else profile=assert(A.event(profile,'hero','DW-01',g.id,nil,nil,R,Items,id))end
 end end
 return profile
end
p=assert(A.begin(p,'hero','DW-01','Easy','first',p.revision,R,Items));p=finish(p,'first')
p.heroes.hero.expeditions.clears['DW-01']={Easy=true,Hard=true,Insane=true}
p=assert(A.begin(p,'hero','DW-01','Hell','old',p.revision,R,Items,1));p.heroes.hero.expeditions.active.balanceVersion=nil
check(R.validate(p,Items),'pre-upgrade journal with no balance version loads safely')
check(D.verifyRun(p.heroes.hero,{id='old',missionId='DW-01',difficultyId='Hell',rulesVersion=1}),'old manifest can rejoin upgraded destination')
local gold=p.wallet.gold;local cores=R.quantity(p,'hero','forge_core');p=finish(p,'old')
check(p.wallet.gold-gold==135 and R.quantity(p,'hero','forge_core')-cores==3,'v1 completion and materials remain pinned')
p=assert(A.begin(p,'hero','DW-01','Hell','new',p.revision,R,Items))
check(p.heroes.hero.expeditions.active.version==1 and p.heroes.hero.expeditions.active.balanceVersion==D.version,'schema stable; new run pins revised rules')
gold=p.wallet.gold;cores=R.quantity(p,'hero','magic_stone');p=finish(p,'new')
check(p.wallet.gold-gold==393 and R.quantity(p,'hero','magic_stone')-cores==10,'new completion and material schedule reaches real reducer')
local completed=assert(A.event(p,'hero','DW-01',C.byId['DW-01'].goals[#C.byId['DW-01'].goals].id,nil,nil,R,Items,'new'))
check(completed.wallet.gold==p.wallet.gold and R.quantity(completed,'hero','forge_core')==R.quantity(p,'hero','forge_core'),'retries cannot duplicate revised rewards')
check(not D.verifyRun(p.heroes.hero,{id='new',missionId='DW-01',difficultyId='Hell',rulesVersion=1}),'mismatched rules manifest rejected')
p.heroes.hero.expeditions.active.balanceVersion=99;check(not R.validate(p,Items),'unknown balance version fails closed')
print('Difficulty balance: '..n..' checks passed')
