local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local T=dofile('src/shared/EquipmentTransactions.luau')
local G=dofile('src/shared/HeroProgression.luau')
local E=dofile('src/shared/EconomyCatalog.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
for _,tier in ipairs(C.equipmentFamilies.tiers)do
 local id=C.equipmentFamilies.mageHat(tier.id)
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
 check(R.stats(worn,'mage',C).armor==tier.low+2,'hat contributes existing family armor '..id)
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
