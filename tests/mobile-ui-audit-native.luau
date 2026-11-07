-- Actual GUI geometry in an isolated Studio; synthetic state, no purchases or saves.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Shared=game.ReplicatedStorage.Shared
local report={kind='MOBILE_UI_AUDIT_NATIVE',checks=0,failures={},cases={}}
local function check(v,m)report.checks+=1;if not v then table.insert(report.failures,m)end end
local function inside(v,host,label)
 local p,s,h,t=v.AbsolutePosition,v.AbsoluteSize,host.AbsolutePosition,host.AbsoluteSize
 check(s.X>0 and s.Y>0 and p.X>=h.X-1 and p.Y>=h.Y-1 and p.X+s.X<=h.X+t.X+1 and p.Y+s.Y<=h.Y+t.Y+1,label)
end
local function separate(a,b,label)
 local p,s,q,t=a.AbsolutePosition,a.AbsoluteSize,b.AbsolutePosition,b.AbsoluteSize
 check(p.X+s.X<=q.X+1 or q.X+t.X<=p.X+1 or p.Y+s.Y<=q.Y+1 or q.Y+t.Y<=p.Y+1,label)
end
local function textFits(label,tag)
 local h=game.TextService:GetTextSize(label.Text,label.TextSize,label.Font,Vector2.new(math.max(1,label.AbsoluteSize.X),10000)).Y
 check(h<=label.AbsoluteSize.Y+1,tag..' text fits '..label:GetFullName())
end
local sizes={Vector2.new(1280,591),Vector2.new(844,390),Vector2.new(750,323),Vector2.new(750,280),Vector2.new(568,320),Vector2.new(390,844),Vector2.new(320,568)}
local player=Instance.new('Folder');player.Name='MobileAuditPlayer';player.Parent=workspace;player:SetAttribute('K0SessionPhase','Lobby')
local facade={UserId=1,WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return player:GetAttribute(k)end,SetAttribute=function(_,k,v)player:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return player:GetAttributeChangedSignal(k)end}
local gui=Instance.new('ScreenGui');gui.Name='MobileAudit';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.BackgroundTransparency=1;host.Parent=gui
local modules={}
local function copy(name,source)
 local m=Instance.new('ModuleScript');m.Name='Audit'..name;m.Source=source or client[name].Source;m.Parent=client;table.insert(modules,m);return m
end
local function case(name,fn)
 print('MOBILE_AUDIT_CASE '..name)
 local ok,err=xpcall(fn,debug.traceback);if not ok then table.insert(report.failures,name..': '..tostring(err))end
end
case('settings',function()
 local view=require(client.SettingsGui).create(facade);local overlay=view.gui.Overlay
 for _,size in ipairs(sizes)do
  overlay.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.15)
  local panel=overlay.SettingsPanel;local list=panel.Options
  inside(panel,overlay,'settings panel '..tostring(size));check(list.AbsoluteSize.Y>=80,'settings readable list '..tostring(size))
  separate(panel.Description,list,'settings description clears list');separate(list,panel.SessionNote,'settings list clears note')
  separate(panel.Title,panel.Close,'settings title clears close')
  for _,label in ipairs({panel.Title,panel.Description,panel.SessionNote})do textFits(label,'settings')end
  for _,row in ipairs(list:GetChildren())do if row:IsA('Frame')then
   textFits(row:FindFirstChild('Name'),'settings name');textFits(row.Hint,'settings hint');separate(row.Hint,row.Toggle,'settings hint clears toggle');inside(row.Toggle,row,'settings toggle inside row')
  end end
 end
 view.gui:Destroy()
end)
case('shops',function()
 local Items=require(Shared.ItemCatalog);local Rules=require(game.ServerScriptService.Server.Inventory.InventoryRules)
 local p=Rules.addHero(Rules.new(91),'hero','knight',Items)
 for _,store in ipairs({'items','blacksmith','diamonds'})do
  local view=require(client.ArmoryView).create(host,function()error('audit sent a trade')end,store=='diamonds',store)
  view.render({ready=true,heroId='hero',heroes=p.heroes,items={},revision=p.revision,wallet={gold=99999,diamonds=9999}})
  for _,size in ipairs(sizes)do
   host.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.15)
   local panel=view.panel
   inside(panel,host,store..' panel '..tostring(size));check(panel.Offers.AbsoluteSize.Y>=64,store..' usable offers '..tostring(size))
   separate(panel.Title,panel.Close,store..' title clears close');textFits(panel.Title,store)
   if store=='blacksmith'then inside(panel.EnhancementHelp,panel,'help inside');separate(panel.Title,panel.EnhancementHelp,'blacksmith title clears help');separate(panel.EnhancementHelp,panel.BuyTab,'blacksmith help clears buy')end
   for _,card in ipairs(panel.Offers:GetChildren())do if card:IsA('Frame')and card:FindFirstChild('Trade')then
    textFits(card:FindFirstChild('Name'),store);textFits(card.Details,store);separate(card.Details,card.Trade,store..' text clears trade')
   end end
  end
  view.panel:Destroy()
 end
end)
case('lobby maps and quests',function()
 local map=require(client.LobbyAtlas).create(host)
 local quest=require(client.LobbyQuestJournal).create(host)
 for _,size in ipairs(sizes)do
  -- Match the shared panel footprint, including its desktop cap.
  local short=size.Y<400 or size.X<720
  host.Size=UDim2.fromOffset(math.min(800,size.X-(short and 24 or 120)),math.min(510,size.Y-(short and 24 or 164)));task.wait(.1)
  for epic=1,5 do
   map.show({heroId='h',heroes={h={deepwood={main=35,explored={},clears={}}}}});map.selectEpic(epic)
   quest.show(nil);quest.selectEpic(epic);task.wait(.1)
   local root=map.root;local area=root.Atlas
   inside(area,root,'lobby map inside '..tostring(size));check(area.AbsoluteSize.Y>=100,'lobby map usable height '..tostring(size))
   separate(area,root.RegionDetail,'lobby map clears detail');separate(root.Fit,root.Zoom,'map zoom controls clear each other')
   for _,b in ipairs({root.Fit,root.Zoom})do inside(b,root,'map button inside');check(b.AbsoluteSize.Y>=44,'map button touch size')end
   textFits(root.RegionDetail,'lobby map detail')
   local list=quest.root.Quests;check(list.AbsoluteSize.Y>=80,'quest list usable '..tostring(size));inside(list,quest.root,'quest list bounds')
  end
 end
 map.root:Destroy();quest.root:Destroy()
end)
case('expedition',function()
 local source=client.ExpeditionView.Source:gsub('local player=game.Players.LocalPlayer',"local player={UserId=1,GetAttribute=function()return 'Lobby'end,GetAttributeChangedSignal=function()return workspace.MobileAuditPlayer:GetAttributeChangedSignal('K0SessionPhase')end}")
 local view=require(copy('ExpeditionView',source)).create(host,function()error('audit sent expedition command')end)
 local modes={};for _,mode in ipairs(require(Shared.Difficulty).order)do modes[mode]={allowed=true,level=1,firstXP=10,firstGold=10,repeatXP=5,repeatGold=5}end
 view.render({role='Lobby',studio=true,hero={classId='knight'},selection={missionId='DW-01',difficultyId='Easy'},missions={{id='DW-01',region='Deepwood',title='Missing Supply Convoy',objective='Find the convoy.',modes=modes}}})
 for _,size in ipairs(sizes)do
  host.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
  local panel=view.panel;inside(panel,host,'expedition panel')
  check(panel.PartyList.AbsoluteSize.Y>=44,'expedition readable list '..tostring(size));inside(panel.PartyList,panel,'expedition list bounds')
  separate(panel.Tabs,panel.PartyList,'expedition tabs clear content');separate(panel.PartyList,panel.Notice,'expedition list clears notice');separate(panel.Notice,panel.Footer,'expedition notice clears footer')
  for _,b in ipairs(panel.Modes:GetChildren())do if b:IsA('GuiButton')then inside(b,panel,'difficulty visible '..b.Name);check(b.AbsoluteSize.Y>=44,'difficulty touch size');textFits(b.Caption,'difficulty')end end
 end
 view.panel:Destroy()
end)
case('battle map',function()
 player:SetAttribute('K0SessionPhase','Tutorial')
 local State=require(client.DeepwoodMapState);State.current={journal=require(Shared.DeepwoodProgress).new(),training=false}
 local source=client.DeepwoodMap.Source:gsub("local Players=game:GetService%('Players'%)",[[local fixturePlayer=workspace.MobileAuditPlayer;local Players={LocalPlayer={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return fixturePlayer:GetAttribute(k)end,SetAttribute=function(_,k,v)fixturePlayer:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return fixturePlayer:GetAttributeChangedSignal(k)end}}]])
 source=source:gsub('local viewport=gui.AbsoluteSize','local viewport=Vector2.new(script.Viewport.Value.X,script.Viewport.Value.Y)')
 local m=copy('DeepwoodMap',source);local value=Instance.new('Vector3Value');value.Name='Viewport';value.Value=Vector3.new(844,390,0);value.Parent=m
 local view=require(m).start();view.open(true)
 for _,size in ipairs(sizes)do
  value.Value=Vector3.new(size.X,size.Y,0);view.fit();task.wait(.1)
  local panel=view.panel
  check(panel.AbsoluteSize.Y<=size.Y-24 and panel.AbsoluteSize.X<=size.X-24,'battle map fits safe area')
  local area=panel.Atlas;inside(area,panel,'battle atlas bounds');check(area.AbsoluteSize.Y>=100,'battle map usable '..tostring(size))
  if size.Y<540 and size.X>=568 then check(area.AbsoluteSize.Y>=panel.AbsoluteSize.Y*.55,'battle map retains content height '..tostring(size))end
  separate(area,panel.RegionDetail,'battle map clears region info')
  for _,name in ipairs({'Close','SelectEpic','NavigationTrail','ZoomOut','ZoomIn','Fit','Center'})do
   local b=panel[name]
   if b.Visible then inside(b,panel,'map control '..name);check(b.AbsoluteSize.Y>=44,'map touch '..name)end
  end
  for epic=1,5 do view.selectEpic(epic);task.wait();check(panel.SelectEpic.Caption.Text:find(require(Shared.CampaignContent).epics[epic].region:upper(),1,true)~=nil or not panel.SelectEpic.Visible,'every region remains selectable')end
 end
 view.open(false);view.panel.Parent:Destroy();player:SetAttribute('K0SessionPhase','Lobby')
end)
case('supporter and completion',function()
 local supporter=require(client.SupporterDetails).create(game.CoreGui)
 local Info=require(Shared.SupporterInfo)
 local data=Info.project({main=4,flags={['DW-03:report']=true}},nil,'SupportReady',true,{credits=5,active=false,story=4});data.balance=1000;data.canBuy=true;data.heroId='qa';data.revision=1
 supporter:open(data)
 local completion=require(client.StoryCompletionView).create(host,function()error('completion navigated')end)
 completion:show({heading='ADVENTURE COMPLETE',action='CONTINUE ADVENTURE',title='The Crown Returns',outcome='You protected the kingdom.',reward='100 Gold',saved='Progress saved.',guidance='Choose your next adventure from the world map.'})
 for _,size in ipairs(sizes)do
  supporter:resize(size.X,size.Y);completion:resize(size.X,size.Y);task.wait(.1)
  local panel=supporter.panel
  textFits(panel.Title,'supporter heading');check(panel.Information.AbsoluteSize.Y>=60,'supporter readable list '..tostring(size))
  separate(panel.Information,panel.PurchaseTerms,'supporter list clears mandatory terms')
  for _,n in ipairs({1,5,10})do local b=panel['Buy'..n];textFits(b.Caption,'supporter purchase '..tostring(size));inside(b,panel,'supporter purchase bounds');separate(panel.PurchaseTerms,b,'supporter terms clear purchase')end
  local done=completion.panel;check(done.AbsoluteSize.Y<=size.Y-24 and done.AbsoluteSize.X<=size.X-24,'completion uses safe bounds')
  textFits(done.Heading,'completion heading');separate(done.Heading,done.Close,'completion heading clears close')
  separate(done.Summary,done.Continue,'completion summary clears continue');check(done.Summary.AbsoluteSize.Y>=60,'completion scroll usable')
 end
 supporter:destroy();completion:destroy()
end)
case('combat HUD',function()
 local source=client.K0Hud.Source:gsub('local Players = game:GetService%("Players"%)',[[local fixturePlayer=workspace.MobileAuditPlayer;local Players={LocalPlayer={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return fixturePlayer:GetAttribute(k)end,GetAttributeChangedSignal=function(_,k)return fixturePlayer:GetAttributeChangedSignal(k)end}}]])
 source=source:gsub('local UserInputService = game:GetService%("UserInputService"%)','local UserInputService={TouchEnabled=true}')
 local module=copy('K0Hud',source);local hud=require(module).create()
 local root=game.CoreGui.DeepwoodTrainingHud.Root
 for _,size in ipairs(sizes)do
  root.Size=UDim2.fromOffset(size.X,size.Y);game.CoreGui.DeepwoodTopHud.Root.Size=root.Size;task.wait(.1)
  local actions,bar=root.Actions,root.SkillBar
  actions.Ultimate.Visible=true
  for _,group in ipairs({actions,bar})do for _,b in ipairs(group:GetChildren())do if b:IsA('GuiButton')and b.Visible then
   inside(b,root,'HUD button bounds '..b.Name..' '..tostring(size))
   local minimum=group==bar and size.X<390 and 35 or 44
   check(b.AbsoluteSize.X>=minimum and b.AbsoluteSize.Y>=minimum,'HUD touch target '..b.Name..' '..tostring(size))
   if group==bar then check(math.abs(b.AbsolutePosition.Y-bar.Item1.AbsolutePosition.Y)<1,'items and skills share one row '..b.Name..' '..tostring(size)) end
   for _,other in ipairs((group==actions and bar or actions):GetChildren())do if other:IsA('GuiButton')and other.Visible then separate(b,other,'HUD controls do not overlap '..b.Name..' / '..other.Name..' '..tostring(size))end end
  end end end
  if size.Y>size.X then check(bar.AbsolutePosition.Y+bar.AbsoluteSize.Y<=root.AbsolutePosition.Y+size.Y-170,'portrait HUD clears movement thumb area')end
  local top=game.CoreGui.DeepwoodTopHud.Root;local minimap=top.Minimap;local menu=minimap.MapActions
  menu.Visible=true;task.wait(.1);inside(menu,top,'battle menu stays inside safe screen '..tostring(size))
  if size.X<900 or size.Y<540 then
   separate(menu,minimap.MapMenu,'popup keeps its toggle reachable')
   for _,b in ipairs(menu:GetChildren())do if b:IsA('GuiButton')then inside(b,menu,'battle menu entry inside');check(b.AbsoluteSize.Y>=44,'battle menu touch target '..b.Name)end end
   check(minimap.MapMenu.AbsoluteSize.Y>=44 and minimap.WorldMap.AbsoluteSize.Y>=44,'minimap launchers remain touch sized')
  end
  menu.Visible=false
 end
 game.CoreGui.DeepwoodTrainingHud:Destroy();game.CoreGui.DeepwoodTopHud:Destroy()
end)
for _,m in ipairs(modules)do m:Destroy()end
player:Destroy();gui:Destroy()
report.pass=#report.failures==0
print('MOBILE_UI_AUDIT_NATIVE '..game.HttpService:JSONEncode(report))
return report
