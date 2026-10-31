-- Client-only QA: normal server remote; no position/health/stun mutation.
_G.TLTQA=_G.TLTQA or {}
_G.TLTQA.watch=function(classId,slot,range)
 local samples={};_G.TLTQA[classId]=samples
 task.spawn(function()
  local stop=os.clock()+25
  while os.clock()<stop do
   local c=game.Players.LocalPlayer.Character;local e=workspace.DeepwoodK0.Enemies:FindFirstChild('Goblin')
   local root=c and c:FindFirstChild('HumanoidRootPart');local target=e and e:FindFirstChild('HumanoidRootPart')
   if root and target and (root.Position-target.Position).Magnitude<range then
    c.Humanoid:MoveTo(root.Position)
    game.ReplicatedStorage.Remotes.K0Action:FireServer('Skill'..slot,(target.Position-root.Position).Unit,e)
    for i=1,65 do
     task.wait(.1)
     if i>10 and i%3==0 then game.ReplicatedStorage.Remotes.K0Action:FireServer('BlockStart')end
     local stars=0;local rays=0;local color
     for _,a in ipairs(target:GetChildren())do if a.Name:match('^StunOrbit')then
      stars+=1;local star=a.StunStar.Star;rays=#star:GetChildren();color=tostring(star.TextColor3)
     end end
     table.insert(samples,{t=workspace:GetServerTimeNow(),state=e:GetAttribute('K0EnemyState'),untilTime=e:GetAttribute('K0EnemyStunUntil'),source=e:GetAttribute('K0EnemyStunClass'),stars=stars,rays=rays,color=color,speed=e.Humanoid.WalkSpeed,health=e.Humanoid.Health,rootPose=tostring(target.RootJoint.Transform)})
    end
    return
   end
   task.wait(.05)
  end
 end)
end
return 'QA watcher installed'
