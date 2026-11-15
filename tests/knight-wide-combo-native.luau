-- TLT-005/084: frozen original vs candidate native R6/R15 sword geometry.
-- Synthetic accepted-server clocks measure motion; Player input and taste need client QA.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated host only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local BaselineConfig=require(Client.KnightWideBaselineConfig)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind='KNIGHT_WIDE_COMBO_NATIVE',baselineCommit=knightWideBaselineCommit,
 measurementOnly=knightWideMeasurementOnly,checks=0,samples={},pass=false}
local function check(value,label)report.checks+=1;assert(value,label)end
local function same(actual,expected,label)
 check(typeof(actual)==typeof(expected),label..' type')
 if type(expected)=='table' then
  for key,value in expected do same(actual[key],value,label..'.'..tostring(key))end
  for key in actual do check(expected[key]~=nil,label..' unexpected '..tostring(key))end
 else check(actual==expected,label..' unchanged')end
end
same(Config.BasicAttackProfiles.knight,BaselineConfig.BasicAttackProfiles.knight,'Knight server budgets')
same(Config.Skills.knight,BaselineConfig.Skills.knight,'Knight skill contracts')

local function measure(rig,visual,motion,combo)
 local description=Instance.new('HumanoidDescription')
 local character=game.Players:CreateHumanoidModelFromDescriptionAsync(description,rig);description:Destroy()
 character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0))
 character:SetAttribute('K0ClassId','knight');character:SetAttribute('K0State','Attack')
 character:SetAttribute('K0AttackKind','Basic');character:SetAttribute('K0Combo',combo)
 character:SetAttribute('K0AttackStartedAt',100)
 local model=Instance.new('Model');model.Name='KnightWideMotionAppearance';model.Parent=character
 local weapon=assert(Appearance.attachInto(model,character,'knight'))
 local shield=assert(Appearance.attachShieldInto(model,character))
 local shieldHand=shield.joint.Part0
 local shieldOffset=shieldHand.CFrame:ToObjectSpace(shield.shield.CFrame)
 local root=character.HumanoidRootPart;local initialRoot=root.CFrame
 local initialSocket=weapon.joint.C0
 local joints={}
 for _,joint in character:GetDescendants()do
  if(joint:IsA('Motor6D')or joint:IsA('AnimationConstraint'))and joint.Part0 and joint.Part1 then joints[joint.Part1]=joint end
 end
 local function frame(part)
  local joint=joints[part]
  return joint and frame(joint.Part0)*joint.C0*joint.Transform*joint.C1:Inverse()or part.CFrame
 end
 local definition=Config.BasicAttackProfiles.knight.attacks[combo]
 local total=definition.windup+definition.active+definition.recovery
 local opening=definition.windup*.45
 local late=definition.windup+definition.active+definition.recovery*.15
 local result={pathLength=0,torsoYawMin=math.huge,torsoYawMax=-math.huge,
  minY=math.huge,maxReach=0,maxStep=0,minShieldSeparation=math.huge}
 local function sample(age)
  character:SetAttribute('K0AttackPhase',age<definition.windup and'Windup'or age<definition.windup+definition.active and'Active'or'Recovery')
  visual.renderArms(character,1/60,100+age);visual.renderCharacter(character,1/60,100+age)
  local grip=frame(weapon.grip)
  local tip=root.CFrame:PointToObjectSpace(grip:PointToWorldSpace(weapon.tip.Position))
  local socket=frame(weapon.joint.Part0)*weapon.joint.C0
  check((socket.Position-grip.Position).Magnitude<.0001,'Native sword remains in hand')
  check(weapon.joint.C0==initialSocket,'Authored motion leaves palm socket unchanged')
  check(root.CFrame==initialRoot,'Native motion leaves server root unchanged')
  -- Exact held-shield OBB versus the cutting segment, excluding the hilt.
  local box=frame(shieldHand)*shieldOffset
  local first=box:PointToObjectSpace(grip:PointToWorldSpace(Vector3.new(0,.7,0)))
  local last=box:PointToObjectSpace(grip:PointToWorldSpace(weapon.tip.Position))
  local delta,half=last-first,shield.shield.Size/2
  local low,high=0,1
  for _,axis in {'X','Y','Z'}do
   if math.abs(delta[axis])<.00001 then
    if math.abs(first[axis])>half[axis]then high=-1;break end
   else
    local a,b=(-half[axis]-first[axis])/delta[axis],(half[axis]-first[axis])/delta[axis]
    low,high=math.max(low,math.min(a,b)),math.min(high,math.max(a,b))
   end
  end
  check(low>high,'Wide sword clears shield '..rig.Name..'/'..combo..' age='..age)
  -- Measure the nearest sampled cutting point to the shield OBB as evidence.
  for i=0,16 do
   local p=first+delta*(i/16)
   local distance=Vector3.new(math.max(0,math.abs(p.X)-half.X),math.max(0,math.abs(p.Y)-half.Y),math.max(0,math.abs(p.Z)-half.Z)).Magnitude
   result.minShieldSeparation=math.min(result.minShieldSeparation,distance)
  end
  return tip
 end
 local previous
 for i=0,120 do
  local tip=sample(total*i/120)
  if previous then result.maxStep=math.max(result.maxStep,(tip-previous).Magnitude)end
  result.minY=math.min(result.minY,tip.Y)
  result.maxReach=math.max(result.maxReach,Vector3.new(tip.X,0,tip.Z).Magnitude)
  previous=tip
 end
 -- These are the existing native safety bounds; widening never raises them.
 check(result.maxStep<.7,'Existing bounded sword speed')
 check(result.minY>-3.4,'Existing floor clearance')
 check(result.maxReach<6.5,'Existing combat reach bound')
 previous=nil
 for i=0,256 do
  local age=opening+(late-opening)*i/256
  local tip=sample(age)
  if previous then result.pathLength+=(tip-previous).Magnitude end
  previous=tip
  local pose=motion.sample('knight',combo,age,nil,nil,nil,rig)
  result.torsoYawMin=math.min(result.torsoYawMin,pose.angles.torso.Y)
  result.torsoYawMax=math.max(result.torsoYawMax,pose.angles.torso.Y)
 end
 result.torsoYawRange=result.torsoYawMax-result.torsoYawMin
 character:Destroy()
 return result
end

local BaselineVisual=require(Client.KnightWideBaselineVisual)
local BaselineMotion=require(Client.KnightWideBaselineMotion)
local Visual=require(Client.K0SwordVisual)
local Motion=require(Client.K0MeleeMotion)
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 for combo=1,3 do
  local baseline=measure(rig,BaselineVisual,BaselineMotion,combo)
  local candidate=measure(rig,Visual,Motion,combo)
  local ratio=candidate.pathLength/baseline.pathLength
  local yawGain=candidate.torsoYawRange-baseline.torsoYawRange
  local row={rig=rig.Name,combo=combo,baseline=baseline,candidate=candidate,pathRatio=ratio,torsoYawGain=yawGain}
  table.insert(report.samples,row)
  print('KNIGHT_WIDE_COMBO_SAMPLE '..game.HttpService:JSONEncode(row))
  if not knightWideMeasurementOnly then
   check(ratio>=1.05,'Each sword cutting path grows at least5% '..rig.Name..'/'..combo..' ratio='..ratio)
   check(yawGain>=8,'Each stroke adds at least8degrees of torso winding '..rig.Name..'/'..combo..' gain='..yawGain)
  end
 end
end
for _,name in {'KnightWideBaselineConfig','KnightWideBaselineDowncut','KnightWideBaselineRisingCut','KnightWideBaselineSweep','KnightWideBaselineCombo','KnightWideBaselineMotion','KnightWideBaselineVisual'}do
 Client[name]:Destroy()
end
report.pass=true
print('KNIGHT_WIDE_COMBO_NATIVE '..game.HttpService:JSONEncode(report))
