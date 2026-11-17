-- Invoke the actual remote handler with a deterministic clock.
local receive,reply
local now,snapshots,trades,acks=1,0,0,0
local signal={Connect=function(_,callback)receive=callback end}
local env=setmetatable({
 game={GetService=function()return {Remotes={}}end,Players={PlayerRemoving={Connect=function()end}}},
 Instance={new=function()return {OnServerEvent=signal,FireClient=function(_,_,packet)reply=packet;acks=acks+1 end}end},
 script={Parent={FacilityAccess={}}},require=function(v)return v end,os={clock=function()return now end},
},{__index=_G})
local merchant=assert(loadfile('src/server/Lobby/MerchantService.luau','t',env))()
merchant.start({inventory={snapshot=function()snapshots=snapshots+1;return {revision=snapshots}end,shop=function()trades=trades+1 end}})
local p={}
receive(p,{action='GetState',requestId='open'})
assert(snapshots==1 and reply.inventory.revision==1)
for i=1,100 do
 local id='buy-'..i
 receive(p,{action='Buy',requestId=id})
 assert(reply.error=='Busy' and reply.requestId==id and not reply.inventory)
end
assert(snapshots==1 and trades==0 and acks==101,'100 throttled mutations perform zero projections or trades')
receive(p,{action='GetState',requestId='read'});assert(acks==101,'throttled reads do not amplify traffic')
now=2
receive(p,{action='Buy',requestId='buy-100',revision=1,heroId='hero',offerId='iron'})
assert(snapshots==2 and trades==1 and reply.requestId=='buy-100' and reply.inventory,'retry gets the confirmed snapshot')
local f=assert(io.open('src/client/LobbyCommerce.luau'));local client=f:read('*a');f:close()
local a=assert(client:find("remotes:WaitForChild('ArmoryState')",1,true))
local b=assert(client:find("remotes:WaitForChild('ExpeditionState')",a,true))
local render,shown=0,nil
local command={requestId='buy-100'}
local ui=setmetatable({pending=command,latest={revision=1},AdventureText={},Text={Busy='Please wait'},InventoryText={},
 remotes={WaitForChild=function()return {OnClientEvent=signal}end},
 inventory=function(data)render=render+1;shown=data end,
},{__index=_G})
assert(load(client:sub(a,b-1),'armory client','t',ui))()
receive({requestId='unrelated',error='Busy'});assert(render==0 and ui.pending==command)
receive({requestId=command.requestId,error='Busy'});assert(shown==ui.latest and ui.pending==command and ui.message=='Please wait')
receive(reply);assert(shown==reply.inventory and ui.pending==nil,'confirmed retry clears only its own pending trade')
print('Merchant throttle: 100 rejected mutations, 0 extra snapshots; retry passed')
