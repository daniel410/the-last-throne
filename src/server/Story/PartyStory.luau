-- Trusted server events shared only within the same admitted expedition run.
-- Personal storage still owns idempotency and rewards; Selene remains personal.
local PartyStory={}
function PartyStory.create(o)
 local runs={}
 local api={}
 local function deliver(player,heroId,c,g,choice,stepId)
  local s=o.state(player,heroId)
  if s and stepId and o.collected then
   for index,step in ipairs(g.activity and g.activity.steps or {}) do
    if step.id==stepId and o.collected(s,c,g,index) then return end
   end
  end
  if s and (g.id=='@accept' and o.canAccept(s,c) or g.id~='@accept' and o.available(s,c,g)) then
   o.enqueue(player,heroId,c,g,choice,stepId)
  end
 end
 function api.replay()
  local now=os.clock()
  for _,p in ipairs(o.players()) do
   local h=o.active(p);local run=h and not h.training and o.run(p,h.heroId)
   local log=run and runs[run.runId]
   if log then
    log.lastSeen=now
    for _,e in ipairs(log.events) do deliver(p,h.heroId,e.c,e.g,e.choice,e.stepId) end
   end
  end
  for id,log in pairs(runs) do if now-log.lastSeen>900 then runs[id]=nil end end
 end
 function api.enqueue(player,heroId,c,g,choice,stepId)
  local run=o.run(player,heroId)
  if not run or g.id=='@selene' then o.enqueue(player,heroId,c,g,choice,stepId);return end
  local log=runs[run.runId]
  if not log then log={events={},keys={},lastSeen=os.clock()};runs[run.runId]=log end
  local key=c.id..':'..g.id..':'..tostring(stepId)
  -- The first server-validated interaction fixes the party's choice for this step.
  if not log.keys[key] then
   log.keys[key]=true;table.insert(log.events,{c=c,g=g,choice=choice,stepId=stepId})
  end
  api.replay()
 end
 return api
end
return PartyStory
