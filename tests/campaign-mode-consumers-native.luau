-- Run in an isolated Edit DataModel; actual UI renderers, normal account APIs.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local S=game.ReplicatedStorage.Shared
local client=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local I,P,A,M,G,C=require(S.ItemCatalog),require(S.DeepwoodProgress),require(S.AdventureRules),require(S.CampaignModeProgress),require(S.HeroProgression),require(S.CampaignContent)
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local function begin(p,mode,run)return assert(A.begin(p,'hero','DW-01',mode,run,p.revision,R,I))end
local function finish(p,run)
 local c=C.byId['DW-01']
 for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)then
  for _,s in ipairs(g.activity and g.activity.steps or {false})do
   p=assert(A.event(p,'hero',c.id,g.id,s and s.choices and(s.solution or s.choices[1].id)or g.choice and 'shared',s and s.id or nil,R,I,run))
  end
 end end
 return p
end
local gui=Instance.new('ScreenGui');gui.Name='ModeConsumerRegression';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(900,650);host.Parent=gui
local fixture
local role=workspace:GetAttribute('TLTServerRole')
local ok,err=xpcall(function()
 local prior={Easy={'Hard'},Hard={'Easy'},Insane={'Easy','Hard'},Hell={'Easy','Hard','Insane'}}
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  local p=assert(R.addHero(R.new(991),'hero','knight',I));p.heroes.hero.level=99;p.heroes.hero.progression=G.new(99)
  for _,other in ipairs(prior[mode])do local run='done_'..other;p=finish(begin(p,other,run),run)end
  p=begin(p,mode,'current_'..mode);local hero=p.heroes.hero
  check(R.validate(p,I),'valid normal profile '..mode)
  check(M.journal(hero,mode).main==0,'selected mode has no completed story '..mode)
  hero.deepwood=assert(P.reveal(hero.deepwood,'DW-01',1,1))
  local snapshot={ready=true,heroId='hero',heroes=R.copy(p.heroes),atHub=false}
  local journal=require(client.LobbyQuestJournal).create(host);journal.show(snapshot)
  check(journal.root.Quests['Quest_DW-01']:GetAttribute('QuestStatus')=='IN PROGRESS','own incomplete quest '..mode)
  check(journal.root.Summary.Text:find(mode:upper(),1,true)~=nil,'quest mode label '..mode)
  local atlas=require(client.LobbyAtlas).create(host);atlas.show(snapshot)
  check(atlas.rows()['DW-02'].name:GetAttribute('Accessible')==false,'own locked region '..mode)
  check(atlas.rows()['DW-01'].name:GetAttribute('ExploredPercent')>0,'shared discovery remains visible '..mode)
  check(atlas.root.Progress.Text:find(mode:upper(),1,true)~=nil,'atlas mode label '..mode)
  -- Temporary cosmetic scene; no existing authored scene is changed.
  if not fixture then
   for _,v in ipairs(workspace:GetDescendants())do assert(not(v:IsA('Model')and v:GetAttribute('ExpansionEvent')),'authored scene present')end
   assert(not workspace:FindFirstChild('DawnspireLobbyPrototype'),'authored lobby present')
   fixture=Instance.new('Folder');fixture.Name='ModeConsumerSceneRegression';fixture.Parent=workspace
  end
  local scene=Instance.new('Model');scene:SetAttribute('ExpansionEvent','DW-01:supplies');scene:SetAttribute('ExpansionChapter','DW-01');scene:SetAttribute('ExpansionMin',0);scene:SetAttribute('ExpansionMax',2)
  local part=Instance.new('Part');part.Anchored=true;part.CanCollide=false;part.Parent=scene;scene.Parent=fixture
  local presentation=require(client.CampaignExpansionPresentation)
  local navigation=require(client.LobbyNavigation).create(gui,{open=function()end,close=function()end});navigation.rail.Visible=false;navigation.panel.Visible=false
  presentation.update({journal=A.projection(hero)});check(part.Transparency==0,'own pending scene visible '..mode)
  workspace:SetAttribute('TLTServerRole','Battle');navigation.update(snapshot)
  check(part.Transparency==0,'hidden lobby does not repaint field '..mode)
  snapshot.atHub=true;navigation.update(snapshot)
  check(part.Transparency==0,'battle role blocks shared repaint even at safe hub '..mode)
  workspace:SetAttribute('TLTServerRole','Lobby');navigation.update(snapshot)
  check(part.Transparency==1,'shared lobby homecoming still paints '..mode)
  snapshot.atHub=false;presentation.update({journal=A.projection(hero)});navigation.update(snapshot)
  check(part.Transparency==0,'nonhub repaint stays mode bound '..mode)
  -- Refresh paths retain the selected mode and do not mutate the account.
  journal.update(snapshot);atlas.update(snapshot)
  check(journal.root.Quests['Quest_DW-01']:GetAttribute('QuestStatus')=='IN PROGRESS','refresh keeps own quest '..mode)
  check(M.journal(hero,mode).main==0 and R.validate(p,I),'UI grants no progress '..mode)
  p=finish(p,'current_'..mode);p=begin(p,mode,'replay_'..mode)
  snapshot.heroes=R.copy(p.heroes);journal.update(snapshot);atlas.update(snapshot)
  check(journal.root.Quests['Quest_DW-01']:GetAttribute('QuestStatus')=='COMPLETED','replay UI keeps actual completion '..mode)
  check(atlas.rows()['DW-02'].name:GetAttribute('Accessible')==true,'replay UI keeps actual unlocked region '..mode)
  journal.root:Destroy();atlas.root:Destroy();navigation.rail:Destroy();navigation.panel:Destroy();scene:Destroy();task.wait()
 end
end,debug.traceback)
workspace:SetAttribute('TLTServerRole',role)
if fixture then fixture:Destroy()end;gui:Destroy()
assert(ok,err)
local report={kind='MODE_CONSUMER_REGRESSION',checks=checks,pass=true,modes=4}
print('MODE_CONSUMER_REGRESSION '..game.HttpService:JSONEncode(report));return report
