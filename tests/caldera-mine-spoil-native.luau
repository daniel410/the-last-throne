-- Inspect final finished geometry, after route relocation and collision application.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local world=assert(_G.MineWorld);local W=game.ServerScriptService.Server.World
local root=world.folder.EpicWorldArt:FindFirstChild('EC-03',true).LayeredVegetation
local source=game.ServerStorage.TDMapModels.VolcanoCliff.body_geom
local r={checks=0,groups=0,rocks=0,parts=0,bands={},heights={},placements={}}
local function check(ok,message)r.checks+=1;assert(ok,message)end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={workspace.Terrain,world.terrain};ray.RespectCanCollide=true
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local A=require(game.ReplicatedStorage.Shared.CampaignAreas)
for _,group in ipairs(root:GetChildren())do
 check(group.Name=='ColdBasaltSpoil'and group:IsA('Model'),'authored static spoil group')
 r.groups+=1;r.bands[tostring(group:GetAttribute('MineSpoilBand'))]=true
 local gc,gs=group:GetBoundingBox();local zone=C.zones['EC-03']
 local radius=Vector3.new(gs.X,0,gs.Z).Magnitude/2
 check(math.abs(gc.X-zone.center[1])+gs.X/2<=zone.size[1]/2 and math.abs(gc.Z-zone.center[3])+gs.Z/2<=zone.size[2]/2,'finished group stays inside EC-03')
 check(not B.connection(gc.X,gc.Z,radius+8),'regional connector remains clear')
 for _,area in ipairs(zone.expansionAreas)do
  check(not A.contains(area,gc.X,gc.Z,radius+8)and not A.contains(area.connector,gc.X,gc.Z,radius+8),'evacuation and return wings remain clear')
 end
 r.placements[#r.placements+1]={center={gc.X,gc.Y,gc.Z},size={gs.X,gs.Y,gs.Z}}
 for _,rock in ipairs(group:GetChildren())do
  r.rocks+=1;r.heights[tostring(rock:GetAttribute('MineSpoilHeight'))]=true
  check(rock:GetAttribute('TDEnvironmentSource')=='VolcanoCliff','pinned original provenance')
  local cf,extent=rock:GetBoundingBox();local bottom=cf.Y-extent.Y/2
  local hit=workspace:Raycast(Vector3.new(cf.X,bottom+4,cf.Z),Vector3.new(0,-12,0),ray)
  check(hit and bottom-hit.Position.Y>=-1.25 and bottom-hit.Position.Y<=.5,'finished rock meets actual floor')
  for _,p in ipairs(rock:GetDescendants())do
   check(not p:IsA('LuaSourceContainer')and not p:IsA('Light')and not p:IsA('ParticleEmitter'),'no executable assets or emitters')
   if p:IsA('BasePart')then
    r.parts+=1
    check(p:IsA('MeshPart')and p.MeshId==source.MeshId,'original mesh identity')
    check(p:GetAttribute('TDOriginalTexture')==source.TextureID and p.TextureID==''and p.Material==Enum.Material.Basalt,'cold basalt derivation preserves source attribution')
    check(p.Anchored and p.CanCollide and p.CanQuery and not p.CanTouch,'visible rock is physical')
   end
  end
 end
end
check(r.groups>=3 and r.groups<=4,'at least three distinct spoil groups')
check(r.rocks==r.groups*3 and r.parts==r.rocks and r.parts<=12,'three single-mesh masses per group; bounded cost')
local n=0;for _ in pairs(r.heights)do n+=1 end;check(n==3,'three authored scales')
_G.MineReport=r
return r
