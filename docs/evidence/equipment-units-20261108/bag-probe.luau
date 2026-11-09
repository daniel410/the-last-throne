-- Real bag rendering with a private snapshot seam; no simulated Player authority.
local client=game.StarterPlayer.StarterPlayerScripts.Client;local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules);local C=require(RS.Shared.ItemCatalog)
local report={kind='INVENTORY_IMPACT_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='BagImpactQA';folder.Parent=workspace
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=folder
local m=client.InventoryGui:Clone();m.Name='InventoryImpactQA'
local source=m.Source
source=source:gsub('local Players = game:GetService%("Players"%)','local Players={LocalPlayer={WaitForChild=function()return script.PlayerGui.Value end,GetAttribute=function(_,k)return script.PlayerGui.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.PlayerGui.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.PlayerGui.Value:GetAttributeChangedSignal(k)end}}')
source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
local start=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',start,true))
source=source:sub(1,start-1)..source:sub(last)
source=source:gsub('\n\treturn {\n\t\topen=', '\n\treturn {\n  qaSnapshot=function(value,id) snapshot=value;selectedId=id;opened=true;render();resize() end,\n\t\topen=')
m.Source=source;m.Parent=client;local ref=Instance.new('ObjectValue');ref.Name='PlayerGui';ref.Value=playerGui;ref.Parent=m
local ok,err=xpcall(function()
 local view=require(m).create(function()end,function()end)
 for _,class in ipairs({'knight','elf','dwarf','mage'})do
  local p=R.addHero(R.new(3),class,class,C);local list,id={},nil
  for _,item in pairs(p.items)do table.insert(list,item);if item.definitionId==class..'_weapon_fine'then id=item.instanceId end end
  id='units-'..class
  table.insert(list,{instanceId=id,definitionId=class..'_weapon_veteran',location={kind='bag',heroId=class},quantity=1,binding='account',version=1})
  local snapshot={ready=true,heroId=class,heroes=p.heroes,items=list,revision=p.revision,bagCapacity=C.bagCapacity,storageCapacity=C.storageCapacity,safe=true,atHub=true,atStorage=false,pending=1,bagUsed=R.count(p,'bag',class),storageUsed=0,stats=R.stats(p,class,C)}
  view.qaSnapshot(snapshot,id)
  local gui=playerGui.InventoryGui;local comparison=assert(gui:FindFirstChild('Comparison',true));local impact=assert(gui:FindFirstChild('ActualStatChanges',true))
  check(comparison.Text:find('4.00%',1,true) and comparison.Text:find(' pts',1,true) and comparison.Text:find(' pp',1,true),'bag explicitly distinguishes percentage, flat points and percentage-point difference')
  check(impact.Text:find('(pts)',1,true),'actual stat changes have point unit')
  check(impact.Position.Y.Offset>=comparison.Position.Y.Offset+comparison.Size.Y.Offset,'actual stat deltas appear below Current -> Selected')
  for _,label in ipairs({'Physical Power','Magic Power','Defense','Max HP','Max MP'})do check(impact.Text:find(label,1,true)~=nil,'bag lists actual '..label..' including zero bonuses')end
  check(gui:FindFirstChild('ActualStatNote',true).Text:find('do not refill',1,true)~=nil,'bag does not promise HP/MP restoration')
  check(impact.Text:find('(+',1,true)~=nil,'compatible upgraded weapon shows signed actual increase')
 end
 view.close()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();m:Destroy();report.pass=#report.failures==0
print('INVENTORY_IMPACT_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Bag stat display failed')
