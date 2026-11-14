-- Pure population and stable kill indices; shared by spatial planning and combat.
local Balance={maxWaveSize=9}
local Easy=game and require(script.Parent.EasyCampaignTuning)or dofile('src/shared/EasyCampaignTuning.luau')
local bosses={Warlord=true,GoblinKing=true,KingOgre=true,EnragedWarlord=true,KingShaman=true,IceTrollKing=true,KingIceBear=true,KingIceGolem=true,QueenIceElf=true,AncientGlacierKing=true,MagmaImp=true,MagmaGolem=true,InfernoOverlord=true,CalderaTitan=true,KingVolcanoShaman=true,AncientHollowbark=true,HollowbarkSovereign=true,VenomcoilKing=true,WidowQueen=true,DreadCommander=true,Lich=true,LichSovereign=true,Veyr=true}
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
function Balance.packSize(chapter,goal) return (chapter.legacyEpic or chapter.epic)==3 and (chapter.side and 6 or math.min(9,(chapter.legacyNumber or chapter.number)-10)) or (chapter.legacyEpic or chapter.epic)==2 and (chapter.side and 5 or math.min(8,(chapter.legacyNumber or chapter.number)-5)) or packSizes[chapter.id..':'..goal.id] or Balance.maxWaveSize end
function Balance.population(partySize) return 6+2*(math.max(1,math.min(4,partySize or 1))-1) end
function Balance.packCapacity(chapter,goal,partySize,mode,version)
 local size=Balance.packSize(chapter,goal)
 if Easy.enabled(mode,version)then size=Easy.packSize(chapter,size)end
 return math.min(12,size+(partySize or 1)-1)
end
function Balance.expand(specs,partySize,epic,legacyEpic)
 local result={}
 -- Interleave source units so later packs also contain mixed enemy roles.
 for index=1,Balance.population(partySize) do for _,spec in ipairs(specs) do
  local copies=Balance.isBoss(spec.kind) and 1 or Balance.population(partySize)
  if index<=copies then for _=1,spec.count do
   table.insert(result,{kind=spec.kind,level=spec.level,legacyLevel=spec.legacyLevel,legacyEpic=legacyEpic,rewardCopies=copies,rewardIndex=index,epic=epic or spec.epic or 1})
  end end
 end end
 return result
end
function Balance.waves(specs,packSize,reserved,finalGuardCap)
 local boss,guards=nil,{}
 for _,spec in ipairs(specs) do if Balance.isBoss(spec.kind) then boss=spec else table.insert(guards,spec) end end
 local capacity=math.max(1,packSize-(reserved or 0))
 local finalGuards=boss and math.min(#guards,math.max(0,packSize-1),finalGuardCap or math.huge)or 0
 local waves={}
 for index=1,#guards-finalGuards do
  local n=math.floor((index-1)/capacity)+1;waves[n]=waves[n] or {};table.insert(waves[n],guards[index])
 end
 if boss then
  local final={boss}
  for index=#guards-finalGuards+1,#guards do table.insert(final,guards[index])end
  table.insert(waves,final)
 end
 return waves
end
-- Used only when an authored boss encounter has no normal units of its own.
local bossEscorts={Warlord='Orc',GoblinKing='Goblin',KingOgre='Ogre',EnragedWarlord='Orc',KingShaman='Shaman',
 IceTrollKing='IceTroll',KingIceBear='IceBear',KingIceGolem='IceGolem',QueenIceElf='IceElf',AncientGlacierKing='IceGolem',
 MagmaImp='Imp',MagmaGolem='Golem',InfernoOverlord='VolcanoShaman',CalderaTitan='Golem',KingVolcanoShaman='VolcanoShaman',
 AncientHollowbark='Barkstalker',HollowbarkSovereign='Barkstalker',VenomcoilKing='VenomcoilCentipede',WidowQueen='Silkweaver',
 DreadCommander='SkeletonKnight',Lich='Skeleton',LichSovereign='Mummy',Veyr='DeathKnight'}
function Balance.encounterWaves(chapter,goal,partySize,mode,version)
 local specs={};local boss,hasGuards
 for _,spec in ipairs(goal.enemies) do table.insert(specs,spec) end
 for _,stage in ipairs(goal.bossEncounter and goal.bossEncounter.waves or {}) do
  for _,spec in ipairs(stage.enemies) do table.insert(specs,spec) end
 end
 for _,spec in ipairs(specs)do if Balance.isBoss(spec.kind)then boss=spec else hasGuards=true end end
 if boss and not hasGuards then
  table.insert(specs,{kind=assert(bossEscorts[boss.kind]),level=math.max(1,boss.level-1),legacyLevel=math.max(1,(boss.legacyLevel or boss.level)-1),count=1})
 end
 local expanded=Balance.expand(specs,partySize,chapter.epic,chapter.legacyEpic)
 if version and version>=16 then for _,spec in ipairs(expanded)do spec.chapterId=chapter.id end end
 -- Keep existing kill receipt IDs even though the boss moves ahead of its final guards.
 -- Formerly solo bosses keep index 1; their new guards get new indices after it.
 local normalCount=0
 for _,spec in ipairs(expanded)do if not Balance.isBoss(spec.kind)then normalCount=normalCount+1;spec.killIndex=normalCount+(boss and not hasGuards and 1 or 0)end end
 for _,spec in ipairs(expanded)do if Balance.isBoss(spec.kind)then spec.killIndex=hasGuards and normalCount+1 or 1 end end
 local waves=Balance.waves(expanded,Balance.packCapacity(chapter,goal,partySize,mode,version),0,Easy.enabled(mode,version)and Easy.finalGuards(partySize)or nil)
 if chapter.id=='DW-01' then
  for n,batch in ipairs(waves) do for index,spec in ipairs(batch) do
   if n%4==2 or n%4==0 and index%2==0 then spec.kind='Slime' end
  end end
 end
 return waves
end
return Balance
