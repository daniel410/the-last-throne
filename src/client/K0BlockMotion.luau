-- Presentation-only two-hand weapon guards. Server guard rules are unchanged.
local Motion = {}
local profiles = {
 dwarf = {side="Right", point=Vector3.new(.6,1.15,-1.25), axis=Vector3.new(-1,.10,0).Unit, spacing=1.2},
 mage = {side="Right", point=Vector3.new(.6,1.15,-1.25), axis=Vector3.new(-1,.18,0).Unit, spacing=1.2},
 elf = {side="Left", point=Vector3.new(-.6,1.15,-1.25), axis=Vector3.new(1,.12,0).Unit, spacing=1.2},
}
local function joint(character,side,name)
 local value=character:FindFirstChild(side..name,true)or character:FindFirstChild(side.." "..name,true)
 return value and(value:IsA("Motor6D")or value:IsA("AnimationConstraint"))and value or nil
end
local function align(from,to)
 if from.Magnitude<1e-7 or to.Magnitude<1e-7 then return CFrame.identity end
 local a,b=from.Unit,to.Unit
 local axis=a:Cross(b);local dot=math.clamp(a:Dot(b),-1,1)
 if axis.Magnitude>1e-7 then return CFrame.fromAxisAngle(axis.Unit,math.acos(dot))end
 if dot<0 then
  axis=a:Cross(Vector3.xAxis)
  if axis.Magnitude<1e-7 then axis=a:Cross(Vector3.zAxis)end
  return CFrame.fromAxisAngle(axis.Unit,math.pi)
 end
 return CFrame.identity
end
local function basis(direction,normal)
 local y=direction.Unit
 local x=normal-y*normal:Dot(y)
 if x.Magnitude<1e-7 then x=y:Cross(Vector3.zAxis)end
 if x.Magnitude<1e-7 then x=y:Cross(Vector3.xAxis)end
 x=x.Unit
 return CFrame.fromMatrix(Vector3.zero,x,y,x:Cross(y))
end
local function worldFrames(character)
 local parents={};local memo={}
 for _,node in character:GetDescendants()do
  if(node:IsA("Motor6D")or node:IsA("AnimationConstraint"))and node.Part0 and node.Part1 then parents[node.Part1]=node end
 end
 local function frame(part)
  if memo[part]then return memo[part]end
  local j=parents[part]
  local result=j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or part.CFrame
  memo[part]=result
  return result
 end
 return frame
end
local function arm(character,side,palm,r15,frame)
 local shoulder=joint(character,side,"Shoulder")
 local hand=character:FindFirstChild(side..(r15 and"Hand"or" Arm"))
 if not shoulder or not shoulder.Part0 or not hand then return nil end
 local value={shoulder=shoulder,hand=hand,palm=palm,base=frame(shoulder.Part0)*shoulder.C0}
 if r15 then
  value.elbow=joint(character,side,"Elbow");value.wrist=joint(character,side,"Wrist")
  if not value.elbow or not value.wrist then return nil end
  -- These vectors run from joint pivots, not part centres. Native C0/C1
  -- offsets preserve lengths on scaled R15 bodies and different hand sizes.
  value.upper=shoulder.C1:PointToObjectSpace(value.elbow.C0.Position)
  local lowerContact=(value.wrist.C0*value.wrist.C1:Inverse()):PointToWorldSpace(palm)
  value.lower=value.elbow.C1:PointToObjectSpace(lowerContact)
  value.length=value.upper.Magnitude+value.lower.Magnitude
 else
  value.reach=shoulder.C1:PointToObjectSpace(palm)
  value.length=value.reach.Magnitude
 end
 return value
end
local function solveRigid(a,point,poses)
 local desired=a.base:VectorToObjectSpace(point-a.base.Position)
 local rotation=align(a.reach,desired)
 poses[a.shoulder]=rotation
 return a.base*rotation*a.shoulder.C1:Inverse()
end
local function solveBent(a,point,pole,poses)
 local offset=point-a.base.Position
 local distance=math.clamp(offset.Magnitude,math.abs(a.upper.Magnitude-a.lower.Magnitude)+.0001,a.length-.0001)
 local direction=offset.Magnitude>.0001 and offset.Unit or Vector3.new(0,0,-1)
 local along=(a.upper.Magnitude^2-a.lower.Magnitude^2+distance^2)/(2*distance)
 local height=math.sqrt(math.max(0,a.upper.Magnitude^2-along^2))
 local bend=pole-a.base.Position
 bend-=direction*bend:Dot(direction)
 if bend.Magnitude<.0001 then bend=direction:Cross(a.base.RightVector)end
 local elbowPosition=a.base.Position+direction*along+bend.Unit*height
 local upperDirection=(elbowPosition-a.base.Position).Unit
 local lowerDirection=(point-elbowPosition).Unit
 local normal=upperDirection:Cross(lowerDirection)
 if normal.Magnitude<.0001 then normal=a.base.RightVector end
 local elbowBasis=a.shoulder.C1:Inverse()*a.elbow.C0
 local localHinge=elbowBasis.RightVector
 local wanted=basis(a.base:VectorToObjectSpace(upperDirection),a.base:VectorToObjectSpace(normal))
 local original=basis(a.upper,localHinge)
 local shoulderRotation=wanted*original:Inverse()
 local upperFrame=a.base*shoulderRotation*a.shoulder.C1:Inverse()
 local elbowFrame=upperFrame*a.elbow.C0
 local elbowRotation=align(a.lower,elbowFrame:VectorToObjectSpace(point-elbowPosition))
 local lowerFrame=elbowFrame*elbowRotation*a.elbow.C1:Inverse()
 local handFrame=lowerFrame*a.wrist.C0*a.wrist.C1:Inverse()
 poses[a.shoulder]=shoulderRotation.Rotation
 poses[a.elbow]=elbowRotation.Rotation
 poses[a.wrist]=CFrame.identity
 return handFrame
end
local function sharedRigidPoint(a,b,shift,ideal)
 -- Intersect the two rigid-arm reach spheres. The secondary hand is offset
 -- along the held shaft, so both unscaled arms keep their original lengths.
 local first=a.base.Position
 local second=b.base.Position-shift
 local delta=second-first
 local distance=delta.Magnitude
 if distance<.0001 then
  local direction=ideal-first
  return first+(direction.Magnitude>.0001 and direction.Unit or Vector3.new(0,0,-1))*a.length
 end
 local direction=delta.Unit
 local along=(a.length*a.length-b.length*b.length+distance*distance)/(2*distance)
 along=math.clamp(along,-a.length,a.length)
 local center=first+direction*along
 local radius=math.sqrt(math.max(0,a.length*a.length-along*along))
 local toward=ideal-center;toward-=direction*toward:Dot(direction)
 if toward.Magnitude<.0001 then toward=direction:Cross(Vector3.yAxis)end
 if toward.Magnitude<.0001 then toward=direction:Cross(Vector3.zAxis)end
 return center+toward.Unit*radius
end

function Motion.solve(character,classId,model)
 local profile=profiles[classId]
 if not profile or not character or not model then return nil end
 local root=character:FindFirstChild("HumanoidRootPart")
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 local grip=model:FindFirstChild("WeaponGrip")
 local weaponJoint=grip and grip:FindFirstChild("PlayerWeaponJoint")
 if not root or not humanoid or not grip or not grip:IsA("BasePart")or not weaponJoint or not weaponJoint:IsA("Motor6D")or not weaponJoint.Part0 or weaponJoint.Part1~=grip then return nil end
 local r15=humanoid.RigType==Enum.HumanoidRigType.R15
 local other=profile.side=="Left"and"Right"or"Left"
 local secondaryHand=character:FindFirstChild(other..(r15 and"Hand"or" Arm"))
 if not secondaryHand then return nil end
 local secondaryPalm=Vector3.new(0,r15 and-.12 or-secondaryHand.Size.Y*.5,-secondaryHand.Size.Z*.5)
 local frame=worldFrames(character)
 local primary=arm(character,profile.side,weaponJoint.C0.Position,r15,frame)
 local secondary=arm(character,other,secondaryPalm,r15,frame)
 if not primary or not secondary or primary.hand~=weaponJoint.Part0 then return nil end
 local axis=root.CFrame:VectorToWorldSpace(profile.axis)
 local shift=axis*profile.spacing
 local point=root.CFrame:PointToWorldSpace(profile.point)
 if not r15 then point=sharedRigidPoint(primary,secondary,shift,point)
 else
  -- Keep ordinary body-scale variation within both arm reach balls. This is
  -- bounded vector projection, not a frame-integrated or iterative IK solver.
  for _=1,2 do
   for _,entry in {{primary,Vector3.zero},{secondary,shift}}do
    local center=entry[1].base.Position-entry[2]
    local offset=point-center;local limit=entry[1].length-.025
    if offset.Magnitude>limit then point=center+offset.Unit*limit end
   end
  end
 end
 local poses={};local primaryFrame
 if r15 then
  local sign=profile.side=="Left"and-1 or 1
  primaryFrame=solveBent(primary,point,root.CFrame:PointToWorldSpace(Vector3.new(sign*1.5,0,-.4)),poses)
  solveBent(secondary,point+shift,root.CFrame:PointToWorldSpace(Vector3.new(-sign*1.5,0,-.4)),poses)
 else
  primaryFrame=solveRigid(primary,point,poses);solveRigid(secondary,point+shift,poses)
 end
 local back=root.CFrame.ZVector-axis*root.CFrame.ZVector:Dot(axis)
 back=back.Unit
 local desired=CFrame.fromMatrix(point,axis:Cross(back).Unit,axis,back)
 local weapon=(primaryFrame*weaponJoint.C0):Inverse()*desired*weaponJoint.C1
 local target=grip:FindFirstChild("K0BlockHandTarget")
 if target and not target:IsA("Attachment")then return nil end
 if not target then target=Instance.new("Attachment");target.Name="K0BlockHandTarget";target.Parent=grip end
 target.Position=Vector3.new(0,profile.spacing,0)
 return {joints=poses,weaponJoint=weaponJoint,weapon=weapon.Rotation,target=target,
  primarySide=profile.side,secondarySide=other,primaryPoint=point,secondaryPoint=point+shift,shaftAxis=axis,spacing=profile.spacing}
end

return Motion
