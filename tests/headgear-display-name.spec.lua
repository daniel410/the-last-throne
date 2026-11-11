local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local Visual=dofile('src/shared/FourFamilyArmorVisuals.luau')
local Preview=dofile('src/shared/SkillStatPreview.luau')
local n=0
for _,tier in ipairs(C.equipmentFamilies.tiers)do
 local id=C.equipmentFamilies.piece(tier.id,'head')
 local d=C.items[id]
 local original=d.name
 for _,class in ipairs({'knight','dwarf','elf','mage'})do
  local expected=tier.name..((class=='knight' or class=='dwarf')and ' Helmet' or ' Hood')
  assert(E.name(d,nil,class)==expected)
  assert(E.name(d,{enhancementLevel=3},class)==expected..' +3')
  assert(Visual.models[id][class]==tier.id..((class=='knight' or class=='dwarf')and '_helmet' or '_hood'))
  local sources=Preview.gearSources('hero',{{definitionId=id,enhancementLevel=3,location={kind='equipped',heroId='hero',slot='head'}}},C,class)
  assert(sources[1].name==expected..' +3')
  n=n+4
 end
 assert(E.name(d)==original and d.name==original)
 local hat=C.items[C.equipmentFamilies.mageHat(tier.id)]
 assert(E.name(hat,nil,'mage')==hat.name)
end
print('PASS: '..n..' class/family headgear name, enhancement, model mapping and stat-source checks; default hood and Mage hats preserved')
