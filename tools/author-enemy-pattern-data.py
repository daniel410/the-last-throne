from pathlib import Path
import json
# Stable runtime kinds and authored actions. Forms are actual server geometry.
normal={
'Slime':('physical','hop','Slime Hop','circle','Gel Splash','cone'),
'Goblin':('physical','sweep','Sidestep Jab','line','Blade Flurry','cone'),
'Orc':('physical','sweep','Heavy Cleave','cone','Overhead Cut','line'),
'Shaman':('arcane','cast','Hex Bolt','projectile','Hex Circle','circle'),
'Ogre':('physical','slam','Club Smash','cone','Ground Break','line'),
'IceWolf':('frost','hop','Frost Bite','cone','Frost Rend','cone'),
'IceTroll':('frost','slam','Frozen Club','cone','Ice Boulder','projectile'),
'IceBear':('frost','sweep','Raking Claws','cone','Heavy Maul','cone'),
'IceGolem':('frost','slam','Frozen Fist','cone','Frost Fissure','line'),
'IceElf':('frost','cast','Crystal Bolt','projectile','Crystal Volley','projectile'),
'Imp':('fire','cast','Ember Toss','projectile','Spark Fan','projectile'),
'LavaSlime':('fire','hop','Magma Hop','circle','Lava Trail','trail'),
'Golem':('physical','slam','Stone Fist','cone','Stone Quake','ring'),
'MagmaWorm':('fire','hop','Molten Bite','cone','Burrow Rush','dash'),
'VolcanoShaman':('fire','cast','Cinder Bolt','projectile','Heat Vent','circle'),
'Webling':('web','cast','Web Dart','projectile','Web Pounce','circle'),
'Silkweaver':('web','cast','Silk Bolt','projectile','Silk Line','line'),
'Barkstalker':('physical','slam','Branch Sweep','cone','Root Ambush','line'),
'Gloambat':('shadow','hop','Wing Slash','cone','Swoop','dash'),
'VenomcoilCentipede':('venom','sweep','Venom Pierce','line','Venom Sweep','cone'),
'Zombie':('physical','slam','Grasping Reach','cone','Lurch','dash'),
'Skeleton':('physical','sweep','Bone Cut','cone','Bone Throw','projectile'),
'Ghoul':('physical','sweep','Rending Claws','cone','Rending Rush','dash'),
'Mummy':('soul','cast','Dust Bolt','projectile','Dust Ring','ring'),
'Hellhound':('fire','hop','Cinder Bite','cone','Cinder Charge','dash'),
'SkeletonKnight':('physical','sweep','Guard Riposte','cone','Shield Line','line'),
'DeathKnight':('shadow','sweep','Dread Cut','line','Delayed Cleave','cone'),
}
boss={
'Warlord':('physical','Command Cleave','cone','Banner Charge','dash','Execution Slam','line'),
'GoblinKing':('physical','Royal Knives','projectile','Trick Dash','dash','Crown Bombs','trail'),
'KingOgre':('physical','Double Hammer','cone','Stone Roll','projectile','Quarry Quake','ring'),
'EnragedWarlord':('physical','Rage Combo','cone','Cross Rush','dash','Overheat','circle'),
'KingShaman':('arcane','Hex Fan','projectile','Totem Pulse','trail','Spirit Surge','ring'),
'IceTrollKing':('frost','Frozen Club','cone','Boulder Barrage','projectile','Avalanche Line','line'),
'KingIceBear':('frost','Royal Maul','cone','Glacier Rush','dash','Winter Roar','ring'),
'KingIceGolem':('frost','Crystal Fissures','line','Ice Bastion','trail','Core Quake','ring'),
'QueenIceElf':('frost','Prism Volley','projectile','Winter Lanes','line','Crystal Fall','trail'),
'AncientGlacierKing':('frost','Frozen Crown','projectile','Glacier March','trail','Whiteout Wave','line'),
'MagmaImp':('fire','Spark Scatter','projectile','Flare Dash','dash','Ember Chain','trail'),
'MagmaGolem':('fire','Molten Fist','cone','Lava Channels','line','Core Vent','cone'),
'InfernoOverlord':('fire','Furnace Cleave','cone','Flame Lanes','trail','Furnace Eruption','ring'),
'CalderaTitan':('fire','Titan Steps','trail','Magma Rain','circle','Caldera Rupture','line'),
'KingVolcanoShaman':('fire','Cinder Fan','projectile','Vent Sequence','trail','Volcanic Convergence','ring'),
'AncientHollowbark':('physical','Root Lanes','line','Branch Sweep','cone','Forest Ring','ring'),
'VenomcoilKing':('venom','Royal Pierce','dash','Coil Sweep','cone','Venom Trail','trail'),
'WidowQueen':('venom','Silk Fan','projectile','Web Lanes','line','Brood Burst','trail'),
'Lich':('soul','Soul Bolts','projectile','Grave Runes','trail','Soul Arc','line'),
'LichSovereign':('soul','Orbiting Seals','projectile','Royal Runes','trail','Soul Collapse','ring'),
'DreadCommander':('shadow','Command Blade','cone','Dread March','line','Banner Break','cone'),
'Veyr':('shadow','Throne Cleave','line','Heart Pulse','ring','Final Gate','projectile'),
}
def action(kind,name,form,element,boss=False,index=0,motion=None):
 shape='line' if form=='dash' else form
 heavy=boss and index==3 or not boss and index==1 and form in ('line','circle','ring','trail','dash')
 p=dict(id=kind+'.'+str(index+1),name=name,shape=shape,element=element,motion=motion or ('dash' if form=='dash' else 'cast' if form in ('projectile','trail') else 'slam' if form in ('circle','ring') else 'sweep'),windup=1.55 if heavy else 1.15 if boss else 1.0,recovery=1.25 if heavy else .85 if boss else .8,range=24 if form in ('projectile','line','dash','trail') else 9 if boss else 6,radius=8 if boss else 4,width=3 if boss else 2,angle=105 if boss else 85,blockable=not heavy,heavy=bool(heavy),pulses=3 if form=='trail' or boss and form in ('cone','projectile') and index>0 else 1,interval=.55,minRange=0,maxRange=32 if form in ('projectile','trail','line','dash') else 10 if boss else 7,cooldown=7 if heavy else 3.5,speed=19 if boss else 16,fan=3 if 'Fan' in name or 'Volley' in name or 'Crown' in name or name=='Final Gate' else 1,spread=40,innerRadius=3 if boss else 2,dashDistance=12 if boss else 8)
 if kind in ('Goblin','Orc','Ogre','IceWolf','IceBear'):
  p['range']=6;p['maxRange']=5.4;p['dashDistance']=0
  if kind in ('IceWolf','IceBear')and index==1:
   p.update(motion='hop' if kind=='IceWolf' else 'slam',heavy=True,blockable=False,windup=1.55,recovery=1.25,cooldown=7)
 if kind in ('Golem','SkeletonKnight')and index==0:p['guard']=True
 if form=='trail':p['radius']=3.5;p['interval']=.65
 if form=='projectile':p['range']=32;p['maxRange']=28
 if form in ('line','cone','dash'):p['maxRange']=min(p['maxRange'],p['dashDistance']*.9 if form=='dash' else p['range']*.9)
 return p
profiles={}
for kind,(el,motion,n1,f1,n2,f2) in normal.items():
 profiles[kind]={'boss':False,'element':el,'attacks':[action(kind,n1,f1,el,index=0,motion=motion),action(kind,n2,f2,el,index=1)]}
for kind,(el,n1,f1,n2,f2,n3,f3) in boss.items():
 basic=action(kind,'Royal Strike' if el=='physical' else 'Arcane Pulse','cone' if el=='physical' else 'projectile',el,True,0)
 profiles[kind]={'boss':True,'element':el,'attacks':[basic,action(kind,n1,f1,el,True,1),action(kind,n2,f2,el,True,2),action(kind,n3,f3,el,True,3)]}
# Queen and final boss receive clean volley gaps. A fan is capped to one hit per pulse/target.
for p in profiles.values():
 for a in p['attacks']:
  a['active']=max(.22,(a['pulses']-1)*a['interval']+(a['range']/a['speed'] if a['shape']=='projectile' else .45 if a['motion']=='dash' else .22))
def lua(v):
 if isinstance(v,bool):return str(v).lower()
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,(float,int)):return str(v)
 if isinstance(v,list):return '{'+','.join(map(lua,v))+'}'
 return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
out='-- Versioned server-owned enemy actions; stable kinds, no reward or stat changes.\nlocal P={version=2,minimumRulesVersion=9,profiles={\n'+''.join(' ['+lua(k)+']='+lua(v)+',\n'for k,v in profiles.items())+'}}\n'
out+='''function P.enabled(version)return type(version)=='number' and version>=P.minimumRulesVersion end
function P.get(kind)return P.profiles[kind]end
function P.choose(kind,distance,history,current)
 local profile=P.profiles[kind];if not profile then return nil end
 history=history or {};local count=history.count or 0;local attacks=profile.attacks
 -- Teach the authored order first, then rotate valid skills without immediate repeats.
 for offset=0,#attacks-1 do
  local index=(count+offset)%#attacks+1;local a=attacks[index]
  if distance>=a.minRange and distance<=a.maxRange and (not history.ready or current>=(history.ready[a.id]or 0)) and (a.id~=history.last or #attacks==1)then return a end
 end
 return nil
end
function P.commit(history,attack,current)
 history.count=(history.count or 0)+1;history.last=attack.id;history.ready=history.ready or {};history.ready[attack.id]=current+attack.windup+attack.active+attack.recovery+attack.cooldown
end
return P
'''
Path('src/shared/EnemyPatterns.luau').write_text(out)
Path('assets/animations/enemy-patterns-v1/pattern-manifest.json').write_text(json.dumps({'version':2,'profiles':profiles},indent=2)+'\n')
