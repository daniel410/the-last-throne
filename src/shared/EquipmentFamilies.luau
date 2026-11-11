-- Fixed single-option equipment. IDs survive balancing; deleted trial IDs stay separate.
local F={version=6,tiers={
 {id='traveler',hatMana=10,name='Traveler',rarity='Common',level=1,low=3,high=3,resource=20,secondary=2},
 {id='tempered',hatMana=20,name='Tempered',rarity='Common',level=1,low=6,high=6,resource=30,secondary=4},
 {id='veteran',hatMana=30,name='Veteran',rarity='Uncommon',level=10,low=15,high=15,resource=50,secondary=10},
 {id='sentinel',hatMana=60,name='Sentinel',rarity='Rare',level=10,low=30,high=30,resource=80,secondary=20},
},weapons={knight='Sword',dwarf='Axe',elf='Bow',mage='Staff'}}
function F.weapon(tier,class)
 return class..'_weapon_'..(tier=='tempered' and 'fine' or tier)
end
function F.piece(tier,slot)
 if slot=='offhand' then return tier=='traveler' and 'knight_shield' or tier=='tempered' and 'knight_shield_fine' or tier..'_tier_shield' end
 local suffix=({head='hood',body='coat',hands='gloves',feet='boots'})[slot]
 return (tier=='sentinel' and 'sentinel_tier' or tier)..'_'..suffix
end
function F.mageHat(tier)return 'mage_'..tier..'_hat'end
function F.mageBody(tier)return 'mage_'..tier..'_coat'end
-- Existing historical Rare copies migrate; deleted Dawnforge/Gauntlets never do.
F.legacy={sentinel_shield='offhand',sentinel_helm='head',sentinel_mail='body',sentinel_boots='feet'}
return F
