-- Numeric tactical decisions; all movement and damage remain server-owned.
local Profiles=game and require(script.Parent.EnemyCombatProfiles)or dofile('src/shared/EnemyCombatProfiles.luau')
local Mechanics=game and require(script.Parent.EnemyEncounterMechanics)or dofile('src/shared/EnemyEncounterMechanics.luau')
local T={}
function T.choose(profile,kind,distance,history,current,difficulty,health)
 if not profile then return nil end
 history=history or {}
 local best,bestScore
 local count=history.count or 0
 local phase=Profiles.phase(kind,health)
 local order=Mechanics.order(kind,phase,history.last,count)
 local role=Profiles.get(kind)
 for offset=0,#profile.attacks-1 do
  local attackIndex=order and order[offset+1]or ((count+offset)%#profile.attacks+1)
  local base=profile.attacks[attackIndex]
  local attack=Profiles.resolve(kind,base,difficulty,health)
  if distance>=attack.minRange and distance<=attack.maxRange and current>=((history.ready or {})[attack.id]or 0)then
   -- A boss follows its current phase's actual combo. Out-of-range/cooling steps
   -- fall back to a reachable move, preserving solo play and preventing stalls.
   local score=-offset*(order and 3 or .1)
   if attack.id==history.last then score=score-10 end
   if not order then
    if distance<(role.retreatRange or 0)and attack.shape~='projectile'then score=score+2 end
    if distance>8 and attack.shape=='projectile'then score=score+1 end
   end
   if not bestScore or score>bestScore then best,bestScore=attack,score end
  end
 end
 return best
end
-- Radial +1 approaches, -1 withdraws; tangent holds a distinct flank.
function T.movement(kind,distance,difficulty,seed,current)
 local p=Profiles.get(kind)
 local rank=({Easy=1,Hard=2,Insane=3,Hell=4})[difficulty]or 1
 local preferred=p.preferredRange or 4
 local retreat=p.retreatRange or 0
 local side=(seed or 0)%1<.5 and -1 or 1
 -- Keep a chosen flank for several seconds instead of jittering every frame.
 if math.floor(current/6+(seed or 0)*2)%2==1 then side=-side end
 local strafe=(p.strafe or 0)*(.55+rank*.15)
 if distance<retreat then return -1,side*strafe,'Retreat' end
 if distance>preferred+.25 then
  return 1,side*math.min(.5,(p.approachAngle or 0)/60),'Approach'
 end
 if distance<math.max(2,preferred-2)then return -.45,side*strafe,'Reposition' end
 return 0,side*strafe,strafe>0 and 'Flank'or 'Hold'
end
return T
