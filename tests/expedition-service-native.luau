-- Actual service source, local MemoryStore adapter, fake Players/Teleport.
-- No real teleport, public write, Player, or published-save acceptance.
local SSS=game.ServerScriptService
local report={kind='EXPEDITION_SERVICE_NATIVE',checks=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 if not game.ReplicatedStorage:FindFirstChild('Remotes') then local remotes=Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=game.ReplicatedStorage end
 local original=SSS.Server.Network.ExpeditionService;local module=original:Clone();module.Name='ExpeditionServiceQA'
 local source=module.Source
 source=source:gsub("local Players=game:GetService%('Players'%)",[[local removal=Instance.new('BindableEvent');local Players={PlayerRemoving=removal.Event,list={}}
 function Players:GetPlayers() return self.list end
 function Players:GetPlayerByUserId(uid) for _,p in ipairs(self.list) do if p.UserId==uid then return p end end end]],1)
 source=source:gsub("local Teleport=game:GetService%('TeleportService'%)",[[local failed=Instance.new('BindableEvent');local Teleport={TeleportInitFailed=failed.Event,calls={},fail={}}
 function Teleport:TeleportAsync(place,people,options)
  local p=people[1];table.insert(self.calls,{userId=p.UserId,place=place,reserved=options.ReservedServerId,data=options:GetTeleportData()})
  if self.fail[p.UserId] then error('simulated travel failure') end
 end]],1)
 source=source:gsub("local C=require%(RS.Shared.ExpeditionConfig%)","local C=table.clone(require(RS.Shared.ExpeditionConfig));C.battlePlaceId=123",1)
 local first=assert(source:find('local function publish',1,true));local last=assert(source:find('local function advertise',first,true))
 source=source:sub(1,first-1).."local function publish(p,e,open) p.notice=e;p.menuOpen=open end\n"..source:sub(last)
 source=source:gsub('return Service%s*$',[[
 function Service.qaPlayers(list) Players.list=list;for _,p in ipairs(list) do p.Parent=Players end end
 function Service.qaCommand(p,c) last[p]=-math.huge;return handle(p,c) end
 function Service.qaParty(p) return parties[p] end
 function Service.qaLive() studio=false end
 function Service.qaCalls() return Teleport.calls end
 function Service.qaFail(p) Teleport.fail[p.UserId]=true end
 function Service.qaRetry(p) return retryTravel(p,travel[p]) end
 function Service.qaRejoin(p) return offer(p) end
 return Service]])
 module.Source=source;module.Parent=original.Parent
 local service=require(module);local prepared,resumed,locks={},{},{}
 local function player(id) local p={UserId=id,DisplayName='Hero'..id,attrs={K0SessionPhase='Lobby'}};function p:GetAttribute(k) return self.attrs[k] end;function p:SetAttribute(k,v) self.attrs[k]=v end;return p end
 local p1,p2=player(1),player(2)
 service.qaPlayers({p1,p2})
 local inventory={ready=function() return true end,storyState=function() return {main=0} end,growth=function() return {level=1} end,
  prepareTransfer=function(p)
   prepared[p]=(prepared[p] or 0)+1
   local locked,reason=service.beforeHeroAction(p==p1 and p2 or p1,'SelectHero');table.insert(locks,locked and reason=='Busy')
   return true
  end,resumeTransfer=function(p) resumed[p]=(resumed[p] or 0)+1;return true end}
 local hero={getActiveHero=function(p) return {heroId='h'..p.UserId,classId='knight'} end,getInventoryContext=function(p) return {heroId='h'..p.UserId,atHub=true} end,refresh=function() end}
 service.start({role='Lobby',inventory=inventory,heroSession=hero})
 service.openMenu(p1);check(p1.menuOpen==true,'world portal opens expedition menu without starting travel')
 p1.attrs.K0SessionPhase='Tutorial';check(service.openMenu(p1)=='WaitForLobby','portal menu is lobby-only');p1.attrs.K0SessionPhase='Lobby'
 service.qaCommand(p1,{action='Create',target=2});local party=assert(service.qaParty(p1))
 service.qaCommand(p2,{action='Join',id=party.id})
 service.qaCommand(p1,{action='Ready',ready=true});service.qaCommand(p2,{action='Ready',ready=true})
 service.qaLive();service.qaCommand(p1,{action='Launch'})
 local calls=service.qaCalls()
 check(#calls==2,'two authorized members dispatched')
 check(calls[1].reserved==calls[2].reserved and calls[1].reserved~='','one reserved battle destination for the party')
 check(calls[1].data.ticket~=calls[2].data.ticket and calls[1].data.runId==calls[2].data.runId,'individual tickets share one server manifest')
 check(locks[1] and locks[2],'all heroes locked across every save yield')
 check(prepared[p1]==1 and prepared[p2]==1,'every account fence released once before departure')
 local oldTicket
 for _,call in ipairs(calls) do if call.userId==p2.UserId then oldTicket=call.data.ticket end end
 assert(oldTicket,'second member dispatched')
 service.qaFail(p2);service.qaRetry(p2);service.qaRetry(p2);service.qaRetry(p2)
 check(resumed[p2]==1 and not resumed[p1],'partial failure resumes only the player who stayed')
 check(not p2:GetAttribute('TLTTravelLock') and p2.notice=='TravelFailed','exhausted retry restores lobby control')
 for _,call in ipairs(calls) do if call.userId==p2.UserId then check(call.data.ticket==oldTicket and call.reserved==calls[1].reserved,'retry never changes ticket or reserved destination') end end
 check(service.qaRejoin(p2)~=nil,'failed member can rejoin the already launched expedition')
 module:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
report.pass=#report.failures==0
print('EXPEDITION_SERVICE_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Expedition service fixture failed')
