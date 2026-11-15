local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local T=dofile('src/shared/EquipmentTransactions.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local p=R.new(42)
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 p=assert(R.addHero(p,class,class,C))
 check(R.quantity(p,class,'veteran_hood')==0,'no free Veteran headgear for '..class)
end
-- Simulate old starter items moved between heroes, storage, and pending rewards.
local locations={{kind='bag',heroId='mage'},{kind='storage'},{kind='pending'},
 {kind='equipped',heroId='knight',slot='head'}}
local head=R.equipped(p,'knight','head');head.location={kind='storage'}
for i,loc in ipairs(locations)do
 local prefix='old-free-'..i
 assert(T.grant(p,R,C,'knight','veteran_hood',1,prefix))
 local item=p.items[prefix..'-1']
 item.sourceGrantId='starter:knight';item.location=loc;item.locked=true;item.enhancementLevel=9
end
assert(T.grant(p,R,C,'mage','veteran_hood',1,'quest-owned'))
p.wallet.gold=10000;p.wallet.diamonds=10000
for _,offer in ipairs({'veteran_hood','veteran_hood_diamond'})do
 p=assert(R.shop(p,{store=offer:find('diamond') and 'diamonds' or 'blacksmith',action='Buy',requestId=offer,heroId='mage',revision=p.revision,offerId=offer},{atLobby=true},C))
end
local expected=R.copy(p.items)
for i=1,4 do expected['old-free-'..i..'-1']=nil end
check(R.validate(p,C),'legacy profile validates before migration')
local db=R.copy(p);local fail=true
local adapter={UpdateAsync=function(_,_,fn)
 fn(R.copy(db)) -- Callback retry must be safe.
 local nextProfile=fn(R.copy(db));if nextProfile then db=R.copy(nextProfile)end
 if fail then error('response lost')end
 return nextProfile
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'headgear-session')
local opened,why=store:open(42)
check(not opened and why=='SaveUnknown','uncertain save never opens a blank profile')
check(same(db.items,expected),'removes all free locations/locks/enhancements and preserves every other item')
check(same(db.wallet,p.wallet)and same(db.operations,p.operations),'wallet and purchase receipts survive')
check(R.validate(db,C),'removed equipped headgear leaves a valid empty slot')
local busy=Store.new(adapter,R,C,function()return 100 end,function()end,'other-session')
fail=false
local rejected,reason=busy:open(42)
check(not rejected and reason=='AccountBusy','concurrent session cannot overwrite migration')
opened=assert(store:open(42))
check(same(R.upgrade(R.copy(opened),C),opened),'migration is idempotent after response loss')
assert(store:close(42));opened=assert(store:open(42))
check(same(opened.items,expected),'reconnect never reissues free Veteran headgear')
check(R.quantity(opened,'mage','veteran_hood')==3,'quest and both currency purchases stay owned')
print('Starter Veteran removal: '..checks..' checks passed')
