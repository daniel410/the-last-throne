assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated place only')
local S=game.ReplicatedStorage.Shared
local C=require(S.ItemCatalog)
local G=require(S.HeroProgression)
local P=require(S.SkillStatPreview)
local Text=require(S.InventoryText)
local CT=require(S.CombatStatText)
local AT=require(S.AdventureText)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
 local def=C.items[classId..'_weapon_veteran']
 check(def.stats.power==4,'veteran weapon is four percent')
 local g=G.new(5);local before=P.derived(classId,g,{})
 local after=P.derived(classId,g,def.stats)
 check(math.abs(after.physicalPower-before.physicalPower*1.04)<.000001,'physical power +4%')
 check(math.abs(after.magicPower-before.magicPower*1.04)<.000001,'magic power +4%')
 local armor=P.derived(classId,g,{armor=4,health=4})
 check(armor.armor-before.armor==4 and armor.health-before.health==4,'flat defense and HP +4 pts')
 local description=string.format(Text.ShopGearStats,'All classes','Common',5,4,string.format(Text.FlatDefense,4),string.format(Text.FlatHealth,4),'')
 check(description:find('Attack +4.0%',1,true)~=nil,'shop percent suffix')
 check(description:find('Defense +4 pts',1,true)~=nil and description:find('Max HP +4 pts',1,true)~=nil,'shop flat units')
end
check(AT.Power=='Attack bonus (%)' and AT.Armor=='Defense (pts)' and AT.Health=='Max HP (pts)','enhancement unit labels')
check(CT.EquipmentPreview:find('(pts)',1,true)~=nil,'actual changes labelled as points')
check(CT.EquipmentNote:find('pp (percentage points)',1,true)~=nil,'percentage difference explained')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local profile=R.addHero(R.new(81),'h','knight',C)
local items={};for _,i in pairs(profile.items) do table.insert(items,i) end
local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
for _,store in ipairs({'blacksmith','all'}) do
 local view=require(client.ArmoryView).create(gui,function()error('no transactions permitted')end,false,store)
 view.render({ready=true,heroId='h',heroes=profile.heroes,items=items,wallet=profile.wallet,revision=profile.revision})
 if store=='all' then view.selectCategory('Weapons') end
 local found=false
 for _,label in ipairs(view.panel:GetDescendants()) do
  if label:IsA('TextLabel') and label.Name=='Details' then
   check(not label.Text:find('Power +',1,true),'ambiguous shop power label removed')
   if label.Text:find('Attack +4.0%',1,true) then found=true end
  end
 end
 check(found,'actual shop constructor shows veteran four percent: '..store)
 view.panel:Destroy()
end
gui:Destroy()
print('EQUIPMENT_UNITS_NATIVE '..checks..' checks PASS')

for _,case in ipairs({{4,'+4.0%'},{4.16,'+4.2%'},{0,'+0.0%'},{-1.25,'-1.2%'}}) do
 check(string.format(CT.AttackBonus,case[1]):find(case[2],1,true)~=nil,'one decimal total')
 check(string.format(CT.GearPower,case[1]):find(case[2],1,true)~=nil,'one decimal gear source')
end
check(string.format(AT.PowerChange,4,4.123)=='Attack bonus: 4.0% → 4.1%','one decimal enhancement preview')
print('PERCENT_FORMAT_NATIVE '..checks..' checks PASS')
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
  check(comparison.Text:find('4.0%',1,true) and comparison.Text:find(' pts',1,true) and comparison.Text:find(' pp',1,true),'bag explicitly distinguishes percentage, flat points and percentage-point difference')
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
