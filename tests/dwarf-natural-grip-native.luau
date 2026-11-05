-- The rendered grip, including its separate yaw layer, must join at an
-- accepted action boundary. Checking just Euler channels missed the old snap.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0MeleeMotion)
local Visual=require(Client.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='DWARF_NATURAL_GRIP_NATIVE',checks=0,failures={}}
local function check(v,label)report.checks+=1;assert(v,label)end
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local c
 local ok,err=xpcall(function()
  local desc=Instance.new('HumanoidDescription');c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0));local origin=c.HumanoidRootPart.CFrame
  local model=Instance.new('Model');model.Parent=c;local w=assert(A.attachInto(model,c,'dwarf'))
  c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
  for _,rate in {1,2}do for _,dt in {1/30,1/144}do
   for _,skillId in {'basic','dwarf.common.overhead','dwarf.common.throw','dwarf.common.ground'}do
    c:SetAttribute('K0State','Dodge');Motion.forCharacter(c,99)
    c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0BasicAttackRate',rate)
    c:SetAttribute('K0SkillId',skillId~='basic'and skillId or nil)
    local definition=Config.BasicAttackProfiles.dwarf.attacks[1]
    if skillId~='basic'then for _,d in Config.Skills.dwarf do if d.id==skillId then definition=d end end end
    local elapsed=(definition.windup+definition.active+.035)/(skillId=='basic'and rate or 1)
    local now=100+elapsed
    local before=Motion.forCharacter(c,now)
    Visual.renderArms(c,dt,now);Visual.render(model,'Recovery',1,dt,'Melee',now)
    local gripBefore=w.joint.Transform
    c:SetAttribute('K0SkillId',nil);c:SetAttribute('K0AttackStartedAt',now)
    local after=Motion.forCharacter(c,now)
    Visual.renderArms(c,dt,now);Visual.render(model,'Windup',1,dt,'Melee',now)
    local _,angle=(gripBefore:Inverse()*w.joint.Transform):ToAxisAngle()
    check(math.abs(angle)<.001,'Full hand-to-axe rotation is continuous on '..skillId)
    check(math.abs(before.axeStrikeTurn-after.axeStrikeTurn)<.00001,'Separate yaw survives recovery cancel')
    for channel,v in before.angles do check((after.angles[channel]-v).Magnitude<.003,'Joint pose survives recovery cancel '..channel)end
    check(c.HumanoidRootPart.CFrame==origin,'Presentation never moves the authoritative root')
   end
  end end
  if rig==Enum.HumanoidRigType.R15 then
   local fixed
   for i=0,100 do
    local p=Motion.sample('dwarf',1,.11+.18*i/100)
    fixed=fixed or p.weapon
    local _,angle=(fixed:Inverse()*p.weapon):ToAxisAngle()
    check(math.abs(angle)<.0001,'Axe socket stays fixed from loaded pose through follow-through')
    check(math.abs(p.angles.wrist.X)<=30.001 and math.abs(p.angles.wrist.Y)<=30.001 and math.abs(p.angles.wrist.Z)<=30.001,'Wrist stays within authored limits')
   end
  end
 end,debug.traceback)
 if not ok then table.insert(report.failures,rig.Name..': '..err)end
 if c then c:Destroy()end
end
report.pass=#report.failures==0;print('DWARF_NATURAL_GRIP_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Natural grip regression failed')
