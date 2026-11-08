local Field=require(game.ServerScriptService.Server.World.TrainingField)
local Appearance=require(game.ServerScriptService.Server.World.GloamwoodAppearance)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(client.K0EnemyMotion)
local Gloam=require(client.GloamwoodMotion)
local folder=Instance.new('Folder');folder.Name='GloamwoodMeshyReview';folder.Parent=workspace
local count=0;local report={models={},assets={}}
local function check(v,message)assert(v,message);count+=1 end
local function near(a,b,message)
 local delta=a:Inverse()*b;local _,angle=delta:ToAxisAngle()
 check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,message)
end
local kinds={'Webling','Silkweaver','Barkstalker','Gloambat','VenomcoilCentipede','WidowQueen','AncientHollowbark','VenomcoilKing'}
for index,kind in kinds do
 local specification=Appearance.describe(kind)
 check(specification.prototype==false and specification.version==3,kind..' uses Meshy')
 for _,multiplier in {.6,1,1.4}do
  local model=Field.makeEnemy(folder,kind,(index-1)%4*17,math.floor((index-1)/4)*20,1,multiplier)
  local root=model.HumanoidRootPart;root.Anchored=true
  local state=assert(Motion.bind(model),kind..' motion bind');local c=assert(state.gloam)
  local visual=model.TdMonsterVisual;local body=visual.Body;local original=root.CFrame;local health=model.Humanoid.Health
  check(visual.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,kind..' atomic streaming')
  check(body.MeshId~='' and body.TextureID~='',kind..' source mesh and texture')
  check(body.Color==Color3.new(1,1,1),kind..' source texture has no importer gray tint')
  if kind=='VenomcoilKing'then
   check(body.DoubleSided,kind..' preserves source double-sided material')
   check(body.RenderFidelity==Enum.RenderFidelity.Precise,kind..' preserves thin tail detail')
  end
  local meshes,bones,legs=0,0,0
  for _,o in visual:GetDescendants()do
   if o:IsA('MeshPart')then meshes+=1 end
   if o:IsA('Bone')then bones+=1;if o.Name:match('^LegUpper_')then legs+=1 end end
   if o:IsA('BasePart')then check(not o.CanCollide and not o.CanTouch and not o.CanQuery and o.Massless,kind..' decoration has no gameplay collision')end
   check(not o:IsA('LuaSourceContainer') and not o:IsA('PackageLink'),kind..' no imported code/package dependency')
  end
  check(meshes==1 and bones==#c.data.bones,kind..' complete intact skin')
  if kind=='Webling'or kind=='Silkweaver'or kind=='Barkstalker'or kind=='WidowQueen'then check(legs==8,kind..' eight articulated legs')end
  check(visual.VisualRoot.CFrame.LookVector:Dot(root.CFrame.LookVector)>.999,kind..' native -Z orientation')
  check(visual.VisualRoot.Position.Y-original.Position.Y<0,kind..' foot pivot below server root')
  for _,clip in {'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned','Exposed','Return','Interrupted'}do
   for _,phase in {0,.25,.5,.62,.75,1}do
    local pose=Gloam.sample(kind,clip,phase,c.scale)
    for _,name in c.data.bones do
     local cf=pose[name];check(cf and cf.Position.Magnitude<100 and cf.Position.X==cf.Position.X,kind..' finite authored '..clip..' '..name)
    end
   end
  end
  for _,hz in {30,60,144}do
   for sequence=1,4 do
    local clip=(sequence>=3 and 'Heavy'or 'Attack')..(sequence%2==0 and 'Alt'or '')
    model:SetAttribute('K0EnemyState','Active');model:SetAttribute('K0EnemyAttackClock',sequence..'|100|1|0.2|0.8|'..(sequence>=3 and '1'or '0'))
    Motion.step(state,1/hz,101)
    local expected=Gloam.sample(kind,clip,.62,c.scale)
    for _,name in c.data.bones do near(expected[name],c.bones[name].Transform,kind..' contact timing '..name)end
    check(c.clip==clip and c.active,kind..' authoritative attack clock')
    local before=c.bones.Body.Transform
    model:SetAttribute('K0EnemyStunUntil',200);Motion.step(state,0,101)
    near(before,c.bones.Body.Transform,kind..' interruption starts from actual pose')
    Motion.step(state,1/hz,101.2);check(c.clip=='Stunned' and not c.active,kind..' stun interrupts attack')
    model:SetAttribute('K0EnemyStunUntil',nil);model:SetAttribute('K0EnemyState','Exposed');Motion.step(state,1/hz,101.4)
    check(c.clip=='Exposed',kind..' exposed clip')
    model:SetAttribute('K0EnemyState','Idle');Motion.step(state,1/hz,101.6);Motion.step(state,1/hz,101.8)
    check(c.clip=='Idle' and root.CFrame==original and model.Humanoid.Health==health,kind..' preserves authoritative root and HP')
   end
  end
  model:SetAttribute('K0EnemyState','Chase');root.CFrame=original*CFrame.new(0,0,-.1);Motion.step(state,1/60,102)
  check(c.clip=='Walk' and c.phase>0,kind..' distance-driven gait')
  model:SetAttribute('K0EnemyState','Dead');Motion.step(state,1/60,103)
  for _,b in c.bones do near(b.Transform,CFrame.identity,kind..' dead cleanup')end
  Motion.unbind(state)
  for _,b in c.bones do near(b.Transform,CFrame.identity,kind..' unbind cleanup')end
  if multiplier==1 then
   table.insert(report.models,{kind=kind,mesh=body.MeshId,texture=body.TextureID,bones=bones,height=specification.targetHeight})
   game:GetService('ContentProvider'):PreloadAsync({body},function(id,status)report.assets[id]=status.Name end)
   local pose=Gloam.sample(kind,'Walk',.25,c.scale);for name,cf in pose do c.bones[name].Transform=cf end
  else model:Destroy()end
 end
end
local normal=game.ServerStorage.GloamwoodMeshyModels.VenomcoilCentipede
local king=game.ServerStorage.GloamwoodMeshyModels.VenomcoilKing
check(normal.SourceToStudScale.Value*normal.Body.Size.Z<king.SourceToStudScale.Value*king.Body.Size.Z,'Normal centipede is shorter than King')
report.checks=count;report.status='PASS'
print('GLOAMWOOD_MESHY_RESULT='..game.HttpService:JSONEncode(report))
