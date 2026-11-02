local RS=game:GetService('ReplicatedStorage')
local Players=game:GetService('Players')
local T=require(script.Parent.TDInventoryTheme)
local Text=require(RS.Shared.AdventureText)
local M={}
function M.start(gui)
 local player=Players.LocalPlayer;local remotes=RS:WaitForChild('Remotes')
 local button=T.button(gui,'PlayAgain',Text.PlayAgain,UDim2.new(.5,0,.25,0),UDim2.fromOffset(320,48));button.AnchorPoint=Vector2.new(.5,0);button.Visible=false
 local completed,returning,opened=false,false,false
 if workspace:GetAttribute('TLTServerRole')=='Battle'or game:GetService('RunService'):IsStudio()then task.spawn(function()
 remotes:WaitForChild('DeepwoodState').OnClientEvent:Connect(function(s)
  completed=s.expedition and s.expedition.completed==true and not s.training
  button.Visible=completed and player:GetAttribute('K0SessionPhase')=='Tutorial'
 end)
 end)end
 button.Activated:Connect(function()
  if not completed then return end
  opened=false;returning=true;T.enabled(button,false);task.delay(8,function()if button.Parent and player:GetAttribute('K0SessionPhase')=='Tutorial'then T.enabled(button,true)end end);remotes:WaitForChild('K0HeroRequest'):FireServer('ReturnLobby',game:GetService('HttpService'):GenerateGUID(false):gsub('%-',''))
 end)
 local function phase()
  if player:GetAttribute('K0SessionPhase')~='Tutorial'then button.Visible=false end
  if (returning or player:GetAttribute('TLTReplayRequested'))and not opened and player:GetAttribute('K0SessionPhase')=='Lobby'then
   opened=true
   returning=false;T.enabled(button,true)
   task.delay(.4,function()require(script.Parent.LobbyMenuBridge):Fire('Play')end)
  end
 end
 player:GetAttributeChangedSignal('K0SessionPhase'):Connect(phase)
 player:GetAttributeChangedSignal('TLTReplayRequested'):Connect(phase)
 phase()
end
return M
