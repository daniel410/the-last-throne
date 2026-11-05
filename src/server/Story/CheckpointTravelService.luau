-- Injected server adapters keep validation/relocation testable without a live account.
local Service={}
function Service.create(o)
 return function(player,id)
  local ctx=o.context(player);local hero=o.active(player)
  if not ctx or not hero or hero.training or ctx.heroId~=hero.heroId or not o.ready(player) then return false end
  if o.pending(player)or o.inEncounter(player,ctx.heroId)then return false end
  local target=o.rules.allowed(o.state(player,ctx.heroId),id)
  if not target then return false end
  local pivot=o.destination(target);if not pivot then return false end
  -- destination() must be non-yielding; only loaded, authoritative checkpoints.
  return o.relocate(player,pivot)==true,target
 end
end
return Service
