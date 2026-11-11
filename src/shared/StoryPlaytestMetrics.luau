-- Opt-in local QA observation. No remotes, identities, rewards, or persistent writes.
local M={}
function M.new()
 local state={seconds={combat=0,reading=0,travel=0,atObjective=0,idle=0,dead=0},distance=0,unchangedTravel=0,confirmedChanges=0,deaths=0,samples=0}
 local lastProgress,lastGoal,lastDead;local still=0
 local api={}
 function api.sample(dt,value)
  if type(dt)~='number'or dt~=dt or dt<=0 or dt>2 or not value then return end
  local distance=math.max(0,math.min(value.distance or 0,100))
  local moving=distance>.1
  still=moving and 0 or still+dt
  local category=value.dead and 'dead'or value.combat and 'combat'or value.reading and 'reading'
   or moving and ((value.nearObjective and 'atObjective')or 'travel')or still>=30 and 'idle'or 'atObjective'
  state.seconds[category]=state.seconds[category]+dt;state.samples=state.samples+1
  -- Death/teleport corrections are not walking distance or backtracking.
  if not value.dead and not lastDead and (value.distance or 0)<=100 then
   state.distance=state.distance+distance
   if category=='travel'and lastProgress==value.progress and lastGoal==value.goal then state.unchangedTravel=state.unchangedTravel+distance end
  end
  if lastProgress~=nil and lastProgress~=value.progress then state.confirmedChanges=state.confirmedChanges+1 end
  if value.dead and not lastDead then state.deaths=state.deaths+1 end
  lastProgress=value.progress;lastGoal=value.goal;lastDead=value.dead
 end
 function api.snapshot()
  local copy={seconds={},distance=state.distance,unchangedTravel=state.unchangedTravel,confirmedChanges=state.confirmedChanges,deaths=state.deaths,samples=state.samples,
   note='Unchanged travel is an observation proxy, not proof of unnecessary movement. Reading and near-objective time are not confirmed player actions.'}
  for key,value in pairs(state.seconds)do copy.seconds[key]=value end
  return copy
 end
 return api
end
return M
