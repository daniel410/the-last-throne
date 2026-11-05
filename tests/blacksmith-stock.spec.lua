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
check(counts.Weapons==8 and counts.Armor==6 and counts.Accessories==2,'all 16 active forge offers classified')
check(grades.Common==5 and grades.Uncommon==11 and not grades.Rare and not grades.Epic,'forge stock by grade')
check(#C.forgeDiamondStock==0,'retired forge stock has no active rows')
print('Blacksmith active stock: '..checks..' checks passed')
