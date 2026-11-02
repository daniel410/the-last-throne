-- Actual InventoryService and AccountStore, isolated identities and adapter.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local Server=game.ServerScriptService.Server;local Shared=game.ReplicatedStorage.Shared
local R=require(Server.Inventory.InventoryRules);local Items=require(Shared.ItemCatalog);local Content=require(Shared.DeepwoodContent)
local Store=require(Server.Inventory.AccountStore)
local report={kind='SUPPORT_PASS_SERVICE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local original=Server.Inventory.InventoryService;local copy=original:Clone();copy.Name='SupportPassServiceQA'
copy.Source=copy.Source:gsub('\nreturn Service%s*$', '\n'..[[
Service.qa=function(player,state,adapter,settings)accounts[player]=state;store=adapter;options=settings end
return Service
]])
copy.Parent=original.Parent;local service=require(copy)
local previousRole=workspace:GetAttribute('TLTServerRole');workspace:SetAttribute('TLTServerRole','Lobby')
local ok,err=xpcall(function()
 local p=R.addHero(R.new(77),'hero','knight',Items)
 for _,c in ipairs(Content.chapters)do if not c.side and c.number<=3 then for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {})do p=assert(R.story(p,'hero',c.id,g.id,step.choices and step.choices[1].id,Items,step.id))end
  if not(g.activity and g.activity.steps)then p=assert(R.story(p,'hero',c.id,g.id,g.choice and 'shared' or nil,Items))end
 end end end end
 p.wallet.gold=5000
 local saved,lose;local adapter={UpdateAsync=function(_,_,fn)local n=fn(R.copy(saved));if n then saved=R.copy(n)end;if lose then error('lost response')end;return n end}
 local store=Store.new(adapter,R,Items,function()return 1000 end,function()end,'support-service')
 assert(store:open(77));p=assert(store:transact(77,function(v)local n=R.copy(p);n.epoch=v.epoch;n.lease=v.lease;return n end))
 local phase='Lobby';local camp=true
 local player={UserId=77,Parent=game.Players,GetAttribute=function(_,key)return key=='K0SessionPhase' and phase or nil end}
 local state={profile=p,valid=true,busy=false}
 service.qa(player,state,store,{heroSession={getInventoryContext=function()return {heroId='hero',atHub=phase=='Lobby'}end,getCombatContext=function()return phase=='Tutorial' and {heroId='hero'}or nil end},supportCampAccess=function()return camp end})
 check(service.supportState(player,'hero').active==false,'old free preference cannot authorize paid support')
 local command={action='Buy',requestId='five',heroId='hero',revision=state.profile.revision,offerId='selene_story_5'}
 check(service.supportPass(player,command)==nil,'five-story purchase saves')
 check(state.profile.wallet.gold==4000 and service.supportState(player,'hero').credits==5,'one account write debits 1000 Gold and grants five stories')
 check(service.supportPass(player,command)==nil and state.profile.wallet.gold==4000,'purchase retry cannot charge twice')
 phase='Tutorial';camp=false
 check(service.activateSupport(player,'hero')=='Unavailable' and service.supportState(player,'hero').credits==5,'live camp access is checked before consuming')
 camp=true;check(service.activateSupport(player,'hero')==nil,'camp activation saves')
 check(service.supportState(player,'hero').active and service.supportState(player,'hero').credits==4,'one story starts with four unused credits left')
 check(service.activateSupport(player,'hero')==nil and service.supportState(player,'hero').credits==4,'same-story reinvitation cannot consume twice')
 check(service.endSupport(player,'hero')==nil and not service.supportState(player,'hero').active,'explicit return ends entitlement')
 check(service.supportState(player,'hero').credits==4,'return retains unused credits')
 phase='Lobby';command={action='Buy',requestId='lost',heroId='hero',revision=state.profile.revision,offerId='selene_story_1'}
 lose=true;check(service.supportPass(player,command)=='SaveUnknown' and not state.valid,'unknown receipt freezes confirmation')
 check(service.supportState(player,'hero')==nil,'failed confirmation does not fabricate an empty entitlement')
 lose=false;check(service.supportPass(player,command)==nil and state.valid,'same pending receipt recovers account')
 check(state.profile.wallet.gold==3800 and service.supportState(player,'hero').credits==5,'unknown retry grants/debits once')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
workspace:SetAttribute('TLTServerRole',previousRole);copy:Destroy();report.pass=#report.failures==0
print('SUPPORT_PASS_SERVICE_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Support pass service failed')
