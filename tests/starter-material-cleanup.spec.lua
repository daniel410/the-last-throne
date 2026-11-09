local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local Atlas=dofile('src/shared/ItemSpriteAtlas.luau')
local count=0
local function check(v,label)count=count+1;assert(v,label)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function hides(p)local n=0;for _,item in pairs(p.items)do if item.definitionId=='soft_hide'then n=n+item.quantity end end;return n end
local p=R.new(42)
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 p=assert(R.addHero(p,class,class,C))
 check(R.quantity(p,class,'iron_ore')==10,'each new hero receives ten Ore once')
 check(hides(p)==0,'no new hero receives Soft Hide')
 check(R.equipped(p,class,'weapon').definitionId==class..'_weapon_traveler','real starter weapon remains equipped')
 check(R.validate(p,C),'new profile remains valid')
end
local before=R.copy(p);local no,why=R.addHero(p,'knight','knight',C)
check(not no and why=='RequestConflict'and equal(p,before),'duplicate creation cannot refill supplies')
check(not F.grant(p,R,C,'knight','soft_hide',8,'no-new-hide')and hides(p)==0,'generic grant rejects retired material')
check(C.items.soft_hide.retired==true,'old definition remains decode-only')
for _,value in pairs(Atlas)do if type(value)=='table'then check(value.soft_hide==nil,'retired icon absent from active atlas')end end
-- Valid legacy stacks, including locked and character-bound stacks in all legal locations.
local locations={{kind='bag',heroId='knight'},{kind='bag',heroId='mage'},{kind='storage'},{kind='pending'}}
for i,location in ipairs(locations)do
 local id='legacy-hide-'..i
 p.items[id]={instanceId=id,definitionId='soft_hide',definitionVersion=C.version,ownerUserId=42,quantity=i*8,version=1,binding=i==2 and 'character'or 'account',boundHeroId=i==2 and 'mage'or nil,locked=i%2==0,location=location,sourceGrantId='legacy'}
end
for _,item in pairs(p.items)do if item.definitionId=='iron_ore'and item.location.heroId=='knight'then item.quantity=24 end end
p.wallet.gold=987;p.wallet.diamonds=76
check(R.validate(p,C),'old stacks pass pre-migration validation')
local expected=R.copy(p)
for id,item in pairs(expected.items)do if item.definitionId=='soft_hide'then expected.items[id]=nil end end
expected.revision=expected.revision+1
local migrated=R.upgrade(R.copy(p))
check(hides(migrated)==0 and equal(migrated,expected),'migration only removes all retired stacks and advances revision once')
check(R.quantity(migrated,'knight','iron_ore')==24,'already-owned Ore is preserved')
check(R.quantity(migrated,'mage','iron_ore')==10,'other hero Ore is preserved')
check(equal(R.upgrade(R.copy(migrated)),migrated),'repeated migration does not refill, debit or change revision')
check(R.validate(migrated,C),'cleaned profile remains valid')
-- Material/creation receipts never restore consumed Ore or removed Hide.
local ore;for _,item in pairs(migrated.items)do if item.definitionId=='iron_ore'and item.location.heroId=='mage'then ore=item end end
ore.quantity=2
check(R.quantity(R.upgrade(R.copy(migrated)),'mage','iron_ore')==2,'rejoin never tops up consumed starting Ore')
-- Actual AccountStore performs validation before upgrade and saves cleanup atomically.
local saved=R.copy(p);local lose=true
local adapter={UpdateAsync=function(_,_,fn)
 fn(R.copy(saved));local n=fn(R.copy(saved));if n then saved=R.copy(n)end
 if lose then error('reply lost after commit')end;return n
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'cleanup-session')
no,why=store:open(42)
check(not no and why=='SaveUnknown','unknown cleanup response is not treated as an empty account')
check(hides(saved)==0 and saved.wallet.gold==987 and R.quantity(saved,'knight','iron_ore')==24,'committed cleanup preserves other rights during lost response')
lose=false;local loaded=assert(store:open(42))
check(hides(loaded)==0 and loaded.revision==expected.revision,'retry opens same cleaned profile without repeated migration')
check(store:close(42)~=nil,'lease closes after cleanup')
loaded=assert(store:open(42));check(hides(loaded)==0 and loaded.wallet.diamonds==76,'cleanup persists through reconnect')
local original=R.copy(p)
local broken=Store.new({UpdateAsync=function()error('read unavailable')end},R,C,function()return 100 end,function()end,'broken')
no,why=broken:open(42);check(not no and why=='SaveUnknown'and equal(original,p),'failed load never replaces legacy data or creates new supplies')
local busy=R.copy(p);busy.lease={token='other-server',epoch=busy.epoch,expiresAt=200}
local blocked=Store.new({UpdateAsync=function(_,_,fn)return fn(R.copy(busy))end},R,C,function()return 100 end,function()end,'blocked')
no,why=blocked:open(42);check(not no and why=='AccountBusy'and hides(busy)>0,'cleanup cannot bypass another active lease')
print('Starter material cleanup: '..count..' checks passed')
