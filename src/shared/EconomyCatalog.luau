local C={version=1,storyDiamonds=2,offers={},sell={},goldOffers={{id='rpg_gold_100_diamond',currency='diamonds',price=10,amount=100}}}
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
  local price=(resource=='health' and {20,50,80,150} or {15,30,60,120})[tier]
  table.insert(C.offers,{id=id,definitionId=id,currency='gold',price=price});C.sell[id]=math.floor(price/5)
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
-- Blacksmith additions: Gold-only trial stock, never story reward replacements.
for _,row in ipairs({{'knight_weapon_forged',950},{'elf_weapon_forged',950},{'dwarf_weapon_forged',950},{'mage_weapon_forged',950},{'sentinel_shield',500},{'sentinel_helm',400},{'sentinel_mail',650},{'sentinel_gauntlets',400},{'sentinel_boots',400},{'ruby_ring',550},{'guardian_charm',550},{'storm_pendant',550}})do
 table.insert(C.offers,{id=row[1],definitionId=row[1],currency='gold',price=row[2]});C.sell[row[1]]=math.floor(row[2]/5)
end
function C.allowed(store,definition,offer)
 if store=='diamonds' then return offer and offer.currency=='diamonds' end
 if store=='blacksmith' then return definition.category=='Equipment' and (not offer or offer.currency=='gold') end
 if store=='items' then return definition.slot~='weapon' and (not offer or offer.currency=='gold') end
 return true
end
function C.offer(id) for _,v in ipairs(C.offers) do if v.id==id then return v end end end
function C.goldOffer(id) for _,v in ipairs(C.goldOffers)do if v.id==id then return v end end end
return C
