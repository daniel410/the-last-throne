local R=dofile('src/server/Inventory/InventoryRules.luau')
local I=dofile('src/shared/ItemCatalog.luau')
local C=dofile('src/shared/EconomyCatalog.luau')
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
check(counts.Weapons==16 and counts.Armor==16 and counts.Accessories==8,'all 40 forge offers classified')
check(grades.Common==5 and grades.Uncommon==11 and grades.Rare==12 and grades.Epic==12,'forge stock by grade')
for _,row in ipairs(C.forgeDiamondStock)do
 check(C.offer(row.id)==nil,'old Gold SKU retired '..row.id)
 local p=R.addHero(R.new(82),'h','knight',I);p.wallet.gold=10000;p.wallet.diamonds=0
 for _,id in ipairs({row.id,row.id..'_diamond',row.id..'_epic_diamond'})do
  check(not R.shop(p,{store='blacksmith',action='Buy',requestId='no-diamonds',heroId='h',revision=p.revision,offerId=id},{atLobby=true},I),'Gold cannot pay for Rare/Epic '..id)
 end
 local rare=I.items[row.id];local epic=I.items[row.id..'_epic']
 for k,v in pairs(rare.stats)do check(epic.stats[k]>v,'Epic base improvement '..row.id..'.'..k)end
 check(epic.level==rare.level and epic.classId==rare.classId and epic.slot==rare.slot and epic.uniqueGroup==rare.uniqueGroup,'same eligibility and group')
 -- Even an accidentally introduced Gold offer must be rejected by the server gate.
 local bad={id='qa-forbidden-gold',definitionId=row.id,currency='gold',price=1};table.insert(C.offers,bad)
 for _,store in ipairs({'blacksmith','items','diamonds','all'})do
  local route=store;if store=='all' then route=nil end
  local n=R.shop(p,{store=route,action='Buy',requestId='forged-offer',heroId='h',revision=p.revision,offerId=bad.id},{atLobby=true},I)
  check(not n,'Gold offer rejected across routes '..store)
 end
 table.remove(C.offers)
end
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId]
 if d.restore or (offer.currency=='diamonds' and not C.diamondGear(d))then
  check(not C.allowed('blacksmith',d,offer),'forge rejects potion/unrelated Diamond offers')
 end
end
-- Insufficient funds/full bag cannot charge a real Diamond offer.
local p=R.addHero(R.new(83),'h','knight',I);p.wallet.diamonds=1000
for i=1,I.bagCapacity-R.count(p,'bag','h')do
 local item=R.copy(p.items['h-starter-3']);item.instanceId='fill'..i;item.location={kind='bag',heroId='h'};p.items[item.instanceId]=item
end
check(not R.shop(p,{store='blacksmith',action='Buy',requestId='full',heroId='h',revision=p.revision,offerId='sentinel_mail_epic_diamond'},{atLobby=true},I),'full bag blocks purchase')
check(p.wallet.diamonds==1000,'failed full-bag purchase preserves balance')
-- Legacy cache rights remain valid without silently adding newly sold Epic gear.
local cacheProfile=R.addHero(R.new(84),'h','knight',I)
cacheProfile.items['qa-cache']={instanceId='qa-cache',definitionId='equipment_cache_10',definitionVersion=I.version,ownerUserId=84,quantity=1,version=1,binding='account',locked=false,location={kind='bag',heroId='h'},sourceGrantId='qa'}
local cacheCmd={store='blacksmith',action='OpenCache',requestId='cache',heroId='h',revision=cacheProfile.revision,instanceId='qa-cache',itemVersion=1,offerId='knight_weapon_forged_epic'}
check(not R.shop(cacheProfile,cacheCmd,{atLobby=true},I),'existing cache cannot acquire newly sold Epic')
cacheCmd.offerId='knight_weapon_forged'
check(R.shop(cacheProfile,cacheCmd,{atLobby=true},I)~=nil,'existing cache Rare choice remains valid')
print('Blacksmith Diamond stock: '..checks..' checks passed')
