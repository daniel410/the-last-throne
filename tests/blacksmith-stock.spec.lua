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
check(counts.Weapons==12 and counts.Armor==18 and counts.Accessories==3,'33 purchasable forge offers exclude starter Traveler')
check(grades.Common==11 and grades.Uncommon==12 and grades.Rare==10 and not grades.Epic,'forge stock by grade')
check(#C.forgeDiamondStock==0,'retired forge stock has no active rows')
-- Cached/forged Traveler requests cannot spend currency or mint gear.
local starter=R.addHero(R.new(82),'h','knight',I);starter.wallet.gold=10000;starter.wallet.diamonds=1000
for _,id in ipairs(I.tierEquipment)do if I.items[id].family=='traveler'then
 for _,offerId in ipairs({id,id..'_diamond'})do
  check(C.offer(offerId)==nil,'no Traveler product '..offerId)
  for _,store in ipairs({'blacksmith','diamonds','all'})do
   local beforeGold,beforeDiamonds,beforeRevision=starter.wallet.gold,starter.wallet.diamonds,starter.revision
   local bought,err=R.shop(starter,{store=store=='all'and nil or store,action='Buy',requestId='old-'..store..offerId,heroId='h',revision=starter.revision,offerId=offerId},{atLobby=true},I)
   check(not bought and err=='InvalidRequest','reject old Traveler request '..offerId..' '..store)
   check(starter.wallet.gold==beforeGold and starter.wallet.diamonds==beforeDiamonds and starter.revision==beforeRevision and not starter.items['shop-old-'..store..offerId],'rejected request leaves profile unchanged')
  end
 end
end end
check(R.equipped(starter,'h','weapon').definitionId=='knight_weapon_traveler','default issued weapon still equipped')
check(R.validate(starter,I),'default issued inventory remains valid')

local Pricing=dofile('src/shared/EquipmentPricing.luau')
for _,offer in ipairs(C.goldOffers)do check(offer.amount==offer.price*Pricing.goldPerDiamond,'equipment price basis matches the actual Gold exchange '..offer.id)end
for _,offer in ipairs(C.offers)do
 local d=I.items[offer.definitionId]
 if d.category=='Equipment'then
  local same=C.offer(d.id)
  if offer.currency=='diamonds'and same then check(offer.price*Pricing.goldPerDiamond==same.price,'alternate currency cannot undercut the Gold price '..d.id)end
  local equivalent=offer.price*(offer.currency=='diamonds'and Pricing.goldPerDiamond or 1)
  check(C.sell[d.id]<=equivalent*.2,'resale cannot create a cross-currency loop '..d.id)
 end
end
for _,slot in ipairs({'weapon','offhand','head','body','hands','feet'})do
 check(Pricing.families.tempered[slot]<Pricing.families.veteran[slot]and Pricing.families.veteran[slot]<Pricing.families.sentinel[slot]*Pricing.goldPerDiamond,'each slot has increasing tier prices '..slot)
end
local Content=dofile('src/shared/CampaignContent.luau');local Summary=dofile('src/shared/EncounterSummary.luau');local Difficulty=dofile('src/shared/Difficulty.luau')
local earnings={0,0}
for _,c in ipairs(Content.mainChapters)do if c.epic<=2 then earnings[c.epic]=earnings[c.epic]+c.reward.coins+Summary.mission(c,'Easy',1,Difficulty.version).gold end end
check(Pricing.families.tempered.head>Summary.mission(Content.byId['DW-01'],'Easy',1,Difficulty.version).gold+Content.byId['DW-01'].reward.coins,'hood is worth saving more than one first mission')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local totals={tempered=0,veteran=0,sentinel=0}
 for family in pairs(totals)do for _,slot in ipairs({'weapon','head','body','hands','feet'})do totals[family]=totals[family]+Pricing.families[family][slot]end;if class=='knight'then totals[family]=totals[family]+Pricing.families[family].offhand end end
 check(totals.tempered<earnings[1],'full first upgrade fits the first epic authored gross budget '..class)
 check(totals.veteran>earnings[1]and totals.veteran<earnings[1]+earnings[2],'Veteran kit is a two-epic saving target '..class)
 check(totals.sentinel<=Content.mainCount*3*2,'Rare kit fits two difficulty tiers of first-clear Diamonds '..class)
end
print('Blacksmith active stock: '..checks..' checks passed')
