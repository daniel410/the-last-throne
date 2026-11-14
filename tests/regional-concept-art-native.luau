-- Concept translation acceptance is separate from user art and device acceptance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene only')
local W=game.ServerScriptService.Server.World
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Profiles=require(W.RegionalConceptProfiles)
local Templates=require(W.RegionalArchitectureTemplates)
local V=Vector3.new
local function snapshot()
 local t={};for _,c in ipairs(C.chapters)do t[#t+1]={c.id,c.zone,c.reward,c.goals,c.combatRoutes}end
 return game.HttpService:JSONEncode(t)
end
local before=snapshot();local world=require(W.CampaignWorld).create()
local report={checks=0,zones={},signatureCount=0,parts=0,solids=0,pavers=0,failures={}}
local function check(v,m)report.checks+=1;if not v then report.failures[#report.failures+1]=m end end
local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={workspace.Terrain,world.terrain};floor.RespectCanCollide=true
for id,z in pairs(C.zones)do
 local site=world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id]
 local group=site:FindFirstChild('RegionalConcept')
 if z.epic==1 then check(group==nil and site:FindFirstChild('DeepwoodConcept')~=nil,'preserve Deepwood '..id)
 else
  check(group~=nil,'regional concept exists '..id)
  local profile=assert(Profiles[id]);local count,signatures,solids,pavers=0,0,0,0
  check(group:GetAttribute('ConceptTitle')==profile.title,'story title '..id)
  for _,storyId in ipairs(profile.stories)do check(C.byId[storyId].zone==id,'shared story zone '..storyId)end
  for _,m in ipairs(group:GetChildren())do
   if m:GetAttribute('ConceptZone')then
    local at=m:GetAttribute('GroundPosition');local r=m:GetAttribute('PlacementRadius')
    check(math.abs(at.X-z.center[1])+r<z.size[1]/2 and math.abs(at.Z-z.center[3])+r<z.size[2]/2,'inside real zone '..id)
    local hit=workspace:Raycast(at+V(0,15,0),V(0,-30,0),floor)
    check(hit and math.abs(hit.Position.Y-at.Y)<.75,'grounded '..id..m.Name)
    if m:GetAttribute('RegionalConceptRole')=='Signature'then
     signatures+=1
     check(m.Name==profile.kind,'matching concept model '..id)
     local approach=m:GetAttribute('ApproachPosition');local delta=approach-m:GetPivot().Position
     check(Vector3.new(delta.X,0,delta.Z).Unit:Dot(m:GetPivot().ZVector)>.99,'entry faces actual approach '..id)
     check(m:GetScale()>=(id:find('%-S')and .68 or 1),'landmark never miniaturized '..id)
     check(m:GetAttribute('BlenderPrimitiveCount')==#Templates[m.Name],'pinned Blender part census '..id)
     check(m:GetAttribute('BlenderSource')=='regional-architecture-blender-v1','actual Blender source '..id)
     check(#m:GetChildren()==#assert(Templates[m.Name])+(m:GetAttribute('RuntimeDetailParts')or 0),'exact primitive census '..id)
    end
   end
  end
  for _,p in ipairs(group:GetDescendants())do
   check(not p:IsA('LuaSourceContainer')and not p:IsA('Light')and not p:IsA('ParticleEmitter')and not p:IsA('ProximityPrompt')and not p:IsA('BillboardGui'),'static scenery only '..id)
   if p:IsA('BasePart')then
    count+=1;check(p.Anchored and not p.CanTouch,'anchored and no touch')
    check(p.CanCollide==require(W.CampaignSceneryCollision).isSolid(p,group),'visible solidity')
    check(p.CanQuery==p.CanCollide,'query contract')
    check(p:GetAttribute('TLTSceneryDistance')<=700,'distance budget')
    if p.CanCollide then solids+=1 end
   end
  end
  for _,p in ipairs(site.RegionalRouteFinish:GetChildren())do
   pavers+=1;check(not p.CanCollide and not p.CanQuery and not p.CastShadow,'path paint only')
   local hit=workspace:Raycast(p.Position+V(0,2,0),V(0,-5,0),floor)
   check(hit and math.abs(hit.Position.Y-p.Position.Y)<.45,'supported path finish '..id)
  end
  check(signatures==1,'one landmark per real region '..id)
  check(count<=520 and pavers<=56,'regional budget '..id)
  check(solids>=12,'physical substantial geometry '..id)
  check(not site.AuthoredVista:FindFirstChild('LodgeWall',true)and not site.AuthoredVista:FindFirstChild('FurnaceChimney',true),'replaced generic landmark '..id)
  report.signatureCount+=signatures;report.parts+=count;report.solids+=solids;report.pavers+=pavers
  report.zones[id]={parts=count,solids=solids,signatures=signatures,pavers=pavers,rejections=group:GetAttribute('PlacementRejections'),skipped=group:GetAttribute('SkippedAssemblies')}
 end
end
check(report.signatureCount==34,'28 main and six separate optional zones')
check(snapshot()==before,'all 47 stories/rewards/goals/encounters remain unchanged')
require(W.EpicWorldArt).connectOverland(world)
check(#world.folder.OverlandRoads:GetChildren()==4,'retain all four overland connections')
local old=report.parts
for epic=1,5 do require(W.CampaignWorld).create(epic,world)end
local after=0
for id,z in pairs(C.zones)do if z.epic>1 then for _,p in ipairs(world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id].RegionalConcept:GetDescendants())do if p:IsA('BasePart')then after+=1 end end end end
check(after==old,'re-entry does not duplicate scenery')
print('REGIONAL_CONCEPT_ART '..game.HttpService:JSONEncode(report))
assert(#report.failures==0,'regional concept acceptance failed: '..table.concat(report.failures,'; '))
return world
