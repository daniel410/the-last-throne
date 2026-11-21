-- Bounded geometry for branch skills. The server owns targets, centers, pulses,
-- movement and per-pulse hit sets; client visuals do not resolve damage.
local AdvancedCombat={}
local function flat(v) return Vector3.new(v.X,0,v.Z) end
local function alive(e) return e.model.Parent~=nil and e.humanoid.Health>0 and e.root.Parent~=nil end
local function inLine(d,direction,delta)
 local horizontal=flat(delta)
 local along=horizontal:Dot(direction)
 return along>=0 and along<=d.range
  and (horizontal-direction*along).Magnitude<=(d.crosscut and 2 or 1.5)
  and math.abs(delta.Y)<=d.maxHeight
end
local function nearer(center,a,b)
 local da,db=(a.root.Position-center).Magnitude,(b.root.Position-center).Magnitude
 return da<db or da==db and a.id<b.id
end
function AdvancedCombat.snapshot(state,skill,direction,target,enemies,clear)
 local origin=state.root.Position
 local center=origin+direction*skill.range
 local selected=target and enemies[target]
 if selected and alive(selected) and (selected.root.Position-origin).Magnitude<=skill.range and math.abs(selected.root.Position.Y-origin.Y)<=skill.maxHeight and clear(origin,selected.root.Position,state.character,selected.model) then center=selected.root.Position
 else selected=nil end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={state.character,workspace:FindFirstChild("DeepwoodK0") and workspace.DeepwoodK0:FindFirstChild("Enemies") or state.character};params.RespectCanCollide=true
 if skill.form=="line" then center=origin+direction*skill.range end
 local wall=workspace:Raycast(origin,center-origin,params)
 if wall then center=wall.Position-direction*.2 end
 local visualCenter
 if skill.detonate and skill.form=="line" then
  -- Preview the charge's destination. Impact still resolves live targets.
  local best
  for _,e in pairs(enemies) do
   if alive(e) and inLine(skill,direction,e.root.Position-origin)
    and (not best or nearer(center,e,best))
    and clear(origin,e.root.Position,state.character,e.model) then best=e end
  end
  visualCenter=best and best.root.Position
 end
 return {origin=origin,center=center,target=selected and selected.model,direction=direction,visualCenter=visualCenter}
end
function AdvancedCombat.resolve(state,attack,current,services,pulse)
 local d=attack.definition
 if d.form=="self" then services.visual(state,d,state.root.Position,state.root.Position,pulse,{});return end
 if d.pulseMove then services.move(state,attack.direction,d.pulseMove) end
 local cast=attack.advancedCast
 local origin=d.returning and cast.origin or state.root.Position
 local center=(d.form=="area" and (d.originArea and cast.origin or origin)) or cast.center
 local direction=attack.direction
 if d.crosscut and pulse%2==0 then direction=CFrame.Angles(0,math.rad(18),0):VectorToWorldSpace(direction) end
 if d.scatter then center=center+Vector3.new((pulse%2==0 and 1 or -1)*3,0,(pulse-2)*2) end
 local targets={}
 local selected=cast.target and services.enemies[cast.target]
 if d.form=="chain" then
  local from=origin;local used={}
  for i=1,d.maxTargets do
   local best,dist
   for _,e in pairs(services.enemies) do
    local distance=(e.root.Position-from).Magnitude
    local maxRange=i==1 and d.range or d.chainRange
    if alive(e) and not used[e] and distance<=maxRange and math.abs(e.root.Position.Y-from.Y)<=d.maxHeight
     and (i>1 or (not selected or e==selected) and (distance<.01 or flat(e.root.Position-origin).Unit:Dot(direction)>=math.cos(math.rad(d.angle/2)))) and services.clear(from,e.root.Position,state.character,e.model)
     and (not dist or distance<dist or distance==dist and e.id<best.id) then best,dist=e,distance end
   end
   if not best then break end
   table.insert(targets,best);used[best]=true;from=best.root.Position
  end
 else
  for _,e in pairs(services.enemies) do
   if alive(e) then
    local delta=e.root.Position-origin;local length=flat(delta).Magnitude
    local dot=length>.001 and flat(delta).Unit:Dot(direction) or 1
    local inside=false
    local rayOrigin=origin
    if d.form=="ground" then
     rayOrigin=center
     inside=flat(e.root.Position-center).Magnitude<=d.radius and math.abs(e.root.Position.Y-center.Y)<=d.maxHeight
      and services.clear(cast.origin,center,state.character,nil)
    elseif d.form=="area" then
     rayOrigin=center;inside=flat(e.root.Position-center).Magnitude<=d.range and math.abs(e.root.Position.Y-center.Y)<=d.maxHeight
    elseif d.form=="projectile" then inside=(not selected or selected==e) and length<=d.range and dot>=math.cos(math.rad(d.angle/2)) and math.abs(delta.Y)<=d.maxHeight
    elseif d.form=="line" then
     inside=inLine(d,direction,delta)
    else inside=length<=d.range and dot>=math.cos(math.rad(d.angle/2)) and math.abs(delta.Y)<=d.maxHeight end
    if inside and services.clear(rayOrigin,e.root.Position,state.character,e.model) then table.insert(targets,e) end
   end
  end
  table.sort(targets,function(a,b)return nearer(center,a,b)end)
 end
 if d.detonate then
  local first=targets[1]
  center=first and first.root.Position or center
  targets={}
  for _,e in pairs(services.enemies) do
   if alive(e) and flat(e.root.Position-center).Magnitude<=d.radius and math.abs(e.root.Position.Y-center.Y)<=d.maxHeight and services.clear(center,e.root.Position,state.character,e.model) then table.insert(targets,e) end
  end
  table.sort(targets,function(a,b)return nearer(center,a,b)end)
 end
 attack.hits={};attack.hitCount=0
 local contactFrom=(d.form=="ground" or d.form=="area" or d.detonate) and center or origin
 for i=1,math.min(d.maxTargets,#targets) do
  local target=targets[i]
  local position=target.root.Position
  local heading=flat(position-contactFrom)
  if d.form=="line" and not d.detonate then
   heading=d.returning and pulse%2==0 and -direction or direction
  end
  services.damage(state,target,attack,current,heading.Magnitude>.001 and heading.Unit or direction,pulse)
  if d.form=="chain" then contactFrom=position end
 end
 local points={};for i=1,math.min(d.maxTargets,#targets) do table.insert(points,targets[i].root.Position) end
 if d.form=="projectile" and points[1] then center=points[1] end
 services.visual(state,d,origin,center,pulse,points)
end
return AdvancedCombat
