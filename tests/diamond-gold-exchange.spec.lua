local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Economy=dofile('src/shared/EconomyCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local offer=assert(Economy.goldOffer('rpg_gold_500_diamond'))
check(offer.amount==500 and offer.price==10 and offer.currency=='diamonds','RPG item-based rate')
local p=R.addHero(R.new(100),'h','knight',C);p.wallet.gold=5;p.wallet.diamonds=10
local command={store='diamonds',action='Buy',requestId='exchange',heroId='h',revision=p.revision,offerId=offer.id}
local n,e=R.shop(p,command,{atLobby=true},C)
check(n and not e and n.wallet.gold==505 and n.wallet.diamonds==0,'single account update exchanges 10 Diamonds for 500 Gold')
check(R.count(n,'bag','h')==R.count(p,'bag','h'),'currency is credited directly, not delivered as an item')
local again,_,replayed=R.shop(n,command,{atLobby=true},C)
check(replayed and again.wallet.gold==505 and again.wallet.diamonds==0,'same request retry never grants twice')
local other=R.copy(command);other.requestId='poor';other.revision=n.revision
local no,reason=R.shop(n,other,{atLobby=true},C);check(not no and reason=='NotEnoughDiamonds','insufficient balance cannot grant Gold')
for _,store in ipairs({'blacksmith','items'})do local bad=R.copy(command);bad.store=store;bad.requestId=store;check(not R.shop(p,bad,{atLobby=true},C),'wrong store cannot exchange')end
local noStore=R.copy(command);noStore.store=nil;check(not R.shop(p,noStore,{atLobby=true},C),'legacy generic store cannot exchange')
check(not R.shop(p,command,{atLobby=false},C),'exchange is lobby-only')
local capped=R.copy(p);capped.wallet.gold=1e12-499
local blocked,cap=R.shop(capped,command,{atLobby=true},C);check(not blocked and cap=='BalanceLimit','wallet cap is respected without debit')
local full=R.copy(p)
for i=1,60-R.count(full,'bag','h')do local item=R.copy(full.items['h-starter-3']);item.instanceId='fill'..i;item.location={kind='bag',heroId='h'};full.items[item.instanceId]=item end
check(R.shop(full,command,{atLobby=true},C)~=nil,'full bag does not block account currency')
local db,fail={},false;local now=1000
local store=Store.new({UpdateAsync=function(_,key,callback)local next=callback(db[key]and R.copy(db[key]));if next then db[key]=R.copy(next)end;if fail then error('ack lost')end;return next end},R,C,function()return now end,function()end,'shop-a')
assert(store:open(100));assert(store:transact(100,function(v)local seeded=R.copy(p);seeded.lease=v.lease;seeded.epoch=v.epoch;return seeded end))
fail=true;local uncertain,err=store:transact(100,function(v)return R.shop(v,command,{atLobby=true},C)end)
check(not uncertain and err=='SaveUnknown','unknown save is not treated as failure or success')
fail=false;local recovered,why,retry=store:transact(100,function(v)return R.shop(v,command,{atLobby=true},C)end)
check(recovered and not why and retry and recovered.wallet.gold==505 and recovered.wallet.diamonds==0,'retry recovers exactly one exchange')
local rival=Store.new(store.adapter,R,C,function()return now end,function()end,'shop-b');local concurrent,locked=rival:open(100)
check(not concurrent and locked=='AccountBusy','concurrent server cannot exchange using stale account')
assert(store:close(100));local rejoined=assert(rival:open(100));check(rejoined.wallet.gold==505 and rejoined.wallet.diamonds==0,'exchange persists after rejoin')
check(not Economy.goldOffer('rpg_gold_100_diamond'),'retired SKU cannot start another purchase')
for _,bundle in ipairs(Economy.goldOffers)do
 local base=R.copy(p);base.wallet.diamonds=bundle.price
 local cmd=R.copy(command);cmd.offerId=bundle.id;cmd.requestId='bundle-'..bundle.amount
 local bought=assert(R.shop(base,cmd,{atLobby=true},C))
 check(bought.wallet.gold==5+bundle.amount and bought.wallet.diamonds==0,'exact debit and credit '..bundle.id)
 local replay=assert(R.shop(bought,cmd,{atLobby=true},C))
 check(replay.wallet.gold==bought.wallet.gold and replay.revision==bought.revision,'idempotent '..bundle.id)
 base.wallet.diamonds=bundle.price-1
 local rejected,why=R.shop(base,cmd,{atLobby=true},C)
 check(not rejected and why=='NotEnoughDiamonds','one short cannot buy '..bundle.id)
end
print('Diamond Gold exchange: '..checks..' checks passed')
