-- Regression: the thin cutting edge leads at server contact, not the broad face.
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeMotion)
local C=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='AXE_CUTTING_EDGE_NATIVE',checks=0,failures={},samples={}}
local function check(v,label)report.checks+=1;assert(v,label)end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 local character
 local ok,err=xpcall(function()
  local desc=Instance.new('HumanoidDescription');character=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
  local m=Instance.new('Model');m.Parent=character;local w=assert(A.attachInto(m,character,'dwarf'))
  check(m:GetAttribute('WeaponSourceKey')=='td:v2:Embercleaver:forward2','stale sideways visual is invalidated')
  local edge=assert(w.grip:FindFirstChild('AxeCuttingEdge'));local direction=assert(w.grip:FindFirstChild('AxeCuttingDirection'));local face=assert(w.grip:FindFirstChild('AxeFaceNormal'))
  check(math.abs(direction.Position:Dot(face.Position))<.0001,'reviewed cutting direction is in the blade plane')
  local part=m.Weapon;check(math.abs(w.grip.CFrame:ToObjectSpace(part.CFrame).LookVector:Dot(face.Position))>.999,'face marker matches actual mesh thickness axis')
  local root=character.HumanoidRootPart;local original=root.CFrame;local joints={}
  for _,j in ipairs(character:GetDescendants())do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
  local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
  local function sample(age,dt)V.renderArms(character,dt,100+age);V.renderCharacter(character,dt,100+age);return frame(w.grip)end
  for _,definition in ipairs({C.BasicAttackProfiles.dwarf.attacks[1],C.Skills.dwarf[1],C.Skills.dwarf[3]})do
   character:SetAttribute('K0State','Dodge');Motion.forCharacter(character,99)
   character:SetAttribute('K0ClassId','dwarf');character:SetAttribute('K0Combo',1);character:SetAttribute('K0State','Attack');character:SetAttribute('K0AttackStartedAt',100);character:SetAttribute('K0SkillId',definition.id)
   local impact=definition.windup+(definition.hitDelay or 0)
   for _,dt in ipairs({1/30,1/144})do for _,delta in ipairs({-.005,0,.005})do
    local t=impact+delta;local before,after,at=sample(t-.0005,dt),sample(t+.0005,dt),sample(t,dt)
    local velocity=(after:PointToWorldSpace(edge.Position)-before:PointToWorldSpace(edge.Position)).Unit
    local edgeDot=at:VectorToWorldSpace(direction.Position).Unit:Dot(velocity)
    local faceDot=math.abs(at:VectorToWorldSpace(face.Position).Unit:Dot(velocity))
    check(edgeDot>.9,'cutting edge leads rather than striking with the back')
    check(faceDot<.35,'broad flat face is not presented along attack travel')
    check(root.CFrame==original,'edge correction never changes server hit origin')
    check((frame(w.joint.Part0)*w.joint.C0).Position:FuzzyEq(at.Position,.0001),'grip remains in palm')
    table.insert(report.samples,{rig=rig.Name,skill=definition.id or 'basic',time=t,dt=dt,edgeDot=edgeDot,faceDot=faceDot})
   end end
  end
 end,debug.traceback)
 if not ok then table.insert(report.failures,rig.Name..': '..tostring(err))end
 if character then character:Destroy()end
end
report.pass=#report.failures==0;print('AXE_CUTTING_EDGE_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Axe edge alignment failed')
