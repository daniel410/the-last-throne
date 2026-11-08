-- tools/prepare-mixamo-dwarf-tests.py injects independently evaluated Blender data.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local M=require(Client.K0MeleeMotion)
local Advanced=require(Client.AdvancedSkillMotion)
local V=require(Client.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,skills=0,maxBlenderDegrees=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
local combos={forehand=1,backhand=2,overhead=3,wide=2,power=3,brace=1}
for key,samples in knightGolden do
 local variant=table.find({'wide','power','brace'},key)and'knight.mixamo.'..key or nil
 for _,sample in samples do
  local combo=combos[key]
  local d=Config.BasicAttackProfiles.knight.attacks[combo]
  local raw=variant and require(Client.K0KnightMixamoVariants)[variant]or require(Client.K0KnightMixamoBasic)[combo]
  local age=sample.age*(d.windup+d.active+d.recovery)/raw.duration
  local p=M.sample('knight',combo,age,nil,nil,variant,Enum.HumanoidRigType.R15)
  for ch,expected in sample.angles do
   local e=(p.angles[ch]-Vector3.new(unpack(expected))).Magnitude
   report.maxBlenderDegrees=math.max(report.maxBlenderDegrees,e)
   check(e<.004,'Blender knight parity '..key..'/'..ch)
  end
 end
end
for _,rig in {Enum.HumanoidRigType.R15,Enum.HumanoidRigType.R6}do
 local desc=Instance.new('HumanoidDescription')
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
 local model=Instance.new('Model');model.Parent=c
 local sword=assert(A.attachInto(model,c,'knight'));assert(A.attachShieldInto(model,c))
 local root=c.HumanoidRootPart;local origin=root.CFrame
 c:SetAttribute('K0ClassId','knight');c:SetAttribute('K0Combo',1)
 for _,d in Config.Skills.knight do
  report.skills+=1
  c:SetAttribute('K0State','Dodge');M.forCharacter(c,99);Advanced.forCharacter(c,99)
  c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',d.id)
  c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0SkillStartedAt',100)
  local duration=d.windup+d.active+d.recovery
  for i=0,40 do
   local age=duration*i/40
   local p=Advanced.forCharacter(c,100+age)or M.forCharacter(c,100+age)
   if p and p.angles then for ch,a in p.angles do check(a.X==a.X and a.Y==a.Y and a.Z==a.Z,'Finite knight joints '..d.id..'/'..ch)end end
   V.renderArms(c,1/60,100+age);V.render(model,'Active',1,1/60,'Skill',100+age)
   check(root.CFrame==origin,'Knight motion never moves physics root')
   check(sword.joint.Transform.Position.Magnitude<.001,'Sword remains attached to its socket')
  end
  c:SetAttribute('K0State','Dead')
  check(M.forCharacter(c,102)==nil and Advanced.forCharacter(c,102)==nil,'Death clears knight action records')
 end
 c:Destroy()
end
report.pass=true;print('MIXAMO_KNIGHT_NATIVE '..game.HttpService:JSONEncode(report))
