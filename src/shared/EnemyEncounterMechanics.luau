-- Encounter scripts describe decisions and announced geometry, never damage or rewards.
local M={version=2}
local function stage(name,sequence,styles,weakness,duration,side)
 return {name=name,sequence=sequence,styles=styles,weakness=weakness,duration=duration,side=side or 'any'}
end
local bosses={
 Warlord={id='banner-cross',counterplay='Leave the crossed sword lanes, then punish the rear after the execution.',phases={
  stage('Measured Command',{1,2,3,4},{[2]='doubleCleave'},4,1.8,'rear'),
  stage('Crossed Banners',{3,2,1,4},{[2]='tripleCleave',[4]='crossCut'},4,2,'rear'),
  stage('Broken Formation',{2,3,4,1},{[2]='backSweep',[4]='threeLanes'},4,2.3,'flank')}},
 GoblinKing={id='royal-shell-game',counterplay='Pass between the knives, leave the three bomb marks, and punish the exhausted dash.',phases={
  stage('Knife Court',{1,2,3,4},{[2]='needleVolley'},3,1.7,'flank'),
  stage('False Crown',{2,4,3,1},{[4]='meteorTriangle'},3,1.9,'rear'),
  stage('Last Trick',{4,2,1,3},{[2]='splitVolley',[4]='gatePools'},3,2.2,'any')}},
 KingOgre={id='quarry-heartbeat',counterplay='Sidestep the hammer, cross the expanding quake, then strike the unguarded back.',phases={
  stage('Quarry Hammer',{1,2,3,4},{[2]='doubleCleave'},4,2.1,'rear'),
  stage('Splitting Quarry',{3,1,2,4},{[4]='outwardWave'},4,2.4,'rear'),
  stage('Quarry Heartbeat',{2,3,4,1},{[3]='weaveVolley',[4]='heartCycle'},4,2.6,'any')}},
 EnragedWarlord={id='rage-reversal',counterplay='Bait the charge, dodge the reversing axe, and punish the final committed swing.',phases={
  stage('Rising Anger',{1,3,2,4},{[2]='doubleCleave'},2,1.8,'rear'),
  stage('Reversing Rage',{3,2,4,1},{[2]='backSweep',[4]='innerBlast'},2,2,'flank'),
  stage('Spent Fury',{2,4,3,1},{[2]='tripleCleave',[4]='heartCycle'},4,2.5,'any')}},
 KingShaman={id='totem-seal-convergence',counterplay='Thread the hex fan, leave the marked seals, and enter the safe center before punishing the totem.',phases={
  stage('Ancestral Signs',{1,2,3,4},{[2]='splitVolley'},4,1.8,'any'),
  stage('Walking Seals',{3,2,1,4},{[3]='gatePools',[4]='inwardWave'},4,2,'flank'),
  stage('Totem Convergence',{2,3,4,1},{[2]='weaveVolley',[3]='meteorTriangle',[4]='heartCycle'},4,2.4,'any')}},
 AncientHollowbark={id='elder-root-ladder',counterplay='Step across successive root lanes, stay inside the forest ring, then attack the exposed trunk.',phases={
  stage('Old Growth',{1,2,3,4},{[2]='pinchLanes'},4,2,'rear'),
  stage('Walking Roots',{2,3,1,4},{[2]='rootLadder',[3]='doubleCleave'},4,2.2,'flank'),
  stage('Splintered Heartwood',{3,2,4,1},{[2]='threeLanes',[4]='inwardWave'},4,2.6,'any')}},
 HollowbarkSovereign={id='sovereign-root-cage',counterplay='Use the gaps in the root cage, reverse direction for the branch sweep, then strike the trunk.',phases={
  stage('Royal Canopy',{1,3,2,4},{[3]='doubleCleave'},4,2,'rear'),
  stage('Root Cage',{2,1,4,3},{[2]='pinchLanes',[4]='outwardWave'},4,2.3,'flank'),
  stage('Falling Crown',{3,4,2,1},{[2]='rootLadder',[3]='backSweep',[4]='heartCycle'},4,2.6,'any')}},
 VenomcoilKing={id='venom-coil-break',counterplay='Sidestep the locked lunge, escape the alternating coils, and punish the flank after the tail settles.',phases={
  stage('Venom Coil',{1,2,3,4},{[3]='doubleCleave'},2,1.9,'flank'),
  stage('Forked Trail',{2,4,1,3},{[1]='splitVolley',[4]='gatePools'},3,2,'rear'),
  stage('Uncoiling King',{4,3,2,1},{[3]='backSweep',[4]='meteorTriangle'},3,2.5,'flank')}},
 WidowQueen={id='widow-silk-weave',counterplay='Move through the web-lane gaps, leave the brood marks, and punish the queen after her weave.',phases={
  stage('Silken Court',{1,2,3,4},{[2]='splitVolley'},3,1.8,'flank'),
  stage('Crossed Webs',{3,2,4,1},{[3]='crossCut',[4]='gatePools'},4,2,'rear'),
  stage('Broken Brood',{2,4,3,1},{[2]='weaveVolley',[3]='pinchLanes',[4]='meteorTriangle'},4,2.4,'any')}},
 KingIceBear={id='winter-maul-cycle',counterplay='Bait the straight rush, dodge across the frost wave, and strike behind the recovering bear.',phases={
  stage('Rime Hunter',{1,3,2,4},{[2]='doubleCleave'},2,1.9,'rear'),
  stage('Winter Circles',{3,4,1,2},{[4]='outwardWave'},4,2.2,'rear'),
  stage('Last Winter',{2,3,4,1},{[2]='backSweep',[4]='heartCycle'},4,2.5,'flank')}},
 IceTrollKing={id='avalanche-fork',counterplay='Keep moving between boulder volleys, sidestep the forked avalanche, and punish the heavy club recovery.',phases={
  stage('Boulder King',{1,3,2,4},{[3]='needleVolley'},2,2,'rear'),
  stage('Split Avalanche',{3,2,4,1},{[3]='weaveVolley',[4]='crossCut'},4,2.2,'flank'),
  stage('Falling Mountain',{2,4,3,1},{[2]='doubleCleave',[4]='threeLanes'},4,2.6,'rear')}},
 KingIceGolem={id='crystal-bastion-shift',counterplay='Cross the fissures through their gaps, move between the bastion marks, and hit the cooling core.',phases={
  stage('Crystal Guard',{1,2,3,4},{[2]='pinchLanes'},4,2,'rear'),
  stage('Shifting Bastion',{2,4,1,3},{[3]='gatePools',[4]='inwardWave'},4,2.3,'flank'),
  stage('Fractured Core',{3,2,4,1},{[2]='rootLadder',[4]='heartCycle'},4,2.6,'any')}},
 QueenIceElf={id='prism-queen-refraction',counterplay='Read the alternating prism volleys, move out of the falling crystals, and punish the end of refraction.',phases={
  stage('Prism Court',{1,2,3,4},{[2]='splitVolley'},4,1.8,'any'),
  stage('Refraction',{2,3,4,1},{[2]='weaveVolley',[3]='crossCut'},4,2,'flank'),
  stage('Shattered Crown',{3,4,2,1},{[3]='threeLanes',[4]='meteorTriangle'},4,2.4,'any')}},
 AncientGlacierKing={id='glacier-procession',counterplay='Cross the marching ice gaps, reverse across the whiteout lanes, and punish the glacier after the procession.',phases={
  stage('Glacier March',{1,3,2,4},{[2]='needleVolley'},4,2,'flank'),
  stage('Divided Glacier',{3,4,1,2},{[3]='gatePools',[4]='crossCut'},4,2.2,'rear'),
  stage('Whiteout Procession',{2,3,4,1},{[2]='weaveVolley',[3]='meteorTriangle',[4]='rootLadder'},4,2.6,'any')}},
 MagmaImp={id='ember-shell-game',counterplay='Use the gaps in the scatter, bait the flare dash, then punish the final ember chain.',phases={
  stage('Spark Crown',{1,2,3,4},{[2]='splitVolley'},3,1.6,'flank'),
  stage('Scattering Embers',{2,4,3,1},{[4]='gatePools'},3,1.9,'rear'),
  stage('Crown Burnout',{4,3,2,1},{[2]='weaveVolley',[4]='meteorTriangle'},4,2.4,'any')}},
 MagmaGolem={id='molten-core-valves',counterplay='Avoid the crossing lava channels, change sides for the vent sweep, and punish the exposed core.',phases={
  stage('Molten Guard',{1,2,3,4},{[2]='doubleCleave'},4,2,'rear'),
  stage('Opening Valves',{3,2,1,4},{[3]='crossCut',[4]='backSweep'},4,2.3,'flank'),
  stage('Core Burnout',{2,3,4,1},{[3]='pinchLanes',[4]='tripleCleave'},4,2.6,'any')}},
 KingVolcanoShaman={id='volcanic-vent-lattice',counterplay='Move through the cinder gaps, leave each vent mark, and punish the convergence after it finishes.',phases={
  stage('Cinder Signs',{1,2,3,4},{[2]='splitVolley'},4,1.9,'any'),
  stage('Vent Lattice',{3,2,4,1},{[3]='gatePools',[4]='inwardWave'},4,2.2,'flank'),
  stage('Volcanic Convergence',{2,4,3,1},{[2]='weaveVolley',[3]='meteorTriangle',[4]='heartCycle'},4,2.5,'any')}},
 InfernoOverlord={id='furnace-door-cycle',counterplay='Cross the flame-lane gaps, move inside then outside the furnace waves, and punish the spent blade.',phases={
  stage('Furnace Guard',{1,2,3,4},{[2]='doubleCleave'},4,1.9,'rear'),
  stage('Furnace Doors',{3,2,4,1},{[3]='gatePools',[4]='inwardWave'},4,2.3,'flank'),
  stage('Furnace Collapse',{2,4,3,1},{[2]='backSweep',[3]='meteorTriangle',[4]='heartCycle'},4,2.6,'any')}},
 CalderaTitan={id='caldera-impact-triangle',counterplay='Leave the three impact marks, cross the rupture gaps, and strike the titan during its long recovery.',phases={
  stage('Titan Footfalls',{1,2,3,4},{[2]='gatePools'},3,2.1,'rear'),
  stage('Impact Triangle',{2,3,1,4},{[3]='meteorTriangle',[4]='crossCut'},4,2.4,'flank'),
  stage('Caldera Collapse',{3,4,2,1},{[2]='meteorTriangle',[3]='heartCycle',[4]='threeLanes'},4,2.8,'any')}},
 Lich={id='grave-rune-procession',counterplay='Thread the soul lances, step between the grave runes, and punish the final soul arc.',phases={
  stage('Soul Harvest',{1,2,3,4},{[2]='needleVolley'},4,1.8,'any'),
  stage('Grave Procession',{3,2,4,1},{[3]='gatePools',[4]='crossCut'},4,2.1,'flank'),
  stage('Broken Phylactery',{2,3,4,1},{[2]='weaveVolley',[3]='meteorTriangle',[4]='threeLanes'},4,2.5,'any')}},
 LichSovereign={id='royal-seal-inversion',counterplay='Pass between the royal seals, change safe zones for soul collapse, and punish the exhausted sovereign.',phases={
  stage('Royal Seals',{1,2,3,4},{[2]='splitVolley'},4,1.9,'any'),
  stage('Inverted Seals',{2,3,4,1},{[3]='gatePools',[4]='inwardWave'},4,2.2,'flank'),
  stage('Soul Throne Collapse',{3,4,2,1},{[2]='weaveVolley',[3]='meteorTriangle',[4]='heartCycle'},4,2.6,'any')}},
 DreadCommander={id='dread-march-reversal',counterplay='Step across the marching blades, read the rear sweep, and attack the flank after banner break.',phases={
  stage('Dread Formation',{1,3,2,4},{[2]='doubleCleave'},4,1.9,'flank'),
  stage('Broken March',{3,2,4,1},{[3]='pinchLanes',[4]='backSweep'},4,2.2,'rear'),
  stage('Last Standard',{2,4,3,1},{[2]='tripleCleave',[3]='rootLadder',[4]='backSweep'},4,2.6,'flank')}},
 Veyr={id='throne-heart-inversion',counterplay='Cross the throne cuts, alternate inside and outside the heart waves, and punish the final gate recovery.',phases={
  stage('Throne Guard',{1,2,3,4},{[2]='crossCut'},4,2,'flank'),
  stage('Divided Heart',{2,3,4,1},{[3]='inwardWave',[4]='splitVolley'},3,2.3,'rear'),
  stage('Last Throne',{3,2,4,1},{[2]='threeLanes',[3]='heartCycle',[4]='weaveVolley'},4,2.8,'any')}},
}
local ordinary={
 Slime={id='gel-rebound',counterplay='Step out of the hop mark, then leave the splash cone.',attack=2,style='doubleCleave',side='any',duration=1.3},
 Goblin={id='knife-feint',counterplay='Let both knife cuts pass, then punish the flank.',attack=2,style='doubleCleave',side='flank',duration=1.5},
 Orc={id='committed-overhead',counterplay='Sidestep the narrow overhead cut and punish the rear.',attack=2,style='overheadLine',side='rear',duration=1.9},
 Shaman={id='hex-circle-denial',counterplay='Close in between bolts, leave the fixed hex circle, and punish the cast recovery.',attack=2,style='hexPool',side='any',duration=1.6},
 Ogre={id='hammer-commitment',counterplay='Leave the narrow ground break and attack the unguarded back.',attack=2,style='overheadLine',side='rear',duration=2.1},
 IceWolf={id='frost-fang-feint',counterplay='Dodge across both bite cones, then strike the flank.',attack=2,style='fangFeint',side='flank',duration=1.5},
 IceBear={id='raking-maul',counterplay='Move behind the bear during its heavy maul.',attack=2,style='wideMaul',side='rear',duration=1.9},
 IceTroll={id='boulder-commitment',counterplay='Sidestep the boulder and close during the throw recovery.',attack=2,style='singleBoulder',side='any',duration=1.7},
 IceGolem={id='forked-fissure',counterplay='Use the gap between the fissures and punish the core.',attack=2,style='crossCut',side='flank',duration=1.9},
 IceElf={id='crystal-refraction',counterplay='Cross between the alternating crystal volleys and interrupt the recovery.',attack=2,style='weaveVolley',side='any',duration=1.7},
 Imp={id='spark-sidestep',counterplay='Pass between the spark fan and close while it recovers.',attack=2,style='splitVolley',side='any',duration=1.6},
 LavaSlime={id='lava-stepping-stones',counterplay='Leave the marked lava pools and use the dry gaps.',attack=2,style='gatePools',side='any',duration=1.7},
 Golem={id='stone-safe-center',counterplay='Enter the safe center of the quake, then strike the stone core.',attack=2,style='outwardWave',side='any',duration=2},
 MagmaWorm={id='locked-burrow-rush',counterplay='Sidestep the locked burrow lane and punish the emerging worm.',attack=2,side='flank',duration=1.8},
 VolcanoShaman={id='burning-vent',counterplay='Leave the fixed vent circle, then punish the exposed caster.',attack=2,style='hexPool',side='any',duration=1.7},
 Webling={id='web-pounce-mark',counterplay='Leave the pounce mark before it lands and attack from the side.',attack=2,side='flank',duration=1.5},
 Silkweaver={id='silk-lane-gap',counterplay='Move through the gap between web lanes and close during the weave recovery.',attack=2,style='pinchLanes',side='any',duration=1.8},
 Barkstalker={id='root-lane-ambush',counterplay='Step through the root-lane gap and punish the exposed trunk.',attack=2,style='pinchLanes',side='rear',duration=1.9},
 Gloambat={id='locked-wing-swoop',counterplay='Sidestep the committed swoop and attack the flank after landing.',attack=2,side='flank',duration=1.5},
 VenomcoilCentipede={id='venom-mandible-reversal',counterplay='Step behind the short mandible thrust, then dodge the tail sweep.',attack=2,style='doubleCleave',side='rear',duration=1.6},
 Zombie={id='exhausted-lurch',counterplay='Sidestep the locked lurch and punish the slow recovery.',attack=2,side='any',duration=1.9},
 Skeleton={id='bone-throw-opening',counterplay='Sidestep the thrown bone and close during its recovery.',attack=2,style='singleBoulder',side='any',duration=1.5},
 Ghoul={id='ghoul-lunge',counterplay='Dodge the straight lunge and punish the exposed flank.',attack=2,side='flank',duration=1.6},
 SkeletonKnight={id='shield-riposte-opening',counterplay='Move around the frontal guard and punish the short shield thrust from behind.',attack=2,style='overheadLine',side='rear',duration=1.8},
 DeathKnight={id='delayed-dread-cleave',counterplay='Wait for the delayed cleave, dodge through its flank, and punish the rear.',attack=2,style='backSweep',side='rear',duration=1.9},
 Mummy={id='dust-ring-inversion',counterplay='Move from the outer dust band into its safe center, then punish the curse recovery.',attack=2,style='inwardWave',side='any',duration=1.8},
 Hellhound={id='cinder-charge-opening',counterplay='Sidestep the cinder charge and punish the hound before it turns.',attack=2,side='flank',duration=1.6},
}
local function copy(source)
 local d={}for key,value in pairs(source)do d[key]=value end return d
end
function M.phase(kind,health)
 if not bosses[kind]then return 1 end
 return health and health<=.35 and 3 or health and health<=.7 and 2 or 1
end
function M.get(kind)return bosses[kind]or ordinary[kind]end
function M.stage(kind,phase)local boss=bosses[kind];return boss and boss.phases[phase or 1]end
function M.order(kind,phase,last,count)
 local s=M.stage(kind,phase);if not s then return nil end
 local cursor=1
 local lastIndex=last and tonumber(last:match('%.(%d+)$'))
 if lastIndex then for i,index in ipairs(s.sequence)do if index==lastIndex then cursor=i%#s.sequence+1;break end end end
 local result={}for offset=0,#s.sequence-1 do result[#result+1]=s.sequence[(cursor+offset-1)%#s.sequence+1]end
 return result
end
local function pulse(shape,fields)
 local result=fields or {};result.shape=shape;return result
end
local function applyStyle(d,style,tier)
 local count=tier>=3 and 3 or 2
 if style=='doubleCleave'or style=='tripleCleave'or style=='backSweep'or style=='fangFeint'then
  d.shape='cone';d.motion='sweep';d.motionStyle='sweep';d.pulses=style=='tripleCleave'and 3 or 2;d.interval=style=='fangFeint'and .65 or .8
  d.angle=style=='backSweep'and 78 or style=='fangFeint'and 52 or 62
  local yaws=style=='backSweep'and {-35,115}or style=='tripleCleave'and {-48,0,48}or {-28,28}
  d.pulseShapes={}for i=1,d.pulses do d.pulseShapes[i]=pulse('cone',{yaw=yaws[i],centerMode='origin'})end
 elseif style=='crossCut'or style=='threeLanes'or style=='pinchLanes'or style=='rootLadder'then
  d.shape='line';d.motion='sweep';d.motionStyle='thrust';d.pulses=(style=='threeLanes'or style=='rootLadder')and 3 or 2;d.interval=.85;d.width=1.25
  d.pulseShapes={}
  for i=1,d.pulses do
   local yaw=style=='crossCut'and (i==1 and -28 or 28)or style=='threeLanes'and (i-2)*32 or 0
   local offset=style=='pinchLanes'and (i==1 and -3.5 or 3.5)or style=='rootLadder'and (i-2)*3.8 or 0
   d.pulseShapes[i]=pulse('line',{yaw=yaw,offsetRight=offset,centerMode='origin'})
  end
 elseif style=='outwardWave'or style=='inwardWave'or style=='heartCycle'then
  d.shape='ring';d.motion='slam';d.motionStyle='slam';d.pulses=style=='heartCycle'and 3 or count;d.interval=style=='heartCycle'and 1.05 or .85
  d.radius=math.min(9,math.max(6,d.radius));d.innerRadius=2;d.maxRange=math.min(d.maxRange,d.radius+1);d.pulseShapes={}
  for i=1,d.pulses do
   local progress=(i-1)/(d.pulses-1)
   local scale=style=='inwardWave'and (1-.45*progress)or (.55+.45*progress)
   local radius=d.radius*scale
   d.pulseShapes[i]=pulse('ring',{radius=radius,innerRadius=math.max(1.5,radius-2.2),centerMode='origin'})
  end
  if style=='heartCycle'then
   d.pulseShapes={pulse('ring',{radius=d.radius,innerRadius=d.radius-2.4,centerMode='origin'}),
    pulse('circle',{radius=d.radius-2,centerMode='origin'}),
    pulse('ring',{radius=d.radius,innerRadius=d.radius-2.4,centerMode='origin'})}
  end
 elseif style=='gatePools'or style=='meteorTriangle'then
  d.shape='trail';d.motion='cast';d.motionStyle='cast';d.pulses=3;d.interval=.9;d.radius=2.6;d.maxRange=math.min(24,d.maxRange)
  local offsets=style=='meteorTriangle'and {{-4,0},{4,0},{0,1.5}}or {{-5,2},{5,2},{0,0}}
  d.pulseShapes={}for i,offset in ipairs(offsets)do d.pulseShapes[i]=pulse('circle',{centerMode='aim',offsetRight=offset[1],offsetForward=offset[2]})end
 elseif style=='needleVolley'or style=='weaveVolley'or style=='splitVolley'then
  d.shape='projectile';d.motion='cast';d.motionStyle='cast';d.pulses=style=='splitVolley'and 2 or 3;d.interval=style=='needleVolley'and .6 or .85
  d.fan=style=='splitVolley'and 3 or 1;d.spread=50;d.pulseShapes={}
  local yaws=style=='weaveVolley'and {-15,15,0}or style=='splitVolley'and {-10,10}or {0,0,0}
  for i=1,d.pulses do d.pulseShapes[i]=pulse('projectile',{yaw=yaws[i],centerMode='origin'})end
 elseif style=='overheadLine'then
  d.shape='line';d.motion='slam';d.motionStyle='thrust';d.pulses=1;d.width=1;d.windup=math.max(1.6,d.windup)
 elseif style=='wideMaul'then
  d.shape='cone';d.motion='slam';d.motionStyle='slam';d.pulses=1;d.angle=120;d.windup=math.max(1.6,d.windup)
 elseif style=='hexPool'then
  d.shape='circle';d.motion='cast';d.motionStyle='cast';d.pulses=count;d.interval=.85;d.radius=math.min(4,d.radius)
  d.pulseShapes={}for i=1,d.pulses do d.pulseShapes[i]=pulse('circle',{centerMode='aim'})end
 elseif style=='innerBlast'then
  d.shape='circle';d.motion='slam';d.motionStyle='slam';d.pulses=2;d.interval=1;d.radius=7
  d.pulseShapes={pulse('circle',{radius=3,centerMode='origin'}),pulse('ring',{radius=7,innerRadius=2.7,centerMode='origin'})}
 elseif style=='singleBoulder'then d.pulses=1;d.windup=math.max(1.25,d.windup)end
 if d.pulseShapes then d.spellStyle=style end
end
function M.apply(kind,definition,tier,health)
 local d=definition;local signature=M.get(kind);if not signature then return d end
 local phase=M.phase(kind,health);local s=M.stage(kind,phase)
 local index=tonumber(d.id:match('%.(%d+)$'))or 1
 d.phase=phase;d.mechanicId=signature.id;d.counterplay=signature.counterplay
 local style=s and s.styles[index]or not s and index==signature.attack and signature.style
 if style then applyStyle(d,style,tier)end
 if s then
  d.phaseName=s.name
  for step,attack in ipairs(s.sequence)do if attack==index then d.comboStep=step end end
 end
 if (s and index==s.weakness)or (not s and index==signature.attack)then
  d.weaknessDuration=s and s.duration or signature.duration
  d.weaknessSide=s and s.side or signature.side
  d.recovery=math.max(d.recovery,d.weaknessDuration)
 end
 -- A new spatial pattern always announces every pulse before the first release.
 if d.pulseShapes then
  d.windup=math.max(d.windup,phase>=2 and 1.5 or 1.25)
  if tier==1 then d.interval=d.interval+.12;d.windup=d.windup+.15 end
 end
 d.pulses=math.min(3,d.pulses);d.fan=math.min(3,d.fan)
 return d
end
function M.pulseGeometry(definition,pulseIndex)
 local result=copy(definition)
 local override=definition.pulseShapes and definition.pulseShapes[pulseIndex]
 if override then for key,value in pairs(override)do result[key]=value end end
 return result
end
return M
