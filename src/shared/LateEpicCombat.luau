-- Trial profiles. Presentation models can be replaced without changing these stable kinds.
local C={profiles={}}
local function attack(w,range,angle,blockable)return {name=blockable and 'Melee' or 'Unblockable',windup=w,active=.18,recovery=w,range=range,angle=angle,blockable=blockable}end
local specs={Webling={13,.9,6},Silkweaver={10,1.2,14},Barkstalker={9,1.2,8},Gloambat={14,.9,7},VenomcoilCentipede={10,1.2,9},AncientHollowbark={7,1.65,12},HollowbarkSovereign={7,1.65,12},VenomcoilKing={9,1.6,12},WidowQueen={9,1.65,13},Zombie={8,1.1,6},Skeleton={11,1,7},Ghoul={12,1.1,8},Mummy={8,1.3,8},Hellhound={14,1.05,8},SkeletonKnight={10,1.3,9},DeathKnight={9,1.5,10},Lich={9,1.5,18},LichSovereign={8,1.7,20},DreadCommander={9,1.7,12},Veyr={9,1.8,14}}
local bosses={AncientHollowbark=true,HollowbarkSovereign=true,VenomcoilKing=true,WidowQueen=true,Lich=true,LichSovereign=true,DreadCommander=true,Veyr=true}
for kind,v in pairs(specs)do
 local attacks={attack(v[2],v[3],kind:find('Lich') and 40 or 100,true)}
 if bosses[kind]then table.insert(attacks,attack(v[2]+.4,v[3]+3,80,false))end
 C.profiles[kind]={speed=v[1],attacks=attacks}
end
return C
