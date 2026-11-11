-- Real R15 physics, following the same client route, with jumping disabled.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create(1)
local from,to
for _,g in ipairs(C.byId['DW-07'].goals)do
 if g.id=='separate'then from=Vector3.new(table.unpack(g.activity.steps[#g.activity.steps].position))
 elseif g.id=='restoration'then to=Vector3.new(table.unpack(g.position))end
end
local desc=Instance.new('HumanoidDescription')
local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
rig.Name='ReportWalkingQA';rig.Parent=workspace;rig:PivotTo(CFrame.new(from+Vector3.new(0,6,0)))
local root=rig.HumanoidRootPart;local human=rig.Humanoid
human.WalkSpeed=32;human.JumpPower=0;human.AutoJumpEnabled=false;human:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
local player={Character=rig,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
local r={relocations=0,jumps=0,arrived=false,stalled=false,elapsed=0,updates=0}
local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
 heroSession={getActiveHero=function()return {heroId='walking-qa'}end},
 inventory={storyState=function()return {main=6,expeditionMission='DW-07'}end,expedition=function()return {missionId='DW-07'}end},
 combat={relocateForStoryGate=function(_,pivot)r.relocations+=1;rig:PivotTo(pivot)end},notice=function()end})
local function flatDistance(a,b)return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude end
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local started=os.clock();local last=root.Position;local lastMoved=started;local lastProgress=started
while os.clock()-started<240 do
 if flatDistance(root.Position,to)<8 then r.arrived=true;break end
 local points=Nav.route(root.Position,to)
 if #points<2 then r.routeFailure=tostring(root.Position);break end
 local index=2;while index<#points and flatDistance(root.Position,points[index])<3 do index+=1 end
 human:MoveTo(points[index]);gate.update(player);r.updates+=1
 if human:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
 if flatDistance(root.Position,last)>1 then last=root.Position;lastMoved=os.clock()end
 if os.clock()-lastMoved>8 then r.stalled=true;break end
 if os.clock()-lastProgress>25 then print('REPORT_WALK_PROGRESS '..math.floor(flatDistance(root.Position,to)));lastProgress=os.clock()end
 task.wait(.1)
end
r.elapsed=os.clock()-started;r.at=tostring(root.Position);r.distance=flatDistance(root.Position,to)
rig:Destroy();Run:Stop()
print('DEEPWOOD_REPORT_WALK '..game.HttpService:JSONEncode(r))
assert(r.arrived and not r.stalled and r.relocations==0 and r.jumps==0,'real R15 cannot follow the return guide without a jump or server correction')
return r
