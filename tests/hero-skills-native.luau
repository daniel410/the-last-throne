-- Isolated engine fixtures. Not a live combat / aesthetic acceptance test.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"isolated local Place required")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Visual=require(Client.K0SwordVisual)
local Effects=require(Client.AdvancedSkillVisual)
local Bow=require(Client.K0BowMotion)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind="HERO_SKILLS_NATIVE",checks=0,skills=0,failures={},rigs={}}
local function check(v,label) report.checks+=1;assert(v,label) end
local function finite(cf,label)
 for _,n in ipairs({cf:GetComponents()}) do check(n==n and math.abs(n)<1e8,label.." finite") end
end
local floor=Instance.new("Part");floor.Name="SkillFixtureFloor";floor.Size=Vector3.new(250,1,250);floor.Anchored=true;floor.CFrame=CFrame.new(0,497,0);floor.Parent=workspace
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
 for _,classId in ipairs({"knight","dwarf","elf","mage"}) do
  local character
  local ok,err=xpcall(function()
   local desc=Instance.new("HumanoidDescription")
   character=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
   character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
   local model=Instance.new("Model");model.Name="SkillFixtureAppearance";model.Parent=character
   local weapon=assert(Appearance.attachInto(model,character,classId))
   character:SetAttribute("K0ClassId",classId);character:SetAttribute("K0Combo",1)
   for index,d in ipairs(Config.Skills[classId]) do
    character:SetAttribute("K0State","Dodge");Visual.renderArms(character,1/60,99)
    character:SetAttribute("K0State","Attack");character:SetAttribute("K0SkillId",d.id)
    character:SetAttribute("K0AttackKind",classId=="mage" and "Arcane" or "Basic")
    character:SetAttribute("K0AttackStartedAt",100);character:SetAttribute("K0SkillStartedAt",100)
    character:SetAttribute("K0AttackSeq",index)
    for _,age in ipairs({0,d.windup*.5,d.windup,d.windup+d.active*.5,d.windup+d.active,d.windup+d.active+d.recovery}) do
     local phase=age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery"
     character:SetAttribute("K0AttackPhase",phase)
     Visual.renderArms(character,1/60,100+age);Visual.renderCharacter(character,1/60,100+age)
     for _,joint in ipairs(character:GetDescendants()) do
      if joint:IsA("Motor6D") or joint:IsA("AnimationConstraint") then finite(joint.Transform,d.id) end
     end
     finite(weapon.joint.Transform,d.id.." weapon")
    end
    if classId=="elf" then
     local drawn=assert(Bow.forCharacter(character,100+d.windup*.75)).draw
     if d.advanced and d.pulses>1 then Bow.confirmPulse(character,d.id,1,index,100+d.windup,100,100+d.windup+.039) end
     if d.effect=="rapid" then character:SetAttribute("K0RapidShotCount",1);character:SetAttribute("K0RapidShotAt",100+d.windup) end
     local released=assert(Bow.forCharacter(character,100+d.windup+.039)).draw
     check(drawn>released+.05,d.id.." authored bow draws and releases")
    end
    if d.advanced then
     local origin=character.HumanoidRootPart.Position;local center=origin+Vector3.new(0,0,-math.min(d.range,30))
     Effects.play(character,d.id,origin,center,0,nil,index)
     for pulse=1,d.pulses do Effects.play(character,d.id,origin,center,pulse,{center},index,100,100-d.windup) end
     character:SetAttribute("K0State","Dodge")
     check(character:FindFirstChild("BranchSkillProp")==nil,d.id.." prop cleared on cancel")
    end
    report.skills+=1
    if index%8==0 then task.wait(.55) end
   end
   table.insert(report.rigs,rig.Name.."/"..classId)
  end,debug.traceback)
  if character then character:Destroy() end
  if not ok then table.insert(report.failures,rig.Name.."/"..classId..": "..tostring(err)) end
  task.wait(.55)
 end
end
floor:Destroy()
report.pass=#report.failures==0
print("HERO_SKILLS_NATIVE "..game.HttpService:JSONEncode(report))
return report
