-- Isolated native GUI fixture; does not simulate published client or touch input.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(RS.Shared.ItemCatalog)
local report={kind='INVENTORY_MOBILE_LAYOUT_NATIVE',checks=0,failures={}}
local function check(value,label) report.checks+=1;assert(value,label) end
local facade=Instance.new('Folder');facade:SetAttribute('K0SessionPhase','Lobby');facade.Parent=workspace
local module=client.InventoryGui:Clone();module.Name='MobileInventoryQA'
local source=module.Source:gsub('local Players = game:GetService%("Players"%)',[[local Players={LocalPlayer={WaitForChild=function()return game:GetService('CoreGui') end,GetAttribute=function(_,k)return script.Facade.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.Facade.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.Facade.Value:GetAttributeChangedSignal(k)end}}]])
source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
local start=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',start,true));source=source:sub(1,start-1)..source:sub(last)
source=source:gsub('\n\treturn {\n\t\topen=',[[
 return {
  qaSet=function(value,gear,detail,id) snapshot=value;opened=true;gearMode=gear;mobileDetail=detail;selectedId=id;resize();render() end,
  open=]])
module.Source=source;local ref=Instance.new('ObjectValue');ref.Name='Facade';ref.Value=facade;ref.Parent=module;module.Parent=client
local ok,err=xpcall(function()
 local profile=assert(R.addHero(R.new(5),'hero','knight',C));local items={};local id
 for _,item in pairs(profile.items) do table.insert(items,item);if item.location.kind=='bag' then id=item.instanceId end end
 local snapshot={ready=true,heroId='hero',heroes=profile.heroes,items=items,revision=profile.revision,bagCapacity=C.bagCapacity,storageCapacity=C.storageCapacity,safe=true,atHub=true,atStorage=false,pending=1,bagUsed=R.count(profile,'bag','hero'),storageUsed=0}
 local view=require(module).create(function()end,function()end)
 local gui=game.CoreGui.InventoryGui;local overlay=gui.InventoryOverlay
 for _,size in ipairs({Vector2.new(750,323),Vector2.new(750,280),Vector2.new(568,320),Vector2.new(390,844),Vector2.new(320,568)})do
 overlay.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
 view.qaSet(snapshot,false,false,nil);task.wait()
 local panel=overlay.InventoryPanel;local content=panel.Content;local bag=content.BagItems
 check(bag.Items.AbsoluteSize.Y>=bag.Items.UIGridLayout.CellSize.Y.Offset,'bag shows a complete item row '..tostring(size))
 view.qaSet(snapshot,true,false,nil);task.wait()
 local preview=content.HeroPreview;check(preview.Visible and not panel.Filters.Visible,'gear view uses its own expanded area')
 for _,slot in ipairs(C.slots) do
  local cell=preview.EquipmentSlots['EquipSlot_'..slot]
  check(cell and cell.AbsolutePosition.Y+cell.AbsoluteSize.Y<=preview.AbsolutePosition.Y+preview.AbsoluteSize.Y,'gear slot fits: '..slot)
 end
 if id then
  view.qaSet(snapshot,false,true,id);task.wait()
  check(content.ItemDetails.Visible and not panel.Filters.Visible,'item detail gets expanded space')
  local details=content.ItemDetails
  check(details.Description.AbsoluteSize.Y>=100,'item description has readable scroll area')
  check(details.PrimaryAction.AbsolutePosition.Y>=details.Description.AbsolutePosition.Y+details.Description.AbsoluteSize.Y,'item action clears description')
 end
 end
 gui:Destroy()
end,debug.traceback)
module:Destroy();facade:Destroy();if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;print('INVENTORY_MOBILE_LAYOUT_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(ok,'mobile inventory fixture failed')
