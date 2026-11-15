assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
local bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end
local W=game.ServerScriptService.Server.World
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local world=require(W.CampaignWorld).create(2)
local r=world.folder.EpicWorldArt.EpicWorldArt_2['GW-01'].LayeredVegetation
local report={checks=0,trees=0,groups={},heights={},parts=0}
local function check(ok,msg)report.checks+=1;assert(ok,msg)end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances={workspace.Terrain,world.terrain};ray.RespectCanCollide=true
local originals={}
for _,p in game.ServerStorage.TDMapModels.ForestTree:GetDescendants()do if p:IsA('MeshPart')then originals[p.MeshId]=true end end
for _,m in r:GetChildren()do if m:GetAttribute('VergeCluster')then
 report.trees+=1;report.groups[m:GetAttribute('VergeCluster')]=true;report.heights[tostring(m:GetAttribute('VergeHeight'))]=true
 local at=m:GetAttribute('GroundPosition');local h=workspace:Raycast(at+Vector3.new(0,180,0),Vector3.new(0,-480,0),ray)
 check(h and math.abs(h.Position.Y-at.Y)<.1,'grounded tree')
 for _,p in m:GetDescendants()do if p:IsA('BasePart')then
 report.parts+=1;check(p.Anchored,'anchored');check(not p:IsA('MeshPart')or originals[p.MeshId],'pinned tree mesh')
 end end
end end
local groups=0;for _ in report.groups do groups+=1 end
local heights=0;for _ in report.heights do heights+=1 end
check(report.trees>=9 and report.trees<=18,'bounded varied forest population')
check(groups>=4,'broken groups');check(heights>=3,'height hierarchy')
check(r:GetAttribute('VergeTrees')==report.trees,'population metadata')
check(world.folder.EpicWorldArt.EpicWorldArt_2['GW-01'].ScoutsTrailEvidence:GetAttribute('MarkCount')==34,'story traces preserved')
_G.GWVergeWorld=world;_G.GWVergeReport=report
return game.HttpService:JSONEncode(report)
