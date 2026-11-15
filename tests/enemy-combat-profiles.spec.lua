local Profiles=dofile('src/shared/EnemyCombatProfiles.luau')
local Patterns=dofile('src/shared/EnemyPatterns.luau')
local Geometry=dofile('src/shared/EnemyAttackGeometry.luau')
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local count,bosses=0,0
local roles,weapons={},{}
for kind,source in pairs(Patterns.profiles)do
 local p=Profiles.get(kind);check(p~=nil,'authored species coverage: '..kind)
 count=count+1;bosses=bosses+(p.boss and 1 or 0)
 check(p.boss==source.boss,'boss phase classification: '..kind)
 check(p.retreatRange>=0 and p.retreatRange<p.preferredRange,'reachable combat spacing: '..kind)
 check(p.strafe>=0 and p.strafe<=1 and p.turnRate>0,'bounded steering: '..kind)
 roles[p.role]=true;weapons[p.weapon]=true
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  for _,health in ipairs({1,.5,.1})do
   for _,base in ipairs(source.attacks)do
    local before={}for key,value in pairs(base)do before[key]=value end
    local d=Profiles.resolve(kind,base,mode,health)
    check(d~=base and d.id==base.id,'stable skill identity; detached resolution')
    for key,value in pairs(before)do check(base[key]==value,'authored definition is immutable: '..base.id..'/'..key)end
    check(d.phase==(source.boss and health<=.5 and 2 or 1),'phase depends on boss health')
    check(d.windup>=1 and d.recovery>=.8,'minimum reaction and punish opening')
    check(d.pulses>=1 and d.pulses<=3 and d.fan>=1 and d.fan<=3,'bounded finite hit budget')
    check(d.cooldown>=2 and d.speed>0,'finite action cadence and projectile lifetime')
    check(d.active>=(d.pulses-1)*d.interval+.22,'last pulse cannot outlive attack')
    if d.shape=='projectile'then check(d.active>=(d.pulses-1)*d.interval+d.range/d.speed-.000001,'last projectile has travel budget')end
    for pulse=1,d.pulses do
     local g=Profiles.pulseGeometry(d,pulse)
     check(g~=d and g.shape==d.shape,'pulse geometry is independent')
     check(g.radius<=d.radius and g.innerRadius>=0,'pulse telegraph fits announced outer extent')
    end
   end
  end
 end
end
check(count==50 and bosses==23,'all shipped species and bosses')
local roleCount,weaponCount=0,0
for _ in pairs(roles)do roleCount=roleCount+1 end
for _ in pairs(weapons)do weaponCount=weaponCount+1 end
check(roleCount>=6 and weaponCount>=15,'tactical and weapon vocabulary')
for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear'})do
 for _,base in ipairs(Patterns.get(kind).attacks)do
  for _,mode in ipairs({'Easy','Hell'})do
   local d=Profiles.resolve(kind,base,mode,1)
   check(d.range<=6 and d.maxRange<=6,'melee role cannot emit distant hit: '..kind)
   check(d.shape~='projectile'and d.shape~='trail'and d.motion~='dash','melee identity preserved: '..kind)
  end
 end
end
for _,entry in ipairs({{'SkeletonKnight',2},{'VenomcoilCentipede',1}})do
 local d=Profiles.resolve(entry[1],Patterns.get(entry[1]).attacks[entry[2]],'Hard',1)
 check(d.shape=='line'and d.range==6 and d.maxRange<=6,'shield/mandible must connect at actual body reach')
 check(d.motionStyle=='thrust','narrow weapon contact uses a thrust pose')
 check(not Geometry.contains(d.shape,0,12,0,d.range,d.width,d.radius,d.innerRadius,d.angle),'weapon cannot create a distant physical lane')
end
local goblin=Profiles.resolve('Goblin',Patterns.get('Goblin').attacks[2],'Hard',1)
check(goblin.pulses==2 and goblin.interval>=.4,'dagger follow-up is discrete and announced')
local orc=Profiles.resolve('Orc',Patterns.get('Orc').attacks[1],'Hard',1)
local ogre=Profiles.resolve('Ogre',Patterns.get('Ogre').attacks[1],'Hard',1)
check(orc.angle>ogre.angle and ogre.windup>orc.windup and ogre.recovery>orc.recovery,'cleave breadth versus hammer commitment')
local fire=Profiles.resolve('VolcanoShaman',Patterns.get('VolcanoShaman').attacks[2],'Hell',1)
check(fire.spellStyle=='burningGround'and fire.pulses==3,'fire denies one warned ground position over time')
local frost=Profiles.resolve('KingIceBear',Patterns.get('KingIceBear').attacks[4],'Hell',1)
check(frost.spellStyle=='expandingRing'and frost.pulses==3,'frost becomes a timed expanding wave')
local first=Profiles.pulseGeometry(frost,1)
local last=Profiles.pulseGeometry(frost,3)
check(first.radius<last.radius and last.radius==frost.radius,'frost wave reaches announced outside bound')
check(not Geometry.contains('ring',0,0,0,last.range,last.width,last.radius,last.innerRadius,last.angle),'ring keeps central safe space')
check(Geometry.contains('ring',last.radius-.5,0,0,last.range,last.width,last.radius,last.innerRadius,last.angle),'ring has a readable damage band')
local ice=Profiles.resolve('IceElf',Patterns.get('IceElf').attacks[1],'Hard',1)
local venom=Profiles.resolve('Webling',Patterns.get('Webling').attacks[1],'Hard',1)
check(ice.speed>venom.speed and ice.spellStyle~=venom.spellStyle,'ice lance and silk dart have different travel character')
local lich=Patterns.get('Lich').attacks[2]
local easy=Profiles.resolve('Lich',lich,'Easy',1)
local hell=Profiles.resolve('Lich',lich,'Hell',1)
local phase2=Profiles.resolve('Lich',lich,'Hell',.5)
check(easy.windup>hell.windup and easy.recovery>hell.recovery,'Easy adds teaching time and an opening')
check(easy.cooldown>hell.cooldown and phase2.cooldown<hell.cooldown,'difficulty and boss phase change cadence')
check(Profiles.get('Shaman').retreatRange>Profiles.get('Ogre').retreatRange,'caster makes space; bruiser holds contact')
check(Profiles.get('Goblin').strafe>Profiles.get('Ogre').strafe,'skirmisher flanks more than a bruiser')
check(Profiles.mode('Unknown').tier==1 and Profiles.get('Unknown')==nil,'unknown mode fails to safe teaching defaults')
local unknown={id='Unknown.1',range=3}
check(Profiles.resolve('Unknown',unknown,'Hard',1).range==3,'unsupported species keeps original definition')
print('enemy-combat-profiles: '..checks..' checks PASS; 50 species/23 bosses, weapon spacing, four modes, finite elemental pulses')
