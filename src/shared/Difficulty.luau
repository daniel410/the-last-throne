-- Trial tuning; Easy Lv1 and repeatable Hell are user decisions.
local Content=game and require(script.Parent.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local D={version=1,order={'Easy','Hard','Insane','Hell'},modes={
 Easy={level=1,hp=1,damage=1,bossHP=1,bossDamage=1,xp=1,gold=1,ore=6,cores=0,cache=1},
 Hard={level=20,previous='Easy',hp=1.35,damage=1.2,bossHP=1.25,bossDamage=1.15,xp=1.15,gold=1.5,ore=8,cores=1,cache=2},
 Insane={level=40,previous='Hard',hp=1.7,damage=1.4,bossHP=1.5,bossDamage=1.3,xp=1.3,gold=2,ore=10,cores=2,cache=3},
 Hell={level=80,previous='Insane',hp=2.1,damage=1.65,bossHP=1.8,bossDamage=1.5,xp=1.5,gold=3,ore=12,cores=3,cache=4}}}
-- Minimum levels reached by the current mandatory route, starting at Lv1.
local levels={1,3,4,4,6,9,10,12,13,13,14,15,17,19,20,21,21,23,24,25,27}
function D.mission(id)return Content.byId[id]end
function D.combat(c)
 for _,g in ipairs(c and c.goals or {})do if #(g.enemies or {})>0 then return true end end
 return false
end
function D.entry(c)return levels[c.number] or (c.epic==3 and 20 or c.epic==2 and 12 or 1)end
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
 if not run or run.rulesVersion~=D.version or not a or a.runId~=run.id or a.missionId~=run.missionId or a.difficultyId~=run.difficultyId or a.version~=run.rulesVersion then return false,'AdventureChanged'end
 return D.allowed(hero,run.missionId,run.difficultyId)
end
function D.stats(kind,level,partySize,boss,mode)
 local m=D.modes[mode] or D.modes.Easy;local effective=math.max(level,m.level)
 local party=(boss and {1,1.7,2.3,2.8}or {1,1.5,2,2.5})[math.max(1,math.min(4,partySize or 1))]
 local hp=(boss and 1000+effective*100 or 100+effective*25)*party*(boss and m.bossHP or m.hp)
 local damage=(boss and 28+effective*2 or 10+effective)*(boss and m.bossDamage or m.damage)
 return math.floor(hp+.5),math.floor(damage+.5),effective
end
return D
