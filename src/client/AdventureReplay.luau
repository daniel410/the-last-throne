local Players=game:GetService('Players')
local M={}
function M.start()
 local player=Players.LocalPlayer
 local opened=false
 local function phase()
  if player:GetAttribute('TLTReplayRequested')and not opened and player:GetAttribute('K0SessionPhase')=='Lobby'then
   opened=true
   task.delay(.4,function()require(script.Parent.LobbyMenuBridge):Fire('Play')end)
  end
 end
 player:GetAttributeChangedSignal('K0SessionPhase'):Connect(phase)
 player:GetAttributeChangedSignal('TLTReplayRequested'):Connect(phase)
 phase()
end
return M
