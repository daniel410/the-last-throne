assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated test place only')
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
local expected={traveler={1,'Common',3,3,20},tempered={1,'Common',6,6,30},veteran={10,'Uncommon',15,15,50},sentinel={10,'Rare',30,30,80}}
check(#C.tierEquipment==40,'four complete families, ten definitions each')
for _,id in ipairs(C.tierEquipment)do
 local d=C.items[id];local v=expected[d.family];local count=0;for _ in pairs(d.stats)do count=count+1 end
 check(count==1,'single fixed option '..id);check(not d.retired and not d.deleted,'current gear active '..id)
 check(d.level==v[1] and d.rarity==v[2],'level/grade '..id)
 local key=d.slot=='weapon' and 'power'or d.slot=='body' and (d.classId=='mage' and 'mana'or 'health')or d.slot=='hands' and 'power'or 'armor'
 local secondary=({traveler=2,tempered=4,veteran=10,sentinel=20})[d.family]
 local amount=(d.slot=='hands'or d.slot=='feet')and secondary or d.slot=='body' and v[5]or (d.slot=='weapon'or d.slot=='offhand')and v[4]or v[3]
 check(d.stats[key]==amount,'fixed bonus '..id)
 near(E.stats(d,{enhancementLevel=9})[key],amount*1.27,'all four stat types enhance at3 percent')
 local p=assert(R.addHero(R.new(42),'h',d.classId or 'knight',C));p.wallet.gold=10000;p.wallet.diamonds=10000
 local offer=Economy.offer(d.rarity=='Rare' and id..'_diamond'or id)
 local bought,instanceId
 if d.family=='traveler'then
  check(offer==nil,'starter Traveler is not a shop product '..id)
  bought=p;assert(T.grant(bought,R,C,'h',id,1,'family-fixture'));instanceId='family-fixture-1'
 else
  check(offer~=nil,'upgraded family gear is purchasable '..id)
  bought=assert(R.shop(p,{store='blacksmith',action='Buy',requestId='buy',heroId='h',revision=p.revision,offerId=offer.id},{atLobby=true},C));instanceId='shop-buy'
 end
 check(bought.items[instanceId].definitionId==id,'acquisition preserves exact family '..id)
 local cmd={action='Equip',requestId='wear',heroId='h',revision=bought.revision,instanceId=instanceId,itemVersion=1}
 local worn,err=R.apply(bought,cmd,{safe=true},C)
 if d.level>1 then
  check(not worn and err=='LevelRequired','low level cannot equip '..id)
  bought.heroes.h.level=d.level;bought.heroes.h.progression=G.new(d.level)
  worn=assert(R.apply(bought,cmd,{safe=true},C))
 end
 check(R.validate(worn,C)and worn.items[instanceId].location.kind=='equipped','valid equipped family '..id)
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
 check(math.abs(rows[1].delta-12)<.00001,'physical attack gains twelve fixed power points')
 check(math.abs(rows[2].delta-12)<.00001,'magic attack gains twelve fixed power points')
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
for tier,value in pairs({traveler=2,tempered=4,veteran=10,sentinel=20})do
 check(C.items[C.equipmentFamilies.piece(tier,'hands')].stats.power==value,'latest fixed glove value '..tier)
 check(C.items[C.equipmentFamilies.piece(tier,'feet')].stats.armor==value,'latest fixed boot value '..tier)
end
print('Copper DEX and secondary gear: '..n..' checks passed')

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
eq(C.items.veteran_hood.stats.armor,15,'bonus Veteran hood follows new tier')
print('Starter gear balance: '..n..' checks passed')

end
do
-- Runs both in plain Lua and in an isolated Roblox Place built from the same source.
local function loadModule(path)
 if not game then return dofile(path)end
 local root,relative
 if path:sub(1,11)=='src/shared/'then root=game.ReplicatedStorage.Shared;relative=path:sub(12)
 else root=game.ServerScriptService.Server.Inventory;relative=path:match('([^/]+)$')end
 return require(root[relative:gsub('%.luau$','')])
end
if game then assert(#game.Players:GetPlayers()==0,'isolated test place only')end
local E=loadModule('src/shared/EquipmentEffects.luau')
local C=loadModule('src/shared/ItemCatalog.luau')
local R=loadModule('src/server/Inventory/InventoryRules.luau')
local P=loadModule('src/shared/SkillStatPreview.luau')
local G=loadModule('src/shared/HeroProgression.luau')
local I=loadModule('src/shared/EquipmentImpact.luau')
local H=loadModule('src/shared/Enhancement.luau')
local Config=loadModule('src/shared/K0Config.luau')
local n=0
local function check(value,message)n=n+1;assert(value,message)end
local function near(a,b)return math.abs(a-b)<1e-8 end
local function effect(id,value,skillId)return {id=id,value=value,skillId=skillId}end
for _,def in pairs(C.items)do check(E.validateDefinition(def),'existing catalog remains valid')end
local cases={
 {effect('physical_damage',.2),1.2,1,1.2,1},
 {effect('magic_damage',.2),1,1.2,1,1.2},
 {effect('basic_damage',.2),1.2,1.2,1,1},
 {effect('skill_damage',.2),1,1,1.2,1.2},
}
for _,row in ipairs(cases)do
 for index,context in ipairs({{false,false},{true,false},{false,true},{true,true}})do
  check(near(E.damageMultiplier({row[1]},context[1],context[2]),row[index+1]),'damage type / basic versus skill scope')
 end
end
check(near(E.damageMultiplier({effect('damage',.1),effect('physical_damage',.2),effect('skill_damage',.3)},false,true),1.6),'bonuses add, never multiply individually')
check(E.damageMultiplier({effect('damage',1),effect('physical_damage',1)},false,true)==2,'combined damage cap')
check(E.incomingMultiplier({effect('damage_reduction',.3),effect('damage_reduction',.3)})==.5,'reduction cap')
check(near(E.incomingMultiplier({effect('damage_reduction',.1)}),.9),'reduction applies to incoming damage only')
local target='knight.common.whirlwind'
check(E.damageMultiplier({effect('skill_damage',.15,target)},false,true,target)==1.15,'targeted skill applies')
check(E.damageMultiplier({effect('skill_damage',.15,target)},false,true,'knight.common.bash')==1,'targeted skill excludes other skills')
for _,bad in ipairs({effect('unknown',.1),effect('damage',-1),effect('damage',0/0),effect('damage',math.huge),effect('damage',1.1),effect('skill_damage',.1,'missing'),effect('damage',.1,target)})do
 check(not E.validateDefinition({slot='weapon',specialEffects={bad}}),'malformed catalog effect rejected')
 check(E.damageMultiplier({bad},false,true)==1,'malformed effect cannot amplify damage')
end
check(not E.validateDefinition({specialEffects={effect('damage',.1)}}),'consumable effects rejected')
check(not E.validateDefinition({slot='weapon',specialEffects={effect('damage',.1),effect('damage',.2)}}),'duplicate item scope rejected')
check(not E.validateDefinition({slot='weapon',specialEffects={[2]=effect('damage',.1)}}),'sparse list rejected')
check(#E.fromDefinition({slot='weapon',deleted=true,specialEffects={effect('damage',1)}})==0,'deleted gear has no effects')
local profile=assert(R.addHero(R.new(88),'hero','knight',C))
local selected=R.equipped(profile,'hero','weapon')
local def=C.items[selected.definitionId];local saved=def.specialEffects
def.specialEffects={effect('skill_damage',.15,target)}
local stats=R.stats(profile,'hero',C)
check(#stats.specialEffects==1,'server collects equipped definition effects')
selected.specialEffects={effect('damage',1)}
check(E.damageMultiplier(R.stats(profile,'hero',C).specialEffects,false,true,'knight.common.bash')==1,'instance effect values are never trusted')
local baseStats={power=stats.power,armor=stats.armor,health=stats.health,mana=stats.mana,dexterity=stats.dexterity}
local growth=profile.heroes.hero.progression
local normal=P.value('knight',2,growth,baseStats)
local boosted=P.value('knight',2,growth,stats)
local power=P.derived('knight',growth,stats).physicalPower
check(boosted.damage==math.floor(power*boosted.skill.damage*1.15+.5)and boosted.damage>normal.damage,'skill preview includes effect before final rounding')
check(P.value('knight',1,growth,stats).damage==P.value('knight',1,growth,baseStats).damage,'other skill unchanged')
check(P.basicAttacks('knight',growth,stats)[1].before==P.basicAttacks('knight',growth,baseStats)[1].before,'skill effect excludes normal attacks')
local upgraded=H.stats(def,{enhancementLevel=9})
check(near(upgraded.power,3.81)and E.fromDefinition(def)[1].value==.15,'enhancement improves base stats, not effects')
check(E.text(def):find('WHIRLWIND damage +15%',1,true)~=nil,'skill-specific English label')
local items={};for _,item in pairs(profile.items)do items[#items+1]=item end
local replacement={definitionId='knight_weapon_fine',location={kind='bag'}}
local rows=assert(I.compare(profile.heroes.hero,items,replacement,nil,C))
check(rows.specialEffects:find('15% -> 0%',1,true)~=nil,'replacement shows lost effect')
check(I.text(rows):find('percentage points',1,true)~=nil,'effect units differ from attack points')
local same=assert(I.compare(profile.heroes.hero,items,selected,nil,C))
check(same.specialEffects:find('15% -> 15%',1,true)~=nil,'equipped preview never doubles effects')
selected.location.kind='bag'
check(#R.stats(profile,'hero',C).specialEffects==0,'bag gear has no effect')
selected.location.kind='storage'
check(#R.stats(profile,'hero',C).specialEffects==0,'storage gear has no effect')
selected.location.kind='equipped';selected.location.heroId='other'
check(#R.stats(profile,'hero',C).specialEffects==0,'other hero gear has no effect')
selected.location.heroId='hero';def.specialEffects=saved
check(#R.stats(profile,'hero',C).specialEffects==0,'removing definition effect leaves no stale bonus')
-- Every class uses the same server multiplier for preview, including branch/ultimate skills.
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local g=G.new(80);local bonuses={specialEffects={effect('damage',.2)}}
 for index,skill in ipairs(Config.Skills[class])do
  local value=P.value(class,index,g,bonuses)
  local d=P.derived(class,g,bonuses);local attack=skill.magic and d.magicPower or d.physicalPower
  check(value.damage==(value.skill.damage>0 and math.max(1,math.floor(attack*value.skill.damage*1.2+.5))or 0),'all class/branch skill damage matches shared multiplier')
 end
 local a,b=P.basicAttacks(class,g,{}),P.basicAttacks(class,g,bonuses)
 check(b[1].before>=a[1].before,'all class normal attacks support effects')
end
if game then
 local client=game.StarterPlayer.StarterPlayerScripts.Client
 for _,name in ipairs({'InventoryGui','ArmoryView','EnhancementView','HeroStatsView','CombatStatsView','MobileHeroStatsView'})do check(type(require(client[name]))=='table','engine loads '..name)end
 check(type(require(game.ServerScriptService.Server.Combat.CombatService))=='table','engine loads combat service')
 local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
 local scroll=Instance.new('ScrollingFrame');scroll.Size=UDim2.fromOffset(400,700);scroll.Parent=gui
 local notice=Instance.new('TextLabel');notice.Parent=gui
 local snapshot={ready=true,heroId='hero',heroes=profile.heroes,items=items,wallet=profile.wallet,revision=profile.revision}
 def.specialEffects={effect('skill_damage',.15,target)}
 local forge=require(client.EnhancementView)
 for _,width in ipairs({400,900})do
  scroll.Size=UDim2.fromOffset(width,700)
  for _,child in ipairs(scroll:GetChildren())do child:Destroy()end
  task.wait(.1);forge.render(scroll,snapshot,function()end,false,notice);task.wait(.1)
  local card=scroll:FindFirstChild(selected.instanceId)
  check(card and card.Description.Text:find('WHIRLWIND damage +15%',1,true),'forge displays authored special effect')
  check(card.Description.AbsoluteSize.Y>=game:GetService('TextService'):GetTextSize(card.Description.Text,12,card.Description.Font,Vector2.new(card.Description.AbsoluteSize.X,10000)).Y,'forge description fits at width '..width)
 end
 def.specialEffects=saved
 local fine=C.items.knight_weapon_fine;local old=fine.specialEffects;fine.specialEffects={effect('physical_damage',.1)}
 local shop=require(client.ArmoryView).create(gui,function()end,false,'blacksmith')
 shop.render(snapshot);shop.panel.Visible=true;task.wait(.1)
 local found=false
 for _,card in ipairs(shop.panel.Offers:GetChildren())do
  if card:FindFirstChild('Details')and card.Details.Text:find('Physical damage +10%',1,true)then found=true end
 end
 check(found,'shop shows definition effect and comparison')
 fine.specialEffects=old;gui:Destroy()
end
print('Equipment special effects: '..n..' checks passed')

end
