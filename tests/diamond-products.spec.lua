local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local S=dofile('src/server/Inventory/AccountStore.luau')
local Receipts=dofile('src/server/Lobby/DiamondReceiptRules.luau')
local Products=dofile('src/shared/DiamondProducts.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local fake={version=1,packs={}}
for index,pack in ipairs(Products.packs)do fake.packs[index]={productId=8000+index,diamonds=pack.diamonds}end
function fake.find(id)for _,p in ipairs(fake.packs)do if p.productId==id then return p end end end
check(Products.universeId==10773575153 and #Products.packs==3,'RPG-only catalog')
check(not Products.find(3728491648)and not Products.find(0),'TD product and zero cannot grant')
for index,id in ipairs({3731586526,3731586668,3731586908})do
 local pack=assert(Products.find(id))
 check(pack==Products.packs[index],'user-created RPG ProductId maps to correct pack')
 local n=assert(Receipts.grant(R.new(12),{PlayerId=12,ProductId=id,PurchaseId='real-sku-'..index},R))
 check(n.wallet.diamonds==({100,500,1200})[index],'configured RPG product grants exact amount')
end
for i,amount in ipairs({100,500,1200})do
 local p=R.new(12);p.wallet.diamonds=7;p.wallet.gold=19
 local receipt={PlayerId=12,ProductId=8000+i,PurchaseId='purchase-'..i}
 local n=assert(Receipts.grant(p,receipt,R,fake))
 check(n.wallet.diamonds==7+amount and n.wallet.gold==19,'exact paid grant '..amount)
 check(p.wallet.diamonds==7 and p.productReceipts==nil,'source untouched')
 check(R.validate(n,C),'valid persisted profile')
 local again,_,replay=Receipts.grant(n,receipt,R,fake)
 check(replay and again.wallet.diamonds==n.wallet.diamonds and again.revision==n.revision,'durable replay')
 receipt.PurchaseId='repeat-purchase-'..i
 check(Receipts.grant(n,receipt,R,fake).wallet.diamonds==7+amount*2,'repeat purchase allowed')
 local full=R.copy(p);full.wallet.diamonds=1e12-amount+1
 check(not Receipts.grant(full,receipt,R,fake),'cap never acknowledges lost reward')
end
local p=R.new(12)
local receipt={PlayerId=12,ProductId=8001,PurchaseId='paid'}
for _,bad in ipairs({{PlayerId=13,ProductId=8001,PurchaseId='x'},{PlayerId=12,ProductId=0,PurchaseId='x'},{PlayerId=12,ProductId=3728491648,PurchaseId='x'},{PlayerId=12,ProductId=8001,PurchaseId=''},{PlayerId=12,ProductId=8001,PurchaseId=1}})do check(not Receipts.grant(p,bad,R,fake),'bad receipt rejected')end
local paid=assert(Receipts.grant(p,receipt,R,fake))
check(not Receipts.grant(paid,{PlayerId=12,ProductId=8002,PurchaseId='paid'},R,fake),'ID collision cannot change product')
paid.operations={};paid.operationOrder={}
check(select(3,Receipts.grant(paid,receipt,R,fake)),'paid ledger independent of request eviction')
local bad=R.copy(paid);bad.productReceipts.paid.diamonds=-1
check(not R.validate(bad,C),'corrupt paid ledger rejected')
local now,data,lose,offline=10,nil,false,false
local adapter={UpdateAsync=function(_,_,fn)
 if offline then error('storage unavailable')end
 local n=fn(R.copy(data));if n then data=R.copy(n)end
 if lose then error('saved but reply lost')end
 return n and R.copy(n)
end}
local store=S.new(adapter,R,C,function()return now end,function()end,'server-a')
assert(store:open(12));lose=true
local n,e=store:transact(12,function(current)return Receipts.grant(current,receipt,R,fake)end)
check(not n and e=='SaveUnknown'and data.wallet.diamonds==100,'unknown save records one grant through retries')
lose=false
n,e=store:transact(12,function(current)return Receipts.grant(current,receipt,R,fake)end)
check(n and not e and n.wallet.diamonds==100,'retry reconciles saved grant')
local other=S.new(adapter,R,C,function()return now end,function()end,'server-b')
check(not other:open(12),'simultaneous server cannot steal lease')
assert(store:close(12));assert(other:open(12))
check(other:transact(12,function(current)return Receipts.grant(current,receipt,R,fake)end).wallet.diamonds==100,'rejoin does not duplicate')
check(not store:transact(12,function(current)return Receipts.grant(current,receipt,R,fake)end),'old server fenced')
local before=R.copy(data);offline=true
check(not other:open(12)and data.wallet.diamonds==before.wallet.diamonds,'load failure preserves paid balance')
print('diamond-products: '..checks..' checks passed')
