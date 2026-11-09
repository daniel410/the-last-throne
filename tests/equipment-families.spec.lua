local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local E=dofile('src/shared/Enhancement.luau')
local T=dofile('src/shared/EquipmentTransactions.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local G=dofile('src/shared/HeroProgression.luau')
local I=dofile('src/shared/EquipmentImpact.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local Economy=dofile('src/shared/EconomyCatalog.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b,m)check(math.abs(a-b)<1e-7,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local F=C.equipmentFamilies
local expected={traveler={1,'Common',3,3,20},tempered={1,'Common',5,5,30},veteran={10,'Uncommon',10,10,40},sentinel={10,'Rare',20,20,50}}
check(#C.tierEquipment==40,'four complete families, ten definitions each')
for _,id in ipairs(C.tierEquipment)do
 local d=C.items[id];local v=expected[d.family];local count=0;for _ in pairs(d.stats)do count=count+1 end
 check(count==1,'single fixed option '..id);check(not d.retired and not d.deleted,'current gear active '..id)
 check(d.level==v[1] and d.rarity==v[2],'level/grade '..id)
 local key=d.slot=='weapon' and 'power'or d.slot=='body' and (d.classId=='mage' and 'mana'or 'health')or d.slot=='hands' and 'power'or 'armor'
 local amount=d.slot=='body' and v[5]or (d.slot=='weapon'or d.slot=='offhand')and v[4]or v[3]
 check(d.stats[key]==amount,'fixed bonus '..id)
 near(E.stats(d,{enhancementLevel=9})[key],amount*1.27,'all four stat types enhance at3 percent')
 local p=assert(R.addHero(R.new(42),'h',d.classId or 'knight',C));p.wallet.gold=10000;p.wallet.diamonds=10000
 local offer=Economy.offer(d.rarity=='Rare' and id..'_diamond'or id)
 check(offer~=nil,'current family gear has acquisition route '..id)
 local bought=assert(R.shop(p,{store='blacksmith',action='Buy',requestId='buy',heroId='h',revision=p.revision,offerId=offer.id},{atLobby=true},C))
 check(bought.items['shop-buy'].definitionId==id,'shop grants exact family '..id)
 local cmd={action='Equip',requestId='wear',heroId='h',revision=bought.revision,instanceId='shop-buy',itemVersion=1}
 local worn,err=R.apply(bought,cmd,{safe=true},C)
 if d.level>1 then
  check(not worn and err=='LevelRequired','low level cannot equip '..id)
  bought.heroes.h.level=d.level;bought.heroes.h.progression=G.new(d.level)
  worn=assert(R.apply(bought,cmd,{safe=true},C))
 end
 check(R.validate(worn,C)and worn.items['shop-buy'].location.kind=='equipped','valid equipped family '..id)
end
check(C.items.copper_ring.stats.power==3,'Copper Ring latest +3')
check(C.items.amber_charm.stats.health==30 and C.items.amber_charm.rarity=='Uncommon','HP charm preserved')
check(C.items.amber_mana_charm.stats.mana==30 and C.items.amber_mana_charm.level==1 and C.items.amber_mana_charm.rarity=='Uncommon','new MP charm')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=assert(R.addHero(R.new(42),'h',class,C));local stats=R.stats(p,'h',C)
 check(R.equipped(p,'h','weapon').definitionId==class..'_weapon_traveler','starter uses Traveler '..class)
 check(R.equipped(p,'h','body').definitionId==(class=='mage'and 'mage_traveler_coat'or 'traveler_coat'),'starter body follows class')
 check(R.quantity(p,'h','veteran_hood')==1,'future veteran hood preserved in bag')
 check(stats.power==9 and stats.armor==(class=='knight'and 9 or 6),'starter fixed attack and defense')
 check(stats.health==(class=='mage'and 30 or 50)and stats.mana==(class=='mage'and 20 or 0),'starter HP/MP classification')
 assert(T.grant(p,R,C,'h','amber_mana_charm',1,'mana'))
 local charm=p.items['mana-1'];local cmd={action='Equip',requestId='charm',heroId='h',revision=p.revision,instanceId=charm.instanceId,itemVersion=1}
 local worn=assert(R.apply(p,cmd,{safe=true},C));check(R.validate(worn,C),'charm equippable')
 local before=P.derived(class,p.heroes.h.progression,R.stats(p,'h',C));local after=P.derived(class,p.heroes.h.progression,R.stats(worn,'h',C))
 near(after.mana-before.mana,class=='mage'and 30 or 0,'MP charm never creates a mana pool')
 local list={};for _,item in pairs(p.items)do table.insert(list,item)end
 local rows=assert(I.compare(p.heroes.h,list,charm,nil,C));near(rows[5].delta,class=='mage'and 30 or 0,'comparison matches MP resource availability')
 near(E.stats(C.items.amber_mana_charm,{enhancementLevel=9}).mana,38.1,'mana charm +9')
 worn.wallet.gold=100
 assert(T.grant(worn,R,C,'h','enhancement_gem',2,'gems'))
 local enhanced=assert(R.shop(worn,{action='Enhance',store='blacksmith',requestId='mp-enhance',heroId='h',revision=worn.revision,instanceId=charm.instanceId,itemVersion=worn.items[charm.instanceId].version,rulesVersion=E.version,expectedLevel=0},{atLobby=true,enhancementRoll=0},C))
 near(R.stats(enhanced,'h',C).mana,(class=='mage'and 20 or 0)+30.9,'authoritative enhancement aggregates MP')
 check(enhanced.wallet.gold==50 and enhanced.items[charm.instanceId].enhancementLevel==1,'MP enhancement costs50 Gold once')
 -- Actual 0.89.4 save shape: old starter fine, old Mage coat and worn Lv5 hood.
 local old=R.copy(p);old.items['mana-1']=nil;old.equipmentRulesVersion=nil
 old.heroes.h.level=5;old.heroes.h.progression=G.new(5)
 local weapon=R.equipped(old,'h','weapon');weapon.definitionId=class..'_weapon_fine';weapon.enhancementLevel=9;weapon.locked=true
 local coat=R.equipped(old,'h','body');coat.definitionId='traveler_coat'
 local head=R.equipped(old,'h','head');head.location={kind='storage'}
 local hood
 for _,item in pairs(old.items)do if item.definitionId=='veteran_hood'then hood=item;item.location={kind='equipped',heroId='h',slot='head'};item.locked=true end end
 check(R.validate(old,C),'old Lv5 profile decodes before migration')
 local oldStats=R.copy(old);local db=R.copy(old);local fail=true
 local adapter={UpdateAsync=function(_,_,fn)fn(R.copy(db));local value=fn(R.copy(db));if value then db=R.copy(value)end;if fail then error('response lost')end;return value end}
 local store=Store.new(adapter,R,C,function()return 100 end,function()end,'tier-session')
 local opened,why=store:open(42);check(not opened and why=='SaveUnknown','lost response never opens blank profile')
 check(db.items[weapon.instanceId].definitionId==class..'_weapon_traveler','starter migration commits under account lease')
 check(db.items[weapon.instanceId].enhancementLevel==9 and db.items[weapon.instanceId].locked,'enhancement and lock preserved')
 check(db.items[hood.instanceId].location.kind=='bag','underlevel worn Veteran returned to bag')
 check(db.items[coat.instanceId].definitionId==(class=='mage'and 'mage_traveler_coat'or 'traveler_coat'),'old starter coat migrates for mage')
 check(equal(db.wallet,oldStats.wallet)and equal(db.operations,oldStats.operations),'wallet and receipts preserved')
 fail=false;opened=assert(store:open(42));local snap=R.copy(opened);check(equal(R.upgrade(R.copy(opened),C),snap),'migration idempotent')
 assert(store:close(42));opened=assert(store:open(42));check(equal(opened.items,snap.items),'reconnect never duplicates or reverts gear')
 -- Full bag returns ineligible worn gear to pending; no destruction or over-capacity.
 local full=R.copy(old)
 for i=1,C.bagCapacity-R.count(full,'bag','h')do
  local item=R.copy(full.items[hood.instanceId]);item.instanceId='fill-'..i;item.location={kind='bag',heroId='h'};full.items[item.instanceId]=item
 end
 check(R.validate(full,C),'full legacy bag valid')
 local migrated=R.upgrade(full,C)
 check(R.validate(migrated,C)and migrated.items[hood.instanceId].location.kind=='pending','full bag uses unclaimed safely')
end
for oldId,slot in pairs(F.legacy)do
 local p=assert(R.addHero(R.new(42),'h','knight',C));p.equipmentRulesVersion=nil;p.heroes.h.level=10;p.heroes.h.progression=G.new(10)
 local current=R.equipped(p,'h',slot);if current then current.location={kind='storage'}end
 p.items.legacy={instanceId='legacy',definitionId=oldId,definitionVersion=C.version,ownerUserId=42,quantity=1,version=1,binding='account',locked=true,location={kind='equipped',heroId='h',slot=slot},sourceGrantId='old',enhancementLevel=9}
 check(R.validate(p,C),'old Sentinel valid at10')
 local updated=R.upgrade(p,C);local item=updated.items.legacy
 check(R.validate(updated,C)and item.definitionId==F.piece('sentinel',slot)and item.location.kind=='equipped'and item.enhancementLevel==9,'Lv10 Sentinel migration preserves eligible equipped instance')
end
for _,id in ipairs(C.deletedEquipment)do check(C.items[id].deleted and C.items[id].retired,'deleted training/old goods never resurrected')end
print('Equipment families: '..n..' checks passed')
