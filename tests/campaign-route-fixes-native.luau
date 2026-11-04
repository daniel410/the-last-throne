-- Six audited regressions; isolated local generated campaign, no save/publish calls.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')
local world=workspace.DeepwoodCampaign;local art=world.EpicWorldArt
local report={checks=0,paths={},pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local physical=RaycastParams.new();physical.RespectCanCollide=true;physical.FilterType=Enum.RaycastFilterType.Include;physical.FilterDescendantsInstances={world,workspace.Terrain}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world}
local function path(a,b,label)
 local p=game.PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
 p:ComputeAsync(a,b);check(p.Status==Enum.PathStatus.Success,label..' accessible without jumping')
 table.insert(report.paths,{label=label,status=p.Status.Name,waypoints=#p:GetWaypoints()});p:Destroy()
end
local function visualLane(root,a,b,label)
 local d=b-a;local n=math.max(1,math.ceil(d.Magnitude/2));local parts=root:GetDescendants()
 for i=0,n do
  local at=a:Lerp(b,i/n)+Vector3.new(0,4,0)
  for _,side in ipairs({-6,0,6})do
   local normal=Vector3.new(-d.Z,0,d.X).Unit;local p=at+normal*side
   for _,part in ipairs(parts)do if part:IsA('BasePart')and part.Transparency<.5 then
    local q=part.CFrame:PointToObjectSpace(p);local h=part.Size/2
    check(math.abs(q.X)>h.X+1 or math.abs(q.Y)>h.Y+1 or math.abs(q.Z)>h.Z+1,label..' visual clearance '..part:GetFullName())
   end end
  end
 end
end
local ok,err=xpcall(function()
 check(art:GetAttribute('ArtVersion')==4,'updated art cache')
 local spawn=world['EC-07_SP'].Position;local target=Vector3.new(-990,151,-10890)
 for _,offset in ipairs({Vector3.zero,Vector3.new(4,0,0),Vector3.new(-4,0,0),Vector3.new(0,0,4),Vector3.new(0,0,-4)})do
  local p=spawn+offset+Vector3.new(0,3,0)
  local parts=workspace:GetPartBoundsInBox(CFrame.new(p),Vector3.new(4,5,4),overlap)
  check(#parts==0,'EC-07 spawn body does not overlap solid pipes')
  path(p,target,'EC-07 spawn '..tostring(offset))
 end
 -- Actual connection centerlines near the previously photographed obstructions.
 visualLane(art['DW-04'].AuthoredVista,Vector3.new(626,30,-2125),Vector3.new(660,34,-2185),'DW-04 tower')
 local gate=art['FV-07'].AuthoredVista.EpicCitadel
 check(not gate:FindFirstChild('GateRecess')and not gate:FindFirstChild('GateIronwork'),'final ice gate is visibly open')
 visualLane(gate,Vector3.new(-854,100,-7285),Vector3.new(-854,102,-7340),'FV-07 exit')
 visualLane(art['EC-07'].AuthoredVista.GreatFoundry,Vector3.new(-825,148,-11190),Vector3.new(-800,151,-11250),'EC-07 foundry')
 visualLane(art['DW-03'].AuthoredVista.ShelteredQuarter,Vector3.new(-530,18,-1680),Vector3.new(-610,18,-1688),'DW-03 quarry')
 local skirt=art['DW-06'].OrganicTerrain.TDDeepCliff
 local cf,size=skirt:GetBoundingBox();check(cf.Position.Y+size.Y/2<38,'DW-06 cliff skirt stays below the lower approach')
 path(Vector3.new(506,41,-2738.5715),Vector3.new(440,49,-2776.2856),'DW-05 to DW-06 slope')
 report.pass=true
end,debug.traceback)
if not ok then report.error=err end
print('CAMPAIGN_ROUTE_FIXES '..game.HttpService:JSONEncode(report));assert(ok,err);return report
