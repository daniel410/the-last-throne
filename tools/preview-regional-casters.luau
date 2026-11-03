-- Isolated local visual QA. Stop by setting workspace.MR01PreviewFinish=true.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Local QA only')
local Run=game:GetService('RunService');Run:Run();task.wait(2)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyMotion)
local folder=Instance.new('Folder');folder.Name='MR01ImportedPreview';folder.Parent=workspace
local platform=Instance.new('Part');platform.Name='PreviewGround';platform.Anchored=true;platform.Size=Vector3.new(40,1,25);platform.CFrame=CFrame.new(10000,49.5,0);platform.Color=Color3.fromRGB(83,86,92);platform.Parent=folder
local states={}
for i,kind in {'QueenIceElf','VolcanoShaman','KingVolcanoShaman'}do
 local m=Field.makeEnemy(folder,kind,10000+(i-2)*10,0,1,1);m.HumanoidRootPart.Anchored=true
 m:PivotTo(CFrame.new(10000+(i-2)*10,53,0));m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock','1|100|1|0.2|0.8|0')
 table.insert(states,assert(Motion.bind(m)))
end
workspace:SetAttribute('MR01PreviewReady',true);workspace:SetAttribute('MR01PreviewAge',1)
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(10000,57,-27),Vector3.new(10000,53,0))
local connection=Run.PreSimulation:Connect(function(dt)
 local age=workspace:GetAttribute('MR01PreviewAge')or 1
 local sequence=workspace:GetAttribute('MR01PreviewSequence')or 1
 local selected=workspace:GetAttribute('MR01PreviewKind')
 for _,s in states do
  local visible=not selected or selected==s.kind
  for _,part in s.model.TdMonsterVisual:GetChildren()do if part:IsA('MeshPart')then part.Transparency=visible and 0 or 1 end end
  s.model:SetAttribute('K0EnemyAttackClock',sequence..'|100|1|0.2|0.8|'..(sequence>=3 and '1'or'0'))
  s.model:SetAttribute('K0EnemyState',age<1 and 'Windup' or age<1.2 and 'Active' or 'Recovery')
  if visible then Motion.step(s,dt,100+age)else require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyWeaponMotion).hide(s.weaponFX)end
 end
end)
game:GetService('ContentProvider'):PreloadAsync(folder:GetDescendants())
print('MR01_PREVIEW_READY')
while not workspace:GetAttribute('MR01PreviewFinish')do task.wait(.2)end
connection:Disconnect();for _,s in states do Motion.unbind(s)end;folder:Destroy()
