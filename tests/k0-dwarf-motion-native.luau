-- Real class/skill attributes, presentation joints and interrupted recovery.
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeMotion)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind="K0_DWARF_MOTION_NATIVE",checks=0,failures={}}
local function check(v,label) report.checks+=1;assert(v,label) end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
 local character
 local ok,err=xpcall(function()
  local desc=Instance.new("HumanoidDescription")
  character=Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
  local root=character.HumanoidRootPart;local origin=root.CFrame
  local model=Instance.new("Model");model.Name="DwarfAppearance";model.Parent=character
  local weapon=assert(Appearance.attachInto(model,character,"dwarf"))
  character:SetAttribute("K0ClassId","dwarf");character:SetAttribute("K0Combo",1)
  for _,skill in ipairs(Config.Skills.dwarf) do
   if not table.find({"dwarf.common.overhead","dwarf.common.ground","dwarf.common.throw"},skill.id) then continue end
   character:SetAttribute("K0State","Dodge");Motion.forCharacter(character,99)
   character:SetAttribute("K0State","Attack");character:SetAttribute("K0SkillId",skill.id)
   character:SetAttribute("K0AttackStartedAt",100);character:SetAttribute("K0SkillStartedAt",100)
   local total=skill.windup+skill.active+skill.recovery
   local impact=skill.windup+(skill.hitDelay or 0)
   for i=0,64 do
    local age=total*i/64
    local actual=assert(Motion.forCharacter(character,100+age))
    local expected=assert(Motion.sample("dwarf",1,age,nil,nil,skill.id))
    check((actual.angles.right-expected.angles.right).Magnitude<.002,"Accepted dwarf skill selects its own clip")
    Visual.renderArms(character,1/60,100+age)
    Visual.render(model,"Active",1,1/60,"Skill",100+age)
    check(root.CFrame==origin,"Dwarf motion never moves authoritative root")
    check((weapon.joint.Transform.Position).Magnitude<.001,"Axe remains on its hand socket")
    local before=Motion.sample("dwarf",1,age-.00001,nil,nil,skill.id)
    local after=Motion.sample("dwarf",1,age+.00001,nil,nil,skill.id)
    check((before.angles.right-after.angles.right).Magnitude<.2,"No phase-boundary shoulder snap")
   end
   local hit=assert(Motion.sample("dwarf",1,impact,nil,nil,skill.id))
   check(hit.cutting==(not skill.ranged),"Ranged throw does not emit melee cutting trail")
   local recoveryTime=100+skill.windup+skill.active+.02
   local previous=assert(Motion.forCharacter(character,recoveryTime))
   character:SetAttribute("K0SkillId",nil);character:SetAttribute("K0AttackStartedAt",recoveryTime)
   local nextPose=assert(Motion.forCharacter(character,recoveryTime))
   for channel,angle in pairs(previous.angles) do
    check((nextPose.angles[channel]-angle).Magnitude<.003,"Skill recovery joins next basic attack")
   end
  end
  character:SetAttribute("K0SkillId","dwarf_unknown")
  check(Motion.forCharacter(character,105)==nil,"Unknown skill retains fallback")
  character:SetAttribute("K0SkillId","dwarf.common.throw");character:SetAttribute("K0ClassId","knight")
  check(Motion.forCharacter(character,105)==nil,"Axe clips cannot apply to Knight")
 end,debug.traceback)
 if not ok then table.insert(report.failures,tostring(rig)..": "..tostring(err)) end
 if character then character:Destroy() end
end
report.pass=#report.failures==0
print("K0_DWARF_MOTION_NATIVE "..Http:JSONEncode(report))
assert(report.pass,"Dwarf motion integration failed")
