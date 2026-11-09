-- Run in an isolated engine. Positive obstacle checks accompany route clearance:
-- an empty/noncolliding map must fail even when every route is unobstructed.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local map only')
local World=game.ServerScriptService.Server.World
local world=require(World.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local V=Vector3.new
local report={checks=0,solids=0,decorations=0,byEpic={},casts={},failures={}}
local function check(v,m)report.checks+=1;if not v then table.insert(report.failures,m)end end
local expected={LodgeWall=true,LodgeBack=true,WingWall=true,OctagonalWall=true,CryptSideWall=true,
 IceGalleryWall=true,WeatheredTrunk=true,FacetedOutcrop=true,ArchPier=true,PierCourse=true}
local meshExpected={trunk_geom=true,body_geom=true,walls_geom=true,['glacier peaks_geom']=true,['basalt columns_geom']=true}
local function cast(part)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={part};params.RespectCanCollide=true
 -- Sweep through actual collision geometry, not its bounding-box occupancy.
 for _,axis in ipairs({V(1,0,0),V(0,0,1),V(0,1,0)})do
  local length=part.Size.Magnitude+12
  local at=part.Position-axis*length
  local hit=workspace:Blockcast(CFrame.new(at),V(2,4,2),axis*length*2,params)
  if hit and hit.Instance==part then return true end
 end
 return false
end
for epic=1,5 do
 local roots={world.folder.EpicWorldArt['EpicWorldArt_'..epic],world.folder.CampaignExpansion['Epic'..epic]}
 local stats={walls=0,trunks=0,rocks=0,arches=0,sceneWalls=0}
 for _,root in ipairs(roots)do for _,part in ipairs(root:GetDescendants())do if part:IsA('BasePart')then
  local dynamic=false;local node=part.Parent
  while node and node~=root do if node:GetAttribute('ExpansionEvent')or node:GetAttribute('ExpansionStepEvent')then dynamic=true end;node=node.Parent end
  local wanted=not dynamic and part.Transparency<.95 and (expected[part.Name]or part:IsA('MeshPart')and meshExpected[part.Name])
  if wanted then check(part.CanCollide and part.CanQuery,'visible obstacle permits passage: '..part:GetFullName())end
  if part:GetAttribute('CampaignScenerySolid')then
   report.solids+=1;check(part.CanCollide and part.CanQuery and part.Anchored and not part.CanTouch,'solid physics contract '..part:GetFullName())
   check(part.Transparency<.95 and not dynamic,'no invisible/personal shared wall '..part:GetFullName())
   local kind
   -- Keep explicit categories independent of the production name registry.
   if part.Name=='trunk_geom'or part.Name=='WeatheredTrunk'then kind='trunks'
   elseif part.Name=='body_geom'or part.Name=='FacetedOutcrop'then kind='rocks'
   elseif part.Name=='ArchPier'or part.Name=='PierCourse'then kind='arches'
   elseif part.Name=='IceGalleryWall'then kind='sceneWalls'
   else kind='walls'end
   stats[kind]+=1
   if not report.casts[epic..kind]then
    local pass=cast(part);check(pass,'hero sweep missed actual '..kind..' '..part:GetFullName())
    report.casts[epic..kind]=pass
   end
  elseif dynamic or part.Name=='foliage_geom'or part.Name=='WornCurvedRoute'then
   report.decorations+=1;check(not part.CanCollide and not part.CanQuery,'personal scenes/leaves/path paint remain nonblocking')
  end
 end end end
 check(stats.walls>0 and stats.rocks>0 and stats.arches>0,'each epic has real physical scenery '..epic)
 if epic~=4 then check(stats.trunks>0,'forest/snow/graves tree trunks stop movement '..epic)end
 if epic==3 then check(stats.sceneWalls>0,'expanded ice galleries have physical walls')end
 report.byEpic[epic]=stats
end
local count=#world.folder:GetDescendants()
for epic=1,5 do require(World.CampaignWorld).create(epic,world)end
check(count==#world.folder:GetDescendants(),'cached creation does not duplicate collision')
-- Every authored entrance must admit a full hero, including east/west arches.
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.expansionGoals)do
 local scene=world.folder.CampaignExpansion['Epic'..c.epic][c.id..'_'..g.id]
 local area;for _,a in ipairs(C.zones[c.zone].expansionAreas)do if a.id==g.area then area=a end end
 local p=V(table.unpack(area.entry))+V(0,3.7,0);local axis=area.axis=='x'and V(1,0,0)or V(0,0,1)
 local arch=scene:FindFirstChild('IncidentEntranceArch')
 local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Include;rp.FilterDescendantsInstances=arch and {arch}or {};rp.RespectCanCollide=true
 check(arch~=nil,'incident entrance has an oriented arch '..c.id..g.id)
 if arch then check(workspace:Blockcast(CFrame.new(p-axis*22),V(4,5,4),axis*44,rp)==nil,'incident arch blocks entrance '..c.id..g.id)end
end end
report.pass=#report.failures==0
report.failureCount=#report.failures
report.failures={table.unpack(report.failures,1,math.min(60,#report.failures))}
print('SCENERY_COLLISION_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'physical scenery regression; see report')
