--!strict
-- The token only correlates failure callbacks; it grants no destination rights.
local TravelAttempt = {}

function TravelAttempt.data(original, token)
 local data = {}
 for key, value in pairs(original) do data[key] = value end
 data._travelAttempt = token
 return data
end

function TravelAttempt.matches(attempt, placeId, data)
 return attempt ~= nil and not attempt.retrying and attempt.placeId == placeId
  and type(data) == 'table' and type(data._travelAttempt) == 'string'
  and data._travelAttempt == attempt.callbackToken
end

return TravelAttempt
