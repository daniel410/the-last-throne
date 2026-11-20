-- Production arrival, renewal and phase handlers, driven by a virtual clock.
local file=assert(io.open('src/server/Network/ExpeditionService.luau'))
local source=file:read('*a');file:close()
local function slice(first,last)
 local a=assert(source:find(first,1,true))
 local b=assert(source:find(last,a+1,true))
 return (source:sub(a,b-1):gsub('(%w+)%+=1','%1=%1+1'))
end
local code=slice('local function count','local function sourceValid')
 ..slice('function Service.admitArrival','local function startRunLocked')
 ..slice('local function prepareBattleArrival','local function maintainParty')
 ..'return {renew=renewBattleLease,refresh=refreshBattleLocks}'
local checks=0
local function check(condition,message)checks=checks+1;assert(condition,message)end
local function fixture(partySize)
 local f={now=0,jobs={},members={},players={},prepared={},offers=0,entered=0,battleReady=0}
 local serial=0
 local function schedule(at,co,...)
  serial=serial+1
  f.jobs[#f.jobs+1]={at=at,co=co,args=table.pack(...),serial=serial}
 end
 function f.advance(untilTime)
  while true do
   table.sort(f.jobs,function(a,b)return a.at==b.at and a.serial<b.serial or a.at<b.at end)
   local nextJob=f.jobs[1]
   if not nextJob or nextJob.at>untilTime then break end
   table.remove(f.jobs,1);f.now=nextJob.at
   local ok,wait=coroutine.resume(nextJob.co,table.unpack(nextJob.args,1,nextJob.args.n))
   assert(ok,wait)
   if coroutine.status(nextJob.co)~='dead' then schedule(f.now+wait,nextJob.co)end
  end
  f.now=untilTime
 end
 local players={}
 for i=1,partySize do
  local attrs={K0SessionPhase='LoadingLobby'}
  f.members[tostring(i)]={heroId='knight',ticket='t'..i}
  f.players[i]={UserId=i,Parent=players,attrs=attrs,
   GetAttribute=function(_,name)return attrs[name]end,SetAttribute=function(_,name,value)attrs[name]=value end,
   GetJoinData=function()return {TeleportData={runId='sm2_run',ticket='t'..i}}end,
   Kick=function(_,message)f.kicked=message end,profileReady=false}
 end
 local function run(ownerUntil)
  return {id='sm2_run',ownerJob='job',ownerUntil=ownerUntil,placeId=2,rulesVersion=19,
   missionId='DW-01',difficultyId='Easy',members=f.members}
 end
 local env=setmetatable({Players=players,Service={},role='Battle',job='job',runHealthy=true,battleOpened=false,renewing=false,nextRenewal=0,seatCount=0,
  seats={},admitted={},preparedArrivals={},verifying={},travel={},game={PrivateServerId='private',PrivateServerOwnerId=0,PlaceId=2},
  sourceValid=function()return true end,C={battleCapacity=4},Content={byId={['DW-01']={}}},
  Backend={select=function(s)return s end,isCurrent=function()return true end},
  Difficulty={compatible=function()return true end,modes={Easy=true},verifyRun=function(hero)return hero and hero.verified end},
  Adventure={projection=function(hero)return {expeditionMission=hero.chapter}end},
  os={clock=function()return f.now end,time=function()return math.floor(100+f.now)end},
  task={defer=function(fn,...)schedule(f.now,coroutine.create(fn),...)end,spawn=function(fn)schedule(f.now,coroutine.create(fn))end,
   delay=function(s,fn)schedule(f.now+s,coroutine.create(fn))end,wait=function(s)coroutine.yield(s)end},
  warn=function(message)f.warning=message end,
 },{__index=_G})
 local api=assert(load(code,'production battle arrival','t',env))()
 env.currentStore={
  admit=function()return run(env.os.time()+90)end,
  departure=function()return true end,
  offer=function()
   f.offers=f.offers+1
   if f.offerDelay then env.task.wait(f.offerDelay)end
   if f.offerUnavailable then return nil,'NetworkUnavailable'end
   return true
  end,
  renewRun=function()
   if f.renewDelay then env.task.wait(f.renewDelay)end
   if f.renewError then return nil,f.renewError end
   return run(env.os.time()+90)
  end,
 }
 env.o={
  inventory={ready=function(p)return p.profileReady end,expeditionHero=function(p)return p.profileReady and p.hero end,
   beginExpedition=function(p)f.writes=(f.writes or 0)+1;p.hero.verified=true end},
  heroSession={enterAdventure=function(p)
   f.entered=f.entered+1;p.attrs.K0SessionPhase='LoadingTutorial';env.Service.sessionChanged(p)
   env.task.delay(.1,function()p.attrs.K0SessionPhase='Tutorial';env.Service.sessionChanged(p)end)
  end},
  warmStoryEnemies=function(p,chapterId,journal)
   assert(journal.expeditionMission==chapterId)
   f.warmup={player=p,chapter=chapterId,at=f.now}
  end,
  previewWorld=function(chapterId)
   f.prepared[#f.prepared+1]=chapterId
   env.task.wait(f.worldDelay or 1)
   if f.worldFailed then error('world build failed')end
  end,
  onBattleReady=function()f.battleReady=f.battleReady+1;f.readyAt=f.now end,
 }
 f.env,f.api,f.service=env,api,env.Service
 function f.profile(index,chapter,verified)
  local p=f.players[index];p.hero={chapter=chapter,verified=verified~=false};p.profileReady=true;p.attrs.K0SessionPhase='Lobby'
  f.service.sessionChanged(p)
 end
 return f
end

local f=fixture(1);local p=f.players[1]
f.worldDelay,f.offerDelay=4,.5
check(f.service.admitArrival(p).heroId=='knight','admission records the validated ticket without generating the launch area')
check(#f.prepared==0 and p.attrs.TLTTravelLock,'unverified profile stays at the arrival platform')
check(not f.warmup,'unverified arrivals do not request story assets')
f.advance(.25);f.profile(1,'HG-03')
f.advance(.25)
check(f.prepared[1]=='HG-03' and #f.prepared==1,'a saved continuation builds only the confirmed destination')
check(f.warmup and f.warmup.player==p and f.warmup.chapter=='HG-03' and f.warmup.at==.25,'resume warms the verified chapter during preparation')
check(f.offers==1,'rejoin promotion starts alongside the region preparation')
f.service.sessionChanged(p);f.advance(.5)
check(f.offers==1 and f.entered==0,'a repeated phase event cannot duplicate promotion or spawn early')
f.advance(4.3)
check(f.entered==1 and p.attrs.TLTTravelLock,'ready geometry starts the character without a polling interval')
f.advance(4.36)
check(not p.attrs.TLTTravelLock and f.battleReady==1 and f.readyAt<4.36,'ready character immediately unlocks and publishes story/encounter work')
check(#f.prepared==1 and f.offers==1,'only one region prepare and one rejoin promotion')

f.renewError='NetworkUnavailable'
f.advance(20);f.api.renew();f.advance(20)
check(not p.attrs.TLTTravelLock and f.battleReady==1,'temporary renewal failure keeps the last valid lease and avoids a mid-story relock')
check(f.env.nextRenewal==22,'transient renewal retries on the short cadence')
f.advance(22);f.api.renew();f.advance(22)
f.advance(90)
check(p.attrs.TLTTravelLock,'an unconfirmed renewal cannot extend the lease')
f.renewError=nil;f.api.renew();f.advance(90)
check(not p.attrs.TLTTravelLock and f.battleReady==2,'confirmed recovery reopens the current story immediately')
f.renewError='RejoinExpired';f.advance(110);f.api.renew();f.advance(110)
check(p.attrs.TLTTravelLock,'explicit ownership loss locks even before the previous lease expires')

f=fixture(1);p=f.players[1]
f.service.admitArrival(p);f.profile(1,'DW-01',false)
f.advance(1.2)
check(f.writes==1 and f.prepared[1]=='DW-01' and not p.attrs.TLTTravelLock,'a newly staged journal is saved before the first encounter starts')

f=fixture(2);p=f.players[1]
f.service.admitArrival(p);f.profile(1,'DW-01')
f.advance(2)
check(p.attrs.TLTTravelLock,'first arrival observes the existing party grace period')
f.service.admitArrival(f.players[2]);f.advance(2)
check(not p.attrs.TLTTravelLock,'last validated admission wakes the ready hero')
f.env.admitted[f.players[2]]=nil;f.api.refresh()
check(not p.attrs.TLTTravelLock,'a disconnect cannot restart the initial party wait')

f=fixture(2);p=f.players[1]
f.service.admitArrival(p);f.profile(1,'DW-01')
f.advance(29.9);check(p.attrs.TLTTravelLock,'incomplete party stays gated before the deadline')
f.advance(30);check(not p.attrs.TLTTravelLock,'party grace expires without a poll')

f=fixture(1);p=f.players[1];f.worldFailed=true
f.service.admitArrival(p);f.profile(1,'DW-01');f.advance(3)
check(f.kicked and f.entered==0 and p.attrs.TLTTravelLock,'failed world preparation never exposes a partial region')

f=fixture(1);p=f.players[1];f.offerUnavailable=true
f.service.admitArrival(p);f.profile(1,'DW-01');f.advance(2)
check(f.entered==0 and p.attrs.TLTTravelLock,'unknown promotion response does not unlock admission')
local previousOffers=f.offers
f.offerUnavailable=false;f.service.sessionChanged(p);f.advance(2.2)
check(f.entered==1 and #f.prepared==1 and f.offers==previousOffers+1,'promotion retries the same prepared world')

f=fixture(1);p=f.players[1];f.worldDelay=.2;f.offerDelay=1
f.service.admitArrival(p);f.profile(1,'DW-01');f.advance(.5)
check(f.entered==0 and f.offers==1,'ready geometry cannot race ahead of an in-flight promotion')
f.advance(1.2);check(not p.attrs.TLTTravelLock and f.entered==1,'the slow promotion wakes the already prepared destination')

f=fixture(1);p=f.players[1]
f.service.admitArrival(p);f.profile(1,'DW-01');f.advance(89)
f.renewDelay=3;f.api.renew();f.advance(90)
check(p.attrs.TLTTravelLock and f.env.renewing,'a renewal still in flight does not keep an expired lease alive')
f.advance(92)
check(not p.attrs.TLTTravelLock,'only the eventual confirmed lease reopens play')
print('Expedition arrival latency: '..checks..' checks passed')
