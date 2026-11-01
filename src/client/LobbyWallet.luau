local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Wallet=require(script.Parent.WalletDisplay)
local M={}

function M.create(player,parent,world)
 local gui=Instance.new("ScreenGui")
 gui.Name="LobbyWallet";gui.ResetOnSpawn=false;gui.DisplayOrder=70
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local wallet=Wallet.create(gui)
 -- The lobby has no minimap: align the balances beside the top menu.
 local function resize()
  local width=gui.AbsoluteSize.X
  if width>0 and width<500 then
   -- Keep TD's left rejoin launcher and the right menu clear on narrow screens.
   wallet.AnchorPoint=Vector2.zero;wallet.Position=UDim2.fromOffset(160,8)
   wallet.Size=UDim2.fromOffset(math.max(68,width-292),56)
  else
   wallet.AnchorPoint=Vector2.new(1,0);wallet.Position=UDim2.new(1,-132,0,8)
   wallet.Size=UDim2.fromOffset(208,56)
  end
 end
 local sizing=gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
 gui.Destroying:Connect(function()sizing:Disconnect()end)
 resize()
 local function refresh()
  local phase=player:GetAttribute("K0SessionPhase")
  gui.Enabled=world:GetAttribute("TLTServerRole")~="Battle"
   and not player:GetAttribute('TLTHeroSelectionOpen') and not player:GetAttribute('TLTProgressionOpen') and not player:GetAttribute('TLTInventoryOpen') and not player:GetAttribute('TLTLobbyTopMenuOpen')
   and (phase==nil or phase=="Lobby" or phase=="LoadingLobby" or phase=="ReturningLobby")
 end
 player:GetAttributeChangedSignal("K0SessionPhase"):Connect(refresh)
 player:GetAttributeChangedSignal('TLTHeroSelectionOpen'):Connect(refresh)
 player:GetAttributeChangedSignal('TLTProgressionOpen'):Connect(refresh)
 player:GetAttributeChangedSignal('TLTInventoryOpen'):Connect(refresh)
 player:GetAttributeChangedSignal('TLTLobbyTopMenuOpen'):Connect(refresh)
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
