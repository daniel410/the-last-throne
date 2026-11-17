-- Isolated Edit-mode integration: production handler/store/projection, fake actors and transport.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')
local SSS,RS=game.ServerScriptService,game.ReplicatedStorage
local R=require(SSS.Server.Inventory.InventoryRules)
local Items=require(RS.Shared.ItemCatalog)
local A=require(RS.Shared.AdventureRules)
local Presentation=require(RS.Shared.ExpeditionPresentation)
local report={kind='PARTY_LAUNCH_NATIVE',checks=0,cases={}}
local function check(v,m)report.checks+=1;assert(v,m)end
if not RS:FindFirstChild('Remotes')then local f=Instance.new('Folder');f.Name='Remotes';f.Parent=RS end
local function scenario(size,mixed)
 local original=SSS.Server.Network.ExpeditionService;local module=original:Clone();module.Name='PartyLaunchQA'
 local source=module.Source
 source="local task={spawn=function()end,delay=function()end}\n"..source
 source=source:gsub("local Players=game:GetService%('Players'%)",[[local Players={PlayerRemoving={Connect=function()end},list={}}
 function Players:GetPlayers()return self.list end
 function Players:GetPlayerByUserId(uid)for _,p in ipairs(self.list)do if p.UserId==uid then return p end end end]],1)
 source=source:gsub("local Teleport=game:GetService%('TeleportService'%)",[[local Teleport={TeleportInitFailed={Connect=function()end},calls={}}
 function Teleport:TeleportAsync(place,people,options)table.insert(self.calls,{userId=people[1].UserId,place=place,reserved=options.ReservedServerId,data=options:GetTeleportData()})end]],1)
 local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.openMenu',first,true))
 source=source:sub(1,first-1)..'local function publish(p,e) p.notice=e end\n'..source:sub(last)
 source=source:gsub('return Service%s*$',[[
 function Service.qaActors(list)Players.list=list;for _,p in ipairs(list)do p.Parent=Players end end
 function Service.qaCommand(p,c)last[p]=-math.huge;return handle(p,c)end
 function Service.qaParty(p)return parties[p]and store.readParty(parties[p].id)end
 function Service.qaLive()studio=false end
 function Service.qaCalls()return Teleport.calls end
 return Service]])
 module.Source=source;module.Parent=original.Parent
 local service=require(module);local actors,profiles,prepared,resumed={},{},{},{}
 for i=1,size do
  local p={UserId=i,DisplayName='Hero'..i,attrs={K0SessionPhase='Lobby'}}
  function p:GetAttribute(k)return self.attrs[k]end;function p:SetAttribute(k,v)self.attrs[k]=v end
  actors[i]=p;profiles[i]=assert(R.addHero(R.new(i),'hero','knight',Items))
  if mixed then profiles[i]=assert(A.begin(profiles[i],'hero','DW-01','Easy','old'..i,profiles[i].revision,R,Items,i==size and 19 or 17))end
 end
 service.qaActors(actors)
 local inv={ready=function()return true end,storyState=function(p)return profiles[p.UserId].heroes.hero.deepwood end,
  growth=function(p)return {level=profiles[p.UserId].heroes.hero.level}end,
  expeditionHero=function(p)return R.copy(profiles[p.UserId].heroes.hero)end,
  expedition=function(p)return profiles[p.UserId].heroes.hero.expeditions.active end,
  prepareTransfer=function(p)
   for _,a in ipairs(actors)do check(a.attrs.TLTAdventureStarting,'every participant notified before first save');local blocked,why=service.beforeHeroAction(a,'SelectHero');check(blocked and why=='Busy','every participant locked before save')end
   prepared[p]=(prepared[p]or 0)+1;return true
  end,resumeTransfer=function(p)resumed[p]=(resumed[p]or 0)+1;return true end}
 local heroes={getActiveHero=function()return {heroId='hero',classId='knight'}end,getInventoryContext=function()return {heroId='hero',atHub=true}end,refresh=function()end}
 service.start({role='Lobby',inventory=inv,heroSession=heroes})
 service.qaCommand(actors[1],{action='Create',target=size});local party=assert(service.qaParty(actors[1]))
 for i=2,size do service.qaCommand(actors[i],{action='Join',id=party.id});check(not actors[i].notice,'member joins selected party')end
 local function view()return Presentation.party(service.qaParty(actors[1]),function(m)return profiles[m.userId].heroes.hero end)end
 check(#view().members==size,'all members present in authoritative projection')
 for i=1,size-1 do service.qaCommand(actors[i],{action='Ready',ready=true})end
 check(not view().launchAllowed,'one unready member blocks launch')
 service.qaCommand(actors[1],{action='Launch'})
 check(actors[1].notice=='NotReady'and #service.qaCalls()==0 and next(prepared)==nil,'server rejects unready party before saving or travel')
 service.qaCommand(actors[size],{action='Ready',ready=true})
 check(view().launchAllowed,'whole ready eligible party can press Launch')
 service.qaCommand(actors[2],{action='Launch'})
 check(actors[2].notice=='LeaderOnly'and #service.qaCalls()==0,'non-leader cannot launch')
 service.qaLive();service.qaCommand(actors[1],{action='Launch'})
 if mixed then
  check(actors[1].notice=='PartyRulesMismatch'and next(prepared)==nil and #service.qaCalls()==0,'mixed checkpoint rule versions fail before saves')
 else
  check(not actors[1].notice and #service.qaCalls()==size,'leader dispatches every ready member')
  local run,reserved,tickets=nil,nil,{}
  for _,call in ipairs(service.qaCalls())do
   check(call.place==129388473517823,'correct RPG battle destination')
   check(call.reserved~=''and(not reserved or reserved==call.reserved),'one reserved server shared by all members');reserved=call.reserved
   check(call.data.runId:sub(1,4)=='sm2_'and(not run or run==call.data.runId),'one fixed SortedMap run');run=call.data.runId
   check(not tickets[call.data.ticket],'each member has its own capability');tickets[call.data.ticket]=true
  end
  for _,p in ipairs(actors)do check(prepared[p]==1 and not resumed[p]and p.attrs.TLTTravelLock,'each account prepared once and remains locked in transit')end
 end
 table.insert(report.cases,{size=size,mixed=mixed==true,error=actors[1].notice,teleports=#service.qaCalls()})
 module:Destroy()
end
for size=2,4 do scenario(size,false)end
scenario(3,true)
print('PARTY_LAUNCH_NATIVE '..game.HttpService:JSONEncode(report))
