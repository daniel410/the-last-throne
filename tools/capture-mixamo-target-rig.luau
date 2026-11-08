-- Authoring fixture only: capture the native rest frames used by the curve player.
local output={}
for _,rig in {Enum.HumanoidRigType.R15,Enum.HumanoidRigType.R6} do
 local desc=Instance.new('HumanoidDescription')
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 c.Parent=workspace;c:PivotTo(CFrame.identity)
 local root=c.HumanoidRootPart.CFrame
 local data={parts={},joints={}}
 for _,p in c:GetDescendants() do
  if p:IsA('BasePart') then data.parts[p.Name]={frame={root:ToObjectSpace(p.CFrame):GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z}} end
  if (p:IsA('Motor6D') or p:IsA('AnimationConstraint')) and p.Part0 and p.Part1 then
   data.joints[p.Name]={part0=p.Part0.Name,part1=p.Part1.Name,c0={p.C0:GetComponents()},c1={p.C1:GetComponents()}}
  end
 end
 output[rig.Name]=data;c:Destroy()
end
print('MIXAMO_TARGET_RIG '..game.HttpService:JSONEncode(output))
