-- Equipment power is a flat physical/magic attack bonus in points.
-- Current Traveler/Tempered/Veteran/Sentinel gear uses fixed flat bonuses.
-- Trial equipment values, not story rewards, shop products or final balance.
-- Starter bonuses are deliberately small; shared definitions also retune owned copies.
-- Existing rarity assignments are explicit. Keep canonical spelling Uncommon.
local Catalog = {
	version = 1, bagCapacity = 60, storageCapacity = 120,
	slots = {"weapon", "offhand", "head", "body", "hands", "feet", "accessory1", "accessory2"},
	classes = {knight = "Knight", elf = "Elf Archer", dwarf = "Dwarf Axe Thrower", mage = "Mage"},
	items = {},
}
local function gear(id, name, slot, classId, stats, glyph, extra)
	local item = {id = id, name = name, category = "Equipment", slot = slot, classId = classId,
		level = 1, maxStack = 1, stats = stats, glyph = glyph, rarity = "Common",
		description = "Dawnspire equipment. Balance values are provisional."}
	for key, value in pairs(extra or {}) do item[key] = value end
	Catalog.items[id] = item
end
-- Decode-only Training tombstones: account load removes every owned instance.
for classId, name in pairs({knight = "Sword", elf = "Bow", dwarf = "Axe", mage = "Staff"}) do
	gear(classId .. "_weapon", "Training " .. name, "weapon", classId, {}, name:sub(1, 2):upper(), {rarity = "Common", retired = true, deleted = true, cacheEligible = false})
	gear(classId .. "_weapon_fine", "Tempered " .. name, "weapon", classId, {power = 3}, name:sub(1, 2):upper(), {rarity = "Common"})
 gear(classId..'_weapon_veteran',"Veteran's "..name,'weapon',classId,{power=4},name:sub(1,2):upper(),{level=5,rarity='Uncommon',description='A Dawnspire weapon for experienced adventurers. Requires level 5. Available for Gold or Diamonds.'})
end
gear("knight_shield", "Dawnspire Shield", "offhand", "knight", {}, "SH", {rarity = "Common"})
gear("knight_shield_fine", "Citadel Shield", "offhand", "knight", {armor = 4}, "SH", {rarity = "Uncommon"})
gear("traveler_hood", "Traveler's Hood", "head", nil, {armor = 2}, "HD", {rarity = "Common"})
gear("traveler_coat", "Traveler's Coat", "body", nil, {health = 20, armor = 2}, "BD", {rarity = "Common"})
gear("traveler_gloves", "Traveler's Gloves", "hands", nil, {power = 1}, "HN", {rarity = "Common"})
gear("traveler_boots", "Traveler's Boots", "feet", nil, {armor = 1}, "FT", {rarity = "Common"})
gear("copper_ring", "Copper Ring", "accessory", nil, {dexterity = 3}, "RG", {uniqueGroup = "copper_ring", rarity = "Common"})
gear("amber_charm", "Amber Charm", "accessory", nil, {health = 30}, "CH", {rarity = "Uncommon"})
gear("veteran_hood", "Veteran's Hood", "head", nil, {armor = 2}, "HD", {level = 5, rarity = "Uncommon"})
-- Provisional Lv10 forge stock. Existing stable definitions/rewards stay intact.
for classId,name in pairs({knight='Sword',elf='Bow',dwarf='Axe',mage='Staff'})do
 gear(classId..'_weapon_forged','Dawnforge '..name,'weapon',classId,{power=5},name:sub(1,2):upper(),{level=10,rarity='Rare',description='Forged in Dawnspire for seasoned adventurers. Requires level 10.'})
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
-- Existing forge-stock Epic counterparts, separate from the 40-family art proposals.
-- Keep old Rare definitions/instances intact; the new IDs are fixed deterministic goods.
for _,baseId in ipairs({"knight_weapon_forged","elf_weapon_forged","dwarf_weapon_forged","mage_weapon_forged",
 "sentinel_shield","sentinel_helm","sentinel_mail","sentinel_gauntlets","sentinel_boots","ruby_ring","guardian_charm","storm_pendant"}) do
 local base=Catalog.items[baseId];local stats={}
 for key,value in pairs(base.stats)do stats[key]=math.floor(value*128/118*10000+.5)/10000 end
 -- Retired Dawnforge weapons use explicit Rare 5% / Epic 6% base bonuses.
 if base.slot=="weapon" then stats.power=6 end
 gear(baseId.."_epic","Epic "..base.name,base.slot,base.classId,stats,base.glyph,
  {level=base.level,rarity="Epic",uniqueGroup=base.uniqueGroup,forgeBaseId=baseId,cacheEligible=false,
   description="Epic Dawnspire forge equipment. Requires level 10. Purchase with Diamonds at the blacksmith. Balance values are provisional."})
end
-- Retired Lv10 trial stock: retained solely to deserialize owned gear/receipts.
-- No active shop, cache choice or new grant may issue these definitions.
Catalog.retiredEquipment = {}
for _,baseId in ipairs({"knight_weapon_forged","elf_weapon_forged","dwarf_weapon_forged","mage_weapon_forged",
 "sentinel_shield","sentinel_helm","sentinel_mail","sentinel_gauntlets","sentinel_boots","ruby_ring","guardian_charm","storm_pendant"}) do
 for _,id in ipairs({baseId,baseId.."_epic"}) do
  local definition=Catalog.items[id]
  definition.retired=true;definition.cacheEligible=false
  definition.description="Retired trial equipment. New purchases and cache selections are unavailable. Existing equipment and enhancement progress are preserved."
  table.insert(Catalog.retiredEquipment,id)
 end
end
-- User-requested deletion. Keep decode-only definitions so old saves validate
-- before AccountStore atomically removes every owned instance on load.
Catalog.deletedEquipment = {"knight_weapon", "dwarf_weapon", "elf_weapon", "mage_weapon"}
for _,baseId in ipairs({'knight_weapon_forged','elf_weapon_forged','dwarf_weapon_forged','mage_weapon_forged',
 'sentinel_gauntlets','ruby_ring','storm_pendant'}) do
 for _,id in ipairs({baseId,baseId..'_epic'}) do
  local definition=Catalog.items[id]
  definition.deleted=true
  definition.description='Removed equipment. Existing copies are removed when your account loads.'
  table.insert(Catalog.deletedEquipment,id)
 end
end
-- Four current families override old balancing, while deleted IDs remain tombstones.
local Families=game and require(script.Parent.EquipmentFamilies)or dofile('src/shared/EquipmentFamilies.luau')
Catalog.equipmentFamilies=Families
Catalog.tierEquipment={}
for _,tier in ipairs(Families.tiers)do
 local function add(id,name,slot,class,stats,glyph,extra)
  extra=extra or {};extra.level=tier.level;extra.rarity=tier.rarity;extra.family=tier.id
  extra.description=tier.name..' equipment. One fixed bonus. Requires level '..tier.level..'.'
  if Catalog.items[id]then extra.legacyLevel=Catalog.items[id].level end
  gear(id,name,slot,class,stats,glyph,extra);table.insert(Catalog.tierEquipment,id)
 end
 for class,name in pairs(Families.weapons)do
  add(Families.weapon(tier.id,class),tier.name..' '..name,'weapon',class,{power=tier.high},name:sub(1,2):upper())
 end
 for _,row in ipairs({{'offhand','Shield','SH'},{'head','Hood','HD'},{'body','Coat','BD'},{'hands','Gloves','HN'},{'feet','Boots','FT'}})do
  local slot=row[1];local stats=slot=='body' and {health=tier.resource}or slot=='hands' and {power=tier.secondary}or {armor=slot=='offhand' and tier.high or slot=='feet'and tier.secondary or tier.low}
  add(Families.piece(tier.id,slot),tier.name..' '..row[2],slot,slot=='offhand' and 'knight'or nil,stats,row[3])
 end
 add(Families.mageBody(tier.id),tier.name..' Mage Robe','body','mage',{mana=tier.resource},'BD')
end
Catalog.items.copper_ring.stats={dexterity=3}
gear('amber_mana_charm','Amber Mana Charm','accessory',nil,{mana=30},'CH',{
 rarity='Uncommon',iconKey='amber_charm',
 description='Adds 30 maximum MP to heroes with a mana pool. Does not create mana for other heroes or restore current MP.'})
-- Decode old non-deleted Sentinel copies, then migrate to the new Lv15 family.
for id in pairs(Families.legacy)do Catalog.items[id].description='Legacy equipment. Migrates to the current Sentinel family when your account loads.'end
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
	glyph = "FE", rarity = "Common", description = "Legacy crafting material. Keep it, or explicitly convert one to one Enhancement Gem at the blacksmith."}
-- Decode-only tombstone: account migration removes every existing stack.
Catalog.items.soft_hide = {id = "soft_hide", name = "Soft Hide", category = "Materials", maxStack = 999,
	glyph = "LH", rarity = "Common", retired = true, description = "Retired material. Removed when your account loads."}
Catalog.kit = {"traveler_hood", "traveler_coat", "traveler_gloves", "traveler_boots", "copper_ring", "amber_charm", "veteran_hood"}
for _,id in ipairs({'warlord_seal','king_shaman_seal'}) do
 Catalog.items[id]={id=id,name=id=='warlord_seal' and 'Orc Warlord Seal' or 'King Shaman Seal',category='Materials',maxStack=99,glyph='SE',rarity='Uncommon',description='A personal trophy from the Deepwood campaign. Collect from Unclaimed at Hub.'}
end
Catalog.items.forge_core={id='forge_core',name='Forge Core',category='Materials',maxStack=999,glyph='FC',rarity='Rare',description='Legacy forge material. Keep it, or explicitly convert one to one Magic Stone at the blacksmith.'}
for _,tier in ipairs({1,5,10})do
 local id='equipment_cache_'..tier
 Catalog.items[id]={id=id,name='Level '..tier..' Equipment Cache',category='Materials',maxStack=99,glyph='EQ',rarity='Rare',cacheTier=tier,description='Claim to your bag, then choose equipment at the blacksmith. Repeat missions to earn more caches.'}
end
Catalog.items.enhancement_gem={id='enhancement_gem',name='Enhancement Gem',category='Materials',maxStack=999,glyph='EG',rarity='Uncommon',description='Earned crafting material for equipment enhancement. Separate from Diamonds. Higher-level missions and difficulties award more.'}
Catalog.items.magic_stone={id='magic_stone',name='Magic Stone',category='Materials',maxStack=999,glyph='MS',rarity='Rare',description='Earned material used from enhancement +4 onward. Complete combat missions or exchange Enhancement Gems at the blacksmith.'}
for _,kind in ipairs({'stat','skill'}) do
 local id=kind..'_reset_ticket'
 Catalog.items[id]={id=id,name=kind=='stat' and 'Stat Reset Ticket' or 'Skill Reset Ticket',category='Consumables',maxStack=99,
  glyph=kind=='stat' and 'ST' or 'SK',rarity='Rare',reset=kind,
  description=kind=='stat' and 'Returns all invested STR, DEX, INT and VIT points for this hero. Use from BAG anytime, including combat. Consumes one ticket only after a successful reset.' or 'Returns all invested skill mastery points for this hero. Keeps learned skills, advancement and combat slots. Use from BAG anytime, including combat. Consumes one ticket only after a successful reset.'}
end
local Effects=game and require(game:GetService('ReplicatedStorage').Shared.EquipmentEffects)or dofile('src/shared/EquipmentEffects.luau')
for id,def in pairs(Catalog.items)do assert(Effects.validateDefinition(def),'Invalid special effects: '..id)end
return Catalog
