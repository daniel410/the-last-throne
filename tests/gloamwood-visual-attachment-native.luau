-- Isolated physics regression: the visible skin must follow the gameplay root.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated engine only')
local Run=game:GetService('RunService')
assert(not Run:IsRunning(),'fresh edit session required')
for _,o in game:GetDescendants()do
 if o:IsA('Script')or o:IsA('LocalScript')then o.Enabled=false end
end
local Appearance=require(game.ServerScriptService.Server.World.GloamwoodAppearance)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.GloamwoodMotion)
local folder=Instance.new('Folder');folder.Name='GloamwoodAttachmentQA';folder.Parent=workspace
local report={checks=0,models={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local function near(a,b,message)
 local delta=a:Inverse()*b;local _,angle=delta:ToAxisAngle()
 check(delta.Position.Magnitude<.001 and math.abs(angle)<.002,message)
end
local cases={}
local kinds={'HollowbarkSovereign','AncientHollowbark','Webling','Silkweaver','Barkstalker','Gloambat','VenomcoilCentipede','VenomcoilKing','WidowQueen'}
for index,kind in kinds do
 for _,multiplier in {.6,1,1.4}do
  if kind=='HollowbarkSovereign' and multiplier==1 then multiplier=12/14 end
  local rig=Instance.new('Model');rig.Name=kind;rig:SetAttribute('EnemyKind',kind)
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1)
  root.CFrame=CFrame.new(index*30,100,multiplier*30);root.Anchored=true;root.CanCollide=false;root.Parent=rig
  rig.PrimaryPart=root
  local visual=Appearance.attach(rig,kind,3,multiplier);rig.Parent=folder
  local body=visual.Body;local bind=root.CFrame:ToObjectSpace(body.CFrame)
  local count=0;for _,o in visual:GetDescendants()do if o:IsA('WeldConstraint')then count+=1 end end
  table.insert(cases,{rig=rig,root=root,body=body,bind=bind,kind=kind,multiplier=multiplier,welds=count})
  check(not body.Anchored and body.Massless and not body.CanCollide and not body.CanTouch and not body.CanQuery,kind..' presentation-only physics')
  local source=kind=='HollowbarkSovereign' and game.ServerStorage.HollowbarkSovereignTemplate or game.ServerStorage.GloamwoodMeshyModels[kind]
  check(body.MeshId==source.Body.MeshId and body.TextureID==source.Body.TextureID,kind..' original mesh and texture preserved')
  check(math.abs(rig:GetAttribute('TdMonsterTargetHeight')-(source.TargetHeight.Value+source.HoverHeight.Value)*multiplier)<.0001,kind..' authored height preserved')
  local bones={};for _,o in visual:GetDescendants()do if o:IsA('Bone')then bones[o.Name]=o end end
  for _,clip in {'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned','Exposed','Return','Interrupted'}do
   for _,phase in {0,.5,1}do
    for name,pose in Motion.sample(kind,clip,phase,rig:GetAttribute('TdMonsterScale'))do
     check(bones[name]~=nil and pose.Position.Magnitude<100,kind..' skin animation preserved '..clip..' '..name)
     bones[name].Transform=pose
    end
   end
  end
 end
end
local ok,err=xpcall(function()
 Run:Run();task.wait(.75)
 for _,case in cases do
  local label=case.kind..' x'..case.multiplier
  check(case.body.Parent~=nil,label..' visible body survives gravity')
  local error=(case.root.CFrame:ToObjectSpace(case.body.CFrame).Position-case.bind.Position).Magnitude
  table.insert(report.models,{kind=case.kind,multiplier=case.multiplier,welds=case.welds,gravityOffsetError=error})
  near(case.root.CFrame:ToObjectSpace(case.body.CFrame),case.bind,label..' skin follows root under gravity')
  check(case.welds==2,label..' has exactly one body weld and one gameplay-root weld')
  check(table.find(case.root:GetConnectedParts(true),case.body)~=nil,label..' single connected assembly')
  case.root.CFrame=case.root.CFrame*CFrame.new(7,3,-11)*CFrame.Angles(0,1.2,0)
 end
 task.wait(.5)
 for _,case in cases do
  near(case.root.CFrame:ToObjectSpace(case.body.CFrame),case.bind,case.kind..' follows translation and rotation')
  table.insert(report.models,{kind=case.kind,multiplier=case.multiplier,height=case.rig:GetAttribute('TdMonsterTargetHeight'),bodyOffsetError=(case.root.CFrame:ToObjectSpace(case.body.CFrame).Position-case.bind.Position).Magnitude})
 end
end,debug.traceback)
Run:Stop();folder:Destroy()
report.pass=ok;report.error=err
print('GLOAMWOOD_VISUAL_ATTACHMENT '..game.HttpService:JSONEncode(report))
assert(ok,err)
return report
