-- Actual TD GUI constructors and text measurement, isolated from account services.
local RS=game:GetService('ReplicatedStorage')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local C=require(RS.Shared.CampaignContent)
local P=require(RS.Shared.DeepwoodProgress)
local report={checks=0,scope='native GUI constructors and text geometry; no real input/device acceptance'}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='QuestRewardQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(800,510);host.Parent=gui
local journal=require(client.LobbyQuestJournal).create(host)
local snapshot={heroId='hero',heroes={hero={deepwood=P.new()}}}
journal.show(snapshot)
for _,size in ipairs({Vector2.new(800,510),Vector2.new(726,299),Vector2.new(270,510)})do
 host.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
 for i=1,5 do
  journal.selectEpic(i);task.wait()
  local list=journal.root.Quests
  for _,row in ipairs(list:GetChildren())do if row:IsA('Frame')then
   local reward=row:FindFirstChild('Reward')
   check(reward and reward.Text:find('XP',1,true)and reward.Text:find('Gold',1,true),'all lobby rows show completion payout')
   check(not reward.Text:find('No fixed',1,true),'no rewardless quest text')
   check(reward.TextBounds.Y<=reward.AbsoluteSize.Y+1,'wrapped reward fits height at '..size.X..' '..row.Name)
   check(reward.Position.Y.Offset+reward.Size.Y.Offset<=row.Size.Y.Offset,'reward remains in row')
   local id=row.Name:sub(7)
   if id=='DW-Q1'then check(reward.Text:find('60 XP · 100 Gold · 2 Iron Ore',1,true),'side reward text matches actual fixed grant')end
   if id=='GW-01'then check(reward.Text:find('180 XP · 250 Gold',1,true),'Gloamwood first completion reward visible')end
  end end
 end
end
local book=require(client.DeepwoodQuestBook).create(gui,function()end)
local state=assert(P.accept(P.new(),'DW-Q1',true))
book.render({journal=state});book.setTab('Side')
local text={};for _,v in ipairs(book.panel:GetDescendants())do if v:IsA('TextLabel')then table.insert(text,v.Text)end end
check(table.concat(text,'\n'):find('60 XP · 100 Gold · 2 Iron Ore',1,true),'battle quest book shares fixed reward definition')
book.panel:Destroy();gui:Destroy()
print('QUEST_REWARD_UI_NATIVE '..game.HttpService:JSONEncode(report))
return report
