assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local player=Instance.new('Folder');player.Name='TopMenuPlayer';player.Parent=workspace;player:SetAttribute('K0SessionPhase','Lobby')
local facade={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return player:GetAttribute(k)end,SetAttribute=function(_,k,v)player:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return player:GetAttributeChangedSignal(k)end}
local calls={};local actions={};for _,id in ipairs({'Hero','Bag','Journal','Settings','DiamondShop','LoginRewards'})do actions[id]=function()table.insert(calls,id)end end
local report={kind='LOBBY_TOP_MENU_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local wallet,view
local ok,err=xpcall(function()
 wallet=require(client.LobbyWallet).create(facade,game.CoreGui,workspace)
 view=require(client.LobbyTopMenu).create(facade,actions)
 view.resize(Vector2.new(1280,720))
 local menuButton=view.gui.Menu
 check(wallet.Wallet.Position.Y.Offset==menuButton.Position.Y.Offset+menuButton.Size.Y.Offset+8,'wallet sits below MENU with 8px gap')
 check(wallet.Wallet.AnchorPoint.X==1 and wallet.Wallet.Position.X.Offset==menuButton.Position.X.Offset+menuButton.Size.X.Offset,'wallet and MENU share the right edge')
 check(menuButton.Size==UDim2.fromOffset(112,44) and menuButton.Caption.Text=='MENU','TD lobby menu size and label')
 check(menuButton:FindFirstChild('TDIcon_settings')~=nil and menuButton.TDButtonArt.SliceScale==.25,'TD lobby menu artwork')
 check(view.buttons.Journal.Caption.Text=='QUEST [J]','quest menu has the unified label')
 check(view.buttons.DiamondShop.Caption.Text=='Diamond Shop' and view.buttons.LoginRewards.Caption.Text=='Login Rewards','TD commerce entries use existing destinations')
 check(view.gui.Enabled and not view.menu.Visible and wallet.Enabled,'lobby menu starts closed and wallet visible')
 check(view.menu.Size==UDim2.fromOffset(232,452) and math.abs(view.menu.TDPanelArt.SliceScale-.45)<.00001,'TD panel width and border')
 check(view.menu.MenuList.Category_SUPPLIES.Text=='SUPPLIES' and view.menu.MenuList.Category_PROGRESS.Text=='PROGRESS' and view.menu.MenuList.Category_MORE.Text=='MORE','TD section headings')
 check(view.buttons.Bag.LayoutOrder<view.buttons.Hero.LayoutOrder and view.buttons.Hero.LayoutOrder<view.buttons.Journal.LayoutOrder and view.buttons.Journal.LayoutOrder<view.buttons.Settings.LayoutOrder,'supply/progress/more grouping')
 for i,id in ipairs({'Hero','Bag','Journal','Settings','DiamondShop','LoginRewards'})do
  local b=view.buttons[id];check(b.Selectable and b.Active,'menu action selectable '..id)
  check(b.Parent==view.menu.MenuList and b.Size==UDim2.new(1,-8,0,52),'TD menu-list row dimensions '..id)
  check(math.abs(b.TDButtonArt.SliceScale-.45)<.00001 and b.Caption.TextSize==16,'TD menu-list artwork and type '..id)
  check(b.Caption.Position.X.Offset==60 and b:FindFirstChild('TDIcon_'..({Hero='hero',Bag='bag',Journal='quests',Settings='settings',DiamondShop='shop',LoginRewards='login_rewards'})[id])~=nil,'TD left emblem and inset '..id)
  view.toggle();check(view.menu.Visible and not wallet.Enabled,'opening menu hides overlapping wallet')
  view.choose(id);check(calls[#calls]==id and not view.menu.Visible and wallet.Enabled,'action closes menu and restores wallet')
 end
 for _,size in ipairs({Vector2.new(1920,1080),Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(390,844)})do
  view.resize(size);check(view.menu.Size.X.Offset<=size.X-24 and view.menu.Size.Y.Offset+56<=size.Y-12,'menu fits '..tostring(size))
 end
 view.toggle();check(not wallet.Enabled,'MENU click hides balances')
 view.toggle();check(wallet.Enabled,'closing MENU restores balances')
 view.toggle();player:SetAttribute('TLTSupporterOpen',true)
 check(not view.gui.Enabled and not view.menu.Visible and not wallet.Enabled,'supporter detail hides overlapping menu and balances')
 player:SetAttribute('TLTSupporterOpen',false);check(view.gui.Enabled and wallet.Enabled,'closing supporter detail restores lobby controls')
 player:SetAttribute('TLTSupporterOpen',true);player:SetAttribute('TLTInventoryOpen',true);player:SetAttribute('TLTSupporterOpen',false)
 check(not view.gui.Enabled,'closing supporter detail cannot restore menu over another open detail')
 player:SetAttribute('TLTInventoryOpen',false)
 player:SetAttribute('TLTHeroSelectionOpen',true);check(not view.gui.Enabled and not wallet.Enabled,'hero selection hides menu and wallet')
 player:SetAttribute('TLTHeroSelectionOpen',false);check(view.gui.Enabled and wallet.Enabled,'closing hero selection restores menu and wallet')
 view.toggle();player:SetAttribute('TLTInventoryOpen',true);check(not view.gui.Enabled and not view.menu.Visible,'opening bag closes menu')
 player:SetAttribute('TLTInventoryOpen',false);check(view.gui.Enabled,'menu returns after closing bag')
 view.toggle();player:SetAttribute('TLTLobbyPanelOpen',true);check(not view.gui.Enabled and not player:GetAttribute('TLTLobbyTopMenuOpen'),'lobby overlay closes menu')
 player:SetAttribute('TLTLobbyPanelOpen',false);player:SetAttribute('K0SessionPhase','Tutorial');check(not view.gui.Enabled,'battle hides lobby menu')
 player:SetAttribute('K0SessionPhase','Lobby');check(view.gui.Enabled,'returning to lobby restores menu')
end,debug.traceback)
if view then view.gui:Destroy()end;if wallet then wallet:Destroy()end;player:Destroy()
if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
