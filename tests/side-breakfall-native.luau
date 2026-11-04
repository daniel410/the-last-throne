local Players=game:GetService('Players')
local visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SideDiveMotion)
local duration=require(game.ReplicatedStorage.Shared.K0Config).Dodge.sideRoll.moveDuration
local count=0
local function check(v,label)count+=1;assert(v,label)end
local function nearFrame(a,b,label)
 check((a.Position-b.Position).Magnitude<.002,label..' position')
 local _,angle=a:ToObjectSpace(b):ToAxisAngle();check(math.abs(angle)<.002,label..' rotation')
end
for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
 for _,class in ipairs({'knight','dwarf','elf','mage'})do
  local c=Players:CreateHumanoidModelFromDescriptionAsync(Instance.new('HumanoidDescription'),rig)
  c.Parent=workspace;c:PivotTo(CFrame.new(0,10,0))
  c:SetAttribute('K0ClassId',class);c:SetAttribute('K0State','Dodge');c:SetAttribute('K0DodgeKind','SideRoll');c:SetAttribute('K0DodgeStartedAt',100)
  local root=c.HumanoidRootPart
  local rootBefore=root.CFrame
  local joints={};for _,j in ipairs(c:GetDescendants())do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
  local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
  local lower=c:FindFirstChild('LowerTorso');local joint=lower and lower:FindFirstChild('Root')or root:FindFirstChild('RootJoint')
  for _,side in ipairs({-1,1})do
   c:SetAttribute('K0DodgeSide',side)
   for _,hz in ipairs({30,60,144})do
    local previous
    for tick=0,math.ceil(duration*hz)do
     local age=math.min(tick/hz,duration);local u=age/duration
     local sample=motion.sample(age,duration,side)
     visual.renderArms(c,1/hz,100+age)
     local b=joint.C0.Rotation;local actual=b*joint.Transform*b:Inverse()
     nearFrame(actual,sample.root,'sampled root')
     nearFrame(root.CFrame,rootBefore,'physics root fixed')
     if u>=.36 and u<=.82 then
      check(math.abs(actual.UpVector.Y)<.002,'body long axis horizontal through entire ground roll')
      check(actual.Position.Y< -1,'ground roll stays low')
      check(side*actual.UpVector.X>.99,'head points toward selected side, feet trail sideways')
     end
     if previous then
      local _,turn=previous:ToObjectSpace(actual):ToAxisAngle()
      check(math.abs(turn)<1.25,'no pose discontinuity')
     end
     previous=actual
    end
   end
   visual.renderArms(c,1/60,100+duration*.12)
   for _,limb in ipairs({'Right','Left'})do
    local j=c:FindFirstChild(limb..'Shoulder',true)or c:FindFirstChild(limb..' Shoulder',true)
    local b=j.C0.Rotation;local p=b*j.Transform*b:Inverse()
    check(side*p:VectorToWorldSpace(-Vector3.yAxis).X>.99,'both hands extend toward chosen side')
   end
   -- Quarter turns must show all four sides of the torso exactly once.
   local p0=motion.sample(duration*.36,duration,side).root
   local p1=motion.sample(duration*.59,duration,side).root
   check(p0.LookVector:Dot(p1.LookVector)<-.99,'half barrel turn on ground')
   local p2=motion.sample(duration*.82,duration,side).root
   check(p0.LookVector:Dot(p2.LookVector)>.99,'full barrel turn before getting up')
   nearFrame(motion.sample(duration,duration,side).root,CFrame.identity,'upright finish')
   c:SetAttribute('K0State','Idle');for _=1,45 do visual.renderArms(c,1/60,102)end
   nearFrame(joint.Transform,CFrame.identity,'idle restores root')
   c:SetAttribute('K0State','Dodge')
  end
  c:Destroy()
 end
end
print('SIDE_BREAKFALL_NATIVE '..count..' checks passed')
