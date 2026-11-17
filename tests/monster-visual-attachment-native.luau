-- Full production roster: visible geometry must survive gravity and follow its rig.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated engine only')
local Run=game:GetService('RunService')
assert(not Run:IsRunning(),'fresh edit session required')
for _,o in game:GetDescendants()do
 if o:IsA('Script')or o:IsA('LocalScript')then o.Enabled=false end
end
local World=game.ServerScriptService.Server.World
local Shared=game.ReplicatedStorage.Shared
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Field=require(World.TrainingField)
local Sizing=require(World.StoryMonsterSizing)
local Patterns=require(Shared.EnemyPatterns)
local Config=require(Shared.K0Config)
local Campaign=require(Shared.CampaignContent)
local Motion=require(Client.K0EnemyMotion)
local Snapshot=require(Client.EnemyPatternDefinition)
local report={checks=0,failures={},models={},assets={},kinds={},attackSamples=0}
local function check(value,label)
 report.checks+=1
 if not value then table.insert(report.failures,label)end
 return value
end
local function gap(a,b)
 local delta=a:Inverse()*b;local _,angle=delta:ToAxisAngle()
 return delta.Position.Magnitude,math.abs(angle)
end
local function finite(cf)
 for _,v in {cf:GetComponents()}do if v~=v or math.abs(v)==math.huge then return false end end
 return true
end
local kinds={};for kind in Patterns.profiles do table.insert(kinds,kind)end;table.sort(kinds)
local coverage={};for _,kind in kinds do coverage[kind]=true end
for _,chapter in Campaign.chapters do for _,goal in chapter.goals do for _,enemy in goal.enemies or {}do
 check(coverage[enemy.kind]==true,'campaign kind covered '..tostring(enemy.kind))
end end end
local stage=Instance.new('Folder');stage.Name='MonsterAttachmentQA';stage.Parent=workspace
local cases={}
local function addCase(kind,factor,split)
 local rigScale,visualScale=Sizing.forStory(kind,Patterns.profiles[kind].boss)
 local actor=Field.makeEnemy(stage,kind,0,10000,rigScale,visualScale*factor)
 local root=actor.HumanoidRootPart;root.Anchored=true
 if split then
  actor.Name='SmallSlime';actor:SetAttribute('SlimeSplitGeneration',1)
  actor:ScaleTo(Config.SlimeSplit.sizeMultiplier)
  for _,name in {'TdMonsterTargetHeight','TdMonsterVisualMultiplier','TdMonsterScale'}do
   actor:SetAttribute(name,actor:GetAttribute(name)*Config.SlimeSplit.sizeMultiplier)
  end
 end
 actor:PivotTo(CFrame.new((#cases%15)*40,500,2000+math.floor(#cases/15)*40))
 local visual=assert(actor:FindFirstChild('TdMonsterVisual'))
 local label=(split and 'SmallSlime' or kind)..' x'..factor
 local row={kind=kind,variant=split and 'SmallSlime' or kind,factor=factor,height=actor:GetAttribute('TdMonsterTargetHeight'),parts=0,meshes=0,bones=0,maxGravityDrift=0,maxMoveDrift=0,maxWeldDrift=0}
 local case={actor=actor,root=root,parts={},row=row,label=label}
 local visible=0
 for _,p in visual:GetDescendants()do
  if p:IsA('Bone')then row.bones+=1 end
  if not p:IsA('BasePart')then continue end
  row.parts+=1
  if p.Transparency<1 then visible+=1 end
  check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,label..' presentation physics '..p:GetFullName())
  if p:IsA('MeshPart')then
   row.meshes+=1
   check(p.Transparency<1 and p.LocalTransparencyModifier<1,label..' mesh visible '..p.Name)
   check(p.MeshId~='' and p.Size.X>0 and p.Size.Y>0 and p.Size.Z>0,label..' valid mesh '..p.Name)
   if p.MeshId~=''then report.assets[p.MeshId]=true end
   if p.TextureID~=''then report.assets[p.TextureID]=true end
   for _,appearance in p:GetChildren()do if appearance:IsA('SurfaceAppearance')then
    for _,name in {'ColorMap','MetalnessMap','NormalMap','RoughnessMap'}do
     local id=appearance[name];if id~=''then report.assets[id]=true end
    end
   end end
   if p:FindFirstChildWhichIsA('Bone',true)then check(p.HasSkinnedMesh,label..' skinned mesh '..p.Name)end
  end
  local link
  for _,w in actor:GetDescendants()do
   if (w:IsA('WeldConstraint')or w:IsA('JointInstance'))and w.Enabled and (w.Part0==p or w.Part1==p)then
    local anchor=w.Part0==p and w.Part1 or w.Part0
    if anchor and anchor~=p then link={anchor=anchor,offset=anchor.CFrame:ToObjectSpace(p.CFrame)};break end
   end
  end
  check(link~=nil,label..' jointed part '..p.Name)
  table.insert(case.parts,{part=p,offset=root.CFrame:ToObjectSpace(p.CFrame),link=link})
 end
 check(row.meshes>0 and visible>0,label..' visible model exists')
 check(actor.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,label..' atomic rig streaming')
 table.insert(report.models,row);table.insert(cases,case)
end
local ok,err=xpcall(function()
 Run:Run()
 for _,kind in kinds do
  table.insert(report.kinds,kind)
  for _,factor in {.6,1,1.4}do addCase(kind,factor,false)end
  task.wait()
 end
 for _,factor in {.6,1,1.4}do addCase('Slime',factor,true)end
 task.wait(.75)
 for _,case in cases do
  local connected={};for _,p in case.root:GetConnectedParts(true)do connected[p]=true end
  for _,entry in case.parts do
   local p=entry.part
   check(p:IsDescendantOf(case.actor),case.label..' survives gravity '..p.Name)
   check(connected[p]==true,case.label..' connected assembly '..p.Name)
   local drift,angle=gap(entry.offset,case.root.CFrame:ToObjectSpace(p.CFrame))
   case.row.maxGravityDrift=math.max(case.row.maxGravityDrift,drift)
   check(drift<.002 and angle<.003,case.label..' gravity attachment '..p.Name..' drift='..drift)
  end
  case.root.CFrame=case.root.CFrame*CFrame.new(7,3,-11)*CFrame.Angles(0,1.2,0)
 end
 task.wait(.5)
 for _,case in cases do
  for _,entry in case.parts do
   local drift,angle=gap(entry.offset,case.root.CFrame:ToObjectSpace(entry.part.CFrame))
   case.row.maxMoveDrift=math.max(case.row.maxMoveDrift,drift)
   check(drift<.002 and angle<.003,case.label..' movement attachment '..entry.part.Name..' drift='..drift)
  end
  local state=Motion.bind(case.actor)
  if not check(state~=nil,case.label..' animation binds')then continue end
  local health=case.actor.Humanoid.Health;local original=case.root.CFrame
  for index,d in Patterns.profiles[case.row.kind].attacks do
   report.attackSamples+=1
   local start=index*100
   case.actor:SetAttribute('K0PatternId',d.id);case.actor:SetAttribute('K0PatternMotion',d.motion)
   case.actor:SetAttribute('K0AttackSeq',index)
   case.actor:SetAttribute('K0EnemyAttackClock',string.format('%d|%d|%.8f|%.8f|%.8f|%d',index,start,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
   Snapshot.message({kind='begin',id=d.id,sequence=index,model=case.actor,definition=d,origin=case.root.Position,direction=-Vector3.zAxis,aim=case.root.Position-Vector3.zAxis*12})
   for _,phase in {{'Windup',d.windup*.75},{'Active',d.windup},{'Recovery',d.windup+d.active+d.recovery}}do
    case.actor:SetAttribute('K0EnemyState',phase[1]);Motion.step(state,1/60,start+phase[2]);task.wait()
    for _,entry in case.parts do
     local p=entry.part
     check(p:IsDescendantOf(case.actor)and finite(p.CFrame),case.label..' animated part survives '..p.Name)
     if entry.link then
      local drift,angle=gap(entry.link.offset,entry.link.anchor.CFrame:ToObjectSpace(p.CFrame))
      case.row.maxWeldDrift=math.max(case.row.maxWeldDrift,drift)
      check(drift<.002 and angle<.003,case.label..' animated weld '..p.Name..' drift='..drift)
     end
    end
   end
  end
  for _,bones in {state.gloam and state.gloam.bones or {},state.caster and state.caster.bones or {}}do
   for _,bone in bones do check(finite(bone.TransformedWorldCFrame),case.label..' finite animated skin '..bone.Name)end
  end
  check(case.root.CFrame==original and case.actor.Humanoid.Health==health,case.label..' gameplay root and health preserved')
  Motion.unbind(state)
 end
end,debug.traceback)
if not ok then table.insert(report.failures,err)end
Run:Stop();stage:Destroy()
report.pass=#report.failures==0
print('MONSTER_VISUAL_ATTACHMENT '..game.HttpService:JSONEncode(report))
assert(report.pass,'Monster visual attachment regression: '..#report.failures..' failures')
return report
