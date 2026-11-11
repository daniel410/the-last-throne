assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated engine only')
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local checks,byEpic=0,{}
local function check(v,m)checks+=1;assert(v,m)end
local floors={workspace.Terrain}
local names={JourneyGround=true,JourneyPass=true,ForestGround=true,SnowGround=true,BasaltGround=true,Ground=true,ForestBedrock=true,TrailEmbankment=true,WalkableTerrace=true,WalkableRamp=true,TerraceLanding=true}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.CanCollide and(names[p.Name]or p.Name:match('^Support_')or p.Name:match('^TrailSupport_')or p.Name:match('^ConnectedPath_')or p.Name:match('^SnowTrail_')or p.Name:match('^CalderaTrail_')or p.Name:match('^LateTrail_'))then table.insert(floors,p)end end
local R=RaycastParams.new();R.FilterType=Enum.RaycastFilterType.Include;R.RespectCanCollide=true
for epic=1,5 do
 local root=world.folder.EpicWorldArt['EpicWorldArt_'..epic]
 local units,footings=0,0
 for _,m in ipairs(root:GetDescendants())do
  check(m.Name~='TDWaterfallGorge','detached waterfall export removed')
  if m:IsA('Model')and m:GetAttribute('ArchitectureGrounded')then
   units+=1
   local surfaces=table.clone(floors)
   for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')and p.Name=='ArchitectureFooting'then
    footings+=1;table.insert(surfaces,p)
    check(p.CanCollide and p.CanQuery and p.Anchored,'foundations are physical')
   end end
   R.FilterDescendantsInstances=surfaces
   -- Lowest feet only. Upper masonry is supported by the courses below it.
   local samples=require(W.ArchitectureGrounding).samples(m)
   for _,p in ipairs(samples)do
    local lowest=true
    for _,q in ipairs(samples)do if q.Y<p.Y-1 and Vector3.new(p.X-q.X,0,p.Z-q.Z).Magnitude<1 then lowest=false;break end end
    if lowest then
     local h=workspace:Raycast(p+Vector3.new(0,256,0),Vector3.new(0,-768,0),R)
     check(h and p.Y-h.Position.Y<.6,'unsupported architecture foot '..m:GetFullName()..' '..tostring(p))
    end
   end
  end
 end
 check(units>0,'all epic architecture audited '..epic)
 byEpic[epic]={units=units,footings=footings}
end
for _,p in ipairs(world.folder:GetDescendants())do check(p.Name~='ReliefAwning'and p.Name~='ReliefAwningPost','suspended relief canopy removed')end
local elder=world.terrain['DW-03']:FindFirstChild('TDElderTree')
check(elder~=nil,'elder tree retained')
for _,name in ipairs({'trunk_geom','roots_geom'})do
 local p=elder:FindFirstChild(name,true)
 check(p and p.CanCollide and p.CanQuery,'elder solid '..name)
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={p};ray.RespectCanCollide=true
 check(workspace:Blockcast(CFrame.new(p.Position-Vector3.new(100,0,0)),Vector3.new(4,5,4),Vector3.new(200,0,0),ray)~=nil,'hero body cannot pass through '..name)
end
-- Story 3 incident-to-Eryn return must not cross a later optional road seal.
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local P=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local journal=P.new();journal.main=2;journal.expansionVersion=1
local gates=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodGates).create()
gates.update({journal=journal})
local gateFolder=workspace:FindFirstChild('PersonalStoryGates')
local sealRay=RaycastParams.new();sealRay.FilterType=Enum.RaycastFilterType.Include;sealRay.RespectCanCollide=true;sealRay.FilterDescendantsInstances={gateFolder}
local Route=require(game.ReplicatedStorage.Shared.CampaignNavigationRoute)
local target=C.byId['DW-03'].goals[#C.byId['DW-03'].goals].position
for _,g in ipairs(C.byId['DW-03'].expansionGoals)do for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then
 local points=Route.route(step.position,target)
 for i=2,#points do
  local a,b=Vector3.new(table.unpack(points[i-1]))+Vector3.new(0,3.7,0),Vector3.new(table.unpack(points[i]))+Vector3.new(0,3.7,0)
  check((b-a).Magnitude<.01 or workspace:Blockcast(CFrame.new(a),Vector3.new(4,5,4),b-a,sealRay)==nil,'Story 3 return crosses locked roadblock '..g.id)
 end
end end end
gates.destroy()
print('ARCHITECTURE_GROUNDING_QA '..game.HttpService:JSONEncode({checks=checks,byEpic=byEpic}))
_G.TLTGroundingWorld=world
