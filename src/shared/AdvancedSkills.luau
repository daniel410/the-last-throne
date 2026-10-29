-- Runtime trial balance for the latest eight branch designs. Names remain
-- provisional. Every selected path has 12 actives + one Level 80 ultimate.
local A={branches={},skills={knight={},dwarf={},elf={},mage={}},order={
 knight={"steel_knight","paladin"},dwarf={"iron_axe","gunner"},elf={"marksman","magic_archer"},mage={"pyro","cryo"}}}
local function s(name,root,level,form,damage,extra)
 local d={name=string.upper(name),root=root,level=level,form=form,damage=damage}
 for k,v in pairs(extra or {}) do d[k]=v end
 return d
end
local function branch(id,classId,name,icon,rows)
 A.branches[id]={id=id,classId=classId,name=name,icon=icon,skills=rows}
 local offset=#A.skills[classId]+3
 for i,d in ipairs(rows) do
  d.index=offset+i;d.branch=id;d.id=classId.."."..id.."."..string.lower(d.name):gsub("[^%w]+","_")
  d.advanced=true;d.stage=d.level>=80 and 4 or d.level>=60 and 3 or d.level>=40 and 2 or 1
  d.ultimate=d.level==80;d.icon=d.icon or icon;d.element=d.element or (classId=="mage" and (id=="pyro" and "fire" or "frost") or id=="magic_archer" and "nature" or id=="gunner" and "gun" or id=="paladin" and "holy" or "steel")
  d.pulses=d.pulses or 1;d.interval=d.interval or .3
  d.windup=d.windup or (d.ultimate and .9 or d.form=="ground" and .65 or .3)
  d.active=.12+(d.pulses-1)*d.interval;d.recovery=.35
  d.cooldown=d.cooldown or (d.ultimate and 60 or d.form=="ground" and 12 or d.shield and 14 or 7)
  d.range=d.range or (d.form=="melee" and 5 or d.form=="cone" and 9 or d.form=="area" and 8 or 45)
  d.radius=d.radius or (d.ultimate and 18 or d.stage>=3 and 12 or 6)
  d.angle=d.angle or (d.form=="area" and 360 or d.form=="line" and 12 or d.form=="cone" and 110 or 65)
  d.maxTargets=d.maxTargets or (d.form=="projectile" and 1 or 8);d.maxHeight=12;d.posture=d.posture or 15
  d.magic=classId=="mage" or id=="magic_archer"
  if d.magic then d.manaCost=d.manaCost or (d.ultimate and 80 or 16+d.stage*4) end
  d.effect="advanced";d.ranged=d.form=="projectile" or d.form=="line" or d.form=="ground" or d.form=="chain"
  d.glyph=(id==A.order[classId][1] and "A" or "B")..string.format("%02d",i)
  table.insert(A.skills[classId],d)
 end
end
branch("steel_knight","knight","Steel Knight","shieldbearer",{
 s("Counter Slash",1,20,"melee",1.35,{counterPosture=18}),
 s("Steel Sweep",2,26,"cone",1.1,{push=2}),
 s("Challenging Strike",3,33,"melee",1.25,{taunt=3,weakenPosture=15}),
 s("Twin Cyclone",2,40,"area",.8,{pulses=2,interval=.35}),
 s("Shield Breaker",1,46,"melee",1.45,{posture=60,maxTargets=1}),
 s("Guardian Counter",1,49,"melee",1.1,{shield=.12,partyShield=true}),
 s("Rallying Slash",3,53,"cone",1.35,{taunt=3,weakenBonus=.2}),
 s("Breaker Charge",1,60,"cone",1.0,{move=6,pulses=2,posture=28}),
 s("Vanguard Strike",3,63,"line",1.65,{move=3,range=10,weakenPosture=25}),
 s("Blade Storm",2,66,"area",.65,{pulses=4,interval=.3,pulseMove=1.5}),
 s("Sweeping Break",2,69,"area",1.4,{slow=.55,slowDuration=3}),
 s("Warcry Assault",3,73,"cone",.7,{pulses=3,taunt=3,move=3,weakenBonus=.2}),
 s("Unyielding Front",0,80,"area",1.8,{move=6,pulses=2,shield=.25,partyShield=true,posture=40}),
})
branch("paladin","knight","Paladin","paladin",{
 s("Oathblade",1,20,"melee",1.35,{mark="oath",pulses=2}),
 s("Radiant Sweep",2,26,"cone",1.25,{mark="oath"}),
 s("Oath Challenge",3,33,"cone",1.35,{taunt=3,consume="oath",markBonus=.3}),
 s("Dawn Burst",2,40,"area",1.4,{consume="oath",markBonus=.3,shield=.12,partyShield=true}),
 s("Oathbreaker Strike",1,46,"melee",1.4,{consume="oath",markPosture=30,posture=30,maxTargets=1}),
 s("Shield Verdict",1,49,"melee",1.9,{consume="oath",markBonus=.4,maxTargets=1}),
 s("Guardian Slash",3,53,"cone",1.4,{taunt=3,shield=.15,partyShield=true}),
 s("Radiant Charge",1,60,"cone",1,{move=6,pulses=2,mark="oath"}),
 s("Valiant Advance",3,63,"cone",1.5,{move=3,shield=.15,partyShield=true}),
 s("Dawn Spiral",2,66,"area",.65,{pulses=3,pulseMove=1.5,consume="oath",markBonus=.3}),
 s("Sunward Cross",2,69,"cone",.9,{pulses=2,consume="oath",markBonus=.3}),
 s("Oathbound Assault",3,73,"cone",.75,{pulses=3,taunt=3,consume="oath",markBonus=.3}),
 s("Oath of Dawn",0,80,"area",1.8,{pulses=2,consume="oath",markBonus=.5,shield=.25,partyShield=true}),
})
branch("iron_axe","dwarf","Iron Axe","axe",{
 s("Armor Splitter",1,20,"melee",1.5,{mark="fracture",posture=35}),
 s("Returning Echo",2,26,"line",.9,{pulses=2,returning=true}),
 s("Mountain Sweep",3,33,"area",1.3,{push=2}),
 s("Crag Cleave",1,36,"cone",1.5),
 s("Breaker Throw",2,40,"line",1.7,{consume="fracture",markPosture=30}),
 s("Stonebound Leap",3,46,"area",1.6,{move=6}),
 s("Iron Shoulder",1,49,"cone",1.35,{move=3,shield=.15}),
 s("Crosscut Axe",2,53,"line",1,{pulses=2,returning=true,crosscut=true}),
 s("Mountain Strike",3,60,"cone",2.1,{range=12,posture=45}),
 s("Shatter Blow",1,63,"ground",1.7,{range=6,radius=4,consume="fracture",markBonus=.4}),
 s("Twin Axe Path",2,69,"projectile",1.25,{pulses=2,interval=.2}),
 s("Tremor Guard",3,73,"area",1.5,{shield=.2}),
 s("Mountain Collapse",0,80,"cone",2,{pulses=2,range=18,angle=120,posture=45}),
})
branch("gunner","dwarf","Gunner","gunner",{
 s("Gunner Shot",1,20,"projectile",1.6,{icon="gunner"}),
 s("Bomb Toss",2,26,"ground",1.8,{icon="grenadier",element="bomb"}),
 s("Shell Burst",3,33,"ground",1.4,{windup=.35,radius=4,icon="mortar",element="shell"}),
 s("Quickfire",1,36,"projectile",.65,{pulses=3,interval=.15,icon="gunner"}),
 s("Shrapnel Toss",2,40,"ground",.8,{pulses=3,scatter=true,radius=4,icon="grenadier",element="bomb"}),
 s("Blast Step",3,46,"cone",1.4,{move=-4,range=12,icon="mortar",element="shell"}),
 s("Scatter Shot",1,49,"cone",1.75,{range=15,angle=100,icon="gunner"}),
 s("Skipping Charge",2,53,"ground",1.1,{pulses=2,scatter=true,icon="grenadier",element="bomb"}),
 s("Field Mortar",3,60,"ground",1,{pulses=4,interval=.6,windup=1,icon="mortar",element="shell"}),
 s("Piercing Round",1,63,"line",1.9,{icon="gunner"}),
 s("Rolling Charge",2,69,"line",1.8,{radius=6,detonate=true,icon="grenadier",element="bomb"}),
 s("Siege Pattern",3,73,"ground",1.35,{pulses=2,scatter=true,interval=.6,icon="mortar",element="shell"}),
 s("Siege Barrage",0,80,"ground",1.3,{pulses=4,interval=.5,icon="mortar",element="shell"}),
})
branch("marksman","elf","Marksman","sharpshooter",{
 s("Weakpoint Shot",1,20,"projectile",1.65,{mark="weakpoint"}),
 s("Moving Volley",2,26,"projectile",.65,{pulses=3,pulseMove=1,icon="rapid"}),
 s("Piercing Line",3,33,"line",1.6),
 s("Heavy Draw",1,36,"projectile",2.3,{windup=.8}),
 s("Precision Volley",2,40,"projectile",.75,{pulses=3,consume="weakpoint",markBonus=.3,icon="rapid"}),
 s("Fan Break",3,46,"cone",1.4,{range=18,push=3}),
 s("Hunter's Focus",1,49,"projectile",1.45,{shield=.15}),
 s("Retreating Fire",2,53,"projectile",1.6,{move=-4}),
 s("Piercing Volley",3,60,"cone",1.9,{range=45,angle=65}),
 s("Mark Breaker",1,63,"projectile",2,{consume="weakpoint",markBonus=.5}),
 s("Crossfire",2,69,"line",1.1,{pulses=2,crosscut=true}),
 s("Arrow Rain",3,73,"ground",.8,{pulses=4,interval=.4}),
 s("Grand Volley",0,80,"cone",1.5,{pulses=3,range=50,angle=90}),
})
branch("magic_archer","elf","Magic Archer","warden",{
 s("Elemental Arrow",1,20,"projectile",1.5,{mark="nature"}),
 s("Spark Volley",2,26,"projectile",.7,{pulses=3,element="lightning",icon="storm"}),
 s("Vine Trap",3,33,"ground",.6,{pulses=3,interval=.6,slow=.5,slowDuration=3}),
 s("Bloom Shot",1,36,"projectile",1.8,{consume="nature",markBonus=.35}),
 s("Storm Arrow",2,40,"ground",1.8,{consume="nature",markBonus=.3,element="lightning",icon="storm"}),
 s("Rooting Fan",3,46,"cone",1.45,{range=22,slow=.2,slowDuration=1.5}),
 s("Warden Arrow",1,49,"projectile",1.5,{shield=.15}),
 s("Gliding Shot",2,53,"projectile",1.65,{move=5}),
 s("Spirit Rain",3,60,"ground",.8,{pulses=4,interval=.4}),
 s("Elemental Pierce",1,63,"line",1.8,{consume="nature",markBonus=.4}),
 s("Echo Arrows",2,69,"projectile",1,{pulses=3,interval=.45}),
 s("Vine Burst",3,73,"ground",2,{consume="nature",markBonus=.4}),
 s("Spirit Arrowfall",0,80,"ground",1.4,{pulses=3,consume="nature",markBonus=.4}),
})
branch("pyro","mage","Pyro","pyromancer",{
 s("Ember Lance",1,20,"projectile",1.6,{mark="ember"}),
 s("Steam Burst",2,26,"ground",1.5,{wetBonus=.2,element="water"}),
 s("Cinder Ring",3,33,"area",.6,{pulses=3,interval=.5}),
 s("Flame Dart",1,36,"projectile",1.55,{windup=.15,consume="ember",markBonus=.3}),
 s("Earth Rise",2,40,"ground",1.65,{slow=.2,slowDuration=1.5,consume="ember",markBonus=.25,element="earth",icon="geomancer"}),
 s("Ember Step",3,46,"area",1.3,{move=5,originArea=true}),
 s("Stone Lance",1,49,"projectile",1.8,{posture=40,element="earth",icon="geomancer"}),
 s("Searing Ward",2,53,"area",1.3,{shield=.18}),
 s("Lava Eruption",3,60,"ground",2.5,{radius=14,windup=.9,element="earth",icon="geomancer"}),
 s("Magma Spear",1,63,"projectile",2,{consume="ember",markBonus=.4}),
 s("Molten Line",2,69,"line",.9,{pulses=3,interval=.45}),
 s("Ashfall",3,73,"ground",.85,{pulses=4,interval=.5}),
 s("Caldera's Judgment",0,80,"ground",1.5,{pulses=3,radius=20,element="earth",icon="geomancer"}),
})
branch("cryo","mage","Cryo","cryomancer",{
 s("Frost Lance",1,20,"projectile",1.6,{mark="frost"}),
 s("Ice Shard",2,26,"projectile",1.5,{slow=.55,slowDuration=3}),
 s("Frost Ring",3,33,"area",1.3,{slow=.5,slowDuration=3}),
 s("Shatter Dart",1,36,"projectile",1.7,{consume="frost",markBonus=.3}),
 s("Chain Lightning",2,40,"chain",1.2,{maxTargets=4,chainRange=10,element="lightning",wetBonus=.2,icon="voltmancer"}),
 s("Frost Step",3,46,"area",1.3,{move=5,originArea=true,slow=.5,slowDuration=2}),
 s("Thunder Spear",1,49,"projectile",2,{element="lightning",wetBonus=.2,icon="voltmancer"}),
 s("Ice Ward",2,53,"area",1.3,{shield=.18,slow=.6,slowDuration=2}),
 s("Froststorm",3,60,"ground",2.3,{radius=14,slow=.5,slowDuration=3}),
 s("Glacial Spike",1,63,"projectile",2,{consume="frost",markBonus=.4}),
 s("Lightning Line",2,69,"line",1.8,{element="lightning",icon="voltmancer"}),
 s("Hailfall",3,73,"ground",.85,{pulses=4,interval=.5,slow=.6,slowDuration=2}),
 s("Eternal Tempest",0,80,"ground",1.5,{pulses=3,radius=20,slow=.4,slowDuration=3}),
})
function A.get(classId,index) return A.skills[classId] and A.skills[classId][index-3] end
function A.slotCount(g) return g.stage>=2 and 5 or g.stage>=1 and 4 or 3 end
function A.unlocked(g,classId,index)
 if type(index)~="number" or index%1~=0 or index<1 or index>29 then return false end
 if index<=3 then return true end
 local d=A.get(classId,index)
 return d~=nil and d.branch==g.branch and g.stage>=d.stage and g.level>=d.level
end
return A
