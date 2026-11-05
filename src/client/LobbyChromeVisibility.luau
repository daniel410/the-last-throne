-- Background lobby controls yield to every detail window, including commerce.
local C={blockers={'TLTHeroSelectionOpen','TLTInventoryOpen','TLTProgressionOpen','TLTSettingsOpen','TLTLobbyPanelOpen','TLTLobbyTopMenuOpen','TLTSupporterOpen','TLTMapOpen','TLTStoryOpen','TLTTravelLock'}}
function C.blocked(player)
 for _,key in ipairs(C.blockers)do if player:GetAttribute(key) then return true end end
 return false
end
return C
