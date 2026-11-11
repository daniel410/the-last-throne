-- Exercise the actual arrow route against physical ground AND the live server gate.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local B=require(Shared.CampaignBounds)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create(1)
local r={checks=0,steps=0,relocations={},bodyBlockers={},floorIssues={},complete=false}
local function check(v,m)r.checks+=1;assert(v,m)end
local from,to
for _,g in ipairs(C.byId['DW-07'].goals)do
 if g.id=='separate'then from=Vector3.new(table.unpack(g.activity.steps[#g.activity.steps].position))
 elseif g.id=='restoration'then to=Vector3.new(table.unpack(g.position))end
end
local character=Instance.new('Model');character.Name='ReportNavigationQA';character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Anchored=true;root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.Parent=character
local player={Character=character,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
local journal={main=6,expeditionMission='DW-07'}
local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
 heroSession={getActiveHero=function()return {heroId='report-qa'}end},
 inventory={storyState=function()return journal end,expedition=function()return {missionId='DW-07'}end},
 combat={relocateForStoryGate=function(_,pivot)r.relocations[#r.relocations+1]={at=tostring(root.Position),back=tostring(pivot.Position)};character:PivotTo(pivot)end},
 notice=function()end})
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local overlap=OverlapParams.new();overlap.RespectCanCollide=true;overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={world.folder}
local probe=Instance.new('Part');probe.Name='ReportWalkProbe';probe.Size=Vector3.new(4,5,4);probe.Anchored=true;probe.CanCollide=false;probe.CanQuery=false;probe.Transparency=1;probe.Parent=workspace
local seen={}
local function ground(p)
 local expected=B.surface(p.X,p.Z)
 local hit=workspace:Raycast(Vector3.new(p.X,(expected or p.Y)+8,p.Z),Vector3.new(0,-24,0),ray)
 if not hit or not expected or math.abs(hit.Position.Y-expected)>2 then r.floorIssues[#r.floorIssues+1]={at=tostring(p),expected=expected,actual=hit and hit.Position.Y,part=hit and hit.Instance:GetFullName()}end
 return hit and hit.Position or p
end
character:PivotTo(CFrame.new(ground(from)+Vector3.new(0,3,0)))
gate.update(player)
while (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(to.X,0,to.Z)).Magnitude>2 and r.steps<2000 and #r.relocations==0 do
 local points=Nav.route(root.Position,to);check(#points>1,'current client has a valid return route at '..tostring(root.Position)..' step '..r.steps)
 local direction=Vector3.new(points[2].X-root.Position.X,0,points[2].Z-root.Position.Z)
 check(direction.Magnitude>.01,'arrows never get stuck on a vertical duplicate')
 local step=direction.Unit*math.min(4,direction.Magnitude)
 local foot=ground(root.Position+step)
 probe.CFrame=CFrame.new(foot+Vector3.new(0,3.7,0))
 for _,p in ipairs(workspace:GetPartsInPart(probe,overlap))do
  local key=p:GetFullName()..tostring(p.Position)
  if not seen[key]then seen[key]=true;r.bodyBlockers[#r.bodyBlockers+1]={part=p:GetFullName(),at=tostring(foot)}end
 end
 character:PivotTo(CFrame.new(foot+Vector3.new(0,3,0)))
 gate.update(player);r.steps+=1
 if r.steps%100==0 then task.wait()end
end
r.complete=(Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(to.X,0,to.Z)).Magnitude<=2
-- Check the 16-stud walking lane with a four-stud body, including both sides.
-- The final side boss unlocks after the Eryn report, so use its valid progress.
journal.main=7
r.connectorSamples=0
for _,edge in ipairs(require(Shared.CampaignAccess).edges)do
 if edge[1]:match('^DW%-')and edge[2]:match('^DW%-')then
  local aa,bb=B.ends(edge);local a,b=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb))
  local delta=b-a;local normal=Vector3.new(-delta.Z,0,delta.X).Unit
  local n=math.max(1,math.ceil(Vector3.new(delta.X,0,delta.Z).Magnitude/4))
  for i=0,n do for _,side in ipairs({-4,0,4})do
   local foot=ground(a:Lerp(b,i/n)+normal*side)
   character:PivotTo(CFrame.new(foot+Vector3.new(0,3,0)));gate.update(player)
   probe.CFrame=CFrame.new(foot+Vector3.new(0,3.7,0))
   for _,p in ipairs(workspace:GetPartsInPart(probe,overlap))do
    local key=p:GetFullName()..tostring(p.Position)
    if not seen[key]then seen[key]=true;r.bodyBlockers[#r.bodyBlockers+1]={part=p:GetFullName(),at=tostring(foot),edge=edge}end
   end
   r.connectorSamples+=1
  end end
 end
end
probe:Destroy();character:Destroy()
print('DEEPWOOD_REPORT_NAVIGATION '..game.HttpService:JSONEncode(r))
check(r.complete,'following current arrows reaches the real Eryn objective')
check(#r.relocations==0,'server never rubber-bands a player following the arrows')
check(#r.bodyBlockers==0,'return guide has full body clearance')
check(#r.floorIssues==0,'return guide has real server-supported ground')
return r
