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
-- Keep the original small-potion IDs and catalog version compatible with saved accounts.
Catalog.potions = {}
for _, resource in ipairs({"health", "mana"}) do
	for tier, size in ipairs({"Small", "Medium", "Large"}) do
		local id = resource .. "_potion" .. (tier == 1 and "" or "_" .. size:lower())
		local amount = (resource == "health" and {40, 120, 300} or {40, 80, 160})[tier]
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
return Catalog
