-- Presentation metadata; rarity never changes item stats, ownership or rewards.
local Rarity = {
 order = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Unique"},
 styles = {
  Common = {label = "Common", rgb = {195, 205, 215}},
  Uncommon = {label = "Uncommon", rgb = {155, 225, 174}},
  Rare = {label = "Rare", rgb = {118, 185, 255}},
  Epic = {label = "Epic", rgb = {202, 156, 255}},
  Legendary = {label = "Legendary", rgb = {255, 182, 102}},
  Unique = {label = "Unique", rgb = {245, 215, 116}},
 },
 unknown = {label = "Unknown", rgb = {195, 205, 215}},
}
function Rarity.style(value)
 return Rarity.styles[value] or Rarity.unknown
end
return Rarity
