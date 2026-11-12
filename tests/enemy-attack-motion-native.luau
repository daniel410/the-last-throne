-- Evaluate actual production rigs without starting gameplay or touching accounts.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion)
local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new('Folder');folder.Name='AttackMotionQA';folder.Parent=workspace
local checks,kinds,attacks=0,0,0
local function check(v,m)checks+=1;assert(v,m)end
local function finite(cf)
 for _,v in ipairs({cf:GetComponents()})do if v~=v or math.abs(v)>10000 then return false end end
 return true
end
for kind,profile in pairs(Patterns.profiles)do
 kinds+=1
 local model=Field.makeEnemy(folder,kind,1000,1000,1,1)
 local root=model.HumanoidRootPart;root.Anchored=true
 local s=assert(Motion.bind(model),'bind '..kind)
 local original,hp=root.CFrame,model.Humanoid.Health
 for index,d in ipairs(profile.attacks)do
  attacks+=1
  model:SetAttribute('K0PatternId',d.id);model:SetAttribute('K0PatternMotion',d.motion)
  model:SetAttribute('K0AttackSeq',index)
  model:SetAttribute('K0EnemyAttackClock',string.format('%d|0|%.6f|%.6f|%.6f|%d',index,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
  for _,hz in ipairs({30,60,144})do
   for f=0,math.ceil((d.windup+d.active+d.recovery)*hz)do
    local age=f/hz
    model:SetAttribute('K0EnemyState',age<d.windup and 'Windup' or age<d.windup+d.active and 'Active' or 'Recovery')
    Motion.step(s,1/hz,age)
    check(finite(s.joint.Transform),'finite root '..kind)
    if s.gloam then for _,b in pairs(s.gloam.bones)do check(finite(b.Transform),'finite Gloam bone '..kind)end end
    if s.caster then for _,b in pairs(s.caster.bones)do check(finite(b.Transform),'finite caster bone '..kind)end end
   end
  end
  check(root.CFrame==original and model.Humanoid.Health==hp,'presentation preserves root and health '..kind)
 end
 model:SetAttribute('K0EnemyState','Stunned');model:SetAttribute('K0EnemyStunUntil',100)
 Motion.step(s,1/60,10)
 check(root.CFrame==original,'interruption preserves root '..kind)
 Motion.unbind(s)
 if s.gloam then for _,b in pairs(s.gloam.bones)do check(b.Transform==CFrame.identity,'skin reset '..kind)end end
 model:Destroy();task.wait()
end
folder:Destroy()
print('ENEMY_ATTACK_MOTION_NATIVE '..game.HttpService:JSONEncode({checks=checks,kinds=kinds,attacks=attacks}))
