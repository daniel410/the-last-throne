local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage');local SSS=game:GetService('ServerScriptService');local Run=game:GetService('RunService')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'Use a local isolated build')
local report={kind='LOBBY_SERVICES_NATIVE',checks=0,failures={},coverage='Native compiler, GUI objects, TD weapon display, Player doubles for 20/4 admission; no published teleport or real concurrent clients'}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 Run:Run();task.wait(3)
 local server=SSS.Server;local client=game.StarterPlayer.StarterPlayerScripts.Client
 local scratch=Instance.new('Folder');scratch.Name='LobbyServicesQA';scratch.Parent=workspace
 for _,root in ipairs({RS.Shared,server,client}) do local sources=root:GetDescendants();table.insert(sources,root);for _,source in ipairs(sources) do if source:IsA('LuaSourceContainer') then
  local wrapper=Instance.new('ModuleScript');wrapper.Name='ParseOnly';wrapper.Source='if true then return true end\n'..source.Source;wrapper.Parent=scratch
  local success,reason=pcall(require,wrapper);check(success,'compile '..source:GetFullName()..': '..tostring(reason));wrapper:Destroy()
 end end end
 local merchant=workspace.DawnspireLobbyPrototype:FindFirstChild('DawnspireWeaponMerchant')
 check(merchant and merchant.WeaponCounter:FindFirstChildOfClass('ProximityPrompt'),'physical lobby armory and interaction')
 check(merchant:FindFirstChild('TDWeaponDisplay1'),'actual shared TD weapon display')
 check(RS.Remotes.ArmoryRequest and RS.Remotes.ExpeditionRequest,'server request remotes boot')
 local R=require(server.Inventory.InventoryRules);local C=require(RS.Shared.ItemCatalog)
 local p=R.addHero(R.new(9),'qa','knight',C);p.wallet.gold=1000;p.wallet.diamonds=20
 local bought=assert(R.shop(p,{action='Buy',requestId='native',heroId='qa',revision=p.revision,offerId='knight_weapon_veteran'},{atLobby=true},C))
 check(bought.wallet.gold==400 and bought.items['shop-native'],'real modules debit and deliver one weapon')
 local gui=Instance.new('ScreenGui');gui.Parent=scratch
 local view=require(client.ArmoryView).create(gui,function() end)
 local snapshot={revision=bought.revision,ready=true,heroId='qa',wallet=bought.wallet,heroes=bought.heroes,items={bought.items['shop-native']}}
 view.render(snapshot);check(view.panel.Balance.Text:find('400') and view.panel.Balance.Text:find('20'),'wallet is explicit in shop')
 check(view.panel.Offers:FindFirstChild('knight_weapon_veteran_diamond'),'Gold and Diamond offers rendered')
 check(view.panel.Offers:FindFirstChild('knight_weapon_veteran').Details.Text:find('equip after'),'low-level purchase explains later equip requirement')
 local expedition=require(client.ExpeditionView).create(gui,function() end)
 expedition.render({role='Lobby',population=1,capacity=20,studio=true,list={}})
 check(expedition.panel.PartyList.Create2 and expedition.panel.PartyList.Create3 and expedition.panel.PartyList.Create4,'2-4 hero party choices')
 check(expedition.panel.PartyList.Solo and expedition.panel.Description.Text:find('20'),'solo and 20-player lobby shown')
 expedition.render({role='Lobby',population=1,capacity=20,studio=false,rejoin={heroId='qa'},list={}})
 check(expedition.panel.PartyList.Rejoin,'rejoin offer rendered')
 local function admission(role,limit)
  local clone=server.Network.ExpeditionService:Clone();clone.Name='Admission'..role;clone.Parent=server.Network
  local network=require(clone);network.start({role=role,heroSession={},inventory={}})
  for i=1,limit do local _,e=network.admitArrival({GetJoinData=function() return {} end});check(not e,role..' seat '..i) end
  local _,e=network.admitArrival({GetJoinData=function() return {} end});check(e~=nil,role..' over-capacity admission rejected')
 end
 admission('Lobby',20);admission('Battle',4)
 scratch:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('LOBBY_SERVICES_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(report.pass,'Lobby services native fixture failed')
