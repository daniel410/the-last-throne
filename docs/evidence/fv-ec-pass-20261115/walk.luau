local V=Vector3.new
local C=require(game.ReplicatedStorage.Shared.CampaignContent);local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local aa,bb=B.ends(C.overlandLinks[3]);local a,b=V(table.unpack(aa)),V(table.unpack(bb));local rigs={};local result={}
for i=1,2 do
 local desc=Instance.new('HumanoidDescription');local rig=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
 local start=(i==1 and a or b)+V(i==1 and 12 or -12,5,0)
 rig.Parent=workspace;rig:PivotTo(CFrame.new(start));rigs[i]=rig
end
local run=game:GetService('RunService');run:Run();task.wait(1)
local finished=0
for i,rig in rigs do task.spawn(function()
 local h=rig.Humanoid;local root=rig.HumanoidRootPart;h.WalkSpeed=32;h.JumpPower=0;h.AutoJumpEnabled=false;h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
 local target=(i==1 and b or a)+V(i==1 and 12 or -12,0,0)
 local row={arrived=false,jumps=0};result[i]=row;local start=os.clock()
 while os.clock()-start<30 do
  if (V(root.Position.X,0,root.Position.Z)-V(target.X,0,target.Z)).Magnitude<6 then row.arrived=true;break end
  h:MoveTo(target)
  if h:GetState()==Enum.HumanoidStateType.Jumping then row.jumps+=1 end
  task.wait(.12)
 end
 row.seconds=os.clock()-start;row.position=tostring(root.Position);rig:Destroy();finished+=1
end)end
while finished<2 do task.wait(.25)end
run:Stop();_G.PassWalk=result
for _,r in result do assert(r.arrived and r.jumps==0,'walk failed')end
return result
