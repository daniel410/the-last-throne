-- Client, fresh isolated local Lobby Play. Uses the normal remote request path.
local p=game.Players.LocalPlayer
local r=game.ReplicatedStorage.Remotes
local report={kind='BATTLE_STARTUP_LIFECYCLE',checks=0}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local function waitFor(predicate,message)
 for _=1,150 do if predicate()then return end;task.wait(.1)end
 error(message)
end
waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby'end,'lobby ready')
check(not p.PlayerGui:FindFirstChild('DeepwoodTrainingHud'),'no battle HUD in initial lobby')
check(not workspace:FindFirstChild('DeepwoodCampaign'),'no campaign in initial lobby')
check(not r:FindFirstChild('K0Action'),'no combat remote in initial lobby')
r.K0HeroRequest:FireServer('CreateHero','lifecycle-create','knight')
task.wait(.5)
r.K0HeroRequest:FireServer('StartTutorial','lifecycle-launch')
waitFor(function()return p:GetAttribute('K0SessionPhase')=='Tutorial'and p.PlayerGui:FindFirstChild('DeepwoodJournal')end,'normal adventure entry')
check(p.PlayerGui:FindFirstChild('DeepwoodWorldMap'),'map initialized after entry')
waitFor(function()return p.Character and p.Character:GetAttribute('K0SpawnReady')==true end,'spawn readiness')
-- Match held attack retries; the first intent can precede the server's first
-- valid movement sample after spawning.
for _=1,20 do
 r.K0Action:FireServer('Attack',Vector3.new(0,0,-1));task.wait(.2)
 if(p.Character:GetAttribute('K0AttackSeq')or 0)>=1 then break end
end
check((p.Character:GetAttribute('K0AttackSeq')or 0)>=1,'server-approved held attack')
report.attackSeq=p.Character:GetAttribute('K0AttackSeq')
r.K0HeroRequest:FireServer('ReturnLobby','lifecycle-return')
waitFor(function()return p:GetAttribute('K0SessionPhase')=='Lobby'end,'return to lobby')
check(not p.PlayerGui.DeepwoodTrainingHud.Enabled,'HUD hidden on return')
r.K0HeroRequest:FireServer('StartTutorial','lifecycle-reenter')
waitFor(function()return p:GetAttribute('K0SessionPhase')=='Tutorial'end,'repeat entry')
local hudCount=0
for _,g in ipairs(p.PlayerGui:GetChildren())do if g.Name=='DeepwoodTrainingHud'then hudCount+=1 end end
check(hudCount==1,'reentry does not duplicate battle HUD')
check(p.PlayerGui.DeepwoodTrainingHud.Enabled,'HUD shown on reentry')
report.normalEntry=true;report.returnToLobby=true;report.reentry=true
-- Geometry idempotence is checked on Server by battle-startup-native.luau.
-- Client descendant counts vary with streaming and local effects.
return game:GetService('HttpService'):JSONEncode(report)
