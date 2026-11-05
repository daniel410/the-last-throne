local T=dofile('src/server/Network/TravelAttempt.luau')
local n=0
local function check(value, message) n=n+1;assert(value,message) end
local original={ticket='ticket',runId='run'}
local old=T.data(original,'old')
local current=T.data(original,'current')
local attempt={placeId=123,callbackToken='current'}
check(original._travelAttempt==nil and current.ticket=='ticket' and current.runId=='run','copy preserves existing data without mutation')
check(T.matches(attempt,123,current),'current callback accepted')
check(not T.matches(attempt,123,old),'previous request to same player and place rejected')
check(not T.matches(attempt,124,current),'wrong place rejected')
check(not T.matches(nil,123,current),'completed or disconnected attempt rejected')
check(not T.matches(attempt,123,nil),'missing data rejected')
check(not T.matches(attempt,123,{_travelAttempt=4}),'malformed token rejected')
attempt.retrying=true
check(not T.matches(attempt,123,current),'duplicate failure while retry scheduled rejected')
print('Travel attempt: '..n..' checks passed')
