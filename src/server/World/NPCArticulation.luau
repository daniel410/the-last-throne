-- Rest-space groups retain the original block art and authoritative actor root.
local A={}
local rightProps={HammerHandle=true,HammerHead=true,LanternHandle=true,LanternFrame=true,LanternGlass=true,
 HealingStaff=true,StaffCrystal=true,KeyRing=true,KeyShaft=true,KeyTeeth=true,Record=true,RecordBand=true,
 ToolHandle=true,ToolHead=true,SoupCup=true}
function A.prepare(model,c,width)
 model:SetAttribute('NPCMotionProp',c.prop)
 model:SetAttribute('NPCMotionWidth',width)
 local carry,carryCenter
 if c.prop=='crown' then
  carry=require(game.ReplicatedStorage.Shared.NPCMotion).pose(0,0,0,1,width,'crown',0)
  local left=carry.HandL:PointToWorldSpace(Vector3.new(-1.49*width,1.94,-.06))
  local right=carry.HandR:PointToWorldSpace(Vector3.new(1.49*width,1.94,-.06))
  carryCenter=(left+right)/2
 end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA('BasePart') and p~=model.PrimaryPart then
   local name=p.Name;local side=p.Position.X<0 and 'L' or 'R';local group='Body'
   if p:IsDescendantOf(model.FaceRig) then group='Head'
   elseif name=='UpperArm' or name=='ShoulderTrim' then group='Arm'..side
   elseif name=='LowerArm' then group='Forearm'..side
   elseif name=='Cuff' or name=='Hand' then group='Hand'..side
   elseif name=='UpperLeg' then group='Thigh'..side
   elseif name=='LowerLeg' then group='Shin'..side
   elseif name=='Boot' then group='Foot'..side
   elseif rightProps[name] then
    group='HandR';p.CFrame+=Vector3.new((1.49-1.7)*width,0,0)
    if name=='HealingStaff' or name=='StaffCrystal' then p.CFrame+=Vector3.new(-.13*width,0,0) end
    if name:find('Lantern') or name:find('Key') or name:find('Record') or name=='SoupCup' then p.CFrame+=Vector3.new(.1*width,0,0) end
   elseif name=='BowLimb' or name=='BowString' then group='HandL'
   elseif name=='ToyCrownBand' or name=='ToyCrownPoint' then
    group='HandR'
    p.CFrame=carry.HandR:Inverse()*CFrame.new(carryCenter-Vector3.new(0,3.2,-.77))*p.CFrame
   end
   p:SetAttribute('NPCMotionGroup',group)
  end
 end
end
function A.capture(model)
 local root=model.PrimaryPart
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA('BasePart') and p~=root then p:SetAttribute('NPCMotionRest',root.CFrame:ToObjectSpace(p.CFrame)) end
 end
 model:SetAttribute('NPCArticulated',true)
 model:SetAttribute('NPCMotionVersion',1)
end
return A
