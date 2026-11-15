-- Actual native PreSimulation -> engine joint evaluation, with no FK feedback.
-- No Player, input replication, published permissions or device acceptance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated unpublished host only')
local RunService=game:GetService('RunService')
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind='BLOCK_NATURAL_RUNTIME_NATIVE',checks=0,cases=0,frames=0,samples={},failures={},
 disabledProductionScripts=0,coverage='Actual PreSimulation and live native CFrames; no synthetic FK feedback',pass=false}
local function check(value,label)report.checks+=1;assert(value,label)end
local function sameFrame(a,b,label)
 check((a.Position-b.Position).Magnitude<1e-6,label..' position')
 check(math.max((a.RightVector-b.RightVector).Magnitude,(a.UpVector-b.UpVector).Magnitude,(a.LookVector-b.LookVector).Magnitude)<1e-6,label..' basis')
end
local function case(label,callback)
 report.cases+=1
 local ok,err=xpcall(callback,debug.traceback)
 if not ok then table.insert(report.failures,label..': '..tostring(err))end
end

-- This is the final suite in a disposable QA host. Disable executable
-- production bootstraps before Run; their Source and all source assets stay intact.
for _,container in {game.ServerScriptService,game.StarterPlayer,game.ReplicatedFirst}do
 for _,node in container:GetDescendants()do
  if node:IsA('Script')or node:IsA('LocalScript')then
   node.Disabled=true;report.disabledProductionScripts+=1
  end
 end
end
local actors={}
local templates={}
for row,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local description=Instance.new('HumanoidDescription')
 local template=game.Players:CreateHumanoidModelFromDescriptionAsync(description,rig);description:Destroy()
 table.insert(templates,template)
 for column,classId in {'elf','dwarf','mage'}do
  local character=template:Clone();character.Name='NaturalBlockLive_'..rig.Name..'_'..classId
  character.Parent=workspace;character:PivotTo(CFrame.new((column-2)*12,500,(row-1)*20))
  character:SetAttribute('K0ClassId',classId);character:SetAttribute('K0State','Block')
  character:SetAttribute('K0AttackPhase','None');character:SetAttribute('K0Combo',1)
  local root=character.HumanoidRootPart
  for _,node in character:GetDescendants()do
   if node:IsA('BasePart')then
    node.Anchored=node==root;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false
   elseif node:IsA('Script')or node:IsA('LocalScript')then node.Disabled=true end
  end
  character:FindFirstChildOfClass('Humanoid').AutoRotate=false
  local model=Instance.new('Model');model.Name='NaturalBlockLiveAppearance';model.Parent=character
  local weapon=assert(Appearance.attachInto(model,character,classId))
  local originalJoints={}
  for _,node in character:GetDescendants()do
   if(node:IsA('Motor6D')or node:IsA('AnimationConstraint'))and node.Part0 and node.Part1 then
    originalJoints[node]={c0=node.C0,c1=node.C1,part0=node.Part0,part1=node.Part1}
   end
  end
  table.insert(actors,{character=character,root=root,model=model,weapon=weapon,rig=rig,classId=classId,
   expectedRoot=root.CFrame,joints=originalJoints,maxContact=0})
 end
end

local frameError
local connection=RunService.PreSimulation:Connect(function(dt)
 if frameError then return end
 local ok,err=xpcall(function()
  local now=workspace:GetServerTimeNow()
  for _,actor in actors do
   Visual.renderArms(actor.character,dt,now)
   Visual.renderCharacter(actor.character,dt,now)
  end
  report.frames+=1
 end,debug.traceback)
 if not ok then frameError=tostring(err)end
end)
if not RunService:IsRunning()then RunService:Run()end

local function measure(actor,phase)
 local c=actor.character;local label=actor.rig.Name..'/'..actor.classId..'/'..phase
 check(not frameError,'native frame callback '..tostring(frameError))
 sameFrame(actor.root.CFrame,actor.expectedRoot,label..' anchored authoritative root unchanged')
 for joint,original in actor.joints do
  check(joint.Parent~=nil and joint.Part0==original.part0 and joint.Part1==original.part1,label..' original joint graph remains attached')
  sameFrame(joint.C0,original.c0,label..' original C0')
  sameFrame(joint.C1,original.c1,label..' original C1')
  if joint.Name:find('Shoulder')or joint.Name:find('Elbow')or joint.Name:find('Wrist')then
   check(joint.Transform.Position.Magnitude<1e-6,label..' zero limb translation')
  end
 end
 local weapon=actor.weapon
 local target=assert(weapon.grip:FindFirstChild('K0BlockHandTarget'),label..' support target exists')
 local side=actor.classId=='elf'and'Right'or'Left'
 local hand=assert(c:FindFirstChild(side..(actor.rig==Enum.HumanoidRigType.R15 and'Hand'or' Arm')))
 local palm=hand.CFrame:PointToWorldSpace(Vector3.new(0,actor.rig==Enum.HumanoidRigType.R15 and-.12 or-hand.Size.Y*.5,-hand.Size.Z*.5))
 local distance=(palm-target.WorldPosition).Magnitude
 actor.maxContact=math.max(actor.maxContact,distance)
 check(distance<.1,label..' live free palm distance='..distance)
 local socket=weapon.joint.Part0.CFrame*weapon.joint.C0
 local gripSocket=weapon.grip.CFrame*weapon.joint.C1
 check((socket.Position-gripSocket.Position).Magnitude<.001,label..' live grip stays at owned hand socket')
 check(math.abs(weapon.grip.CFrame.UpVector.Y)<.35,label..' live shaft bracing angle')
 local primary=actor.classId=='elf'and'Left'or'Right'
 check(weapon.joint.Part0==c:FindFirstChild(primary..(actor.rig==Enum.HumanoidRigType.R15 and'Hand'or' Arm')),label..' original weapon hand ownership')
 if actor.classId=='elf'then
  check(assert(actor.model:FindFirstChild('NockedArrow')).Transparency==1,label..' guard hides nocked arrow')
  local ik=c:FindFirstChild('K0BowDrawIK',true)
  if ik then check(not ik.Enabled and ik.Weight==0,label..' draw IK disabled')end
 end
 table.insert(report.samples,{rig=actor.rig.Name,class=actor.classId,phase=phase,contact=distance,
  shaftY=weapon.grip.CFrame.UpVector.Y,socketDistance=(socket.Position-gripSocket.Position).Magnitude,frames=report.frames})
end

task.wait(.65)
local deadline=os.clock()+3
while report.frames<8 and not frameError and os.clock()<deadline do task.wait(.05)end
case('native frame scheduler',function()check(report.frames>=8,'at least8 actual PreSimulation frames');check(not frameError,tostring(frameError))end)
for _,actor in actors do case(actor.rig.Name..'/'..actor.classId..'/hold',function()measure(actor,'Hold')end)end
for _,actor in actors do
 actor.root.CFrame*=CFrame.Angles(0,math.rad(45),0);actor.expectedRoot=actor.root.CFrame
end
task.wait(.4)
for _,actor in actors do case(actor.rig.Name..'/'..actor.classId..'/turn',function()measure(actor,'Turn45')end)end
for _,actor in actors do actor.character:SetAttribute('K0State','Idle')end
task.wait(.4)
for _,actor in actors do
 case(actor.rig.Name..'/'..actor.classId..'/release',function()
  check(not actor.weapon.grip:FindFirstChild('K0BlockHandTarget'),'live Idle releases support target')
  sameFrame(actor.root.CFrame,actor.expectedRoot,'release leaves authoritative root unchanged')
 end)
end
connection:Disconnect()
for _,actor in actors do actor.character:Destroy()end
for _,template in templates do template:Destroy()end
report.pass=#report.failures==0
print('BLOCK_NATURAL_RUNTIME_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'native runtime block schedule failed; inspect named cases')
