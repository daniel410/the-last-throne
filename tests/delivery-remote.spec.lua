-- Exercise the remote boundary with adversarial payloads, not a live DataStore.
local checkCount=0
local function check(ok,msg)checkCount=checkCount+1;assert(ok,msg)end
local clock=10;local listeners={};local created={};local responses={};local phase='Lobby';local role='Lobby'
local player={GetAttribute=function()return phase end}
local players={PlayerRemoving={Connect=function(_,fn)listeners.remove=fn end}}
local instance={new=function()
 local remote={OnServerEvent={Connect=function(_,fn)listeners.request=fn end},FireClient=function(_,p,data)table.insert(responses,data)end}
 table.insert(created,remote);return remote
end}
local calls=0
local inventory={deliveryStatus=function()return {status='Ready',mails={},unread=0}end,
 claimDelivery=function(_,c)calls=calls+1;return nil end}
local env=setmetatable({game={GetService=function(_,name)return name=='Players'and players or {Remotes={}}end},
 Instance=instance,workspace={GetAttribute=function()return role end},os={clock=function()return clock end}},{__index=_G})
local S=assert(loadfile('src/server/Lobby/DeliveryService.luau','t',env))();S.start(inventory)
local valid={action='Redeem',value='THRONE',requestId='one'}
listeners.request(player,{action='Redeem',value='THRONE',requestId='one',gold=999999})
check(calls==0 and #responses==0,'client cannot attach a forged reward amount')
listeners.request(player,valid,'unexpected')
check(calls==0,'extra remote arguments rejected')
listeners.request(player,{action='Redeem',value={},requestId='one'})
listeners.request(player,{action='Redeem',value=string.rep('A',65),requestId='one'})
listeners.request(player,{action='Redeem',value='THRONE',requestId='!'})
check(calls==0,'malformed and oversized inputs rejected')
listeners.request(player,valid)
check(calls==1 and responses[#responses].claimed,'valid intent reaches account transition')
clock=10.2;listeners.request(player,valid)
check(calls==1 and responses[#responses].error=='Busy','throttle responds with retry state without executing grant')
clock=12;phase='Tutorial';listeners.request(player,valid)
check(calls==1,'battle session cannot claim')
phase='Lobby';role='Battle';listeners.request(player,valid)
check(calls==1,'battle server cannot claim even with lobby phase')
role='Lobby';clock=14;listeners.request(player,{action='GetState'})
check(calls==1 and responses[#responses].state.unread==0 and not responses[#responses].claimed,'state read never grants')
listeners.remove(player);listeners.request(player,valid)
check(calls==2,'player cleanup clears throttle state')
print('Delivery remote: '..checkCount..' checks passed')
