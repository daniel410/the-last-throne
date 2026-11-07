local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Shop=dofile('src/shared/EconomyCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0
local function check(v,m) checks=checks+1;assert(v,m) end
for _,class in ipairs({'knight','elf','dwarf','mage'}) do
 local p=R.addHero(R.new(79),class,class,C)
 check(p.heroes[class].starterSuppliesClaimed==true,"hero starter receipt is committed with supplies")
 check(p.starterSuppliesClaimed==true and R.count(p,'pending')==0,'first kit is recorded once with no extra pending potions')
 for _,id in ipairs(C.potions) do
  local d=C.items[id];local quantity=R.quantity(p,class,id)
  check(quantity==((d.restore=='health' or class=='mage') and (d.potionTier==1 and 3 or d.potionTier==2 and 2 or 1) or 0),'only Mage starts with MP potions, all HP tiers retained')
  local offer=assert(Shop.offer(id));check(offer.currency=='gold' and offer.price>0,'all eight potion variants purchasable with server Gold price')
  p.wallet.gold=10000
  local before=R.quantity(p,class,id);local gold=p.wallet.gold
  local command={action='Buy',requestId='buy-'..id,heroId=class,revision=p.revision,offerId=id}
  local n=assert(R.shop(p,command,{atLobby=true},C));check(R.quantity(n,class,id)==before+1 and n.wallet.gold==gold-offer.price,'one potion and debit commit atomically for any class')
  local again,_,repeated=R.shop(n,command,{atLobby=true},C)
  check(repeated and R.quantity(again,class,id)==before+1 and again.wallet.gold==n.wallet.gold,'potion retry never duplicates quantity or debit')
  check(R.validate(n,C),'potion purchase retains inventory invariant');p=n
 end
 local slots=p.heroes[class].quickSlots
 check(slots[2]==(class=='mage' and 'mana_potion' or 'health_potion_medium'),'starter quick slots match class resources')
end
-- Each newly created hero gets its own kit, regardless of creation order.
for _,first in ipairs({'knight','elf','dwarf','mage'})do
 local p=assert(R.addHero(R.new(780),first,first,C))
 for _,class in ipairs({'knight','elf','dwarf','mage'})do if class~=first then
  p=assert(R.addHero(p,class,class,C))
  for _,id in ipairs(C.potions)do
   local d=C.items[id];local expected=(d.restore=='health' or class=='mage') and (d.potionTier==1 and 3 or d.potionTier==2 and 2 or 1) or 0
   check(R.quantity(p,class,id)==expected,'later hero receives its own initial potions')
  end
  check(R.quantity(p,class,'iron_ore')==24 and R.equipped(p,class,'weapon').definitionId==class..'_weapon_fine','later hero receives its initial equipment and materials')
  check(R.equipped(p,class,'weapon')~=nil,'later hero retains basic class weapon')
 end end
 check(R.validate(p,C),'all four heroes with once-only supplies remain valid')
end
local legacyProfile=assert(R.addHero(R.new(781),'old','knight',C));legacyProfile.starterSuppliesClaimed=nil;legacyProfile.heroes.old.starterSuppliesClaimed=nil
local legacyAdded=assert(R.addHero(legacyProfile,'new','mage',C))
check(R.quantity(legacyAdded,'new','health_potion')==3 and R.quantity(legacyAdded,'new','mana_potion')==3,'new hero on legacy account receives its own kit')
check(R.quantity(legacyAdded,'old','health_potion')==3,'legacy inventory is preserved')
local migrated=R.upgrade(R.copy(legacyProfile))
check(migrated.starterSuppliesClaimed==true and R.quantity(migrated,'old','health_potion')==3,'opening a legacy profile records prior supplies without granting or removing items')
local consumed=assert(R.addHero(R.new(782),'old','knight',C));consumed.items={}
local again=R.upgrade(R.copy(consumed))
check(R.quantity(again,'old','health_potion')==0 and next(again.items)==nil,'empty bags never trigger a refill')
local deniedDuplicate=R.addHero(again,'retry','knight',C)
check(not deniedDuplicate,'retrying class creation cannot repeat a starter kit')
local conflict=R.addHero(again,'old','mage',C);check(not conflict,'existing hero ID cannot be overwritten')
again.heroes.old.starterSuppliesClaimed='invalid';check(not R.validate(again,C),'invalid hero supply receipt rejected')
consumed.starterSuppliesClaimed='invalid';check(not R.validate(consumed,C),'invalid supply marker is rejected')
local p=R.addHero(R.new(80),'h','knight',C);p.wallet.gold=10000
local hp
for _,item in pairs(p.items) do if item.definitionId=='health_potion' and item.location.kind=='bag' then hp=item end end
for i=1,C.bagCapacity-R.count(p,'bag','h') do local item=R.copy(p.items[hp.instanceId]);item.instanceId='fill-'..i;item.definitionId='iron_ore';p.items[item.instanceId]=item end
local command={action='Buy',requestId='full-stack',heroId='h',revision=p.revision,offerId='health_potion'}
local n=assert(R.shop(p,command,{atLobby=true},C));check(R.count(n,'bag','h')==C.bagCapacity and n.items[hp.instanceId].quantity==4,'full bag accepts purchase into existing available stack')
check(n.items[hp.instanceId].version==hp.version+1,'stack purchase invalidates stale item revision')
n.items[hp.instanceId].quantity=99;command.requestId='overflow';command.revision=n.revision
local denied,reason=R.shop(n,command,{atLobby=true},C);check(not denied and reason=='BagFull' and n.items[hp.instanceId].quantity==99,'full stack and bag cannot lose Gold or overflow')
-- A persisted legacy non-Mage MP inventory is left intact by new hero grants.
local legacy=R.addHero(R.new(81),'old','mage',C);legacy.heroes.old.baseClassId='knight'
for _,item in pairs(legacy.items) do if item.definitionId=='mage_weapon' then item.definitionId='knight_weapon' end end
-- Only assert that adding an unrelated new hero preserves its existing MP stock.
local before=R.quantity(legacy,'old','mana_potion');local added=assert(R.addHero(legacy,'new','dwarf',C))
check(R.quantity(added,'old','mana_potion')==before and added.heroes.old.quickSlots[2]=='mana_potion','existing saved MP items and assignments are never retroactively removed')
-- A save that committed but did not acknowledge recovers the same merged stack.
local db,fail={},false
local store=Store.new({UpdateAsync=function(_,key,fn)local v=fn(db[key] and R.copy(db[key]));if v then db[key]=R.copy(v) end;if fail then error('lost acknowledgement') end;return v end},R,C,function() return 100 end,function() end,'potion-test')
assert(store:open(91));assert(store:transact(91,function(v)v=R.addHero(v,'h','knight',C);v.wallet.gold=100;return v end))
local buy={action='Buy',requestId='unknown-potion',heroId='h',revision=db['account:91'].revision,offerId='health_potion'}
fail=true;local result,err=store:transact(91,function(v)return R.shop(v,buy,{atLobby=true},C) end)
check(not result and err=='SaveUnknown','unknown potion save is not treated as a failed purchase')
fail=false;result=assert(store:transact(91,function(v)return R.shop(v,buy,{atLobby=true},C) end))
check(result.wallet.gold==75 and R.quantity(result,'h','health_potion')==4,'same request recovers one debit and one stacked potion')
local second={action='Buy',requestId='second-potion',heroId='h',revision=result.revision,offerId='health_potion',store='items'}
local nextPurchase=assert(R.shop(result,second,{atLobby=true},C))
check(nextPurchase.wallet.gold==50 and R.quantity(nextPurchase,'h','health_potion')==5,'a new request can purchase the same potion again')
local replay,_,duplicate=R.shop(nextPurchase,second,{atLobby=true},C)
check(duplicate and replay.wallet.gold==50 and R.quantity(replay,'h','health_potion')==5,'retrying the second request does not duplicate it')
check(store:close(91)~=nil,'account closes after committed purchases')
local reopened=assert(store:open(91));check(reopened.starterSuppliesClaimed==true,'supply marker persists across rejoin')
local later=assert(store:transact(91,function(v)return R.addHero(v,'later','mage',C)end))
check(R.quantity(later,'later','health_potion')==3 and R.quantity(later,'later','mana_potion')==3,'new hero after rejoin gets its initial kit')
local revision=later.revision
local reopen=R.upgrade(R.copy(later));check(reopen.revision==revision,'reopening an already migrated profile never regrants supplies')
print('Starter potions and shop: '..checks..' checks passed')
