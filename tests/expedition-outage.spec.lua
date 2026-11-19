-- Exercise the production heartbeat handlers with independently failing MemoryStore calls.
local f=assert(io.open('src/server/Network/ExpeditionService.luau'))
local source=f:read('*a');f:close()
local first=assert(source:find('local function verifyBattleArrival',1,true))
local last=assert(source:find('function Service.start(options)',first,true))
local env=setmetatable({Service={}},{__index=_G})
local verify,maintain,gather=assert(load(source:sub(first,last-1)..'return verifyBattleArrival,maintainParty,confirmGatherArrival','heartbeat','t',env))()
local kicked,entered,begun,promoted,verified=0,0,0,false,false
local p={UserId=1,Kick=function()kicked=kicked+1 end}
local m={heroId='knight',ticket='t'}
local mine={id='party',token='fence'}
local reason='NetworkUnavailable'
local released,advertised=0,0
env.store={
 departure=function()return reason==nil,reason end,
 offer=function()return promoted end,
 claimMembership=function()return true end,
 touch=function()return reason==nil,reason end,
 releaseMembership=function()released=released+1 end,
 readParty=function()return {members={['1']=m}} end,
 membership=function()return mine end,
 arrive=function()return reason==nil,reason end,
}
env.runHealthy=true;env.battleRun={id='run'}
env.admitted={[p]=m};env.travel={}
env.hasBattleLease=function()return env.runHealthy end
env.Adventure={projection=function()end}
local prepared={ready=true}
env.prepareBattleArrival=function()return prepared end
env.Backend={isCurrent=function()return true end}
env.Difficulty={verifyRun=function()return verified end}
env.o={inventory={expeditionHero=function()return {}end,beginExpedition=function()begun=begun+1;verified=true end,ready=function()return true end},
 heroSession={enterAdventure=function()entered=entered+1 end,selectForArrival=function()end}}
env.member=function()return m end
env.advertise=function()advertised=advertised+1 end
env.publish=function()error('unexpected confirmed party loss')end
env.parties={[p]=mine}
local arrival={partyId=mine.id,token=mine.token};env.arrivals={[p]=arrival}
verify(p,m);assert(kicked==0 and begun==0 and entered==0,'outage keeps the destination locked')
maintain(p,mine);assert(env.parties[p]==mine and released==0,'touch outage retains membership')
gather(p,arrival);assert(env.arrivals[p]==arrival,'arrival write can be retried')
reason=nil
verify(p,m);assert(kicked==0 and begun==1 and entered==0,'failed promotion does not enter the battle')
promoted=true;verify(p,m);assert(entered==1 and begun==1,'confirmed promotion enters once without rewriting the journal')
maintain(p,mine);assert(advertised==1 and released==0,'next heartbeat renews the existing party')
gather(p,arrival);assert(not env.arrivals[p] and env.parties[p].id==mine.id,'gather resumes the original party')
mine=env.parties[p];reason='PartyChanged';maintain(p,mine);assert(not env.parties[p] and released==1,'confirmed seat loss releases ownership')
verified=false;reason='RejoinExpired';verify(p,m);assert(kicked==1 and begun==1,'expired ticket never stages a journal')
print('Expedition outage: 9 checks passed')
