local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function fresh(gold)local p=assert(R.addHero(R.new(42),'h','knight',C));p.wallet.gold=gold;p.wallet.diamonds=99;return p end
local function cmd(p,id,action)return {requestId=id,action=action or 'ExchangeGems',store='blacksmith',heroId='h',revision=p.revision,exchangeVersion=E.exchangeVersion}end
local function trade(p,c,ctx)return R.shop(p,c,ctx or {atLobby=true},C)end
local p=fresh(200);local c=cmd(p,'gems');c.price=0;c.amount=10000
local n=assert(trade(p,c))
check(n.wallet.gold==150 and R.quantity(n,'h','enhancement_gem')==5,'server ignores forged price/quantity and grants five gems for50 Gold')
check(n.wallet.diamonds==99 and R.validate(n,C),'Diamonds and ownership preserved')
for i=1,100 do local replay,err,duplicate=trade(n,c,{atLobby=false});check(not err and duplicate and replay.wallet.gold==150 and R.quantity(replay,'h','enhancement_gem')==5,'duplicate request never repeats debit/grant')end
local conflict=R.copy(c);conflict.exchangeVersion=2
local no,why=trade(n,conflict);check(not no and why=='RequestConflict','same request with different quote version conflicts')
for _,version in ipairs({0,2})do local stale=cmd(n,'stale'..version);stale.exchangeVersion=version;no,why=trade(n,stale);check(not no and why=='ExchangeChanged','stale quote rejected without spending')end
local missing=cmd(n,'missing');missing.exchangeVersion=nil;no,why=trade(n,missing);check(not no and why=='ExchangeChanged','new exchange requires a quote version')
no,why=trade(p,cmd(p,'outside'),{atLobby=false});check(not no and why=='ShopLobbyOnly','exchange is lobby-only')
local poor=fresh(49);no,why=trade(poor,cmd(poor,'poor'));check(not no and why=='NotEnoughGold' and poor.wallet.gold==49 and R.quantity(poor,'h','enhancement_gem')==0,'one Gold short cannot buy or debit')
local exact=fresh(50);n=assert(trade(exact,cmd(exact,'exact')));check(n.wallet.gold==0 and R.quantity(n,'h','enhancement_gem')==5,'exact Gold succeeds')
local foreign=cmd(p,'foreign');foreign.heroId='missing';no,why=trade(p,foreign);check(not no and why=='HeroNotOwned','other hero cannot receive materials')
-- Preserve the existing stone exchange and its historical request shape.
local stone=cmd(n,'stone','ExchangeStone');n.wallet.gold=50;stone.exchangeVersion=nil
n=assert(trade(n,stone));check(n.wallet.gold==0 and R.quantity(n,'h','enhancement_gem')==0 and R.quantity(n,'h','magic_stone')==1,'five gems and50 Gold yield one stone')
local receipt=assert(trade(n,stone));check(receipt.wallet.gold==0 and R.quantity(receipt,'h','magic_stone')==1,'legacy stone retry cannot mint')
-- Bought Gems must fit in this hero's bag, including split-stack edge cases.
local full=fresh(50)
while R.count(full,'bag','h')<C.bagCapacity do
 local id='fill-'..R.count(full,'bag','h');full.items[id]={instanceId=id,definitionId='iron_ore',definitionVersion=C.version,ownerUserId=42,quantity=999,version=1,binding='account',locked=false,location={kind='bag',heroId='h'}}
end
no,why=trade(full,cmd(full,'full'));check(not no and why=='BagFull' and full.wallet.gold==50 and R.count(full,'pending')==0,'full bag cannot lose Gold or redirect bought Gems')
local slot='fill-20';assert(full.items[slot]);full.items[slot].definitionId='enhancement_gem';full.items[slot].quantity=994
n=assert(trade(full,cmd(full,'merge')));check(n.items[slot].quantity==999 and n.wallet.gold==0,'full bag can fill an existing gem stack exactly')
full.items[slot].quantity=997;no,why=trade(full,cmd(full,'split'))
check(not no and why=='BagFull' and full.items[slot].quantity==997 and full.wallet.gold==50,'partial merge refusal rolls back entire purchase')
full.items[slot].quantity=994;full.items[slot].locked=true;no,why=trade(full,cmd(full,'locked'));check(not no and why=='BagFull','locked stack cannot receive a purchase')
-- Lost acknowledgement after commit and repeated UpdateAsync callback.
local saved,lose
local adapter={UpdateAsync=function(_,_,fn)
 fn(saved and R.copy(saved));local result=fn(saved and R.copy(saved));if result then saved=R.copy(result)end
 if lose then error('lost acknowledgement')end;return result
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'exchange-session')
assert(store:open(42));p=assert(store:transact(42,function(v)local q=fresh(100);q.epoch=v.epoch;q.lease=v.lease;return q end));c=cmd(p,'unknown')
lose=true;no,why=store:transact(42,function(v)return trade(v,c)end);check(not no and why=='SaveUnknown','lost committed purchase remains unknown')
lose=false;n=assert(store:transact(42,function(v)return trade(v,c)end));check(n.wallet.gold==50 and R.quantity(n,'h','enhancement_gem')==5,'unknown retry recovers one debit and one grant')
check(store:close(42)~=nil,'save release succeeds');local reopened=assert(store:open(42));check(reopened.wallet.gold==50 and R.quantity(reopened,'h','enhancement_gem')==5,'purchase persists on rejoin')
-- Enhancement costs are fixed for every target and supported equipment type.
for _,id in ipairs({'knight_weapon_fine','traveler_coat','copper_ring'})do for target=1,9 do check(E.cost(C.items[id],target).gold==25,'flat25 Gold on every equipment type and target')end end
local gear;for _,item in pairs(p.items)do if item.definitionId=='knight_weapon_fine'then gear=item end end
local function attempt(profile,id,version)return {action='Enhance',store='blacksmith',requestId=id,heroId='h',revision=profile.revision,instanceId=gear.instanceId,itemVersion=gear.version,rulesVersion=version or E.version,expectedLevel=0}end
p=fresh(24);F.grant(p,R,C,'h','enhancement_gem',10,'gems');local before=R.quantity(p,'h','enhancement_gem')
no,why=trade(p,attempt(p,'fee-poor'),{atLobby=true,enhancementRoll=0});check(not no and why=='NotEnoughGold'and p.wallet.gold==24 and R.quantity(p,'h','enhancement_gem')==before,'fee shortage never consumes materials')
p.wallet.gold=25;n=assert(trade(p,attempt(p,'fee-exact'),{atLobby=true,enhancementRoll=0}));check(n.wallet.gold==0 and n.operations['fee-exact'].enhancementOutcome.gold==25,'exact fee and receipt saved')
no,why=trade(p,attempt(p,'old-ui',2),{atLobby=true,enhancementRoll=0});check(not no and why=='EnhancementChanged','old free-cost UI cannot spend with stale confirmation')
local old=attempt(p,'old-receipt',2)
local fingerprint=table.concat({'forge',old.action,old.heroId,old.instanceId,'',tostring(old.itemVersion),tostring(old.revision),old.store,tostring(old.rulesVersion),tostring(old.expectedLevel)},'|')
p.operations[old.requestId]={fingerprint=fingerprint,revision=p.revision,enhancementOutcome={gold=0,success=true,rulesVersion=2}}
local historic,err,duplicate=trade(p,old,{atLobby=false});check(not err and duplicate and historic.wallet.gold==25 and historic.operations[old.requestId].enhancementOutcome.gold==0,'historical free attempt receipt is replayed without a retroactive charge')
print('Material exchange and flat fee: '..checks..' checks passed')
