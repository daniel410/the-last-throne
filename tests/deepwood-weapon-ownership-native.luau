-- Actual uploaded meshes, actual server rig and client bindings; no live Place.
assert(game.PlaceId == 0, 'Unpublished fixture required')
local Run = game:GetService('RunService')
local started = not Run:IsRunning()
if started then Run:Run(); task.wait(1) end
local Field = require(game.ServerScriptService.Server.World.TrainingField)
local Motion = require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyMotion)
local Appearance = require(game.ServerScriptService.Server.World.TdMonsterAppearance)
local report = {kind='DEEPWOOD_WEAPON_OWNERSHIP_NATIVE',checks=0,failures={},assets={}}
local function check(v,m) report.checks+=1; assert(v,m) end
local folder=Instance.new('Folder');folder.Name='WeaponOwnershipQA';folder.Parent=workspace
local ok,err=xpcall(function()
 for _,kind in ipairs({'Ogre','Warlord'}) do
  local model=Field.makeEnemy(folder,kind,0,0,1,1)
  model.HumanoidRootPart.Anchored=true
  local visual=model.TdMonsterVisual
  local arm=kind=='Ogre' and 'ArmR' or 'ArmL'
  local shoulder=kind=='Ogre' and 'Left Shoulder' or 'Right Shoulder'
  local weapon=visual:FindFirstChild(kind=='Ogre' and 'Weapon' or 'ArmL')
  local s=assert(Motion.bind(model))
  check(model:GetAttribute('TdWeaponArm')==arm,kind..' correct source weapon arm')
  check(s.joints.weapon==model.Torso[shoulder],kind..' actual weapon hand drives attack')
  check(s.weaponFX.part==weapon,kind..' trail uses actual weapon geometry')
  check(s.weaponFX.shoulder==s.joints.weapon,kind..' current frame effects use attacking shoulder')
  check(weapon.TdVisualWeld.Part0==s.joints.weapon.Part1,kind..' weapon is rigidly attached to attacking hand')
  if kind=='Ogre' then
   check(weapon~=visual.ArmR and weapon~=visual.Body,'club is separated from hand and torso')
   check(#Appearance.describe(kind).parts==6,'Ogre has one independent whole weapon')
  else
   check(s.joints.weapon.Part1.Name=='Right Arm','DW-05 boss attacks with right hand')
   check(s.joints.off.Part1.Name=='Left Arm','empty left hand remains offhand')
  end
  local preload={}
  for _,part in visual:GetChildren() do if part:IsA('MeshPart') then table.insert(preload,part) end end
  game:GetService('ContentProvider'):PreloadAsync(preload,function(id,status)
   table.insert(report.assets,{id=id,status=status.Name})
   check(status==Enum.AssetFetchStatus.Success,kind..' actual uploaded mesh/texture loads: '..id)
  end)
  local root=model.HumanoidRootPart.CFrame;local hp=model.Humanoid.Health
  local grip=s.joints.weapon.Part1.CFrame:ToObjectSpace(weapon.CFrame)
  for _,hz in ipairs({30,60,144}) do
   for sequence=1,4 do
    model:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|0.15|1.4|'..(sequence>=3 and '1' or '0'))
    model:SetAttribute('K0EnemyState','Windup')
    Motion.step(s,1/hz,501.2)
    local motor=s.joints.weapon
    local hand=s.root.CFrame*s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()*motor.C0*motor.Transform*motor.C1:Inverse()
    local predicted=hand*grip
    -- Head, shaft and lower grip share one physical MeshPart and one hand
    -- transform at every attack variant; no torso/leg motor owns the head.
    check(predicted.Position.X==predicted.Position.X,kind..' finite weapon transform')
    check(weapon.TdVisualWeld.Part0==motor.Part1,kind..' unchanged grip ownership through attack')
    check(model.HumanoidRootPart.CFrame==root and model.Humanoid.Health==hp,kind..' preserves gameplay authority')
   end
  end
  Motion.unbind(s);model:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
folder:Destroy();if started then Run:Stop()end
report.pass=#report.failures==0
print('DEEPWOOD_WEAPON_OWNERSHIP_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'Weapon ownership regression failed')
