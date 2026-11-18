assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local Physics = game:GetService('PhysicsService')
pcall(function() Physics:RegisterCollisionGroup('TerraceWalkQA') end)
Physics:CollisionGroupSetCollidable('TerraceWalkQA','TerraceWalkQA',false)
local cases = {}
local a=Vector3.new(390,188,-17444)
local b=Vector3.new(390,206.05,-17498)
local function flat(v)return Vector3.new(v.X,0,v.Z)end
local samples={}
for _,x in ipairs({150,270,390})do
 a=Vector3.new(x,188,-17444);b=Vector3.new(x,206.05,-17498)
 for _,back in ipairs({false,true}) do
 local desc = Instance.new('HumanoidDescription')
 local rig = game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15)
 desc:Destroy()
 for _,p in ipairs(rig:GetDescendants()) do if p:IsA('BasePart') then p.CollisionGroup='TerraceWalkQA' end end
 local from,to = back and b or a, back and a or b
 rig.Name = (back and 'TerraceReturnQA' or 'TerraceOutboundQA')..x
 rig.Parent=workspace
 rig:PivotTo(CFrame.new(from+Vector3.new(0,6,0)))
 cases[#cases+1]={rig=rig,from=from,to=to,id=rig.Name}
end
_G.TerraceWalkAudit={mode='Run R15 fixture',samples=samples,cases={},complete=false}
end
local Run=game:GetService('RunService')
Run:Run()
task.wait(1)
local done=0
for _,c in ipairs(cases) do task.spawn(function()
 local row={id=c.id,jumps=0,arrived=false,trace={}}
 _G.TerraceWalkAudit.cases[c.id]=row
 local ok,err=xpcall(function()
  local h=c.rig.Humanoid;local root=c.rig.HumanoidRootPart
  h.WalkSpeed=16;h.AutoJumpEnabled=false;h.JumpPower=0
  h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  local start=os.clock();local last=root.Position;local moved=start
  while os.clock()-start<40 do
   local pos=root.Position;local distance=flat(pos-c.to).Magnitude
   row.trace[#row.trace+1]={t=os.clock()-start,x=pos.X,y=pos.Y,z=pos.Z,distance=distance}
   if distance<3 and math.abs(pos.Y-c.to.Y-3)<4 then row.arrived=true;break end
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

_G.TerraceWalkAudit.complete=true
return {complete=true,cases=_G.TerraceWalkAudit.cases,sampleCount=#samples}
