-- Real server targeting and real client socket/pose code, including near shots.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated direction fixture only')
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local report={checks=0,failures={}}
local copies={}
local function check(v,label)report.checks+=1;assert(v,label)end
local function test(label,f)local ok,err=xpcall(f,debug.traceback);if not ok then table.insert(report.failures,{case=label,error=err})end end
local function instrument(source,tail)
 local copy=source:Clone();copy.Name='ArrowDirectionQA';copy.Source=copy.Source:gsub('return %w+%s*$',function()return tail end);copy.Parent=source.Parent;table.insert(copies,copy);return require(copy)
end
local folder=Instance.new('Folder');folder.Name='ArrowDirectionQA';folder.Parent=workspace
local function rig(name,position)
 local c=Instance.new('Model');c.Name=name;local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.CFrame=CFrame.new(position);root.Parent=c
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;c.Parent=folder;return c,root,h
end
local api=instrument(game.ServerScriptService.Server.Combat.CombatService,[[return {shot=applyArrowShot,enemies=enemyStates,setFolder=function(f)enemyFolder=f end,spy=function(f)damageEnemy=f end}]])
api.setFolder(folder)
local c,root,h=rig('Archer',Vector3.new(20000,1000,20000));c:SetAttribute('K0ClassId','elf')
local enemy,er,eh=rig('Selected',root.Position+Vector3.new(0,0,-12))
api.enemies[enemy]={model=enemy,root=er,humanoid=eh,id=1}
local hits=0;api.spy(function()hits+=1 end)
local defs={Config.BasicAttackProfiles.elf.attacks[1],Config.Skills.elf[1],Config.Skills.elf[2],Config.Skills.elf[3]}
for _,d in defs do for _,yaw in {0,90,-90,180}do
 test((d.id or 'basic')..' target yaw '..yaw,function()
  hits=0;er.Position=root.Position+CFrame.Angles(0,math.rad(yaw),0).LookVector*12
  local state={character=c,root=root,humanoid=h,baseClassId='elf',arrowSeq=0,feedbackSeq=0,attackSeq=1,
   attack={definition=d,direction=Vector3.new(0,0,-1),targetModel=enemy,isSkill=d.id~=nil,started=100,hits={},hitCount=0,maxHeight=10,maxTargets=d.maxTargets or 1}}
  api.shot(state,101)
  local dir=(c:GetAttribute('K0ArrowTo')-c:GetAttribute('K0ArrowFrom')).Unit
  check(dir:Dot(Vector3.new(0,0,-1))>.9999,'Selected target cannot pull an accepted arrow sideways or backward')
  check(hits==(yaw==0 and 1 or 0),'Off-axis target receives no homing hit; forward hit remains')
 end)
end end
local visual=instrument(Client.K0SwordVisual,'return {origin=weaponOrigin,render=Visual.render}')
local model=Instance.new('Model');model:SetAttribute('WeaponClassId','elf');model.Parent=c
local grip=Instance.new('Part');grip.Name='WeaponGrip';grip.Anchored=true;grip.CanCollide=false;grip.Parent=model
local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Parent=grip
for _,row in {{-1.5,-3,3.2},{1.5,-3,3.2},{0,-3,2},{-1.5,-2,40},{1.5,-2,14.5,.8},{-1.5,-2,40,.8}}do
 test('Muzzle parallax '..table.concat(row,','),function()
  grip.CFrame=CFrame.new(root.Position+Vector3.new(row[1],row[4]or 0,row[2]))
  local endpoint=root.Position+Vector3.new(0,0,-row[3])
  local from=visual.origin(c,root.Position,endpoint,'elf')
  local flight=endpoint-from;local flat=Vector3.new(flight.X,0,flight.Z).Unit
  check(flat:Dot(Vector3.new(0,0,-1))>.99999,'No lateral socket component remains, including previously allowed small angles')
  if row[3]==40 then check(math.abs(from.Y-tip.WorldPosition.Y)<.001 and math.abs(from.X-root.Position.X)<.001,'Distant arrows preserve launch height without lateral socket parallax')end
 end)
end
local joint=Instance.new('Motor6D');joint.Name='PlayerWeaponJoint';joint.Part0=root;joint.Part1=grip;joint.Parent=grip
for _,yaw in {90,-90,180}do
 test('Bow heading while root turns '..yaw,function()
  c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',nil);c:SetAttribute('K0AttackStartedAt',200);c:SetAttribute('K0AttackSeq',44)
  c:SetAttribute('K0BowAim','44|0|0|-1');root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(yaw),0)
  c:SetAttribute('K0AttackAim',nil)
  local before=root.CFrame;visual.render(model,'Windup',1,1/60,'Basic',200+.875*Config.BasicAttackProfiles.elf.attacks[1].windup)
  check((root.CFrame*joint.C0*joint.Transform).LookVector:Dot(Vector3.new(0,0,-1))>.9999,'Nocked arrow keeps accepted server heading instead of following current body yaw')
  check(root.CFrame==before,'Presentation never rotates or moves the authority root')
 end)
end
for _,packed in {'43|0|0|1','44|nan|0|-1','44|0|0|0','44|1e999|0|-1'}do
 test('Stale or invalid heading '..packed,function()
  c:SetAttribute('K0BowAim',packed)
  visual.render(model,'Windup',1,1/60,'Basic',200+.875*Config.BasicAttackProfiles.elf.attacks[1].windup)
  check((root.CFrame*joint.C0*joint.Transform).LookVector:Dot(root.CFrame.LookVector)>.9999,'Old/invalid packets cannot impose a previous attack heading')
 end)
end
for _,copy in copies do copy:Destroy()end;folder:Destroy()
report.pass=#report.failures==0
print('ELF_ARROW_DIRECTION_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Arrow direction regression failed')
