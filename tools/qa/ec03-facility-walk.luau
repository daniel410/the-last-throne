-- Physical fixture audit, not player/HUD/quest acceptance. Run only in isolated QA.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated QA required')
local world = assert(_G.AccessWorld, 'load EC-03 access fixture first')
assert(_G.AccessStatus.ok)
local mine = world.folder.EpicWorldArt.EpicWorldArt_4['EC-03'].RegionalConcept.BracedMineHead
local a = mine:GetPivot():PointToWorldSpace(Vector3.new(0,0,12))
local b = assert(mine:GetAttribute('ApproachPosition'))
local function flat(v) return Vector3.new(v.X,0,v.Z) end
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = {workspace.Terrain, world.terrain}
ray.RespectCanCollide = true
local samples = {}
local side = flat(b-a).Unit:Cross(Vector3.yAxis)
for lane = -1,1 do
 for i = 0,400 do
  local p = a:Lerp(b,i/400) + side*lane*3
  local h = workspace:Raycast(p+Vector3.new(0,20,0),Vector3.new(0,-80,0),ray)
  samples[#samples+1] = {lane=lane,index=i,x=p.X,z=p.Z,y=h and h.Position.Y,surface=h and h.Instance.Name}
 end
end
local Physics = game:GetService('PhysicsService')
pcall(function() Physics:RegisterCollisionGroup('MineWalkQA') end)
Physics:CollisionGroupSetCollidable('MineWalkQA','MineWalkQA',false)
local cases = {}
for _,back in ipairs({false,true}) do
 local desc = Instance.new('HumanoidDescription')
 local rig = game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15)
 desc:Destroy()
 for _,p in ipairs(rig:GetDescendants()) do if p:IsA('BasePart') then p.CollisionGroup='MineWalkQA' end end
 local from,to = back and b or a, back and a or b
 rig.Name = back and 'MineReturnQA' or 'MineOutboundQA'
 rig.Parent=workspace
 rig:PivotTo(CFrame.new(from+Vector3.new(0,6,0)))
 cases[#cases+1]={rig=rig,from=from,to=to,id=rig.Name}
end
_G.MineWalkAudit={mode='Run R15 fixture',samples=samples,cases={},complete=false}
local Run=game:GetService('RunService')
Run:Run()
task.wait(1)
local done=0
for _,c in ipairs(cases) do task.spawn(function()
 local row={id=c.id,jumps=0,arrived=false,trace={}}
 _G.MineWalkAudit.cases[c.id]=row
 local ok,err=xpcall(function()
  local h=c.rig.Humanoid;local root=c.rig.HumanoidRootPart
  h.WalkSpeed=16;h.AutoJumpEnabled=false;h.JumpPower=0
  h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  local start=os.clock();local last=root.Position;local moved=start
  while os.clock()-start<40 do
   local pos=root.Position;local distance=flat(pos-c.to).Magnitude
   row.trace[#row.trace+1]={t=os.clock()-start,x=pos.X,y=pos.Y,z=pos.Z,distance=distance}
   if distance<3 then row.arrived=true;break end
   h:MoveTo(c.to)
   if h:GetState()==Enum.HumanoidStateType.Jumping then row.jumps+=1 end
   if flat(pos-last).Magnitude>1 then last=pos;moved=os.clock() end
   if os.clock()-moved>6 then row.stalled=true;break end
   task.wait(.25)
  end
  row.elapsed=os.clock()-start;row.distance=flat(root.Position-c.to).Magnitude
 end,debug.traceback)
 if not ok then row.error=err end
 c.rig:Destroy();done+=1
end) end
while done<#cases do task.wait(.25) end
for _,row in pairs(_G.MineWalkAudit.cases) do
 assert(not row.error and row.arrived and not row.stalled and row.jumps==0, 'facility walk failed: '..row.id)
end
_G.MineWalkAudit.complete=true
return {complete=true,cases=_G.MineWalkAudit.cases,sampleCount=#samples}
