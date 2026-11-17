-- Source-side preparation never writes an adventure journal. A failed member
-- preparation cancels the manifest and releases only accounts already closed.
local Departure={}
function Departure.prepare(store,inventory,participants,members,run,unlock)
 local r,e=store.createRun(run)
 if not r then
  if warn then warn('[Expedition] Departure blocked: createRun reason='..tostring(e))end
  return nil,e
 end
 local prepared={}
 for _,person in ipairs(participants)do
  local m=members[tostring(person.UserId)]
  local saved=store.stageOffer(person.UserId,r,m.heroId,m.ticket)
  if not saved or not inventory.prepareTransfer(person)then
   if warn then warn('[Expedition] Departure blocked: '..(not saved and 'stageOffer' or 'prepareTransfer'))end
   store.cancelRun(r.id,r.ticket)
   for _,old in ipairs(prepared)do unlock(old)end
   return nil,'Unavailable'
  end
  table.insert(prepared,person)
 end
 return r,nil,prepared
end
return Departure
