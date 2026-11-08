-- Real pinned TD meshes in all five RPG epics; never a live place/player session.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scenery QA only')
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local S=require(game.ServerScriptService.Server.World.EpicScenicComposition)
local world=World.create()
local report={checks=0,zones={},parts=0,meshes=0,compositionModels=0,heroes=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local root=world.folder.EpicWorldArt
local checkpoints={};for id,p in pairs(world.spawns)do checkpoints[id]=p.CFrame end
for id,z in pairs(Content.zones)do
 local site=root['EpicWorldArt_'..z.epic][id];local group=site:FindFirstChild('TDScenicComposition')
 check(group~=nil,'TD composition exists '..id)
 check(site:GetAttribute('Composition')==S.profile(id)[1],'region-specific composition '..id)
 local n,hero=0,0
 for _,m in ipairs(group:GetChildren())do
  if m:IsA('Model')then
   n+=1;local source=m:GetAttribute('CompositionSource')
   check(game.ServerStorage.TDMapModels:FindFirstChild(source)~=nil,'authentic pinned TD source')
   check(m:GetAttribute('GroundPosition')~=nil,'grounded source placement')
   local cf,size=m:GetBoundingBox();local low,high=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
   for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,zz in ipairs({-1,1})do
    local p=cf:PointToWorldSpace(size*Vector3.new(x,y,zz)/2)
    low=Vector3.new(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z));high=Vector3.new(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z))
   end end end
   local clear=true
   local function anchor(p)
    if p.Y>=low.Y-20 and p.Y<=high.Y+20 and p.X>low.X-16 and p.X<high.X+16 and p.Z>low.Z-16 and p.Z<high.Z+16 then clear=false end
   end
   for _,chapter in ipairs(Content.chapters)do for _,g in ipairs(chapter.goals)do
    anchor(Vector3.new(table.unpack(g.position)))
    for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then anchor(Vector3.new(table.unpack(step.position)))end end
   end end
   for _,spawn in pairs(world.spawns)do anchor(spawn.Position)end
   check(clear,'rotated TD bounds leave real story/activity/spawn anchors clear '..id)
   if m:GetAttribute('CompositionRole')=='Hero'then hero+=1 end
  end
  for _,p in ipairs(m:GetDescendants())do
   if p:IsA('BasePart')then
    check(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch,'cosmetics preserve gameplay physics')
    check(p:GetAttribute('TLTDecorative')==true,'streaming budget opt-in')
   elseif p:IsA('LuaSourceContainer')then check(false,'no executable asset content')end
  end
 end
 check(hero==1,'one readable primary landmark '..id)
 check(n<=9,'bounded composition budget '..id)
 report.zones[id]={composition=site:GetAttribute('Composition'),models=n,hero=hero}
 report.compositionModels+=n;report.heroes+=hero
end
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')then report.parts+=1;if p:IsA('MeshPart')then report.meshes+=1 end end end
local count=#root:GetDescendants()
for epic=1,5 do World.create(epic,world)end
check(#root:GetDescendants()==count,'cached world never duplicates scenery')
for id,cf in pairs(checkpoints)do check(world.spawns[id].CFrame==cf,'cached rebuild preserves checkpoint '..id)end
print('TD_SCENIC_QA '..game.HttpService:JSONEncode(report))
_G.TLTReviewWorld=world
return report
