-- End-to-end starter loadout: server equip reducer -> current definitions -> UI totals.
local R=game and require(game.ServerScriptService.Server.Inventory.InventoryRules) or dofile('src/server/Inventory/InventoryRules.luau')
local C=game and require(game.ReplicatedStorage.Shared.ItemCatalog) or dofile('src/shared/ItemCatalog.luau')
local G=game and require(game.ReplicatedStorage.Shared.HeroProgression) or dofile('src/shared/HeroProgression.luau')
local P=game and require(game.ReplicatedStorage.Shared.SkillStatPreview) or dofile('src/shared/SkillStatPreview.luau')
local n=0
local function eq(a,b,label)n=n+1;assert(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local p=assert(R.addHero(R.new(42),'hero',class,C))
 local ids={class..'_weapon_fine','traveler_hood','traveler_coat','traveler_gloves','traveler_boots','copper_ring','amber_charm'}
 for i,id in ipairs(ids)do
  local item
  for _,candidate in pairs(p.items)do if candidate.definitionId==id then item=candidate end end
  p=assert(R.apply(p,{action='Equip',requestId='equip-'..i,heroId='hero',instanceId=item.instanceId,itemVersion=item.version,revision=p.revision},{safe=true,atHub=true},C))
 end
 local stats=R.stats(p,'hero',C)
 eq(stats.power,5,class..' starter power ceiling');eq(stats.health,50,class..' starter HP ceiling');eq(stats.armor,5,class..' starter armor ceiling')
 local base=G.derived(class,p.heroes.hero.progression)
 local total=P.derived(class,p.heroes.hero.progression,stats)
 eq(total.health,base.health+50,class..' UI HP follows equipped server stats')
 eq(total.physicalPower,base.physicalPower*1.05,class..' physical power uses5 percent')
 eq(total.magicPower,base.magicPower*1.05,class..' magic power uses5 percent')
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
eq(C.items.veteran_hood.stats.armor,2,'free Lv5 hood remains modest')
print('Starter gear balance: '..n..' checks passed')
