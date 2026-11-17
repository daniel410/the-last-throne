-- Disposable seeded fixture only. Real admission, humanoid movement and local camera.
local p=game.Players.LocalPlayer
local RS=game.ReplicatedStorage
local Run=game:GetService('RunService')
local report={kind='EC03_PLAY',walk={},views={},pass=false}
_G.ECPlayRun=report
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
  if s.requestId=='ec-camera-configure'then configured=not s.error and s.selection.missionId=='EC-03'end
 end)
 remote.ExpeditionRequest:FireServer({action='Configure',missionId='EC-03',difficultyId='Easy',requestId='ec-camera-configure'})
 waitFor(function()return configured end,'GW configuration')
 task.wait(.6)
 remote.ExpeditionRequest:FireServer({action='Solo',requestId='ec-camera-solo'})
 waitFor(function()return p:GetAttribute('K0SessionPhase')=='Tutorial'and p.Character and p.Character:GetAttribute('K0SpawnReady')and p.Character.HumanoidRootPart.Position.Z< -3000 end,'EC spawn',90)
 connection:Disconnect()
 report.phase=p:GetAttribute('K0SessionPhase')
 report.position={p.Character.HumanoidRootPart.Position.X,p.Character.HumanoidRootPart.Position.Y,p.Character.HumanoidRootPart.Position.Z}
 report.heading={p.PlayerGui.DeepwoodTopHud.Root.Heading.Title.Text,p.PlayerGui.DeepwoodTopHud.Root.Heading.Subtitle.Text}
end,debug.traceback)
report.pass=ok;report.error=not ok and tostring(err)or nil;report.done=true
return game.HttpService:JSONEncode(report)
