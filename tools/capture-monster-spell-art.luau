-- Actual production caster + clock-driven spell renderer in an account-free local scene.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
local baseplate=workspace:FindFirstChild('Baseplate');if baseplate then baseplate:Destroy()end
local Run=game:GetService('RunService');Run:Run();task.wait(.8)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.EnemySpellVFX);local Motion=require(Client.K0EnemyMotion)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local kind=_G.SpellArtKind or 'VolcanoShaman';local index=_G.SpellArtAttack or 1
local definition=Patterns.get(kind).attacks[index]
local stage=Instance.new('Folder');stage.Name='SpellArtReview';stage.Parent=workspace
local floor=Instance.new('Part');floor.Name='ReviewFloor';floor.Anchored=true;floor.Size=Vector3.new(100,.5,100);floor.Position=Vector3.new(0,-.25,0);floor.Color=Color3.fromRGB(64,78,65);floor.Material=Enum.Material.SmoothPlastic;floor.Parent=stage
local caster=Field.makeEnemy(stage,kind,0,0,1,1);local root=caster.HumanoidRootPart;root.Anchored=true
root.CFrame=CFrame.lookAt(root.Position,root.Position+Vector3.new(0,0,-1));caster:SetAttribute('K0AttackSeq',1)
caster:SetAttribute('K0PatternId',definition.id);caster:SetAttribute('K0PatternMotion',definition.motion)
caster:SetAttribute('K0EnemyAttackClock',string.format('1|1000|%.6f|%.6f|%.6f|%d',definition.windup,definition.active,definition.recovery,definition.heavy and 1 or 0))
local motion=assert(Motion.bind(caster),'review caster binding')
local target=Instance.new('Model');target.Name='TrainingTarget';target.Parent=stage
for _,row in ipairs({{'HumanoidRootPart',Vector3.new(1.6,2.2,1),Vector3.new(0,2.1,-13)},{'Head',Vector3.one,Vector3.new(0,3.8,-13)}, {'LeftArm',Vector3.new(.55,1.8,.65),Vector3.new(-1.1,2.1,-13)},{'RightArm',Vector3.new(.55,1.8,.65),Vector3.new(1.1,2.1,-13)}, {'LeftLeg',Vector3.new(.6,1.2,.6),Vector3.new(-.45,.7,-13)},{'RightLeg',Vector3.new(.6,1.2,.6),Vector3.new(.45,.7,-13)}})do
 local p=Instance.new('Part');p.Name=row[1];p.Size=row[2];p.Position=row[3];p.Anchored=true;p.CanCollide=false;p.Color=row[1]=='Head'and Color3.fromRGB(194,172,143)or Color3.fromRGB(103,125,154);p.Parent=target
end
if definition.shape~='projectile'then for _,part in target:GetChildren()do if part:IsA('BasePart')then part.Position+=Vector3.new(0,0,7)end end end
local cameraPosition=definition.shape=='projectile'and Vector3.new(11,13,12)or Vector3.new(18,24,20)
local cameraTarget=definition.shape=='projectile'and Vector3.new(0,2,-6)or Vector3.new(0,2,-1)
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=40
camera.CFrame=CFrame.lookAt(cameraPosition,cameraTarget)
local light=game.Lighting;light.ClockTime=14;light.Brightness=2;light.Ambient=Color3.fromRGB(128,134,145);light.OutdoorAmbient=Color3.fromRGB(140,145,150)
local encoding=game:GetService('EncodingService')
local frameIndex=0
local function capture(phase,age)
 task.wait(.07);frameIndex+=1
 workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
 workspace.CurrentCamera.CFrame=CFrame.lookAt(cameraPosition,cameraTarget)
 task.wait(.06)
 for _,node in workspace:GetChildren()do
  assert(node==stage or node:IsA('Terrain')or node:IsA('Camera')or node.Name=='EnemyMagicProjectile'or node.Name:match('^EnemySpell')or node.Name=='PixelFXAccent','foreign QA scene detected: '..node.Name)
 end
 local done=false
 game:GetService('CaptureService'):CaptureScreenshot(function(id)
  local ok,err=pcall(function()
   local image=game:GetService('AssetService'):CreateEditableImageAsync(Content.fromUri(id));local raw=image:ReadPixelsBuffer(Vector2.zero,image.Size)
   local w=640;local h=math.floor(w*image.Size.Y/image.Size.X+.5);local rgb=buffer.create(w*h*3)
   for y=0,h-1 do for x=0,w-1 do
    local at=(math.floor(y/h*image.Size.Y)*image.Size.X+math.floor(x/w*image.Size.X))*4
    local to=(y*w+x)*3
    for c=0,2 do buffer.writeu8(rgb,to+c,buffer.readu8(raw,at+c))end
   end end
   local bytes=encoding:CompressBuffer(rgb,Enum.CompressionAlgorithm.Zstd,9);local hex={}
   for i=0,buffer.len(bytes)-1 do hex[#hex+1]=string.format('%02x',buffer.readu8(bytes,i))end
   local data=table.concat(hex)
   local loaded,total=0,0;for _,node in workspace:GetDescendants()do if node:IsA('ImageLabel')then total+=1;if node.IsLoaded then loaded+=1 end end end
   print('SPELL_ART_META '..game.HttpService:JSONEncode({case=kind,index=frameIndex,width=w,height=h,phase=phase,age=age,baseline=_G.SpellArtBaseline==true,encoding='zstd-hex',clock=workspace:GetServerTimeNow(),imagesLoaded=loaded,imageCount=total}))
   for i=1,#data,6000 do print('SPELL_ART_FRAME '..frameIndex..' '..data:sub(i,i+5999))end
   image:Destroy()
  end)
  if not ok then print('SPELL_ART_CAPTURE_ERROR',err)end
  done=true
 end)
 local deadline=os.clock()+12;while not done and os.clock()<deadline do task.wait(.03)end
 assert(done,'spell art capture timeout')
end
-- Continuous native playback keeps particles, trails, geometry and pose on one clock.
local flightSeconds=definition.shape=='projectile'and .7 or 0;local cycleStart=workspace:GetServerTimeNow();local lastPhase;local charge,shot
local origin,contact,direction;local currentPhase='charge';local phaseAge=0
local seq=0
local connection=Run.Heartbeat:Connect(function(dt)
 local now=workspace:GetServerTimeNow();local age=now-cycleStart
 local total=definition.windup+flightSeconds+.95
 if age>=total then cycleStart=now;age=0;lastPhase=nil;V.clear()end
 local phase=age<definition.windup and 'charge'or age<definition.windup+flightSeconds and 'flight'or age<definition.windup+flightSeconds+.68 and 'impact'or 'pause'
 if phase~=lastPhase then
  if phase=='charge'then
   seq+=1;caster:SetAttribute('K0AttackSeq',seq)
   caster:SetAttribute('K0EnemyAttackClock',string.format('%d|%.6f|%.6f|%.6f|%.6f|%d',seq,cycleStart,definition.windup,definition.active,definition.recovery,definition.heavy and 1 or 0))
   charge=V.charge(definition,caster,seq,cycleStart)
  elseif phase=='flight'then
   V.destroy(charge);charge=nil
   local socket=caster:FindFirstChild('EnemyCastSocket',true)
   origin=socket and socket.WorldPosition or root.Position+Vector3.yAxis
   contact=target.HumanoidRootPart.Position+Vector3.yAxis*.2;direction=(contact-origin).Unit
   flightSeconds=(contact-origin).Magnitude/definition.speed
   shot=V.projectile(definition,caster,seq,origin,direction,cycleStart+definition.windup)
  elseif phase=='impact'then
   V.destroy(shot);shot=nil
   if definition.shape=='projectile'then V.impact(definition,contact,cycleStart+definition.windup+flightSeconds,caster,seq,-direction)
   else
    local center=(definition.shape=='circle'or definition.shape=='trail')and Vector3.new(0,.04,-6)or Vector3.new(0,.04,0)
    V.pulse(definition,center,Vector3.new(0,0,-1),cycleStart+definition.windup,caster,seq)
   end
  else V.clear()end
  lastPhase=phase
 end
 currentPhase=phase;phaseAge=phase=='charge'and age or phase=='flight'and age-definition.windup or age-definition.windup-flightSeconds
 caster:SetAttribute('K0EnemyState',phase=='charge'and 'Windup'or phase=='flight'and 'Active'or 'Recovery')
 Motion.step(motion,math.min(dt,.1),now)
 if charge and not charge.dead then
  local socket=caster:FindFirstChild('EnemyCastSocket',true);local at=socket and socket.WorldPosition or root.Position+Vector3.yAxis
  V.pose(charge,CFrame.new(at)*CFrame.Angles(0,age*1.7,0),age,.3+math.clamp(age/definition.windup,0,1)*.65)
 end
 if shot and not shot.dead then
  local at=origin+direction*definition.speed*phaseAge;local roll=V.roll and V.roll(definition,phaseAge)or phaseAge*5
  V.pose(shot,CFrame.lookAt(at,at+direction)*CFrame.Angles(0,0,roll),phaseAge,1)
 end
 V.step(now)
end)
if _G.SpellArtHold then print('SPELL_ART_RECORD_READY',kind);task.wait(_G.SpellArtHold)
else task.wait(1.5);for i=1,18 do capture(currentPhase,phaseAge);task.wait(.08)end end
connection:Disconnect();V.clear();Motion.unbind(motion);stage:Destroy()
print('SPELL_ART_CAPTURE_COMPLETE',kind,frameIndex)
