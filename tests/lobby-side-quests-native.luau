-- Isolated engine constructor/text geometry checks; no real account or input acceptance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local RS=game.ReplicatedStorage
local clients=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local Items=require(RS.Shared.ItemCatalog)
local C=require(RS.Shared.CampaignContent)
local G=require(RS.Shared.HeroProgression)
local S=require(RS.Shared.LobbySideQuests)
local A=require(RS.Shared.AdventureRules)
local P=require(RS.Shared.DeepwoodProgress)
local report={checks=0,scope='isolated native constructors, marker states, text geometry; not real input or device acceptance'}
local function check(v,m)report.checks+=1;assert(v,m)end
local p=assert(R.addHero(R.new(928),'hero','knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do if not g.optional then for _,s in ipairs(g.activity and g.activity.steps or {false})do
 p=assert(R.story(p,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',Items,s and s.id or nil))
end end end end
local gui=Instance.new('ScreenGui');gui.Name='SideQuestNativeQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(800,510);host.Parent=gui
local attributes=Instance.new('Folder');attributes:SetAttribute('K0SessionPhase','Lobby')
local player=setmetatable({Character=nil},{__index=function(_,key)if key=='Character'then return nil end;local value=attributes[key];if type(value)=='function'then return function(_,...)return value(attributes,...)end end;return value end})
workspace:SetAttribute('TLTServerRole','Lobby')
local lobby=Instance.new('Folder');lobby.Name='DawnspireLobbyPrototype';lobby.Parent=workspace
local residents=Instance.new('Folder');residents.Name='DawnspireResidents';residents.Parent=lobby
local model=Instance.new('Model');model.Name='Tessa';model.Parent=residents
local part=Instance.new('Part');part.Anchored=true;part.Position=Vector3.new(-29,96,488);part.Parent=model;model.PrimaryPart=part
local sent={}
local guide=require(clients.LobbySideQuestGuide).create(host,{player=player,send=function(c)table.insert(sent,c)end,close=function()end,select=function()end})
local function snapshot(profile)return {ready=true,heroId='hero',heroes=profile.heroes}end
local function ack()
 if #sent>0 then local c=sent[#sent];p=assert(S.apply(p,c,R,Items));guide.update(snapshot(p));guide.receive({requestId=c.requestId})end
end
guide.update(snapshot(p));task.wait(.1)
check(guide.toast.Visible,'new requests actively announced')
check(#sent==1 and sent[1].action=='Notice','notice ack uses bounded server operation')
ack();check(guide.state().symbol=='!','read marker remains available')
check(host.PersonalSideQuestMarker.Symbol.Text=='!','personal world marker')
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 host.Size=UDim2.fromOffset(size.X,size.Y);guide.open();task.wait(.1)
 check(guide.panel.AbsoluteSize.X<=host.AbsoluteSize.X,'panel fits '..size.X)
 check(guide.panel.AbsoluteSize.Y<=host.AbsoluteSize.Y,'panel height fits '..size.Y)
 for _,button in ipairs({guide.panel.ViewAll,guide.panel.FindTessa})do check(button.Caption.TextBounds.Y<=button.Caption.AbsoluteSize.Y+1,'footer caption fits '..size.X)end
 for _,card in ipairs(guide.panel.Requests:GetChildren())do if card:IsA('Frame')and card.Name:match('^Quest_')then
  for _,name in ipairs({'Heading','NextAction','Reward'})do local label=card[name]
   check(label.TextBounds.Y<=label.AbsoluteSize.Y+1,'text fits '..name..' '..size.X)
   check(label.Position.Y.Offset+label.Size.Y.Offset<card.Action.Position.Y.Offset,'text above action '..name)
  end
  check(card.Action.AbsoluteSize.Y>=44,'touch action minimum')
  check(card.Action.Position.Y.Offset+44<=card.Size.Y.Offset,'action fits row')
 end end
 guide.find();task.wait(.1)
 local map=guide.panel.Requests.DawnspireMap.Courtyard
 check(map.Tessa.Caption.Text:find('!',1,true),'map shares marker state')
 check(map.Route.Size.X.Offset>0,'local map route visible')
 guide.close()
end
local c=C.byId['DW-Q1'];p=assert(A.begin(p,'hero',c.id,'Easy','native-guide',p.revision,R,Items))
for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)and g.id~=c.quest.turnIn then for _,s in ipairs(g.activity and g.activity.steps or {false})do
 p=assert(A.event(p,'hero',c.id,g.id,s and s.choices and s.choices[1].id or nil,s and s.id or nil,R,Items,'native-guide'))
end end end
guide.update(snapshot(p));task.wait(.1)
check(guide.state().symbol=='?','ready report priority')
check(host.PersonalSideQuestMarker.Symbol.Text=='?','ready world marker')
guide.open();task.wait(.1)
check(guide.panel.Requests['Quest_DW-Q1'].Action.Caption.Text=='Report Quest','report action visible')
local done=assert(S.apply(p,{action='Report',heroId='hero',questId=c.id,runId='native-guide'},R,Items))
guide.update(snapshot(done));task.wait(.1);check(guide.state().symbol=='!','remaining offers after report')
guide.update({ready=false,heroId='hero',heroes=done.heroes});task.wait(.1)
check(not host.PersonalSideQuestMarker.Enabled,'failed load hides false marker')
player:SetAttribute('K0SessionPhase','Tutorial');task.wait(.6)
check(not guide.panel.Visible and not guide.toast.Visible,'guide hidden outside lobby')
gui:Destroy();attributes:Destroy();lobby:Destroy()
print('LOBBY_SIDE_QUESTS_NATIVE '..game.HttpService:JSONEncode(report))
return report
