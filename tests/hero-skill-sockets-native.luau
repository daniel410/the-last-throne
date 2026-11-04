-- Native visual contact invariants found during individual Studio review.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"isolated Edit fixture required")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Visual=require(Client.K0SwordVisual)
local Effects=require(Client.AdvancedSkillVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local A=require(game.ReplicatedStorage.Shared.AdvancedSkills)
local report={kind="HERO_SKILL_SOCKETS_NATIVE",checks=0,failures={},samples={}}
local function check(v,label)report.checks+=1;assert(v,label)end
local function fk(c)
 local joints,offsets={},{}
 for _,j in ipairs(c:GetDescendants())do
  if (j:IsA("Motor6D")or j:IsA("AnimationConstraint"))and j.Part0 and j.Part1 then joints[j.Part1]=j
  elseif j:IsA("WeldConstraint")and j.Part0 and j.Part1 then offsets[j.Part1]={p=j.Part0,cf=j.Part0.CFrame:ToObjectSpace(j.Part1.CFrame)}end
 end
 local memo={}
 local function frame(p)
  if memo[p]then return memo[p]end
  local j,o=joints[p],offsets[p]
  local cf=j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or o and frame(o.p)*o.cf or p.CFrame
  memo[p]=cf;return cf
 end
 for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then frame(p)end end
 for p,cf in pairs(memo)do p.Anchored=true;p.CFrame=cf end
end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 for _,classId in ipairs({"knight","dwarf"})do
  local c
  local ok,err=xpcall(function()
   local desc=Instance.new("HumanoidDescription");c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
   c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
   local m=Instance.new("Model");m.Parent=c;local w=assert(Appearance.attachInto(m,c,classId))
   local d=classId=="knight" and A.common.knight[1] or A.branches.gunner.skills[1]
   c:SetAttribute("K0ClassId",classId);c:SetAttribute("K0State","Attack");c:SetAttribute("K0SkillId",d.id)
   c:SetAttribute("K0AttackPhase","Active");c:SetAttribute("K0AttackStartedAt",100);c:SetAttribute("K0AttackSeq",7);c:SetAttribute("K0AttackKind","Basic");c:SetAttribute("K0Combo",1)
   Visual.renderArms(c,1/60,100+d.windup);fk(c)
   Visual.renderCharacter(c,1/60,100+d.windup);fk(c)
   local forward=c.HumanoidRootPart.CFrame.LookVector
   if classId=="knight"then
    local dot=w.grip.CFrame.UpVector:Dot(forward)
    local height=w.tip.WorldPosition.Y-c.HumanoidRootPart.Position.Y
    check(dot>.97,"Driving Thrust blade must point forward at contact")
    check(height>-.5 and height<2,"Driving Thrust stays above the feet")
    table.insert(report.samples,{rig=rig.Name,id=d.id,forwardDot=dot,tipHeight=height})
   else
    Effects.play(c,d.id,c.HumanoidRootPart.Position,c.HumanoidRootPart.Position+forward*20,0,nil,7)
    local prop=assert(c:FindFirstChild("BranchSkillProp"));local barrel=assert(prop:FindFirstChild("Barrel"))
    local dot=barrel.CFrame.RightVector:Dot(forward)
    check(dot>.97,"Rifle bore must face forward at firing, before recoil")
    check(barrel.SkillMuzzle.Position.X>0,"Muzzle is on the cylinder bore axis")
    table.insert(report.samples,{rig=rig.Name,id=d.id,forwardDot=dot})
    c:SetAttribute("K0State","Dodge");task.wait()
    check(c:FindFirstChild("BranchSkillProp")==nil,"Cancel removes gun")
    check(m.Weapon.LocalTransparencyModifier==0,"Cancel restores axe")
   end
  end,debug.traceback)
  if c then c:Destroy()end
  if not ok then table.insert(report.failures,rig.Name.."/"..classId..": "..tostring(err))end
 end
end
report.pass=#report.failures==0
print("HERO_SKILL_SOCKETS_NATIVE "..game.HttpService:JSONEncode(report))
return report
