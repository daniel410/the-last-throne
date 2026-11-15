-- Actual R15 movement along both verges in each biome, without jumping/rescue.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA required')
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local world=assert(_G.StoryPassageWorld)
local V=Vector3.new
local physics=game:GetService('PhysicsService');pcall(function()physics:RegisterCollisionGroup('PassageQA')end)
physics:CollisionGroupSetCollidable('PassageQA','PassageQA',false)
local rows,cases={},{}
for _,edge in ipairs({{'DW-01','DW-02'},{'DW-02','DW-03'},{'DW-03','DW-04'},{'GW-01','GW-02'},{'FV-02','FV-03'},{'EC-04','EC-05'},{'HG-02','HG-03'}})do
 local aa,bb=B.ends(edge);local a,b=V(table.unpack(aa)),V(table.unpack(bb))
 local unit=V(b.X-a.X,0,b.Z-a.Z).Unit;local side=V(-unit.Z,0,unit.X)
 for _,offset in ipairs({-40,40})do for _,back in ipairs({false,true})do
  local sections=require(game.ReplicatedStorage.Shared.CampaignPassage).create(C.zones[edge[1]],C.zones[edge[2]]).sections
  local start,finish
  for i=2,#sections do local l,r=sections[i-1],sections[i]
   if offset>=l.side and offset<=r.side then
    local t=(offset-l.side)/(r.side-l.side)
    start=V(table.unpack(l.first)):Lerp(V(table.unpack(r.first)),t)-unit*8
    finish=V(table.unpack(l.last)):Lerp(V(table.unpack(r.last)),t)+unit*8
    break
   end
  end
  assert(start and finish)
  if back then start,finish=finish,start end
  local desc=Instance.new('HumanoidDescription');local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
  rig.Name='PassageWalk_'..#cases
  for _,p in rig:GetDescendants()do if p:IsA('BasePart')then p.CollisionGroup='PassageQA'end end
  rig.Parent=workspace;rig:PivotTo(CFrame.new(start+V(0,5,0)))
  table.insert(cases,{id=edge[1]..'_'..edge[2]..'_'..offset..'_'..tostring(back),rig=rig,to=finish})
 end end
end
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local done=0
for _,case in ipairs(cases)do task.spawn(function()
 local r={id=case.id,corrections=0,jumps=0,arrived=false};table.insert(rows,r)
 local ok,why=xpcall(function()
  local rig=case.rig;local root=rig.HumanoidRootPart;local human=rig.Humanoid
  human.WalkSpeed=24;human.JumpPower=0;human.AutoJumpEnabled=false;human:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  local player={Character=rig,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end}
  local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,
   heroSession={getActiveHero=function()return {heroId=case.id}end},
   inventory={storyState=function()return {main=35,expeditionMission='DW-02'}end,expedition=function()return {missionId='DW-02'}end},
   combat={relocateForStoryGate=function(_,cf)r.corrections+=1;rig:PivotTo(cf)end},notice=function()end})
  local started=os.clock();local last=root.Position;local moved=started
  while os.clock()-started<30 do
   if V(root.Position.X-case.to.X,0,root.Position.Z-case.to.Z).Magnitude<3 then r.arrived=true;break end
   human:MoveTo(case.to);gate.update(player)
   if human:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
   if (root.Position-last).Magnitude>1 then last=root.Position;moved=os.clock()end
   if os.clock()-moved>5 then r.stalled=true;break end
   task.wait(.1)
  end
  r.position=tostring(root.Position);r.elapsed=os.clock()-started
  r.floor=B.surface(root.Position.X,root.Position.Z)
  if not r.arrived then
   r.contacts={};local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.folder};params.RespectCanCollide=true
   for _,p in workspace:GetPartBoundsInBox(CFrame.new(root.Position+V(0,1,0)),V(5,4,5),params)do table.insert(r.contacts,p:GetFullName())end
   local cast=RaycastParams.new();cast.RespectCanCollide=true;cast.FilterType=Enum.RaycastFilterType.Include;cast.FilterDescendantsInstances={world.folder,workspace.Terrain}
   local aim=V(case.to.X-root.Position.X,0,case.to.Z-root.Position.Z)
   local hit=workspace:Blockcast(root.CFrame,V(2,2,1),aim.Unit*4,cast)
   r.blocker=hit and hit.Instance:GetFullName()
  end
  gate.remove(player)
 end,debug.traceback)
 if not ok then r.error=why end
 case.rig:Destroy();done+=1
end)end
while done<#cases do task.wait(.5)end
Run:Stop()
print('STORY_PASSAGE_WALK '..game.HttpService:JSONEncode(rows))
for _,r in ipairs(rows)do assert(not r.error and r.arrived and not r.stalled and r.corrections==0 and r.jumps==0,'passage walk failed '..r.id)end
return rows
