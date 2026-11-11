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
