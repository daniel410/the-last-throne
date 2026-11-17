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
local function scenario(size,mixed,advancedHost)
 local original=SSS.Server.Network.ExpeditionService;local module=original:Clone();module.Name='PartyLaunchQA'
 local source=module.Source
 source="local task={spawn=function()end,delay=function()end}\n"..source
 source=source:gsub("local Players=game:GetService%('Players'%)",[[local Players={PlayerRemoving={Connect=function()end},list={}}
 function Players:GetPlayers()return self.list end
 function Players:GetPlayerByUserId(uid)for _,p in ipairs(self.list)do if p.UserId==uid then return p end end end]],1)
 source=source:gsub("local Teleport=game:GetService%('TeleportService'%)",[[local Teleport={TeleportInitFailed={Connect=function()end},calls={}}
 function Teleport:TeleportAsync(place,people,options)table.insert(self.calls,{userId=people[1].UserId,place=place,reserved=options.ReservedServerId,data=options:GetTeleportData()})end]],1)
 local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.openMenu',first,true))
 source=source:sub(1,first-1)..source:sub(first,last-1):gsub('local function publish','local function captureListing',1)..'local function publish(p,e) p.notice=e end\n'..source:sub(last)
 source=source:gsub('return Service%s*$',[[
 function Service.qaActors(list)Players.list=list;for _,p in ipairs(list)do p.Parent=Players end end
 function Service.qaCommand(p,c)last[p]=-math.huge;return handle(p,c)end
 function Service.qaParty(p)return parties[p]and store.readParty(parties[p].id)end
 function Service.qaLive()studio=false end
 function Service.qaCalls()return Teleport.calls end
 function Service.qaBrowse(p)
  local original=remote
  remote={FireClient=function(_,actor,state)actor.snapshot=state end}
  captureListing(p)
  remote=original
  return p.snapshot
 end
 return Service]])
 module.Source=source;module.Parent=original.Parent
 local service=require(module);local actors,profiles,prepared,resumed={},{},{},{}
 for i=1,size do
  local p={UserId=i,DisplayName='Hero'..i,attrs={K0SessionPhase='Lobby'}}
  function p:GetAttribute(k)return self.attrs[k]end;function p:SetAttribute(k,v)self.attrs[k]=v end
  actors[i]=p;profiles[i]=assert(R.addHero(R.new(i),'hero','knight',Items))
  if mixed then profiles[i]=assert(A.begin(profiles[i],'hero','DW-01','Easy','old'..i,profiles[i].revision,R,Items,i==size and 19 or 17))end
 end
 if advancedHost then
  local c=require(RS.Shared.CampaignContent).byId['DW-01']
  local progress=require(RS.Shared.DeepwoodProgress)
  local p=profiles[1]
  p.heroes.hero.level=10;p.heroes.hero.progression=require(RS.Shared.HeroProgression).new(10)
  p=assert(A.begin(p,'hero',c.id,'Easy','original',p.revision,R,Items))
  for _,g in ipairs(c.goals) do
   if progress.required(A.projection(p.heroes.hero),g) then
    for _,step in ipairs(g.activity and g.activity.steps or {false})do
     local choice=step and step.choices and (step.solution or step.choices[1].id) or g.choice and 'shared' or nil
     p=assert(A.event(p,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,'original'))
    end
   end
  end
  profiles[1]=p
 end
 service.qaActors(actors)
 local inv={ready=function()return true end,storyState=function(p)return profiles[p.UserId].heroes.hero.deepwood end,
  growth=function(p)return {level=profiles[p.UserId].heroes.hero.level}end,
  expeditionHero=function(p)return R.copy(profiles[p.UserId].heroes.hero)end,
  expedition=function(p)local e=profiles[p.UserId].heroes.hero.expeditions;return e and e.active end,
  prepareTransfer=function(p)
   for _,a in ipairs(actors)do check(a.attrs.TLTAdventureStarting,'every participant notified before first save');local blocked,why=service.beforeHeroAction(a,'SelectHero');check(blocked and why=='Busy','every participant locked before save')end
   prepared[p]=(prepared[p]or 0)+1;return true
  end,resumeTransfer=function(p)resumed[p]=(resumed[p]or 0)+1;return true end}
 local heroes={getActiveHero=function()return {heroId='hero',classId='knight'}end,getInventoryContext=function()return {heroId='hero',atHub=true}end,refresh=function()end}
 service.start({role='Lobby',inventory=inv,heroSession=heroes})
 service.qaCommand(actors[1],{action='Create',target=size});local party=assert(service.qaParty(actors[1]))
 if advancedHost then
  check(party.missionId=='DW-02','advanced leader starts at own frontier')
  local browser=actors[2]
  local snapshot=service.qaBrowse(browser)
  local listing=assert(snapshot.list[1])
  check(listing.missionId=='DW-02' and listing.joinMissionId=='DW-01','recruitment previews both missions before joining')
  local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(640,360)
  local ui=require(game.StarterPlayer.StarterPlayerScripts.Client.ExpeditionView).create(frame,function()end)
  ui.showTab('Party');ui.render(snapshot)
  local row=assert(ui.panel.PartyList:FindFirstChild('Listing'..party.id))
  local function caption(id)
   for _,m in ipairs(snapshot.missions)do if m.id==id then return m.region..' · '..m.title end end
  end
  check(row.Destination.Text==caption('DW-02')..' · Easy' and row.JoinDestination.Text=='If you join: '..caption('DW-01'),'recruitment card shows the two server-authored destinations')
  check(row:FindFirstChild('Join'..party.id).Active,'join button available before membership')
  frame:Destroy()
  service.qaCommand(actors[1],{action='Configure',missionId='DW-02',difficultyId='Easy'})
  service.qaCommand(browser,{action='Join',id=party.id,missionId=listing.joinMissionId,difficultyId=listing.difficultyId})
  check(browser.notice=='ListingChanged' and not service.qaParty(browser),'stale listing does not join a different mission')
  check(service.qaBrowse(browser).list[1].joinMissionId=='DW-02','edited mission advertised immediately')
  service.qaCommand(actors[1],{action='PartyMode',missionId='DW-02',difficultyId='Easy'})
 end
 for i=2,size do service.qaCommand(actors[i],{action='Join',id=party.id});check(not actors[i].notice,'member joins selected party')end
 local function view()return Presentation.party(service.qaParty(actors[1]),function(m)return profiles[m.userId].heroes.hero end)end
 if advancedHost then
  local entry=view()
  check(entry.missionId=='DW-01' and not entry.members[1].firstClear and entry.members[2].firstClear,'join automatically selects shared story and individual rewards')
 end
 check(#view().members==size,'all members present in authoritative projection')
 for i=1,size-1 do service.qaCommand(actors[i],{action='Ready',ready=true})end
 check(not view().launchAllowed,'one unready member blocks launch')
 service.qaCommand(actors[1],{action='Launch'})
 check(actors[1].notice=='NotReady'and #service.qaCalls()==0 and next(prepared)==nil,'server rejects unready party before saving or travel')
 service.qaCommand(actors[size],{action='Ready',ready=true})
 check(view().launchAllowed==not mixed,'eligible party can launch only with compatible checkpoints')
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
 table.insert(report.cases,{size=size,mixed=mixed==true,advancedHost=advancedHost==true,error=actors[1].notice,teleports=#service.qaCalls()})
 module:Destroy()
end
for size=2,4 do scenario(size,false)end
scenario(3,true)
scenario(3,false,true)
print('PARTY_LAUNCH_NATIVE '..game.HttpService:JSONEncode(report))
