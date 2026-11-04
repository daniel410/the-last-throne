-- Local real-engine scenery contract, including smooth Terrain (not a mock renderer).
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local Server=game.ServerScriptService.Server
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local world=require(Server.World.DeepwoodWorld).create()
require(Server.World.FrozenValeWorld).create(world)
require(Server.World.EmberCalderaWorld).create(world)
require(Server.World.LateEpicWorld).create(world)
require(Server.World.DeepwoodActivityWorld).create(world)
local report={kind='EPIC_WORLD_ART_NATIVE',checks=0,pass=false,sites={},failures={}}
local function check(v,msg)report.checks+=1;assert(v,msg)end
local before={};local rays={};local anchors={};local lanes={}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.CanCollide then before[p]={p.CFrame,p.Size,p.CanQuery}end end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain,workspace.Terrain};params.RespectCanCollide=true
local function planarDistance(p,a,b)
 local dx,dz=b.X-a.X,b.Z-a.Z;local t=math.clamp(((p.X-a.X)*dx+(p.Z-a.Z)*dz)/math.max(.001,dx*dx+dz*dz),0,1)
 return math.sqrt((p.X-a.X-t*dx)^2+(p.Z-a.Z-t*dz)^2)
end
for id in pairs(Content.zones)do table.insert(anchors,{p=world.spawns[id].Position,r=36})end
for _,chapter in ipairs(Content.chapters)do
 local previous=world.spawns[chapter.zone].Position
 for _,g in ipairs(chapter.goals)do
  local p=Vector3.new(table.unpack(g.position));table.insert(anchors,{p=p,r=#g.enemies>0 and 78 or 22});table.insert(lanes,{previous,p,21});previous=p
  local stepPrevious=p
  for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then
   local at=Vector3.new(table.unpack(step.position));table.insert(anchors,{p=at,r=23});table.insert(lanes,{stepPrevious,at,21});stepPrevious=at
  end end
  table.insert(lanes,{stepPrevious,p,21})
 end
end
for _,edge in ipairs(Access.edges)do local aa,bb=Bounds.ends(edge);table.insert(lanes,{Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb)),44})end
local actors=world.folder:FindFirstChild('NPCActors')
if actors then for _,m in ipairs(actors:GetChildren())do if m:IsA('Model')and m.PrimaryPart then table.insert(anchors,{p=m.PrimaryPart.Position,r=23})end end end
local function protected(p)
 for _,a in ipairs(anchors)do if math.abs(p.Y-a.p.Y)<25 and planarDistance(p,a.p,a.p)<a.r then return true end end
 for _,l in ipairs(lanes)do if math.abs(p.Y-(l[1].Y+l[2].Y)/2)<30 and planarDistance(p,l[1],l[2])<l[3]then return true end end
 return false
end
local function saveRay(p)
 local strict=protected(p)
 local hit=workspace:Raycast(p+Vector3.new(0,strict and 3 or 100,0),Vector3.new(0,strict and -8 or -110,0),params)
 if hit and math.abs(hit.Position.Y-p.Y)<1 then table.insert(rays,{p=p,y=hit.Position.Y,strict=protected(p)})end
end
for id,z in pairs(Content.zones)do
 local c=Vector3.new(table.unpack(z.center))
 for x=-4,4 do for zz=-4,4 do saveRay(c+Vector3.new(x*z.size[1]/10,0,zz*z.size[2]/10))end end
 saveRay(world.spawns[id].Position-Vector3.new(0,.1,0))
end
for _,chapter in ipairs(Content.chapters)do for _,g in ipairs(chapter.goals)do
 saveRay(Vector3.new(table.unpack(g.position)))
 local previous=Vector3.new(table.unpack(g.position))
 for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position then
  local at=Vector3.new(table.unpack(s.position));local count=math.max(1,math.ceil((at-previous).Magnitude/8))
  for i=0,count do saveRay(previous:Lerp(at,i/count))end
  previous=at
 end end
end end
for _,edge in ipairs(Access.edges)do
 local aa,bb=Bounds.ends(edge);local a,b=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb))
 for i=0,24 do saveRay(a:Lerp(b,i/24))end
end
local legacySurfaces={}
local legacy=world.terrain:FindFirstChild('DeepwoodPlaces')
if legacy then for _,part in ipairs(legacy:GetDescendants())do
 if part:IsA('BasePart')and part.CanCollide and (part.Name=='WalkableTerrace'or part.Name=='WalkableRamp'or part.Name=='TerraceLanding')then
  local single=RaycastParams.new();single.FilterType=Enum.RaycastFilterType.Include;single.FilterDescendantsInstances={part};single.RespectCanCollide=true
  for x=-2,2 do for z=-2,2 do
   local q=part.CFrame:PointToWorldSpace(Vector3.new(x*part.Size.X/5,0,z*part.Size.Z/5))
   local hit=workspace:Raycast(q+Vector3.new(0,100,0),Vector3.new(0,-200,0),single)
   if hit then table.insert(legacySurfaces,{p=hit.Position,name=part.Name})end
  end end
 end
end end
local start=os.clock()
local ok,err=xpcall(function()
 require(Server.World.EpicWorldArt).create(world)
 report.generationSeconds=os.clock()-start
 local art=world.folder.EpicWorldArt;local total=0
 for p,v in pairs(before)do check(p.Parent and p.CFrame==v[1]and p.Size==v[2]and p.CanQuery==v[3]and p.CanCollide,'existing collision retained '..p.Name)end
 report.protectedGroundSamples=0;report.sculptedSamples=0;report.maxRaisedGround=0
 for _,ray in ipairs(rays)do
  local hit=workspace:Raycast(ray.p+Vector3.new(0,ray.strict and 3 or 100,0),Vector3.new(0,ray.strict and -8 or -110,0),params)
  check(hit~=nil,'supported floor retained '..tostring(ray.p))
  local rise=hit.Position.Y-ray.y
  if ray.strict then report.protectedGroundSamples+=1;check(math.abs(rise)<.15,'protected encounter/spawn/NPC/corridor stays clear '..tostring(ray.p))
  else check(rise>=-.15 and rise<=48,'bounded optional terrain shoulders');if rise>.5 then report.sculptedSamples+=1;report.maxRaisedGround=math.max(report.maxRaisedGround,rise)end end
 end
 check(report.protectedGroundSamples>1000,'broad protection coverage')
 check(report.sculptedSamples>15,'actual raised terrain, not decorative-only terrain claims')
 local onlyTerrain=RaycastParams.new();onlyTerrain.FilterType=Enum.RaycastFilterType.Include;onlyTerrain.FilterDescendantsInstances={workspace.Terrain}
 for _,surface in ipairs(legacySurfaces)do
  local hit=workspace:Raycast(surface.p+Vector3.new(0,80,0),Vector3.new(0,-160,0),onlyTerrain)
  check(not hit or hit.Position.Y<=surface.p.Y+.15,'old optional walk surface cannot be buried '..surface.name)
 end
 report.legacyWalkSurfaceSamples=#legacySurfaces
 report.groundSamples=#rays
 for id in pairs(Content.zones)do
  local site=art:FindFirstChild(id);check(site~=nil,'every main/optional site dressed '..id)
  check(site:GetAttribute('Landmark')~=nil and site:GetAttribute('Theme')~=nil,'authored site identity '..id)
  local parts=0
  for _,p in ipairs(site:GetDescendants())do
   if p:IsA('BasePart')then
    parts+=1;check(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch,'scenery cannot change physics or hit queries')
    check(p:GetAttribute('TLTDecorative')==true,'scenery budget opt-in')
    local limit=p:GetAttribute('TLTSceneryDistance');check(not limit or limit<=900,'bounded backdrop distance')
   elseif p:IsA('LuaSourceContainer')then check(false,'no executable asset content')end
  end
  check(parts>150 and parts<4000,'bounded authored site density '..id)
  report.sites[id]={theme=site:GetAttribute('Theme'),landmark=site:GetAttribute('Landmark'),parts=parts};total+=parts
 end
 local meshes=0
 for _,p in ipairs(art:GetDescendants())do
  if p:IsA('BasePart')then check(not p.CanCollide and not p.CanQuery,'all route scenery non-physical')end
  if p:IsA('MeshPart')then meshes+=1;check(p.MeshId~='','original reusable TD mesh')end
 end
 report.siteParts=total;report.reusedMeshInstances=meshes
 check(art:GetAttribute('BuildComplete')==true and art:GetAttribute('ArtVersion')==3,'only fully generated v3 worlds are cached')
 local count=#art:GetDescendants();require(Server.World.EpicWorldArt).create(world)
 check(#art:GetDescendants()==count,'idempotent rebuild')
 report.totalDescendants=count;report.pass=true
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
print('EPIC_WORLD_ART_NATIVE '..game.HttpService:JSONEncode(report))
assert(ok,err)
return report
