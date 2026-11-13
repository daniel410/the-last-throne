-- Exercise actual private shot/flight functions without shipping a QA API.
local report={kind='ELF_STRAIGHT_SHOT_NATIVE',checks=0,failures={}}
local function check(v,label)report.checks+=1;assert(v,label)end
local folder=Instance.new('Folder');folder.Name='ElfStraightShotQA';folder.Parent=workspace
local modules={}
local function instrument(original,tail)
 local m=original:Clone();m.Name='StraightShotQA';m.Source=m.Source:gsub('\nreturn %w+%s*$',function()return '\n'..tail end);m.Parent=original.Parent;table.insert(modules,m);return require(m)
end
local function rig(name,position)
 local c=Instance.new('Model');c.Name=name
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.CFrame=CFrame.new(position);root.Parent=c
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;c.PrimaryPart=root;c.Parent=folder
 return c,root,h
end
local ok,err=xpcall(function()
 local service=game.ServerScriptService.Server.Combat.CombatService
 local api=instrument(service,[[
return {start=startAttack,skill=startSkill,shot=applyArrowShot,clear=clearAction,enemies=enemyStates,
 setFolder=function(v)enemyFolder=v end, spy=function(f)damageEnemy=f end}
]])
 api.setFolder(folder)
 local Config=require(game.ReplicatedStorage.Shared.K0Config)
 local c,root,h=rig('Archer',Vector3.new(20000,1000,20000));c:SetAttribute('K0ClassId','elf')
 local enemy,er,eh=rig('SelectedEnemy',root.Position+Vector3.new(12,0,0))
 api.enemies[enemy]={model=enemy,root=er,humanoid=eh,id=1}
 local state={character=c,root=root,humanoid=h,baseClassId='elf',attackProfile=Config.BasicAttackProfiles.elf,
 combo=0,lastAttackFinished=-math.huge,attackSeq=0,feedbackSeq=0,arrowSeq=0,mode='Idle'}
 local damage=0;api.spy(function()damage+=1 end)
 for _,autoRotate in {true,false}do
  h.AutoRotate=autoRotate;root.CFrame=CFrame.new(root.Position)
  er.Position=root.Position+Vector3.new(12,0,0)
  api.start(state,100,enemy)
  local aimPacket=string.split(c:GetAttribute('K0BowAim'),'|')
  check(tonumber(aimPacket[1])==state.attackSeq,'Bow heading packet belongs to accepted basic attack')
  check(Vector3.new(tonumber(aimPacket[2]),0,tonumber(aimPacket[4])):Dot(state.attack.direction)>.9999,'Bow heading agrees with authoritative shot direction')
  check(root.CFrame.LookVector:Dot(state.attack.direction)>.9999,'Accepted target turns bow and locked aim together')
  check(not h.AutoRotate,'Basic windup prevents movement AutoRotate')
  api.shot(state,101)
  local confirmation=string.split(c:GetAttribute('K0ArrowRelease'),'|')
  check(tonumber(confirmation[1])==state.attackSeq and tonumber(confirmation[2])==100 and tonumber(confirmation[3])==101,'Release metadata belongs to accepted attack and time')
  check(tonumber(confirmation[4])==state.arrowSeq,'Release confirmation names the same projectile sequence')
  check((c:GetAttribute('K0ArrowTo')-er.Position).Magnitude<.001,'Selected side target is still usable after accepted turn')
  api.clear(state);check(h.AutoRotate==autoRotate,'Clear/cancel restores original rotation policy')
  check(c:GetAttribute('K0BowAim')==nil,'Clear/cancel releases the previous bow heading')
 end
 check(damage==2,'Valid selected shot retains server hit behavior')
 h.AutoRotate=true;root.CFrame=CFrame.new(root.Position);er.Position=root.Position+Vector3.new(0,0,-12)
 api.start(state,110,enemy);local aim=state.attack.direction
 er.Position=root.Position+Vector3.new(12,0,0)
 api.shot(state,111)
 local released=(c:GetAttribute('K0ArrowTo')-c:GetAttribute('K0ArrowFrom')).Unit
 check(released:Dot(aim)>.9999,'Target crossing sideways during draw cannot bend basic shot')
 check(damage==2,'Off-axis selected target receives no sideways homing hit')
 local seq=state.arrowSeq;api.shot(state,112);check(state.arrowSeq==seq,'One release per accepted attack')
 api.clear(state);check(h.AutoRotate,'Recovery/cancel restores movement rotation')
 root.CFrame=CFrame.new(root.Position);api.start(state,120,nil)
 check(not h.AutoRotate and state.attack.direction:Dot(root.CFrame.LookVector)>.9999,'Untargeted moving shot also keeps bow heading')
 api.clear(state)
 state.skillSlots={1,2,3};state.slotCount=3;state.skillReadyAt={}
 for slot=1,3 do
  state.mode='Idle';er.Position=root.Position+Vector3.new(0,0,-12)
  api.skill(state,slot,130+slot,enemy)
  local packet=string.split(c:GetAttribute('K0BowAim'),'|')
  check(tonumber(packet[1])==state.attackSeq and tonumber(packet[4])<-.999,'Each accepted common skill publishes its locked bow heading')
  api.clear(state);check(c:GetAttribute('K0BowAim')==nil,'Skill cancellation clears its heading')
 end
 local visual=instrument(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual,
 'return {emit=emitArrow,advance=advanceArrows}')
 for _,fps in {30,60,144}do for _,offset in {0,4,-4}do
  local first=root.Position;local last=first+Vector3.new(offset,0,-40);local direction=(last-first).Unit
  local arrow=visual.emit(c,first,last,nil,false)
  for i=1,math.floor(arrow.duration*fps)-1 do
   root.CFrame=CFrame.new(first+Vector3.new(i,0,2))*CFrame.Angles(0,math.pi/2,0)
   visual.advance(1/fps)
   local delta=arrow.shaft.Position-first
   check(delta:Cross(direction).Magnitude<.004,'Flight stays on release ray when shooter moves/turns')
   check(arrow.shaft.CFrame.LookVector:Dot(direction)>.9999,'Arrow heading stays constant throughout flight')
  end
  visual.advance(.1);visual.advance(.1)
 end end
end,debug.traceback)
for _,m in modules do m:Destroy()end;folder:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;print('ELF_STRAIGHT_SHOT_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,'Straight shot regression failed')
