-- Shared spatial and en-US presentation contract. No progression or rewards.
local Facilities = require(script.Parent.LobbyFacilities)
return {
 tessaOffset = Facilities.portal.offset + Vector3.new(14,0,6),
 floorSize = Vector3.new(300, 4, 300),
 throneOffset = Vector3.new(0, 0, -110),
 heartOffset = Vector3.new(0, 6.5, 12),
 text = {
  title = 'THE DAWNSPIRE THRONE',
  missing = 'The Crownheart is missing. Bring our light home.',
  restored = 'The Crownheart is home. Dawnspire shines again.',
  welcome = 'WELCOME HOME, HERO!',
 },
}
