-- Observe a normal accepted Skill1; no root/health/time/authority overrides.
assert(game.PlaceId==0,'Unpublished QA only')
local p=game.Players.LocalPlayer
_G.TLTShieldQA={samples={},snapshotted=false}
local report=_G.TLTShieldQA
local action=game.ReplicatedStorage.Remotes.K0Action
local c=p.Character
local e=workspace.DeepwoodK0.Enemies.Goblin
local target=e.HumanoidRootPart
local root=c.HumanoidRootPart
local function reach(part)
 local top=-math.huge
 for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
  top=math.max(top,-root.CFrame:PointToObjectSpace(part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)*.5)).Z)
 end end end
 return top
end
report.beforeHealth=e.Humanoid.Health
report.rig=c.Humanoid.RigType.Name
report.requestedAt=workspace:GetServerTimeNow()
task.spawn(function()
 local stop=os.clock()+40
 while os.clock()<stop do
  if (root.Position-target.Position).Magnitude<3.95 then
   c.Humanoid:MoveTo(root.Position)
   action:FireServer('Skill1',(target.Position-root.Position).Unit,e)
   local appearance=c:FindFirstChild('TLT_K0_KnightAppearance')
   local sword,shield
   if appearance then
    report.weaponSource=appearance:GetAttribute('WeaponSourceKey');report.shieldSource=appearance:GetAttribute('ShieldSourceKey')
    for _,part in ipairs(appearance:GetChildren())do
     if part:IsA('BasePart') then
      if part:GetAttribute('SourceMeshId')=='rbxassetid://136222429214301' then sword=part end
      if part:GetAttribute('SourceMeshId')=='rbxassetid://86935256146675' then shield=part end
     end
    end
   end
   report.parts={sword=sword and sword.Name,shield=shield and shield.Name}
   for i=1,160 do
    game:GetService('RunService').Heartbeat:Wait()
    local now=workspace:GetServerTimeNow()
    local started=c:GetAttribute('K0AttackStartedAt')
    local age=type(started)=='number' and now-started or -1
    local sample={time=now,age=age,skill=c:GetAttribute('K0SkillId'),phase=c:GetAttribute('K0AttackPhase'),health=e.Humanoid.Health,enemyState=e:GetAttribute('K0EnemyState'),stunUntil=e:GetAttribute('K0EnemyStunUntil')}
    if sword and shield then sample.gap=reach(shield)-reach(sword);sample.faceDot=shield.CFrame.LookVector:Dot(root.CFrame.LookVector)end
    table.insert(report.samples,sample)
    if not report.snapshotted and age>=.205 and age<.295 and sample.phase=='Active' then
     -- Client-only still of the real accepted-cast pose for visual review.
     local previous=c.Archivable;c.Archivable=true;local clone=c:Clone();c.Archivable=previous
     clone.Name='TLT_QA_RecordedShieldContact'
     for _,o in ipairs(clone:GetDescendants())do
      if o:IsA('LuaSourceContainer') or o:IsA('JointInstance') or o:IsA('Constraint') or o:IsA('Humanoid')then o:Destroy()
      elseif o:IsA('BasePart')then o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false;o.CFrame+=Vector3.new(0,8,0)end
     end
     clone.Parent=workspace
     report.snapshotted=true;report.snapshotAge=age;report.snapshotPosition=tostring(root.Position+Vector3.new(0,8,0))
    end
    if i>45 and i%20==0 then action:FireServer('BlockStart')end
   end
   report.afterHealth=e.Humanoid.Health
   report.done=true
   return
  end
  task.wait(.05)
 end
 report.error='Normal path did not reach cast range';report.done=true
end)
return 'normal-cast observer armed'
