-- Native R6/R15 sockets and Blender reference samples; no local hit authority.
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Bow=require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
local Geometry=require(game.ReplicatedStorage.Shared.ElfBowGeometry)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind="K0_ELF_BOW_NATIVE",checks=0,failures={},maxDegreesError=0,maxNockError=0}
local function check(v,label) report.checks+=1;assert(v,label) end
local function near(a,b,e,label) check((a-b).Magnitude<e,label) end
local ok,err=xpcall(function()
 for _,sample in ipairs(BowGolden) do
  local pose=Bow.sample(sample.time)
  check(math.abs(pose.draw-sample.draw)<.00001,"Draw agrees with Blender evaluation")
  for channel,expected in pairs(sample.angles) do
   local delta=(pose.angles[channel]-Vector3.new(unpack(expected))).Magnitude
   report.maxDegreesError=math.max(report.maxDegreesError,delta)
   check(delta<.003,"Arm and body curves agree with Blender evaluation")
  end
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
 local character
 local pass,message=xpcall(function()
  local desc=Instance.new("HumanoidDescription")
  character=Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
  local root=character.HumanoidRootPart;local origin=root.CFrame
  local model=Instance.new("Model");model.Name="ElfAppearance";model.Parent=character
  local weapon=assert(Appearance.attachInto(model,character,"elf"))
  local bow,arrow,stringPart=model.Bow,model.NockedArrow,model.String
  check(weapon.joint.Part0.Name==(rig==Enum.HumanoidRigType.R15 and "LeftHand" or "Left Arm"),"Elf bow stays in left hand")
  check(math.abs(arrow.Size.Z-2.7)<.00001 and stringPart.Transparency==1,"Derived arrow length and hidden predrawn string")
  check(bow.MeshId==game.ServerStorage.TDPlayerWeaponModels.ElfBow.Bow.MeshId,"TD bow geometry identity retained")
  check(Appearance.isAttached(model,character,"elf"),"Derived rig remains valid for lifecycle reuse")
  local joints,offsets={},{}
  for _,j in ipairs(character:GetDescendants()) do
   if (j:IsA("Motor6D") or j:IsA("AnimationConstraint") or j:IsA("WeldConstraint")) and j.Part0 and j.Part1 then
    joints[j.Part1]=j
    if j:IsA("WeldConstraint") then offsets[j]=j.Part0.CFrame:ToObjectSpace(j.Part1.CFrame) end
    -- Manual FK writes individual parts; disconnect assemblies so the fixture
    -- itself cannot translate the root when setting a connected Part.CFrame.
    j.Enabled=false
   end
  end
  local function fk()
   local frames={[root]=origin}
   local function frame(part)
    if frames[part] then return frames[part] end
    local j=joints[part]
    frames[part]=j and (j:IsA("WeldConstraint") and frame(j.Part0)*offsets[j] or frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()) or part.CFrame
    return frames[part]
   end
   for part in pairs(joints) do frame(part) end
   for part,cf in pairs(frames) do if part~=root then part.CFrame=cf end end
  end
  character:SetAttribute("K0ClassId","elf");character:SetAttribute("K0Combo",1)
  local definitions={Config.BasicAttackProfiles.elf.attacks[1],Config.Skills.elf[1],Config.Skills.elf[2],Config.Skills.elf[3]}
  for _,d in ipairs(definitions) do
   character:SetAttribute("K0State","Dodge");Bow.forCharacter(character,99)
   character:SetAttribute("K0State","Attack");character:SetAttribute("K0SkillId",d.id)
   character:SetAttribute("K0AttackStartedAt",100);character:SetAttribute("K0RapidShotCount",0)
   character:SetAttribute("K0RapidShotAt",nil)
   local total=d.windup+d.active+d.recovery
   for i=0,64 do
    local age=total*i/65;local now=100+age
    if d.effect=="rapid" and age>=d.windup then
     local count=math.min(d.shotCount,1+math.floor((age-d.windup)/d.shotInterval))
     character:SetAttribute("K0RapidShotCount",count);character:SetAttribute("K0RapidShotAt",100+d.windup+(count-1)*d.shotInterval)
    end
    character:SetAttribute("K0AttackPhase",age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery")
    Visual.renderArms(character,1/30,now);fk();Visual.renderCharacter(character,1/30,now);fk()
    local nock=weapon.grip.BowNock
    local tail=arrow.CFrame:PointToWorldSpace(Vector3.new(0,0,arrow.Size.Z*.5))
    local delta=(tail-nock.WorldPosition).Magnitude;report.maxNockError=math.max(report.maxNockError,delta)
    check(delta<.002,"Both strings meet the arrow's rear nock")
    check(weapon.grip.BowStrandUpper.Attachment1==nock and weapon.grip.BowStrandLower.Attachment1==nock,"Two taut strands share one nock")
    check(arrow.CFrame.LookVector:Dot(root.CFrame.LookVector)>.98,"Arrow faces server-forward instead of sideways")
    check(root.CFrame==origin,"Bow presentation cannot move authoritative root")
    local first=arrow.NockedArrowVisualJoint.Transform
    local expected=assert(Bow.forCharacter(character,now))
    near(first.Position,Vector3.new(0,0,.86*math.clamp(expected.draw,0,1)),.0001,"String and arrow use the same authored displacement")
    Visual.renderCharacter(character,1/144,now)
    near(arrow.NockedArrowVisualJoint.Transform.Position,first.Position,.0001,"Draw is independent of FPS and render-call count")
    check((arrow.Transparency==0)==expected.nocked,"Nocked arrow visibility follows release/redraw")
   end
  end
  character:SetAttribute("K0SkillId",nil);character:SetAttribute("K0State","Attack");character:SetAttribute("K0AttackStartedAt",200)
  Visual.renderArms(character,1/60,200.21);fk();Visual.renderCharacter(character,1/60,200.21);fk()
  if rig==Enum.HumanoidRigType.R15 then
   local ik=character.Humanoid:FindFirstChild("K0BowDrawIK")
   check(ik and ik.Enabled and ik.Pole~=nil,"Draw hand uses native IK with an elbow pole")
   near(ik.Target.Position,Vector3.new(.06,-.06,1.27),.0001,"Hand target follows arrow rear, without the old vertical offset")
   Visual.renderArms(character,1/60,200.25)
   check(not ik.Enabled,"Release hand does not chase the snapping string")
  end
  for _,mode in ipairs({"Block","Dodge","Dead"}) do
   character:SetAttribute("K0State",mode)
   check(Bow.forCharacter(character,200.3)==nil,"Common actions cancel draw pose")
   Visual.renderArms(character,1/60,200.3);Visual.renderCharacter(character,1/60,200.3)
   check(arrow.NockedArrowVisualJoint.Transform.Position.Magnitude==0,"Cancelled draw releases string")
  end
  character:SetAttribute("K0State","Idle");character:SetAttribute("TLTEquippedWeapon","")
  Visual.renderCharacter(character,1/60,201)
  check(arrow.Transparency==1 and not weapon.grip.BowStrandUpper.Enabled,"Unequipping hides local arrow and both strings")
  character:SetAttribute("TLTEquippedWeapon","elf.bow.basic");Visual.renderCharacter(character,1/60,201)
  check(arrow.Transparency==0 and weapon.grip.BowStrandUpper.Enabled,"Re-equipping restores the bow rig")
  local payload="19|0|500|0|0|500|-20"
  character:SetAttribute("K0ArrowVisual",payload)
  Visual.renderCharacter(character,1/60,201)
  local projectile
  local count=0
  for _,item in ipairs(workspace:GetChildren()) do if item.Name=="K0VisualArrow" then projectile=item;count+=1 end end
  check(projectile and projectile.Shaft:IsA("MeshPart"),"Flight reuses the nocked arrow mesh")
  check(projectile.Shaft.MeshId==arrow.MeshId and projectile.Shaft.Size==arrow.Size,"Arrow geometry and scale do not change on release")
  check(projectile.Shaft.Anchored and not projectile.Shaft.CanCollide and not projectile.Shaft.CanQuery,"Local arrow cannot create a hit")
  Visual.renderCharacter(character,1/30,201)
  local repeated=0
  for _,item in ipairs(workspace:GetChildren()) do if item.Name=="K0VisualArrow" then repeated+=1 end end
  check(repeated==count,"Repeated payload does not duplicate a projectile")
  projectile:Destroy()
  check(game.ServerStorage.TDPlayerWeaponModels.ElfBow.NockedArrow.Size.Z>3.8,"Source arrow is immutable")
  weapon.grip.BowStrandUpper:Destroy()
  check(not Appearance.isAttached(model,character,"elf"),"Missing strand is detected by equipment lifecycle")
  local repaired=assert(Appearance.attachInto(model,character,"elf"))
  check(repaired.grip~=weapon.grip and Appearance.isAttached(model,character,"elf"),"Damaged bow rig rebuilds without stale attachments")
  character:SetAttribute("K0ClassId","knight")
  check(Bow.forCharacter(character,201)==nil,"Elf motion cannot affect Knight")
 end,debug.traceback)
 if not pass then table.insert(report.failures,tostring(rig)..": "..tostring(message)) end
 if character then character:Destroy() end
end
report.pass=#report.failures==0
print("K0_ELF_BOW_NATIVE "..Http:JSONEncode(report))
assert(report.pass,"Elf bow refinement failed")
