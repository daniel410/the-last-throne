-- Independent R15 traversals in each epic, plus the two low-step connector verges.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local scene required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local B=require(Shared.CampaignBounds)
local Nav=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodNavigation)
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()
local V=Vector3.new
local function vec(p)return V(table.unpack(p))end
local function flat(a,b)return V(a.X-b.X,0,a.Z-b.Z).Magnitude end
local function reportCase(id,main)
 local c=C.byId[id];local previous=world.spawns[c.zone].Position
 for _,g in ipairs(c.goals)do
  if g.id=='report'then return {id=id..':report',chapter=id,main=math.max(main,g.minMain or 0),from=previous,to=vec(g.position),epic=c.epic}end
  local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points
  if points and #points>0 then previous=vec(points[#points])
  elseif g.activity and g.activity.steps and #g.activity.steps>0 then previous=vec(g.activity.steps[#g.activity.steps].position)
  else previous=vec(g.position)end
 end
 error('report missing '..id)
end
local erynFrom,erynTo
for _,g in ipairs(C.byId['DW-07'].goals)do if g.id=='separate'then erynFrom=vec(g.activity.steps[#g.activity.steps].position)elseif g.id=='restoration'then erynTo=vec(g.position)end end
local cases={
 {id='Eryn_regression',chapter='DW-07',main=6,from=erynFrom,to=erynTo,epic=1},
 {id='GW-07_to_hub',chapter='GW-07',main=14,from=world.spawns['GW-07'].Position,to=world.spawns['GW-03'].Position,epic=2},
 reportCase('FV-Q1',15),reportCase('EC-Q1',22),reportCase('EC-Q4',28),
 {id='HG-07_to_hub',chapter='HG-07',main=35,from=world.spawns['HG-07'].Position,to=world.spawns['HG-02'].Position,epic=5},
}
for _,ids in ipairs({{'EC-04','EC-05'},{'EC-05','EC-06'}})do
 local aa,bb=B.ends(ids);local a,b=vec(aa),vec(bb);local d=V(b.X-a.X,0,b.Z-a.Z).Unit;local normal=V(-d.Z,0,d.X)
 for _,side in ipairs({-4,4})do cases[#cases+1]={id=ids[1]..'_'..ids[2]..'_verge'..side,chapter=ids[1],main=28,epic=4,from=a-d*12+normal*side,to=b+d*12+normal*side,fixed=true}end
end
local physics=game:GetService('PhysicsService');pcall(function()physics:RegisterCollisionGroup('EpicNavigationQA')end);physics:CollisionGroupSetCollidable('EpicNavigationQA','EpicNavigationQA',false)
local rows={};local finished=0
for _,case in ipairs(cases)do
 local desc=Instance.new('HumanoidDescription');local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
 rig.Name='EpicWalk_'..case.id
 for _,part in ipairs(rig:GetDescendants())do if part:IsA('BasePart')then part.CollisionGroup='EpicNavigationQA'end end
 rig.Parent=workspace;rig:PivotTo(CFrame.new(case.from+V(0,6,0)));case.rig=rig
end
local Run=game:GetService('RunService');Run:Run();task.wait(1)
for _,case in ipairs(cases)do task.spawn(function()
 local r={id=case.id,epic=case.epic,arrived=false,stalled=false,corrections=0,jumps=0,updates=0,fixedVerge=case.fixed==true};rows[case.id]=r
 local ok,why=xpcall(function()
  local rig=case.rig;local root=rig.HumanoidRootPart;local human=rig.Humanoid
  human.WalkSpeed=case.fixed and 16 or 32;human.JumpPower=0;human.AutoJumpEnabled=false;human:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  local player={Character=rig,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
  local journal={main=case.main,expeditionMission=case.chapter}
  local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
   heroSession={getActiveHero=function()return {heroId=case.id}end},
   inventory={storyState=function()return journal end,expedition=function()return {missionId=case.chapter}end},
   combat={relocateForStoryGate=function(_,pivot)r.corrections+=1;rig:PivotTo(pivot)end},notice=function()end})
  local started=os.clock();local last=root.Position;local lastMoved=started;local lastProgress=started
  while os.clock()-started<300 do
   if flat(root.Position,case.to)<(case.fixed and 2 or 8)then r.arrived=true;break end
   local points=case.fixed and {root.Position,case.to}or Nav.route(root.Position,case.to)
   if #points<2 then r.routeFailure=tostring(root.Position);break end
   local index=2;while index<#points and flat(root.Position,points[index])<3 do index+=1 end
   human:MoveTo(points[index]);gate.update(player);r.updates+=1
   if human:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
   if flat(root.Position,last)>1 then last=root.Position;lastMoved=os.clock()end
   if os.clock()-lastMoved>10 then
    r.stalled=true;r.state=human:GetState().Name;r.nearby={}
    local o=OverlapParams.new();o.FilterType=Enum.RaycastFilterType.Include;o.FilterDescendantsInstances={world.folder};o.RespectCanCollide=true
    for _,part in ipairs(workspace:GetPartBoundsInBox(root.CFrame,V(10,8,10),o))do
     if part.Position.Y+part.Size.Y/2>root.Position.Y-1 then r.nearby[#r.nearby+1]={part=part:GetFullName(),position=tostring(part.Position),size=tostring(part.Size)}end
    end
    r.next=tostring(points[index]);break
   end
   if os.clock()-lastProgress>25 then print('EPIC_WALK_PROGRESS '..case.id..' '..math.floor(flat(root.Position,case.to)));lastProgress=os.clock()end
   task.wait(.12)
  end
  r.elapsed=os.clock()-started;r.at=tostring(root.Position);r.distance=flat(root.Position,case.to)
 end,debug.traceback)
 if not ok then r.error=why end
 case.rig:Destroy();finished+=1;print('EPIC_MAP_WALK_CASE '..game.HttpService:JSONEncode(r))
end)end
while finished<#cases do task.wait(.5)end
Run:Stop()
print('EPIC_MAP_WALK '..game.HttpService:JSONEncode(rows))
for _,r in pairs(rows)do assert(not r.error and r.arrived and not r.stalled and r.corrections==0 and r.jumps==0,'R15 walk failed '..r.id)end
return rows
