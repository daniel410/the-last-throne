-- Real lobby panel constructors with a local-player facade and fixed viewport hosts.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local RS=game.ReplicatedStorage
local report={kind='LOBBY_PANEL_SIZE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local player=Instance.new('Folder');player.Name='LobbyPanelFixture';player:SetAttribute('K0SessionPhase','Lobby');player.Parent=workspace
local createdRemotes=not RS:FindFirstChild('Remotes')
local remotes=RS:FindFirstChild('Remotes')or Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=RS
local made={}
for _,n in ipairs({'HeroProgressionRequest','InventoryRequest','InventoryState','InventoryOpenStorage','K0HeroState'})do if not remotes:FindFirstChild(n)then local r=Instance.new('RemoteEvent');r.Name=n;r.Parent=remotes;table.insert(made,r)end end
local modules={}
local replacement=[[local Players={LocalPlayer={WaitForChild=function()return game:GetService('CoreGui')end,GetAttribute=function(_,k)return script.Player.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.Player.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.Player.Value:GetAttributeChangedSignal(k)end}}]]
local function copy(name)
 local m=Instance.new('ModuleScript');m.Name='SizeQA'..name
 local source=client[name].Source
 local n;source,n=source:gsub('local Players%s*=%s*game:GetService%(["\']Players["\']%)',function()return replacement end);assert(n==1,name..' player seam')
 m.Source=source;local v=Instance.new('ObjectValue');v.Name='Player';v.Value=player;v.Parent=m;m.Parent=client;table.insert(modules,m);return require(m)
end
local gui=Instance.new('ScreenGui');gui.Name='SizeQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Name='Host';host.BackgroundTransparency=1;host.Parent=gui
local ok,err=xpcall(function()
 local heroController=copy('HeroLobbyGui').create(function()end)
 local heroGui=game.CoreGui.HeroLobbyGui;local heroShade=heroGui.Shade;local hero=heroShade.HeroPanel
 check(not heroGui:FindFirstChild('OpenHeroes'),'standalone HEROES launcher removed')
 require(client.LobbyMenuBridge):Fire('Heroes');task.wait()
 check(heroShade.Visible,'existing HEROES navigation still opens the panel')
 check(player:GetAttribute('TLTHeroSelectionOpen')==true,'visible hero panel suppresses lobby chrome')
 heroController.setSuppressed(true);check(not player:GetAttribute('TLTHeroSelectionOpen'),'suppression restores lobby chrome')
 heroController.setSuppressed(false);check(player:GetAttribute('TLTHeroSelectionOpen'),'restored panel suppresses lobby chrome again')
 local armory=require(client.ArmoryView).create(host,function()end,false,'blacksmith')
 local items=require(client.ArmoryView).create(host,function()end,false,'items')
 local diamonds=require(client.ArmoryView).create(host,function()end,true)
 local navigation=require(client.LobbyNavigation).create(host,{close=function()end,open=function()end})
 local expedition=require(client.ExpeditionView).create(host,function()end)
 local settings=require(client.SettingsGui).create({WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return player:GetAttribute(k)end,SetAttribute=function(_,k,v)player:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return player:GetAttributeChangedSignal(k)end})
 local growth=copy('HeroGrowthGui').create()
 local inventory=copy('InventoryGui').create()
 local invGui=game.CoreGui.InventoryGui;local growthGui=game.CoreGui.HeroGrowthGui;local settingsGui=game.CoreGui.GameSettings
 local invShade=invGui.InventoryOverlay;local growthShade=growthGui.Overlay;local settingsShade=settingsGui.Overlay
 check(not invGui.OpenBag.Visible and not growthGui.OpenHero.Visible and not settingsGui.OpenSettings.Visible,'individual top launchers are hidden in the lobby: '..tostring(invGui.OpenBag.Visible)..' / '..tostring(growthGui.OpenHero.Visible)..' / '..tostring(settingsGui.OpenSettings.Visible))
 player:SetAttribute('K0SessionPhase','ReturningLobby');task.wait()
 check(invGui.OpenBag.Visible and growthGui.OpenHero.Visible and settingsGui.OpenSettings.Visible,'non-lobby launcher visibility is preserved')
 player:SetAttribute('K0SessionPhase','Lobby');task.wait()
 local panels={armory.panel,items.panel,diamonds.panel,navigation.panel,expedition.panel,settingsShade.SettingsPanel,invShade.ClaimsOverlay.ClaimsPopup}
 local atlas=require(client.LobbyAtlas).create(navigation.panel)
 for _,size in ipairs({Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(390,780)})do
  host.Size=UDim2.fromOffset(size.X,size.Y);heroShade.Size=host.Size;invShade.Size=host.Size;growthShade.Size=host.Size;settingsShade.Size=host.Size;task.wait(.1)
  local h=hero.AbsoluteSize
  for _,panel in ipairs(panels)do
   check((panel.AbsoluteSize-h).Magnitude<1,'same size as HEROES: '..panel.Name..' at '..tostring(size))
   check((panel.AbsolutePosition-hero.AbsolutePosition).Magnitude<1,'same position as HEROES: '..panel.Name..' at '..tostring(size))
  end
  local lobbyBagSize,lobbyBagPosition=invShade.InventoryPanel.AbsoluteSize,invShade.InventoryPanel.AbsolutePosition
  local lobbyGrowthSize,lobbyGrowthPosition=growthShade.InventoryPanel.AbsoluteSize,growthShade.InventoryPanel.AbsolutePosition
  player:SetAttribute('K0SessionPhase','Tutorial');task.wait()
  check((invShade.InventoryPanel.AbsoluteSize-lobbyBagSize).Magnitude<1 and (invShade.InventoryPanel.AbsolutePosition-lobbyBagPosition).Magnitude<1,'bag matches battle layout at '..tostring(size))
  check((growthShade.InventoryPanel.AbsoluteSize-lobbyGrowthSize).Magnitude<1 and (growthShade.InventoryPanel.AbsolutePosition-lobbyGrowthPosition).Magnitude<1,'growth matches battle layout at '..tostring(size))
  player:SetAttribute('K0SessionPhase','Lobby');task.wait()
  check(armory.panel.Offers.AbsoluteSize.Y>0,'blacksmith has scrollable stock')
  check(items.panel.Offers.AbsoluteSize.Y>0,'item shop has scrollable stock')
  check(diamonds.panel.Offers.AbsoluteSize.Y>0,'diamond shop has scrollable stock')
  atlas.show(nil);task.wait();check(atlas.root.Atlas.AbsoluteSize.Y>0,'story map has usable canvas')
  check(atlas.root.Atlas.AbsolutePosition.Y+atlas.root.Atlas.AbsoluteSize.Y<=atlas.root.RegionDetail.AbsolutePosition.Y+1,'map and detail do not overlap')
  check(expedition.panel.PartyList.AbsoluteSize.Y>0,'party list has usable scroll area')
  check(hero.HeroCards.AbsoluteSize.Y>0,'hero cards remain visible')
  if size.Y<400 then
   local cards=hero.HeroCards;local card=cards.knight
   check(cards.ScrollingDirection==Enum.ScrollingDirection.X and cards.AutomaticCanvasSize==Enum.AutomaticSize.X,'short screen uses horizontal hero scrolling')
   check(card.AbsoluteSize.Y<=cards.AbsoluteSize.Y and card.ChooseHero.AbsolutePosition.Y+card.ChooseHero.AbsoluteSize.Y<=cards.AbsolutePosition.Y+cards.AbsoluteSize.Y,'hero choice fits the card viewport')
   check(card.ChooseHero.AbsoluteSize.Y>=38,'hero selection remains touch sized')
   check(hero.TitlePlaque.AbsolutePosition.Y>=hero.AbsolutePosition.Y,'short screen title stays inside panel')
   check(hero.ExploreCourtyard.AbsolutePosition.Y+hero.ExploreCourtyard.AbsoluteSize.Y<=cards.AbsolutePosition.Y,'close button stays above cards')
  end
  check(invShade.InventoryPanel.Content.AbsoluteSize.Y>0,'bag content remains visible')
  check(growthShade.InventoryPanel.Content.AbsoluteSize.Y>0,'growth content remains visible')
  check(settingsShade.SettingsPanel.Options.AbsoluteSize.Y>0,'settings options remain visible')
 end
 player:SetAttribute('K0SessionPhase','Tutorial');task.wait()
 check(invShade.InventoryPanel.UISizeConstraint.MaxSize==Vector2.new(1160,760),'battle bag size restored')
 check(growthShade.InventoryPanel.UISizeConstraint.MaxSize==Vector2.new(1240,800),'battle growth size restored')
 check(settingsShade.SettingsPanel.UISizeConstraint.MaxSize==Vector2.new(620,520),'battle settings size restored')
 player:SetAttribute('K0SessionPhase','Lobby');task.wait()
 check(invShade.InventoryPanel.UISizeConstraint.MaxSize==Vector2.new(1160,760),'bag retains battle size in lobby')
 check(growthShade.InventoryPanel.UISizeConstraint.MaxSize==Vector2.new(1240,800),'growth retains battle size in lobby')
end,debug.traceback)
for _,name in ipairs({'SizeQA','HeroLobbyGui','InventoryGui','HeroGrowthGui','GameSettings'})do local g=game.CoreGui:FindFirstChild(name);if g then g:Destroy()end end
for _,m in ipairs(modules)do m:Destroy()end
for _,r in ipairs(made)do r:Destroy()end
if createdRemotes then remotes:Destroy()end
player:Destroy();if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;return report
