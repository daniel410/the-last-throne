-- Isolated real bag UI; fake transport injects concurrent/late server responses.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local fixture')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local report={kind='POTION_REQUEST_RECOVERY_NATIVE',checks=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local root=Instance.new('Folder');root.Name='PotionRequestQA';root.Parent=workspace
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=root
local module=client.InventoryGui:Clone();module.Name='PotionRequestQA'
local source=module.Source
source=source:gsub('local Players = game:GetService%("Players"%)','local Players={LocalPlayer={WaitForChild=function()return script.PlayerGui.Value end,GetAttribute=function(_,k)return script.PlayerGui.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.PlayerGui.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.PlayerGui.Value:GetAttributeChangedSignal(k)end}}')
source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
local first=assert(source:find('\n\ttask.spawn(function()',1,true))
local last=assert(source:find('\n\tresize()\n\treturn {',first,true))
source=source:sub(1,first-1)..source:sub(last)
source=source:gsub('\n\treturn {\n\t\topen=', '\n\treturn {\n qaReceive=receiveInventory,qaRemote=function(value)remote=value end,\n\t\topen=')
module.Source=source;module.Parent=client
local ref=Instance.new('ObjectValue');ref.Name='PlayerGui';ref.Value=playerGui;ref.Parent=module
local ok,err=xpcall(function()
 local sent,messages={},{}
 local view=require(module).create(function()end,function(message)table.insert(messages,message)end)
 view.qaRemote({FireServer=function(_,command)table.insert(sent,command)end})
 view.use(1)
 check(#messages==1 and sent[1].action=='GetState','unloaded bag explains failure and requests state')
 local p=R.addHero(R.new(1),'h','mage',C);p.wallet.gold=100
 p=assert(R.shop(p,{action='Buy',requestId='purchase',heroId='h',revision=p.revision,offerId='health_potion',store='items'},{atLobby=true},C))
 local function snapshot(profile)
  local items={};for _,item in pairs(profile.items)do table.insert(items,item)end
  return {revision=profile.revision,ready=true,heroId='h',heroes=profile.heroes,items=items,safe=true,atHub=false,atStorage=false,pending=0,bagCapacity=C.bagCapacity,storageCapacity=C.storageCapacity,bagUsed=R.count(profile,'bag','h'),storageUsed=0}
 end
 local s=snapshot(p);view.qaReceive(s)
 sent={};view.use(1);local command=sent[1]
 check(command and command.action=='Use','purchased stacked potion submits use')
 view.qaReceive(s,command.requestId,'Busy')
 view.qaReceive(s,command.requestId,'Busy')
 view.use(1)
 check(#sent==1 and #messages>=3,'pending input gives feedback without creating another use')
 task.wait(.65)
 check(#sent==2 and sent[2]==command,'Busy retries the exact command once despite duplicate responses')
 local n=assert(R.apply(p,command,{canUse=true,restore='health',lifeToken='test-life'},C))
 check(R.quantity(n,'h','health_potion')==3,'one purchased/starter stack potion consumed')
 local replay,_,repeated=R.apply(n,command,{canUse=true,restore='health',lifeToken='test-life'},C)
 check(repeated and R.quantity(replay,'h','health_potion')==3,'exact retry cannot consume a second potion')
 view.qaReceive(snapshot(n),command.requestId)
 task.wait(.6);check(#sent==2,'success stops Busy retries')
 view.use(1);local nextCommand=sent[3]
 check(nextCommand and nextCommand.requestId~=command.requestId,'success permits next potion input')
 -- A newer unrelated update arrives before an older matching acknowledgement.
 local newer=R.copy(n);newer.revision+=2
 view.qaReceive(snapshot(newer))
 view.qaReceive(snapshot(n),nextCommand.requestId,'Changed')
 view.use(1)
 check(#sent==4 and sent[4].revision==newer.revision,'late acknowledgement releases pending without rolling back newer data')
 local lastCommand=sent[4]
 view.qaReceive(snapshot(newer),lastCommand.requestId,'SaveUnknown')
 view.use(1);task.wait(.65)
 check(#sent==4,'unknown save remains pending; input cannot create a second use')
 view.qaReceive(snapshot(newer),lastCommand.requestId)
 view.use(1);lastCommand=sent[5]
 check(lastCommand and lastCommand.requestId~=sent[4].requestId,'confirmed recovery allows the next use')
 view.qaReceive(snapshot(newer),lastCommand.requestId,'Busy')
 playerGui.InventoryGui:Destroy();task.wait(.65)
 check(#sent==5,'destroyed bag never retries a request')
end,debug.traceback)
root:Destroy();module:Destroy()
if not ok then table.insert(report.failures,tostring(err)) end
report.pass=#report.failures==0
print('POTION_REQUEST_RECOVERY_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'Potion request recovery failed')
