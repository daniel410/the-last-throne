-- Actual TD Orc geometry and native R6/R15 avatars; isolated local QA.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local place required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run()end
local report={kind='MELEE_FEEDBACK_REAL_RIGS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local C=require(game.ReplicatedStorage.Shared.K0Config)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyMotion)
local Control=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyControlEffects)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new('Folder');folder.Name='MeleeFeedbackRealRigsQA';folder.Parent=workspace
local original=game.ServerScriptService.Server.Combat.CombatService
local copy=original:Clone();copy.Name='MeleeFeedbackRealRigsQA'
copy.Source=copy.Source:gsub('\nreturn CombatService%s*$',[[
return {register=registerEnemy,hit=applySwordHits,step=stepEnemy,begin=beginEnemyAttack,setFolder=function(f)enemyFolder=f end}
]])
copy.Parent=original.Parent;local api=require(copy);api.setFolder(folder)
local ok,err=xpcall(function()
 for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
  for _,classId in ipairs({'knight','dwarf','elf','mage'})do
   local desc=Instance.new('HumanoidDescription');local char=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy();char.Parent=folder
   local root=char.HumanoidRootPart;root.Anchored=true;char:PivotTo(CFrame.new(20000,1000,20000))
   char:SetAttribute('K0ClassId',classId);char:SetAttribute('K0State','Stunned');char:SetAttribute('K0HurtAt',100)
   local joint=rig==Enum.HumanoidRigType.R15 and char:FindFirstChild('Waist',true) or root:FindFirstChild('RootJoint')
   local cf,hp=root.CFrame,char.Humanoid.Health
   Visual.renderArms(char,1/60,100.035)
   local _,angle=joint.Transform:ToAxisAngle()
   check(math.abs(angle)>.01,rig.Name..'/'..classId..' shows body reaction')
   check(root.CFrame==cf and char.Humanoid.Health==hp,'body effect cannot move root or deal damage')
   for i=1,30 do Visual.renderArms(char,1/60,100.3+i/60)end
   local _,rest=joint.Transform:ToAxisAngle();check(math.abs(rest)<.0001,'body returns to neutral')
   char:Destroy()
  end
 end
 -- Use the actual Training Field's Orc rig/visual scale (1.65/1.5).
 local orc=Field.makeEnemy(folder,'Orc',25000,25000,1.65,1.5);orc.HumanoidRootPart.Anchored=true
 local enemy=api.register(orc);local root=orc.HumanoidRootPart
 local char=Instance.new('Model');local pr=Instance.new('Part');pr.Name='HumanoidRootPart';pr.Anchored=true;pr.CanCollide=false
 pr.CFrame=CFrame.new(root.Position.X,3,root.Position.Z+4.8);pr.Parent=char;char.PrimaryPart=pr
 local ph=Instance.new('Humanoid');ph.RequiresNeck=false;ph.Parent=char;char.Parent=folder
 local state={character=char,root=pr,humanoid=ph,baseClassId='knight',heroId='qa',player={UserId=-777,Parent=game.Players},feedbackSeq=0}
 state.attack={started=0,definition=C.Skills.knight[1],attackPower=100,counterDamage=0,hits={},hitCount=0,maxTargets=3,maxHeight=7,isSkill=true,direction=Vector3.new(0,0,-1)}
 api.begin(enemy,state,0);local hp=enemy.humanoid.Health
 api.hit(state,.21)
 check(enemy.humanoid.Health==hp-80,'real scaled Orc receives bash through range/cone/wall checks')
 check(enemy.stunUntil==5.21 and enemy.mode=='Stunned','real scaled Orc gets five-second stun')
 check(not enemy.attack and orc:GetAttribute('K0EnemyAttackClock')==nil,'real Orc attack and animation cancelled')
 local motion=assert(Motion.bind(orc));local before=root.CFrame
 Motion.step(motion,1/60,workspace:GetServerTimeNow())
 check(root.CFrame==before,'stun pose cannot move authoritative Orc root')
 local fx=assert(Control.bind(orc));check(Control.update(fx,workspace:GetServerTimeNow()) and #fx.stars==3,'real Orc displays three stun stars')
 api.step(enemy,5.209,1/60);check(enemy.mode=='Stunned' and enemy.humanoid.WalkSpeed==0,'real Orc remains stopped until expiry')
 api.step(enemy,5.21,1/60);check(not enemy.stunUntil and enemy.humanoid.WalkSpeed==enemy.config.walkSpeed,'real Orc recovers at expiry')
 Motion.unbind(motion)
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();copy:Destroy();if started then Run:Stop()end
report.pass=#report.failures==0;print('MELEE_FEEDBACK_REAL_RIGS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Real rig feedback failed')
