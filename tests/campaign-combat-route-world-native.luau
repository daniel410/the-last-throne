assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local W=require(game.ServerScriptService.Server.World.CampaignWorld)
local world=W.create()
local report={kind='COMBAT_ROUTE_WORLD',checks=0,blockers={},floorFailures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local V=Vector3.new
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain};ray.RespectCanCollide=true
local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.folder};params.RespectCanCollide=true
local seen={}
local function sample(p,key,width)
 report.checks+=1
 local floor=workspace:Raycast(p+V(0,2,0),V(0,-10,0),ray)
 if not floor or math.abs(floor.Position.Y-p.Y)>1.1 then report.floorFailures[#report.floorFailures+1]={key=key,at={p.X,p.Y,p.Z},floor=floor and floor.Position.Y}end
 for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(p+V(0,3.7,0)),V(width or 12,5,12),params))do
  if part.CanCollide and part.Transparency<.95 then local id=key..':'..part:GetFullName()
   if not seen[id]then seen[id]=true;report.blockers[#report.blockers+1]={key=key,part=part:GetFullName(),at={p.X,p.Y,p.Z}}end
  end
 end
end
for _,c in ipairs(C.chapters)do
 for _,g in ipairs(c.goals)do local route=c.combatRoutes[g.id]
  if route then
   local previous=V(table.unpack(g.position))
   for i,point in ipairs(route.points)do
    local p=V(table.unpack(point));local key=c.id..':'..g.id..':'..i
    for x=-1,1 do for z=-1,1 do sample(p+V(x*15,0,z*15),key,8)end end
    local d=p-previous
    if d.Magnitude>1 then
     local normal=V(-d.Z,0,d.X).Unit
     for n=0,math.ceil(d.Magnitude/8)do
      local t=n/math.ceil(d.Magnitude/8)
      local at=previous:Lerp(p,t)+normal*math.sin(t*math.pi)*(c.id:sub(1,2)=='FV'and 8 or 13)*(i%2==0 and 1 or -1)
      sample(at,key,12)
     end
    end
    previous=p
   end
  end
 end
end
for i=1,5 do check(world.loadedEpics[i]and world.folder.CampaignCombatRoutes:FindFirstChild('Epic'..i),'real expanded route world for every epic')end
print('COMBAT_ROUTE_WORLD '..game.HttpService:JSONEncode(report))
return report
