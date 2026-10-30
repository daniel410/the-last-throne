-- Isolated actual GUI constructors; no real Player input or device acceptance.
local client=game:GetService('StarterPlayer').StarterPlayerScripts.Client
local Http=game:GetService('HttpService')
local playerGui=Instance.new('Folder');playerGui.Name='QuestUiQA';playerGui.Parent=workspace
local report={checks=0,failures={}}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,reason=xpcall(function()
 local questBook=require(client.DeepwoodQuestBook).create(playerGui,function() end)
 local progressForQuest=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
 local questState=progressForQuest.new()
 local function bookText()
  local lines={};for _,v in ipairs(questBook.panel:GetDescendants()) do if v:IsA('TextLabel') then table.insert(lines,v.Text) end end;return table.concat(lines,'\n')
 end
 questBook.render({journal=questState})
 check(bookText():find('MAIN STORY 1 / 7',1,true) and bookText():find('The Missing Supply Convoy',1,true),'main quest has story identity distinct from region')
 check(bookText():find('Phase 1 / 3',1,true),'journal shows meaningful current phase')
 questBook.setTab('Side')
 check(not bookText():find('Supplies in the Marsh',1,true),'hidden discovery is absent before acceptance')
 questState=assert(progressForQuest.accept(questState,'DW-Q1',true));questBook.render({journal=questState})
 check(bookText():find('Waiting for story 2',1,true) and bookText():find('No fixed XP',1,true),'early side discovery explains report gate and exact reward')
 questBook.setTab('Chronicle');check(bookText():find('YOUR CHRONICLE',1,true),'chronicle is separate from active objectives')
 questBook.panel:Destroy()
end,debug.traceback)
playerGui:Destroy()
if not ok then table.insert(report.failures,tostring(reason)) end
report.pass=#report.failures==0
print('DEEPWOOD_QUEST_UI_NATIVE '..Http:JSONEncode(report));assert(report.pass,'Quest GUI failed')
