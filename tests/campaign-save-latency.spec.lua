-- Actual service/reducers/fenced store; simulated slow storage, never live data.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local Buffer=dofile('src/server/Inventory/ExplorationSaveBuffer.luau')
local source=arg[1] or 'src/server/Inventory/InventoryService.luau'
local baseline=arg[2]=='baseline'
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local function fixture()
 local f={now=0,jobs={},writes=0,delay=0,unknown=false,offline=false,storyPending=false}
 local serial=0
 local function resume(co)
  local ok,seconds=coroutine.resume(co);assert(ok,seconds)
  if coroutine.status(co)~='dead' then
   serial=serial+1;table.insert(f.jobs,{co=co,at=f.now+(seconds or .01),serial=serial})
  end
 end
 function f.spawn(fn)resume(coroutine.create(fn))end
 function f.advance(seconds)
  local untilTime=f.now+seconds
  while true do
   table.sort(f.jobs,function(a,b)return a.at==b.at and a.serial<b.serial or a.at<b.at end)
   local job=f.jobs[1];if not job or job.at>untilTime then break end
   table.remove(f.jobs,1);f.now=job.at;resume(job.co)
  end
  f.now=untilTime
 end
 local adapter={UpdateAsync=function(_,_,fn)
  f.writes=f.writes+1
  if f.delay>0 then coroutine.yield(f.delay)end
  if f.offline then error('offline')end
  if f.replay then fn(R.copy(f.data))end -- UpdateAsync may discard a callback result.
  local p=fn(R.copy(f.data));if p then f.data=R.copy(p)end
  if f.unknown then error('ack lost')end
  return R.copy(p)
 end}
 local players={};local remotes={}
 local rs={Shared={ItemCatalog=C,HeroProgression=G,AdventureRules=A,
  CampaignModeProgress=dofile('src/shared/CampaignModeProgress.luau'),EconomyRules=dofile('src/shared/EconomyRules.luau'),Difficulty=dofile('src/shared/Difficulty.luau')}}
 function rs:FindFirstChild()return remotes end
 local env=setmetatable({
  script={Parent={InventoryRules=R,AccountStore=Store,ExplorationSaveBuffer=Buffer,
   Parent={Lobby={DeliveryRules=dofile('src/server/Lobby/DeliveryRules.luau'),DeliveryCatalog=dofile('src/server/Lobby/DeliveryCatalog.luau')}}}},
  os={clock=function()return f.now end,time=function()return 100+math.floor(f.now)end},
  require=function(module)assert(module,'missing fixture dependency');return module end,
  Instance={new=function()return {OnServerEvent={Connect=function()end},FireClient=function()end}end},
  task={spawn=f.spawn,wait=function(seconds)return coroutine.yield(seconds or .01)end},
  game={GameId=10773575153,GetService=function(_,name)return ({Players=players,ReplicatedStorage=rs,
   RunService={IsStudio=function()return false end},HttpService={GenerateGUID=function()return 'fixture-lease'end},
   DataStoreService={GetDataStore=function()return adapter end}})[name]end,BindToClose=function()end},
 },{__index=_G})
 local S=assert(loadfile(source,'t',env))()
 local attrs={K0SessionPhase='Tutorial'}
 local p={UserId=42,Parent=players,GetAttribute=function(_,k)return attrs[k]end,SetAttribute=function(_,k,v)attrs[k]=v end}
 S.start({prompts={},storyPending=function()return f.storyPending end,
  heroSession={getInventoryContext=function()return nil end,refresh=function()end},combat={}})
 assert(S.open(p));assert(S.createHero(p,'hero','knight')==nil)
 f.writes=0;f.S=S;f.player=p;f.attrs=attrs
 function f.reveal(x)S.reveal(p,'hero','DW-01',x,1)end
 function f.reward(amount)S.awardXP(p,'hero',amount or 1,true,2)end
 function f.story()
  f.storyPending=true
  f.spawn(function()
   while true do
    local reason=S.storyEvent(p,'hero','DW-01','trail_guards')
    if not reason then f.storyAt=f.now;f.storyPending=false;break end
    assert(reason=='Busy' or reason=='SaveUnknown',reason)
    coroutine.yield(1)
   end
  end)
 end
 return f
end

-- A map worker used to monopolize the account fence until every cell saved.
local f=fixture();f.delay=1.5
for x=1,6 do f.reveal(x)end
f.story();f.advance(14)
print(string.format('map + story: %.2fs, %d writes',assert(f.storyAt),f.writes))
check(f.S.storyState(f.player,'hero').flags['DW-01:trail_guards'],'story is durably advanced')
for x=1,6 do check(f.data.heroes.hero.deepwood.explored['DW-01'][tostring(x)],'all observed cells persist')end
if not baseline then check(f.storyAt<=1.5 and f.writes==1,'story saves first and includes all map cells')end

-- A simultaneous kill pack must not require one network round trip per kill.
f=fixture();f.delay=1.5
local gold=f.data.wallet.gold
for _=1,6 do f.reward()end
f.story();f.advance(14)
print(string.format('kills + story: %.2fs, %d writes',assert(f.storyAt),f.writes))
check(f.data.wallet.gold==gold+12 and f.data.heroes.hero.progression.rewardSequence==6,'six exact rewards')
if not baseline then check(f.storyAt<4 and f.writes==2,'pack and story need only two writes')end
if baseline then print('baseline reproduced');return end

f=fixture();f.delay=1.5;gold=f.data.wallet.gold
for _=1,6 do f.reward();f.advance(.1)end
f.story();f.advance(10)
print(string.format('staggered kills + story: %.2fs, %d writes',assert(f.storyAt),f.writes))
check(f.storyAt<6 and f.writes==3 and f.data.wallet.gold==gold+12,'kills arriving during a save form one subsequent batch')

f=fixture();f.replay=true;gold=f.data.wallet.gold
for x=1,6 do f.reveal(x);f.reward()end
f.story();f.advance(2)
check(f.storyAt and f.data.wallet.gold==gold+12,'repeated callbacks do not consume buffers or double rewards')

-- Failed acknowledgement: immutable batch retries; later kills are a new batch.
f=fixture();gold=f.data.wallet.gold;f.unknown=true
for _=1,6 do f.reward()end
f.advance(1.3)
check(not f.S.available(f.player),'unknown reward save blocks authority')
check(f.data.wallet.gold==gold+12,'ack loss never pays a batch twice')
f.unknown=false;f.advance(1.1)
check(f.S.available(f.player),'same batch recovers')
f.reward();f.advance(.1)
check(f.data.wallet.gold==gold+14 and f.data.heroes.hero.progression.rewardSequence==7,'new reward follows recovered batch')

-- In-flight map snapshot excludes new cells, preserves them for a later save.
f=fixture();f.delay=1;f.reveal(1);f.story();f.reveal(12);f.advance(1)
check(f.data.heroes.hero.deepwood.explored['DW-01']['1'],'snapshot cell committed')
check(not f.data.heroes.hero.deepwood.explored['DW-01']['12'],'late cell not consumed by old callback')
f.advance(5)
check(f.data.heroes.hero.deepwood.explored['DW-01']['12'],'late cell survives and flushes')

-- A background failure cannot overwrite the profile or allow travel until recovery.
f=fixture();f.reveal(1);f.unknown=true;f.advance(6.3)
check(not f.S.available(f.player),'unknown map save suspends authority')
f.unknown=false;f.advance(1.1)
check(f.S.available(f.player) and f.data.heroes.hero.deepwood.explored['DW-01']['1'],'idempotent map recovery')

-- New rewards cannot prevent recovery of an already submitted story write.
f=fixture();f.delay=.1;f.unknown=true;f.story();f.reward();f.advance(2)
check(not f.S.available(f.player),'in-flight story acknowledgement is unknown')
f.unknown=false;f.advance(4)
check(f.storyAt and f.S.available(f.player),'pending story recovers ahead of newly queued rewards')
check(f.data.heroes.hero.progression.rewardSequence==1,'reward queued during story save survives')

-- The batch freezes before the yielding request; arrivals during it are retained.
f=fixture();f.delay=1;gold=f.data.wallet.gold
for _=1,6 do f.reward()end
f.advance(.1);f.reward();f.advance(3)
check(f.writes==2 and f.data.wallet.gold==gold+14,'in-flight reward batch never consumes a later kill')

-- Large bursts are bounded and death remains between the surrounding rewards.
f=fixture();gold=f.data.wallet.gold
for _=1,33 do f.reward()end
f.advance(.1)
check(f.writes==2 and f.data.wallet.gold==gold+66,'reward batches are bounded to 32')
f=fixture();for _=1,6 do f.reward()end
f.S.penalizeDeath(f.player,'hero','death_1',false);f.reward();f.advance(.1)
check(f.writes==3 and f.attrs.TLTDeathXPState=='Saved','death is not reordered across reward batches')
check(f.data.heroes.hero.progression.rewardSequence==7,'death preserves reward stream order')

-- Actual expedition receipts still reject duplicate kill rewards after batching.
f=fixture();assert(f.S.beginExpedition(f.player,'hero','DW-01','Easy','run_1')==nil)
gold=f.data.wallet.gold;f.writes=0
for _,id in ipairs({'trail_guards_1','trail_guards_2','trail_guards_1'})do
 f.S.awardXP(f.player,'hero',1,true,2,'run_1',id)
end
check(f.S.beginExpedition(f.player,'hero','DW-01','Easy','run_2')=='Busy','run cannot change before buffered kill receipts save')
f.advance(.1)
check(f.writes==1 and f.data.wallet.gold==gold+4,'duplicate kill receipt pays only once')
check(f.data.heroes.hero.progression.rewardSequence==3,'duplicate kill consumes its sequence')

-- Failure before commit retains all observations; no new/default profile appears.
f=fixture();f.reveal(1);f.offline=true;f.story();f.advance(1.3)
check(not f.S.available(f.player) and not f.S.storyState(f.player,'hero').flags['DW-01:trail_guards'],'failed save never advances story')
f.offline=false;f.advance(1.1)
check(f.storyAt and f.data.heroes.hero.deepwood.explored['DW-01']['1'],'retry retains pending map observations')

-- Close/transfer flush every pending cell/reward without double-removing jobs.
for _,operation in ipairs({'close','prepareTransfer'})do
 f=fixture();gold=f.data.wallet.gold
 for x=1,6 do f.reveal(x);f.reward()end
 f.S[operation](f.player);f.advance(.1)
 check(not f.data.lease,operation..' releases only after flush')
 check(f.data.wallet.gold==gold+12,operation..' preserves queued rewards')
 for x=1,6 do check(f.data.heroes.hero.deepwood.explored['DW-01'][tostring(x)],operation..' preserves cell')end
end
print('Campaign save latency: '..checks..' checks passed')
