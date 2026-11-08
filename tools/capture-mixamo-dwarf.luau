local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.K0SwordVisual)
local M=require(Client.K0MeleeMotion)
local Advanced=require(Client.AdvancedSkillMotion)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={clips={},edges={}}
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(Instance.new('HumanoidDescription'),Enum.HumanoidRigType.R15)
c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
local model=Instance.new('Model');model.Parent=c;local w=assert(A.attachInto(model,c,'dwarf'))
local joints={};for _,j in c:GetDescendants()do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
local edge=w.grip.AxeCuttingEdge.Position
local dir=w.grip.AxeCuttingDirection.Position.Unit;local face=w.grip.AxeFaceNormal.Position.Unit
local offset=w.grip.CFrame:ToObjectSpace(model.Weapon.CFrame)
c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
for _,key in {'basic','dwarf.common.overhead','dwarf.common.ground','dwarf_hooking_chop','dwarf_low_sweep','dwarf.common.throw'}do
 local d=Config.BasicAttackProfiles.dwarf.attacks[1]
 for _,s in Config.Skills.dwarf do if s.id==key then d=s end end
 c:SetAttribute('K0State','Dodge');M.forCharacter(c,99);Advanced.forCharacter(c,99)
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0SkillStartedAt',100);c:SetAttribute('K0SkillId',d.id)
 local duration=d.windup+d.active+d.recovery;local contact=d.windup+(d.hitDelay or 0)
 local function sample(t)
  V.renderArms(c,1/60,100+t);V.render(model,'Active',1,1/60,'Melee',100+t)
  -- Edit-time Humanoids report Air. Evaluate the grounded leg branch explicitly
  -- for this FK capture; live walking/airborne masks remain unchanged.
  local p=Advanced.forCharacter(c,100+t)or M.forCharacter(c,100+t)
  if p then for _,side in {'Right','Left'}do
   local hip=c:FindFirstChild(side..'Hip',true);local knee=c:FindFirstChild(side..'Knee',true)
   local prefix=side=='Right'and'right'or'left'
   local basis=hip.C0.Rotation;hip.Transform=basis:Inverse()*p[prefix..'Hip']*basis
   knee.Transform=p[prefix..'Knee']
  end end
  return frame(w.grip)
 end
 report.clips[key]={}
 for i=0,24 do
  local t=duration*i/24;sample(t)
  local row={age=t,parts={}}
  for _,p in c:GetChildren()do if p:IsA('BasePart')and p~=c.HumanoidRootPart then
   row.parts[p.Name]={cf={c.HumanoidRootPart.CFrame:ToObjectSpace(frame(p)):GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z}}
  end end
  row.parts.Weapon={cf={c.HumanoidRootPart.CFrame:ToObjectSpace(frame(w.grip)*offset):GetComponents()},size={model.Weapon.Size.X,model.Weapon.Size.Y,model.Weapon.Size.Z}}
  local point=c.HumanoidRootPart.CFrame:PointToObjectSpace(frame(w.grip):PointToWorldSpace(edge))
  row.edge={point.X,point.Y,point.Z}
  table.insert(report.clips[key],row)
  print('MIXAMO_POSE '..game.HttpService:JSONEncode({key=key,frame=row}))
 end
 for _,delta in {-.005,0,.005}do
  local t=contact+delta;local before=sample(t-.0005);local after=sample(t+.0005);local at=sample(t)
  local velocity=(after:PointToWorldSpace(edge)-before:PointToWorldSpace(edge)).Unit
  table.insert(report.edges,{key=key,delta=delta,edgeDot=at:VectorToWorldSpace(dir):Dot(velocity),faceDot=math.abs(at:VectorToWorldSpace(face):Dot(velocity))})
 end
end
print('MIXAMO_DWARF_EDGES '..game.HttpService:JSONEncode(report.edges));c:Destroy()
