-- Execute actual network return/admission bodies; no real Teleport/DataStore.
local f=assert(io.open('src/server/Network/ExpeditionService.luau'));local source=f:read('*a');f:close()
local function body(first,last)
 local a=assert(source:find(first,1,true));local b=assert(source:find(last,a+1,true))
 return source:sub(a,b-1):gsub('seatCount%+=1','seatCount=seatCount+1')
end
local checks=0
local function check(v,m) checks=checks+1;assert(v,m) end
local C={lobbyPlaceId=10,battlePlaceId=20,lobbyCapacity=24,battleCapacity=4}
local p={UserId=42,attributes={}}
function p:SetAttribute(k,v) self.attributes[k]=v end
function p:GetJoinData() return self.join end
local sent,prepared,finished= nil,0,0
local failSave,failFinish=false,false
local inventory={expedition=function(_,id) check(id=='dwarf-hero','return uses admitted hero');return {completed=true} end,
 prepareTransfer=function() prepared=prepared+1;return not failSave end}
local battle={}
local returnEnv=setmetatable({Service=battle,studio=false,role='Battle',admitted={[p]={heroId='dwarf-hero',ticket='ticket'}},battleRun={id='run'},travel={},leaving={},C=C,
 o={inventory=inventory},store={finish=function(uid,id,ticket) finished=finished+1;check(uid==42 and id=='run' and ticket=='ticket','finish retains verified membership');return not failFinish end},
 unlock=function() end,send=function(_,attempt,ready) check(ready,'save completed before send');sent=attempt;return true end},{__index=_G})
assert(load(body('function Service.returnLobby','function Service.beforeHeroAction'),'returnLobby','t',returnEnv))()
local handled,reason=battle.returnLobby(p)
check(handled and reason==nil and prepared==1 and finished==1,'successful return saves and finishes once')
check(sent.placeId==10 and sent.data.heroId=='dwarf-hero' and sent.data.returning and sent.data.replay,'return carries hero selection with existing replay intent')
local returnData=sent.data
sent=nil;failSave=true;battle.returnLobby(p)
check(sent==nil and finished==1,'failed save cannot send return')
failSave=false;failFinish=true;battle.returnLobby(p)
check(sent==nil,'failed finish cannot send return')
local lobby={}
local env=setmetatable({Service=lobby,role='Lobby',C=C,seats={},seatCount=0,arrivals={},game={GameId=100},
 sourceValid=function(data) return data.SourceGameId==100 and (data.SourcePlaceId==10 or data.SourcePlaceId==20) end},{__index=_G})
assert(load(body('function Service.admitArrival','local function startRunLocked'),'admitArrival','t',env))()
local function admit(data,place,gameId)
 p.join={SourceGameId=gameId or 100,SourcePlaceId=place or 20,TeleportData=data}
 p.attributes={};return lobby.admitArrival(p)
end
local arrival=admit(returnData)
check(arrival.lobbyHeroId=='dwarf-hero' and arrival.heroId==nil,'return enters optional lobby selection path')
check(p.attributes.TLTReplayRequested==true,'completed replay prompt retained')
for _,id in ipairs({'elf','dwarf','knight','mage'}) do
 local a=admit({returning=true,heroId=id});check(a and a.lobbyHeroId==id,'all four classes carry their identity')
end
for _,data in ipairs({{}, {returning=true}, {returning=true,heroId=''}, {returning=true,heroId=4}, {returning=true,heroId={}}, {returning=true,heroId=string.rep('x',65)}, {heroId='dwarf'}}) do
 check(admit(data)==nil,'malformed/missing return hint ignored')
end
check(admit(returnData,10)==nil,'lobby gathering is not a battle return')
check(admit(returnData,20,999)==nil,'foreign Experience hint ignored')
check(admit(returnData,30)==nil,'foreign Place hint ignored')
check(admit(nil)==nil,'ordinary join retains existing behavior')
print('Lobby return hero: '..checks..' checks PASS')
