task.spawn(function()
 local p=game.Players.LocalPlayer;local root=p.Character.HumanoidRootPart;local h=p.Character.Humanoid
 local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
 local nav=require(p.PlayerScripts.Client.DeepwoodNavigation)
 local report={samples={},started=os.clock(),jumps=0,discontinuities=0};_G.ECRescue.follow=report;local last=root.Position
 while os.clock()-report.started<120 do
  if _G.ECRescue.state.journal.flags['EC-03:miners']then report.miners=true;break end
  local a=_G.ECRescue.state.activities['EC-03:miners'];if not a then task.wait(.2);continue end
  local pos=a.actorPosition
  if (Vector3.new(pos.X-root.Position.X,0,pos.Z-root.Position.Z)).Magnitude>8 then
   local path=nav.route(root.Position,pos);local nextPoint=path[#path]
   for i=2,#path do if Vector3.new(path[i].X-root.Position.X,0,path[i].Z-root.Position.Z).Magnitude>3 then nextPoint=path[i];break end end
   h:MoveTo(nextPoint)
  else h:MoveTo(root.Position)end
  if #report.samples==0 or os.clock()-report.samples[#report.samples].t>1 then
   report.samples[#report.samples+1]={t=os.clock(),player={root.Position.X,root.Position.Y,root.Position.Z},actor={pos.X,pos.Y,pos.Z},status=a.status,steps=_G.ECRescue.state.journal.activities['EC-03:miners']}
  end
  if h:GetState()==Enum.HumanoidStateType.Jumping then report.jumps+=1 end
  if (root.Position-last).Magnitude>15 then report.discontinuities+=1 end;last=root.Position
  task.wait(.12)
 end
 h:MoveTo(root.Position);controls:Enable();report.done=true;report.elapsed=os.clock()-report.started
end);return 'following actual Orik actor within eight studs'
