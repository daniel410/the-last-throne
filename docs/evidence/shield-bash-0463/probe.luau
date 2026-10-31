local Players=game.Players;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Visual=require(Client.K0SwordVisual);local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local result={before={},candidates={}}
for _,type in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 local d=Instance.new('HumanoidDescription');local c=Players:CreateHumanoidModelFromDescriptionAsync(d,type);d:Destroy();c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
 local model=Instance.new('Model');model.Parent=c;local sword=assert(A.attachInto(model,c,'knight'));local shield=assert(A.attachShieldInto(model,c))
 local root=c.HumanoidRootPart;local joints={};for _,j in ipairs(c:GetDescendants())do if (j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
 local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
 local swordOffset=sword.grip.CFrame:ToObjectSpace(sword.trailPart.CFrame);local shieldOffset=shield.joint.Part0.CFrame:ToObjectSpace(shield.shield.CFrame)
 local function reach(cf,size)local top=-math.huge;for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do top=math.max(top,-root.CFrame:PointToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)).Z)end end end;return top end
 local function measure()
  local sh=frame(shield.joint.Part0)*shieldOffset;local blade=frame(sword.grip)*swordOffset
  return {rig=type.Name,gap=reach(sh,shield.shield.Size)-reach(blade,sword.trailPart.Size),shield=reach(sh,shield.shield.Size),sword=reach(blade,sword.trailPart.Size),faceDot=sh.LookVector:Dot(root.CFrame.LookVector)}
 end
 c:SetAttribute('K0ClassId','knight');c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackKind','Basic');c:SetAttribute('K0SkillId','knight.common.bash');c:SetAttribute('K0AttackPhase','Active')
 for _=1,30 do Visual.renderArms(c,1/60,100);Visual.renderCharacter(c,1/60,100)end
 table.insert(result.before,measure())
 local function pose(j,cf)if j then local b=j.C0.Rotation;j.Transform=b:Inverse()*cf*b end end
 local function joint(side,name)return c:FindFirstChild(side..name,true)or c:FindFirstChild(side..' '..name,true)end
 for _,pitch in ipairs({70,90,110})do for _,yaw in ipairs({-100,-90,-80})do for _,elbow in ipairs({0,20,45})do
  pose(joint('Left','Shoulder'),CFrame.new(0,.05,-.45)*CFrame.Angles(0,math.rad(yaw),0)*CFrame.Angles(math.rad(pitch),0,0))
  pose(joint('Right','Shoulder'),CFrame.Angles(0,math.rad(30),0)*CFrame.Angles(math.rad(-12),0,math.rad(-18)))
  pose(joint('Left','Elbow'),CFrame.Angles(math.rad(elbow),0,0));pose(joint('Right','Elbow'),CFrame.Angles(math.rad(15),0,0));sword.joint.Transform=CFrame.Angles(math.rad(30),0,0)
  local torso=c:FindFirstChild('Waist',true)or root:FindFirstChild('RootJoint');pose(torso,CFrame.new(0,0,-.2)*CFrame.Angles(math.rad(-8),math.rad(12),0))
  local v=measure();v.pitch=pitch;v.yaw=yaw;v.elbow=elbow;table.insert(result.candidates,v)
 end end end
 c:Destroy()
end
print('SHIELD_BASH_PROBE '..game.HttpService:JSONEncode(result))
