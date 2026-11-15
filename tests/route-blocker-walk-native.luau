assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local world=World.create();local V=Vector3.new
local function vec(p)return V(table.unpack(p))end
local function flat(a,b)return V(a.X-b.X,0,a.Z-b.Z).Magnitude end
local roads=world.folder.OverlandRoads
assert(#roads:GetChildren()==4,'all four overland roads built')
require(game.ServerScriptService.Server.World.EpicWorldArt).connectOverland(world)
assert(#roads:GetChildren()==4,'road construction is idempotent')
local physics=game:GetService('PhysicsService');pcall(function()physics:RegisterCollisionGroup('OverlandQA')end)
physics:CollisionGroupSetCollidable('OverlandQA','OverlandQA',false)
local cases={};local rows={};local finished=0
for _,id in ipairs({'GW-01','EC-05'})do
 local chapter=C.byId[id];local g=chapter.combatRoutes[id=='GW-01'and 'lantern_patrol'or 'vault_patrol']
 local target
 for _,goal in ipairs(chapter.goals)do if goal.id=='exp_2'then target=goal.activity.steps[1].position end end
 for _,variant in ipairs({'points','worldPoints'})do
  local points=g[variant];local case={id=id..'_'..variant,from=vec(points[#points]),to=vec(target),main=35,chapter=id}
  local desc=Instance.new('HumanoidDescription');local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
  rig.Name='RouteBlocker_'..case.id
  for _,p in ipairs(rig:GetDescendants())do if p:IsA('BasePart')then p.CollisionGroup='OverlandQA'end end
  rig.Parent=workspace;rig:PivotTo(CFrame.new(case.from+V(0,6,0)));case.rig=rig;cases[#cases+1]=case
 end
end
local Run=game:GetService('RunService');Run:Run();task.wait(1)
for _,case in ipairs(cases)do task.spawn(function()
 local r={id=case.id,corrections=0,jumps=0,arrived=false};rows[case.id]=r
 local ok,why=xpcall(function()
  local rig=case.rig;local root=rig.HumanoidRootPart;local human=rig.Humanoid
  human.WalkSpeed=32;human.JumpPower=0;human.AutoJumpEnabled=false;human:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  local player={Character=rig,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
  local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
   heroSession={getActiveHero=function()return {heroId=case.id}end},
   inventory={storyState=function()return {main=case.main,expeditionMission=case.chapter}end,expedition=function()return {missionId=case.chapter}end},
   combat={relocateForStoryGate=function(_,pivot)r.corrections+=1;rig:PivotTo(pivot)end},notice=function()end})
  local started=os.clock();local last=root.Position;local moved=started
  while os.clock()-started<100 do
   if flat(root.Position,case.to)<8 then r.arrived=true;break end
   local path=Nav.route(root.Position,case.to);assert(#path>=2,'missing route')
   local i=2;while i<#path and flat(root.Position,path[i])<3 do i+=1 end
   human:MoveTo(path[i]);gate.update(player)
   if human:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
   if flat(root.Position,last)>1 then last=root.Position;moved=os.clock()end
   if os.clock()-moved>8 then r.stalled=true;r.next=tostring(path[i]);break end
   task.wait(.12)
  end
  r.elapsed=os.clock()-started;r.position=tostring(root.Position);r.distance=flat(root.Position,case.to)
 end,debug.traceback)
 if not ok then r.error=why end
 case.rig:Destroy();finished+=1;print('ROUTE_BLOCKER_WALK_CASE '..game.HttpService:JSONEncode(r))
end)end
while finished<#cases do task.wait(.5)end
Run:Stop()
print('ROUTE_BLOCKER_WALK_RESULT '..game.HttpService:JSONEncode(rows))
for _,r in pairs(rows)do assert(not r.error and r.arrived and not r.stalled and r.corrections==0 and r.jumps==0,'story approach walk failed '..r.id)end
return world
