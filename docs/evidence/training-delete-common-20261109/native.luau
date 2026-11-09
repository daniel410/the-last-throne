assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"isolated place only")
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
 local ids={class..'_weapon_fine','traveler_hood','traveler_coat','traveler_gloves','traveler_boots','copper_ring','amber_charm'}
 for _,id in ipairs(ids)do
  local count=0
  for _,item in pairs(p.items)do if item.definitionId==id then
   count=count+1;eq(item.location.kind,'equipped',class..' starts wearing '..id)
  end end
  eq(count,1,class..' receives exactly one '..id)
 end
 eq(R.equipped(p,'hero','weapon').definitionId,class..'_weapon_fine',class..' starts with real weapon')
 eq(C.items[class..'_weapon_fine'].rarity,'Common',class..' starter is Common')
 eq(C.items[class..'_weapon_fine'].stats.power,3,class..' starter power unchanged')
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
 eq(stats.power,5,class..' starter power ceiling');eq(stats.health,50,class..' starter HP ceiling');eq(stats.armor,5,class..' starter armor ceiling')
 local base=G.derived(class,p.heroes.hero.progression)
 local total=P.derived(class,p.heroes.hero.progression,stats)
 eq(total.health,base.health+50,class..' UI HP follows equipped server stats')
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
eq(C.items.veteran_hood.stats.armor,2,'free Lv5 hood remains modest')
print('Starter gear balance: '..n..' checks passed')

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
  check(def.rarity=='Common'or def.rarity=='Uncommon','all usable attack gear uses flat contract')
  check(near(E.stats(def,{enhancementLevel=9}).power,def.stats.power*1.27),'enhancement increases flat base by 27 percent')
 end
end
for _,id in ipairs(C.deletedEquipment)do check(next(E.stats(C.items[id],{enhancementLevel=9}))==nil,'deleted gear adds no combat effects')end
print('Flat equipment power: '..n..' checks passed')

end
do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local I=require(game.ReplicatedStorage.Shared.ItemCatalog)
local C=require(game.ReplicatedStorage.Shared.EconomyCatalog)
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local counts={Weapons=0,Armor=0,Accessories=0};local grades={}
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId]
 if C.allowed('blacksmith',d,offer)then
  counts[C.category(d)]=counts[C.category(d)]+1;grades[d.rarity]=(grades[d.rarity]or 0)+1
  check(not C.diamondGear(d) or offer.currency=='diamonds','Rare/Epic Diamond-only '..offer.id)
  local p=R.addHero(R.new(81),'h','knight',I);p.wallet.gold=10000;p.wallet.diamonds=1000
  local cmd={store='blacksmith',action='Buy',requestId='forge-buy',heroId='h',revision=p.revision,offerId=offer.id,currency='gold',price=0}
  local n,e=R.shop(p,cmd,{atLobby=true},I)
  check(n and not e and n.wallet[offer.currency]==p.wallet[offer.currency]-offer.price,'server currency/price '..offer.id)
  local other=offer.currency=='gold' and 'diamonds' or 'gold'
  check(n.wallet[other]==p.wallet[other],'other currency unchanged '..offer.id)
  check(n.items['shop-forge-buy'].definitionId==d.id,'correct delivery '..offer.id)
  local again=assert(R.shop(n,cmd,{atLobby=true},I));check(again.wallet[offer.currency]==n.wallet[offer.currency] and again.revision==n.revision,'buy retry idempotent')
  local sell={store='blacksmith',action='Sell',requestId='forge-sell',heroId='h',revision=n.revision,instanceId='shop-forge-buy',itemVersion=1}
  local sold=assert(R.shop(n,sell,{atLobby=true},I))
  check(not sold.items['shop-forge-buy'] and sold.wallet.gold==n.wallet.gold+C.sell[d.id] and sold.wallet.diamonds==n.wallet.diamonds,'sale credits only Gold once')
  local twice=assert(R.shop(sold,sell,{atLobby=true},I));check(twice.wallet.gold==sold.wallet.gold,'sale retry idempotent')
 end
end
check(counts.Weapons==8 and counts.Armor==6 and counts.Accessories==2,'all 16 active forge offers classified')
check(grades.Common==9 and grades.Uncommon==7 and not grades.Rare and not grades.Epic,'forge stock by grade')
check(#C.forgeDiamondStock==0,'retired forge stock has no active rows')
print('Blacksmith active stock: '..checks..' checks passed')

end
