-- Fixed trial rate: 1 Diamond buys 50 RPG account Gold; no bundle bonus.
-- Retire the 100-Gold SKU rather than changing its promised amount under the same ID.
local C={version=8,offers={},sell={},goldOffers={
 {id='rpg_gold_500_diamond',currency='diamonds',price=10,amount=500},
 {id='rpg_gold_1000_diamond',currency='diamonds',price=20,amount=1000},
 {id='rpg_gold_2000_diamond',currency='diamonds',price=40,amount=2000},
}}
-- Stable main-story IDs only; side quests and prologue never mint Diamonds.
C.storyDiamondModes={Hard=true,Insane=true,Hell=true}
C.storyDiamondsByMode={Easy=3,Hard=5,Insane=7,Hell=10}
C.storyDiamondIds={}
for _,prefix in ipairs({'DW','GW','FV','EC','HG'})do
 for i=1,7 do C.storyDiamondIds[string.format('%s-%02d',prefix,i)]=true end
end
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
-- Retired products retain their historical resale values.
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
local Items=game and require(script.Parent.ItemCatalog)or dofile('src/shared/ItemCatalog.luau')
local Pricing=game and require(script.Parent.EquipmentPricing)or dofile('src/shared/EquipmentPricing.luau')
C.equipmentPricingVersion=Pricing.version
for _,id in ipairs(Items.tierEquipment)do
 local definition=Items.items[id]
 local price,currency=Pricing.price(definition)
 if price then
  table.insert(C.offers,{id=currency=='diamonds'and id..'_diamond'or id,definitionId=id,currency=currency,price=price})
 end
 C.sell[id]=Pricing.resale(definition)
end
-- Preserve existing alternate-currency SKU IDs, with the same 50-Gold exchange basis.
local diamondAlternatives={'knight_shield_fine','veteran_hood'}
for _,class in ipairs({'knight','elf','dwarf','mage'})do table.insert(diamondAlternatives,class..'_weapon_veteran')end
for _,id in ipairs(diamondAlternatives)do
 local price,currency=Pricing.price(Items.items[id]);assert(currency=='gold'and price%Pricing.goldPerDiamond==0)
 table.insert(C.offers,{id=id..'_diamond',definitionId=id,currency='diamonds',price=price/Pricing.goldPerDiamond})
end
for _,id in ipairs({'copper_ring','amber_charm','amber_mana_charm'})do
 local definition=Items.items[id];local price=Pricing.price(definition)
 table.insert(C.offers,{id=id,definitionId=id,currency='gold',price=price})
 table.insert(C.offers,{id=id..'_diamond',definitionId=id,currency='diamonds',price=price/Pricing.goldPerDiamond})
 C.sell[id]=Pricing.resale(definition)
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
