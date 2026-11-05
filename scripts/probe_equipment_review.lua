-- Isolated, read-only audit. Run from repository root with Lua.
local Rules=dofile('src/server/Inventory/InventoryRules.luau')
local Catalog=dofile('src/shared/ItemCatalog.luau')
local Shop=dofile('src/shared/EconomyCatalog.luau')
local count,mana,gear=0,0,0
local grades={}
for _,definition in pairs(Catalog.items) do
 count=count+1
 grades[definition.rarity]=(grades[definition.rarity]or 0)+1
 if definition.category=='Equipment' then gear=gear+1 end
 if definition.stats and definition.stats.maxMana then mana=mana+1 end
end
assert(count==63 and gear==45 and mana==0)
print('PASS runtime definitions='..count..'; equipment='..gear..'; MP definitions='..mana)
for _,grade in ipairs({'Common','Uncommon','Rare','Epic'}) do print(grade..'='..grades[grade]) end
local file=assert(io.open('assets/balance/equipment-review-160-2026-11-05.json','r'))
local data=file:read('*a');file:close()
-- IDs in this generated audit are unescaped ASCII; no JSON parser/runtime dependency.
local seen,offered,registered={},0,0
for id in data:gmatch('"candidateDefinitionId"%s*:%s*"([%w_]+)"') do
 assert(not seen[id]);seen[id]=true
 if Catalog.items[id] then registered=registered+1 end
 for _,offer in ipairs(Shop.offers) do if offer.definitionId==id then offered=offered+1 end end
end
local candidates=0;for _ in pairs(seen) do candidates=candidates+1 end
assert(candidates==160 and offered==0 and registered==0)
print('PASS candidate definitions='..candidates..'; registered='..registered..'; offered='..offered)
assert(#Shop.forgeDiamondStock==12)
print('PASS actual forge Rare/Epic pairs='..#Shop.forgeDiamondStock)
local profile={items={probe={definitionId='probe',location={kind='equipped',heroId='probe'}}}}
local ok,err=pcall(Rules.stats,profile,'probe',{items={probe={stats={maxMana=10}}}})
assert(not ok and tostring(err):find('arithmetic'))
print('REPRODUCED proposed MP injection blocker (isolated memory): '..tostring(err))
print('No game services, profiles, currencies or canonical inputs changed.')
