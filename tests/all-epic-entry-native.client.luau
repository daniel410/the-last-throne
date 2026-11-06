-- Isolated 0.75.7 Play fixture, Studio session adapter and seeded QA hero only.
-- Uses real Configure/Solo/ReturnLobby remotes and production arrival loading
-- code, with Battle role selected explicitly for the local (non-teleport) run.
local p=game.Players.LocalPlayer
local RS=game.ReplicatedStorage
local Http=game.HttpService
local report={kind='ALL_EPIC_ENTRY_NATIVE',checks=0,epics={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function waitFor(fn,label,timeout)
 local untilTime=os.clock()+(timeout or 45)
 repeat if fn()then return end;task.wait(.1)until os.clock()>untilTime
 error(label..' timed out; phase='..tostring(p:GetAttribute('K0SessionPhase')))
end
local ok,err=xpcall(function()
 check(game.PlaceId==0 and game:GetService('RunService'):IsStudio(),'local fixture only')
 waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby'end,'initial lobby')
 check(p:GetAttribute('TLTInventoryMode')=='Studio session','no live account store')
 local r=RS.Remotes
 local latest
 r.ExpeditionState.OnClientEvent:Connect(function(s)latest=s end)
 for _,id in ipairs({'FV-01','EC-01','GW-01','HG-01','DW-01'})do
  local row={missionId=id};report.epics[#report.epics+1]=row
  p:SetAttribute('TLTQAEntryProgress',id)
  waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby'end,'lobby before '..id)
  local request='qa-configure-'..id
  r.ExpeditionRequest:FireServer({action='Configure',missionId=id,difficultyId='Easy',requestId=request})
  waitFor(function()return latest and latest.requestId==request end,'configure '..id)
  check(not latest.error and latest.selection.missionId==id,'mission accepted '..id)
  task.wait(.5)
  local loader=game.ReplicatedFirst.QAEntryLoader:Clone()
  loader.Enabled=false;loader.Parent=game.ReplicatedFirst;loader.Enabled=true
  waitFor(function()return p.PlayerGui:FindFirstChild('ArrivalLoadingScreen')end,'cover installed '..id)
  local started=os.clock()
  r.ExpeditionRequest:FireServer({action='Solo',requestId='qa-solo-'..id})
  waitFor(function()return p:GetAttribute('K0SessionPhase')=='Tutorial'and p.Character and p.Character:GetAttribute('K0SpawnReady')==true end,'adventure '..id,60)
  waitFor(function()return not p.PlayerGui:FindFirstChild('ArrivalLoadingScreen')end,'loading dismissal '..id,30)
  check(p:GetAttribute('TLTBattleClientReady')==true,'battle UI ready '..id)
  check(workspace:GetAttribute('TLTCombatReady')==true,'server combat ready '..id)
  local root=p.Character.HumanoidRootPart
  local actualZone=require(RS.Shared.CampaignAccess).region(root.Position.X,root.Position.Z)
  check(actualZone==id,'character at selected epic '..id)
  check(p.PlayerGui:FindFirstChild('DeepwoodWorldMap')~=nil,'map initialized '..id)
  row.position={root.Position.X,root.Position.Y,root.Position.Z};row.seconds=os.clock()-started;row.loadingDismissed=true
  r.K0HeroRequest:FireServer('ReturnLobby','qa-return-'..id)
  waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby' and p.Character and p.Character:GetAttribute('K0SpawnReady')==true end,'return '..id,45)
  row.returned=true
  loader:Destroy();task.wait(.6)
 end
end,debug.traceback)
report.pass=ok;if not ok then report.error=tostring(err)end
p:SetAttribute('TLTQAEntryResult',Http:JSONEncode(report))
return Http:JSONEncode(report)
