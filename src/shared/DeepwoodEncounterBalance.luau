-- Trial adventure tuning. Authored levels and fixed story rewards remain canonical.
local Balance={density=3,normalHealth=1.5,normalDamage=1.5,bossHealth=1.35,bossDamage=1.25,maxWaveSize=18}
local bosses={Warlord=true,GoblinKing=true,KingOgre=true,EnragedWarlord=true,KingShaman=true}
function Balance.isBoss(kind) return bosses[kind]==true end
function Balance.expand(specs)
 local result={}
 for _,spec in ipairs(specs) do
  local copies=Balance.isBoss(spec.kind) and 1 or Balance.density
  for _=1,spec.count do for index=1,copies do
   table.insert(result,{kind=spec.kind,level=spec.level,rewardCopies=copies,rewardIndex=index})
  end end
 end
 return result
end
local function share(amount,spec)
 local copies=spec.rewardCopies or 1
 return math.floor(amount/copies)+((spec.rewardIndex or 1)<=amount%copies and 1 or 0)
end
function Balance.rewards(spec)
 local boss=Balance.isBoss(spec.kind)
 return share((8+2*spec.level)*(boss and 5 or 1),spec),share((3+math.floor(spec.level/2))*(boss and 10 or 1),spec)
end
function Balance.stats(kind,level,partySize)
 local boss=Balance.isBoss(kind)
 local party=boss and ({1,1.7,2.3,2.8})[partySize or 1] or 1
 local health=(boss and 1000+level*100 or 100+level*25)*party*(boss and Balance.bossHealth or Balance.normalHealth)
 local damage=(boss and 28+level*2 or 10+level)*(boss and Balance.bossDamage or Balance.normalDamage)
 return math.floor(health+.5),math.floor(damage+.5)
end
return Balance
