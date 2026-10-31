-- Server-selected trial profiles, independent of replicated/client claims.
local F={}
local function attack(name,w,r,range,angle,blockable)return {name=name,windup=w,active=.18,recovery=r,range=range,angle=angle,blockable=blockable}end
F.profiles={
 IceWolf={speed=14,attacks={attack('Melee',.85,.95,5.5,70,true)}},
 IceTroll={speed=9,attacks={attack('Melee',1.15,1.2,7,95,true),attack('Unblockable',1.5,1.5,9,65,false)}},
 IceBear={speed=10,attacks={attack('Melee',1.1,1.25,7,100,true),attack('Unblockable',1.55,1.7,10,60,false)}},
 IceGolem={speed=7,attacks={attack('Melee',1.3,1.4,7,100,true),attack('Unblockable',1.7,1.8,10,70,false)}},
 IceElf={speed=9,attacks={attack('Melee',1.2,1.3,16,35,true)}},
 IceTrollKing={speed=8,attacks={attack('Melee',1.25,1.3,8,110,true),attack('Unblockable',1.65,1.7,12,65,false)}},
 KingIceBear={speed=9,attacks={attack('Melee',1.2,1.3,8,110,true),attack('Unblockable',1.65,1.7,12,65,false)}},
 KingIceGolem={speed=7,attacks={attack('Melee',1.4,1.5,9,110,true),attack('Unblockable',1.85,1.9,13,75,false)}},
 QueenIceElf={speed=9,attacks={attack('Melee',1.3,1.3,18,35,true),attack('Unblockable',1.7,1.8,11,360,false)}},
 AncientGlacierKing={speed=7,attacks={attack('Melee',1.45,1.6,9,110,true),attack('Unblockable',1.9,2,14,80,false)}},
}
return F
