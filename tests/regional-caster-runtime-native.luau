-- The assembler injects independent GLB world-pose fixtures, not this implementation.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(2)end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Caster=require(Client.RegionalCasterMotion)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local report={kind='REGIONAL_CASTER_RUNTIME_NATIVE',checks=0,failures={},assets={},maxSourcePositionFraction=0,maxSourceAngle=0}
local function check(v,label)report.checks+=1;assert(v,label)end
local function cf(m,h)
 local right=Vector3.new(m[1][1],m[2][1],m[3][1]).Unit
 local up=Vector3.new(m[1][2],m[2][2],m[3][2]);up=(up-right*up:Dot(right)).Unit
 return CFrame.fromMatrix(Vector3.new(m[1][4],m[2][4],m[3][4])*h,right,up,right:Cross(up))
end
local folder=Instance.new('Folder');folder.Name='MR01RuntimeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 for kind,fixture in fixtures do
  for _,multiplier in {0.6,1,1.4}do
   local model=Field.makeEnemy(folder,kind,0,0,1,multiplier);local root=model.HumanoidRootPart;root.Anchored=true
   local s=assert(Motion.bind(model));local c=assert(s.caster);local visual=model.TdMonsterVisual;local original=root.CFrame;local health=model.Humanoid.Health
   local meshes=0;for _,o in visual:GetDescendants()do
    if o:IsA('MeshPart')then meshes+=1;check(o.MeshId~='' and o.TextureID~='',kind..' pinned mesh and texture')end
    if o:IsA('BasePart')then check(not o.CanCollide and not o.CanTouch and not o.CanQuery and (o.Anchored or o.Massless),kind..' presentation cannot collide: '..o.Name)end
   end
   check(meshes==2 and visual:FindFirstChild('Staff')~=nil,kind..' body and whole staff imported')
   check(visual.VisualRoot.CFrame.LookVector:Dot(root.CFrame.LookVector)>.999,kind..' imported -Z faces server forward')
   for _,pose in fixture.poses do
    local sample=Caster.sample(kind,pose.clip,pose.phase,s.height)
    for name,frame in sample do c.bones[name].Transform=frame end
    for i,bone in fixture.bones do
     local actual=visual.VisualRoot.CFrame:ToObjectSpace(c.bones[bone.name].TransformedWorldCFrame)
     local basis=CFrame.Angles(0,math.pi,0)
     local expected=basis*cf(pose.world[i],s.height)*basis:Inverse()
     local delta=expected:Inverse()*actual;local _,angle=delta:ToAxisAngle()
     report.maxSourcePositionFraction=math.max(report.maxSourcePositionFraction,delta.Position.Magnitude/s.height)
     report.maxSourceAngle=math.max(report.maxSourceAngle,math.abs(angle))
     -- Studio resamples the source into 24 Hz keys. World poses between keys
     -- accumulate small local interpolation differences along the limb chain.
     check(delta.Position.Magnitude/s.height<.002 and math.abs(angle)<.015,kind..' resampled GLB pose '..pose.clip..' '..bone.name..' gap='..delta.Position.Magnitude..' angle='..angle)
    end
   end
   for _,hz in {30,60,144}do for sequence=1,4 do
    local clip=(sequence>=3 and 'Heavy' or 'Attack')..(sequence%2==0 and 'Alt' or '')
    model:SetAttribute('K0EnemyAttackClock',sequence..'|100|1|0.2|0.8|'..(sequence>=3 and '1'or'0'));model:SetAttribute('K0EnemyState','Active')
    Motion.step(s,1/hz,101)
    local expected=Caster.sample(kind,clip,.62,s.height)
    for name,frame in expected do local delta=frame:Inverse()*c.bones[name].Transform;local _,angle=delta:ToAxisAngle();check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,kind..' authoritative contact '..hz)end
    local focus=c.bones.Staff.TransformedWorldCFrame:PointToWorldSpace(c.tip)
    check((focus-s.weaponFX.a.WorldPosition).Magnitude<.0001,kind..' focus follows this frame skinned staff')
    check(s.weaponFX.trail.Enabled,kind..' contact trail')
    local before=c.bones.HandR.Transform
    model:SetAttribute('K0EnemyStunUntil',200);Motion.step(s,0,101)
    local delta=before:Inverse()*c.bones.HandR.Transform;local _,angle=delta:ToAxisAngle()
    check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,kind..' no discontinuity on arbitrary interruption')
    Motion.step(s,1/hz,101.2);check(not s.weaponFX.trail.Enabled and c.clip=='Stunned',kind..' stun cancels attack presentation')
    model:SetAttribute('K0EnemyStunUntil',nil);model:SetAttribute('K0EnemyState','Exposed');Motion.step(s,1/hz,101.4)
    check(c.clip=='Exposed',kind..' exposed has its own imported clip')
    model:SetAttribute('K0EnemyState','Idle');Motion.step(s,1/hz,101.6);Motion.step(s,1/hz,101.8)
    check(c.clip=='Idle' and root.CFrame==original and model.Humanoid.Health==health,kind..' return preserves server root and health')
   end end
   if multiplier==1 then
    local assets={};for _,o in visual:GetChildren()do if o:IsA('MeshPart')then table.insert(assets,o)end end
    game:GetService('ContentProvider'):PreloadAsync(assets,function(id,status)report.assets[id]=status.Name end)
   end
   Motion.unbind(s)
   check(not visual:FindFirstChild('K0WeaponPresentation',true),kind..' effect cleanup')
   for _,b in c.bones do check(b.Transform==CFrame.identity,kind..' Bone reset')end
   model:Destroy()
  end
 end
 for id,status in report.assets do check(status=='Success','asset fetch '..id..' '..status)end
 -- A body can arrive before its final streamed Bone. Binding must wait and
 -- recover on DescendantAdded; removing the model must clear local effects.
 local streamed=Instance.new('Folder');streamed.Name='StreamedCasters';streamed.Parent=folder
 local late=Field.makeEnemy(folder,'QueenIceElf',0,0,1,1);late.HumanoidRootPart.Anchored=true
 local hand=late.TdMonsterVisual:FindFirstChild('HandL',true);local parent=hand.Parent;hand.Parent=nil
 check(Motion.bind(late)==nil,'partial caster cannot bind without all nine Bones')
 local stop=Motion.start(streamed);late.Parent=streamed;task.wait(.1)
 hand.Parent=parent;late:SetAttribute('K0EnemyState','Windup')
 late:SetAttribute('K0EnemyAttackClock','1|'..(workspace:GetServerTimeNow()-.7)..'|1|0.2|0.8|0');task.wait(.15)
 check(late.TdMonsterVisual:FindFirstChild('K0WeaponPresentation',true)~=nil,'late Bone arrival binds presentation automatically')
 late.Parent=folder;task.wait(.1)
 check(not late.TdMonsterVisual:FindFirstChild('K0WeaponPresentation',true),'caster stream-out cleans effects')
 stop();late:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();report.pass=#report.failures==0
print('REGIONAL_CASTER_RUNTIME_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Imported caster runtime failed')
