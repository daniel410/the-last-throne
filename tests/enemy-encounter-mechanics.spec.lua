local Patterns=dofile('src/shared/EnemyPatterns.luau')
local Profiles=dofile('src/shared/EnemyCombatProfiles.luau')
local Tactics=dofile('src/shared/EnemyCombatTactics.luau')
local Mechanics=dofile('src/shared/EnemyEncounterMechanics.luau')
local Geometry=dofile('src/shared/EnemyAttackGeometry.luau')
local count=0
local function check(value,message)count=count+1;assert(value,message)end
local function fingerprint(kind,health)
 local pieces={}
 for _,base in ipairs(Patterns.get(kind).attacks)do
  local d=Profiles.resolve(kind,base,'Hard',health)
  pieces[#pieces+1]=d.shape..d.element..d.pulses..d.fan
  for pulse=1,d.pulses do
   local g=Profiles.pulseGeometry(d,pulse)
   pieces[#pieces+1]=table.concat({g.shape,g.radius,g.innerRadius,g.angle,g.width,g.yaw or 0,g.offsetRight or 0,g.offsetForward or 0},'/')
  end
 end
 return table.concat(pieces,'|')
end
local signatures={}
local bossCount,ordinaryCount=0,0
for kind,profile in pairs(Patterns.profiles)do
 local signature=Profiles.signature(kind)
 check(signature and #signature.counterplay>30,'every species has actionable counterplay: '..kind)
 check(not signatures[signature.id],'species signature ID is unique: '..kind);signatures[signature.id]=true
 if profile.boss then
  bossCount=bossCount+1
  check(#signature.phases==3,'three authored boss phases: '..kind)
  check(Profiles.phase(kind,.71)==1 and Profiles.phase(kind,.7)==2,'first threshold is exact: '..kind)
  check(Profiles.phase(kind,.36)==2 and Profiles.phase(kind,.35)==3,'final threshold is exact: '..kind)
  local phaseFingerprints={}
  for phase,health in ipairs({1,.6,.2})do
   local s=signature.phases[phase]
   check(#s.sequence==4,'phase includes every authored move: '..kind)
   local included={}
   for _,index in ipairs(s.sequence)do check(index>=1 and index<=4 and not included[index],'phase order contains no missing/duplicated moves');included[index]=true end
   local previous
   local observed={}
   local history={ready={}}
   for turn=1,4 do
    local selected=Tactics.choose(profile,kind,4,history,turn*30,'Hard',health)
    check(selected~=nil,'solo melee has a reachable counterplay action: '..kind)
    observed[#observed+1]=tonumber(selected.id:match('%.(%d+)$'))
    check(selected.id~=previous,'phase combo cannot immediately repeat a move: '..kind)
    history.last=selected.id;previous=selected.id
   end
   for i,index in ipairs(s.sequence)do check(observed[i]==index,'boss follows authored phase sequence: '..kind)end
   local final=Profiles.resolve(kind,profile.attacks[s.weakness],'Hard',health)
   check(final.weaknessDuration>=1.6 and final.recovery>=final.weaknessDuration,'finisher leaves a real punish window: '..kind)
   check(final.weaknessSide=='rear'or final.weaknessSide=='flank'or final.weaknessSide=='any','weakness has a server-readable side')
   local f=table.concat(observed,',')..fingerprint(kind,health)
   check(not phaseFingerprints[f],'phase changes actual combo or spatial geometry: '..kind);phaseFingerprints[f]=true
  end
 else
  ordinaryCount=ordinaryCount+1
  check(Profiles.phase(kind,.01)==1,'normal monster cannot enter a boss phase')
  local opening=Profiles.resolve(kind,profile.attacks[signature.attack],'Hard',1)
  check(opening.weaknessDuration>=1.3 and opening.recovery>=opening.weaknessDuration,'signature move has a punish window: '..kind)
 end
 for _,health in ipairs({1,.6,.2})do
  for _,base in ipairs(profile.attacks)do
   for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
    local d=Profiles.resolve(kind,base,mode,health)
    check(d.id==base.id and d.damage==base.damage,'stable attack and damage budget: '..kind)
    check(d.windup>=1 and d.recovery>=.8,'class-independent reaction window')
    check(d.pulses<=3 and d.fan<=3,'finite encounter visual/damage budget')
    for pulse=1,d.pulses do
     local g=Profiles.pulseGeometry(d,pulse)
     check(g.range<=32 and g.radius<=9,'bounded warning footprint')
     check(math.abs(g.offsetRight or 0)<=5 and math.abs(g.offsetForward or 0)<=5,'bounded locked spatial offsets')
     if g.centerMode=='aim'then
      local reach=math.sqrt((g.offsetRight or 0)^2+(g.offsetForward or 0)^2)+g.radius
      check(d.maxRange+reach<=32.000001,'targeted warning cannot escape the32stud contract')
     end
     if d.pulseShapes then check(d.windup>=1.25,'new spatial mechanic is announced before its first pulse')end
    end
   end
  end
 end
end
check(bossCount==23 and ordinaryCount==27,'current shipped roster is fully authored')
-- Crossed lanes leave a center corridor; their damage reaches either side.
local cross=Profiles.resolve('Warlord',Patterns.get('Warlord').attacks[4],'Hard',.6)
check(cross.pulseShapes~=nil and cross.pulses==2,'crossed execution has two independently announced lanes')
for pulse=1,cross.pulses do
 local g=Profiles.pulseGeometry(cross,pulse)
 local lateral=12*math.sin(math.rad(g.yaw))
 check(not Geometry.contains('line',lateral,12*math.cos(math.rad(g.yaw)),0,g.range,g.width,g.radius,g.innerRadius,g.angle),'center corridor escapes a diagonal lane')
 check(Geometry.contains('line',0,math.min(12,g.range),0,g.range,g.width,g.radius,g.innerRadius,g.angle),'each warned execution lane still deals damage')
end
-- Heart cycle requires changing safe space; waiting at one safe center is insufficient.
local heart=Profiles.resolve('KingOgre',Patterns.get('KingOgre').attacks[4],'Hard',.2)
local outside=Profiles.pulseGeometry(heart,1)
local inside=Profiles.pulseGeometry(heart,2)
check(outside.shape=='ring'and inside.shape=='circle','late quake changes outside/inside geometry')
check(not Geometry.contains(outside.shape,0,0,0,outside.range,outside.width,outside.radius,outside.innerRadius,outside.angle),'center initially safe')
check(Geometry.contains(inside.shape,0,0,0,inside.range,inside.width,inside.radius,inside.innerRadius,inside.angle),'center must be left before second pulse')
check(heart.interval>=1,'safe-space transition leaves enough walking time for every class')
-- Within the warned outer radius, inside/outside sequences have no permanent
-- safe annulus. Each release still has a reachable safe region for every class.
local AfflictionRules=dofile('src/shared/EnemyAfflictionRules.luau')
local minimumWalkSpeed=16*AfflictionRules.minimumMovement
local function radialHit(g,r)
 return Geometry.contains(g.shape,r,0,0,g.range,g.width,g.radius,g.innerRadius,g.angle)
end
local radialPatterns=0
for kind,profile in pairs(Patterns.profiles)do
 for _,health in ipairs({1,.6,.2})do
  for _,base in ipairs(profile.attacks)do
   for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
    local d=Profiles.resolve(kind,base,mode,health)
    if d.spellStyle=='heartCycle'or d.spellStyle=='innerBlast'then
     radialPatterns=radialPatterns+1
     for sample=0,math.floor(d.radius*20)do
      local radius=sample/20;local threatened=false
      for pulse=1,d.pulses do threatened=threatened or radialHit(Profiles.pulseGeometry(d,pulse),radius)end
      check(threatened,'inside/outside cannot be solved by standing in a permanent safe radial band: '..kind)
     end
     local route={}
     for pulse=1,d.pulses do
      local g=Profiles.pulseGeometry(d,pulse)
      route[pulse]=g.shape=='circle'and g.radius+.3 or math.max(0,g.innerRadius-.3)
      check(route[pulse]<=d.radius and not radialHit(g,route[pulse]),'every pulse has a safe point inside the encounter footprint')
      if pulse>1 then
       check(math.abs(route[pulse]-route[pulse-1])<=minimumWalkSpeed*(d.interval-.2),'all four classes can walk between safe points even at the strongest permitted slow')
      end
     end
     if d.spellStyle=='heartCycle'then
      check(route[2]<=minimumWalkSpeed*(d.interval-.2),'even a player initially at the boss center can escape the next central blast')
     end
    elseif d.spellStyle=='gatePools'or d.spellStyle=='meteorTriangle'then
     local threatenedAim=false
     for pulse=1,d.pulses do
      local g=Profiles.pulseGeometry(d,pulse)
      threatenedAim=threatenedAim or Geometry.contains(g.shape,-(g.offsetRight or 0),-(g.offsetForward or 0),0,g.range,g.width,g.radius,g.innerRadius,g.angle)
     end
     check(threatenedAim,'a stationary locked target must move out of at least one announced pool: '..kind)
    end
   end
  end
 end
end
check(radialPatterns>=40,'inside/outside fairness covers every authored boss variant and difficulty')
-- Moving pools snapshot three separate locations rather than chasing a dodging target.
local bombs=Profiles.resolve('GoblinKing',Patterns.get('GoblinKing').attacks[4],'Hard',.6)
local centers={}
for pulse=1,bombs.pulses do
 local g=Profiles.pulseGeometry(bombs,pulse)
 check(g.centerMode=='aim','bombs use locked begin aim')
 local key=(g.offsetRight or 0)..'/'..(g.offsetForward or 0)
 check(not centers[key],'bombs occupy distinct preannounced spaces');centers[key]=true
end
-- A phase combo never stalls when its preferred move is out of reach or cooling.
local profile=Patterns.get('Warlord')
local fallback=Tactics.choose(profile,'Warlord',4,{last='Warlord.3',ready={['Warlord.2']=100}},50,'Hard',.6)
check(fallback and fallback.id~='Warlord.2','cooling preferred combo move chooses a reachable fallback')
for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear'})do
 for _,health in ipairs({1,.6,.2})do
  for _,base in ipairs(Patterns.get(kind).attacks)do
   local d=Profiles.resolve(kind,base,'Hell',health)
   check(d.range<=6 and d.maxRange<=6 and d.shape~='projectile'and d.motion~='dash','signature never gives a melee species a ranged bypass')
  end
 end
end
print('enemy-encounter-mechanics: '..count..' checks PASS; 23 authored three-phase bosses, 27 signatures, solo gaps, real punish windows')
