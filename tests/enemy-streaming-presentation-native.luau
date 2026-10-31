-- Late container and partial atomic-rig arrival, stream-out/in, no test hook.
assert(game.PlaceId==0,'Local fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run();task.wait(1)end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Visual=require(Client.K0EnemyVisual);Visual.start()
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local result={kind='ENEMY_STREAMING_PRESENTATION_NATIVE',checks=0,failures={}}
local function check(v,m)result.checks+=1;assert(v,m)end
local field=Instance.new('Model');field.Name='DeepwoodK0';field.Parent=workspace
local source=Instance.new('Folder');source.Parent=workspace
local camera=workspace.CurrentCamera;local cameraFrame=camera and camera.CFrame
if camera then camera.CFrame=CFrame.new(10000,15,10012)end
local ok,err=xpcall(function()
 local template=Field.makeEnemy(source,'Goblin',10000,10000,1,1);template.HumanoidRootPart.Anchored=true
 for pass=1,2 do
  local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=field
  local model=Instance.new('Model');model.Name='LateGoblin';model:SetAttribute('EnemyKind','Goblin');model:SetAttribute('TdMonsterTargetHeight',5);model.Parent=enemies
  task.wait(.1) -- First bind happens before any parts exist.
  for _,o in ipairs(template:GetChildren())do o.Parent=model end
  model.PrimaryPart=model.HumanoidRootPart;model:SetAttribute('K0EnemyStunUntil',workspace:GetServerTimeNow()+5);model:SetAttribute('K0EnemyStunClass','knight');model:SetAttribute('K0EnemyState','Stunned')
  task.wait(.25)
  check(model:FindFirstChild('ControlStunFX')~=nil,'late rig gets control effect after initial empty arrival '..pass)
  local count=0;for _,o in ipairs(model.HumanoidRootPart:GetChildren())do if o.Name:match('^StunOrbit')then count+=1 end end
  check(count==3,'streamed rig gets exactly one three-star cue')
  check(model.HumanoidRootPart.RootJoint.Transform~=CFrame.identity,'late rig gets authored motion without manual rebinding')
  -- RenderStepped does not run in a zero-player Run fixture, so countdown UI
  -- is checked in Client QA. Heartbeat/PreSimulation observers are real here.
  enemies.Parent=nil;task.wait(.15)
  check(not model:FindFirstChild('ControlStunFX'),'stream-out clears persistent effects')
  count=0;for _,o in ipairs(model.HumanoidRootPart:GetChildren())do if o.Name:match('^StunOrbit')then count+=1 end end
  check(count==0,'stream-out removes all orbit attachments')
  for _,o in ipairs(model:GetChildren())do o.Parent=template end
  enemies:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(result.failures,tostring(err))end
source:Destroy();field:Destroy();if started then Run:Stop()end
if camera and cameraFrame then camera.CFrame=cameraFrame end
result.pass=#result.failures==0;print('ENEMY_STREAMING_PRESENTATION_NATIVE '..game.HttpService:JSONEncode(result));assert(result.pass,'Late streaming presentation failed')
