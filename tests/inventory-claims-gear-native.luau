local client=game.StarterPlayer.StarterPlayerScripts.Client;local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules);local C=require(RS.Shared.ItemCatalog)
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local report={kind='INVENTORY_CLAIMS_GEAR_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='ClaimsGearQA';fixture.Parent=workspace
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=fixture
local copies={}
local ok,err=xpcall(function()
 local p=assert(R.addHero(R.new(5),'hero','knight',C));local list,pendingId={}
 for _,item in pairs(p.items)do table.insert(list,item);if item.location.kind=='pending'then pendingId=item.instanceId end end
 for _,width in ipairs({1100,500})do
  local m=client.InventoryGui:Clone();m.Name='ClaimsGearQA'..width;table.insert(copies,m)
  local source=m.Source:gsub('local Players = game:GetService%("Players"%)','local Players={LocalPlayer={WaitForChild=function()return script.PlayerGui.Value end,GetAttribute=function(_,k)return script.PlayerGui.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.PlayerGui.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.PlayerGui.Value:GetAttributeChangedSignal(k)end}}')
  source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
  source=source:gsub('local width,height=shell.AbsoluteSize.X,shell.AbsoluteSize.Y','local width,height='..width..',700')
  local start=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',start,true));source=source:sub(1,start-1)..source:sub(last)
  source=source:gsub('\n\treturn {\n\t\topen=', '\n\treturn {\n  qaBag=function(value) snapshot=value;sourceTab="bag";opened=true;resize();render() end,\n  qaClaims=function(value,id) snapshot=value;sourceTab="pending";selectedId=id;opened=true;resize();render() end,\n  qaReceive=receiveInventory,\n\t\topen=')
  m.Source=source;m.Parent=client;local ref=Instance.new('ObjectValue');ref.Name='PlayerGui';ref.Value=playerGui;ref.Parent=m
  local view=require(m).create(function()end,function()end)
  local snapshot={ready=true,heroId='hero',heroes=p.heroes,items=list,revision=p.revision,bagCapacity=C.bagCapacity,storageCapacity=C.storageCapacity,safe=true,atHub=false,atStorage=false,pending=1,bagUsed=R.count(p,'bag','hero'),storageUsed=0}
  view.qaBag(snapshot)
  local gui=playerGui.InventoryGui;local preview=assert(gui:FindFirstChild('HeroPreview',true));local slots=preview.EquipmentSlots
  check(slots.Visible and #slots:GetChildren()==8,'all eight gear slots are always rendered at width '..width)
  check(gui:FindFirstChild('ViewEquipment',true).Visible==(width<900),'gear switch is limited to compact navigation')
  view.qaClaims(snapshot,pendingId)
  local popup=assert(gui:FindFirstChild('ClaimsPopup',true));local message=popup.InventoryMessage;local primary=popup:FindFirstChild('PrimaryAction',true)
  check(message.Text=='Return to the lobby to claim unclaimed items.','claims window explains the lobby requirement')
  check(not primary.Active and popup:FindFirstChild('ActionBlockedReason',true)~=nil,'field claim is disabled with a visible reason')
  local hub=table.clone(snapshot);hub.atHub=true;view.qaReceive(hub,nil,nil)
  check(primary.Active and message.Text=='Select an item to claim it to your bag.','returning to lobby refreshes claim without a revision change')
  check(popup:FindFirstChild('ActionBlockedReason',true)==nil,'lobby removes the stale restriction')
  view.close()
 end
end,debug.traceback)
for _,m in ipairs(copies)do m:Destroy()end;fixture:Destroy()
if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
