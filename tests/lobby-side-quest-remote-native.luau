-- Exercise the actual NPC remote handler with in-memory transports, no network/account.
local source=game.ServerScriptService.Server.Lobby.NPCService.Source
local objects,calls,replies={},0,{}
local now,near=100,true
local function signal()return {Connect=function(self,fn)self.callback=fn end}end
local players={PlayerRemoving=signal()}
local function remote()
 local r={OnServerEvent=signal()};function r:FireClient(player,data)table.insert(replies,data)end
 table.insert(objects,r);return r
end
local remotes={FindFirstChild=function()return nil end}
local shared={NPCCatalog={},SupporterInfo={},SupportPassRules={},LobbySideQuests={}}
local env=setmetatable({game={GetService=function(_,name)if name=='ReplicatedStorage'then return {Shared=shared,Remotes=remotes}end end,Players=players},
 script={Parent={FacilityAccess={}}},Instance={new=function(class)assert(class=='RemoteEvent');return remote()end},
 os={clock=function()return now end},require=function(module)
 if module==shared.LobbySideQuests then return S end
 if module==shared.NPCCatalog then return {byId={tessa={}}}end
 return {allowed=function()return near end}
end},{__index=getfenv()})
local fn=assert(loadstring(source));setfenv(fn,env);local service=fn()
local trigger=signal()
service.start({residents={tessa={prompt={Triggered=trigger}}},inventory={sideQuest=function()calls+=1;return nil end}})
local request;for _,r in ipairs(objects)do if r.Name=='LobbySideQuestRequest'then request=r.OnServerEvent.callback end end
check(request~=nil,'NPC installs side quest remote')
local remotePlayer={};local notice={action='Notice',heroId='hero',questId='DW-Q1',noticeState=1,noticeKey='DW-Q1:1',requestId='notice'}
request(remotePlayer,notice);check(calls==1,'valid notice reaches account service')
request(remotePlayer,notice);check(calls==1 and replies[#replies].error=='Busy','rate limit suppresses repeated account writes')
now+=1
local command={action='Report',heroId='hero',questId='DW-Q1',runId='run',requestId='report'}
near=false;request(remotePlayer,command);check(calls==1 and replies[#replies].error=='Unavailable','cannot report away from Tessa')
now+=1;near=true;request(remotePlayer,command);check(calls==2 and replies[#replies].requestId=='report','authorized report replies to exact request')
now+=1;local forged=table.clone(command);forged.gold=10000;request(remotePlayer,forged);check(calls==2,'client cannot provide payout')
request(remotePlayer,command,'extra');check(calls==2,'reject extra remote arguments')
request(remotePlayer,{action='Report',heroId='hero',questId='DW-01',runId='run',requestId='main'});check(calls==2,'cannot report main story at Tessa')
near=true;trigger.callback(remotePlayer)
check(replies[#replies].sideQuests==true,'Tessa interaction opens recommendation panel directly')
