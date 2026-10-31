-- Server-selected trial profiles; no class-specific device key or client damage authority.
local E={}
local function a(name,w,r,range,angle,blockable)return {name=name,windup=w,active=.18,recovery=r,range=range,angle=angle,blockable=blockable}end
E.profiles={
 Imp={speed=13,attacks={a('Melee',.85,.9,5.5,75,true)}},
 LavaSlime={speed=8,attacks={a('Melee',1.05,1.2,6,100,true)}},
 Golem={speed=7,attacks={a('Melee',1.3,1.4,7,95,true),a('Unblockable',1.7,1.8,10,65,false)}},
 MagmaWorm={speed=8,attacks={a('Melee',1.3,1.4,8,90,true),a('Unblockable',1.75,1.8,11,60,false)}},
 VolcanoShaman={speed=9,attacks={a('Melee',1.25,1.3,16,35,true)}},
 MagmaImp={speed=12,attacks={a('Melee',1,1.2,7,85,true),a('Unblockable',1.5,1.6,10,60,false)}},
 MagmaGolem={speed=7,attacks={a('Melee',1.4,1.5,9,110,true),a('Unblockable',1.85,1.9,13,75,false)}},
 InfernoOverlord={speed=8,attacks={a('Melee',1.45,1.5,10,110,true),a('Unblockable',1.9,2,14,80,false)}},
 CalderaTitan={speed=7,attacks={a('Melee',1.5,1.6,10,110,true),a('Unblockable',2,2.1,15,80,false)}},
 KingVolcanoShaman={speed=9,attacks={a('Melee',1.35,1.4,18,35,true),a('Unblockable',1.8,1.9,12,360,false)}},
}
return E
