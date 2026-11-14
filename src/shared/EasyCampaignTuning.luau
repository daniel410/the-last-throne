-- Rules 16 regional combat curve; pack and party relief apply only to Easy.
local T={rulesVersion=16}
local regions={
 {hp=1,damage=1,bossHP=1,bossDamage=1},
 {hp=1,damage=.85,bossHP=.8,bossDamage=.85},
 {hp=.85,damage=.85,bossHP=.72,bossDamage=.68},
 {hp=.8,damage=.75,bossHP=.55,bossDamage=.6},
 {hp=.6,damage=.55,bossHP=.48,bossDamage=.48},
}
local rangedHP={Webling=.85,Silkweaver=.85,Gloambat=.9}
local packs={DW={3,3,4,6,5,6,7},GW={6,6,6,7,7,8,8},FV={3,4,5,6,6,7,7},EC={5,5,6,6,7,7,8},HG={6,6,6,7,7,8,8}}
function T.enabled(mode,version)return mode=='Easy'and(version==nil or version>=T.rulesVersion)end
function T.current(version)return version==nil or version>=T.rulesVersion end
function T.factors(kind,boss,epic)
 local region=assert(regions[epic or 1],'Unsupported Easy region')
 return boss and region.bossHP or region.hp*(rangedHP[kind]or 1),boss and region.bossDamage or region.damage
end
function T.partyHealth(partySize)return ({1,1.35,1.65,2})[math.max(1,math.min(4,partySize or 1))]end
function T.packSize(chapter,legacy)
 local prefix=chapter.id:sub(1,2)
 local number=tonumber(chapter.id:match('%-(%d+)$'))
 local cap=number and packs[prefix]and packs[prefix][number]or 6
 return math.min(legacy,cap)
end
function T.finalGuards(partySize)return 3+math.max(0,math.min(3,(partySize or 1)-1))end
return T
