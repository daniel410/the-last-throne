-- Shared, deterministic target for previews and authoritative inventory changes.
local Slots={}
function Slots.resolve(heroId,items,definition,catalog,requested)
 if definition.slot~='accessory' then return definition.slot end
 if requested~=nil then
  if requested=='accessory1' or requested=='accessory2' then return requested end
  return nil,'ChooseAccessory'
 end
 local equipped={}
 for _,item in pairs(items or {})do
  local loc=item.location
  if loc.kind=='equipped' and loc.heroId==heroId and (loc.slot=='accessory1' or loc.slot=='accessory2')then equipped[loc.slot]=item end
 end
 -- Replacing the matching unique group avoids an otherwise illegal duplicate.
 for _,slot in ipairs({'accessory1','accessory2'})do
  local item=equipped[slot];local def=item and catalog.items[item.definitionId]
  if definition.uniqueGroup and def and def.uniqueGroup==definition.uniqueGroup then return slot end
 end
 for _,slot in ipairs({'accessory1','accessory2'})do if not equipped[slot]then return slot end end
 return 'accessory1'
end
return Slots
