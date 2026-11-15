-- Shared combat vocabulary. The server resolves these definitions before publishing a cast.
-- This module never changes damage, rewards, ownership, or the stable attack IDs.
local P={version=1}
local rows={
 -- kind = role, weapon, preferred range, retreat range, strafe weight, approach angle
 Slime={'pouncer','gel',3.5,0,.12,0},
 Goblin={'skirmisher','dagger',4.2,0,.85,38},
 Orc={'bruiser','axe',4.8,0,.12,12},
 Shaman={'caster','staff',18,10,.4,16},
 Ogre={'bruiser','club',4.8,0,.08,6},
 Warlord={'commander','sword',5,0,.3,20},
 GoblinKing={'skirmisher','dagger',10,5,.85,42},
 KingOgre={'bruiser','club',5.2,0,.12,8},
 EnragedWarlord={'bruiser','axe',5,0,.35,22},
 KingShaman={'caster','totem',20,11,.45,18},
 Webling={'controller','fang',10,5,.65,30},
 Silkweaver={'controller','web',17,9,.35,20},
 Barkstalker={'guardian','branch',5,0,.15,12},
 Gloambat={'pouncer','wing',4.2,0,.8,48},
 VenomcoilCentipede={'skirmisher','mandible',5,0,.65,34},
 AncientHollowbark={'guardian','branch',6,0,.08,6},
 HollowbarkSovereign={'guardian','branch',6,0,.1,8},
 VenomcoilKing={'skirmisher','mandible',7,0,.65,32},
 WidowQueen={'controller','web',18,10,.5,26},
 IceWolf={'pouncer','fang',4,0,.85,42},
 IceBear={'bruiser','claw',4.8,0,.1,8},
 IceTroll={'bruiser','club',6,0,.15,12},
 IceGolem={'guardian','fist',5,0,.08,6},
 IceElf={'artillery','crystalStaff',21,12,.6,24},
 KingIceBear={'bruiser','claw',5.5,0,.18,12},
 IceTrollKing={'bruiser','club',7,0,.18,14},
 KingIceGolem={'guardian','fist',6,0,.1,8},
 QueenIceElf={'artillery','crystalStaff',22,12,.6,26},
 AncientGlacierKing={'controller','crystal',17,7,.2,14},
 Imp={'artillery','ember',18,10,.8,34},
 LavaSlime={'controller','gel',6,0,.1,0},
 MagmaWorm={'pouncer','fang',5,0,.4,24},
 Golem={'guardian','fist',5,0,.08,6},
 VolcanoShaman={'caster','staff',19,10,.4,18},
 MagmaImp={'artillery','ember',19,10,.85,38},
 MagmaGolem={'guardian','fist',6,0,.1,8},
 KingVolcanoShaman={'caster','totem',20,11,.45,20},
 InfernoOverlord={'commander','sword',7,0,.3,18},
 CalderaTitan={'guardian','fist',8,0,.05,4},
 Skeleton={'skirmisher','sword',5,0,.5,26},
 Zombie={'bruiser','hand',4,0,.05,2},
 Ghoul={'pouncer','claw',4.2,0,.75,40},
 SkeletonKnight={'guardian','swordShield',5,0,.25,16},
 DeathKnight={'commander','greatsword',5.5,0,.35,22},
 Mummy={'controller','curse',16,8,.18,12},
 Hellhound={'pouncer','fang',4.2,0,.75,38},
 Lich={'caster','soulStaff',20,11,.35,18},
 LichSovereign={'controller','soulStaff',21,12,.4,22},
 DreadCommander={'commander','greatsword',6,0,.35,22},
 Veyr={'commander','greatsword',8,0,.45,28},
}
local bossKinds={Warlord=true,GoblinKing=true,KingOgre=true,EnragedWarlord=true,KingShaman=true,
 AncientHollowbark=true,HollowbarkSovereign=true,VenomcoilKing=true,WidowQueen=true,
 KingIceBear=true,IceTrollKing=true,KingIceGolem=true,QueenIceElf=true,AncientGlacierKing=true,
 MagmaImp=true,MagmaGolem=true,KingVolcanoShaman=true,InfernoOverlord=true,CalderaTitan=true,
 Lich=true,LichSovereign=true,DreadCommander=true,Veyr=true}
local modes={
 Easy={tier=1,tactics=.25,spacing=1.08,cooldown=1.12},
 Hard={tier=2,tactics=.6,spacing=1,cooldown=1},
 Insane={tier=3,tactics=.85,spacing=.96,cooldown=.94},
 Hell={tier=4,tactics=1,spacing=.92,cooldown=.88},
}
local weaponShapes={
 dagger={angle=60,width=.9,windup=1,recovery=.8,style='thrust'},
 axe={angle=110,width=1.5,windup=1.18,recovery=1,style='cleave'},
 sword={angle=90,width=1.15,windup=1.08,recovery=.9,style='sweep'},
 swordShield={angle=80,width=1.3,windup=1.18,recovery=1,style='riposte'},
 greatsword={angle=115,width=1.6,windup=1.3,recovery=1.12,style='cleave'},
 club={angle=78,width=1.8,windup=1.38,recovery=1.2,style='slam'},
 fist={angle=80,width=1.7,windup=1.35,recovery=1.18,style='slam'},
 branch={angle=115,width=1.6,windup=1.3,recovery=1.12,style='sweep'},
 claw={angle=92,width=1.25,windup=1.12,recovery=.92,style='rake'},
 fang={angle=58,width=1.05,windup=1,recovery=.85,style='bite'},
 mandible={angle=72,width=1.05,windup=1.12,recovery=.9,style='thrust'},
 wing={angle=105,width=1.2,windup=1.05,recovery=.85,style='swoop'},
 hand={angle=72,width=1.5,windup=1.42,recovery=1.2,style='grasp'},
 gel={angle=95,width=1.5,windup=1.2,recovery=1,style='hop'},
}
local names={
 ['Warlord.1']="Commander's Edge", ['GoblinKing.1']='Royal Shiv',
 ['KingOgre.1']='Quarry Hammer', ['EnragedWarlord.1']='Rage Cleave',
 ['KingShaman.1']='Ancestral Hex', ['AncientGlacierKing.1']='Glacier Lance',
 ['IceTrollKing.1']='Frozen Boulder', ['KingIceBear.1']='Rime Shard',
 ['KingIceGolem.1']='Crystal Shard', ['QueenIceElf.1']='Prism Lance',
 ['MagmaImp.1']='Crown Ember', ['MagmaGolem.1']='Molten Shard',
 ['KingVolcanoShaman.1']='Volcanic Bolt', ['InfernoOverlord.1']='Furnace Spear',
 ['CalderaTitan.1']='Caldera Bomb', ['VenomcoilKing.1']='Venom Spit',
 ['WidowQueen.1']='Brood Venom', ['Lich.1']='Soul Lance',
 ['LichSovereign.1']='Royal Soul Lance', ['DreadCommander.1']='Dread Lance',
 ['Veyr.1']='Throne Rift',
}
local function copy(source)
 local result={}for key,value in pairs(source)do result[key]=value end return result
end
function P.mode(difficulty)return modes[difficulty]or modes.Easy end
function P.get(kind)
 local row=rows[kind];if not row then return nil end
 return {boss=bossKinds[kind]==true,role=row[1],weapon=row[2],preferredRange=row[3],retreatRange=row[4],strafe=row[5],approachAngle=row[6],
  turnRate=(row[1]=='bruiser'or row[1]=='guardian')and 3.2 or 5.5}
end
function P.resolve(kind,base,difficulty,healthRatio)
 local profile=P.get(kind);if not profile then return copy(base)end
 local d=copy(base);local mode=P.mode(difficulty);local weapon=weaponShapes[profile.weapon]
 d.weapon=profile.weapon;d.combatProfileVersion=P.version
 d.phase=(profile.boss and healthRatio and healthRatio<=.5)and 2 or 1
 d.name=names[d.id]or d.name
 -- A shield and a mandible connect at body reach; neither emits a distant lane.
 if d.id=='SkeletonKnight.2'or d.id=='VenomcoilCentipede.1'then
  d.range=6;d.maxRange=5.4
  if d.id=='SkeletonKnight.2'then d.name='Shield Thrust' end
 end
 local index=tonumber(d.id:match('%.(%d+)$'))or 1
 local contact=d.shape~='projectile'and d.shape~='trail'and d.motion~='dash' and d.range<=10
 d.motionStyle=weapon and weapon.style or 'cast'
 if weapon and contact then
  d.angle=weapon.angle;d.width=weapon.width
  d.windup=math.max(d.windup,weapon.windup+(d.heavy and .28 or 0))
  d.recovery=math.max(d.recovery,weapon.recovery+(d.heavy and .2 or 0))
  if d.shape=='line'then d.motionStyle='thrust' end
  if d.motion=='slam'then d.motionStyle='slam' end
  -- Fast weapons carry an announced follow-up; every pulse shares one damage budget.
  if index==2 and (profile.weapon=='dagger'or kind=='IceWolf'or kind=='Ghoul')then
   d.pulses=math.max(d.pulses,2);d.interval=.48
  end
 end
 if d.motion=='dash'then d.motionStyle='lunge' end
 d.spellStyle=d.element
 if d.shape=='projectile'then
  d.motionStyle='cast'
  if d.element=='frost'then d.spellStyle='iceLance';d.speed=d.speed*1.12;d.spread=34
  elseif d.element=='fire'then d.spellStyle='emberFan';d.speed=d.speed*.95;d.spread=48
  elseif d.element=='venom'then d.spellStyle='venomSpit';d.speed=d.speed*.82;d.spread=42
  elseif d.element=='web'then d.spellStyle='silkDart';d.speed=d.speed*.86;d.spread=46
  elseif d.element=='soul'then d.spellStyle='soulLance';d.speed=d.speed*.9;d.interval=.72
  elseif d.element=='arcane'then d.spellStyle='hexBolt';d.speed=d.speed*1.05;d.interval=.6
  elseif d.element=='shadow'then d.spellStyle='riftBolt';d.interval=.68 end
  if mode.tier>=3 and index>1 and (profile.role=='caster'or profile.role=='artillery')then d.pulses=math.min(3,math.max(2,d.pulses))end
 elseif d.element=='fire'and d.shape=='circle'then
  d.spellStyle='burningGround';d.pulses=math.max(d.pulses,mode.tier>=3 and 3 or 2);d.interval=.7
 elseif d.element=='frost'and d.shape=='ring'then
  d.spellStyle='expandingRing';d.pulses=mode.tier>=3 and 3 or 2;d.interval=.65
 elseif d.shape=='trail'then
  d.spellStyle=({fire='lavaLanes',frost='crystalFall',venom='venomPools',web='silkLanes',soul='graveRunes',shadow='riftLanes',arcane='hexSeals'})[d.element]or 'rootLanes'
  d.interval=d.element=='venom'and .8 or d.element=='soul'and .75 or d.interval
 end
 -- Easy keeps a longer response/opening. Later modes preserve those hard floors.
 if mode.tier==1 then d.windup=d.windup+.12;d.recovery=d.recovery+.1 end
 d.windup=math.max(1,d.windup);d.recovery=math.max(.8,d.recovery)
 d.cooldown=math.max(2,d.cooldown*mode.cooldown*(d.phase==2 and .94 or 1))
 if d.phase==2 and d.shape=='projectile'and d.fan>1 then d.spread=math.min(58,d.spread+6)end
 d.pulses=math.min(3,d.pulses);d.fan=math.min(3,d.fan)
 d.active=(d.pulses-1)*d.interval+(d.shape=='projectile'and d.range/d.speed or d.motion=='dash'and .45 or .22)
 return d
end
function P.pulseGeometry(definition,pulse)
 local d=copy(definition)
 if d.spellStyle=='expandingRing'and d.pulses>1 then
  local progress=math.max(0,math.min(1,(pulse-1)/(d.pulses-1)))
  d.radius=definition.radius*(.55+.45*progress)
  d.innerRadius=math.max(1,d.radius-2.5)
 end
 return d
end
return P
