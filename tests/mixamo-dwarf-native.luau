-- tools/prepare-mixamo-dwarf-tests.py supplies independent Blender evaluations.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local M=require(Client.K0MeleeMotion)
local Advanced=require(Client.AdvancedSkillMotion)
local V=require(Client.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,maxBlenderDegrees=0,skills=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
local keys={basic=false,overhead='dwarf.common.overhead',ground='dwarf.common.ground',grounded='dwarf.mixamo.grounded',backhand='dwarf.mixamo.backhand',sweep='dwarf.mixamo.sweep'}
for key,samples in mixamoGolden do
 for _,s in samples do
  local p=assert(M.sample('dwarf',1,s.age,nil,nil,keys[key]or nil,Enum.HumanoidRigType.R15))
  for ch,expected in s.angles do
   local error=(p.angles[ch]-Vector3.new(unpack(expected))).Magnitude
   report.maxBlenderDegrees=math.max(report.maxBlenderDegrees,error)
   check(error<.004,'Independent Blender curve parity '..key..'/'..ch..' age='..s.age..' error='..error..' actual='..tostring(p.angles[ch])..' expected='..tostring(Vector3.new(unpack(expected))))
  end
 end
end
for _,rig in {Enum.HumanoidRigType.R15,Enum.HumanoidRigType.R6} do
 local desc=Instance.new('HumanoidDescription')
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
 local root=c.HumanoidRootPart;local origin=root.CFrame
 local model=Instance.new('Model');model.Parent=c;local w=assert(A.attachInto(model,c,'dwarf'))
 c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
 for _,d in Config.Skills.dwarf do
  report.skills+=1
  c:SetAttribute('K0State','Dodge');M.forCharacter(c,99);Advanced.forCharacter(c,99)
  c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',d.id)
  c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0SkillStartedAt',100)
  local total=d.windup+d.active+d.recovery
  for i=0,40 do
   local age=total*i/40
   local p=Advanced.forCharacter(c,100+age)or M.forCharacter(c,100+age)
   check(p~=nil,'Every dwarf skill has choreography '..d.id)
   for ch,a in p.angles do
    check(a.X==a.X and a.Y==a.Y and a.Z==a.Z,'Finite joints '..d.id..'/'..ch)
   end
   V.renderArms(c,1/60,100+age);V.render(model,'Active',1,1/60,'Skill',100+age)
   check(root.CFrame==origin,'Presentation leaves physics root unchanged')
   check(w.joint.Transform.Position.Magnitude<.0001,'Axe stays in its hand socket')
   if rig==Enum.HumanoidRigType.R15 and d.id=='dwarf.common.ground' and age<total-.001 then
    check(p.root~=nil,'Ground Slam has an explicit visual jump')
    check(math.abs(p.root.X)<.0001 and math.abs(p.root.Z)<.0001,'In-place jump removes run-up')
   end
  end
  c:SetAttribute('K0State','Dead')
  check(M.forCharacter(c,102)==nil and Advanced.forCharacter(c,102)==nil,'Death cancels old poses')
 end
 c:Destroy()
end
local g=Config.Skills.dwarf[3];local contact=g.windup+(g.hitDelay or 0)
check(M.sample('dwarf',1,contact,nil,nil,g.id,Enum.HumanoidRigType.R15).root.Position.Magnitude<.001,'Jump lands on server contact')
report.pass=true
print('MIXAMO_DWARF_NATIVE '..game.HttpService:JSONEncode(report))
