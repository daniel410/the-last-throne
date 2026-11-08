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
local content=require(game.ReplicatedStorage.Shared.DeepwoodContent)
local c=content.byId['DW-04'];local prev=Vector3.new(table.unpack(c.goals[4].activity.steps[3].position))
for j=5,6 do for _,step in ipairs(c.goals[j].activity.steps)do
 local at=Vector3.new(table.unpack(step.position));local n=math.max(1,math.ceil((at-prev).Magnitude/2))
 for i=0,n do
  local p=prev:Lerp(at,i/n)
  check(#workspace:GetPartBoundsInBox(CFrame.new(p+Vector3.new(0,3.5,0)),Vector3.new(4,5,4),overlap)==0,'phase3 body clearance '..step.id)
  local floor=workspace:Raycast(p+Vector3.new(0,4,0),Vector3.new(0,-12,0),physical)
  check(floor and math.abs(floor.Position.Y-p.Y)<1,'phase3 floor '..step.id)
 end
 local path=game.PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
 path:ComputeAsync(prev+Vector3.new(0,3,0),at+Vector3.new(0,3,0));check(path.Status==Enum.PathStatus.Success,'phase3 reachable without jump '..step.id)
 table.insert(report.paths,{step=step.id,status=path.Status.Name});path:Destroy();prev=at
end end
-- Reusing an older Studio world repairs the colliders without moving anchors.
local spawn=world.spawns['DW-04'];local spawnCF=spawn.CFrame
for _,p in ipairs(pillars)do p.CanCollide=true;p.CanQuery=true;p.CanTouch=true end
Forest.create(world)
for _,p in ipairs(pillars)do check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'reused scene repaired')end
check(world.spawns['DW-04']==spawn and spawn.CFrame==spawnCF,'checkpoint preserved')
check(workspace:Blockcast(CFrame.new(a),Vector3.new(4,5,4),b-a,physical)==nil,'reused main road clear')
report.pass=true
print('DEEPWOOD_WATCHTOWER_ROAD '..game.HttpService:JSONEncode(report));return report
