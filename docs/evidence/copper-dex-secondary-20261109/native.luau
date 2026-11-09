assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"isolated place only")
do
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local I=require(game.ReplicatedStorage.Shared.EquipmentImpact)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b,m)check(math.abs(a-b)<1e-8,m)end
check(C.items.copper_ring.rarity=='Common'and C.items.copper_ring.level==1,'grade/level preserved')
check(C.items.copper_ring.stats.dexterity==3 and C.items.copper_ring.stats.power==nil,'ring has exactly DEX instead of attack')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=assert(R.addHero(R.new(42),'h',class,C));local ring=R.equipped(p,'h','accessory1');local before=R.copy(p)
 local equipped=R.stats(p,'h',C);local d=P.derived(class,p.heroes.h.progression,equipped);local base=G.derived(class,p.heroes.h.progression)
 near(d.totalStats.DEX,base.totalStats.DEX+3,'total DEX includes ring')
 near(d.attackRate,1.015,'ring raises basic attack rate by1.5 percent of base')
 near(d.moveRate,1.003,'ring raises movement by0.3 percent of base')
 near(d.physicalPower,base.physicalPower+5,'ring no longer supplies attack')
 local sp,kp=G.points(p.heroes.h.progression);check(sp==0 and kp==0 and G.validate(p.heroes.h.progression,class),'gear never spends or creates allocation points')
 check(p.heroes.h.progression.stats.DEX==0 and p.revision==before.revision,'derived calculations never save invested DEX')
 local bag=assert(R.apply(p,{action='Unequip',requestId='off',heroId='h',revision=p.revision,instanceId=ring.instanceId,itemVersion=ring.version},{safe=true},C))
 local unequipped=P.derived(class,bag.heroes.h.progression,R.stats(bag,'h',C))
 near(unequipped.attackRate,1,'bag ring has no speed bonus');near(unequipped.totalStats.DEX,base.totalStats.DEX,'bag ring has no DEX bonus')
 local list={};for _,item in pairs(bag.items)do table.insert(list,item)end
 local rows=assert(I.compare(bag.heroes.h,list,bag.items[ring.instanceId],nil,C))
 check(#rows==8 and rows[6].key=='dexterity','ring preview shows DEX and both speed changes')
 near(rows[1].delta,0,'ring preview adds no direct physical attack');near(rows[6].delta,3,'preview DEX matches actual')
 near(rows[7].delta,.015,'preview attack speed matches actual');near(rows[8].delta,.003,'preview movement matches actual')
 check(I.text(rows):find('Dexterity',1,true)and I.summary(rows):find('DEX +3',1,true),'ring changes are visible in bag/shop text')
 p.wallet.gold=100;assert(F.grant(p,R,C,'h','enhancement_gem',2,'gems'))
 local enhanced=assert(R.shop(p,{action='Enhance',store='blacksmith',requestId='dex-enhance',heroId='h',revision=p.revision,instanceId=ring.instanceId,itemVersion=ring.version,rulesVersion=E.version,expectedLevel=0},{atLobby=true,enhancementRoll=0},C))
 near(R.stats(enhanced,'h',C).dexterity,3.09,'authoritative DEX enhancement uses existing3 percent rate')
 near(enhanced.wallet.gold,50,'DEX enhancement retains50 Gold cost')
 check(R.validate(enhanced,C),'existing enhanced ring remains valid')
 near(E.stats(C.items.copper_ring,{enhancementLevel=9}).dexterity,3.81,'existing +9 follows new DEX definition')
 for _,investment in ipairs({199,200,299,300})do
  local g=G.new(80);g.stats.DEX=investment;local derived=G.derived(class,g,{dexterity=3.81})
  near(derived.attackRate,1+math.min(1,(investment+3.81)*.005),'DEX gear obeys attack speed cap')
  near(derived.moveRate,1+math.min(.3,(investment+3.81)*.001),'DEX gear obeys movement cap')
  check(G.validate(g,class),'gear never violates316-point budget')
 end
end
for tier,value in pairs({traveler=2,tempered=4,veteran=7,sentinel=15})do
 check(C.items[C.equipmentFamilies.piece(tier,'hands')].stats.power==value,'latest fixed glove value '..tier)
 check(C.items[C.equipmentFamilies.piece(tier,'feet')].stats.armor==value,'latest fixed boot value '..tier)
end
print('Copper DEX and secondary gear: '..n..' checks passed')

end
do
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local T=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local I=require(game.ReplicatedStorage.Shared.EquipmentImpact)
local Store=require(game.ServerScriptService.Server.Inventory.AccountStore)
local Economy=require(game.ReplicatedStorage.Shared.EconomyCatalog)
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
 local secondary=({traveler=2,tempered=4,veteran=7,sentinel=15})[d.family]
 local amount=(d.slot=='hands'or d.slot=='feet')and secondary or d.slot=='body' and v[5]or (d.slot=='weapon'or d.slot=='offhand')and v[4]or v[3]
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
check(C.items.copper_ring.stats.dexterity==3 and not C.items.copper_ring.stats.power,'Copper Ring DEX +3 only')
check(C.items.amber_charm.stats.health==30 and C.items.amber_charm.rarity=='Uncommon','HP charm preserved')
check(C.items.amber_mana_charm.stats.mana==30 and C.items.amber_mana_charm.level==1 and C.items.amber_mana_charm.rarity=='Uncommon','new MP charm')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=assert(R.addHero(R.new(42),'h',class,C));local stats=R.stats(p,'h',C)
 check(R.equipped(p,'h','weapon').definitionId==class..'_weapon_traveler','starter uses Traveler '..class)
 check(R.equipped(p,'h','body').definitionId==(class=='mage'and 'mage_traveler_coat'or 'traveler_coat'),'starter body follows class')
 check(R.quantity(p,'h','veteran_hood')==1,'future veteran hood preserved in bag')
 check(stats.power==5 and stats.dexterity==3 and stats.armor==(class=='knight'and 8 or 5),'starter fixed attack and defense')
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

end
do
-- End-to-end starter loadout: server equip reducer -> current definitions -> UI totals.
local R=game and require(game.ServerScriptService.Server.Inventory.InventoryRules) or require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=game and require(game.ReplicatedStorage.Shared.ItemCatalog) or require(game.ReplicatedStorage.Shared.ItemCatalog)
local G=game and require(game.ReplicatedStorage.Shared.HeroProgression) or require(game.ReplicatedStorage.Shared.HeroProgression)
local F=game and require(game.ReplicatedStorage.Shared.EquipmentTransactions) or require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local P=game and require(game.ReplicatedStorage.Shared.SkillStatPreview) or require(game.ReplicatedStorage.Shared.SkillStatPreview)
local n=0
local function eq(a,b,label)n=n+1;assert(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local p=assert(R.addHero(R.new(42),'hero',class,C))
 local ids={class..'_weapon_traveler','traveler_hood',(class=='mage'and 'mage_traveler_coat'or 'traveler_coat'),'traveler_gloves','traveler_boots','copper_ring','amber_charm'}
 for _,id in ipairs(ids)do
  local count=0
  for _,item in pairs(p.items)do if item.definitionId==id then
   count=count+1;eq(item.location.kind,'equipped',class..' starts wearing '..id)
  end end
  eq(count,1,class..' receives exactly one '..id)
 end
 eq(R.equipped(p,'hero','weapon').definitionId,class..'_weapon_traveler',class..' starts with real weapon')
 eq(C.items[class..'_weapon_traveler'].rarity,'Common',class..' starter is Common')
 eq(C.items[class..'_weapon_traveler'].stats.power,3,class..' starter weapon power')
 eq(R.equipped(p,'hero','head').definitionId,'traveler_hood',class..' wears level1 hood')
 eq(R.equipped(p,'hero','accessory1').definitionId,'copper_ring',class..' auto accessory1')
 eq(R.equipped(p,'hero','accessory2').definitionId,'amber_charm',class..' auto accessory2')
 eq(R.quantity(p,'hero','veteran_hood'),1,class..' level5 bonus stays in bag')
 for _,item in pairs(p.items)do eq(item.definitionId==class..'_weapon',false,class..' no training weapon') end
 eq(R.count(p,'equipped'),class=='knight' and 8 or 7,class..' all eligible slots filled')
 eq(R.validate(p,C),true,class..' creation is valid')
 eq(F.grant(p,R,C,'hero',class..'_weapon',1,'retired-test'),false,class..' retired training weapon cannot be granted')
 eq(R.quantity(p,'hero',class..'_weapon'),0,class..' retired grant adds no training weapon')
 local stats=R.stats(p,'hero',C)
 eq(stats.power,5,class..' starter power');eq(stats.health,class=='mage'and 30 or 50,class..' starter HP');eq(stats.mana,class=='mage'and 20 or 0,class..' starter MP');eq(stats.armor,class=='knight'and 8 or 5,class..' starter defense')
 local base=G.derived(class,p.heroes.hero.progression)
 local total=P.derived(class,p.heroes.hero.progression,stats)
 eq(total.health,base.health+stats.health,class..' UI HP follows equipped server stats')
 eq(total.physicalPower,base.physicalPower+5,class..' physical power adds5 points')
 eq(total.magicPower,base.magicPower+5,class..' magic power adds5 points')
 -- Saved instances contain identity/enhancement, not a frozen copy of old bonuses.
 local restored=R.copy(p)
 for _,item in pairs(restored.items)do item.definitionVersion=1 end
 eq(R.validate(restored,C),true,class..' existing instance schema remains valid')
 local loaded=R.stats(restored,'hero',C)
 eq(loaded.power,stats.power,class..' saved equipment follows current power')
 eq(loaded.health,stats.health,class..' saved equipment follows current HP')
 eq(loaded.armor,stats.armor,class..' saved equipment follows current armor')
 eq(R.quantity(restored,'hero','health_potion'),3,class..' potion stock preserved')
end
eq(C.items.veteran_hood.stats.armor,10,'bonus Veteran hood follows new tier')
print('Starter gear balance: '..n..' checks passed')

end
do
local I=require(game.ReplicatedStorage.Shared.EquipmentImpact)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=R.addHero(R.new(2),class,class,C);local h=p.heroes[class];local list={}
 for _,item in pairs(p.items)do table.insert(list,item)end
 local same=assert(I.compare(h,list,{definitionId=class..'_weapon_traveler',location={kind='bag'}},nil,C))
 check(same[1].delta==0 and same[2].delta==0,'starter Traveler weapon is already equipped and does not count twice')
 local selected={definitionId=class..'_weapon_veteran',location={kind='bag'}}
 local rows=assert(I.compare(h,list,selected,nil,C));local base=G.derived(class,h.progression)
 check(#rows==5,'comparison always shows both attacks, defense, HP and MP')
 check(math.abs(rows[1].delta-7)<.00001,'physical attack gains seven fixed power points')
 check(math.abs(rows[2].delta-7)<.00001,'magic attack gains seven fixed power points')
 check(rows[3].delta==0 and rows[4].delta==0 and rows[5].delta==0,'weapon comparison does not invent defense, HP or MP')
 local original=R.copy(p)
 local current=assert(R.equipped(p,class,'weapon'));current.definitionId=class..'_weapon_veteran'
 local upgraded=assert(I.compare(h,list,selected,nil,C));check(upgraded[1].delta==0,'already equipped item never counts twice')
 local downgrade=assert(I.compare(h,list,{definitionId=class..'_weapon'},nil,C));check(downgrade[1].delta<0,'downgrade shows negative actual attack')
 local before=p.revision;local hp=assert(I.compare(h,list,{definitionId=class=='mage'and 'mage_traveler_coat'or 'traveler_coat'},nil,C))
 check(hp[3].delta==0 and hp[4].delta==0 and hp[5].delta==0,'starter coat is already equipped and does not count twice')
 local emptyBody={};for _,item in ipairs(list)do if not (item.location.kind=='equipped' and item.location.slot=='body') then table.insert(emptyBody,item) end end
 local added=assert(I.compare(h,emptyBody,{definitionId=class=='mage'and 'mage_traveler_coat'or 'traveler_coat'},nil,C))
 check(added[3].delta==0 and added[4].delta==(class=='mage'and 0 or 20) and added[5].delta==(class=='mage'and 20 or 0),'empty body slot gains only its class resource')
 check(p.revision==before and p.heroes[class].progression.stats.VIT==original.heroes[class].progression.stats.VIT,'read-only preview never saves, heals or allocates stats')
 local accessory=I.compare(h,list,{definitionId='copper_ring'},nil,C);check(accessory and accessory[1].delta==0,'starter ring automatically replaces its own unique group without double counting')
 local other=class=='mage' and 'knight' or 'mage'
 check(not I.compare(h,list,{definitionId=other..'_weapon_fine'},nil,C),'incompatible gear cannot imply an applicable stat increase')
 check(I.text(rows):find('Max MP',1,true)~=nil,'comparison explicitly labels max MP even at zero')
end
print('Equipment impact: '..checks..' checks passed')

end
do
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b)return math.abs(a-b)<1e-8 end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 for _,level in ipairs({1,5,40,80})do
  local growth=G.new(level)
  local base=P.derived(class,growth,{})
  local d=P.derived(class,growth,{power=6,armor=4,health=20})
  check(near(d.physicalPower-base.physicalPower,6),'flat physical at every level')
  check(near(d.magicPower-base.magicPower,6),'flat magic at every level')
  check(d.armor-base.armor==4 and d.health-base.health==20,'other flat bonuses preserved')
 end
 local profile=assert(R.addHero(R.new(42),'hero',class,C))
 local stats=R.stats(profile,'hero',C)
 local derived=P.derived(class,profile.heroes.hero.progression,stats)
 local base=P.derived(class,profile.heroes.hero.progression,{})
 check(near(derived.physicalPower-base.physicalPower,stats.power),'actual starter aggregation adds points')
end
for _,def in pairs(C.items)do
 if def.slot and not def.deleted and (def.stats.power or 0)>0 then
  check(def.rarity=='Common'or def.rarity=='Uncommon'or def.rarity=='Rare','all current attack gear uses flat contract')
  check(near(E.stats(def,{enhancementLevel=9}).power,def.stats.power*1.27),'enhancement increases flat base by 27 percent')
 end
end
for _,id in ipairs(C.deletedEquipment)do check(next(E.stats(C.items[id],{enhancementLevel=9}))==nil,'deleted gear adds no combat effects')end
print('Flat equipment power: '..n..' checks passed')

end
do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local Store=require(game.ServerScriptService.Server.Inventory.AccountStore)
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
check(#C.deletedEquipment==18,'four Training weapons plus seven Rare/Epic families')
for _,id in ipairs(C.deletedEquipment)do
 local def=C.items[id]
 local p=assert(R.addHero(R.new(42),'hero',def.classId or 'knight',C))
 p.heroes.hero.level=10;p.heroes.hero.progression=require(game.ReplicatedStorage.Shared.HeroProgression).new(10)
 p.wallet.gold=987;p.wallet.diamonds=76
 local slot=def.slot=='accessory'and 'accessory1'or def.slot
 local locations={{kind='bag',heroId='hero'},{kind='storage'},{kind='pending'},{kind='equipped',heroId='hero',slot=slot}}
 for key,item in pairs(p.items)do if item.location.kind=='equipped'and item.location.slot==slot then p.items[key]=nil end end
 for i,loc in ipairs(locations)do
  local key='legacy-'..i
  p.items[key]={instanceId=key,definitionId=id,definitionVersion=C.version,ownerUserId=42,quantity=1,version=1,
   binding='account',locked=true,location=loc,sourceGrantId='legacy',enhancementLevel=next(def.stats) and 9 or nil}
 end
 check(R.validate(p,C),'legacy enhanced copies validate before cleanup '..id)
 local expected=R.copy(p)
 for key,item in pairs(expected.items)do if item.definitionId==id then expected.items[key]=nil end end
 expected.revision=expected.revision+1
 local cleaned=R.upgrade(R.copy(p),C)
 check(equal(cleaned,expected),'only requested equipment removed in every location '..id)
 check(R.validate(cleaned,C),'cleaned profile validates '..id)
 check(equal(R.upgrade(R.copy(cleaned),C),cleaned),'idempotent cleanup '..id)
 check(not F.grant(cleaned,R,C,'hero',id,1,'new-grant'),'deleted item cannot be granted '..id)
 local saved=R.copy(p);local lose=true
 local adapter={UpdateAsync=function(_,_,fn)
  fn(R.copy(saved));local value=fn(R.copy(saved));if value then saved=R.copy(value)end
  if lose then error('reply lost after commit')end;return value
 end}
 local store=Store.new(adapter,R,C,function()return 100 end,function()end,'deletion-session')
 local value,why=store:open(42)
 check(not value and why=='SaveUnknown','lost response never opens empty account '..id)
 check(equal(saved.items,expected.items)and saved.wallet.gold==987 and saved.wallet.diamonds==76,'committed cleanup preserves other property '..id)
 lose=false;value=assert(store:open(42))
 check(equal(value.items,expected.items)and value.revision==expected.revision,'retry does not resurrect items '..id)
 assert(store:close(42));value=assert(store:open(42))
 check(equal(value.items,expected.items),'reconnect persists deletion '..id)
end
for _,id in ipairs({'sentinel_shield','sentinel_helm','sentinel_mail','sentinel_boots','guardian_charm','knight_weapon_veteran','copper_ring','traveler_gloves'})do
 check(not C.items[id].deleted,'unrequested equipment preserved '..id)
end
print('Deleted equipment: '..n..' checks passed')

end
do
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated place only')
local RS=game:GetService('ReplicatedStorage')
local G=require(RS.Shared.HeroProgression);local K=require(RS.Shared.K0Config)
local source=game.ServerScriptService.Server.Combat.CombatService
local private=Instance.new('ModuleScript');private.Parent=source.Parent
private.Source=source.Source:gsub('\nreturn CombatService%s*$', '\nreturn {refresh=CombatService.refreshEquipment,attack=startAttack,states=playerStates,resolver=function(fn)contextResolver=fn end}')
local api=require(private);local n=0
local function near(a,b,m)n+=1;assert(math.abs(a-b)<1e-7,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local model=Instance.new('Model');model.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=model
 local hum=Instance.new('Humanoid');hum.Parent=model;hum.MaxHealth=500;hum.Health=10
 local player={Character=model};local growth=G.new();local base=G.derived(class,growth)
 local state={player=player,character=model,humanoid=hum,root=root,baseClassId=class,growth=growth,derived=base,
  mana=base.mana>0 and 10 or nil,maxMana=base.mana,mode='Idle',skillSlots={1,2,3,0,0},skillReadyAt={},slotCount=3,
  attackProfile=K.BasicAttackProfiles[class],combo=0,lastAttackFinished=-math.huge,attackSeq=0,feedbackSeq=0}
 api.states[player]=state
 api.resolver(function()return {heroId='h',baseClassId=class,epoch=1,characterGeneration=1,growth=growth,skillSlots={1,2,3,0,0}}end)
 local gear={power=0,armor=0,health=0,mana=0,dexterity=3,weapon=false,offhand=false}
 api.refresh(player,gear)
 near(state.derived.totalStats.DEX,base.totalStats.DEX+3,'actual server total DEX')
 near(state.derived.attackRate,1.015,'actual server attack rate');near(hum.WalkSpeed,K.WalkSpeed*1.003,'native Humanoid speed includes ring')
 near(hum.Health,10,'DEX swap does not heal HP')
 if state.mana then near(state.mana,10,'DEX swap does not restore MP')end
 api.attack(state,10)
 near(state.attack.definition.windup,K.BasicAttackProfiles[class].attacks[1].windup/1.015,'actual attack timing uses gear DEX')
 near(model:GetAttribute('K0BasicAttackRate'),1.015,'replicated attack rate includes ring')
 state.attack=nil;state.mode='Idle';gear.dexterity=0;api.refresh(player,gear)
 near(state.derived.attackRate,1,'ring removal restores rate');near(hum.WalkSpeed,K.WalkSpeed,'ring removal restores native speed')
 api.states[player]=nil;model:Destroy()
end
private:Destroy()
for _,name in ipairs({'ArmoryView','EnhancementView','InventoryGui','CombatStatsView','HeroStatsView','MobileHeroStatsView'})do
 assert(type(require(game.StarterPlayer.StarterPlayerScripts.Client[name]))=='table','changed UI loads '..name);n+=1
end
print('COPPER_DEX_NATIVE PASS '..n..' checks; synthetic identities/native timing and Humanoid, no live input or device acceptance')

end
