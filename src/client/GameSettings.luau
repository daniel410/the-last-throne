-- Player-local session preferences survive respawns and menu reconstruction.
local Settings={options={
 {id='autoTarget',attribute='TLTAutoTargetEnabled',title='AutoTarget',hint='AutoTargetHint'},
 {id='attacks',attribute='TLTAttackRangesEnabled',title='AttackRanges',hint='AttackRangesHint'},
 {id='navigation',attribute='TLTNavigationEnabled',title='Navigation',hint='NavigationHint'},
 {id='waypoints',attribute='TLTWaypointsEnabled',title='Waypoints',hint='WaypointsHint'},
}}
local byId={}
for _,option in ipairs(Settings.options) do byId[option.id]=option end
function Settings.enabled(player,id)
 return player:GetAttribute(assert(byId[id],'Unknown game setting').attribute)~=false
end
function Settings.set(player,id,value)
 assert(type(value)=='boolean','Game setting must be a boolean')
 player:SetAttribute(assert(byId[id],'Unknown game setting').attribute,value)
end
function Settings.toggle(player,id) Settings.set(player,id,not Settings.enabled(player,id)) end
return Settings
