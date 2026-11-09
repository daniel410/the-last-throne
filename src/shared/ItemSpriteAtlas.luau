-- RPG-specific illustrated sprites, generated as one atlas; asset provenance is
-- recorded in assets/ui/item-icons-v1/manifest.json. TD's original art is unchanged.
return {
	-- Separate transparent material icons; provenance: enhancement-material-icons-v1.
	images = {
		-- Latest four-family Meshy model renders; shared by gear and bag.
		["dwarf_weapon_sentinel"] = "rbxassetid://126622922289484",
		["elf_weapon_sentinel"] = "rbxassetid://93652204708306",
		["mage_weapon_sentinel"] = "rbxassetid://74366161848908",
		["knight_weapon_sentinel"] = "rbxassetid://76943152457590",
		["dwarf_weapon_veteran"] = "rbxassetid://88074217383860",
		["elf_weapon_veteran"] = "rbxassetid://121049680687223",
		["mage_weapon_veteran"] = "rbxassetid://98052385179240",
		["knight_weapon_veteran"] = "rbxassetid://99740451046658",
		["dwarf_weapon_fine"] = "rbxassetid://83551316779237",
		["elf_weapon_fine"] = "rbxassetid://123323237309349",
		["mage_weapon_fine"] = "rbxassetid://131197800580947",
		["knight_weapon_fine"] = "rbxassetid://121495916623375",
		["dwarf_weapon_traveler"] = "rbxassetid://91201276228888",
		["elf_weapon_traveler"] = "rbxassetid://84686712382386",
		["mage_weapon_traveler"] = "rbxassetid://111844365076046",
		["knight_weapon_traveler"] = "rbxassetid://83463381365228",
		enhancement_gem = "rbxassetid://81095702596861",
		magic_stone = "rbxassetid://103562386022277",
	},
	image = "rbxassetid://135019494060990",
	width = 1024, height = 1536, renderWidth = 683, renderHeight = 1024,
	cells = {
		knight_weapon={0,0,256,288}, dwarf_weapon={256,0,256,288}, elf_weapon={512,0,256,288}, mage_weapon={768,0,256,288},
		offhand={0,288,256,256}, head={256,288,256,256}, body={512,288,256,256}, hands={768,288,256,256},
		feet={0,544,256,256}, copper_ring={256,544,256,256}, amber_mana_charm={512,544,256,256}, amber_charm={512,544,256,256}, iron_ore={768,554,256,232},
		health_potion={16,832,224,208}, health_potion_medium={256,800,256,240}, health_potion_large={512,800,256,240}, health_potion_xl={768,788,256,252},
		mana_potion={16,1072,224,232}, mana_potion_medium={256,1040,256,264}, mana_potion_large={512,1040,256,264}, mana_potion_xl={768,1040,256,264},
	},
}
