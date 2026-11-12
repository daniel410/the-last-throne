-- Actual InventoryService + AccountStore; deterministic services, no live data.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local data,down,unknown={},false,false
local adapter={UpdateAsync=function(_,key,fn)
 if down then error('offline')end
 local p=fn(R.copy(data[key]));if p then data[key]=R.copy(p)end
 if unknown then error('ack lost')end
 return R.copy(p)
end}
local function signal()return {Connect=function()end}end
local rs={Shared={ItemCatalog=C,HeroProgression=G,EconomyRules=dofile('src/shared/EconomyRules.luau')}}
local remotes={}
function rs:FindFirstChild(name)return name=='Remotes' and remotes end
local players={}
local tasks={}
local environment=setmetatable({
 script={Parent={InventoryRules=R,AccountStore=Store}},
 require=function(module)return module end,
 Instance={new=function()return {OnServerEvent=signal(),FireClient=function()end}end},
 task={spawn=function(fn)table.insert(tasks,fn)end,wait=function()end},
 game={GameId=10773575153,GetService=function(_,name)return ({
  Players=players,RunService={IsStudio=function()return false end},ReplicatedStorage=rs,
  HttpService={GenerateGUID=function()return 'test-token'end},
  DataStoreService={GetDataStore=function()return adapter end},
 })[name]end,BindToClose=function()end},
},{__index=_G})
local S=assert(loadfile('src/server/Inventory/InventoryService.luau','t',environment))()
local attrs={}
local player={UserId=725,Parent=players,SetAttribute=function(_,k,v)attrs[k]=v end}
local current={heroId='mage',health=31.25,mana=0,level=1}
local snapshots=0
S.start({prompts={},heroSession={getInventoryContext=function()return nil end},combat={snapshotVitals=function()
 snapshots=snapshots+1
 checkFrozen=not S.available(player)
 if current then return current.heroId,{health=current.health,mana=current.mana,level=current.level}end
end}})
-- Discard only the background renewal loop; run close jobs explicitly below.
tasks={}
local n=0;local function check(v,m)n=n+1;assert(v,m)end
check(S.open(player)~=nil,'account opens')
assert(S.createHero(player,'mage','mage')==nil)
check(S.prepareTransfer(player),'saved checkpoint permits departure')
check(checkFrozen,'combat frozen before transfer snapshot')
check(not data['account:725'].lease,'only saved checkpoint releases fence')
check(data['account:725'].heroes.mage.vitals.health==31.25 and data['account:725'].heroes.mage.vitals.mana==0,'depleted values committed before departure')
check(not S.available(player),'prepared transfer disables combat')
local captures=snapshots;S.close(player)
check(snapshots==captures,'departed close cannot overwrite checkpoint')
assert(S.open(player))
local v=S.vitals(player,'mage');v.health=999
check(S.vitals(player,'mage').health==31.25,'checkpoint read is isolated')
current=nil
check(S.prepareTransfer(player),'lobby departure with no combat state succeeds')
check(data['account:725'].heroes.mage.vitals.health==31.25,'lobby placeholder never overwrites battle resources')
check(S.resumeTransfer(player),'failed teleport reacquires account')
current={heroId='mage',health=19,mana=3,level=1}
S.close(player);check(checkFrozen,'disconnect freezes combat before snapshot')
assert(#tasks==1);tasks[1]();tasks={}
assert(S.open(player))
check(S.vitals(player,'mage').health==19,'disconnect and reconnect preserve checkpoint')
current.health=11
down=true
check(not S.prepareTransfer(player),'save failure blocks departure')
check(data['account:725'].lease~=nil,'failed save retains account fence')
check(data['account:725'].heroes.mage.vitals.health==19,'failed save does not write defaults')
down=false
assert(S.open(player))
unknown=true
check(not S.prepareTransfer(player),'lost acknowledgement blocks teleport')
check(data['account:725'].lease~=nil,'unknown checkpoint cannot release fence')
unknown=false;assert(S.open(player))
check(S.vitals(player,'mage').health==11,'reconnect recovers committed unknown checkpoint')
check(S.prepareTransfer(player),'recovered checkpoint can depart safely')
print('Hero vitals service: '..n..' checks passed')
