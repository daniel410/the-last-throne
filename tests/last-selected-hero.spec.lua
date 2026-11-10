-- Actual account store/reducers and InventoryService bodies, with an in-memory adapter.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0
local function check(v,m) checks=checks+1;assert(v,m) end
local data,fail,unknownAfterCommit,writes=nil,false,false,0
local adapter={}
function adapter:UpdateAsync(_,fn)
 writes=writes+1
 if fail then error('offline') end
 local result=fn(R.copy(data))
 if result then data=R.copy(result) end
 if unknownAfterCommit then error('response lost after commit') end
 return result
end
local function store(token) return Store.new(adapter,R,C,function()return 100 end,function()end,token) end
local first=store('first')
local p=assert(first:open(42))
for _,class in ipairs({'elf','dwarf','knight','mage'}) do
 p=assert(first:transact(42,function(current)return R.addHero(current,'hero-'..class,class,C)end))
 check(p.lastSelectedHeroId=='hero-'..class,'creation atomically remembers new '..class)
end
local original=R.copy(p)
local selected=assert(R.selectHero(p,'hero-dwarf'))
check(p.lastSelectedHeroId==original.lastSelectedHeroId,'selection reducer preserves input')
check(selected.revision==p.revision+1 and R.validate(selected,C),'selection increments revision and remains valid')
check(R.selectHero(selected,'hero-dwarf').revision==selected.revision,'same selection replay is idempotent')
for _,bad in ipairs({'foreign',false,{}}) do
 local result,reason=R.selectHero(p,bad);check(result==nil and reason=='HeroNotOwned','invalid ownership cannot write')
end
local f=assert(io.open('src/server/Inventory/InventoryService.luau'));local source=f:read('*a');f:close()
local function body(a,b) local i=assert(source:find(a,1,true));return source:sub(i,assert(source:find(b,i+1,true))-1)end
local player={UserId=42};local players={};player.Parent=players
function player:SetAttribute()end
local accounts={}
local service={ready=function(person)local s=accounts[person];return s and s.valid and not s.busy end}
local env=setmetatable({Service=service,accounts=accounts,store=first,Rules=R,Players=players,sessionOnly=false,publish=function()end},{__index=_G})
assert(load(body('function Service.open(', 'function Service.close('),'open','t',env))()
assert(load(body('function Service.selectHero(', 'function Service.stats('),'selectHero','t',env))()
service.open(player)
check(service.selectHero(player,'hero-dwarf')==nil,'service saves owned dwarf')
local count=writes
check(service.selectHero(player,'hero-dwarf')==nil and writes==count,'unchanged selection avoids a datastore write')
local _,reason=R.selectHero(data,'foreign')
check(service.selectHero(player,'foreign')==reason and writes==count,'service rejects foreign hero before storage')
assert(first:close(42))
local second=store('second');env.store=second
local roster,err,id=service.open(player)
check(roster['hero-dwarf'] and err==nil and id=='hero-dwarf','new server opens durable last hero')
check(data.wallet.gold==original.wallet.gold and data.heroes['hero-mage'].baseClassId=='mage','selection preserves wallet and roster')
fail=true
check(service.selectHero(player,'hero-knight')=='SaveUnknown','failed write reports uncertainty')
check(not accounts[player].valid and data.lastSelectedHeroId=='hero-dwarf','failure blocks inventory without replacing stored profile')
fail=false;service.open(player)
unknownAfterCommit=true
check(service.selectHero(player,'hero-knight')=='SaveUnknown','lost responses are not reported as confirmed selection')
unknownAfterCommit=false
local revision=data.revision
local _,_,recovered=service.open(player)
check(recovered=='hero-knight' and data.revision==revision,'reopen recovers committed preference without duplicate revision')
check(service.selectHero(player,'hero-knight')==nil and data.revision==revision,'replay after recovery remains idempotent')
assert(second:close(42))
-- Old accounts have no historical preference; opening must not invent one or erase progress.
data.lastSelectedHeroId=nil
local third=store('third');env.store=third
local legacy,legacyError,legacyId=service.open(player)
check(legacy and not legacyError and legacyId==nil,'legacy profile without preference opens intact')
print('Last selected hero: '..checks..' checks PASS')
