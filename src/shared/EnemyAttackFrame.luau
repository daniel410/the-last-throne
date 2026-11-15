-- One world-space frame drives each server pulse and its warning.
local Profiles=require(game:GetService('ReplicatedStorage').Shared.EnemyCombatProfiles)
local F={}
function F.resolve(attack,pulse)
 local d=attack.pattern or attack.d
 local g=Profiles.pulseGeometry(d,pulse)
 local base=attack.direction
 local center=attack.origin
 if g.shape=='projectile'then
  center=attack.castOrigin or attack.origin+Vector3.yAxis+base*1.2
  local towards=attack.aim+Vector3.yAxis-center
  if towards.Magnitude>.01 then base=towards.Unit end
 elseif g.centerMode=='aim'or g.centerMode=='target'or not g.centerMode and(g.shape=='circle'or g.shape=='trail')then
  center=attack.aim
 end
 local direction=CFrame.Angles(0,math.rad(g.yaw or 0),0):VectorToWorldSpace(base)
 local right=Vector3.new(-direction.Z,0,direction.X)
 if right.Magnitude>.001 then right=right.Unit end
 if not g.centerMode and d.shape=='trail'then center=attack.aim+right*((pulse-(d.pulses+1)/2)*d.radius*2.5)end
 center+=right*(g.offsetRight or 0)+direction*(g.offsetForward or 0)
 return g,center,direction
end
return F
