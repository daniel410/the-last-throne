-- Disposable Studio fixture only. Does not alter movement speed or pivot.
assert(game.PlaceId==0 and game:GetService('RunService'):IsStudio(),'isolated fixture only')
_G.ECWalk=function(target,label)
 local p=game.Players.LocalPlayer;local h=p.Character.Humanoid;local root=p.Character.HumanoidRootPart
 local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
 local nav=require(p.PlayerScripts.Client.DeepwoodNavigation);local start=os.clock();local last=root.Position
 local r={jumps=0,discontinuities=0,target={target.X,target.Y,target.Z}};table.insert(_G.ECRescue.walk,r);r.label=label
 while os.clock()-start<90 do
  if (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(target.X,0,target.Z)).Magnitude<4 then r.arrived=true;break end
  local path=nav.route(root.Position,target);local nextPoint=path[#path];for i=2,#path do if Vector3.new(path[i].X-root.Position.X,0,path[i].Z-root.Position.Z).Magnitude>3 then nextPoint=path[i];break end end;h:MoveTo(nextPoint);task.wait(.12)
  if (root.Position-last).Magnitude>15 then r.discontinuities+=1 end;last=root.Position
  if h:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
 end
 h:MoveTo(root.Position);controls:Enable();r.elapsed=os.clock()-start;r.position={root.Position.X,root.Position.Y,root.Position.Z};r.done=true
 return r
end

return 'ECWalk installed'
