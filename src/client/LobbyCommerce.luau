local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Text=require(RS.Shared.LobbyText)
local InventoryText=require(RS.Shared.InventoryText)
local Wallet=require(script.Parent.WalletDisplay)
local M={}
function M.start()
 local p=Players.LocalPlayer
 require(script.Parent.LobbyWallet).start(p)
 local remotes=RS:WaitForChild('Remotes')
 local shopRequest=remotes:WaitForChild('ArmoryRequest');local networkRequest=remotes:WaitForChild('ExpeditionRequest')
 local gui=Instance.new('ScreenGui');gui.Name='LobbyServices';gui.ResetOnSpawn=false;gui.DisplayOrder=48;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p:WaitForChild('PlayerGui')
 local partyButton=T.button(gui,'OpenExpedition','ADVENTURES',UDim2.new(0,16,1,-60),UDim2.fromOffset(156,44))
 local latest,pending
 local armory=require(script.Parent.ArmoryView).create(gui,function(command)
  command.requestId=Http:GenerateGUID(false):gsub('%-','');pending=command;shopRequest:FireServer(command)
 end,false,'blacksmith')
 local items=require(script.Parent.ArmoryView).create(gui,function(command)
  command.requestId=Http:GenerateGUID(false):gsub('%-','');pending=command;shopRequest:FireServer(command)
 end,false,'items')
 local diamonds=require(script.Parent.ArmoryView).create(gui,function(command)
  command.requestId=Http:GenerateGUID(false):gsub('%-','');pending=command;shopRequest:FireServer(command)
 end,true)
 local expedition=require(script.Parent.ExpeditionView).create(gui,function(command) networkRequest:FireServer(command) end)
 local dailyRequest=remotes:WaitForChild('DailyLoginRequest')
 local daily=require(script.Parent.DailyLoginGui).create(gui,function(command) dailyRequest:FireServer(command) end)
 local message=''
 local navigation
 remotes:WaitForChild('DailyLoginState').OnClientEvent:Connect(function(data)
  daily.receive(data)
  if navigation and type(data)=='table' and type(data.state)=='table' then navigation.dailyAvailable(data.state.status=='Ready' and data.state.canClaim==true)end
 end)
 local function lock()
  local open=(navigation and navigation.panel.Visible) or armory.panel.Visible or items.panel.Visible or diamonds.panel.Visible or expedition.panel.Visible or daily.panel.Visible;p:SetAttribute('TLTLobbyPanelOpen',open)
 end
 armory.panel:GetPropertyChangedSignal('Visible'):Connect(lock);items.panel:GetPropertyChangedSignal('Visible'):Connect(lock);diamonds.panel:GetPropertyChangedSignal('Visible'):Connect(lock);expedition.panel:GetPropertyChangedSignal('Visible'):Connect(lock);daily.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 local function closePanels()
  armory.panel.Visible=false;items.panel.Visible=false;diamonds.panel.Visible=false;expedition.panel.Visible=false;daily.panel.Visible=false
 end
 navigation=require(script.Parent.LobbyNavigation).create(gui,{
  close=closePanels,
  open=function(kind)
   if kind=='LoginRewards' then local wasOpen=daily.panel.Visible;closePanels();if not wasOpen then daily.open()end;return end
   local target=kind=='Blacksmith' and armory or kind=='DiamondShop' and diamonds or items;local wasOpen=target.panel.Visible
   closePanels();target.panel.Visible=not wasOpen
   shopRequest:FireServer({action='GetState',requestId=Http:GenerateGUID(false):gsub('%-','')})
  end,
 })
 navigation.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 partyButton.Activated:Connect(function() local wasOpen=expedition.panel.Visible;closePanels();navigation.panel.Visible=false;expedition.panel.Visible=not wasOpen;networkRequest:FireServer({action='GetState'}) end)
 local function inventory(s)
  if latest and s.revision<latest.revision then return end
  latest=s
  navigation.update(s)
  Wallet.update(s)
  if armory.panel.Visible then armory.render(s,message) end
  if items.panel.Visible then items.render(s,message) end
  if diamonds.panel.Visible then diamonds.render(s,message) end
 end
 remotes:WaitForChild('InventoryState').OnClientEvent:Connect(function(s) inventory(s) end)
 remotes:WaitForChild('ArmoryState').OnClientEvent:Connect(function(data)
  if data.open then closePanels();navigation.panel.Visible=false;(data.store=='items' and items or armory).panel.Visible=true end
  message=data.error and (Text[data.error] or InventoryText[data.error] or Text.Unavailable) or data.requestId and data.requestId==(pending and pending.requestId) and 'Trade complete. Your wallet and items are saved.' or ''
  if data.error=='SaveUnknown' and pending then
   local exact=pending;task.delay(2,function() if pending==exact then shopRequest:FireServer(exact) end end)
  elseif data.requestId==(pending and pending.requestId) then pending=nil end
  inventory(data.inventory)
 end)
 remotes:WaitForChild('ExpeditionState').OnClientEvent:Connect(function(s)
  expedition.render(s,s.error and (Text[s.error] or Text.NetworkUnavailable))
  if s.open then closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true end
  if s.travelling then closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true end
 end)
 local function phase()
  local lobby=p:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle'
  navigation.rail.Visible=lobby;partyButton.Visible=lobby
  if lobby then task.delay(.3,function()if p.Parent and p:GetAttribute('K0SessionPhase')=='Lobby'then dailyRequest:FireServer({action='GetState'})end end)end
  if not lobby then navigation.panel.Visible=false;items.panel.Visible=false;diamonds.panel.Visible=false;armory.panel.Visible=false;daily.panel.Visible=false;if not p:GetAttribute('TLTTravelLock') then expedition.panel.Visible=false end end
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(phase);phase()
 task.spawn(function()
  local ticks=0
  while gui.Parent do
   ticks+=1;if ticks%6==0 and p:GetAttribute('K0SessionPhase')=='Lobby'then dailyRequest:FireServer({action='GetState'})end
   if p:GetAttribute('K0SessionPhase')=='Lobby' then networkRequest:FireServer({action='GetState'}) end
   task.wait(10)
  end
 end)
 shopRequest:FireServer({action='GetState',requestId=Http:GenerateGUID(false):gsub('%-','')})
end
return M
