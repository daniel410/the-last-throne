local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Text=require(RS.Shared.LobbyText)
local AdventureText=require(RS.Shared.AdventureText)
local InventoryText=require(RS.Shared.InventoryText)
local Wallet=require(script.Parent.WalletDisplay)
local Chrome=require(script.Parent.LobbyChromeVisibility)
local M={}
function M.start()
 local p=Players.LocalPlayer
 require(script.Parent.LobbyWallet).start(p)
 local remotes=RS:WaitForChild('Remotes')
 local shopRequest=remotes:WaitForChild('ArmoryRequest');local networkRequest=remotes:WaitForChild('ExpeditionRequest')
 local gui=Instance.new('ScreenGui');gui.Name='LobbyServices';gui.ResetOnSpawn=false;gui.DisplayOrder=48;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p:WaitForChild('PlayerGui')

 require(script.Parent.AdventureReplay).start(gui)
 local latest,pending,inventory
 local message=''
 local function trade(command)
  if pending then return end
  command.requestId=Http:GenerateGUID(false):gsub('%-','');pending=command;message='Saving transaction...'
  shopRequest:FireServer(command)
  if latest then inventory(latest) end
  -- A lost reply or a transient Busy/SaveUnknown must reuse the exact ID.
  task.spawn(function()
   while pending==command and gui.Parent do
    task.wait(2)
    if pending==command and gui.Parent then shopRequest:FireServer(command) end
   end
  end)
 end
 local armory=require(script.Parent.ArmoryView).create(gui,trade,false,'blacksmith')
 local items=require(script.Parent.ArmoryView).create(gui,trade,false,'items')
 local diamonds=require(script.Parent.ArmoryView).create(gui,trade,true)
 local expedition=require(script.Parent.ExpeditionView).create(gui,function(command) networkRequest:FireServer(command) end)
 local dailyRequest=remotes:WaitForChild('DailyLoginRequest')
 local daily=require(script.Parent.DailyLoginGui).create(gui,function(command) dailyRequest:FireServer(command) end)
 local navigation,sideGuide
 remotes:WaitForChild('DailyLoginState').OnClientEvent:Connect(function(data)
  daily.receive(data)
  if navigation and type(data)=='table' and type(data.state)=='table' then navigation.dailyAvailable(data.state.status=='Ready' and data.state.canClaim==true)end
 end)
 local function lock()
  local open=(navigation and navigation.panel.Visible) or armory.panel.Visible or items.panel.Visible or diamonds.panel.Visible or expedition.panel.Visible or daily.panel.Visible or (sideGuide and sideGuide.panel.Visible);p:SetAttribute('TLTLobbyPanelOpen',open)
 end
 gui.Destroying:Connect(function()p:SetAttribute('TLTLobbyPanelOpen',false)end)
 armory.panel:GetPropertyChangedSignal('Visible'):Connect(lock);items.panel:GetPropertyChangedSignal('Visible'):Connect(lock);diamonds.panel:GetPropertyChangedSignal('Visible'):Connect(lock);expedition.panel:GetPropertyChangedSignal('Visible'):Connect(lock);daily.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 local function closePanels()
  armory.panel.Visible=false;items.panel.Visible=false;diamonds.panel.Visible=false;expedition.panel.Visible=false;daily.panel.Visible=false;if sideGuide then sideGuide.close()end
 end
 local function openStore(kind)
  if kind=='LoginRewards' then local wasOpen=daily.panel.Visible;closePanels();if not wasOpen then daily.open()end;return end
  local target=kind=='Blacksmith' and armory or kind=='DiamondShop' and diamonds or items;local wasOpen=target.panel.Visible
  closePanels();target.panel.Visible=not wasOpen
  shopRequest:FireServer({action='GetState',requestId=Http:GenerateGUID(false):gsub('%-','')})
 end
 navigation=require(script.Parent.LobbyNavigation).create(gui,{close=closePanels,open=openStore})
 navigation.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 sideGuide=require(script.Parent.LobbySideQuestGuide).create(gui,{player=p,
  close=function()closePanels();navigation.panel.Visible=false end,
  send=function(command)remotes.LobbySideQuestRequest:FireServer(command)end,
  select=function(id,mode)
   closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true
   expedition.request({action='Configure',missionId=id,difficultyId=mode or 'Easy'})
  end})
 sideGuide.panel:GetPropertyChangedSignal('Visible'):Connect(lock)
 remotes:WaitForChild('LobbySideQuestResult').OnClientEvent:Connect(sideGuide.receive)
 require(script.Parent.LobbyMenuBridge).Event:Connect(function(action)
  if p:GetAttribute('K0SessionPhase')~='Lobby' or workspace:GetAttribute('TLTServerRole')=='Battle' then return end
  if action=='SideQuests'then sideGuide.open();return end
  if action=='FindTessa'then sideGuide.find();return end
  if action=='DiamondShop' or action=='LoginRewards' then navigation.panel.Visible=false;openStore(action);return end
  if action~='Play' then return end
  closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true
  networkRequest:FireServer({action='GetState'})
 end)
 local rejoinButton=require(script.Parent.LobbyRejoinButton).create(gui,function()
  closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true
  networkRequest:FireServer({action='GetState'})
 end)
 local function refreshNavigation()
  local visible=p:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle' and not Chrome.blocked(p)
  navigation.rail.Visible=visible;rejoinButton.Visible=visible
 end
 for _,key in ipairs(Chrome.blockers)do p:GetAttributeChangedSignal(key):Connect(refreshNavigation)end
 workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(refreshNavigation)
 inventory=function(s)
  if latest and s.revision<latest.revision then s=latest end
  latest=s
  navigation.update(s)
  sideGuide.update(s)
  Wallet.update(s)
  if armory.panel.Visible then armory.render(s,message,pending~=nil) end
  if items.panel.Visible then items.render(s,message,pending~=nil) end
  if diamonds.panel.Visible then diamonds.render(s,message,pending~=nil) end
 end
 remotes:WaitForChild('InventoryState').OnClientEvent:Connect(function(s) inventory(s) end)
 remotes:WaitForChild('ArmoryState').OnClientEvent:Connect(function(data)
  if data.open then closePanels();navigation.panel.Visible=false;(data.store=='items' and items or armory).panel.Visible=true end
  local outcome=data.enhancementOutcome
  message=not data.error and outcome and string.format(outcome.success and AdventureText.EnhancementSucceeded or AdventureText.EnhancementFailed,outcome.level,outcome.gold or 0) or data.error and (AdventureText[data.error] or Text[data.error] or InventoryText[data.error] or Text.Unavailable) or data.requestId and data.requestId==(pending and pending.requestId) and 'Trade complete. Your wallet and items are saved.' or ''
  if data.requestId==(pending and pending.requestId) and data.error~='SaveUnknown' and data.error~='Busy' and data.error~='AccountBusy' then pending=nil end
  inventory(data.inventory)
 end)
 remotes:WaitForChild('ExpeditionState').OnClientEvent:Connect(function(s)
  expedition.render(s,s.error and (AdventureText[s.error] or Text[s.error] or Text.NetworkUnavailable))
  if s.open then closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true end
  if s.travelling then closePanels();navigation.panel.Visible=false;expedition.panel.Visible=true end
 end)
 local function phase()
  local lobby=p:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle'
  refreshNavigation()
  if lobby then task.delay(.3,function()if p.Parent and p:GetAttribute('K0SessionPhase')=='Lobby'then dailyRequest:FireServer({action='GetState'})end end)end
  if not lobby then sideGuide.close();sideGuide.toast.Visible=false;navigation.panel.Visible=false;items.panel.Visible=false;diamonds.panel.Visible=false;armory.panel.Visible=false;daily.panel.Visible=false;if not p:GetAttribute('TLTTravelLock') then expedition.panel.Visible=false end end
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(phase)
 phase()
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
