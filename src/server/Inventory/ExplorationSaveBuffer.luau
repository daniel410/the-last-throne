-- Fold server-observed map cells into the next fenced account transaction.
-- Snapshot before UpdateAsync: retries must not consume newly queued cells.
local Buffer={}
function Buffer.attach(state,rules)
 local store=state.store
 local transact=store.transact
 function store:transact(userId,transform)
  local batch={}
  for index,job in ipairs(state.revealJobs or {})do
   if index>32 then break end
   table.insert(batch,job)
  end
  local profile,reason,repeated=transact(self,userId,function(current)
   local nextProfile,errorCode,replayed=transform(current)
   if not nextProfile then return nil,errorCode end
   for _,job in ipairs(batch)do
    -- A stale/invalid cell must not reject a valid purchase or story event.
    local revealed=rules.explore(nextProfile,job.heroId,job.zone,job.x,job.z)
    if revealed then nextProfile=revealed end
   end
   return nextProfile,nil,replayed
  end)
  if profile then
   for _,job in ipairs(batch)do
    assert(state.revealJobs[1]==job,'Exploration queue changed during save')
    table.remove(state.revealJobs,1)
    state.revealKeys[job.key]=nil
   end
   state.revealPending=nil
  end
  return profile,reason,repeated
 end
end
return Buffer
