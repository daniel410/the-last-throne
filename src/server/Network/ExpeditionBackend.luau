-- A run's ID fixes its authority. Never retry an unknown write in another store.
local Backend={prefix='sm2_',mapName='TLT_Expedition_v2'}
function Backend.newId(id)return Backend.prefix..id end
function Backend.isCurrent(id)
 return type(id)=='string'and id:sub(1,#Backend.prefix)==Backend.prefix
end
function Backend.select(current,legacy,id)
 if legacy and not Backend.isCurrent(id)then return legacy end
 return current
end
function Backend.rejoin(current,legacy,uid,activeRun)
 local offer,reason=current.rejoin(uid,activeRun)
 -- A current error/finished capability cannot be interpreted as an empty slot.
 if offer or reason or not legacy then return offer,reason end
 return legacy.rejoin(uid,activeRun)
end
return Backend
