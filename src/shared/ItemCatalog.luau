-- Trial equipment values, not story rewards, shop products or final balance.
local Catalog = {
	version = 1, bagCapacity = 60, storageCapacity = 120,
	slots = {"weapon", "offhand", "head", "body", "hands", "feet", "accessory1", "accessory2"},
	classes = {knight = "Knight", elf = "Elf Archer", dwarf = "Dwarf Axe Thrower", mage = "Mage"},
	items = {},
}
local function gear(id, name, slot, classId, stats, glyph, extra)
	local item = {id = id, name = name, category = "Equipment", slot = slot, classId = classId,
		level = 1, maxStack = 1, stats = stats, glyph = glyph, rarity = "Common",
		description = "Dawnspire training equipment. Balance values are provisional."}
	for key, value in pairs(extra or {}) do item[key] = value end
	Catalog.items[id] = item
end
for classId, name in pairs({knight = "Sword", elf = "Bow", dwarf = "Axe", mage = "Staff"}) do
	gear(classId .. "_weapon", "Training " .. name, "weapon", classId, {}, name:sub(1, 2):upper())
	gear(classId .. "_weapon_fine", "Tempered " .. name, "weapon", classId, {power = 10}, name:sub(1, 2):upper(), {rarity = "Uncommon"})
 gear(classId..'_weapon_veteran',"Veteran's "..name,'weapon',classId,{power=18},name:sub(1,2):upper(),{level=5,rarity='Uncommon',description='A Dawnspire weapon for experienced adventurers. Requires level 5. Available for Gold or Diamonds.'})
end
gear("knight_shield", "Training Shield", "offhand", "knight", {}, "SH")
gear("knight_shield_fine", "Citadel Shield", "offhand", "knight", {armor = 4}, "SH", {rarity = "Uncommon"})
gear("traveler_hood", "Traveler's Hood", "head", nil, {armor = 2}, "HD")
gear("traveler_coat", "Traveler's Coat", "body", nil, {health = 40, armor = 2}, "BD")
gear("traveler_gloves", "Traveler's Gloves", "hands", nil, {power = 3}, "HN")
gear("traveler_boots", "Traveler's Boots", "feet", nil, {armor = 2}, "FT")
gear("copper_ring", "Copper Ring", "accessory", nil, {power = 5}, "RG", {uniqueGroup = "copper_ring"})
gear("amber_charm", "Amber Charm", "accessory", nil, {health = 60}, "CH", {rarity = "Uncommon"})
gear("veteran_hood", "Veteran's Hood", "head", nil, {armor = 6}, "HD", {level = 5, rarity = "Uncommon"})
-- Provisional Lv10 forge stock. Existing stable definitions/rewards stay intact.
for classId,name in pairs({knight='Sword',elf='Bow',dwarf='Axe',mage='Staff'})do
 gear(classId..'_weapon_forged','Dawnforge '..name,'weapon',classId,{power=24},name:sub(1,2):upper(),{level=10,rarity='Rare',description='Forged in Dawnspire for seasoned adventurers. Requires level 10.'})
end
for _,row in ipairs({
 {'sentinel_shield','Sentinel Shield','offhand','knight',{armor=8},'SH'},
 {'sentinel_helm','Sentinel Helm','head',false,{armor=8},'HD'},
 {'sentinel_mail','Sentinel Mail','body',false,{health=80,armor=7},'BD'},
 {'sentinel_gauntlets','Sentinel Gauntlets','hands',false,{power=5,armor=3},'HN'},
 {'sentinel_boots','Sentinel Boots','feet',false,{armor=7},'FT'},
 {'ruby_ring','Ruby Ring','accessory',false,{power=10},'RG'},
 {'guardian_charm','Guardian Charm','accessory',false,{health=100,armor=2},'CH'},
 {'storm_pendant','Storm Pendant','accessory',false,{power=6,health=50},'CH'},
})do gear(row[1],row[2],row[3],row[4]or nil,row[5],row[6],{level=10,rarity='Rare',description='Dawnspire forge equipment. Requires level 10. Balance values are provisional.',uniqueGroup=row[3]=='accessory' and row[1]or nil})end
-- Stable IDs/schema; potion restore amounts follow the latest user balance decision.
Catalog.potions = {}
for _, resource in ipairs({"health", "mana"}) do
	for tier, size in ipairs({"Small", "Medium", "Large", "XL"}) do
		local id = resource .. "_potion" .. (tier == 1 and "" or "_" .. size:lower())
		local amount = (resource == "health" and {100, 300, 500, 1000} or {50, 100, 200, 500})[tier]
		local glyph = resource == "health" and "HP" or "MP"
		Catalog.items[id] = {id = id, name = size .. " " .. (resource == "health" and "Health" or "Mana") .. " Potion",
			category = "Consumables", maxStack = 99, glyph = glyph, rarity = "Common", restore = resource,
			amount = amount, potionSize = size, potionTier = tier, iconKey = id,
			description = "Restores up to " .. amount .. " " .. glyph .. ". "
				.. (resource == "mana" and "A mana pool is required. " or "") .. "Assign to Z / C in your bag. Training balance is provisional."}
		table.insert(Catalog.potions, id)
	end
end
Catalog.items.iron_ore = {id = "iron_ore", name = "Iron Ore", category = "Materials", maxStack = 999,
	glyph = "FE", rarity = "Common", description = "Crafting material. Keep it in your bag or shared storage."}
Catalog.items.soft_hide = {id = "soft_hide", name = "Soft Hide", category = "Materials", maxStack = 999,
	glyph = "LH", rarity = "Common", description = "Crafting material. Crafting is not available yet."}
Catalog.kit = {"traveler_hood", "traveler_coat", "traveler_gloves", "traveler_boots", "copper_ring", "amber_charm", "veteran_hood"}
for _,id in ipairs({'warlord_seal','king_shaman_seal'}) do
 Catalog.items[id]={id=id,name=id=='warlord_seal' and 'Orc Warlord Seal' or 'King Shaman Seal',category='Materials',maxStack=99,glyph='SE',rarity='Uncommon',description='A personal trophy from the Deepwood campaign. Collect from Unclaimed at Hub.'}
end
Catalog.items.forge_core={id='forge_core',name='Forge Core',category='Materials',maxStack=999,glyph='FC',rarity='Rare',description='Enhancement material. Earn from harder missions or exchange Iron Ore at the blacksmith.'}
for _,tier in ipairs({1,5,10})do
 local id='equipment_cache_'..tier
 Catalog.items[id]={id=id,name='Level '..tier..' Equipment Cache',category='Materials',maxStack=99,glyph='EQ',rarity='Rare',cacheTier=tier,description='Claim to your bag, then choose equipment at the blacksmith. Repeat missions to earn more caches.'}
end
return Catalog
