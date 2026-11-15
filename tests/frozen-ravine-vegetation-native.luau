assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local root=world.folder.EpicWorldArt.EpicWorldArt_3['FV-03'].LayeredVegetation
local original={};for _,p in game.ServerStorage.TDMapModels.SnowTree:GetDescendants()do if p:IsA('MeshPart')then original[p.Name]={p.MeshId,p.TextureID}end end
local r={checks=0,trees=0,parts=0,groups={},heights={}}
local function check(ok,message)r.checks+=1;assert(ok,message)end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={workspace.Terrain,world.terrain};ray.RespectCanCollide=true
for _,m in root:GetChildren()do
 check(m:IsA('Model')and m:GetAttribute('TDEnvironmentSource')=='SnowTree','pinned TD tree only')
 check(m:GetAttribute('VergeSource')=='PinnedTD:SnowTree','runtime derivation attribution')
 r.trees+=1;r.groups[m:GetAttribute('VergeCluster')]=true;r.heights[tostring(m:GetAttribute('VergeHeight'))]=true
 local at=m:GetAttribute('GroundPosition');local cf,size=m:GetBoundingBox()
 check(math.abs(cf.Y-size.Y/2-at.Y)<.1,'tree rooted on its declared surface')
 local hit=workspace:Raycast(at+Vector3.new(0,4,0),Vector3.new(0,-10,0),ray)
 check(hit and math.abs(hit.Position.Y-at.Y)<1,'actual ground contact')
 for _,p in m:GetDescendants()do
  check(not p:IsA('LuaSourceContainer')and not p:IsA('Light')and not p:IsA('ParticleEmitter'),'static reuse')
  if p:IsA('BasePart')then
   r.parts+=1;check(p:IsA('MeshPart')and original[p.Name]and p.MeshId==original[p.Name][1]and p.TextureID==original[p.Name][2],'original mesh and texture preserved')
   check(p.Anchored and not p.CanTouch,'anchored scenery')
   check(p.CanCollide==require(W.CampaignSceneryCollision).isSolid(p,root),'trunks solid; leaves soft')
  end
 end
end
local groups=0;for _ in pairs(r.groups)do groups+=1 end
local heights=0;for _ in pairs(r.heights)do heights+=1 end
check(r.trees>=5 and r.trees<=18 and groups>=3 and heights>=3,'unequal groups and heights actually placed')
check(r.parts<=54,'finite original mesh instance budget')
local C=require(game.ReplicatedStorage.Shared.CampaignContent);local a,b
for _,g in C.byId['FV-03'].goals do if g.id=='west_beacon'then a=Vector3.new(table.unpack(g.position))elseif g.id=='east_beacon'then b=Vector3.new(table.unpack(g.position))end end
local signal=RaycastParams.new();signal.FilterType=Enum.RaycastFilterType.Include;signal.FilterDescendantsInstances={root};signal.RespectCanCollide=true
check(workspace:Raycast(a+Vector3.new(0,18,0),b-a,signal)==nil,'open twin signal sightline')
print('FROZEN_RAVINE_VERGE '..game.HttpService:JSONEncode(r))
return r
