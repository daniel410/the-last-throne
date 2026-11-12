-- Isolated engine geometry / story contract regression, no account services.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local function snapshot()
 local rows={}
 for _,c in ipairs(C.chapters)do
  local goals={};for _,g in ipairs(c.goals)do goals[#goals+1]={g.id,g.position,g.enemies,g.activity}end
  rows[#rows+1]={c.id,c.zone,c.combatRoutes,goals,c.rewards}
 end
 return game.HttpService:JSONEncode(rows)
end
local before=snapshot()
local world=require(W.CampaignWorld).create()
local report={checks=0,zones={},clusters=0,parts=0,missing={}}
local function check(ok,msg)report.checks+=1;assert(ok,msg)end
local floorRay=RaycastParams.new();floorRay.FilterType=Enum.RaycastFilterType.Include
floorRay.FilterDescendantsInstances={workspace.Terrain,world.terrain};floorRay.RespectCanCollide=true
local roads={}
for _,p in ipairs(world.folder:GetDescendants())do
 if p:IsA('BasePart')and (p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ReturnLoop'or p.Name=='RegionalReturnTrail')and p.Transparency<.5 then roads[#roads+1]=p end
end
local roadOverlap=OverlapParams.new();roadOverlap.FilterType=Enum.RaycastFilterType.Include;roadOverlap.FilterDescendantsInstances=roads
for id,z in pairs(C.zones)do
 local site=world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id]
 local root=site:FindFirstChild('StoryComposition');check(root~=nil,'composition root '..id)
 local clusters=#root:GetChildren();local count=0
 if clusters==0 then report.missing[#report.missing+1]=id end
 check(clusters>0,'story composition present '..id)
 check(clusters<=2,'bounded cluster budget '..id)
 for _,m in ipairs(root:GetChildren())do
  check(m:GetAttribute('StoryZone')==id,'zone attribution')
  local ground=m:GetAttribute('GroundPosition')
  check(#workspace:GetPartBoundsInBox(CFrame.new(ground+Vector3.new(0,2,0)),Vector3.new(24,6,24),roadOverlap)==0,'visible road verge '..id)
  check(m:GetAttribute('StoryMotif')==require(W.CampaignStoryComposition).profile(id),'story motif')
  local at=m:GetAttribute('GroundPosition');local cf,size=m:GetBoundingBox()
  check(size.Y<9 and Vector3.new(size.X,0,size.Z).Magnitude/2<12,'camera and footprint envelope '..id)
  check(math.abs(at.X-z.center[1])<z.size[1]/2-12 and math.abs(at.Z-z.center[3])<z.size[2]/2-12,'inside own playable region')
  local hit=workspace:Raycast(at+Vector3.new(0,10,0),Vector3.new(0,-20,0),floorRay)
  check(hit and math.abs(hit.Position.Y-at.Y)<.6,'grounded '..id)
  for _,p in ipairs(m:GetDescendants())do
   if p:IsA('BasePart')then
    count+=1;check(p.Anchored and not p.CanTouch,'static scenery')
    check(p.CanCollide==require(W.CampaignSceneryCollision).isSolid(p,root),'solid ownership')
    check(p.CanQuery==p.CanCollide,'query ownership')
    check(p:GetAttribute('TLTSceneryDistance')==360,'distance budget')
   end
   check(not p:IsA('Light')and not p:IsA('ParticleEmitter')and not p:IsA('LuaSourceContainer')and not p:IsA('BillboardGui'),'no effects/labels/loop budget')
  end
 end
 check(count<=50,'part budget '..id)
 report.zones[id]={clusters=clusters,parts=count};report.clusters+=clusters;report.parts+=count
end
check(snapshot()==before,'story/encounter data unchanged')
local n=#world.folder:GetDescendants()
for i=1,5 do require(W.CampaignWorld).create(i,world)end
check(#world.folder:GetDescendants()==n,'world reentry idempotence')
print('STORY_COMPOSITION_QA '..game.HttpService:JSONEncode(report))
_G.TLTReviewWorld=world
return report
