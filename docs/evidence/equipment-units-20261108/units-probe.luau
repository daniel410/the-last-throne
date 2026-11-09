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
 check(description:find('Attack +4.00%',1,true)~=nil,'shop percent suffix')
 check(description:find('Defense +4 pts',1,true)~=nil and description:find('Max HP +4 pts',1,true)~=nil,'shop flat units')
end
check(AT.Power=='Attack bonus (%)' and AT.Armor=='Defense (pts)' and AT.Health=='Max HP (pts)','enhancement unit labels')
check(CT.EquipmentPreview:find('(pts)',1,true)~=nil,'actual changes labelled as points')
check(CT.EquipmentNote:find('percentage points (pp)',1,true)~=nil,'percentage difference explained')
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
   if label.Text:find('Attack +4.00%',1,true) then found=true end
  end
 end
 check(found,'actual shop constructor shows veteran four percent: '..store)
 view.panel:Destroy()
end
gui:Destroy()
print('EQUIPMENT_UNITS_NATIVE '..checks..' checks PASS')
