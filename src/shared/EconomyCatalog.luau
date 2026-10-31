local C={version=1,storyDiamonds=2,offers={},sell={}}
for _,class in ipairs({'knight','elf','dwarf','mage'}) do
 local fine=class..'_weapon_fine';local veteran=class..'_weapon_veteran'
 table.insert(C.offers,{id=fine,definitionId=fine,currency='gold',price=250})
 table.insert(C.offers,{id=veteran,definitionId=veteran,currency='gold',price=600})
 table.insert(C.offers,{id=veteran..'_diamond',definitionId=veteran,currency='diamonds',price=10})
 C.sell[fine]=50;C.sell[veteran]=120
end
table.insert(C.offers,{id='knight_shield_fine',definitionId='knight_shield_fine',currency='gold',price=250})
C.sell.knight_shield_fine=50
-- Provisional Diamond Shop assortment; prices and balance require playtesting.
for _,row in ipairs({{'knight_shield_fine',5},{'traveler_hood',2},{'traveler_coat',3},{'traveler_gloves',2},{'traveler_boots',2},{'copper_ring',4},{'amber_charm',4},{'veteran_hood',6}}) do
 table.insert(C.offers,{id=row[1]..'_diamond',definitionId=row[1],currency='diamonds',price=row[2]})
end
-- Gold prices are provisional; all classes may buy for their bag/shared storage.
for _,resource in ipairs({'health','mana'}) do
 for tier,size in ipairs({'','_medium','_large','_xl'}) do
  local id=resource..'_potion'..size
  table.insert(C.offers,{id=id,definitionId=id,currency='gold',price=(resource=='health' and {20,50,80,150} or {15,30,60,120})[tier]})
 end
end
C.categories={{id='All',label='ALL'},{id='Weapons',label='WEAPONS'},{id='Armor',label='ARMOR'},{id='Accessories',label='ACCESSORIES'},{id='Potions',label='POTIONS'}}
function C.category(definition)
 if definition.restore then return 'Potions' end
 if definition.slot=='weapon' then return 'Weapons' end
 if definition.slot=='accessory' then return 'Accessories' end
 return 'Armor'
end
for _,row in ipairs({{'traveler_hood',80},{'traveler_coat',120},{'traveler_gloves',80},{'traveler_boots',80},{'copper_ring',150},{'amber_charm',150},{'veteran_hood',250}}) do
 table.insert(C.offers,{id=row[1],definitionId=row[1],currency='gold',price=row[2]});C.sell[row[1]]=math.floor(row[2]/5)
end
function C.offer(id) for _,v in ipairs(C.offers) do if v.id==id then return v end end end
return C
