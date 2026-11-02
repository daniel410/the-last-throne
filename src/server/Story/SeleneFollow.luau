-- Grounded kinematic locomotion for the TD-derived articulated actor.
-- The server owns the route; clients only interpolate and pose the appearance.
local Pathfinding=game:GetService('PathfindingService')
local Budget=require(game.ReplicatedStorage.Shared.SeleneSupport)
local Follow={}
local function flat(v) return Vector3.new(v.X,0,v.Z) end
function Follow.params(model,character,enemies)
 local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Exclude
 p.FilterDescendantsInstances={model,character,enemies};p.RespectCanCollide=true
 return p
end
function Follow.ground(position,params)
 local hit=workspace:Raycast(position+Vector3.new(0,6,0),Vector3.new(0,-18,0),params)
 if hit and hit.Normal.Y>.55 then return hit.Position end
end
function Follow.step(f,root,dt,params,hold)
 dt=math.clamp(dt,0,.25)
 local position=f.model.PrimaryPart.Position
 local ownerDelta=flat(root.Position-(f.lastOwner or root.Position))
 -- Looking around while stationary must not send the supporter orbiting.
 if ownerDelta.Magnitude>.25 then f.heading=ownerDelta.Unit;f.lastOwner=root.Position end
 f.heading=f.heading or flat(root.CFrame.LookVector).Unit;f.lastOwner=f.lastOwner or root.Position
 local goal=Follow.ground(root.Position-f.heading*8+Vector3.new(f.heading.Z,0,-f.heading.X)*2.5,params)
 local separation=flat(root.Position-position).Magnitude
 if not goal or separation>100 then hold=true end
 local gap=goal and flat(goal-position).Magnitude or 0
 if hold or gap<1.4 then f.moving=false elseif gap>4 then f.moving=true end
 local point
 if f.moving and not hold then
  local delta=goal-position
  -- Clearance at body height; never steer through an obstacle using a stale route.
  local direct=not workspace:Spherecast(position+Vector3.new(0,2.3,0),1.1,flat(delta),params)
  local middle=Follow.ground(position+flat(delta)*.5,params)
  if direct and middle and math.abs(middle.Y-position.Y)<2.5 and math.abs(goal.Y-position.Y)<3 then
   point=goal;f.waypoints=nil
  else
   local time=os.clock()
   if time>=(f.nextPath or 0) and not f.computing then
    f.nextPath=time+Budget.pathRefresh;f.computing=true
    task.spawn(function()
     local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=3})
     local ok=pcall(function()path:ComputeAsync(position+Vector3.new(0,2,0),goal)end)
     if f.model.Parent and ok and path.Status==Enum.PathStatus.Success then
      f.waypoints=path:GetWaypoints();f.index=2
     elseif f.model.Parent then f.waypoints=nil end
     f.computing=false;path:Destroy()
    end)
   end
   local waypoints=f.waypoints
   while waypoints and waypoints[f.index] and flat(waypoints[f.index].Position-position).Magnitude<1.2 do f.index+=1 end
   point=waypoints and waypoints[f.index] and waypoints[f.index].Position
  end
 end
 local delta=point and flat(point-position) or Vector3.zero
 local desired=delta.Magnitude>.1 and math.min(Budget.followSpeed,14+math.max(0,separation-12)*.8,math.sqrt(2*28*math.max(0,gap-1))) or 0
 f.speed=math.max(0,(f.speed or 0)+math.clamp(desired-(f.speed or 0),-40*dt,28*dt))
 local nextPosition=position
 if delta.Magnitude>.1 and f.speed>.01 then
  local step=delta.Unit*math.min(delta.Magnitude,f.speed*dt)
  local ground=Follow.ground(position+step,params)
  local blocked=workspace:Spherecast(position+Vector3.new(0,2.3,0),1.05,step,params)
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
  overlap.FilterDescendantsInstances=params.FilterDescendantsInstances;overlap.RespectCanCollide=true
  local occupied=#workspace:GetPartBoundsInBox(CFrame.new(position+step+Vector3.new(0,2.3,0)),Vector3.new(2.1,4,2.1),overlap)>0
  if not occupied and ground and math.abs(ground.Y-position.Y)<=math.max(1,step.Magnitude*.85) and not blocked then
   nextPosition=ground
  else f.speed=0;f.waypoints=nil;f.nextPath=0 end
 end
 local facing=delta.Magnitude>.1 and delta or (hold and flat(root.Position-position) or nil)
 local rotation=f.model.PrimaryPart.CFrame.Rotation
 if facing and facing.Magnitude>.1 then
  local desiredRotation=CFrame.lookAt(Vector3.zero,facing).Rotation
  rotation=rotation:Lerp(desiredRotation,1-math.exp(-6*dt))
 end
 f.model:PivotTo(CFrame.new(nextPosition)*rotation)
 f.model:SetAttribute('SeleneMoveSpeed',dt>0 and flat(nextPosition-position).Magnitude/dt or 0)
 return separation
end
return Follow
