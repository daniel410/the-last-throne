-- Trusted server events shared only within the same admitted expedition run.
-- Personal storage still owns idempotency and rewards; Selene remains personal.
local PartyStory = {}

function PartyStory.create(o)
 local runs = {}
 local cursors = {}
 local api = {}

 local function confirmed(journal, event)
  local chapter, goal = event.c, event.g
  if journal.clears[chapter.id] then return true end
  if goal.id == '@accept' then return (journal.accepted or {})[chapter.id] == true end
  if journal.flags[chapter.id..':'..goal.id] then return true end
  return event.stepIndex and o.collected(journal, chapter, goal, event.stepIndex)
 end

 local function replayMember(player, heroId, log)
  local cursor = cursors[player]
  if not cursor or cursor.log ~= log or cursor.heroId ~= heroId then
   cursor = {log=log, heroId=heroId, nextEvent=1}
   cursors[player] = cursor
  end
  if cursor.nextEvent > #log.events then return end
  local journal = o.state(player, heroId)
  if not journal then return end

  for index = cursor.nextEvent, #log.events do
   local event = log.events[index]
   if confirmed(journal, event) then
    if index == cursor.nextEvent then cursor.nextEvent = index + 1 end
   else
    local chapter, goal = event.c, event.g
    if goal.id == '@accept' and o.canAccept(journal, chapter)
     or goal.id ~= '@accept' and o.available(journal, chapter, goal) then
     o.enqueue(player, heroId, chapter, goal, event.choice, event.stepId)
    end
   end
  end
 end

 function api.remove(player)
  cursors[player] = nil
 end

 function api.replay()
  local now = os.clock()
  for _,player in ipairs(o.players()) do
   local hero = o.active(player)
   local run = hero and not hero.training and o.run(player, hero.heroId)
   local log = run and runs[run.runId]
   if log then
    log.lastSeen = now
    replayMember(player, hero.heroId, log)
   else
    api.remove(player)
   end
  end
  for id,log in pairs(runs) do
   if now - log.lastSeen > 900 then runs[id] = nil end
  end
 end

 function api.enqueue(player, heroId, chapter, goal, choice, stepId)
  local run = o.run(player, heroId)
  if not run or goal.id == '@selene' then
   o.enqueue(player, heroId, chapter, goal, choice, stepId)
   return
  end
  local log = runs[run.runId]
  if not log then
   log = {events={}, keys={}, lastSeen=os.clock()}
   runs[run.runId] = log
  end
  local key = chapter.id..':'..goal.id..':'..tostring(stepId)
  -- The first server-validated interaction fixes the party's choice for this step.
  if not log.keys[key] then
   local event = {c=chapter, g=goal, choice=choice, stepId=stepId}
   if stepId then
    for index,step in ipairs(goal.activity and goal.activity.steps or {}) do
     if step.id == stepId then event.stepIndex = index; break end
    end
   end
   log.keys[key] = true
   table.insert(log.events, event)
  end
  api.replay()
 end
 return api
end

return PartyStory
