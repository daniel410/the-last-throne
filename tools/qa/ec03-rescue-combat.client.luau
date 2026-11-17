-- Isolated Studio fixture only; normal combat requests, no enemy/hero stat edits.
assert(game.PlaceId==0 and game:GetService('RunService'):IsStudio(),'isolated fixture only')
task.spawn(function()
 _G.ECWalk(Vector3.new(242.15,141,-12644.4),'worm-combat')
 _G.ECRescue.combat={started=os.clock(),samples={}}
 local p=game.Players.LocalPlayer;local r=p.Character.HumanoidRootPart;local h=p.Character.Humanoid
 local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
 for tick=1,1200 do
  local target,dist=nil,math.huge
  for _,m in workspace:GetDescendants()do
   if m:IsA('Model') and m:GetAttribute('DeepwoodEncounter') and m:FindFirstChild('HumanoidRootPart') and m:FindFirstChildOfClass('Humanoid') and m:FindFirstChildOfClass('Humanoid').Health>0 then
    local d=(m.HumanoidRootPart.Position-r.Position).Magnitude
    if d<dist then target=m;dist=d end
   end
  end
  if target then
   h:MoveTo(target.HumanoidRootPart.Position)
   game.ReplicatedStorage.Remotes.K0Action:FireServer('Attack',nil,target)
  end
  if tick%25==0 then table.insert(_G.ECRescue.combat.samples,{t=os.clock(),hp=h.Health,d=target and dist,encounters=_G.ECRescue.state.encounters})end
  if _G.ECRescue.state.journal.flags['EC-03:worm'] or h.Health<=0 then break end
  task.wait(.22)
 end
 h:MoveTo(r.Position);controls:Enable();_G.ECRescue.combat.done=true;_G.ECRescue.combat.worm=_G.ECRescue.state.journal.flags['EC-03:worm']
end);return 'normal server-authorized attacks and movement running'
