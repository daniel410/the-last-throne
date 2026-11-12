-- Server checkpoints preserve absolute resources across character/place changes.
local Vitals = {}
local function finite(value)
 return type(value)=='number' and value==value and value>=0 and value<math.huge
end
function Vitals.valid(value)
 return type(value)=='table' and finite(value.health) and finite(value.mana)
  and finite(value.level) and value.level%1==0 and value.level>=1 and value.level<=80
end
function Vitals.restore(value,maxHealth,maxMana,level)
 -- Legacy heroes start full. Death and level-up retain their existing refill.
 if not value or value.health==0 or value.level<level then return maxHealth,maxMana end
 return math.min(value.health,maxHealth),math.min(value.mana,maxMana)
end
return Vitals
