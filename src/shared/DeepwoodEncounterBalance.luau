local BossTuning=game and require(script.Parent.BossCombatTuning)or dofile('src/shared/BossCombatTuning.luau')
local Difficulty=game and require(script.Parent.Difficulty)or dofile('src/shared/Difficulty.luau')
local GrowthBudget=game and require(script.Parent.CampaignGrowthBudget)or dofile('src/shared/CampaignGrowthBudget.luau')
-- Trial adventure tuning. Authored levels and fixed story rewards remain canonical.
local Balance={density=6,normalHealth=1.5,normalDamage=1.875,bossHealth=1.35,bossDamage=1.5625,maxWaveSize=9}
local Population=game and require(script.Parent.EncounterPopulation)or dofile('src/shared/EncounterPopulation.luau')
for key,value in pairs(Population)do Balance[key]=value end
function Balance.tempo(kind,version)return BossTuning.forRun(Balance.isBoss(kind),version)end
local function share(amount,spec)
 local copies=spec.rewardCopies or 1
 return math.floor(amount/copies)+((spec.rewardIndex or 1)<=amount%copies and 1 or 0)
end
function Balance.rewards(spec,mode,version,cycle)
 local boss=Balance.isBoss(spec.kind)
 local level=version~=nil and version<10 and (spec.legacyLevel or spec.level)or spec.level
 local m=version~=1 and mode and assert(Difficulty.mode(mode,version),'Unsupported reward rules')or {xp=1,gold=1}
 -- Scale the original whole-unit budget before splitting its six finite copies.
 local xp=mode and GrowthBudget.killXP(spec,mode,version or Difficulty.version,cycle)
 return share(xp or math.floor((8+2*level)*(boss and 5 or 1)*m.xp),spec),share(math.floor((3+math.floor(level/2))*(boss and 10 or 1)*(mode and version~=1 and Difficulty.goldMultiplier(level,mode,version)or m.gold)),spec)
end
function Balance.stats(kind,level,partySize,mode,version,epic)
 if mode then return Difficulty.stats(kind,level,partySize,Balance.isBoss(kind),mode,version,epic)end
 local boss=Balance.isBoss(kind)
 local party=(boss and {1,1.7,2.3,2.8} or {1,1.5,2,2.5})[partySize or 1]
 local health=(boss and 1000+level*100 or 100+level*25)*party*(boss and Balance.bossHealth or Balance.normalHealth)
 local damage=(boss and 28+level*2 or 10+level)*(boss and Balance.bossDamage or Balance.normalDamage)
 local scale=Difficulty.epicScale(epic,version)
 return math.floor(health*scale.hp+.5),math.floor(damage*scale.damage*BossTuning.forRun(boss,version).damage*(1+.1*((partySize or 1)-1))+.5)
end
-- Elite adjustments share a single path with the runtime and entry preview.
function Balance.unitStats(spec,partySize,mode,version,index)
 local authored=version~=nil and version<10 and (spec.legacyLevel or spec.level)or spec.level
 local epic=version~=nil and version<10 and (spec.legacyEpic or spec.epic)or spec.epic
 local hp,damage,level=Balance.stats(spec.kind,authored,partySize,mode,version,epic)
 local elite
 if not Balance.isBoss(spec.kind)then
  if (mode=='Insane'or mode=='Hell')and index==1 then hp=math.floor(hp*1.15+.5);elite='Armored' end
  if mode=='Hell'and index==2 then damage=math.floor(damage*1.1+.5);elite='Empowered' end
 end
 return hp,damage,level,elite
end
return Balance
