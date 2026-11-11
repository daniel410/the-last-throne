local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local T=dofile('src/shared/EquipmentTransactions.luau')
local G=dofile('src/shared/HeroProgression.luau')
local E=dofile('src/shared/EconomyCatalog.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local I=dofile('src/shared/EquipmentImpact.luau')
local checks=0
local function near(a,b,m)checks=checks+1;assert(math.abs(a-b)<1e-8,m)end
local function check(v,m)checks=checks+1;assert(v,m)end
for _,tier in ipairs(C.equipmentFamilies.tiers)do
 local id=C.equipmentFamilies.mageHat(tier.id)
 local hatMana=({traveler=10,tempered=20,veteran=30,sentinel=60})[tier.id]
 local p=assert(R.addHero(R.new(42),'mage','mage',C))
 p=assert(R.addHero(p,'knight','knight',C))
 p.heroes.mage.level=10;p.heroes.mage.progression=G.new(10)
 p.heroes.knight.level=10;p.heroes.knight.progression=G.new(10)
 if tier.id=='traveler'then
  check(R.equipped(p,'mage','head').definitionId==id,'new mage wears Traveler hat immediately')
  check(R.quantity(p,'mage','veteran_hood')==1,'existing Veteran bonus contract preserved')
  check(not E.offer(id),'Traveler hat is starter equipment, not a new paid SKU')
 end
 assert(T.grant(p,R,C,'mage',id,1,'hat'))
 local item=p.items['hat-1']
 local rejected=R.copy(p);rejected.items[item.instanceId].location={kind='bag',heroId='knight'}
 local bad,why=R.apply(rejected,{action='Equip',requestId='wrong',heroId='knight',revision=p.revision,instanceId=item.instanceId,itemVersion=item.version},{safe=true},C)
 check(not bad and why=='WrongClass','server rejects non-Mage hat use '..id)
 local worn=assert(R.apply(p,{action='Equip',requestId='wear',heroId='mage',revision=p.revision,instanceId=item.instanceId,itemVersion=item.version},{safe=true},C))
 check(R.equipped(worn,'mage','head').definitionId==id and R.validate(worn,C),'hat equips in existing head slot '..id)
 local retry=assert(R.apply(worn,{action='Equip',requestId='wear',heroId='mage',revision=p.revision,instanceId=item.instanceId,itemVersion=item.version},{safe=true},C))
 check(retry.revision==worn.revision,'equip retry does not duplicate hat '..id)
 check(R.stats(worn,'mage',C).armor==2,'hat replaces head armor '..id)
 check(R.stats(worn,'mage',C).mana==20+hatMana,'hat contributes maximum MP '..id)
 local g=worn.heroes.mage.progression
 local savedINT=g.stats.INT
 for _,level in ipairs({0,1,9})do
  worn.items[item.instanceId].enhancementLevel=level
  worn.items[item.instanceId].stats={mana=99999,intelligence=99999}
  local stats=R.stats(worn,'mage',C)
  local amount=hatMana*(1+.03*level)
  near(stats.mana,20+amount,'server ignores instance claims and enhances MP '..id)
  local base=G.derived('mage',g)
  local derived=P.derived('mage',g,stats)
  near(derived.totalStats.INT,base.totalStats.INT,'hat does not increase INT '..id)
  near(derived.magicPower-base.magicPower,stats.power,'hat does not increase spell or basic attack power '..id)
  near(derived.mana-base.mana,stats.mana,'hat increases maximum MP '..id)
  near(derived.physicalPower-base.physicalPower,stats.power,'hat does not increase physical power '..id)
  check(g.stats.INT==savedINT,'gear does not spend or save allocated points '..id)
 end
 local list={};for _,entry in pairs(worn.items)do list[#list+1]=entry end
 local hood=R.copy(worn.items[item.instanceId]);hood.definitionId='traveler_hood';hood.enhancementLevel=0
 local rows=assert(I.compare(worn.heroes.mage,list,hood,'head',C))
 near(rows[2].delta,0,'unequip preview preserves magic power '..id)
 near(rows[5].delta,-hatMana*1.27,'unequip preview removes maximum MP '..id)
 check(I.text(rows):find('Max MP',1,true) and not I.text(rows):find('Intelligence',1,true),'comparison explains maximum MP '..id)
 local removed=R.copy(worn);removed.items[item.instanceId].location={kind='bag',heroId='mage'}
 check(R.stats(removed,'mage',C).mana==20,'bag hat contributes no MP '..id)
 removed.items[item.instanceId].location={kind='storage'}
 check(R.stats(removed,'mage',C).mana==20,'stored hat contributes no MP '..id)
 local loaded=R.upgrade(R.copy(worn),C)
 check(loaded.items[item.instanceId].enhancementLevel==9 and R.validate(loaded,C),'saved enhanced hat survives reload '..id)
 near(R.stats(loaded,'mage',C).mana,20+hatMana*1.27,'owned hat recalculates MP after load '..id)
end
for _,class in ipairs({'knight','dwarf','elf'})do
 local g=G.new(1);local d=P.derived(class,g,{mana=30})
 check(d.mana==0,'MP gear never creates an MP pool '..class)
end
-- Existing generic hoods and their owned enhancement/lock remain untouched on load.
local p=assert(R.addHero(R.new(42),'mage','mage',C))
local old=R.equipped(p,'mage','head')
old.definitionId='traveler_hood';old.enhancementLevel=7;old.locked=true
local loaded=R.upgrade(R.copy(p),C)
local saved=R.equipped(loaded,'mage','head')
check(saved.definitionId=='traveler_hood' and saved.enhancementLevel==7 and saved.locked,'old Mage hood ownership is preserved')
check(R.quantity(loaded,'mage','mage_traveler_hat')==0,'loading existing hero does not issue another starter hat')
check(R.validate(loaded,C),'old profile still validates')
print('Mage hats: '..checks..' checks passed')
