-- Server-only finite attacks. No tasks, client hit claims, or live projectiles survive cancellation.
local Geometry=require(game:GetService('ReplicatedStorage').Shared.EnemyAttackGeometry)
local R={}
local function flat(v)return Vector3.new(v.X,0,v.Z)end
function R.center(attack,pulse)
 local d=attack.pattern
 if d.shape=='circle'then return attack.aim end
 if d.shape=='trail'then
  local right=Vector3.new(-attack.direction.Z,0,attack.direction.X)
  return attack.aim+right*((pulse-(d.pulses+1)/2)*d.radius*2.5)
 end
 return attack.origin
end
function R.cancel(enemy,emit)
 local a=enemy.attack
 if a and a.pattern then emit({kind='cancel',model=enemy.model,sequence=enemy.attackSeq});enemy.model:SetAttribute('K0PatternId',nil)end
end
function R.begin(enemy,target,pattern,current,emit)
 local direction=flat(target.root.Position-enemy.root.Position)
 direction=direction.Magnitude>.01 and direction.Unit or enemy.root.CFrame.LookVector
 local a={pattern=pattern,definition=table.clone(pattern),started=current,origin=enemy.root.Position,direction=direction,
  aim=target.root.Position,hits={},projectiles={},fired=0,extraRecovery=0,locked=true,lastStep=current}
 a.definition.damage=enemy.config.attacks[1].damage
 enemy.attack=a;enemy.attackSeq+=1
 enemy.model:SetAttribute('K0AttackSeq',enemy.attackSeq)
 enemy.model:SetAttribute('K0PatternId',pattern.id)
 enemy.model:SetAttribute('K0PatternMotion',pattern.motion)
 enemy.model:SetAttribute('K0PatternElement',pattern.element)
 enemy.model:SetAttribute('K0PatternOrigin',a.origin);enemy.model:SetAttribute('K0PatternDirection',direction);enemy.model:SetAttribute('K0PatternAim',a.aim)
 enemy.model:SetAttribute('K0Telegraph','Pattern')
 enemy.model:SetAttribute('K0EnemyAttackClock',string.format('%d|%.6f|%.6f|%.6f|%.6f|%d',enemy.attackSeq,workspace:GetServerTimeNow(),pattern.windup,pattern.active,pattern.recovery,pattern.heavy and 1 or 0))
 enemy.root.CFrame=CFrame.lookAt(enemy.root.Position,enemy.root.Position+direction)
 emit({kind='begin',model=enemy.model,sequence=enemy.attackSeq,id=pattern.id,origin=a.origin,direction=direction,aim=a.aim,at=workspace:GetServerTimeNow()})
 return a
end
function R.step(enemy,current,targets,ctx)
 local a=enemy.attack;local d=a.pattern;local elapsed=current-a.started
 local function hit(target,pulse,origin,impact)
  if not ctx.valid(enemy,target) then return end
  a.pulseHits=a.pulseHits or {};a.pulseHits[pulse]=a.pulseHits[pulse] or {}
  if a.pulseHits[pulse][target.character] then return end
  local wall=ctx.raycast(origin,impact,enemy,target)
  if wall then return end
  a.pulseHits[pulse][target.character]=true
  local definition=table.clone(a.definition);definition.damage=math.max(1,math.floor(a.definition.damage/d.pulses+.5))
  local sample={definition=definition,direction=a.direction,origin=origin,hits={},geometryChecked=true,pattern=d,
   impact=impact,pulse=pulse,sequence=enemy.attackSeq,extraRecovery=0}
  ctx.hit(enemy,target,sample,current)
  a.extraRecovery=math.max(a.extraRecovery or 0,sample.extraRecovery or 0)
 end
 -- Delayed frames may advance an existing projectile but never replay an old contact pulse.
 while a.fired<d.pulses and elapsed>=d.windup+a.fired*d.interval do
  local pulse=a.fired+1;a.fired=pulse
  local due=d.windup+(pulse-1)*d.interval
  if elapsed-due<=.22 then
   a.sampledActive=true
   local center=R.center(a,pulse)
   if d.shape=='projectile'then
    for i=1,d.fan do
     local yaw=math.rad(d.fan==1 and 0 or (i-(d.fan+1)/2)*d.spread/(d.fan-1))
     local dir=CFrame.Angles(0,yaw,0):VectorToWorldSpace(a.direction)
     local socket=enemy.model:FindFirstChild('EnemyCastSocket',true)
     local origin=socket and socket.WorldPosition or a.origin+Vector3.new(0,1,0)+dir*1.2
     local towards=a.aim+Vector3.new(0,1,0)-origin
     if towards.Magnitude>.01 then dir=CFrame.Angles(0,yaw,0):VectorToWorldSpace(towards.Unit)end
     table.insert(a.projectiles,{position=origin,direction=dir,distance=0,pulse=pulse,shot=i,at=current})
     ctx.emit({kind='projectile',model=enemy.model,sequence=enemy.attackSeq,id=d.id,origin=origin,direction=dir,at=workspace:GetServerTimeNow(),pulse=pulse,shot=i})
    end
   elseif d.motion~='dash'then
    ctx.emit({kind='pulse',model=enemy.model,sequence=enemy.attackSeq,id=d.id,position=center,at=workspace:GetServerTimeNow(),pulse=pulse})
    local right=Vector3.new(-a.direction.Z,0,a.direction.X)
    for _,target in ipairs(targets)do
     local delta=target.root.Position-center
     if Geometry.contains(d.shape,delta:Dot(right),delta:Dot(a.direction),delta.Y,d.range,d.width,d.radius,d.innerRadius,d.angle)then hit(target,pulse,center,target.root.Position)end
    end
   end
  end
 end
 if d.motion=='dash' and elapsed>=d.windup and elapsed<=d.windup+.45 then
  local desired=a.origin+a.direction*d.dashDistance*math.clamp((elapsed-d.windup)/.45,0,1)
  local from=enemy.root.Position
  local wall=ctx.raycast(from,desired,enemy)
  if wall then desired=wall.Position-a.direction*2 end
  local floor=ctx.floor(desired,enemy)
  if floor and math.abs(floor.Position.Y-(a.origin.Y-enemy.root.Size.Y*1.5))<5 and (flat(desired-enemy.spawnPosition)).Magnitude<enemy.config.leashRange then
   local to=Vector3.new(desired.X,from.Y,desired.Z)
   enemy.root.CFrame=CFrame.lookAt(to,to+a.direction)
   for _,target in ipairs(targets)do
    local p=target.root.Position
    if Geometry.segmentDistance(p.X,p.Y,p.Z,from.X,from.Y,from.Z,to.X,to.Y,to.Z)<=d.width+1 then hit(target,1,from,p)end
   end
  end
 end
 for i=#a.projectiles,1,-1 do
  local p=a.projectiles[i];local step=math.min(d.range-p.distance,d.speed*math.max(0,current-p.at));p.at=current
  local last=p.position+p.direction*step;local wall=ctx.raycast(p.position,last,enemy)
  if wall then last=wall.Position end
  local closest,closestT=nil,math.huge
  for _,target in ipairs(targets)do if ctx.valid(enemy,target)then
   local v=target.root.Position
   local distance,t=Geometry.segmentDistance(v.X,v.Y+1,v.Z,p.position.X,p.position.Y,p.position.Z,last.X,last.Y,last.Z)
   if distance<=1.4 and t<closestT then closest,closestT=target,t end
  end end
  local remove=wall~=nil
  if closest then hit(closest,p.pulse,p.position,closest.root.Position);remove=true end
  p.distance+=step;p.position=last
  if p.distance>=d.range then remove=true end
  if remove then
   ctx.emit({kind='projectileEnd',model=enemy.model,sequence=enemy.attackSeq,id=d.id,pulse=p.pulse,shot=p.shot,position=closest and closest.root.Position+Vector3.yAxis or last})
   table.remove(a.projectiles,i)
  end
 end
 a.lastStep=current
end
return R
