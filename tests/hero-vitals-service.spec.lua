-- Actual InventoryService + AccountStore; deterministic services, no live data.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local data,down,unknown={},false,false
local failRelease, onWrite, onCloseWait
local adapter={UpdateAsync=function(_,key,fn)
 if down then error('offline')end
 local p=fn(R.copy(data[key]));if p then data[key]=R.copy(p)end
 if failRelease and p and not p.lease then down=true;error('release reply lost')end
 if onWrite and p then onWrite(p) end
 if unknown then error('ack lost')end
 return R.copy(p)
end}
local function signal()return {Connect=function()end}end
local rs={Shared={ItemCatalog=C,HeroProgression=G,EconomyRules=dofile('src/shared/EconomyRules.luau')}}
local remotes={}
function rs:FindFirstChild(name)return name=='Remotes' and remotes end
local players={}
local tasks={}
local now,serial=100,0
local environment=setmetatable({
 script={Parent={InventoryRules=R,AccountStore=Store,ExplorationSaveBuffer=dofile('src/server/Inventory/ExplorationSaveBuffer.luau'),Parent={Lobby={DeliveryRules=dofile('src/server/Lobby/DeliveryRules.luau'),DeliveryCatalog=dofile('src/server/Lobby/DeliveryCatalog.luau')}}}},
 os={clock=os.clock,time=function()return now end},
 require=function(module)return module end,
 Instance={new=function()return {OnServerEvent=signal(),FireClient=function()end}end},
 task={spawn=function(fn)table.insert(tasks,fn)end,wait=function(seconds)
  if seconds==30 then coroutine.yield() end
  if seconds==.5 and onCloseWait then onCloseWait() end
 end},
 game={GameId=10773575153,GetService=function(_,name)return ({
  Players=players,RunService={IsStudio=function()return false end},ReplicatedStorage=rs,
  HttpService={GenerateGUID=function()serial=serial+1;return 'lease-'..serial end},
  DataStoreService={GetDataStore=function()return adapter end},
 })[name]end,BindToClose=function()end},
},{__index=_G})
local S=assert(loadfile('src/server/Inventory/InventoryService.luau','t',environment))()
local attrs={}
local player={UserId=725,Parent=players,SetAttribute=function(_,k,v)attrs[k]=v end}
local current={heroId='mage',health=31.25,mana=0,level=1}
local snapshots=0
S.start({prompts={},heroSession={getInventoryContext=function()return nil end,refresh=function()end},combat={snapshotVitals=function()
 snapshots=snapshots+1
 checkFrozen=not S.available(player)
 if current then return current.heroId,{health=current.health,mana=current.mana,level=current.level}end
end}})
local renewal=coroutine.create(assert(tasks[1]))
assert(coroutine.resume(renewal))
tasks={}
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function tick()
 assert(coroutine.resume(renewal))
 for _,fn in ipairs(tasks) do fn() end
 tasks={}
end
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
current.health,current.mana=11,2
down=true
check(not S.prepareTransfer(player),'save failure blocks departure')
check(data['account:725'].lease~=nil,'failed save retains account fence')
check(data['account:725'].heroes.mage.vitals.health==19,'failed save does not write defaults')
tick();check(not S.available(player),'continued outage keeps the account suspended')
now=now+121;down=false;tick()
check(S.available(player) and S.vitals(player,'mage').health==11 and S.vitals(player,'mage').mana==2,
 'same connection retries the original HP and MP after an unwritten snapshot')
check(S.prepareTransfer(player),'transfer retry succeeds after checkpoint recovery')
assert(S.resumeTransfer(player))
current.health,current.mana=9,0
local revisionBeforeUnknown=data['account:725'].revision
unknown=true
check(not S.prepareTransfer(player),'lost acknowledgement blocks teleport')
check(data['account:725'].lease~=nil,'unknown checkpoint cannot release fence')
check(data['account:725'].revision==revisionBeforeUnknown+1,'unacknowledged retries write the same checkpoint once')
unknown=false;tick()
check(S.available(player) and S.vitals(player,'mage').health==9 and S.vitals(player,'mage').mana==0,
 'same connection resolves committed HP and zero MP after a lost reply')
check(data['account:725'].revision==revisionBeforeUnknown+1,'acknowledgement recovery does not advance the checkpoint revision again')
check(S.prepareTransfer(player),'recovered checkpoint can depart safely')
assert(S.resumeTransfer(player))
current.health,current.mana=6,1
down=true;check(not S.prepareTransfer(player),'disconnect case starts with an unwritten checkpoint')
current=nil;S.close(player)
onCloseWait=function()onCloseWait=nil;down=false end
assert(#tasks==1);tasks[1]();tasks={}
check(not onCloseWait,'disconnect retries after the first checkpoint recovery attempt also fails')
check(not data['account:725'].lease,'disconnect persists pending vitals before releasing the account')
assert(S.open(player))
check(S.vitals(player,'mage').health==6 and S.vitals(player,'mage').mana==1,'reconnect restores pending HP and MP even after the character disappears')
down=true;tick();check(not S.available(player),'unconfirmed renewal suspends mutations')
now=now+121;down=false;tick()
check(S.available(player) and S.vitals(player,'mage').health==6,'same owner resumes after expiry and storage recovery')
local oldLease=data['account:725'].lease
S.close(player);S.close(player)
check(#tasks==1,'duplicate close schedules only one teardown')
local reconnect={UserId=player.UserId,Parent=players,SetAttribute=player.SetAttribute}
local _,busy=S.open(reconnect);check(busy=='AccountBusy','new connection waits for the old lease')
now=now+121
check(S.open(reconnect),'reconnect acquires expired lease')
local newLease=data['account:725'].lease
check(oldLease.token~=newLease.token and oldLease.epoch<newLease.epoch,'reconnect has a fresh token and epoch')
tasks[1]();tasks={}
check(data['account:725'].lease.token==newLease.token and S.available(reconnect),'late close cannot release a newer connection')
current={heroId='mage',health=7,mana=3,level=1}
check(not S.captureVitals(reconnect) and S.vitals(reconnect,'mage').health==7,'new owner can still save')

-- Run the production cancellation and account storage with a two-member departure.
local Departure=dofile('src/server/Network/ExpeditionDeparture.luau')
local file=assert(io.open('src/server/Network/ExpeditionService.luau'))
local networkSource=file:read('*a');file:close()
local first=assert(networkSource:find('local function recoverTravel',1,true))
local last=assert(networkSource:find('local function retryTravel',first,true))
local travel, delayed, refreshed={}, {},0
local other={UserId=726,Parent=players}
local partyStore={createRun=function(run)return run end,stageOffer=function()return true end,cancelRun=function()return true end}
local cancel=assert(load(networkSource:sub(first,last-1)..'return cancelTransfer','transfer cancellation','t',setmetatable({
 Players=players,travel=travel,parties={[reconnect]={id='party'}},admitted={},advertise=function()end,publish=function()end,
 o={inventory=S,heroSession={refresh=function()refreshed=refreshed+1 end}},
 task={delay=function(seconds,job)check(seconds==2,'cancellation backs off before retry');table.insert(delayed,job)end},
},{__index=_G})))()
local members={['725']={heroId='mage',ticket='first'},['726']={heroId='elf',ticket='second'}}
local function rejectedParty(id)
 return Departure.prepare(partyStore,{prepareTransfer=function(p)
  if p==reconnect then return S.prepareTransfer(p) end
  down=true;return false
 end},{reconnect,other},members,{id=id,ticket=id},cancel)
end
local releasedEpoch=data['account:725'].epoch
check(not rejectedParty('first-cancel'),'second member failure cancels the prepared party')
check(not S.available(reconnect) and attrs.TLTTravelLock and travel[reconnect] and #delayed==1,
 'prepared member stays locked during the first account reopen outage')
down=false;unknown=true;table.remove(delayed,1)()
check(not S.available(reconnect) and #delayed==1 and data['account:725'].epoch==releasedEpoch+1,
 'committed but unacknowledged reopen keeps the member locked without reclaiming twice')
unknown=false;table.remove(delayed,1)()
check(S.available(reconnect) and not attrs.TLTTravelLock and not travel[reconnect] and refreshed==1,
 'scheduled retry restores lobby controls on the same connection')
check(data['account:725'].epoch==releasedEpoch+1 and S.prepareTransfer(reconnect),'same account can depart again after cancellation')
assert(S.resumeTransfer(reconnect))

failRelease=true
check(not S.prepareTransfer(reconnect),'an unacknowledged lease release blocks teleport')
check(not S.available(reconnect) and not data['account:725'].lease,'unconfirmed release and reopen keep controls suspended')
failRelease=false;down=false;tick()
check(S.available(reconnect) and data['account:725'].lease,'local rollback retries the acknowledged reopen automatically')

check(S.prepareTransfer(reconnect),'prepare a transfer before disconnecting during its reopen')
onWrite=function(profile)
 if profile.lease then onWrite=nil;S.close(reconnect) end
end
check(not S.resumeTransfer(reconnect) and not S.available(reconnect),'disconnect during reopen never re-enables the old session')
assert(#tasks==1);tasks[1]();tasks={}
check(not data['account:725'].lease,'disconnect releases a lease reopened by the in-flight request')
assert(S.open(reconnect))

-- A delayed cancellation cannot take the account back after another owner releases it.
check(not rejectedParty('second-cancel') and #delayed==1,'new cancellation waits for a reopen')
down=false
local destination=Store.new(adapter,R,C,function()return now end,function()end,'destination')
assert(destination:open(reconnect.UserId));assert(destination:close(reconnect.UserId))
table.remove(delayed,1)()
check(not S.available(reconnect) and #delayed==0 and data['account:725'].release.token=='destination',
 'a cancellation cannot reopen a superseding epoch, even after that account was released')

S.close(reconnect);assert(S.open(reconnect))
current.health=4
down=true;check(not S.prepareTransfer(reconnect),'replacement-owner case starts with pending vitals')
down=false;now=now+121
local competing=Store.new(adapter,R,C,function()return now end,function()end,'remote-owner')
assert(competing:open(reconnect.UserId));tick()
check(not S.available(reconnect) and data['account:725'].lease.token=='remote-owner'
 and data['account:725'].heroes.mage.vitals.health==7,'pending checkpoint cannot overwrite a replacement owner')
print('Hero vitals service: '..n..' checks passed')
