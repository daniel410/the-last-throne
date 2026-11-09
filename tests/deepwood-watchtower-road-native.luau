-- Isolated scene only; exercises actual generated/reused collision and roads.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local Forest=require(game.ServerScriptService.Server.World.DeepwoodWorld)
local world=World.create(1)
local report={checks=0,paths={},pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local region=world.terrain['DW-04'];local pillars={}
for _,p in ipairs(region:GetChildren())do if p.Name=='WatchtowerPillar'then
 table.insert(pillars,p);check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'retired pillar cannot stop walking or dodge')
end end
check(#pillars==4,'all four retired pillars covered')
local physical=RaycastParams.new();physical.RespectCanCollide=true;physical.FilterType=Enum.RaycastFilterType.Include;physical.FilterDescendantsInstances={world.folder,workspace.Terrain}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world.folder}
-- Main visible road crosses the north-east legacy pillar at (521,30,-1886).
local a,b=Vector3.new(522,33.5,-1875),Vector3.new(522,33.5,-1897)
check(workspace:Blockcast(CFrame.new(a),Vector3.new(4,5,4),b-a,physical)==nil,'main road body sweep is unobstructed')
local content=require(game.ReplicatedStorage.Shared.CampaignContent)
local route=require(game.ReplicatedStorage.Shared.CampaignIncidentRoute)
local c=content.byId['DW-04'];local spirit
for index,g in ipairs(c.goals)do if g.id=='spirit'then spirit=index end end
local prev=Vector3.new(table.unpack(c.goals[spirit].activity.steps[3].position))
local probe=Instance.new('Part');probe.Size=Vector3.new(4,5,4);probe.Anchored=true;probe.CanCollide=false;probe.CanQuery=false;probe.Transparency=1;probe.Parent=workspace
-- Phase 3 now includes exp_2 before shortcut. The archived six-goal chord
-- bypassed that mandatory wing and tested terrain no current route uses.
for j=spirit+1,#c.goals do for _,step in ipairs(c.goals[j].activity.steps)do
 local points=route.route({prev.X,prev.Y,prev.Z},step.position)
 for leg=2,#points do
 local at=Vector3.new(table.unpack(points[leg]))
 local path=game.PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
 path:ComputeAsync(prev+Vector3.new(0,3,0),at+Vector3.new(0,3,0));check(path.Status==Enum.PathStatus.Success,'phase3 reachable without jump '..step.id)
 -- A solid roadside tree is an intended obstacle. Probe the engine's walkable
 -- route around it, not an arbitrary straight chord through its trunk.
 local waypoints=path:GetWaypoints()
 for wi=2,#waypoints do
 local first,last=waypoints[wi-1].Position,waypoints[wi].Position
 local n=math.max(1,math.ceil((last-first).Magnitude/2))
 for i=0,n do
  local p=first:Lerp(last,i/n)
  -- ComputeAsync starts at root height (+3). Its interpolated waypoints are
  -- not authored foot coordinates; ground them before sampling the body.
  local floor=workspace:Raycast(p+Vector3.new(0,4,0),Vector3.new(0,-12,0),physical)
  check(floor and math.abs(floor.Position.Y-p.Y)<4,'phase3 grounded path '..step.id)
  probe.CFrame=CFrame.new(floor.Position+Vector3.new(0,3.5,0))
  local hits=workspace:GetPartsInPart(probe,overlap)
  check(#hits==0,'phase3 body clearance '..step.id..' at '..tostring(p)..' / '..tostring(hits[1]and hits[1]:GetFullName()))
 end end
 table.insert(report.paths,{step=step.id,status=path.Status.Name});path:Destroy();prev=at
end end end
probe:Destroy()
-- Reusing an older Studio world repairs the colliders without moving anchors.
local spawn=world.spawns['DW-04'];local spawnCF=spawn.CFrame
for _,p in ipairs(pillars)do p.CanCollide=true;p.CanQuery=true;p.CanTouch=true end
Forest.create(world)
for _,p in ipairs(pillars)do check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'reused scene repaired')end
check(world.spawns['DW-04']==spawn and spawn.CFrame==spawnCF,'checkpoint preserved')
check(workspace:Blockcast(CFrame.new(a),Vector3.new(4,5,4),b-a,physical)==nil,'reused main road clear')
report.pass=true
print('DEEPWOOD_WATCHTOWER_ROAD '..game.HttpService:JSONEncode(report));return report
