assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local Shared=game.ReplicatedStorage.Shared
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local C=require(Shared.CampaignContent)
local P=require(Shared.DeepwoodProgress)
local Completion=require(Shared.StoryCompletion)
local report={kind='CAMPAIGN_CONTEXT_REVIEW_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
check(require(Shared.CampaignStoryText).version==2,'fixed artifact includes the final narrative review')
local briefs,outcomes={},{}
for _,c in ipairs(C.chapters)do
 check(not briefs[c.quest.brief]and not outcomes[c.quest.outcome],'all 47 real runtime stories have distinct purposes and results '..c.id)
 briefs[c.quest.brief]=true;outcomes[c.quest.outcome]=true
 for _,g in ipairs(c.goals)do if g.activity and g.activity.steps and #g.activity.steps==1 then
  check(g.text==g.activity.steps[1].text,'runtime objective and dialogue agree '..c.id..':'..g.id)
 end end
end
local gui=Instance.new('ScreenGui');gui.Name='ReviewedStoryCardsQA';gui.Parent=game.CoreGui
local journal=require(Client.DeepwoodJournal)
for _,chapter in ipairs(C.mainChapters)do
 local saved=P.new();saved.main=chapter.number-1;saved.expeditionMission=chapter.id
 for _,goal in ipairs(chapter.goals)do
  if goal.approach then
   local hint=journal.guidance({journal=saved},{chapter=chapter,goal=goal})
   check(hint and hint.note==goal.approach and hint.objective==goal.title,'pre-interaction HUD explains the contact '..chapter.id..':'..goal.id)
   check(hint.position==Vector3.new(table.unpack(goal.position)),'waypoint points at the contact')
   local bounds=game.TextService:GetTextSize(hint.note,13,Enum.Font.GothamBold,Vector2.new(224,1000))
   check(bounds.Y<=34,'approach fits the tracker at its authored width')
  end
  saved.flags[chapter.id..':'..goal.id]=true
 end
end
local host=Instance.new('Frame');host.Parent=gui
local expedition=require(Client.ExpeditionView).create(host,function()error('reading a brief cannot launch a mission')end)
expedition.panel.Visible=true
local c=C.byId['GW-02']
local mission={id=c.id,title=c.quest.title,objective=c.goals[1].title,region='Gloamwood',modes={Easy={allowed=true}}}
local selection={selection={missionId=c.id,difficultyId='Easy'},missions={mission},role='Lobby'}
local lobby=require(Client.LobbyQuestJournal).create(host)
local saved=P.new();saved.main=c.number-1
local snapshot={heroId='h',heroes={h={expeditions={modeJournals={Easy=saved}}}}}
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 host.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
 expedition.render(selection);lobby.show(snapshot);lobby.selectEpic(2);task.wait()
 local brief=expedition.panel.PartyList.StoryBrief
 check(brief.Text==c.quest.brief and brief.TextFits,'departure brief fits at '..tostring(size))
 local row=lobby.root.Quests['Quest_GW-02']
 check(row.Hint.Text==c.quest.brief and row.Hint.TextFits,'lobby journal includes the complete search directions')
 check(row.Reward.AbsolutePosition.Y>=row.Hint.AbsolutePosition.Y+row.Hint.AbsoluteSize.Y,'directions end before rewards')
end
mission.modes.Easy.allowed=false;expedition.render(selection)
check(not expedition.panel.PartyList:FindFirstChild('StoryBrief'),'locked mission hides the story brief')
host:Destroy()
local view=require(Client.StoryCompletionView).create(gui,function()error('reading a summary cannot grant progress')end)
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 for _,index in ipairs({7,14,21,28,35})do
  local c=C.mainChapters[index];local s=P.new();s.main=index;s.clears[c.id]=true
  local data=Completion.project({heroId='h',journal=s,completion={id=c.id}})
  check(data.outcome==c.quest.outcome and data.nextReason~=nil,'actual completion uses reviewed outcome and region handoff')
  view:show(data);view:resize(size.X,size.Y);task.wait()
  local scroll=view.panel.Summary
  check(scroll.AbsoluteSize.Y>0,'reviewed long summaries retain scroll space')
  for _,label in ipairs(scroll:GetChildren())do if label:IsA('TextLabel')then
   check(label.TextBounds.Y<=label.AbsoluteSize.Y+2,'reviewed outcome text fits its native row')
  end end
 end
end
view:destroy();gui:Destroy()
print('CAMPAIGN_CONTEXT_REVIEW_NATIVE '..game.HttpService:JSONEncode(report))
return report
