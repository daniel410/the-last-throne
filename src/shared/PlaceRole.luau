-- Shared by server startup and ReplicatedFirst before gameplay replication.
local Config = require(script.Parent:WaitForChild('ExpeditionConfig'))
local PlaceRole = {}
function PlaceRole.resolve(placeId, isStudio, studioRole)
 if placeId == Config.lobbyPlaceId then return 'Lobby' end
 if placeId == Config.battlePlaceId then return 'Battle' end
 if isStudio then
  assert(studioRole == nil or studioRole == 'Lobby' or studioRole == 'Battle',
   'Set the Workspace TLTStudioRole attribute to Lobby or Battle, then restart Play.')
  return studioRole or 'Lobby'
 end
 error('This Place is not configured. Publish this build to the configured TLT Lobby or Battle Place.')
end
return PlaceRole
