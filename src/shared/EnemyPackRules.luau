-- Finite cooperation and counterplay; these rules never award or spawn units.
local R={version=1}
local wards={Shaman=true,KingShaman=true,VolcanoShaman=true,KingVolcanoShaman=true,
 Silkweaver=true,WidowQueen=true,Mummy=true,Lich=true,LichSovereign=true,QueenIceElf=true}
local commanders={Warlord=true,EnragedWarlord=true,DreadCommander=true,InfernoOverlord=true,Veyr=true}
function R.support(kind)
 if wards[kind]then return {kind='Ward',windup=1.8,recovery=1.1,cooldown=12,range=18,duration=5,maxTargets=1,wardFraction=.18}end
 if commanders[kind]then return {kind='Rally',windup=1.6,recovery=1.2,cooldown=14,range=18,duration=5,maxTargets=3}end
end
function R.pressureLimit(difficulty)return (difficulty=='Hard'or difficulty=='Insane'or difficulty=='Hell')and 2 or 1 end
function R.weaknessMultiplier(side,dot)
 if side=='any'or side=='rear'and dot<=-.35 or side=='flank'and math.abs(dot)<=.55 then return 1.25 end
 return 1
end
return R
