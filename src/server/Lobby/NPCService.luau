local RS=game:GetService('ReplicatedStorage')
local Catalog=require(RS.Shared.NPCCatalog)
local Info=require(RS.Shared.SupporterInfo)
local Pass=require(RS.Shared.SupportPassRules)
local Access=require(script.Parent.FacilityAccess)
local S={}
function S.start(options)
 local remote=RS.Remotes:FindFirstChild('NPCDialogue') or Instance.new('RemoteEvent');remote.Name='NPCDialogue';remote.Parent=RS.Remotes
 local purchase=Instance.new('RemoteEvent');purchase.Name='SupporterPassRequest';purchase.Parent=RS.Remotes
 local last={}
 local side=Instance.new('RemoteEvent');side.Name='LobbySideQuestRequest';side.Parent=RS.Remotes
 local result=Instance.new('RemoteEvent');result.Name='LobbySideQuestResult';result.Parent=RS.Remotes
 local sideLast={}
 side.OnServerEvent:Connect(function(player,c,...)
  if select('#',...)~=0 or not require(RS.Shared.LobbySideQuests).command(c)then return end
  if os.clock()-(sideLast[player]or -math.huge)<.4 then result:FireClient(player,{requestId=c.requestId,error='Busy'});return end
  sideLast[player]=os.clock()
  local entry=options.residents and options.residents.tessa
  local why
  if c.action=='Report'and not Access.allowed(player,entry and entry.prompt)then why='Unavailable'
  else why=options.inventory.sideQuest(player,c)end
  result:FireClient(player,{requestId=c.requestId,error=why})
 end)
 local function show(player,requestId,reason)
  local snap=options.inventory.snapshot(player);local h=snap.ready and snap.heroId and snap.heroes[snap.heroId]
  local pass=h and options.inventory.supportState(player,snap.heroId)
  local data=Info.project(h and (h.deepwood or {flags={}}),nil,nil,true,pass)
  data.heroId=snap.heroId;data.revision=snap.revision;data.balance=snap.ready and snap.wallet and snap.wallet.gold or nil
  data.canBuy=snap.ready==true and h~=nil and player:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')=='Lobby'
  data.message=reason and (Info.text[reason] or Info.text.Unavailable) or requestId and Info.text.purchased or nil
  remote:FireClient(player,{supporter=data,requestId=requestId,error=reason})
 end
 purchase.OnServerEvent:Connect(function(player,c,...)
  if select('#',...)~=0 or type(c)~='table' then return end
  for k in pairs(c)do if k~='requestId' and k~='revision' and k~='heroId' and k~='offerId' then return end end
  if type(c.requestId)~='string' or #c.requestId<1 or #c.requestId>64 or not c.requestId:match('^[%w_-]+$') or type(c.heroId)~='string' or #c.heroId>64 or type(c.offerId)~='string' or not Pass.offer(c.offerId)
   or type(c.revision)~='number' or c.revision~=c.revision or c.revision%1~=0 or c.revision<0 or c.revision>1e12 then return end
  if os.clock()-(last[player] or -math.huge)<.3 then show(player,c.requestId,'Busy');return end
  last[player]=os.clock()
  local reason=options.inventory.supportPass(player,{action='Buy',requestId=c.requestId,revision=c.revision,heroId=c.heroId,offerId=c.offerId})
  show(player,c.requestId,reason)
 end)
 for id,entry in pairs(options.residents or {})do if entry.prompt then
  entry.prompt.Triggered:Connect(function(player)
   if os.clock()-(last[player] or -math.huge)<.6 or not Access.allowed(player,entry.prompt)then return end
   last[player]=os.clock()
   if entry.homecoming then
    local snapshot=options.inventory.snapshot(player);local hero=snapshot.ready and snapshot.heroId and snapshot.heroes[snapshot.heroId]
    if hero and hero.deepwood and hero.deepwood.clears['HG-07']then remote:FireClient(player,{name=entry.name,role='Welcome Home',text=entry.text})end
   elseif id=='mira' then
    if options.inventory.ready(player)then RS.Remotes.ArmoryState:FireClient(player,{inventory=options.inventory.snapshot(player),open=true,store='items'})end
   elseif id=='selene' then show(player)
   elseif id=='tessa' then remote:FireClient(player,{sideQuests=true})
   else local c=Catalog.byId[id];remote:FireClient(player,{id=id,name=c.name,role=c.role,key=c.textKey,text=c.greeting})end
  end)
 end end
 game.Players.PlayerRemoving:Connect(function(player)last[player]=nil;sideLast[player]=nil end)
end
return S
