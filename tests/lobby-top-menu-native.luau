assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local player=Instance.new('Folder');player.Name='TopMenuPlayer';player.Parent=workspace;player:SetAttribute('K0SessionPhase','Lobby')
local facade={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return player:GetAttribute(k)end,SetAttribute=function(_,k,v)player:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return player:GetAttributeChangedSignal(k)end}
local calls={};local actions={};for _,id in ipairs({'Hero','Bag','Journal','Settings'})do actions[id]=function()table.insert(calls,id)end end
local report={kind='LOBBY_TOP_MENU_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local wallet,view
local ok,err=xpcall(function()
 wallet=require(client.LobbyWallet).create(facade,game.CoreGui,workspace)
 view=require(client.LobbyTopMenu).create(facade,actions)
 local menuButton=view.gui.Menu
 check(wallet.Wallet.Position.Y.Offset==menuButton.Position.Y.Offset,'wallet and menu align at the top')
 check(wallet.Wallet.Position.X.Offset<=menuButton.Position.X.Offset,'wallet ends before the menu button')
 check(view.gui.Enabled and not view.menu.Visible and wallet.Enabled,'lobby menu starts closed and wallet visible')
 for i,id in ipairs({'Hero','Bag','Journal','Settings'})do
  local b=view.buttons[id];check(b.Selectable and b.Active,'menu action selectable '..id)
  check(b.Position.Y.Offset==8+(i-1)*44,'battle menu order '..id)
  check(b.Position.Y.Offset+b.Size.Y.Offset<=view.menu.Size.Y.Offset,'row fits menu '..id)
  view.toggle();check(view.menu.Visible and not wallet.Enabled,'opening menu hides overlapping wallet')
  view.choose(id);check(calls[#calls]==id and not view.menu.Visible and wallet.Enabled,'action closes menu and restores wallet')
 end
 view.toggle();player:SetAttribute('TLTInventoryOpen',true);check(not view.gui.Enabled and not view.menu.Visible,'opening bag closes menu')
 player:SetAttribute('TLTInventoryOpen',false);check(view.gui.Enabled,'menu returns after closing bag')
 view.toggle();player:SetAttribute('TLTLobbyPanelOpen',true);check(not view.gui.Enabled and not player:GetAttribute('TLTLobbyTopMenuOpen'),'lobby overlay closes menu')
 player:SetAttribute('TLTLobbyPanelOpen',false);player:SetAttribute('K0SessionPhase','Tutorial');check(not view.gui.Enabled,'battle hides lobby menu')
 player:SetAttribute('K0SessionPhase','Lobby');check(view.gui.Enabled,'returning to lobby restores menu')
end,debug.traceback)
if view then view.gui:Destroy()end;if wallet then wallet:Destroy()end;player:Destroy()
if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
