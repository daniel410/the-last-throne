local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Text=require(RS.Shared.LobbyText)
local Wallet=require(script.Parent.WalletDisplay)
local M={}
function M.start()
 local p=Players.LocalPlayer
 require(script.Parent.LobbyWallet).start(p)
 local remotes=RS:WaitForChild('Remotes')
 local shopRequest=remotes:WaitForChild('ArmoryRequest');local networkRequest=remotes:WaitForChild('ExpeditionRequest')
 local gui=Instance.new('ScreenGui');gui.Name='LobbyServices';gui.ResetOnSpawn=false;gui.DisplayOrder=48;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p:WaitForChild('PlayerGui')
 local shopButton=T.button(gui,'OpenArmory','ARMORY',UDim2.new(1,-172,1,-60),UDim2.fromOffset(156,44))
 local partyButton=T.button(gui,'OpenExpedition','ADVENTURES',UDim2.new(0,16,1,-60),UDim2.fromOffset(156,44))
 local latest,pending
 local armory=require(script.Parent.ArmoryView).create(gui,function(command)
  command.requestId=Http:GenerateGUID(false):gsub('%-','');pending=command;shopRequest:FireServer(command)
 end)
 local expedition=require(script.Parent.ExpeditionView).create(gui,function(command) networkRequest:FireServer(command) end)
 local message=''
 local function lock()
  local open=armory.panel.Visible or expedition.panel.Visible;p:SetAttribute('TLTLobbyPanelOpen',open)
 end
 armory.panel:GetPropertyChangedSignal('Visible'):Connect(lock);expedition.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 shopButton.Activated:Connect(function() expedition.panel.Visible=false;armory.panel.Visible=not armory.panel.Visible;shopRequest:FireServer({action='GetState',requestId=Http:GenerateGUID(false):gsub('%-','')}) end)
 partyButton.Activated:Connect(function() armory.panel.Visible=false;expedition.panel.Visible=not expedition.panel.Visible;networkRequest:FireServer({action='GetState'}) end)
 local function inventory(s)
  if latest and s.revision<latest.revision then return end
  latest=s
  Wallet.update(s)
  if armory.panel.Visible then armory.render(s,message) end
 end
 remotes:WaitForChild('InventoryState').OnClientEvent:Connect(function(s) inventory(s) end)
 remotes:WaitForChild('ArmoryState').OnClientEvent:Connect(function(data)
  if data.open then armory.panel.Visible=true;expedition.panel.Visible=false end
  message=data.error and (Text[data.error] or Text.Unavailable) or data.requestId and data.requestId==(pending and pending.requestId) and 'Trade complete. Your wallet and weapon are saved.' or ''
  if data.error=='SaveUnknown' and pending then
   local exact=pending;task.delay(2,function() if pending==exact then shopRequest:FireServer(exact) end end)
  elseif data.requestId==(pending and pending.requestId) then pending=nil end
  inventory(data.inventory)
 end)
 remotes:WaitForChild('ExpeditionState').OnClientEvent:Connect(function(s)
  expedition.render(s,s.error and (Text[s.error] or Text.NetworkUnavailable))
  if s.open then expedition.panel.Visible=true;armory.panel.Visible=false end
  if s.travelling then expedition.panel.Visible=true;armory.panel.Visible=false end
 end)
 local function phase()
  local lobby=p:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle'
  shopButton.Visible=lobby;partyButton.Visible=lobby
  if not lobby then armory.panel.Visible=false;if not p:GetAttribute('TLTTravelLock') then expedition.panel.Visible=false end end
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(phase);phase()
 task.spawn(function()
  while gui.Parent do
   if p:GetAttribute('K0SessionPhase')=='Lobby' then networkRequest:FireServer({action='GetState'}) end
   task.wait(10)
  end
 end)
 shopRequest:FireServer({action='GetState',requestId=Http:GenerateGUID(false):gsub('%-','')})
end
return M
