assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
task.spawn(function()
 local ok,e=pcall(function()
 _G.PlotWorld=require(game.ServerScriptService.Server.World.CampaignWorld).create(5)
 local site=_G.PlotWorld.folder.EpicWorldArt:FindFirstChild('HG-03',true)
 local g=site.GroundAndPaths;local plots={};local graves=0;local parts=0
 for _,m in ipairs(g:GetChildren())do if m.Name=='QuietBurialPlot'then
  local box,size=m:GetBoundingBox();plots[#plots+1]={band=m:GetAttribute('BurialPlotBand'),position={box.X,box.Y,box.Z},size={size.X,size.Y,size.Z}}
  for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then parts+=1;if p.Name=='BurialGardenWall'then assert(p.CanCollide and p.CanQuery and not p.CanTouch);assert(p.Size.Y<=5)end end;if p:GetAttribute('BurialPlotGrave')then graves+=1 end end
 end end
 assert(#plots>=3 and graves==#plots*3,'insufficient supported burial plots')
 _G.PlotReport={plots=plots,graves=graves,parts=parts}
 _G.PlotNav={}
do local r=(function()-- All active chapter routes, using current client guidance AND server authority.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local B=require(Shared.CampaignBounds)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local world=assert(_G.PlotWorld)
local report={epics={},blockers={},floors={},corrections={},routeFailures={},returns={},lowSteps={}}
local character=Instance.new('Model');character.Name='EpicMapAudit';character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Size=Vector3.new(2,2,1);root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.Parent=character
local player={Character=character,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
local journal={main=35};local label;local stats
local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
 heroSession={getActiveHero=function()return {heroId='epic-audit'}end},
 inventory={storyState=function()return journal end,expedition=function()return {missionId=journal.expeditionMission}end},
 combat={relocateForStoryGate=function(_,pivot)stats.corrections+=1;if #report.corrections<50 then report.corrections[#report.corrections+1]={label=label,at=tostring(root.Position),back=tostring(pivot.Position)}end end},notice=function()end})
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world.folder}
local probe=Instance.new('Part');probe.Name='EpicAuditProbe';probe.Size=Vector3.new(4,5,4);probe.Anchored=true;probe.CanCollide=false;probe.CanQuery=false;probe.Transparency=1;probe.Parent=workspace
local seen={}
local function flat(a,b)return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude end
local function vec(p)return Vector3.new(table.unpack(p))end
local function sample(p)
 stats.samples+=1
 local expected=B.surface(p.X,p.Z)
 local hit=workspace:Raycast(Vector3.new(p.X,(expected or p.Y)+8,p.Z),Vector3.new(0,-32,0),ray)
 if not hit or not B.supported(p.X,(hit and hit.Position.Y or p.Y)+3,p.Z)then
  stats.floors+=1;if #report.floors<80 then report.floors[#report.floors+1]={label=label,at=tostring(p),expected=expected,actual=hit and hit.Position.Y,part=hit and hit.Instance:GetFullName()}end
 end
 local foot=hit and hit.Position or p
 character:PivotTo(CFrame.new(foot+Vector3.new(0,3,0)));gate.update(player)
 probe.CFrame=CFrame.new(foot+Vector3.new(0,3.7,0))
 for _,part in ipairs(workspace:GetPartsInPart(probe,overlap))do
  local key=label..part:GetFullName()..tostring(part.Position)
  if not seen[key]then
   seen[key]=true
   local floor=part.Name=='JourneyGround'or part.Name=='BasaltGround'or part.Name=='SnowGround'or part.Name=='ForestGround'or part.Name=='Ground'or part.Name:match('^Support_')
   local rise=part.Position.Y+part.Size.Y/2-foot.Y
   if floor and part.CFrame.UpVector.Y>.999 and rise<=1.5 then
    stats.lowSteps+=1;report.lowSteps[#report.lowSteps+1]={label=label,part=part:GetFullName(),rise=rise,at=tostring(foot)}
   else stats.blockers+=1;if #report.blockers<200 then report.blockers[#report.blockers+1]={label=label,part=part:GetFullName(),position=tostring(part.Position),at=tostring(foot)}end end
  end
 end
 return foot
end
for epic=5,5 do
 stats={chapters=0,targets=0,samples=0,steps=0,blockers=0,floors=0,corrections=0,routeFailures=0,connectors=0,lowSteps=0};report.epics[tostring(epic)]=stats
 for _,c in ipairs(C.chapters)do if c.epic==epic then
  stats.chapters+=1;journal.expeditionMission=c.id;journal.main=c.minMain or 0
  if c.quest and c.quest.offerPosition then local p=c.quest.offerPosition;local _,id=B.region(p[1],p[3]);if id then journal.main=math.max(journal.main,C.zones[id].requiresMain)end end
  gate.remove(player)
  local current=world.spawns[c.zone].Position
  local targets={}
  if c.quest and c.quest.offerPosition then targets[#targets+1]={id='offer',position=c.quest.offerPosition}end
  for _,g in ipairs(c.goals)do
   local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points
   if points and #points>0 then
    for i,point in ipairs(points)do targets[#targets+1]={id=g.id..':combat'..i,position=point,minMain=g.minMain}end
   elseif g.activity and g.activity.steps and #g.activity.steps>0 then
    for _,step in ipairs(g.activity.steps)do if step.position then targets[#targets+1]={id=g.id..':'..step.id,position=step.position,minMain=g.minMain}end end
   else targets[#targets+1]={id=g.id,position=g.position,minMain=g.minMain}end
  end
  for _,target in ipairs(targets)do
   stats.targets+=1;label=c.id..':'..target.id;journal.main=math.max(journal.main,target.minMain or 0)
   local goal=vec(target.position);local first=current;local n=0
   local _,from=B.region(current.X,current.Z);local _,to=B.region(goal.X,goal.Z)
   if from and to and from~=to and C.zones[from].epic==C.zones[to].epic then report.returns[#report.returns+1]={label=label,epic=epic,chapter=c.id,from={current.X,current.Y,current.Z},to=target.position}end
   while flat(current,goal)>8 and n<2000 do
    local points=Nav.route(current,goal)
    if #points<2 then
     stats.routeFailures+=1;if #report.routeFailures<50 then report.routeFailures[#report.routeFailures+1]={label=label,at=tostring(current),goal=tostring(goal)}end;break
    end
    local index=2;while index<#points and flat(current,points[index])<.1 do index+=1 end
    local delta=Vector3.new(points[index].X-current.X,0,points[index].Z-current.Z)
    if delta.Magnitude<.01 then stats.routeFailures+=1;break end
    local foot=sample(current+delta.Unit*math.min(4,delta.Magnitude));current=foot+Vector3.new(0,3,0);n+=1;stats.steps+=1
    if n%200==0 then task.wait()end
   end
   if n>=2000 then stats.routeFailures+=1;report.routeFailures[#report.routeFailures+1]={label=label,kind='loop',at=tostring(current)}end
   if flat(current,goal)>8 then current=goal+Vector3.new(0,3,0)end
  end
  print('EPIC_MAP_CHAPTER '..c.id);task.wait()
 end end
 journal.main=epic*7
 for _,edge in ipairs(require(Shared.CampaignAccess).edges)do if C.zones[edge[1]].epic==epic and C.zones[edge[2]].epic==epic then
  stats.connectors+=1;label=edge[1]..' -> '..edge[2]
  local aa,bb=B.ends(edge);local a,b=vec(aa),vec(bb);local d=b-a;local normal=Vector3.new(-d.Z,0,d.X).Unit
  local n=math.max(1,math.ceil(flat(a,b)/4))
  for i=0,n do for _,side in ipairs({-4,0,4})do sample(a:Lerp(b,i/n)+normal*side)end end
 end end
 print('EPIC_MAP_EPIC '..epic..' '..game.HttpService:JSONEncode(stats))
end
probe:Destroy();character:Destroy()
print('EPIC_MAP_NAVIGATION '..game.HttpService:JSONEncode(report))
return report
 end)();_G.PlotNav.points=r;assert(#r.blockers==0 and #r.floors==0 and #r.corrections==0 and #r.routeFailures==0 and #r.lowSteps==0)end
do local r=(function()-- All active chapter routes, using current client guidance AND server authority.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local B=require(Shared.CampaignBounds)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local world=assert(_G.PlotWorld)
local report={epics={},blockers={},floors={},corrections={},routeFailures={},returns={},lowSteps={}}
local character=Instance.new('Model');character.Name='EpicMapAudit';character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Size=Vector3.new(2,2,1);root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.Parent=character
local player={Character=character,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
local journal={main=35};local label;local stats
local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
 heroSession={getActiveHero=function()return {heroId='epic-audit'}end},
 inventory={storyState=function()return journal end,expedition=function()return {missionId=journal.expeditionMission}end},
 combat={relocateForStoryGate=function(_,pivot)stats.corrections+=1;if #report.corrections<50 then report.corrections[#report.corrections+1]={label=label,at=tostring(root.Position),back=tostring(pivot.Position)}end end},notice=function()end})
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world.folder}
local probe=Instance.new('Part');probe.Name='EpicAuditProbe';probe.Size=Vector3.new(4,5,4);probe.Anchored=true;probe.CanCollide=false;probe.CanQuery=false;probe.Transparency=1;probe.Parent=workspace
local seen={}
local function flat(a,b)return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude end
local function vec(p)return Vector3.new(table.unpack(p))end
local function sample(p)
 stats.samples+=1
 local expected=B.surface(p.X,p.Z)
 local hit=workspace:Raycast(Vector3.new(p.X,(expected or p.Y)+8,p.Z),Vector3.new(0,-32,0),ray)
 if not hit or not B.supported(p.X,(hit and hit.Position.Y or p.Y)+3,p.Z)then
  stats.floors+=1;if #report.floors<80 then report.floors[#report.floors+1]={label=label,at=tostring(p),expected=expected,actual=hit and hit.Position.Y,part=hit and hit.Instance:GetFullName()}end
 end
 local foot=hit and hit.Position or p
 character:PivotTo(CFrame.new(foot+Vector3.new(0,3,0)));gate.update(player)
 probe.CFrame=CFrame.new(foot+Vector3.new(0,3.7,0))
 for _,part in ipairs(workspace:GetPartsInPart(probe,overlap))do
  local key=label..part:GetFullName()..tostring(part.Position)
  if not seen[key]then
   seen[key]=true
   local floor=part.Name=='JourneyGround'or part.Name=='BasaltGround'or part.Name=='SnowGround'or part.Name=='ForestGround'or part.Name=='Ground'or part.Name:match('^Support_')
   local rise=part.Position.Y+part.Size.Y/2-foot.Y
   if floor and part.CFrame.UpVector.Y>.999 and rise<=1.5 then
    stats.lowSteps+=1;report.lowSteps[#report.lowSteps+1]={label=label,part=part:GetFullName(),rise=rise,at=tostring(foot)}
   else stats.blockers+=1;if #report.blockers<200 then report.blockers[#report.blockers+1]={label=label,part=part:GetFullName(),position=tostring(part.Position),at=tostring(foot)}end end
  end
 end
 return foot
end
for epic=5,5 do
 stats={chapters=0,targets=0,samples=0,steps=0,blockers=0,floors=0,corrections=0,routeFailures=0,connectors=0,lowSteps=0};report.epics[tostring(epic)]=stats
 for _,c in ipairs(C.chapters)do if c.epic==epic then
  stats.chapters+=1;journal.expeditionMission=c.id;journal.main=c.minMain or 0
  if c.quest and c.quest.offerPosition then local p=c.quest.offerPosition;local _,id=B.region(p[1],p[3]);if id then journal.main=math.max(journal.main,C.zones[id].requiresMain)end end
  gate.remove(player)
  local current=world.spawns[c.zone].Position
  local targets={}
  if c.quest and c.quest.offerPosition then targets[#targets+1]={id='offer',position=c.quest.offerPosition}end
  for _,g in ipairs(c.goals)do
   local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].worldPoints
   if points and #points>0 then
    for i,point in ipairs(points)do targets[#targets+1]={id=g.id..':combat'..i,position=point,minMain=g.minMain}end
   elseif g.activity and g.activity.steps and #g.activity.steps>0 then
    for _,step in ipairs(g.activity.steps)do if step.position then targets[#targets+1]={id=g.id..':'..step.id,position=step.position,minMain=g.minMain}end end
   else targets[#targets+1]={id=g.id,position=g.position,minMain=g.minMain}end
  end
  for _,target in ipairs(targets)do
   stats.targets+=1;label=c.id..':'..target.id;journal.main=math.max(journal.main,target.minMain or 0)
   local goal=vec(target.position);local first=current;local n=0
   local _,from=B.region(current.X,current.Z);local _,to=B.region(goal.X,goal.Z)
   if from and to and from~=to and C.zones[from].epic==C.zones[to].epic then report.returns[#report.returns+1]={label=label,epic=epic,chapter=c.id,from={current.X,current.Y,current.Z},to=target.position}end
   while flat(current,goal)>8 and n<2000 do
    local points=Nav.route(current,goal)
    if #points<2 then
     stats.routeFailures+=1;if #report.routeFailures<50 then report.routeFailures[#report.routeFailures+1]={label=label,at=tostring(current),goal=tostring(goal)}end;break
    end
    local index=2;while index<#points and flat(current,points[index])<.1 do index+=1 end
    local delta=Vector3.new(points[index].X-current.X,0,points[index].Z-current.Z)
    if delta.Magnitude<.01 then stats.routeFailures+=1;break end
    local foot=sample(current+delta.Unit*math.min(4,delta.Magnitude));current=foot+Vector3.new(0,3,0);n+=1;stats.steps+=1
    if n%200==0 then task.wait()end
   end
   if n>=2000 then stats.routeFailures+=1;report.routeFailures[#report.routeFailures+1]={label=label,kind='loop',at=tostring(current)}end
   if flat(current,goal)>8 then current=goal+Vector3.new(0,3,0)end
  end
  print('EPIC_MAP_CHAPTER '..c.id);task.wait()
 end end
 journal.main=epic*7
 for _,edge in ipairs(require(Shared.CampaignAccess).edges)do if C.zones[edge[1]].epic==epic and C.zones[edge[2]].epic==epic then
  stats.connectors+=1;label=edge[1]..' -> '..edge[2]
  local aa,bb=B.ends(edge);local a,b=vec(aa),vec(bb);local d=b-a;local normal=Vector3.new(-d.Z,0,d.X).Unit
  local n=math.max(1,math.ceil(flat(a,b)/4))
  for i=0,n do for _,side in ipairs({-4,0,4})do sample(a:Lerp(b,i/n)+normal*side)end end
 end end
 print('EPIC_MAP_EPIC '..epic..' '..game.HttpService:JSONEncode(stats))
end
probe:Destroy();character:Destroy()
print('EPIC_MAP_NAVIGATION '..game.HttpService:JSONEncode(report))
return report
 end)();_G.PlotNav.worldPoints=r;assert(#r.blockers==0 and #r.floors==0 and #r.corrections==0 and #r.routeFailures==0 and #r.lowSteps==0)end
end);_G.PlotStatus={ok=ok,error=tostring(e)}end);return "started"