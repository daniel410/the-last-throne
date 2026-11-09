-- Fixed single-option equipment. IDs survive balancing; deleted trial IDs stay separate.
local F={version=3,tiers={
 {id='traveler',name='Traveler',rarity='Common',level=1,low=3,high=3,resource=20,secondary=2},
 {id='tempered',name='Tempered',rarity='Common',level=1,low=5,high=5,resource=30,secondary=4},
 {id='veteran',name='Veteran',rarity='Uncommon',level=10,low=10,high=10,resource=40,secondary=7},
 {id='sentinel',name='Sentinel',rarity='Rare',level=10,low=20,high=20,resource=50,secondary=15},
},weapons={knight='Sword',dwarf='Axe',elf='Bow',mage='Staff'}}
function F.weapon(tier,class)
 return class..'_weapon_'..(tier=='tempered' and 'fine' or tier)
end
function F.piece(tier,slot)
 if slot=='offhand' then return tier=='traveler' and 'knight_shield' or tier=='tempered' and 'knight_shield_fine' or tier..'_tier_shield' end
 local suffix=({head='hood',body='coat',hands='gloves',feet='boots'})[slot]
 return (tier=='sentinel' and 'sentinel_tier' or tier)..'_'..suffix
end
function F.mageBody(tier)return 'mage_'..tier..'_coat'end
-- Existing historical Rare copies migrate; deleted Dawnforge/Gauntlets never do.
F.legacy={sentinel_shield='offhand',sentinel_helm='head',sentinel_mail='body',sentinel_boots='feet'}
return F
