-- Fixed trial rate: 1 Diamond buys 50 RPG account Gold; no bundle bonus.
-- Retire the 100-Gold SKU rather than changing its promised amount under the same ID.
local C={version=2,storyDiamonds=3,offers={},sell={},goldOffers={
 {id='rpg_gold_500_diamond',currency='diamonds',price=10,amount=500},
 {id='rpg_gold_1000_diamond',currency='diamonds',price=20,amount=1000},
 {id='rpg_gold_2000_diamond',currency='diamonds',price=40,amount=2000},
}}
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
  local price=(resource=='health' and {25,60,100,200} or {20,40,80,160})[tier]
  table.insert(C.offers,{id=id,definitionId=id,currency='gold',price=price});C.sell[id]=math.floor(price/5)
 end
end
for _,kind in ipairs({'stat','skill'}) do
 table.insert(C.offers,{id=kind..'_reset_ticket_diamond',definitionId=kind..'_reset_ticket',currency='diamonds',price=100})
end
C.categories={{id='All',label='ALL'},{id='Weapons',label='WEAPONS'},{id='Armor',label='ARMOR'},{id='Accessories',label='ACCESSORIES'},{id='Potions',label='POTIONS'},{id='Resets',label='RESET TICKETS'}}
function C.category(definition)
 if definition.reset then return 'Resets' end
 if definition.restore then return 'Potions' end
 if definition.slot=='weapon' then return 'Weapons' end
 if definition.slot=='accessory' then return 'Accessories' end
 return 'Armor'
end
for _,row in ipairs({{'traveler_hood',80},{'traveler_coat',120},{'traveler_gloves',80},{'traveler_boots',80},{'copper_ring',150},{'amber_charm',150},{'veteran_hood',250}}) do
 table.insert(C.offers,{id=row[1],definitionId=row[1],currency='gold',price=row[2]});C.sell[row[1]]=math.floor(row[2]/5)
end
-- Rare and Epic forge gear is sold only for Diamonds. Retire former Gold offer IDs.
-- Keep the existing four weapon Diamond SKU IDs and prices unchanged.
C.forgeDiamondStock={} -- Current assortment excludes all 24 retired Lv10 goods.
C.retiredForgeDiamondStock={
 {id='knight_weapon_forged',rare=18,epic=30,sell=190},
 {id='elf_weapon_forged',rare=18,epic=30,sell=190},
 {id='dwarf_weapon_forged',rare=18,epic=30,sell=190},
 {id='mage_weapon_forged',rare=18,epic=30,sell=190},
 {id='sentinel_shield',rare=10,epic=18,sell=100},
 {id='sentinel_helm',rare=8,epic=14,sell=80},
 {id='sentinel_mail',rare=13,epic=22,sell=130},
 {id='sentinel_gauntlets',rare=8,epic=14,sell=80},
 {id='sentinel_boots',rare=8,epic=14,sell=80},
 {id='ruby_ring',rare=11,epic=18,sell=110},
 {id='guardian_charm',rare=11,epic=18,sell=110},
 {id='storm_pendant',rare=11,epic=18,sell=110},
}
-- Historical rows retain resale values; they are not purchase offers.
for _,row in ipairs(C.retiredForgeDiamondStock)do
 C.sell[row.id]=row.sell;C.sell[row.id..'_epic']=row.sell
end
function C.diamondGear(definition)
 return definition and definition.category=='Equipment' and (definition.rarity=='Rare' or definition.rarity=='Epic')
end
function C.allowed(store,definition,offer)
 if definition and definition.retired then return offer==nil and (store==nil or store=='blacksmith') end
 if offer and C.diamondGear(definition) and offer.currency~='diamonds' then return false end
 if store=='diamonds' then return offer and offer.currency=='diamonds' end
 if store=='blacksmith' then return definition.category=='Equipment' and (not offer or (C.diamondGear(definition) and offer.currency=='diamonds') or (not C.diamondGear(definition) and offer.currency=='gold')) end
 if store=='items' then return (definition.category~='Equipment' or definition.slot=='accessory') and (not offer or offer.currency=='gold') end
 return true
end
function C.offer(id) for _,v in ipairs(C.offers) do if v.id==id then return v end end end
function C.goldOffer(id) for _,v in ipairs(C.goldOffers)do if v.id==id then return v end end end
return C
