-- Inspect actual terrain and public playable contracts, not a geometry mock.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local V=Vector3.new
local report={checks=0,ridges={},terrainParts=0}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local z=C.zones['FV-03'];local root=world.folder.EpicWorldArt.EpicWorldArt_3['FV-03'].OrganicTerrain.GlacialLandforms
check(root:GetAttribute('RidgeCount')>=4,'representative relief actually generated')
check(root:GetAttribute('TerrainWrites')<=51,'bounded terrain authoring work')
for _,p in ipairs(root:GetDescendants())do
 check(not p:IsA('BasePart')and not p:IsA('LuaSourceContainer'),'no extra scenery parts or executable assets')
end
local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={workspace.Terrain}
local tall,shoulders=0,0
for _,m in ipairs(root:GetChildren())do
 local p=m:GetAttribute('Center');local radius=m:GetAttribute('FootprintRadius');local kind=m:GetAttribute('LandformKind')
 check(not B.region(p.X,p.Z,radius,kind=='Shoulder'and 'FV-03'or nil),'neighbor/expanded-wing clearance '..m.Name)
 check(not B.connection(p.X,p.Z,radius),'connection clearance '..m.Name)
 local width=kind=='Shoulder'and 38 or 128;local depth=kind=='Shoulder'and 42 or 144
 local maxY=-math.huge;local materials={}
 for x=-depth/2+4,depth/2-4,4 do for zz=-width/2+4,width/2-4,4 do
  local hit=workspace:Raycast(p+V(x,220,zz),V(0,-440,0),rp)
  check(hit~=nil,'continuous solid terrain '..m.Name)
  if hit then maxY=math.max(maxY,hit.Position.Y);materials[hit.Material.Name]=(materials[hit.Material.Name]or 0)+1 end
 end end
 check(maxY>p.Y+m:GetAttribute('Height')-12,'visible raised silhouette '..m.Name)
 check(materials.Glacier~=nil and materials.Snow~=nil,'exposed ice and supported snow cap '..m.Name)
 report.ridges[m.Name]={height=maxY-p.Y,materials=materials}
 if kind=='Skyline'then tall+=1 else shoulders+=1 end
end
check(tall>0 and shoulders>0,'skyline and foreground relief both present')
-- The twin signal line must remain open to camera/beam projection above actors.
local chapter=C.byId['FV-03'];local a,b
for _,g in ipairs(chapter.goals)do
 if g.id=='west_beacon'then a=V(table.unpack(g.position))end
 if g.id=='east_beacon'then b=V(table.unpack(g.position))end
end
check(a and b,'existing signal story contract')
check(workspace:Raycast(a+V(0,18,0),b-a,rp)==nil,'unobstructed twin-beacon signal line')
for id,zone in pairs(C.zones)do
 if id~='FV-03'then
  local site=world.folder.EpicWorldArt['EpicWorldArt_'..zone.epic][id]
  check(site.OrganicTerrain:FindFirstChild('GlacialLandforms')==nil,'representative scope only '..id)
 end
end
print('FROZEN_RAVINE_LANDFORMS '..game.HttpService:JSONEncode(report))
return report
