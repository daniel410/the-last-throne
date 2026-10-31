-- Native TD meshes/motors: presentation timing, foot bounds, and root authority.
assert(game.PlaceId==0,'Unpublished local fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run();task.wait(1)end
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyMotion)
local Reaction=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyHitReaction)
local Clips=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyClips)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local report={kind='DEEPWOOD_MONSTER_MOTION_NATIVE',checks=0,failures={},maxFootError=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local function near(a,b,m,t)check(math.abs(a-b)<(t or .0001),m..': '..a..' / '..b)end
local folder=Instance.new('Folder');folder.Name='MonsterMotionQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local kinds={'Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','EnragedWarlord','KingShaman','Slime'}
 for index,kind in ipairs(kinds)do
  local m=Field.makeEnemy(folder,kind,10000+index*30,10000,1,1);local root=m.HumanoidRootPart;root.Anchored=true;m:SetAttribute('K0EnemyMotionSeed',.17)
  local s=assert(Motion.bind(m),'actual '..kind..' rig binds');local initial=root.CFrame;local human=m:FindFirstChildOfClass('Humanoid');local health=human.Health
  for _,clip in ipairs({'Idle','Walk','Attack','Heavy','Stunned'})do
   for _,phase in ipairs({0,.18,.4,.5,.62,.78,1})do
    local p=Motion.sample(kind,clip,phase)
    for _,ch in ipairs(Clips.channels)do for _,v in ipairs(p[ch])do check(v==v and math.abs(v)<1000,'finite authored '..kind..' '..clip..' '..ch)end end
   end
  end
  for _,clip in ipairs({'Idle','Walk','Stunned'})do
   local a,b=Motion.sample(kind,clip,0),Motion.sample(kind,clip,1)
   for _,ch in ipairs(Clips.channels)do for i,v in ipairs(a[ch])do near(v,b[ch][i],kind..' seamless '..clip)end end
  end
  m:SetAttribute('K0EnemyState','Chase')
  for frame=1,60 do
   root.CFrame=initial*CFrame.new(0,0,-frame/30*6);Motion.step(s,1/30,100+frame/30)
   local bodyInRoot=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
   for ch,leg in pairs(s.legs)do
    local motor=s.joints[ch];local cf=bodyInRoot*motor.C0*motor.Transform*motor.C1:Inverse()
    local bottom=math.huge;for _,v in ipairs(leg.points)do bottom=math.min(bottom,cf:PointToWorldSpace(v).Y)end
    local gap=bottom-leg.bottom;report.maxFootError=math.max(report.maxFootError,math.max(0,-gap))
    check(gap>=-.001 and gap<=s.height*.026,kind..' feet stay above ground with bounded swing lift')
   end
   check(root.CFrame==initial*CFrame.new(0,0,-frame/30*6),'pose never moves physical root')
  end
  local phase=s.phase;for _=1,20 do Motion.step(s,1/60,103)end;near(phase,s.phase,'stationary enemy cannot keep stepping')
  m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock','3|200|1.2|0.15|1.4|0')
  Motion.step(s,1/60,201.2);local contact=Motion.sample(kind,'Attack',.62)
  for _,ch in ipairs(Clips.channels)do for i,v in ipairs(contact[ch])do near(s.pose[ch][i],v,'contact matches server windup boundary')end end
  local late=assert(Motion.bind(m));Motion.step(late,1/144,201.2)
  for _,ch in ipairs(Clips.channels)do for i,v in ipairs(s.pose[ch])do near(late.pose[ch][i],v,'late observer sees same attack pose')end end
  m:SetAttribute('K0EnemyStunUntil',210);m:SetAttribute('K0EnemyState','Stunned');m:SetAttribute('K0EnemyAttackClock',nil)
  for frame=1,30 do Motion.step(s,1/30,205+frame/30)end
  check(s.attack==nil,'stun clears local attack');check(human.Health==health and root.CFrame==initial*CFrame.new(0,0,-12),'motion cannot change health or root')
  if kind=='Slime'then check(s.body.Size.Y<s.bodySize.Y and s.body.Size.X>s.bodySize.X,'slime has grounded squash/stretch')end
  -- Same travelled distance produces the same gait at different frame rates.
  local phases={}
  for _,hz in ipairs({30,144})do
   m:SetAttribute('K0EnemyStunUntil',nil);m:SetAttribute('K0EnemyState','Chase');root.CFrame=initial
   local q=assert(Motion.bind(m));for f=1,hz do root.CFrame=initial*CFrame.new(0,0,-6*f/hz);Motion.step(q,1/hz,300+f/hz)end;table.insert(phases,q.phase)
  end
  near(phases[1],phases[2],'distance-driven gait independent of frame rate',.0005)
  m:SetAttribute('K0EnemyState','Idle');root.CFrame=initial
  local recoil=assert(Motion.bind(m));Reaction.record(m,root.CFrame.LookVector,400);Motion.step(recoil,1/60,400.025)
  check(root.CFrame==initial and human.Health==health,kind..' hit reaction preserves server root/health')
  local bodyInRoot=recoil.joint.C0*recoil.joint.Transform*recoil.joint.C1:Inverse()
  for ch,leg in pairs(recoil.legs)do
   local motor=recoil.joints[ch];local cf=bodyInRoot*motor.C0*motor.Transform*motor.C1:Inverse()
   local bottom=math.huge;for _,v in ipairs(leg.points)do bottom=math.min(bottom,cf:PointToWorldSpace(v).Y)end
   check(bottom>=leg.bottom-.001,kind..' flinch keeps feet above ground')
  end
  check(Reaction.sample(m,400.2)==CFrame.identity,kind..' hit reaction fully expires')
  m:Destroy()
 end
 near(Motion.attackPhase(1.2,1.2,.15,1.4),.62,'impact anchor');near(Motion.attackPhase(1.35,1.2,.15,1.4),.78,'follow-through anchor');near(Motion.attackPhase(2.75,1.2,.15,1.4),1,'recovery ends at rest')
 local text=require(game.ReplicatedStorage.Shared.NavigationText)
 check(text.statsKey=='H' and text.ultimateKey=='T' and text.bagKey=='B','latest user keys H stats / T ultimate / B gear')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();if started then Run:Stop()end
report.pass=#report.failures==0;print('DEEPWOOD_MONSTER_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Monster motion native failed')
