local Service={}
function Service.create(o)
 local preparing={}
 local function authorize(player,id)
  local ctx=o.context(player);local hero=o.active(player)
  if not ctx or ctx.inventoryLocked or not hero or hero.training or ctx.heroId~=hero.heroId or not o.ready(player) then return end
  if o.pending(player) or o.inEncounter(player,ctx.heroId) then return end
  local journal=o.state(player,ctx.heroId)
  local target=o.rules.allowed(journal,id)
  if target then return target,ctx,journal and journal.expeditionRunId end
 end
 return function(player,id)
  if preparing[player]then return false end
  local target,ctx,run=authorize(player,id)
  if not target then return false end
  if o.loaded and not o.loaded(target)then
   preparing[player]=true
   local ok=pcall(o.prepare,target)
   preparing[player]=nil
   if not ok then return false end
   local fresh,life,currentRun=authorize(player,id)
   if not fresh or fresh.zone~=target.zone or fresh.goalId~=target.goalId or currentRun~=run or life.heroId~=ctx.heroId or life.epoch~=ctx.epoch
    or life.characterGeneration~=ctx.characterGeneration or not o.loaded(fresh)then return false end
   target=fresh
  end
  local pivot=o.destination(target,player,ctx.heroId)
  if not pivot then return false end
  return o.relocate(player,pivot)==true,target
 end
end
return Service
