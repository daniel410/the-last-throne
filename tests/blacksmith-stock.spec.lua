local R=dofile('src/server/Inventory/InventoryRules.luau')
local I=dofile('src/shared/ItemCatalog.luau')
local C=dofile('src/shared/EconomyCatalog.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local counts={Weapons=0,Armor=0,Accessories=0}
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId]
 if C.allowed('blacksmith',d,offer)then
  counts[C.category(d)]=counts[C.category(d)]+1
  local p=R.addHero(R.new(81),'h','knight',I);p.wallet.gold=10000
  local cmd={store='blacksmith',action='Buy',requestId='forge-buy',heroId='h',revision=p.revision,offerId=offer.id}
  local n,e=R.shop(p,cmd,{atLobby=true},I)
  check(n and not e and n.wallet.gold==10000-offer.price,'forge buys '..offer.id)
  check(n.items['shop-forge-buy'].definitionId==d.id,'correct bag delivery '..offer.id)
  local again=assert(R.shop(n,cmd,{atLobby=true},I));check(again.wallet.gold==n.wallet.gold and again.revision==n.revision,'buy retry idempotent')
  local sell={store='blacksmith',action='Sell',requestId='forge-sell',heroId='h',revision=n.revision,instanceId='shop-forge-buy',itemVersion=1}
  local sold=assert(R.shop(n,sell,{atLobby=true},I))
  check(not sold.items['shop-forge-buy'] and sold.wallet.gold==n.wallet.gold+C.sell[d.id],'forge sale credits Gold once')
  local twice=assert(R.shop(sold,sell,{atLobby=true},I));check(twice.wallet.gold==sold.wallet.gold,'sale retry idempotent')
 end
end
check(counts.Weapons==12 and counts.Armor==11 and counts.Accessories==5,'complete Gold stock by category')
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId]
 if d.restore or offer.currency=='diamonds'then
  check(not C.allowed('blacksmith',d,offer),'forge rejects consumables and Diamond offers')
  local p=R.addHero(R.new(82),'h','knight',I);p.wallet.gold=10000;p.wallet.diamonds=100
  check(not R.shop(p,{store='blacksmith',action='Buy',requestId='bad',heroId='h',revision=p.revision,offerId=offer.id},{atLobby=true},I),'server rejects wrong-store offer')
 end
end
print('Blacksmith stock: '..checks..' checks passed')
