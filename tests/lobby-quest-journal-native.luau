assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Progress=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local gui=Instance.new('ScreenGui');gui.Name='LobbyQuestQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(800,510);host.Parent=gui
local report={kind='LOBBY_QUEST_JOURNAL_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function count(list)local n=0;for _,v in ipairs(list:GetChildren())do if v:IsA('GuiObject')then n+=1 end end;return n end
local ok,err=xpcall(function()
 local view=require(client.LobbyQuestJournal).create(host);view.show(nil)
 local list=view.root.Quests
 check(count(list)==11,'Deepwood shows seven main and four side quests')
 check(list['Quest_DW-01']:GetAttribute('QuestStatus')=='LOCKED','no selected hero locks quests')
 local journal=Progress.new();local snapshot={heroId='h',heroes={h={deepwood=journal}}};view.update(snapshot)
 check(list['Quest_DW-01']:GetAttribute('QuestStatus')=='IN PROGRESS','first main quest is active')
 check(list['Quest_DW-02']:GetAttribute('QuestStatus')=='LOCKED','future main quest remains locked')
 check(list['Quest_DW-02'].Hint.Text:find('Missing Supply Convoy',1,true)~=nil,'locked main quest explains actual prerequisite')
 check(list['Quest_DW-Q1']:GetAttribute('QuestStatus')=='LOCKED','unaccepted side quest is locked')
 check(list['Quest_DW-Q1'].Hint.Text:find('Supply Survivor',1,true)~=nil,'eligible side quest explains who accepts it')
 check(list['Quest_DW-Q1'].Title.Text:find('Supplies in the Marsh',1,true)~=nil,'legacy side quest title is displayed')
 journal.accepted['DW-Q1']=true;view.update(snapshot);check(list['Quest_DW-Q1']:GetAttribute('QuestStatus')=='IN PROGRESS','accepted side quest is active')
 journal.accepted['DW-Q1']=nil;journal.flags['DW-Q1:waterproof_log']=true;view.update(snapshot)
 check(list['Quest_DW-Q1']:GetAttribute('QuestStatus')=='IN PROGRESS','legacy in-progress side quest remains active')
 journal.flags={};journal.main=1;journal.clears['DW-01']=true;view.update(snapshot)
 check(list['Quest_DW-01']:GetAttribute('QuestStatus')=='COMPLETED' and list['Quest_DW-02']:GetAttribute('QuestStatus')=='IN PROGRESS','completed and next main quest use progress')
 view.selectEpic(2);check(count(list)==7 and list['Quest_GW-01']:GetAttribute('QuestStatus')=='LOCKED','Gloamwood is second and locked before Deepwood completion')
 journal.main=7;view.update(snapshot);check(list['Quest_GW-01']:GetAttribute('QuestStatus')=='IN PROGRESS','Gloamwood opens after Deepwood')
 view.selectEpic(3);check(count(list)==11 and list['Quest_FV-01']:GetAttribute('QuestStatus')=='LOCKED','Frozen Vale is third and remains locked')
 journal.main=14;view.update(snapshot);check(list['Quest_FV-01']:GetAttribute('QuestStatus')=='IN PROGRESS','Frozen Vale opens after Gloamwood')
 check(list['Quest_FV-Q1']:GetAttribute('QuestStatus')=='LOCKED' and list['Quest_FV-Q1'].Hint.Text:find('Discover',1,true)~=nil,'undiscovered quest stays locked with discovery hint')
 view.selectEpic(4);check(count(list)==11 and list['Quest_EC-01']:GetAttribute('QuestStatus')=='LOCKED','Ember quests visible and locked')
 journal.main=21;view.update(snapshot);check(list['Quest_EC-01']:GetAttribute('QuestStatus')=='IN PROGRESS','Ember opens after Frozen Vale')
 journal.main=28;view.selectEpic(5);view.update(snapshot);check(count(list)==7 and list['Quest_HG-01']:GetAttribute('QuestStatus')=='IN PROGRESS','HG follows EC')
 local nav=require(client.LobbyNavigation).create(gui,{open=function()end,close=function()end})
 nav.update(snapshot);nav.showGuide('Quest')
 check(nav.panel.Visible and nav.panel.LobbyQuestJournal.Visible and not nav.panel.LobbyAtlas.Visible,'quest button opens the journal in the shared lobby panel')
 nav.showGuide('Maps');check(nav.panel.LobbyAtlas.Visible and not nav.panel.LobbyQuestJournal.Visible,'map and journal views switch cleanly')
 require(client.LobbyMenuBridge):Fire('Quest');task.wait()
 check(nav.panel.LobbyQuestJournal.Visible and not nav.panel.LobbyAtlas.Visible,'top menu journal event opens the same journal')
 for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
  host.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
  check(list.AbsoluteSize.X>0 and list.AbsoluteSize.Y>0,'quest list scrolls at supported sizes')
  local tabs=view.root.EpicCategories
  for i=1,5 do
   local b=tabs:FindFirstChild('Epic'..i)
   check(b and b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,'epic button touch size '..i)
   check(b.AbsolutePosition.X>=tabs.AbsolutePosition.X and b.AbsolutePosition.X+b.AbsoluteSize.X<=tabs.AbsolutePosition.X+tabs.AbsoluteSize.X+1,'epic button visible '..i)
   check(b.AbsolutePosition.Y+b.AbsoluteSize.Y<=view.root.Summary.AbsolutePosition.Y,'epic button overlaps summary '..i)
  end
 end
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
