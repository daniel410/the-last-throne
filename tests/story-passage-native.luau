-- Full-width story mouths, not only the center line of the previous probes.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA scene required')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()
local V=Vector3.new
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.IgnoreWater=true
ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local r={edges=0,samples=0,holes={},steps={},maxError=0}
for _,edge in ipairs(C.edges)do
 local aa,bb=B.ends(edge);local a,b=V(table.unpack(aa)),V(table.unpack(bb))
 local d=V(b.X-a.X,0,b.Z-a.Z);local side=V(-d.Z,0,d.X).Unit
 local n=math.max(1,math.ceil(d.Magnitude/2));r.edges+=1
 for _,offset in ipairs({-46,-40,-24,-4,0,4,24,40,46})do
  local last
  -- Include the skewed mouth corners outside the nominal center-line ends.
  for i=-40,n+40 do
   local p=a+d*(i/n)+side*offset;local expected=B.surface(p.X,p.Z)
   if expected then
    r.samples+=1
    local hit=workspace:Raycast(V(p.X,expected+24,p.Z),V(0,-64,0),ray)
    local error=hit and expected-hit.Position.Y or 64
    r.maxError=math.max(r.maxError,error)
    if error>.6 then table.insert(r.holes,{edge=edge,offset=offset,position=tostring(p),expected=expected,actual=hit and hit.Position.Y})end
    if hit and last and math.abs(hit.Position.Y-last)>2.5 then table.insert(r.steps,{edge=edge,offset=offset,position=tostring(p),rise=hit.Position.Y-last})end
    last=hit and hit.Position.Y
   end
  end
 end
 task.wait()
end
local retired=0
for _,p in ipairs(world.terrain:GetDescendants())do
 if p:IsA('BasePart')and(p.Name:match('^ConnectedPath_')or p.Name:match('^SnowTrail_')or p.Name:match('^CalderaTrail_')or p.Name:match('^LateTrail_'))then
  assert(not p.CanCollide and not p.CanQuery and not p.CanTouch,'obsolete nested trail remains physical: '..p:GetFullName())
  retired+=1
 end
end
r.retiredTrails=retired
print('STORY_PASSAGE_SURFACES '..game.HttpService:JSONEncode(r))
assert(#r.holes==0,'story passage floor holes')
-- Recovery must not record a partly buried root as a valid return position.
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
for _,rigType in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 local desc=Instance.new('HumanoidDescription')
 local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rigType);desc:Destroy()
 rig.Parent=workspace;local root=rig.HumanoidRootPart;root.Anchored=true
 rig.PrimaryPart=root
 local human=rig.Humanoid;local height=human.HipHeight+root.Size.Y/2+(rigType==Enum.HumanoidRigType.R6 and rig['Left Leg'].Size.Y or 0)
 local hero={heroId='passage-qa'};local s={main=35,expeditionMission='DW-02'}
 local player={Character=rig,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
 local corrections=0
 local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
  heroSession={getActiveHero=function()return hero end},
  inventory={storyState=function()return s end,expedition=function()return {missionId='DW-02'}end},
  combat={relocateForStoryGate=function(_,cf)corrections+=1;rig:PivotTo(cf);return true end},notice=function()end})
 local safe=V(-1150,0,-1010);local floor=B.surface(safe.X,safe.Z)
 rig:PivotTo(CFrame.new(safe.X,floor+height,safe.Z));gate.update(player)
 local accepted=rig:GetPivot()
 root.Position=V(-1107.9,B.surface(-1107.9,-1049.48)+1.2,-1049.48)
 gate.update(player)
 check(corrections==1 and (rig:GetPivot().Position-accepted.Position).Magnitude<.01,'partly buried feet recover to last standing location '..rigType.Name..' corrections='..corrections..' height='..height..' health='..human.Health..' root='..tostring(root.Position)..' accepted='..tostring(accepted.Position))
 root.Position=V(-1107.9,B.surface(-1107.9,-1049.48)-8,-1049.48);gate.update(player)
 check(corrections==2 and (rig:GetPivot().Position-accepted.Position).Magnitude<.01,'fully buried feet do not overwrite safe point')
 -- Airborne samples cannot replace the last grounded location either.
 root.Position=V(safe.X+10,floor+height+5,safe.Z);gate.update(player)
 root.Position=V(-1107.9,-20,-1049.48);gate.update(player)
 check(corrections==3 and (rig:GetPivot().Position-accepted.Position).Magnitude<.01,'airborne sample not reused')
 -- No prior safe sample / changed hero uses the current checkpoint.
 hero={heroId='new-hero'};root.Position=V(-1107.9,-20,-1049.48);gate.update(player)
 check(corrections==4 and (rig:GetPivot().Position-(world.spawns['DW-02'].Position+V(0,4,0))).Magnitude<.01,'hero change cannot reuse old return point')
 gate.remove(player);rig:Destroy()
end
r.recoveryChecks=checks
print('STORY_PASSAGE_RECOVERY '..checks..' checks passed')
_G.StoryPassageWorld=world
return r
