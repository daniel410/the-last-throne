-- Real TD sword/shield geometry, R6/R15 forward kinematics, accepted time.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Unpublished native fixture required')
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local C=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='SHIELD_BASH_LEADING_NATIVE',checks=0,failures={},samples={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
  local desc=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy();c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
  local model=Instance.new('Model');model.Parent=c;local sword=assert(A.attachInto(model,c,'knight'));local shield=assert(A.attachShieldInto(model,c))
  local root=c.HumanoidRootPart;local rootBefore=root.CFrame;local joints={}
  for _,j in ipairs(c:GetDescendants())do if (j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
  local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
  local swordOffset=sword.grip.CFrame:ToObjectSpace(sword.trailPart.CFrame);local shieldOffset=shield.joint.Part0.CFrame:ToObjectSpace(shield.shield.CFrame)
  local function reach(cf,size)local top=-math.huge;for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do top=math.max(top,-root.CFrame:PointToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)).Z)end end end;return top end
  c:SetAttribute('K0ClassId','knight');c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackKind','Basic');c:SetAttribute('K0SkillId','knight.common.bash');c:SetAttribute('K0AttackStartedAt',1000)
  for _,dt in ipairs({1/30,1/144})do
   for _,age in ipairs({.195,.2,.25,.299})do
    c:SetAttribute('K0AttackPhase',age<.2 and 'Windup' or 'Active')
    Visual.renderArms(c,dt,1000+age);Visual.renderCharacter(c,dt,1000+age)
    local sh=frame(shield.joint.Part0)*shieldOffset;local blade=frame(sword.grip)*swordOffset
    local gap=reach(sh,shield.shield.Size)-reach(blade,sword.trailPart.Size);local face=sh.LookVector:Dot(root.CFrame.LookVector)
    check(gap>.5,'shield leads entire real sword bounds by at least .5stud at contact: '..rig.Name..' '..gap)
    check(face>.9,'shield face points toward target: '..rig.Name..' '..face)
    check(root.CFrame==rootBefore,'pose cannot move authoritative root')
    check((frame(sword.joint.Part0)*sword.joint.C0* sword.joint.Transform).Position:FuzzyEq((frame(sword.grip)*sword.joint.C1).Position,.0001),'sword remains in hand socket')
    check(model:GetAttribute('ShieldSourceKey')=='td:SwordsmanShield' and model:GetAttribute('WeaponSourceKey')=='td:v2:AzureOathblade','source meshes retained')
    table.insert(report.samples,{rig=rig.Name,age=age,dt=dt,gap=gap,faceDot=face})
   end
  end
  c:SetAttribute('K0State','Idle');c:SetAttribute('K0AttackPhase','None')
  for i=1,30 do Visual.renderArms(c,1/60,1001+i/60);Visual.renderCharacter(c,1/60,1001+i/60)end
  for _,name in ipairs({'LeftShoulder','Left Shoulder','RightShoulder','Right Shoulder'})do local j=c:FindFirstChild(name,true);if j then local _,angle=j.Transform:ToAxisAngle();check(j.Transform.Position.Magnitude<.0001 and math.abs(angle)<.0001,'arms settle after skill')end end
  check(C.Skills.knight[1].stunDuration==5 and C.Skills.knight[1].windup==.2,'stun and hit timing stay unchanged')
  c:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
report.pass=#report.failures==0;print('SHIELD_BASH_LEADING_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Shield-first contact failed')
