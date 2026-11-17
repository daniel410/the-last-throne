-- A fixed backend per run; a failed HashMap cannot block a new SortedMap departure.
local B=dofile('src/server/Network/ExpeditionBackend.luau')
local S=dofile('src/server/Network/ExpeditionStore.luau')
local Departure=dofile('src/server/Network/ExpeditionDeparture.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local C=dofile('src/shared/ExpeditionConfig.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local now=100
local function adapter()
 local m={db={},reads=0,writes=0,broken=false,unknown=false}
 function m:GetAsync(key)self.reads=self.reads+1;if self.broken then error('InternalError: Unknown Error.')end;return R.copy(self.db[key])end
 function m:UpdateAsync(key,fn)
  self.writes=self.writes+1;if self.broken then error('InternalError: Unknown Error.')end
  local v=fn(R.copy(self.db[key]));if v then self.db[key]=R.copy(v)end
  if self.unknown then error('lost committed reply')end
  return R.copy(v)
 end
 return m
end
local sorted,hash=adapter(),adapter()
local current,legacy=S.new(sorted,function()return now end,C),S.new(hash,function()return now end,C)
local id=B.newId('run');check(id=='sm2_run'and #B.newId(string.rep('a',32))<=64,'versioned IDs fit wire limit')
check(B.select(current,legacy,id)==current,'new authority is always SortedMap')
check(B.select(current,legacy,'historic')==legacy,'historic authority is always HashMap')
check(B.select(current,nil,'studio')==current,'isolated Studio can use one adapter')
local p=assert(R.addHero(R.new(1),'hero','knight',Items))
p=assert(A.begin(p,'hero','DW-01','Easy','historic',p.revision,R,Items,17))
local original=R.copy(p)
local old=assert(legacy.createRun({id='historic',ticket='old-master',members={['1']={heroId='hero',ticket='old-ticket'}}}))
assert(legacy.offer(1,old,'hero','old-ticket',true))
hash.broken=true
local closed=false
local inventory={prepareTransfer=function()closed=true;return true end}
local version=A.departureVersion(p.heroes.hero,'DW-01','Easy')
local run={id=id,ticket='master',reservedId='reserved',placeId=123,missionId='DW-01',difficultyId='Easy',rulesVersion=version,members={['1']={heroId='hero',ticket='ticket'}}}
local manifest,why=Departure.prepare(current,inventory,{{UserId=1}},run.members,run,function()closed=false end)
check(manifest and not why and closed,'new departure prepares during total HashMap outage')
check(hash.writes==2 and hash.reads==0,'new departure never reads/writes legacy backend')
check(p.revision==original.revision and p.heroes.hero.expeditions.active.runId=='historic','preparation leaves durable checkpoint intact')
local missing,errorCode=B.rejoin(current,legacy,1,function()return 'historic'end)
check(not missing and errorCode=='NetworkUnavailable','unknown legacy read remains unavailable rather than fabricated rights')
check(B.select(current,legacy,id).admit(id,1,'ticket','battle'),'new pending ticket admits despite broken legacy service')
check(not current.admit(id,2,'ticket','battle'),'new ticket cannot admit a different user')
check(not current.admit(id,1,'wrong','battle'),'forged ticket stays rejected')
check(not current.admit(id,1,'ticket','other'),'concurrent battle owner stays fenced')
check(current.departure(1,id,'ticket'),'new server-stage authority permits destination begin')
p=assert(A.begin(p,'hero','DW-01','Easy',id,p.revision,R,Items,version))
check(D.verifyRun(p.heroes.hero,manifest),'destination journal and fixed manifest agree')
local reads=hash.reads
check(B.rejoin(current,legacy,1,function()return id end).runId==id,'unknown promotion recovers from durable active run')
check(hash.reads==reads,'current capability recovery never falls back to failed HashMap')
check(current.offer(1,manifest,'hero','ticket',true),'new capability promotes')
check(B.rejoin(current,legacy,1).runId==id,'normal new rejoin remains available')
check(current.finish(1,id,'ticket'),'intentional return finishes current capability')
local offer,reason=B.rejoin(current,legacy,1)
check(not offer and reason=='RejoinExpired'and hash.reads==reads,'finished current capability cannot resurrect legacy rights')
sorted.broken=true
local writes=hash.writes
check(not current.createRun({id=B.newId('unknown'),ticket='m'}),'new backend failure fails closed')
check(hash.writes==writes,'failed current write cannot be redirected to legacy authority')
local _,readError=B.rejoin(current,legacy,1)
check(readError=='NetworkUnavailable'and hash.reads==reads,'current read outage cannot reveal superseded legacy rights')
sorted.broken=false;hash.broken=false
check(B.select(current,legacy,'historic')==legacy,'backend selection does not change when health recovers')
-- A failed new preparation preserves the historic capability in its original store.
local sorted2=adapter();local current2=S.new(sorted2,function()return now end,C)
local failed=R.copy(run);failed.id=B.newId('failed');failed.ticket='failed-master'
check(not Departure.prepare(current2,{prepareTransfer=function()return false end},{{UserId=1}},failed.members,failed,function()end),'failed transfer cancels only new run')
check(B.rejoin(current2,legacy,1,function()return 'historic'end).runId=='historic','uncommitted new attempt preserves old rejoin when legacy is available')
check(not current2.admit(failed.id,1,'ticket','battle'),'cancelled current manifest stays rejected')
local oldAgain=legacy.readRun('historic');check(oldAgain and not oldAgain.closed,'historic run was never cancelled/copied')
-- An update response can be lost after commit; retries stay in the same backend.
local sorted3=adapter();local current3=S.new(sorted3,function()return now end,C)
sorted3.unknown=true
local unknown={id=B.newId('lost'),ticket='stable',members={}}
check(not current3.createRun(unknown),'unknown committed response reported as unavailable')
sorted3.unknown=false
check(current3.createRun(unknown).id==unknown.id,'same ID/ticket retries original committed record')
check(hash.writes==writes,'lost replies never create an alternate authority')
-- Execute the production arrival block: legacy tickets may resume only the saved run.
local f=assert(io.open('src/server/Network/ExpeditionService.luau'));local service=f:read('*a');f:close()
local first=assert(service:find("if p:GetAttribute('K0SessionPhase')=='Lobby' and o.inventory.ready(p) then",1,true))
local last=assert(service:find('local arrived=count(admitted)',first,true))
local admission=service:sub(first,last-1)
local function arrival(runId,alreadyVerified)
 local starts,entered,kicked=0,0,0
 local p={UserId=1,GetAttribute=function()return 'Lobby'end,Kick=function()kicked=kicked+1 end}
 local bound=alreadyVerified
 local env=setmetatable({p=p,Backend=B,runHealthy=true,battleRun={id=runId},admitted={[p]={heroId='hero',ticket='ticket'}},
  Difficulty={verifyRun=function()return bound end},store={departure=function()return true end,offer=function()return true end},
  o={inventory={ready=function()return true end,expeditionHero=function()return {}end,
   beginExpedition=function()starts=starts+1;bound=true end},heroSession={enterAdventure=function()entered=entered+1 end}}
 },{__index=_G})
 assert(load(admission,'production arrival','t',env))()
 return starts,entered,kicked
end
local starts,entered,kicked=arrival('historic',false)
check(starts==0 and entered==0 and kicked==1,'legacy staged ticket cannot replace a superseded durable journal')
starts,entered,kicked=arrival('historic',true)
check(starts==0 and entered==1 and kicked==0,'verified legacy journal still resumes without restarting it')
starts,entered,kicked=arrival(B.newId('current'),false)
check(starts==1 and entered==1 and kicked==0,'current staged departure begins and enters once')
print('Expedition fixed backend: '..n..' checks passed')
