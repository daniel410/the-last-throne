-- Trial tuning; Easy Lv1 and repeatable Hell are user decisions.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
-- Balance/rule generation is pinned by the run and persisted hero journal.
local D={version=2,order={'Easy','Hard','Insane','Hell'},legacyModes={
 Easy={level=1,hp=1,damage=1,bossHP=1,bossDamage=1,xp=1,gold=1,ore=6,cores=0,cache=1},
 Hard={level=20,previous='Easy',hp=1.35,damage=1.2,bossHP=1.25,bossDamage=1.15,xp=1.15,gold=1.5,ore=8,cores=1,cache=2},
 Insane={level=40,previous='Hard',hp=1.7,damage=1.4,bossHP=1.5,bossDamage=1.3,xp=1.3,gold=2,ore=10,cores=2,cache=3},
 Hell={level=80,previous='Insane',hp=2.1,damage=1.65,bossHP=1.8,bossDamage=1.5,xp=1.5,gold=3,ore=12,cores=3,cache=4}}}
D.modes={
 Easy={level=1,levelShift=0,hp=1,damage=1,bossHP=1,bossDamage=1,xp=1,gold=1,cache=1},
 Hard={level=20,levelShift=15,previous='Easy',hp=1.2,damage=1.15,bossHP=1.15,bossDamage=1.1,xp=1.5,gold=2,cache=2},
 Insane={level=40,levelShift=35,previous='Hard',hp=1.4,damage=1.3,bossHP=1.3,bossDamage=1.2,xp=2,gold=3,cache=3},
 Hell={level=80,levelShift=75,previous='Insane',hp=1.65,damage=1.5,bossHP=1.5,bossDamage=1.35,xp=3,gold=5,cache=4},
}
local Economy=game and require(script.Parent.RewardEconomy)or dofile('src/shared/RewardEconomy.luau')
local Repeat=game and require(script.Parent.AdventureRepeatRewards)or dofile('src/shared/AdventureRepeatRewards.luau')
D.families={
 Slime={hp=.8,damage=.8},Goblin={hp=1,damage=1},Orc={hp=2.2,damage=1},Shaman={hp=.85,damage=.9},Ogre={hp=2.7,damage=1.1},
 IceWolf={hp=.9,damage=1},IceTroll={hp=1.25,damage=1.1},IceBear={hp=1.3,damage=1.1},IceGolem={hp=1.4,damage=.95},IceElf={hp=.85,damage=1},
 Imp={hp=.85,damage=.9},Golem={hp=1.35,damage=1},VolcanoShaman={hp=.85,damage=1},LavaSlime={hp=.9,damage=.9},MagmaWorm={hp=1.2,damage=1.05},
 Warlord={hp=1,damage=1},GoblinKing={hp=.9,damage=1},KingOgre={hp=1.15,damage=1.05},EnragedWarlord={hp=1.1,damage=1.05},KingShaman={hp=.9,damage=1},
 IceTrollKing={hp=1.1,damage=1},KingIceBear={hp=1.15,damage=1},KingIceGolem={hp=1.2,damage=1},QueenIceElf={hp=.9,damage=1},AncientGlacierKing={hp=1.15,damage=1.05},
 MagmaImp={hp=.9,damage=1},MagmaGolem={hp=1.15,damage=1},InfernoOverlord={hp=1,damage=1},CalderaTitan={hp=1.2,damage=1.05},KingVolcanoShaman={hp=.9,damage=1},
}
function D.compatible(version)return version==1 or version==D.version end
function D.mode(mode,version)
 if version~=nil and not D.compatible(version)then return nil end
 return (version==1 and D.legacyModes or D.modes)[mode]
end
function D.enemyLevel(level,mode,version)
 local m=assert(D.mode(mode,version),'Unsupported difficulty rules')
 return version==1 and math.max(level,m.level)or math.max(m.level,level+(m.levelShift or 0))
end
function D.rewardLevel(c,mode,version)
 local authored=D.entry(c)
 for _,g in ipairs(c.goals)do
  for _,unit in ipairs(g.enemies or {})do authored=math.max(authored,unit.level)end
  for _,wave in ipairs(g.bossEncounter and g.bossEncounter.waves or {})do for _,unit in ipairs(wave.enemies)do authored=math.max(authored,unit.level)end end
 end
 return D.enemyLevel(authored,mode,version)
end
function D.goldMultiplier(level,mode,version)
 local m=assert(D.mode(mode,version),'Unsupported difficulty rules')
 return m.gold*(version==1 and 1 or Economy.band(D.enemyLevel(level,mode,version)).gold)
end
function D.completion(c,mode,version)
 local m=assert(D.mode(mode,version),'Unsupported difficulty rules')
 local base=Repeat[c.id]or {xp=math.floor(c.reward.xp*.25),gold=math.floor(c.reward.coins*.30)}
 local level=D.rewardLevel(c,mode,version);local band=Economy.band(level)
 local gems,stones=0,0
 if version~=1 and D.combat(c)then gems,stones=Economy.materials(level,mode)end
 return {xp=math.floor(base.xp*m.xp),gold=math.floor(base.gold*m.gold*(version==1 and 1 or band.gold)),
  ore=version==1 and D.combat(c)and m.ore or 0,cores=version==1 and D.combat(c)and m.cores or 0,
  gems=gems,stones=stones,rewardLevel=level,rewardBand=band.level,cache=D.combat(c)and m.cache or 0}
end
-- Minimum levels reached by the current mandatory route, starting at Lv1.
local levels={1,3,4,4,6,9,10,12,13,13,14,15,17,19,20,21,21,23,24,25,27}
function D.mission(id)return Content.byId[id]end
function D.combat(c)
 for _,g in ipairs(c and c.goals or {})do if #(g.enemies or {})>0 then return true end end
 return false
end
-- Late-epic entry stays at Lv27 until a mandatory-route growth budget is accepted.
function D.entry(c)return levels[c.number] or ((c.epic or 1)>=4 and 27 or c.epic==3 and 20 or c.epic==2 and 12 or 1)end
function D.tier(c)return D.entry(c)>=10 and 10 or D.entry(c)>=5 and 5 or 1 end
-- An isolated side expedition cannot advance another main chapter to unlock its report.
function D.requiredMain(c)
 local main=c.side and c.minMain or c.number-1
 if c.side then
  for _,g in ipairs(c.goals)do
   if not g.optional then
    main=math.max(main,g.minMain or 0)
    local zone=Content.zones[g.zone or c.zone]
    if zone then main=math.max(main,zone.requiresMain or 0)end
   end
  end
 end
 return main
end
function D.allowed(hero,id,mode)
 local c,m=Content.byId[id],D.modes[mode]
 if not hero or not c or not m then return false,'InvalidMission' end
 if mode~='Easy' and not D.combat(c)then return false,'CombatMissionOnly' end
 if hero.level<math.max(m.level,D.entry(c))then return false,'DifficultyLevel' end
 local s=hero.deepwood or {main=0,clears={}}
 if s.main<D.requiredMain(c)then return false,'StoryLocked' end
 if m.previous then
  local clears=hero.expeditions and hero.expeditions.clears or {}
  local prior=clears[id] or {}
  if not prior[m.previous] and not (m.previous=='Easy' and s.clears[id])then return false,'PreviousDifficulty' end
 end
 return true
end
function D.verifyRun(hero,run)
 local a=hero and hero.expeditions and hero.expeditions.active
 if not run or not D.compatible(run.rulesVersion) or not a or a.runId~=run.id or a.missionId~=run.missionId or a.difficultyId~=run.difficultyId or (a.balanceVersion or 1)~=run.rulesVersion then return false,'AdventureChanged'end
 return D.allowed(hero,run.missionId,run.difficultyId)
end
function D.stats(kind,level,partySize,boss,mode,version)
 local m=assert(D.mode(mode or 'Easy',version),'Unsupported difficulty rules')
 local effective=D.enemyLevel(level,mode or 'Easy',version)
 local family=version==1 and {hp=1,damage=1}or D.families[kind]or {hp=1,damage=1}
 local party=(boss and {1,1.7,2.3,2.8}or {1,1.5,2,2.5})[math.max(1,math.min(4,partySize or 1))]
 local hp=(boss and 1000+effective*100 or 100+effective*25)*party*(boss and m.bossHP or m.hp)*family.hp
 local damage=(boss and 28+effective*2 or 10+effective)*(boss and m.bossDamage or m.damage)*family.damage
 return math.floor(hp+.5),math.floor(damage+.5),effective
end
return D
