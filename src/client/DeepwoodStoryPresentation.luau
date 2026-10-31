-- Personal completion visuals; shared portal never disappears for unfinished players.
local View={}
function View.update(journal)
 local world=workspace:FindFirstChild('DeepwoodCampaign');local portal=world and world:FindFirstChild('MonsterPortal')
 if not portal then return end
 for _,item in ipairs(portal:GetDescendants()) do if item:IsA('BasePart') then
  local zone=item:GetAttribute('ForestKitZone');local value=item:FindFirstChild('ForestKitZone');zone=zone or value and value.Value
  if zone=='PortalEnergy' then item.LocalTransparencyModifier=journal.flags['DW-07:stabilize'] and 1 or 0 end
 end end
end
return View
