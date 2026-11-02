local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local Economy=dofile('src/shared/EconomyCatalog.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local count=0
for _,offer in ipairs(Economy.offers)do
 local def=Items.items[offer.definitionId]
 if offer.currency=='diamonds' and def.slot=='weapon' then
  count=count+1
  local p=R.addHero(R.new(73),'h',def.classId,Items);p.wallet.diamonds=offer.price
  local cmd={store='diamonds',action='Buy',requestId='weapon',heroId='h',revision=p.revision,offerId=offer.id}
  local bought=assert(R.shop(p,cmd,{atLobby=true},Items))
  check(bought.wallet.diamonds==0 and bought.wallet.gold==p.wallet.gold,'debit exact Diamonds '..offer.id)
  check(bought.items['shop-weapon'].definitionId==Economy.offer(def.id).definitionId,'same gear as Gold purchase '..offer.id)
  local replay=assert(R.shop(bought,cmd,{atLobby=true},Items))
  check(replay.revision==bought.revision and R.count(replay,'bag','h')==R.count(bought,'bag','h'),'retry grants no duplicate '..offer.id)
  p.wallet.diamonds=offer.price-1
  local no,why=R.shop(p,cmd,{atLobby=true},Items)
  check(not no and why=='NotEnoughDiamonds','one short rejected '..offer.id)
  local sold=assert(R.shop(bought,{store='blacksmith',action='Sell',requestId='sell',heroId='h',revision=bought.revision,instanceId='shop-weapon',itemVersion=1},{atLobby=true},Items))
  check(sold.wallet.diamonds==0 and sold.wallet.gold==p.wallet.gold+Economy.sell[def.id],'resale returns Gold only '..offer.id)
  check(Economy.sell[def.id]<offer.price*50,'resale worse than direct Gold exchange '..offer.id)
 end
end
check(count==8,'existing Veteran and added Dawnforge for each of four classes')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 check(not Economy.offer(class..'_weapon_fine_diamond'),'free starter weapon is not added as a Diamond product')
end
print('Diamond weapons: '..checks..' checks passed')
