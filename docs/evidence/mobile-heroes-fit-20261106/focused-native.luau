local report=(function()
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
 for _,size in ipairs({Vector2.new(1280,800),Vector2.new(1280,591),Vector2.new(844,390),Vector2.new(750,323),Vector2.new(568,320),Vector2.new(390,780)})do
  host.Size=UDim2.fromOffset(size.X,size.Y);heroShade.Size=host.Size;task.wait(.2)
  local h=hero.AbsoluteSize
  if h.Y<480 then
   local cards=hero.HeroCards;local card=cards.knight
   check(cards.ScrollingDirection==Enum.ScrollingDirection.X and cards.AutomaticCanvasSize==Enum.AutomaticSize.X,'short screen uses horizontal hero scrolling')
   check(card.AbsoluteSize.Y<=cards.AbsoluteSize.Y and card.ChooseHero.AbsolutePosition.Y+card.ChooseHero.AbsoluteSize.Y<=cards.AbsolutePosition.Y+cards.AbsoluteSize.Y,'hero choice fits the card viewport')
   for _,classId in ipairs({'knight','elf','dwarf','mage'})do
    local choice=cards[classId].ChooseHero
    local p,s=choice.AbsolutePosition,choice.AbsoluteSize
    check(p.X>=cards.AbsolutePosition.X and p.X+s.X<=cards.AbsolutePosition.X+cards.AbsoluteSize.X+1,'every hero selection fits horizontally: '..classId..' at '..tostring(size))
    check(p.Y>=cards.AbsolutePosition.Y and p.Y+s.Y<=cards.AbsolutePosition.Y+cards.AbsoluteSize.Y+1,'every hero selection fits vertically: '..classId..' at '..tostring(size))
    check(s.Y>=44,'hero selection remains touch sized: '..classId)
    check(math.abs(cards[classId].AbsolutePosition.Y-card.AbsolutePosition.Y)<1,'all four heroes share one row: '..classId)
   end
   check(hero.TitlePlaque.AbsolutePosition.Y>=hero.AbsolutePosition.Y,'short screen title stays inside panel')
   check(hero.ExploreCourtyard.AbsolutePosition.Y+hero.ExploreCourtyard.AbsoluteSize.Y<=cards.AbsolutePosition.Y,'close button stays above cards')
  end
  print('HERO_VIEWPORT '..tostring(size)..' panel '..tostring(h)..' Mage '..tostring(hero.HeroCards.mage.ChooseHero.AbsolutePosition))
 end
end,debug.traceback)
for _,name in ipairs({'SizeQA','HeroLobbyGui','InventoryGui','HeroGrowthGui','GameSettings'})do local g=game.CoreGui:FindFirstChild(name);if g then g:Destroy()end end
for _,m in ipairs(modules)do m:Destroy()end
for _,r in ipairs(made)do r:Destroy()end
if createdRemotes then remotes:Destroy()end
player:Destroy();if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;return report

end)()
print(game.HttpService:JSONEncode(report))
assert(report.pass)
