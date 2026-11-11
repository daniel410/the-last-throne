-- Appended to the offline traversal audit, which has already built all five epics.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'))
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local Art=require(game.ServerScriptService.Server.World.EpicWorldArt)
local report={checks=0,retired=0,moved=0,trees=0,pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local spawns={};for _,p in ipairs(world:GetChildren())do if p:IsA('SpawnLocation')then spawns[p]=p.CFrame end end
local anchors={};for _,folder in ipairs({world.Objectives,world.AdventureActivities})do for _,p in ipairs(folder:GetChildren())do if p:IsA('BasePart')then anchors[p]=p.CFrame end end end
for _,p in ipairs(world:GetDescendants())do if p:IsA('BasePart')then
 if p:GetAttribute('StoryBlockoutProxy')then report.retired+=1;check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'replaced proxy has no physical barrier')end
 local from=p:GetAttribute('RouteClearanceOriginalPosition')
 if from then
  report.moved+=1;check((p.Position-from).Magnitude>0,'roadside scenery relocated')
  if p.Name=='TreeCollision' or p.Name=='GroveTrunk'then
   local found=false
   for _,m in ipairs(p.Parent:GetChildren())do if m:IsA('Model')and (m.Name=='TDForestTree'or m.Name=='TDElderTree')then
    local cf=m:GetBoundingBox()
    if Vector3.new(cf.X-p.Position.X,0,cf.Z-p.Position.Z).Magnitude<.1 then found=true end
   end end
   check(found,'tree artwork follows its collider');report.trees+=1
  elseif p.Name=='AltarObelisk'then
   local found=false
   for _,s in ipairs(p.Parent:GetChildren())do if s.Name=='VioletSeal'and(s.Position-p.Position-Vector3.new(0,14,0)).Magnitude<.1 then found=true end end
   check(found,'obelisk seal follows its pillar')
  end
 end
end end
check(report.retired>0,'actual retired proxies covered');check(report.moved>0 and report.trees>0,'actual relocated props and artwork covered')
local ref={folder=world,terrain=world.TerrainBlockout,spawns={}}
for p in pairs(spawns)do ref.spawns[p.Name:gsub('_SP$','')]=p end
for epic=1,5 do
 local scope=World.scope(epic);local root=world.EpicWorldArt['EpicWorldArt_'..epic]
 check(root and root:GetAttribute('RouteClearanceVersion')==2,'clearance applied to epic '..epic)
 local moves=root:GetAttribute('RelocatedRoadsideProps')
 Art.create(ref,scope)
 check(root:GetAttribute('RelocatedRoadsideProps')==moves,'cached repeat never moves scenery again '..epic)
end
for p,cf in pairs(spawns)do check(p.CFrame==cf,'spawn remains stable after cached repair')end
for p,cf in pairs(anchors)do check(p.CFrame==cf,'story/activity anchors remain stable after cached repair')end
-- Restore the old furnace wall and confirm the migration opens it exactly once.
local region=world.TerrainBlockout['EC-07'];local center=Vector3.new(table.unpack(require(game.ReplicatedStorage.Shared.CampaignContent).zones['EC-07'].center))
local wall
for _,p in ipairs(region:GetChildren())do if p.Name=='GreatFurnaceWall'or p.Name=='GreatFurnaceLintel'then if not wall and p.Name=='GreatFurnaceWall'then wall=p else p:Destroy()end end end
wall.Size=Vector3.new(130,42,10);wall.Position=center+Vector3.new(0,21,-175)
local repair=require(game.ServerScriptService.Server.World.EmberCalderaWorld).repairEntrance
repair(ref);repair(ref)
local walls,headers=0,0
for _,p in ipairs(region:GetChildren())do if p.Name=='GreatFurnaceWall'then walls+=1;check(p.Size.X==45,'legacy side wall retained')elseif p.Name=='GreatFurnaceLintel'then headers+=1 end end
check(walls==2 and headers==1,'legacy wall upgraded once into a doorway')
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={region};params.RespectCanCollide=true
local a=center+Vector3.new(0,3.7,-160);local b=center+Vector3.new(0,3.7,-190)
check(workspace:Blockcast(CFrame.new(a),Vector3.new(4,5,4),b-a,params)==nil,'legacy furnace doorway admits the hero body')
report.pass=true
print('CAMPAIGN_CLEARANCE_NATIVE '..game.HttpService:JSONEncode(report))
