-- Edit/FK pose review on native R15 + actual axe. Only this temporary group is replaced.
local old=workspace:FindFirstChild('TLTDwarfRecoveryReview');if old then old:Destroy()end
local clone=game.StarterPlayer.StarterPlayerScripts.Client:Clone();clone.Name='DwarfRecoveryReviewClient';clone.Parent=game.ServerStorage
local V=require(clone.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local group=Instance.new('Folder');group.Name='TLTDwarfRecoveryReview';group.Parent=workspace
local function bake(c)
 local joints,offsets={},{}
 for _,j in c:GetDescendants()do
  if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j
  elseif j:IsA('WeldConstraint')and j.Part0 and j.Part1 then offsets[j.Part1]={j.Part0,j.Part0.CFrame:ToObjectSpace(j.Part1.CFrame)}end
 end
 local memo={}
 local function frame(p)
  if memo[p]then return memo[p]end
  local j,o=joints[p],offsets[p]
  memo[p]=j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or o and frame(o[1])*o[2]or p.CFrame
  return memo[p]
 end
 for _,p in c:GetDescendants()do if p:IsA('BasePart')then frame(p)end end
 for p,cf in memo do p.Anchored=true;p.CFrame=cf end
end
local rows={{name='Idle',age=0},{name='Basic end',basic=true},{name='Overhead end',index=1},{name='Ground Slam end',index=3}}
for i,row in rows do
 local desc=Instance.new('HumanoidDescription');desc.TorsoColor=Color3.fromRGB(125,85,50);desc.RightArmColor=Color3.fromRGB(220,180,135);desc.LeftArmColor=desc.RightArmColor
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
 c.Name=row.name;c.Parent=group;c:PivotTo(CFrame.new((i-2.5)*6,15000,0)*CFrame.Angles(0,math.rad(-12),0))
 c.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 local m=Instance.new('Model');m.Name='ReviewAppearance';m.Parent=c;A.attachInto(m,c,'dwarf')
 c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
 local d=row.index and Config.Skills.dwarf[row.index]or Config.BasicAttackProfiles.dwarf.attacks[1]
 local age=row.age or d.windup+d.active+d.recovery
 c:SetAttribute('K0State',row.age and 'Idle'or'Attack');c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0SkillId',row.index and d.id or nil)
 V.renderArms(c,1/60,100+age);V.renderCharacter(c,1/60,100+age);bake(c)
 local anchor=Instance.new('Part');anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.Position=Vector3.new((i-2.5)*6,15004,0);anchor.Parent=group
 local gui=Instance.new('BillboardGui');gui.Size=UDim2.fromOffset(150,30);gui.AlwaysOnTop=true;gui.Parent=anchor
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.Text=row.name;t.TextColor3=Color3.new(1,1,1);t.BackgroundColor3=Color3.fromRGB(22,27,32);t.TextSize=18;t.Parent=gui
end
clone:Destroy()
return 'Created four native R15 review poses; temporary group only'
