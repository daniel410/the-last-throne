-- Shop targets calibrated against authored campaign income, not live play-time data.
local P={version=2,goldPerDiamond=50,resaleRate=.20,families={
 tempered={currency='gold',weapon=500,offhand=400,head=300,body=400,hands=250,feet=250},
 veteran={currency='gold',weapon=1200,offhand=1000,head=800,body=1000,hands=650,feet=650},
 sentinel={currency='diamonds',weapon=60,offhand=48,head=42,body=45,hands=32,feet=32},
},accessories={copper_ring=300,amber_charm=400,amber_mana_charm=400},
-- Preserve starter/drop resale values; issuing gear never makes it a shop product.
travelerResale={weapon=50,offhand=50,head=16,body=24,hands=16,feet=16},
-- A performance/retail increase does not revalue old Rare stock into extra Gold.
sentinelResale={weapon=400,offhand=320,head=280,body=320,hands=240,feet=240}}
function P.price(definition)
 local family=P.families[definition.family]
 if family then return family[definition.slot],family.currency end
 local price=P.accessories[definition.id]
 if price then return price,'gold' end
 return nil
end
function P.resale(definition)
 if definition.family=='traveler'then return P.travelerResale[definition.slot] end
 if definition.family=='sentinel'then return P.sentinelResale[definition.slot] end
 local price,currency=P.price(definition)
 return price and math.floor(price*(currency=='diamonds'and P.goldPerDiamond or 1)*P.resaleRate)or nil
end
return P
