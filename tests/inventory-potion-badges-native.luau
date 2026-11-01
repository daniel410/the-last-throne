-- Synthetic inventory snapshots; production request loop is removed from this fixture.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local report={kind='INVENTORY_POTION_BADGES_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local facade=Instance.new('Folder');facade:SetAttribute('K0SessionPhase','Lobby');facade.Parent=workspace
local m=client.InventoryGui:Clone();m.Name='InventoryPotionBadgesQA'
local source=m.Source:gsub('local Players = game:GetService%("Players"%)',[[local Players={LocalPlayer={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return script.Facade.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.Facade.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.Facade.Value:GetAttributeChangedSignal(k)end}}]])
source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
local first=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',first,true));source=source:sub(1,first-1)..source:sub(last)
source=source:gsub('\n\treturn {\n\t\topen=',[[
 return {
  qaSet=function(value,id,detail) snapshot=value;opened=true;category="All";selectedId=id;mobileDetail=detail==true;resize();render()end,
  open=]])
m.Source=source;local ref=Instance.new('ObjectValue');ref.Name='Facade';ref.Value=facade;ref.Parent=m;m.Parent=client
local ok,err=xpcall(function()
 local p=R.addHero(R.new(99),'hero','knight',C);local items={};local id
 for _,item in p.items do table.insert(items,item);if item.location.kind=='bag' and item.definitionId=='health_potion' then item.quantity=99;id=item.instanceId end end
 table.insert(items,{instanceId='medium',definitionId='health_potion_medium',quantity=2,version=1,location={kind='bag',heroId='hero'}})
 table.insert(items,{instanceId='ore',definitionId='iron_ore',quantity=999,version=1,location={kind='bag',heroId='hero'}})
 local snapshot={ready=true,heroId='hero',heroes=p.heroes,items=items,revision=1,bagCapacity=60,storageCapacity=120,safe=true,atHub=true,atStorage=false,pending=0,bagUsed=5,storageUsed=0}
 local view=require(m).create(function()end,function()end);local gui=game.CoreGui.InventoryGui;local overlay=gui.InventoryOverlay
 for _,size in ipairs({Vector2.new(1160,760),Vector2.new(750,323),Vector2.new(390,780)})do
  overlay.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
  view.qaSet(snapshot,id,false);task.wait(.1)
  local small=assert(gui:FindFirstChild('Item_'..id,true));local medium=assert(gui:FindFirstChild('Item_medium',true));local ore=assert(gui:FindFirstChild('Item_ore',true))
  check(small.QuickSlotBadge.Text=='Z' and medium.QuickSlotBadge.Text=='C','correct independent quick keys')
  check(small.ItemStatus.Text=='x99' and medium.ItemStatus.Text=='x2' and ore.ItemStatus.Text=='x999','exact stack quantities')
  for _,card in ipairs({small,medium})do
   for _,badge in ipairs({card.QuickSlotBadge,card.ItemStatus})do
    check(badge.BackgroundTransparency==0 and badge.Font==Enum.Font.GothamBold,'opaque bold badge')
    check(badge.TextSize>=14 and badge.TextFits,'readable badge fits')
    check(badge.ZIndex>card.ZIndex,'badge above item art')
    check(badge.AbsolutePosition.X>=card.AbsolutePosition.X and badge.AbsolutePosition.X+badge.AbsoluteSize.X<=card.AbsolutePosition.X+card.AbsoluteSize.X,'badge stays inside cell')
   end
   check(card.QuickSlotBadge.AbsolutePosition.Y+card.QuickSlotBadge.AbsoluteSize.Y<card.ItemName.AbsolutePosition.Y,'quick key clears item name')
  end
  check(ore.ItemStatus.TextFits,'three digit material quantity fits')
  p.heroes.hero.quickSlots={'health_potion','health_potion'};view.qaSet(snapshot,id,false);task.wait()
  small=assert(gui:FindFirstChild('Item_'..id,true));check(small.QuickSlotBadge.Text=='Z / C' and small.QuickSlotBadge.TextFits,'both keys remain visible')
  p.heroes.hero.quickSlots={'health_potion','health_potion_medium'}
  for _,item in items do if item.instanceId==id then item.locked=true end end
  view.qaSet(snapshot,id,false);task.wait();small=assert(gui:FindFirstChild('Item_'..id,true))
  check(small.ItemStatus.Text=='LOCK  x99' and small.ItemStatus.TextFits,'locked stack preserves count and lock')
  view.qaSet(snapshot,id,true);task.wait()
  check(gui:FindFirstChild('PotionQuantity',true).Text=='QUANTITY: 99','detail repeats exact stack quantity')
  check(gui:FindFirstChild('QuickSlotStatus',true).TextSize==16,'detail quick key is larger')
  for _,item in items do if item.instanceId==id then item.locked=nil end end
 end
 gui:Destroy()
end,debug.traceback)
m:Destroy();facade:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
