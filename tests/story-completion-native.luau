assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run()end
local View=require(game.StarterPlayer.StarterPlayerScripts.Client.StoryCompletionView)
local M=require(game.ReplicatedStorage.Shared.StoryCompletion)
assert(type(require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodJournal).start)=='function','journal integration loads')
local P=require(game.ReplicatedStorage.Shared.DeepwoodProgress);local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local gui=Instance.new('ScreenGui');gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=game.CoreGui
local api=View.create(gui,function()end);local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(667,375)})do
  for _,id in ipairs({'DW-01','DW-04','DW-07','FV-07','EC-07'})do
   local c=C.byId[id];local s=P.new();s.main=c.number;s.clears[id]=true
   local data=M.project({heroId='test',journal=s,completion={id=id,title=c.quest.title,outcome=c.quest.outcome,xp=100,coins=200}}, {heroId='test',supporter={pass={story=c.number,active=true}}})
   api:show(data);api:resize(size.X,size.Y);task.wait(.5)
   local panel=api.panel
   check(panel.Visible and panel.Size.X.Offset<=size.X-24 and panel.Size.Y.Offset<=size.Y-24,'completion fits desktop and landscape')
   check(panel.TDPanelArt.Image~='' and panel.Continue.TDButtonArt.Image~='','approved TD frame and button art')
   check(panel.Heading.Text==data.heading and panel.Heading.TextBounds.Y<=panel.Heading.AbsoluteSize.Y+1,'story/epic completion heading readable')
   check(panel.Continue.AbsoluteSize.Y>=44 and panel.Close.AbsoluteSize.Y>=44,'touch button size')
   check(panel.Summary.AbsoluteSize.Y>=180,'summary has usable scroll area')
   check(panel:FindFirstChildOfClass('UIScale').Scale==1 and panel.CompletionAccent.BackgroundTransparency==0,'entrance effect settles')
   for _,v in ipairs(panel.Summary:GetChildren())do if v:IsA('TextLabel')then check(v.TextBounds.Y<=v.AbsoluteSize.Y+1,'result/reward/next-story/support explanation fits its line')end end
   check(panel.Summary.Line9.Text==M.text.support,'paid support expiry and reinvite instructions visible in summary')
   api:dismiss();check(not panel.Visible,'user can dismiss without starting a story')
  end
 end
 api:show({heading='STORY COMPLETE',title='New result',outcome='',reward='+0 XP',saved='',nextTitle='NEXT',region='',objective='',guidance='',action='CONTINUE'})
 check(not api.panel.Summary:FindFirstChild('Line9'),'old support expiry cleared for later summaries')
end,debug.traceback)
api:destroy();gui:Destroy();if started then Run:Stop()end
print('STORY_COMPLETION_NATIVE '..game.HttpService:JSONEncode({checks=checks,pass=ok,error=not ok and tostring(err)or nil}));assert(ok,err)
