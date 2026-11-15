-- TLT-005/084: actual native R6/R15 joints and original held-weapon sockets.
-- Controlled FK advances exactly the same C0/Transform/C1 graph as native rigs.
-- This covers presentation geometry, not real Player input or visual acceptance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated unpublished host only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Visual=require(Client.K0SwordVisual)
local Baseline=require(Client.BlockNaturalBaselineVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='BLOCK_NATURAL_GUARD_NATIVE',baselineCommit=blockNaturalBaselineCommit,
 checks=0,cases=0,failures={},samples={},nonBlockComparisons=0,pass=false,
 frameComparison={maxPosition=0,maxBasis=0,maxRelativeAxisAngle=0,maxSelfAxisAngle=0},
 nonBlockErrors={maxPosition=0,maxBasis=0,maxRelativeAxisAngle=0,maxSelfAxisAngle=0}}
local function check(value,label)report.checks+=1;assert(value,label)end
local function nearFrame(a,b,epsilon,label)
 local position=(a.Position-b.Position).Magnitude
 local basis=math.max((a.RightVector-b.RightVector).Magnitude,(a.UpVector-b.UpVector).Magnitude,(a.LookVector-b.LookVector).Magnitude)
 local _,relativeAngle=a:ToObjectSpace(b):ToAxisAngle()
 local _,selfAngle=a:ToObjectSpace(a):ToAxisAngle()
 local comparison=report.frameComparison
 comparison.maxPosition=math.max(comparison.maxPosition,position)
 comparison.maxBasis=math.max(comparison.maxBasis,basis)
 comparison.maxRelativeAxisAngle=math.max(comparison.maxRelativeAxisAngle,math.abs(relativeAngle))
 comparison.maxSelfAxisAngle=math.max(comparison.maxSelfAxisAngle,math.abs(selfAngle))
 if label:sub(1,9)=='unblocked'then
  local unchanged=report.nonBlockErrors
  unchanged.maxPosition=math.max(unchanged.maxPosition,position)
  unchanged.maxBasis=math.max(unchanged.maxBasis,basis)
  unchanged.maxRelativeAxisAngle=math.max(unchanged.maxRelativeAxisAngle,math.abs(relativeAngle))
  unchanged.maxSelfAxisAngle=math.max(unchanged.maxSelfAxisAngle,math.abs(selfAngle))
 end
 check(position<epsilon,label..' position error='..position)
 -- Multiplying a float CFrame by its own inverse can produce a nonzero
 -- ToAxisAngle even for identical input frames. Compare the original bases
 -- directly; keep the same epsilon and report both measures as evidence.
 check(basis<epsilon,label..' rotation basis error='..basis..' relativeAngle='..relativeAngle..' selfAngle='..selfAngle)
end
local templates={}
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local description=Instance.new('HumanoidDescription')
 templates[rig]=game.Players:CreateHumanoidModelFromDescriptionAsync(description,rig);description:Destroy()
end
local fixtures={}
local function fixture(rig,classId,renderer)
 local character=templates[rig]:Clone();character.Parent=workspace
 character:PivotTo(CFrame.new(0,500,0));character:SetAttribute('K0ClassId',classId)
 character:SetAttribute('K0State','Idle');character:SetAttribute('K0Combo',1)
 character:SetAttribute('K0AttackPhase','None');character:SetAttribute('K0BasicAttackRate',1)
 local model=Instance.new('Model');model.Parent=character
 local weapon=assert(Appearance.attachInto(model,character,classId))
 if classId=='knight'then assert(Appearance.attachShieldInto(model,character))end
 local value={character=character,model=model,weapon=weapon,renderer=renderer,rig=rig,classId=classId,time=99}
 table.insert(fixtures,value)
 function value:rebuild()
  self.parents={};self.sockets={};self.parts={}
  for _,node in self.character:GetDescendants()do
   if node:IsA('BasePart')then
    node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false
    table.insert(self.parts,node)
   elseif(node:IsA('Motor6D')or node:IsA('AnimationConstraint')or node:IsA('Weld'))and node.Part0 and node.Part1 then
    self.parents[node.Part1]={joint=node};self.sockets[node]={c0=node.C0,c1=node.C1}
   elseif node:IsA('WeldConstraint')and node.Part0 and node.Part1 then
    self.parents[node.Part1]={part0=node.Part0,offset=node.Part0.CFrame:ToObjectSpace(node.Part1.CFrame)}
   end
  end
 end
 function value:evaluate()
  local frames={}
  local function frame(part)
   if frames[part]then return frames[part]end
   local link=self.parents[part];local result=part.CFrame
   if link then
    if link.joint then
     local j=link.joint
     result=frame(j.Part0)*j.C0*((j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Transform or CFrame.identity)*j.C1:Inverse()
    else result=frame(link.part0)*link.offset end
   end
   frames[part]=result;return result
  end
  for _,part in self.parts do frame(part)end
  for part,cf in frames do part.CFrame=cf end
  self.frames=frames
 end
 function value:step(now,dt)
  self.renderer.renderArms(self.character,dt,now)
  self.renderer.renderCharacter(self.character,dt,now)
  self:evaluate();self.time=now
 end
 function value:advance(now,fps)
  while self.time<now-1e-8 do
   local dt=math.min(1/fps,now-self.time)
   self:step(self.time+dt,dt)
  end
 end
 function value:palm(side)
  local name=side..(self.rig==Enum.HumanoidRigType.R15 and'Hand'or' Arm')
  local hand=assert(self.character:FindFirstChild(name))
  local point=Vector3.new(0,self.rig==Enum.HumanoidRigType.R15 and-.12 or-hand.Size.Y*.5,-hand.Size.Z*.5)
  return self.frames[hand]:PointToWorldSpace(point)
 end
 function value:contact()
  local target=assert(self.weapon.grip:FindFirstChild('K0BlockHandTarget'),'guard support target exists')
  return(self:palm(self.classId=='elf'and'Right'or'Left')-self.frames[self.weapon.grip]:PointToWorldSpace(target.Position)).Magnitude
 end
 value:rebuild();value:evaluate()
 return value
end
local function inside(cf,size,point,inset)
 local p=cf:PointToObjectSpace(point);local half=size*.5-Vector3.one*(inset or 0)
 return math.abs(p.X)<half.X and math.abs(p.Y)<half.Y and math.abs(p.Z)<half.Z
end
local function guardGeometry(value,label)
 local c=value.character;local root=c.HumanoidRootPart
 local grip=value.frames[value.weapon.grip]
 local relative=root.CFrame:PointToObjectSpace(grip.Position)
 check(relative.Z<-.5 and relative.Z>-2.5,label..' guard remains in front of upper body')
 check(relative.Y>.25 and relative.Y<2,label..' guard stays below crown and above waist')
 local shaft=grip.UpVector
 check(math.abs(shaft.Y)<.35,label..' shaft forms a slightly angled cross guard')
 local primary=value.classId=='elf'and'Left'or'Right'
 check(value.weapon.joint.Part0==c:FindFirstChild(primary..(value.rig==Enum.HumanoidRigType.R15 and'Hand'or' Arm')),label..' owned weapon remains on original hand')
 check(value:contact()<.1,label..' free palm contacts shaft within0.1stud')
 local spacing=(value:palm('Left')-value:palm('Right')).Magnitude
 check(spacing>=1,label..' both palms keep useful bracing width')
 if value.classId=='elf'then
  check(assert(value.model:FindFirstChild('NockedArrow')).Transparency==1,label..' bow guard hides nocked arrow')
  for _,node in c:GetDescendants()do
   if node:IsA('IKControl')and node.Name=='K0BowDrawIK'then
    check(not node.Enabled and node.Weight==0,label..' bow draw IK cannot override bracing hand')
   end
  end
 end
 local head=c.Head;local torso=c:FindFirstChild('UpperTorso')or c:FindFirstChild('Torso')
 for _,side in {'Left','Right'}do
  local palm=value:palm(side)
  check(not inside(value.frames[head],head.Size,palm,.02),label..' palm clears head')
  check(not inside(value.frames[torso],torso.Size,palm,.02),label..' palm clears torso')
 end
 local target=assert(value.weapon.grip:FindFirstChild('K0BlockHandTarget'))
 for i=0,16 do
  local point=grip:PointToWorldSpace(target.Position*(i/16))
  check(not inside(value.frames[head],head.Size,point,.02),label..' braced handle clears face')
 end
 local maxTranslation=0
 for joint,original in value.sockets do
  nearFrame(joint.C0,original.c0,1e-6,label..' C0 remains authored')
  nearFrame(joint.C1,original.c1,1e-6,label..' C1 remains authored')
  if joint:IsA('Motor6D')or joint:IsA('AnimationConstraint')then
   for _,component in {joint.Transform:GetComponents()}do check(component==component and math.abs(component)<1e5,label..' finite joint')end
   if joint.Name:find('Shoulder')or joint.Name:find('Elbow')or joint.Name:find('Wrist')then
    maxTranslation=math.max(maxTranslation,joint.Transform.Position.Magnitude)
    check(joint.Transform.Position.Magnitude<1e-6,label..' limb never telescopes')
   end
   if joint.Name:find('Wrist')then
    local _,angle=joint.Transform:ToAxisAngle();check(math.abs(angle)<.001,label..' wrist remains neutral')
   end
  end
 end
 if value.rig==Enum.HumanoidRigType.R15 then
  for _,side in {'Left','Right'}do
   local shoulder=c:FindFirstChild(side..'Shoulder',true)
   local elbow=c:FindFirstChild(side..'Elbow',true)
   local wrist=c:FindFirstChild(side..'Wrist',true)
   local a=(value.frames[shoulder.Part0]*shoulder.C0).Position
   local b=(value.frames[elbow.Part0]*elbow.C0).Position
   local d=(value.frames[wrist.Part0]*wrist.C0).Position
   local angle=180-math.deg(math.acos(math.clamp((a-b).Unit:Dot((d-b).Unit),-1,1)))
   check(angle>=0 and angle<135,label..' natural elbow bend below135degrees')
  end
 end
 return{grip=grip,support=value:palm(value.classId=='elf'and'Right'or'Left'),contact=value:contact(),
  spacing=spacing,translation=maxTranslation,relative={relative.X,relative.Y,relative.Z},shaftY=shaft.Y}
end
local function case(label,callback)
 report.cases+=1
 local ok,err=xpcall(callback,debug.traceback)
 if not ok then table.insert(report.failures,label..': '..tostring(err))end
end

local byRate={}
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 for _,classId in {'elf','dwarf','mage'}do
  for _,fps in {30,144}do
   local label=rig.Name..'/'..classId..'/'..fps
   case(label,function()
    local value=fixture(rig,classId,Visual);local c=value.character;local root=c.HumanoidRootPart
    local originalRoot=root.CFrame
    value:advance(100,fps);c:SetAttribute('K0State','Block');value:step(100,1/fps)
    local poses={};local previous=100
    for _,age in {.06,.12,.18,.24,.5,2}do
     value:advance(100+age,fps)
     poses[tostring(age)]={grip=value.frames[value.weapon.grip],left=value:palm('Left'),right=value:palm('Right')}
     check(root.CFrame==originalRoot,label..' root unchanged during entry')
     previous=100+age
    end
    local settled=guardGeometry(value,label)
    value:advance(120,fps)
    local held=guardGeometry(value,label..'20second hold')
    nearFrame(held.grip,settled.grip,.001,label..' long hold never drifts')
    check((held.support-settled.support).Magnitude<.001,label..' free arm never accumulates correction')
    root.CFrame*=CFrame.Angles(0,math.rad(35),0);value:evaluate()
    value:advance(120.5,fps);guardGeometry(value,label..' facing turn')
    c:SetAttribute('K0State','Idle');value:advance(121,fps)
    check(not value.weapon.grip:FindFirstChild('K0BlockHandTarget'),label..' release removes target')
    for _,state in {'Dodge','Dead'}do
     c:SetAttribute('K0State','Block');value:advance(value.time+.4,fps);guardGeometry(value,label..' reentry')
     c:SetAttribute('K0State',state);value:advance(value.time+.4,fps)
     check(not value.weapon.grip:FindFirstChild('K0BlockHandTarget'),label..' '..state..' removes target')
    end
    c:SetAttribute('K0State','Block');value:advance(value.time+.4,fps)
    c:SetAttribute('TLTDeathFalling',true);value:advance(value.time+.4,fps)
    check(not value.weapon.grip:FindFirstChild('K0BlockHandTarget'),label..' death falling clears guard')
    c:SetAttribute('TLTDeathFalling',nil);c:SetAttribute('K0State','Idle');value:advance(value.time+.4,fps)
    c:SetAttribute('K0State','Block');value:advance(value.time+.4,fps)
    local oldTarget=value.weapon.grip:FindFirstChild('K0BlockHandTarget')
    local oldGrip=value.weapon.grip
    check(c:GetAttribute('TLTEquippedWeapon')==nil,label..' starts with original class weapon')
    -- FourFamilyWeaponVisuals explicitly maps this definition for all three
    -- classes; nil-to-Traveler changes the owned source and must replace it.
    c:SetAttribute('TLTEquippedWeapon',classId..'_weapon_traveler')
    value.weapon=assert(Appearance.attachInto(value.model,c,classId));value:rebuild()
    check(value.weapon.grip~=oldGrip,label..' fixture actually replaces original grip')
    value:advance(value.time+.5,fps);guardGeometry(value,label..' replacement weapon')
    check(oldTarget and oldTarget.Parent==nil,label..' old weapon target cannot leak')
    local replacementTarget=value.weapon.grip:FindFirstChild('K0BlockHandTarget')
    c:SetAttribute('K0ClassId','knight');value:advance(value.time+.4,fps)
    check(not replacementTarget.Parent,label..' class change clears support target')
    local key=rig.Name..'/'..classId
    if fps==30 then byRate[key]=poses else
     for age,pose in poses do
      local other=byRate[key][age]
      nearFrame(pose.grip,other.grip,.035,label..' frame rates agree at'..age)
      check((pose.left-other.left).Magnitude<.035 and(pose.right-other.right).Magnitude<.035,label..' hands agree across frame rates at'..age)
     end
    end
    table.insert(report.samples,{rig=rig.Name,class=classId,fps=fps,contact=settled.contact,spacing=settled.spacing,
     shoulderTranslation=settled.translation,grip=settled.relative,shaftY=settled.shaftY,longHoldSeconds=20})
    c:Destroy()
   end)
  end
 end
end

-- A separate frozen implementation must still produce the same unblocked
-- attacks and knight shield block. This catches changes outside the new guard.
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 for _,classId in {'knight','elf','dwarf','mage'}do
  case('unchanged '..rig.Name..'/'..classId,function()
   local actual=fixture(rig,classId,Visual);local expected=fixture(rig,classId,Baseline)
   for _,value in {actual,expected}do
    value:advance(100,60)
    value.character:SetAttribute('K0State',classId=='knight'and'Block'or'Attack')
    value.character:SetAttribute('K0AttackPhase','Windup');value.character:SetAttribute('K0AttackKind',classId=='mage'and'Arcane'or'Basic')
    value.character:SetAttribute('K0AttackStartedAt',100)
   end
   for sample=0,30 do
    local now=100+sample/30
    actual:advance(now,60);expected:advance(now,60)
    for _,part in actual.character:GetChildren()do
     if part:IsA('BasePart')then
      local counterpart=expected.character:FindFirstChild(part.Name)
      nearFrame(actual.frames[part],expected.frames[counterpart],1e-5,'unblocked body unchanged '..classId..'/'..part.Name)
     end
    end
    nearFrame(actual.frames[actual.weapon.grip],expected.frames[expected.weapon.grip],1e-5,'unblocked weapon unchanged '..classId)
    report.nonBlockComparisons+=1
   end
   actual.character:Destroy();expected.character:Destroy()
  end)
 end
end
for _,value in fixtures do if value.character.Parent then value.character:Destroy()end end
for _,template in templates do template:Destroy()end
Client.BlockNaturalBaselineVisual:Destroy()
report.pass=#report.failures==0
print('BLOCK_NATURAL_GUARD_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'natural block geometry failed; inspect named cases')
