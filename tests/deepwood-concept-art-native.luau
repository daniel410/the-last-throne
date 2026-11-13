-- Engine acceptance for the concept translation, not a substitute for art/user QA.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local V=Vector3.new
local function snapshot()
 local t={}
 for _,c in ipairs(C.chapters)do t[#t+1]={c.id,c.zone,c.goals,c.combatRoutes,c.rewards}end
 return game.HttpService:JSONEncode(t)
end
local before=snapshot()
local world=require(W.CampaignWorld).create()
local report={checks=0,zones={},signatureCount=0,parts=0,solids=0,pavers=0,failures={}}
local function check(ok,msg)report.checks+=1;if not ok then report.failures[#report.failures+1]=msg end end
local floor=RaycastParams.new();floor.FilterType=Enum.RaycastFilterType.Include;floor.FilterDescendantsInstances={workspace.Terrain,world.terrain};floor.RespectCanCollide=true
local cast=RaycastParams.new();cast.FilterType=Enum.RaycastFilterType.Include;cast.RespectCanCollide=true
for id,z in pairs(C.zones)do
 local site=world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id]
 local group=site:FindFirstChild('DeepwoodConcept')
 if id:sub(1,2)~='DW'then check(not group,'other epics untouched '..id)
 else
  check(group~=nil,'Deepwood concept exists '..id)
  check(group:GetAttribute('ConceptTitle')==require(W.DeepwoodConceptArt).profile(id)[1],'distinct region identity '..id)
  local count,signatures,assemblies,solids,pavers=0,0,0,0,0
  for _,m in ipairs(group:GetChildren())do
   if m:GetAttribute('ConceptZone')then
    assemblies+=1;signatures+=m:GetAttribute('DeepwoodConceptRole')=='Signature'and 1 or 0
    if m:GetAttribute('DeepwoodConceptRole')=='Signature'then
     check(m:GetAttribute('BlenderSource')=='deepwood-architecture-blender-v1','Blender-authored signature '..id)
     check(#m:GetChildren()==#require(W.DeepwoodArchitectureTemplates)[m.Name],'complete Blender primitive export '..id)
    end
    local at=m:GetAttribute('GroundPosition');local r=m:GetAttribute('PlacementRadius')
    check(math.abs(at.X-z.center[1])+r<z.size[1]/2 and math.abs(at.Z-z.center[3])+r<z.size[2]/2,'inside real region '..id)
    local hit=workspace:Raycast(at+V(0,15,0),V(0,-30,0),floor)
    check(hit and math.abs(hit.Position.Y-at.Y)<.75,'grounded assembly '..id..m.Name)
   end
  end
  for _,p in ipairs(group:GetDescendants())do
   check(not p:IsA('LuaSourceContainer')and not p:IsA('Light')and not p:IsA('ParticleEmitter')and not p:IsA('ProximityPrompt')and not p:IsA('BillboardGui'),'static scenery only')
   if p:IsA('BasePart')then
    count+=1;check(p.Anchored and not p.CanTouch,'anchored/no touch')
    check(p.CanCollide==require(W.CampaignSceneryCollision).isSolid(p,group),'visible solidity contract')
    check(p.CanQuery==p.CanCollide,'queries follow solidity')
    check(p:GetAttribute('TLTSceneryDistance')<=700,'distance budget')
    if p.CanCollide then solids+=1 end
   end
  end
  for _,p in ipairs(site.DeepwoodRouteFinish:GetChildren())do
   if p.Name=='WornTrailPaver'then pavers+=1 end
   check(not p.CanCollide and not p.CanQuery and not p.CastShadow,'paving is grounded paint')
   local hit=workspace:Raycast(p.Position+V(0,2,0),V(0,-5,0),floor)
   check(hit and math.abs(hit.Position.Y-p.Position.Y)<.45,'paver supported '..id..' at '..tostring(p.Position)..' floor '..tostring(hit and hit.Position.Y))
  end
  check(signatures==1,'one characteristic landmark '..id)
  check(assemblies>=3,'supporting scale clusters '..id)
  check(count<=520 and pavers<=84,'per-zone scenery budget '..id)
  check(solids>20,'physical substantial geometry '..id)
  check(#site.AuthoredVista:GetChildren()==0,'replaced generic Deepwood architecture '..id)
  report.signatureCount+=signatures;report.parts+=count;report.solids+=solids;report.pavers+=pavers
  report.zones[id]={parts=count,solids=solids,assemblies=assemblies,pavers=pavers,skipped=group:GetAttribute('SkippedAssemblies'),rejections=group:GetAttribute('PlacementRejections')}
 end
end
check(report.signatureCount==10,'all seven main + three shared optional regions')
check(world.folder:GetAttribute('DeepwoodFinishedPaths')>500,'all Deepwood route layers share the finish')
check(world.folder:GetAttribute('DeepwoodGroundedVergeCliffs')>0,'legacy TD cliff islands sunk into banks')
check(world.folder:GetAttribute('DeepwoodLandmarkPrunedTrees')>0,'landmark approach canopies opened')
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p:GetAttribute('DeepwoodConceptPath')then
 local _,id=require(game.ReplicatedStorage.Shared.CampaignBounds).region(p.Position.X,p.Position.Z)
 check(id and id:sub(1,2)=='DW'and not p.CanCollide and not p.CanQuery,'route finish confined to Deepwood paint')
end end
check(snapshot()==before,'story/encounter/reward contracts unchanged')
local n=#world.folder:GetDescendants()
for i=1,5 do require(W.CampaignWorld).create(i,world)end
check(n==#world.folder:GetDescendants(),'reentry idempotent')
print('DEEPWOOD_CONCEPT_QA '..game.HttpService:JSONEncode(report))
_G.TLTReviewWorld=world
assert(#report.failures==0,'Deepwood concept regression; see report')
return report
