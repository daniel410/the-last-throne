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
local before={};local rays={}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.CanCollide then before[p]={p.CFrame,p.Size,p.CanQuery}end end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain,workspace.Terrain};params.RespectCanCollide=true
local function saveRay(p)
 local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
 if hit and math.abs(hit.Position.Y-p.Y)<1 then table.insert(rays,{p=p,y=hit.Position.Y})end
end
for id,z in pairs(Content.zones)do
 local c=Vector3.new(table.unpack(z.center))
 for x=-4,4 do for zz=-4,4 do saveRay(c+Vector3.new(x*z.size[1]/10,0,zz*z.size[2]/10))end end
 saveRay(world.spawns[id].Position-Vector3.new(0,.1,0))
end
for _,chapter in ipairs(Content.chapters)do for _,g in ipairs(chapter.goals)do
 saveRay(Vector3.new(table.unpack(g.position)))
 for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position then saveRay(Vector3.new(table.unpack(s.position)))end end
end end
for _,edge in ipairs(Access.edges)do
 local aa,bb=Bounds.ends(edge);local a,b=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb))
 for i=0,24 do saveRay(a:Lerp(b,i/24))end
end
local start=os.clock()
local ok,err=xpcall(function()
 require(Server.World.EpicWorldArt).create(world)
 report.generationSeconds=os.clock()-start
 local art=world.folder.EpicWorldArt;local total=0
 for p,v in pairs(before)do check(p.Parent and p.CFrame==v[1]and p.Size==v[2]and p.CanQuery==v[3]and p.CanCollide,'existing collision retained '..p.Name)end
 for _,ray in ipairs(rays)do
  local hit=workspace:Raycast(ray.p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
  check(hit and math.abs(hit.Position.Y-ray.y)<.15,'terrain cannot cover safe floor at '..tostring(ray.p))
 end
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
  check(parts>45 and parts<1100,'bounded authored site density '..id)
  report.sites[id]={theme=site:GetAttribute('Theme'),landmark=site:GetAttribute('Landmark'),parts=parts};total+=parts
 end
 local meshes=0
 for _,p in ipairs(art:GetDescendants())do
  if p:IsA('BasePart')then check(not p.CanCollide and not p.CanQuery,'all route scenery non-physical')end
  if p:IsA('MeshPart')then meshes+=1;check(p.MeshId~='','original reusable TD mesh')end
 end
 report.siteParts=total;report.reusedMeshInstances=meshes
 local count=#art:GetDescendants();require(Server.World.EpicWorldArt).create(world)
 check(#art:GetDescendants()==count,'idempotent rebuild')
 report.totalDescendants=count;report.pass=true
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
print('EPIC_WORLD_ART_NATIVE '..game.HttpService:JSONEncode(report))
assert(ok,err)
return report
