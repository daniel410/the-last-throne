-- Native GUI/state fixture; no real client rendering or live account balances.
local Players=game:GetService('Players')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'Use an isolated local build')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='LOBBY_WALLET_NATIVE',checks=0,failures={}}
local function check(value,message) report.checks+=1;assert(value,message) end
local scratch=Instance.new('Folder');scratch.Parent=workspace
local ok,err=xpcall(function()
 local player=Instance.new('Folder');player.Parent=scratch
 local world=Instance.new('Folder');world.Parent=scratch
 local view=require(client.LobbyWallet).create(player,scratch,world)
 local wallet=view.Wallet
 check(view.Enabled,'wallet visible before lobby phase arrives')
 check(view.DisplayOrder>60 and not view.ResetOnSpawn,'wallet above hero and bag windows and survives respawn')
 check(not wallet.Active and wallet.BackgroundTransparency==1,'wallet does not block lobby input')
 local display=require(client.WalletDisplay)
 display.update({revision=1,ready=false})
 check(wallet.Gold.Text=='Gold  —' and wallet.Diamonds.Text=='Diamonds  —','unloaded balances never appear as zero')
 display.update({revision=2,ready=true,wallet={gold=123456,diamonds=789}})
 check(wallet.Gold.Text=='Gold  123456' and wallet.Diamonds.Text=='Diamonds  789','both actual account balances shown')
 display.update({revision=3,ready=true,wallet={gold=0,diamonds=0}})
 check(wallet.Gold.Text=='Gold  0' and wallet.Diamonds.Text=='Diamonds  0','real zero balances shown')
 for _,phase in ipairs({'LoadingLobby','Lobby','ReturningLobby'}) do
  player:SetAttribute('K0SessionPhase',phase);task.wait()
  check(view.Enabled,'wallet visible during '..phase)
 end
 for _,phase in ipairs({'LoadingTutorial','Tutorial','Respawning'}) do
  player:SetAttribute('K0SessionPhase',phase);task.wait()
  check(not view.Enabled,'lobby wallet hidden during '..phase)
 end
 player:SetAttribute('K0SessionPhase','Lobby');task.wait()
 check(view.Enabled,'wallet returns after battle')
 world:SetAttribute('TLTServerRole','Battle');task.wait()
 check(not view.Enabled,'Battle role hides wallet even with stale Lobby phase')
 world:SetAttribute('TLTServerRole','Lobby');task.wait()
 check(view.Enabled,'role refresh restores lobby wallet')
 check(wallet.Size==UDim2.fromOffset(208,56) and wallet.Gold:FindFirstChildOfClass('UITextSizeConstraint').MaxTextSize==17,'readable shared wallet sizing preserved')
end,debug.traceback)
scratch:Destroy()
if not ok then table.insert(report.failures,tostring(err)) end
report.pass=#report.failures==0
print('LOBBY_WALLET_NATIVE '..game:GetService('HttpService'):JSONEncode(report))
assert(report.pass,'Lobby wallet fixture failed')
