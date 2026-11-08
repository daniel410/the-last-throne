-- Real Luau modules and TD UI constructors with private fixture snapshots.
-- Does not connect a player's account or write DataStore.
local client=game.StarterPlayer.StarterPlayerScripts.Client
local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(RS.Shared.ItemCatalog);local G=require(RS.Shared.HeroProgression)
local report={kind='RESET_TICKETS_NATIVE',checks=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='ResetTicketsQA';folder.Parent=workspace
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=folder
local m=client.InventoryGui:Clone();m.Name='ResetTicketsBagQA'
local source=m.Source
source=source:gsub('local Players = game:GetService%("Players"%)','local Players={LocalPlayer={WaitForChild=function()return script.PlayerGui.Value end,GetAttribute=function(_,k)return script.PlayerGui.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.PlayerGui.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.PlayerGui.Value:GetAttributeChangedSignal(k)end}}')
source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
local start=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',start,true))
source=source:sub(1,start-1)..source:sub(last)
source=source:gsub('\n\treturn {\n\t\topen=', '\n\treturn {\n  qaActivate=activatePrimary,\n  qaSnapshot=function(value,id) pending=nil;remote={FireServer=function(_,value)script:SetAttribute("QACommand",value.action)end};snapshot=value;selectedId=id;opened=true;render();resize() end,\n\t\topen=')
m.Source=source;m.Parent=client
local ref=Instance.new('ObjectValue');ref.Name='PlayerGui';ref.Value=playerGui;ref.Parent=m
local ok,err=xpcall(function()
 local view=require(m).create(function()end,function()end)
 local Shop=require(client.ArmoryView)
 for _,kind in ipairs({'stat','skill'})do
  local p=assert(R.addHero(R.new(38),'qa','mage',C));p.wallet.diamonds=100
  p.heroes.qa.level=9;p.heroes.qa.progression=G.new(9);p.heroes.qa.progression.stats.INT=32;p.heroes.qa.progression.mastery[1]=8
  local buy={action='Buy',requestId='qa-'..kind,heroId='qa',offerId=kind..'_reset_ticket_diamond',revision=p.revision,store='diamonds'}
  p=assert(R.shop(p,buy,{atLobby=true},C));check(p.wallet.diamonds==50,'50 Diamond debit')
  local id='shop-'..buy.requestId
  local function snapshot(hub)
   local list={};for _,item in pairs(p.items)do table.insert(list,item)end
   return {ready=true,heroId='qa',heroes=p.heroes,items=list,revision=p.revision,bagCapacity=C.bagCapacity,storageCapacity=C.storageCapacity,safe=true,atHub=hub,atStorage=false,pending=0,bagUsed=R.count(p,'bag','qa'),storageUsed=0,stats=R.stats(p,'qa',C),wallet=p.wallet}
  end
  view.qaSnapshot(snapshot(true),id)
  local gui=playerGui.InventoryGui
  local preview=assert(gui:FindFirstChild('ResetPreview',true));check(preview.Text:find(kind=='stat' and '32' or '8',1,true),'refund preview')
  local primary=assert(gui:FindFirstChild('PrimaryAction',true));check(primary.Active,'lobby reset enabled');check(primary.Caption.Text=='RESET POINTS','first step label')
  check(not gui:FindFirstChild('AssignQuick1',true),'ticket has no potion assignment')
  m:SetAttribute('QACommand',nil);view.qaActivate();check(primary.Caption.Text=='CONFIRM RESET','first click asks confirmation');check(m:GetAttribute('QACommand')==nil,'first click submits nothing')
  view.qaActivate();check(m:GetAttribute('QACommand')=='ResetPoints','second click submits reset request')
  view.qaSnapshot(snapshot(true),id)
  view.qaActivate();view.close();view.qaSnapshot(snapshot(true),id);check(primary.Caption.Text=='RESET POINTS','closing cancels confirmation')
  view.qaSnapshot(snapshot(false),id);check(not primary.Active,'field reset disabled')
  local host=Instance.new('ScreenGui');host.Parent=playerGui
  local shop=Shop.create(host,function()error('UI fixture must not trade')end,true,'diamonds')
  shop.render(snapshot(true));shop.selectCategory('Resets')
  local card=assert(shop.panel:FindFirstChild(kind..'_reset_ticket_diamond',true));check(card.Trade.Caption.Text=='BUY · 50 Diamonds','shop price visible')
  check(card.Trade.Active,'affordable ticket enabled');check(card.Details.Text:find('lobby',1,true),'shop explains lobby requirement')
  local poor=snapshot(true);poor.wallet={gold=0,diamonds=49};shop.render(poor)
  card=assert(shop.panel:FindFirstChild(kind..'_reset_ticket_diamond',true));check(not card.Trade.Active,'unaffordable ticket disabled')
  host:Destroy()
  local item=p.items[id];local cmd={action='ResetPoints',requestId='use-'..kind,heroId='qa',instanceId=id,itemVersion=item.version,revision=p.revision}
  p=assert(R.apply(p,cmd,{safe=true,atHub=true},C));check(p.items[id]==nil,'last ticket consumed')
  local st,sp=G.points(p.heroes.qa.progression);check(kind=='stat' and st==32 or kind=='skill' and sp==8,'points returned in Luau')
  local again,_,repeated=R.apply(p,cmd,{safe=false,atHub=false},C);check(repeated and again.wallet.diamonds==50,'same receipt reconciles')
 end
 view.close()
end,debug.traceback)
folder:Destroy();m:Destroy();report.pass=ok;report.error=not ok and tostring(err)or nil
print('RESET_TICKETS_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
