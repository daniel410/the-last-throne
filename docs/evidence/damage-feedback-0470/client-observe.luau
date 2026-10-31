-- Normal inputs only; does not overwrite HP, root, damage or clock attributes.
local p=game.Players.LocalPlayer
local remotes=game.ReplicatedStorage.Remotes
_G.TLTDamageQA={samples={},impacts={},done=false}
local q=_G.TLTDamageQA
local seen={}
q.impactConnection=workspace.ChildAdded:Connect(function(h)
 if h.Name~='K0HitEffect' then return end
 task.defer(function()
  local rays=0;for _,o in ipairs(h:GetChildren())do if o.Name=='K0ContactRay'then rays+=1 end end
  table.insert(q.impacts,{rays=rays,skill=h:GetAttribute('K0SkillEffectId'),flash=h:FindFirstChild('K0ImpactFlash')~=nil,highlight=h:FindFirstChild('K0HitFlash')~=nil})
 end)
end)
task.spawn(function()
 remotes.K0HeroRequest:FireServer('CreateHero',game.HttpService:GenerateGUID(false),'knight')
 task.wait(.8)
 remotes.K0HeroRequest:FireServer('StartTraining',game.HttpService:GenerateGUID(false))
 local deadline=os.clock()+20
 repeat task.wait(.1)until (p:GetAttribute('K0SessionPhase')=='Tutorial' and p.Character and p.Character:GetAttribute('K0ClassId')=='knight' and p.Character:GetAttribute('K0SpawnReady')) or os.clock()>deadline
 local c=p.Character;local root=c.HumanoidRootPart;local human=c.Humanoid;local gui=p.PlayerGui:WaitForChild('K0PlayerHitFeedback')
 q.beforeHealth=human.Health;q.class=c:GetAttribute('K0ClassId')
 task.spawn(function()
  for _,v in ipairs({Vector3.new(8,3.1,47),Vector3.new(8,3.1,24),Vector3.new(-18,3.1,8)})do human:MoveTo(v);human.MoveToFinished:Wait()end
 end)
 local firstHurt;local retaliated=false
 local stop=os.clock()+35
 while os.clock()<stop and human.Health>0 do
  game:GetService('RunService').Heartbeat:Wait()
  local pulse=gui:GetAttribute('PulseCount')or 0
  if pulse>0 then
   firstHurt=firstHurt or os.clock()
   table.insert(q.samples,{time=workspace:GetServerTimeNow(),health=human.Health,damage=c:GetAttribute('K0HurtDamage'),maxHealth=c:GetAttribute('K0HurtMaxHealth'),pulse=pulse,grunts=gui:GetAttribute('GruntCount'),veil=gui.Veil.BackgroundTransparency,edge=gui.Top.BackgroundTransparency,soundPlaying=gui.K0HurtGrunt.IsPlaying,soundTime=gui.K0HurtGrunt.TimePosition,soundLoaded=gui.K0HurtGrunt.IsLoaded})
   if not retaliated and os.clock()-firstHurt>.32 then
    local e=workspace.DeepwoodK0.Enemies.Goblin
    human:MoveTo(root.Position)
    remotes.K0Action:FireServer('Skill1',(e.HumanoidRootPart.Position-root.Position).Unit,e)
    retaliated=true
   end
   if os.clock()-firstHurt>1.2 then
    remotes.K0Action:FireServer('BlockStart')
    q.afterHealth=human.Health;q.done=true;q.impactConnection:Disconnect();q.impactConnection=nil
    return
   end
  end
 end
 q.error='No normal enemy hit observed';q.done=true;q.impactConnection:Disconnect();q.impactConnection=nil
end)
return 'normal Knight training damage observer started'
