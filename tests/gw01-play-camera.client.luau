-- Disposable seeded fixture only. Real admission, humanoid movement and local camera.
local p=game.Players.LocalPlayer
local RS=game.ReplicatedStorage
local Run=game:GetService('RunService')
local report={kind='GW01_PLAY_CAMERA',walk={},views={},pass=false}
_G.GWPlayRun=report
local controls
local function waitFor(fn,label,limit)
 local start=os.clock()
 repeat if fn()then return end;task.wait(.1)until os.clock()-start>(limit or 30)
 error(label..' timeout')
end
local ok,err=xpcall(function()
 assert(game.PlaceId==0 and Run:IsStudio(),'isolated fixture only')
 waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby'and p:GetAttribute('TLTInventoryMode')=='Studio session'end,'Studio session')
 local remote=RS:WaitForChild('Remotes')
 local configured,latest=false,nil
 local connection=remote.ExpeditionState.OnClientEvent:Connect(function(s)
  latest=s
  if s.requestId=='gw-camera-configure'then configured=not s.error and s.selection.missionId=='GW-01'end
 end)
 remote.ExpeditionRequest:FireServer({action='Configure',missionId='GW-01',difficultyId='Easy',requestId='gw-camera-configure'})
 waitFor(function()return configured end,'GW configuration')
 task.wait(.6)
 remote.ExpeditionRequest:FireServer({action='Solo',requestId='gw-camera-solo'})
 waitFor(function()return p:GetAttribute('K0SessionPhase')=='Tutorial'and p.Character and p.Character:GetAttribute('K0SpawnReady')and p.Character.HumanoidRootPart.Position.Z< -3000 end,'GW spawn',90)
 connection:Disconnect()
 local root=p.Character.HumanoidRootPart
 local hum=p.Character.Humanoid
 local function xyz(v)return {v.X,v.Y,v.Z}end
 local nav=require(p.PlayerScripts.Client.DeepwoodNavigation)
 controls=require(p.PlayerScripts.PlayerModule):GetControls();controls:Disable()
 local target=Vector3.new(-1338.53,54,-4084.4)
 local last=root.Position;local started=os.clock()
 local walk=report.walk;walk.from=xyz(last);walk.jumps=0;walk.discontinuities=0;walk.samples=0
 while os.clock()-started<55 do
  if Vector3.new(root.Position.X-target.X,0,root.Position.Z-target.Z).Magnitude<5 then walk.arrived=true;break end
  local path=nav.route(root.Position,target);local i=2
  while i<#path and(root.Position-path[i]).Magnitude<6 do i+=1 end
  hum:MoveTo(path[i]);task.wait(.12);walk.samples+=1
  if(root.Position-last).Magnitude>15 then walk.discontinuities+=1 end
  last=root.Position
  if hum:GetState()==Enum.HumanoidStateType.Jumping then walk.jumps+=1 end
 end
 hum:MoveTo(root.Position);controls:Enable()
 walk.elapsed=os.clock()-started;walk.to=xyz(root.Position)
 assert(walk.arrived and walk.jumps==0 and walk.discontinuities==0,'physical approach')
 local h=p.PlayerGui.DeepwoodTopHud.Root.Heading
 report.heading={h.Title.Text,h.Subtitle.Text}
 assert(h.Title.Text=='GLOAMWOOD'and h.Subtitle.Text=='ONE BRAVE STEP','GW runtime heading')
 local art=workspace.DeepwoodCampaign.EpicWorldArt.EpicWorldArt_2['GW-01'].ScoutsTrailEvidence
 local cam=workspace.CurrentCamera
 for _,yaw in ipairs({0,90,180,270})do
  local focus=root.Position+Vector3.new(0,1.5,0)
  local angle=math.rad(yaw)
  local offset=Vector3.new(math.sin(angle),1,math.cos(angle)).Unit*32
  cam.CFrame=CFrame.lookAt(focus+offset,focus);cam.Focus=CFrame.new(focus)
  task.wait(.4)
  local view={yaw=yaw,type=cam.CameraType.Name,distance=(cam.CFrame.Position-cam.Focus.Position).Magnitude,position=xyz(cam.CFrame.Position),visibleFootprints=0}
  for _,part in art:GetChildren()do if part.Name~='LoadedWheelRut'then
   local point,visible=cam:WorldToViewportPoint(part.Position)
   if visible and point.Z>0 and part.LocalTransparencyModifier<1 then view.visibleFootprints+=1 end
  end end
  report.views[#report.views+1]=view
  assert(view.type=='Custom'and view.distance<=32.1,'production camera limits')
 end
 report.profile=p:GetAttribute('TLTInventoryMode');report.clockTime=game.Lighting.ClockTime
 report.characterClass=p.Character:GetAttribute('K0ClassId');report.characterLevel=p.Character:GetAttribute('K0Level')
end,debug.traceback)
if controls then controls:Enable()end
report.pass=ok;report.error=not ok and tostring(err)or nil;report.done=true
return game.HttpService:JSONEncode(report)
