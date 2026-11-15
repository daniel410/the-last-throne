-- Inspect retained terrain AFTER carve, neighboring terrain and scenery finishing.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local world=assert(_G.HGWorld)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local site=world.folder.EpicWorldArt:FindFirstChild('HG-03',true)
local banks=assert(site.OrganicTerrain:FindFirstChild('PassageBanks'))
local report={checks=0,banks={},skyline=0,shoulders=0}
local function check(ok,msg)report.checks+=1;assert(ok,msg)end
local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances={workspace.Terrain}
for _,m in ipairs(banks:GetChildren())do
 local p=m:GetAttribute('Center');local r=m:GetAttribute('FootprintRadius');local kind=m:GetAttribute('LandformKind')
 check(not B.region(p.X,p.Z,r,kind=='Shoulder'and 'HG-03'or nil),'other playable areas '..m.Name)
 check(not B.connection(p.X,p.Z,r),'connector clearance '..m.Name)
 local top=-math.huge;local mats={}
 for x=-m:GetAttribute('BallRadius')+8,m:GetAttribute('BallRadius')-8,8 do
 for z=-m:GetAttribute('BallRadius')+8,m:GetAttribute('BallRadius')-8,8 do
  if x*x+z*z<(m:GetAttribute('BallRadius')-8)^2 then
   local hit=workspace:Raycast(p+Vector3.new(x,180,z),Vector3.new(0,-360,0),rp)
   check(hit~=nil,'continuous native terrain '..m.Name)
   if hit then top=math.max(top,hit.Position.Y);mats[hit.Material.Name]=(mats[hit.Material.Name]or 0)+1 end
  end
 end end
 check(top>p.Y+m:GetAttribute('Height')-8,'retained raised silhouette '..m.Name)
 check(mats.Rock~=nil,'weathered rock cap remains '..m.Name)
 if kind=='Skyline'then check(mats.Slate~=nil,'exposed slate bank '..m.Name);report.skyline+=1 else report.shoulders+=1 end
 report.banks[m.Name]={height=top-p.Y,materials=mats,center={p.X,p.Y,p.Z}}
end
check(report.skyline>0 and report.shoulders>0,'both skyline and internal relief')
check(banks:GetAttribute('TerrainWrites')<=22,'bounded authoring work')
for _,m in ipairs(banks:GetDescendants())do check(not m:IsA('BasePart')and not m:IsA('LuaSourceContainer'),'no new part or script assets')end
local plots,graves=0,0
for _,m in ipairs(site.GroundAndPaths:GetChildren())do if m.Name=='QuietBurialPlot'then
 plots+=1
 for _,p in ipairs(m:GetDescendants())do if p:GetAttribute('BurialPlotGrave')then graves+=1 end end
end end
check(plots>=3 and graves==plots*3,'burial groups preserved')
report.plots=plots;report.graves=graves
_G.HGBankReport=report
return report
