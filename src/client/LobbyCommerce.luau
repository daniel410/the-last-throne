local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Text=require(RS.Shared.LobbyText)
local M={}
function M.start()
 local p=Players.LocalPlayer;local remotes=RS:WaitForChild('Remotes')
 local shopRequest=remotes:WaitForChild('ArmoryRequest');local networkRequest=remotes:WaitForChild('ExpeditionRequest')
 local gui=Instance.new('ScreenGui');gui.Name='LobbyServices';gui.ResetOnSpawn=false;gui.DisplayOrder=48;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p:WaitForChild('PlayerGui')
 local wallet=T.frame(gui,'Wallet',UDim2.new(.5,0,0,8),UDim2.new(1,-48,0,42));wallet.AnchorPoint=Vector2.new(.5,0)
 local walletCap=Instance.new('UISizeConstraint');walletCap.MaxSize=Vector2.new(340,42);walletCap.Parent=wallet
 local balance=T.label(wallet,'Balance','Gold: —     Diamonds: —',UDim2.fromOffset(12,4),UDim2.new(1,-24,1,-8),14,T.color.gold);balance.TextXAlignment=Enum.TextXAlignment.Center
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
  balance.Text=s.ready and s.wallet and string.format('Gold: %d     Diamonds: %d',s.wallet.gold,s.wallet.diamonds) or 'Wallet unavailable · wait or rejoin'
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
  if s.travelling then expedition.panel.Visible=true;armory.panel.Visible=false end
 end)
 local function phase()
  local lobby=p:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle'
  shopButton.Visible=lobby;partyButton.Visible=lobby
  wallet.Position=UDim2.new(.5,0,0,lobby and 8 or 76)
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
