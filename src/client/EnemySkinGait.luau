-- Keep the walk cycle on sparse replicated positions. Only observed travel
-- advances the feet. A short pause between packets should not restart Idle.
local Gait={}
function Gait.step(c,root,chasing,height,stride,dt,current)
 local delta=root.Position-c.position
 c.position=root.Position
 local distance=Vector3.new(delta.X,0,delta.Z).Magnitude
 if not chasing or distance>=math.max(3,height*1.5) then
  c.walkUntil=nil
  c.travelLeft=0
  c.side=0
  return false,distance
 end
 if distance>.001 then
  local localTravel=root.CFrame:VectorToObjectSpace(delta)
  c.walkUntil=current+.10
  c.travelLeft=(c.travelLeft or 0)+(localTravel.Z/distance>.35 and -distance or distance)
  c.sideTarget=math.clamp(localTravel.X/distance,-1,1)
 end
 local moving=c.walkUntil~=nil and current<=c.walkUntil
 local remaining=c.travelLeft or 0
 local step=moving and remaining*(1-math.exp(-dt*40)) or remaining
 c.travelLeft=remaining-step
 c.phase=(c.phase+step/stride)%1
 c.side=(c.side or 0)+((moving and c.sideTarget or 0)-(c.side or 0))*(1-math.exp(-dt*10))
 return moving,distance
end
return Gait
