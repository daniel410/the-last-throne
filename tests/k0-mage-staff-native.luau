-- Isolated native joints and manual FK, not a live-client/Animator acceptance.
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MageMotion)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind="K0_MAGE_STAFF_NATIVE",checks=0,failures={},maxDegreesError=0,minReleaseForward=1}
local function check(v,label) report.checks+=1;assert(v,label) end
local ok,err=xpcall(function()
 for name,samples in pairs(MageGolden) do
  for _,s in ipairs(samples) do
   local p=assert(Motion.raw(name,s.time))
   check(math.abs(p.focus-s.focus)<.00001,"Focus agrees with independent Blender samples")
   for c,a in pairs(s.angles) do
    local delta=(p.angles[c]-Vector3.new(unpack(a))).Magnitude
    report.maxDegreesError=math.max(report.maxDegreesError,delta)
    check(delta<.003,"Native curve agrees with Blender evaluation")
   end
  end
 end
 check(Motion.raw("unknown",0)==nil and Motion.raw("arcane_bolt",0/0)==nil,"Reject unknown clips and nonfinite time")
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
 local character
 local pass,message=xpcall(function()
  local desc=Instance.new("HumanoidDescription")
  character=Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
  local root=character.HumanoidRootPart;local origin=root.CFrame
  local model=Instance.new("Model");model.Name="MageAppearance";model.Parent=character
  local weapon=assert(Appearance.attachInto(model,character,"mage"))
  check(weapon.joint.Part0.Name==(rig==Enum.HumanoidRigType.R15 and "RightHand" or "Right Arm"),"Staff stays in right hand")
  check(Appearance.isAttached(model,character,"mage"),"Staff retains equipment lifecycle contract")
  local joints,offsets={},{}
  for _,j in ipairs(character:GetDescendants()) do
   if (j:IsA("Motor6D") or j:IsA("AnimationConstraint") or j:IsA("WeldConstraint")) and j.Part0 and j.Part1 then
    joints[j.Part1]=j;if j:IsA("WeldConstraint") then offsets[j]=j.Part0.CFrame:ToObjectSpace(j.Part1.CFrame) end
    j.Enabled=false
   end
  end
  local function fk()
   local frames={[root]=origin}
   local function frame(p)
    if frames[p] then return frames[p] end
    local j=joints[p]
    frames[p]=j and (j:IsA("WeldConstraint") and frame(j.Part0)*offsets[j] or frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()) or p.CFrame
    return frames[p]
   end
   for p in pairs(joints) do frame(p) end
   for p,cf in pairs(frames) do if p~=root then p.CFrame=cf end end
  end
  character:SetAttribute("K0ClassId","mage");character:SetAttribute("K0Combo",1)
  local definitions={Config.BasicAttackProfiles.mage.attacks[1]}
  for _,d in ipairs(Config.Skills.mage) do table.insert(definitions,d) end
  local used={}
  for _,d in ipairs(definitions) do
   character:SetAttribute("K0State","Dodge");Motion.forCharacter(character,99)
   character:SetAttribute("K0State","Attack");character:SetAttribute("K0AttackKind",d.id and "Arcane" or "Basic")
   character:SetAttribute("K0SkillId",d.id);character:SetAttribute("K0AttackStartedAt",100)
   local def,profile=Motion.definition(d.id,d.id and "Arcane" or "Basic");used[profile]=true
   check(def==d,"Every configured Mage skill resolves to its own timing definition")
   local total=d.windup+d.active+d.recovery
   for i=0,32 do
    local age=total*i/32;local now=100+age
    character:SetAttribute("K0AttackPhase",age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery")
    local pose=assert(Motion.forCharacter(character,now));check(pose.profile==profile,"Form selects the intended Mage motion")
    Visual.renderArms(character,1/30,now);fk();Visual.renderCharacter(character,1/30,now);fk()
    check(root.CFrame==origin,"Mage presentation cannot move authoritative root")
    check(weapon.joint.Transform.Position.Magnitude<.00001,"Staff grip never slips from its socket")
    local first=weapon.joint.Transform;Visual.renderCharacter(character,1/144,now)
    check((first.LookVector-weapon.joint.Transform.LookVector).Magnitude<.00001,"Same accepted time is independent of FPS and call count")
    check(not pose.cutting or profile=="staff_strike","Spells never enable melee cutting trail")
   end
   for _,boundary in ipairs({d.windup,d.windup+d.active,total}) do
    local before,after=Motion.sample(d,profile,boundary-.00001),Motion.sample(d,profile,boundary+.00001)
    check((before.angles.right-after.angles.right).Magnitude<.1,"No shoulder snap at phase boundaries")
   end
   local at=100+d.windup;Visual.renderArms(character,1/60,at);fk();Visual.renderCharacter(character,1/60,at);fk()
   if profile=="arcane_bolt" or profile=="water_orb" then
    local forward=weapon.grip.CFrame.UpVector:Dot(root.CFrame.LookVector)
    report.minReleaseForward=math.min(report.minReleaseForward,forward)
    check(forward>.8,"Projectile release points staff crown toward front target corridor")
   end
   local atNext=100+d.windup+d.active+.03;local previous=assert(Motion.forCharacter(character,atNext))
   character:SetAttribute("K0SkillId",nil);character:SetAttribute("K0AttackKind","Basic");character:SetAttribute("K0AttackStartedAt",atNext)
   local nextPose=assert(Motion.forCharacter(character,atNext))
   for c,v in pairs(previous.angles) do check((nextPose.angles[c]-v).Magnitude<.003,"Spell recovery joins accepted next staff attack") end
  end
  local n=0;for _ in pairs(used) do n+=1 end;check(n==6,"All six original motion families are exercised")
  character:SetAttribute("K0State","Dodge");Motion.forCharacter(character,199)
  character:SetAttribute("K0State","Attack");character:SetAttribute("K0SkillId","mage.common.mana_bolt");character:SetAttribute("K0AttackKind","Arcane");character:SetAttribute("K0AttackStartedAt",200)
  character:SetAttribute("K0AttackPhase","Windup");character:SetAttribute("K0SpellVisual",nil)
  local now=200+Config.Skills.mage[1].windup*.8
  Visual.renderArms(character,1/60,now);fk();Visual.renderCharacter(character,1/60,now);fk()
  local light=assert(model:FindFirstChild("K0StaffFocusLight",true));local emitter=assert(model:FindFirstChild("K0StaffFocus",true))
  check(light.Enabled and emitter.Rate>0,"Gathered spell charges staff focus")
  check(not workspace:FindFirstChild("K0VisualSpell"),"Charge creates no unapproved projectile")
  local first=root.Position+Vector3.new(0,2,-1);local last=root.Position+root.CFrame.LookVector*30
  local function payload(seq) return string.format("%d|%.4f|%.4f|%.4f|%.4f|%.4f|%.4f",seq,first.X,first.Y,first.Z,last.X,last.Y,last.Z) end
  now=200+Config.Skills.mage[1].windup;character:SetAttribute("K0AttackPhase","Active")
  Visual.renderArms(character,1/60,now);fk();Visual.renderCharacter(character,1/60,now);fk()
  character:SetAttribute("K0SpellVisual",payload(rig==Enum.HumanoidRigType.R15 and 2 or 1))
  Visual.renderCharacter(character,1/60,now)
  local orb=assert(workspace:FindFirstChild("K0VisualSpell"));local tip=weapon.grip.WeaponTip
  check((orb.Position-tip.WorldPosition).Magnitude<.002,"Server-approved shot starts at current rendered staff tip")
  check(orb.Anchored and not orb.CanCollide and not orb.CanTouch and not orb.CanQuery,"Projectile is inert presentation")
  Visual.renderCharacter(character,1/144,now)
  local count=0;for _,o in ipairs(workspace:GetChildren()) do if o.Name=="K0VisualSpell" then count+=1 end end
  check(count==1,"Repeated rendering never duplicates server payload")
  orb:Destroy()
  for _,mode in ipairs({"Block","Dodge","Dead"}) do
   character:SetAttribute("K0State",mode);check(Motion.forCharacter(character,now)==nil,"Cancellation clears authored spell action")
   Visual.renderCharacter(character,1/60,now)
   check(not light.Enabled and emitter.Rate==0,"Cancelled cast clears staff charge")
  end
  character:SetAttribute("K0State","Attack");character:SetAttribute("K0AttackStartedAt",300)
  character:SetAttribute("TLTEquippedWeapon","");Visual.renderCharacter(character,1/60,300.2)
  check(not light.Enabled and emitter.Rate==0,"Unequipped staff cannot retain charge")
  character:SetAttribute("TLTEquippedWeapon",nil);character:SetAttribute("K0SkillId","mage_unknown")
  check(Motion.forCharacter(character,300.2)==nil,"Unknown spell uses existing fallback")
  character:SetAttribute("K0ClassId","knight");check(Motion.forCharacter(character,300.2)==nil,"Mage clips never leak into other classes")
  model.Parent=nil;check(Visual.render(model,"Idle",1,1/60,"Basic",301),"Detached staff presentation handles absent character")
  weapon.joint:Destroy();check(not Visual.render(model,"Idle",1,1/60,"Basic",301),"Missing weapon joint clears charge without raising an error")
  check(not light.Enabled and emitter.Rate==0,"Invalid staff clears focus")
  model:Destroy()
 end,debug.traceback)
 if not pass then table.insert(report.failures,tostring(rig)..": "..tostring(message)) end
 if character then character:Destroy() end
 for _,o in ipairs(workspace:GetChildren()) do if o.Name=="K0VisualSpell" then o:Destroy() end end
end
report.pass=#report.failures==0
print("K0_MAGE_STAFF_NATIVE "..Http:JSONEncode(report))
assert(report.pass,"Mage staff motion verification failed")
