local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Wallet=require(script.Parent.WalletDisplay)
local M={}

function M.create(player,parent,world)
 local gui=Instance.new("ScreenGui")
 gui.Name="LobbyWallet";gui.ResetOnSpawn=false;gui.DisplayOrder=70
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local wallet=Wallet.create(gui)
 wallet.AnchorPoint=Vector2.new(1,0);wallet.Position=UDim2.new(1,-12,0,12)
 local function refresh()
  local phase=player:GetAttribute("K0SessionPhase")
  gui.Enabled=world:GetAttribute("TLTServerRole")~="Battle"
   and (phase==nil or phase=="Lobby" or phase=="LoadingLobby" or phase=="ReturningLobby")
 end
 player:GetAttributeChangedSignal("K0SessionPhase"):Connect(refresh)
 world:GetAttributeChangedSignal("TLTServerRole"):Connect(refresh)
 refresh()
 return gui
end

function M.start(player)
 local parent=player:WaitForChild("PlayerGui")
 if parent:FindFirstChild("LobbyWallet") then return end
 local gui=M.create(player,parent,workspace)
 -- Subscribe before requesting so the initial balance cannot be missed.
 task.spawn(function()
  local remotes=RS:WaitForChild("Remotes")
  local latestRevision=-1
  local connection=remotes:WaitForChild("InventoryState").OnClientEvent:Connect(function(snapshot)
   if snapshot.revision<latestRevision then return end
   latestRevision=snapshot.revision;Wallet.update(snapshot)
  end)
  gui.Destroying:Connect(function() connection:Disconnect() end)
  remotes:WaitForChild("InventoryRequest"):FireServer({action="GetState",requestId=Http:GenerateGUID(false)})
 end)
end
return M
