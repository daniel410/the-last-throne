-- End-to-end starter loadout: server equip reducer -> current definitions -> UI totals.
local R=game and require(game.ServerScriptService.Server.Inventory.InventoryRules) or dofile('src/server/Inventory/InventoryRules.luau')
local C=game and require(game.ReplicatedStorage.Shared.ItemCatalog) or dofile('src/shared/ItemCatalog.luau')
local G=game and require(game.ReplicatedStorage.Shared.HeroProgression) or dofile('src/shared/HeroProgression.luau')
local F=game and require(game.ReplicatedStorage.Shared.EquipmentTransactions) or dofile('src/shared/EquipmentTransactions.luau')
local P=game and require(game.ReplicatedStorage.Shared.SkillStatPreview) or dofile('src/shared/SkillStatPreview.luau')
local n=0
local function eq(a,b,label)n=n+1;assert(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local p=assert(R.addHero(R.new(42),'hero',class,C))
 local ids={class..'_weapon_traveler',(class=='mage'and 'mage_traveler_hat'or 'traveler_hood'),(class=='mage'and 'mage_traveler_coat'or 'traveler_coat'),'traveler_gloves','traveler_boots','copper_ring','amber_charm'}
 for _,id in ipairs(ids)do
  local count=0
  for _,item in pairs(p.items)do if item.definitionId==id then
   count=count+1;eq(item.location.kind,'equipped',class..' starts wearing '..id)
  end end
  eq(count,1,class..' receives exactly one '..id)
 end
 eq(R.equipped(p,'hero','weapon').definitionId,class..'_weapon_traveler',class..' starts with real weapon')
 eq(C.items[class..'_weapon_traveler'].rarity,'Common',class..' starter is Common')
 eq(C.items[class..'_weapon_traveler'].stats.power,3,class..' starter weapon power')
 eq(R.equipped(p,'hero','head').definitionId,class=='mage'and 'mage_traveler_hat'or 'traveler_hood',class..' wears level1 headgear')
 eq(R.equipped(p,'hero','accessory1').definitionId,'copper_ring',class..' auto accessory1')
 eq(R.equipped(p,'hero','accessory2').definitionId,'amber_charm',class..' auto accessory2')
 eq(R.quantity(p,'hero','veteran_hood'),1,class..' level5 bonus stays in bag')
 for _,item in pairs(p.items)do eq(item.definitionId==class..'_weapon',false,class..' no training weapon') end
 eq(R.count(p,'equipped'),class=='knight' and 8 or 7,class..' all eligible slots filled')
 eq(R.validate(p,C),true,class..' creation is valid')
 eq(F.grant(p,R,C,'hero',class..'_weapon',1,'retired-test'),false,class..' retired training weapon cannot be granted')
 eq(R.quantity(p,'hero',class..'_weapon'),0,class..' retired grant adds no training weapon')
 local stats=R.stats(p,'hero',C)
 eq(stats.power,5,class..' starter power');eq(stats.health,class=='mage'and 30 or 50,class..' starter HP');eq(stats.mana,class=='mage'and 20 or 0,class..' starter MP');eq(stats.armor,class=='knight'and 8 or class=='mage'and 2 or 5,class..' starter defense')
 local base=G.derived(class,p.heroes.hero.progression)
 local total=P.derived(class,p.heroes.hero.progression,stats)
 eq(total.health,base.health+stats.health,class..' UI HP follows equipped server stats')
 eq(total.physicalPower,base.physicalPower+5,class..' physical power adds5 points')
 eq(total.magicPower,base.magicPower+5+(class=='mage'and 6 or 0),class..' magic power adds5 points')
 -- Saved instances contain identity/enhancement, not a frozen copy of old bonuses.
 local restored=R.copy(p)
 for _,item in pairs(restored.items)do item.definitionVersion=1 end
 eq(R.validate(restored,C),true,class..' existing instance schema remains valid')
 local loaded=R.stats(restored,'hero',C)
 eq(loaded.power,stats.power,class..' saved equipment follows current power')
 eq(loaded.health,stats.health,class..' saved equipment follows current HP')
 eq(loaded.armor,stats.armor,class..' saved equipment follows current armor')
 eq(R.quantity(restored,'hero','health_potion'),3,class..' potion stock preserved')
end
eq(C.items.veteran_hood.stats.armor,15,'bonus Veteran hood follows new tier')
print('Starter gear balance: '..n..' checks passed')
