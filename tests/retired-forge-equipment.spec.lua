local R=dofile('src/server/Inventory/InventoryRules.luau')
local I=dofile('src/shared/ItemCatalog.luau')
local C=dofile('src/shared/EconomyCatalog.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local E=dofile('src/shared/Enhancement.luau')
local G=dofile('src/shared/HeroProgression.luau')
-- Inject an offer into the actual economy reducer's catalog (dofile otherwise creates separate tables).
local env=setmetatable({dofile=function(path)if path=='src/shared/EconomyCatalog.luau'then return C end;return dofile(path)end},{__index=_G})
local Economy=assert(loadfile('src/shared/EconomyRules.luau','t',env))()
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
check(#I.retiredEquipment==24,'exactly 24 retired definitions')
check(#C.forgeDiamondStock==0 and #C.retiredForgeDiamondStock==12,'no active old forge stock')
for _,id in ipairs(I.retiredEquipment)do
 local def=I.items[id];check(def.retired and not def.cacheEligible and def.level==10,'retirement marker '..id)
 check(def.rarity=='Rare'or def.rarity=='Epic','only Rare/Epic retired')
 check(C.offer(id)==nil and C.offer(id..'_diamond')==nil,'old Gold/Diamond SKUs removed '..id)
 local p=assert(R.addHero(R.new(78),'h',def.classId or 'knight',I));p.heroes.h.level=10;p.heroes.h.progression=G.new(10)
 p.wallet.gold=10000;p.wallet.diamonds=1000
 p.items.cache={instanceId='cache',definitionId='equipment_cache_10',definitionVersion=I.version,ownerUserId=78,quantity=3,version=1,binding='account',locked=false,location={kind='bag',heroId='h'},sourceGrantId='legacy-cache'}
 local before=R.copy(p)
 -- A previously committed purchase can replay after retirement without charging again.
 local historical={id='historical-receipt',definitionId=id,currency='diamonds',price=1}
 def.retired=false;table.insert(C.offers,historical)
 local receipt={store='blacksmith',action='Buy',requestId='paid-before-retirement',heroId='h',revision=p.revision,offerId=historical.id}
 local paid=assert(Economy.apply(p,receipt,{atLobby=true},I,R))
 def.retired=true;table.remove(C.offers)
 local replay,_,repeated=Economy.apply(paid,receipt,{atLobby=false},I,R)
 check(repeated and equal(paid,replay),'committed receipt replay survives retirement without duplicate charge')
 for _,store in ipairs({'blacksmith','items','diamonds','all'})do
  for _,currency in ipairs({'gold','diamonds'})do
   local fake={id='fake-retired',definitionId=id,currency=currency,price=1};table.insert(C.offers,fake)
   local cmd={store=store~='all'and store or nil,action='Buy',requestId='buy',heroId='h',revision=p.revision,offerId=fake.id}
   check(not Economy.apply(p,cmd,{atLobby=true},I,R),'forged retired SKU blocked '..id..'/'..store..'/'..currency)
   table.remove(C.offers)
  end
 end
 -- Defense remains even if an obsolete client claims cache eligibility.
 local saved=def.cacheEligible;def.cacheEligible=true
 local result,err=R.shop(p,{store='blacksmith',action='OpenCache',requestId='cache',heroId='h',revision=p.revision,instanceId='cache',itemVersion=1,offerId=id},{atLobby=true},I)
 def.cacheEligible=saved
 check(not result and err=='RetiredEquipment','retired cache choice blocked '..id)
 check(equal(p,before),'failed cache/purchase does not consume cache, balances, revisions or operations')
 check(not F.grant(p,R,I,'h',id,1,'forbidden') and equal(p,before),'generic new grant blocked')
 -- An owned +9 instance must still load, move and retain its investment.
 p.items.legacy={instanceId='legacy',definitionId=id,definitionVersion=I.version,ownerUserId=78,quantity=1,version=1,binding='account',locked=false,location={kind='bag',heroId='h'},sourceGrantId='old-purchase',enhancementLevel=9}
 check(R.validate(p,I),'owned retired +9 validates '..id)
 local snap=R.copy(p);local power=E.stats(def,p.items.legacy)
 local moved=assert(R.apply(p,{action='Deposit',quantity=1,heroId='h',revision=p.revision,requestId='storage',instanceId='legacy',itemVersion=1},{safe=true,atStorage=true},I))
 check(moved.items.legacy.location.kind=='storage' and moved.items.legacy.enhancementLevel==9,'legacy storage keeps +9')
 local worn=assert(R.apply(p,{action='Equip',slot='accessory1',heroId='h',revision=p.revision,requestId='equip',instanceId='legacy',itemVersion=1},{safe=true},I))
 check(worn.items.legacy.location.kind=='equipped' and worn.items.legacy.enhancementLevel==9 and R.validate(worn,I),'existing equipment remains compatible')
 check(equal(p,snap)and power~=nil,'reading owned gear does not mutate it')
 local sold=assert(R.shop(p,{store='blacksmith',action='Sell',requestId='sell',heroId='h',revision=p.revision,instanceId='legacy',itemVersion=1},{atLobby=true},I))
 check(sold.wallet.gold==p.wallet.gold+C.sell[id]and sold.wallet.diamonds==p.wallet.diamonds and not sold.items.legacy,'explicit legacy resale preserved')
end
for _,id in ipairs({'knight_weapon_fine','knight_weapon_veteran','veteran_hood'})do check(not I.items[id].retired,'starter/Uncommon preserved')end
check(I.items.knight_weapon.retired and I.items.knight_weapon.cacheEligible==false,'training starter retired separately')
print('Retired forge equipment: '..n..' checks passed')
