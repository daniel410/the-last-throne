-- Independent Blender samples are supplied by the isolated QA preparation tool.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Bow=require(Client.K0BowMotion)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,skills=0,maxBlenderDegrees=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
for _,s in elfGolden.reload do
 local p=Bow.sampleBasic(s.age,Enum.HumanoidRigType.R15)
 check(math.abs(p.draw-s.draw)<.00001,'Standing Draw Arrow string curve agrees with Blender')
 for ch,expected in s.angles do
  local error=(p.angles[ch]-Vector3.new(unpack(expected))).Magnitude
  report.maxBlenderDegrees=math.max(report.maxBlenderDegrees,error)
  check(error<.004,'Standing Draw Arrow independent Blender parity '..ch)
 end
end
local desc=Instance.new('HumanoidDescription')
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
c:SetAttribute('K0ClassId','elf')
local d=Config.BasicAttackProfiles.elf.attacks[1]
for _,rate in {1,2}do
 c:SetAttribute('K0State','Dodge');Bow.forCharacter(c,99)
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',nil)
 c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0BasicAttackRate',rate)
 local early=Bow.forCharacter(c,100+d.windup*.25/rate)
 check(early.reloading and not early.nocked,'Basic attack reaches for a fresh arrow before nocking')
 check(early.ikWeight==0 and early.draw==0,'Draw IK does not erase the quiver reach')
 local loaded=Bow.forCharacter(c,100+d.windup*.875/rate)
 check(loaded.nocked and loaded.draw>.999 and loaded.ikWeight==1,'Arrow reaches the reviewed anchor before release')
 local release=Bow.forCharacter(c,100+d.windup/rate+.000001)
 check(not release.nocked,'Basic arrow releases on unchanged server windup')
 local a=Bow.forCharacter(c,100+d.windup*.6/rate)
 local b=Bow.forCharacter(c,100+d.windup*.6/rate)
 check((a.right.Position-b.right.Position).Magnitude==0 and a.right==b.right,'Sampling is independent of render count')
end
for _,skill in Config.Skills.elf do
 report.skills+=1
 c:SetAttribute('K0State','Dodge');Bow.forCharacter(c,99)
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',skill.id);c:SetAttribute('K0AttackStartedAt',100)
 local p=Bow.forCharacter(c,100+skill.windup*.5)
 check(p and not p.reloading,'Skill casting retains its existing draw choreography '..skill.id)
 check(math.abs(p.draw-Bow.sample(p.time).draw)<.00001,'Skill draw timing is unchanged '..skill.id)
end
for _,mode in {'Dodge','Block','Dead'}do
 c:SetAttribute('K0State',mode);check(Bow.forCharacter(c,101)==nil,'Reload cancels on '..mode)
end
c:Destroy();report.pass=true
print('MIXAMO_ELF_NATIVE '..game.HttpService:JSONEncode(report))
