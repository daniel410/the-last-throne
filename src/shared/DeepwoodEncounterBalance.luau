-- Trial adventure tuning. Authored levels and fixed story rewards remain canonical.
local Balance={density=6,normalHealth=1.5,normalDamage=1.5,bossHealth=1.35,bossDamage=1.25,maxWaveSize=9}
local bosses={Warlord=true,GoblinKing=true,KingOgre=true,EnragedWarlord=true,KingShaman=true,IceTrollKing=true,KingIceBear=true,KingIceGolem=true,QueenIceElf=true,AncientGlacierKing=true}
function Balance.isBoss(kind) return bosses[kind]==true end
-- Double the previous three-copy population, split into finite story-paced packs.
local packSizes={
 ['DW-01:trail_guards']=2,['DW-01:supply_guards']=3,
 ['DW-02:cart_guards']=3,['DW-02:escape_guards']=3,
 ['DW-04:courtyard']=4,['DW-04:west_link']=5,['DW-04:east_link']=6,
 ['DW-05:ruin_guards']=4,['DW-05:prison_guards']=5,['DW-05:first_ogre']=6,['DW-05:barracks']=6,['DW-05:warlord']=6,
 ['DW-06:root_west']=7,['DW-06:root_east']=8,['DW-06:root_depth']=9,
 ['DW-07:corridor']=7,['DW-07:outer_west']=8,['DW-07:outer_east']=9,['DW-07:king_shaman']=9,
 ['DW-Q1:marsh_slimes']=4,['DW-Q2:goblin_king']=6,['DW-Q3:quarry_slimes']=7,['DW-Q3:king_ogre']=8,['DW-Q4:enraged_warlord']=9,
}
function Balance.packSize(chapter,goal) return chapter.epic==2 and (chapter.side and 5 or math.min(8,chapter.number-5)) or packSizes[chapter.id..':'..goal.id] or Balance.maxWaveSize end
function Balance.expand(specs)
 local result={}
 -- Interleave source units so later packs also contain mixed enemy roles.
 for index=1,Balance.density do for _,spec in ipairs(specs) do
  local copies=Balance.isBoss(spec.kind) and 1 or Balance.density
  if index<=copies then for _=1,spec.count do
   table.insert(result,{kind=spec.kind,level=spec.level,rewardCopies=copies,rewardIndex=index})
  end end
 end end
 return result
end
function Balance.waves(specs,packSize,reserved)
 local boss,guards=nil,{}
 for _,spec in ipairs(specs) do if Balance.isBoss(spec.kind) then boss=spec else table.insert(guards,spec) end end
 local capacity=math.max(1,packSize-(reserved or (boss and 1 or 0)))
 local waves={}
 for index,spec in ipairs(guards) do
  local n=math.floor((index-1)/capacity)+1;waves[n]=waves[n] or {};table.insert(waves[n],spec)
 end
 if boss then waves[1]=waves[1] or {};table.insert(waves[1],1,boss) end
 return waves
end
-- Preserve each unit's original level/reward share while varying the first story.
function Balance.encounterWaves(chapter,goal)
 local waves=Balance.waves(Balance.expand(goal.enemies),Balance.packSize(chapter,goal))
 if chapter.id=='DW-01' then
  for n,batch in ipairs(waves) do for index,spec in ipairs(batch) do
   if n%4==2 or n%4==0 and index%2==0 then spec.kind='Slime' end
  end end
 end
 return waves
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
 local party=(boss and {1,1.7,2.3,2.8} or {1,1.5,2,2.5})[partySize or 1]
 local health=(boss and 1000+level*100 or 100+level*25)*party*(boss and Balance.bossHealth or Balance.normalHealth)
 local damage=(boss and 28+level*2 or 10+level)*(boss and Balance.bossDamage or Balance.normalDamage)
 return math.floor(health+.5),math.floor(damage+.5)
end
return Balance
