assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local Shared=game.ReplicatedStorage.Shared
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local G=require(Shared.CampaignStoryGuide)
local P=require(Shared.DeepwoodProgress)
local C=require(Shared.CampaignContent)
local report={kind='STORY_RPG_GUIDE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='StoryGuideQA';gui.Parent=game.CoreGui
local saved=P.new();saved.seleneUnlocked=true
saved.flags['GW-02:exp_1']=true;saved.activities['GW-02:exp_1']=3
saved.flags['DW-02:exp_1']=true;saved.activities['DW-02:exp_1']=3
local before=game.HttpService:JSONEncode(saved)
local book=require(Client.DeepwoodQuestBook).create(gui,function()error('reading must not track or complete a quest')end)
book.panel.Visible=true
local function contains(text)
 for _,v in ipairs(book.panel:GetDescendants())do if v:IsA('TextLabel')and v.Text:find(text,1,true)then return true end end
 return false
end
for _,size in ipairs({Vector2.new(680,510),Vector2.new(680,275),Vector2.new(270,510)})do
 book.panel.Size=UDim2.fromOffset(size.X,size.Y)
 book.setTab('Main');book.render({heroId='h',journal=saved});task.wait()
 check(contains(G.text.purpose),'current purpose is rendered in the existing TD journal')
 check(contains(G.text.combatTitle),'combat help stays in the optional journal')
 check(book.openDiscovery('people','selene'),'unlocked Selene motivation opens without a support request')
 task.wait();check(contains('Someone is waiting for them'),'actual optional conversation is readable')
 check(book.openDiscovery('people','finn'),'earned Finn story opens')
 check(not contains('Brann\'s gate'),'undiscovered final callback is absent')
 check(not book.openDiscovery('people','lumi'),'future people cannot be opened via a guessed ID')
 local filter=book.panel.Chapters:FindFirstChild('DiscoveryFilters')
 for _,button in ipairs(filter:GetChildren())do if button:IsA('GuiButton')then
  check(button.AbsoluteSize.X>=44 and button.AbsoluteSize.Y>=44,'discovery controls retain touch hit areas')
 end end
 local scroll=book.panel.Chapters
 check(scroll.AbsoluteSize.Y>0 and scroll.AbsoluteSize.X>0,'journal keeps a usable scroll area')
 for _,label in ipairs(scroll:GetDescendants())do if label:IsA('TextLabel')then
  check(label.TextBounds.Y<=label.AbsoluteSize.Y+2,'authored story text has enough height: '..label.Text:sub(1,35))
 end end
end
book.render({heroId='other',journal=P.new()})
check(not book.openDiscovery('people','finn'),'hero switch removes unearned discoveries')
check(not contains('Finn was frightened'),'previous hero prose does not survive the next render')
check(game.HttpService:JSONEncode(saved)==before,'all real GUI reads preserve the saved journal')
-- Exercise the production dialogue builder itself, including long text on landscape touch.
local journalSource=Client.DeepwoodJournal.Source
local dialogueSource=assert(journalSource:match('( local dialog=Theme.frame.-) local navigation='),'production dialogue builder')
local construct=assert(loadstring('return function(Theme,gui,workspace)\n'..dialogueSource..'\nreturn dialog,prose,dialogueScroll,layoutDialogue\nend'))()
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 local panel,prose,scroll,layout=construct(require(Client.TDInventoryTheme),gui,{CurrentCamera={ViewportSize=size}})
 prose.Text=string.rep('Selene: Every traveler has a place to come home to. ',80)
 layout(prose.Text);panel.Visible=true;task.wait()
 check(panel.AbsoluteSize.Y<=size.Y*.65+1,'long dialogue remains within its height budget')
 check(prose.AbsoluteSize.Y>scroll.AbsoluteSize.Y,'long dialogue can be read by scrolling instead of clipping')
 check(scroll.AbsoluteSize.Y>0,'dialogue retains a readable area on short landscape screens')
 panel:Destroy()
end
local layer=workspace.DeepwoodCampaign.CampaignExpansion
local result=layer.Epic3['FV-07_exp_2'].ConfirmedRegionalResult
local present=require(Client.CampaignExpansionPresentation)
local partial=P.new();partial.flags['FV-07:exp_2']=true;partial.activities['FV-07:exp_2']=3
present.update({journal=partial});present.tick(1)
check(result:FindFirstChildWhichIsA('BasePart',true).Transparency==1,'final incident alone cannot show region victory')
partial.clears['FV-07']=true;present.update({journal=partial});present.tick(1)
check(result:FindFirstChildWhichIsA('BasePart',true).Transparency<1,'confirmed region clear reveals the result at the final action')
check(layer.Epic3['FV-07_exp_2']:FindFirstChild('ShelterSignalsRemembered')~=nil,'guardian resolution is recalled alongside the village reunion')
local arrows=0
for _,v in ipairs(layer.Epic4['EC-05_exp_2']:GetChildren())do if v.Name=='FlowArrowHead'then arrows+=1 end end
check(arrows==6,'each circuit drawing has physical directional arrowheads beyond color')
for _,m in ipairs({result,layer.Epic3['FV-07_exp_2'].ShelterSignalsRemembered})do
 for _,part in ipairs(m:GetDescendants())do if part:IsA('BasePart')then check(not part.CanCollide and not part.CanQuery and not part.CanTouch,'story results never alter shared traversal or targeting')end end
end
gui:Destroy()
print('STORY_RPG_GUIDE_NATIVE '..game.HttpService:JSONEncode(report))
return report
