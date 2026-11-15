-- Read-only source probe: account transitions stay in memory, GUI is destroyed.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local Shared=game.ReplicatedStorage.Shared
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Rules=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local Items=require(Shared.ItemCatalog)
local Growth=require(Shared.HeroProgression)
local Progress=require(Shared.DeepwoodProgress)
local Adventure=require(Shared.AdventureRules)
local Modes=require(Shared.CampaignModeProgress)
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local profile=assert(Rules.addHero(Rules.new(991),'hero','knight',Items))
profile.heroes.hero.level=99;profile.heroes.hero.progression=Growth.new(99)
profile=assert(Adventure.begin(profile,'hero','DW-01','Easy','consumer-easy',profile.revision,Rules,Items))
local chapter=Content.byId['DW-01']
for _,goal in ipairs(chapter.goals)do if Progress.required(Adventure.projection(profile.heroes.hero),goal)then
 for _,step in ipairs(goal.activity and goal.activity.steps or {false})do
  profile=assert(Adventure.event(profile,'hero',chapter.id,goal.id,step and step.choices and(step.solution or step.choices[1].id)or goal.choice and 'shared',step and step.id or nil,Rules,Items,'consumer-easy'))
 end
end end
profile=assert(Adventure.begin(profile,'hero','DW-01','Hard','consumer-hard',profile.revision,Rules,Items))
assert(Rules.validate(profile,Items),'normal API account remains valid')
local hero=profile.heroes.hero
local report={kind='MODE_CONSUMER_NATIVE_REVIEW',activeMode=hero.expeditions.active.difficultyId,easyMain=Modes.journal(hero,'Easy').main,hardMain=Modes.journal(hero,'Hard').main,hardDW01Completed=Modes.journal(hero,'Hard').clears['DW-01']==true,hardDW02Accessible=Access.allowed(Modes.journal(hero,'Hard'),'DW-02')==true}
-- InventoryService.snapshot returns exactly this unchanged heroes copy.
local snapshot={ready=true,heroId='hero',heroes=Rules.copy(profile.heroes)}
local gui=Instance.new('ScreenGui');gui.Name='ModeConsumerReadOnlyReview';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(800,510);host.Parent=gui
local fixture
local ok,err=xpcall(function()
 local journal=require(client.LobbyQuestJournal).create(host)
 journal.show(snapshot)
 report.actualQuestStatus=journal.root.Quests['Quest_DW-01']:GetAttribute('QuestStatus')
 local atlas=require(client.LobbyAtlas).create(host)
 atlas.show(snapshot)
 report.actualDW02Accessible=atlas.rows()['DW-02'].name:GetAttribute('Accessible')==true
 report.pass=report.hardMain==0 and not report.hardDW01Completed and report.actualQuestStatus=='IN PROGRESS'and report.actualDW02Accessible==report.hardDW02Accessible
 -- Probe the real hidden-lobby navigation path without touching authored scenes.
 local existing=0
 for _,item in ipairs(workspace:GetDescendants())do if item:IsA('Model')and(item:GetAttribute('ExpansionEvent')or item:GetAttribute('ExpansionStepEvent'))then existing=existing+1 end end
 if existing==0 and not workspace:FindFirstChild('DawnspireLobbyPrototype')and not game.Lighting:FindFirstChild('TLTRegionalAtmosphere')then
  fixture=Instance.new('Folder');fixture.Name='ModeConsumerReadOnlyScene';fixture.Parent=workspace
  local scene=Instance.new('Model');scene.Name='PendingSupplies';scene:SetAttribute('ExpansionEvent','DW-01:supplies');scene:SetAttribute('ExpansionChapter','DW-01');scene:SetAttribute('ExpansionMin',0);scene:SetAttribute('ExpansionMax',2)
  local part=Instance.new('Part');part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Parent=scene
  local prompt=Instance.new('ProximityPrompt');prompt.Parent=part;scene.Parent=fixture
  local presentation=require(client.CampaignExpansionPresentation)
  presentation.update({journal=Adventure.projection(hero)})
  report.beforeHiddenNavigation={partTransparency=part.Transparency,promptEnabled=prompt.Enabled}
  local navigation=require(client.LobbyNavigation).create(gui,{open=function()end,close=function()end})
  navigation.rail.Visible=false;navigation.panel.Visible=false
  navigation.update(snapshot)
  report.afterHiddenNavigation={partTransparency=part.Transparency,promptEnabled=prompt.Enabled}
  report.sceneLeak=report.beforeHiddenNavigation.partTransparency==0 and report.beforeHiddenNavigation.promptEnabled==true and report.afterHiddenNavigation.partTransparency==1 and report.afterHiddenNavigation.promptEnabled==false
  presentation.update({journal=Adventure.projection(hero)})
 else report.sceneProbeSkipped='Existing authored scenes are left unchanged.'end
end,debug.traceback)
if fixture then fixture:Destroy()end
gui:Destroy()
if not ok then report.error=tostring(err);report.pass=false end
print('MODE_CONSUMER_NATIVE_REVIEW '..game.HttpService:JSONEncode(report))
return report
