task.spawn(function()
local p=game.Players.LocalPlayer;local h=p.Character.Humanoid;local root=p.Character.HumanoidRootPart
local controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
local nav=require(p.PlayerScripts.Client.DeepwoodNavigation);local target=Vector3.new(242.15,140,-12644.4);local start=os.clock();local last=root.Position
local r={jumps=0,discontinuities=0};_G.ECReport.wormApproach=r
local ok,err=xpcall(function()
while os.clock()-start<30 do
 if (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(target.X,0,target.Z)).Magnitude<5 then r.arrived=true;break end
 local path=nav.route(root.Position,target);h:MoveTo(path[2]);task.wait(.12)
 if (root.Position-last).Magnitude>15 then r.discontinuities+=1 end;last=root.Position
 if h:GetState()==Enum.HumanoidStateType.Jumping then r.jumps+=1 end
end end,debug.traceback)
h:MoveTo(root.Position);controls:Enable();r.elapsed=os.clock()-start;r.position={root.Position.X,root.Position.Y,root.Position.Z};r.done=true;r.error=not ok and err or nil
end)
return 'walking worm approach'
