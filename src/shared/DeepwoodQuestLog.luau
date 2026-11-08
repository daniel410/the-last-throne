local Content=game and require(game:GetService('ReplicatedStorage').Shared.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local P=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress) or dofile('src/shared/DeepwoodProgress.luau')
local Log={}
-- Saved progression, rather than a completion-card button, drives main tracking.
-- Snapshots can arrive before the one-shot completion event after a save.
function Log.followNext(value,previous)
 local s=value and value.journal
 if not s or value.training then return false end
 if previous and previous.heroId==value.heroId and previous.journal and s.main>previous.journal.main then return true end
 local event=value.completion;local c=event and Content.byId[event.id]
 return c~=nil and not c.side and event.kind~='Accepted'and s.clears[c.id]==true
end
function Log.main(s) return s.main<Content.mainCount and Content.mainChapters[s.main+1] or nil end
function Log.target(s,c,optionalId)
 if not c then return nil end
 if optionalId then local g=P.goal(c,optionalId);if g and g.optional and P.available(s,c,g) then return {chapter=c,goal=g} end end
 for _,g in ipairs(c.goals) do if P.required(s,g) and P.available(s,c,g) then return {chapter=c,goal=g} end end
end
function Log.reportGuidance(s)
 if s.main~=6 or not s.flags or not s.flags['DW-07:separate'] or s.flags['DW-07:restoration'] then return nil end
 local chapter=Content.byId['DW-07'];local goal=P.goal(chapter,'restoration')
 if P.available(s,chapter,goal) then
  return {objective='Return to Eryn and report your findings.',note='Deepwood is not complete yet. Follow the gold waypoint, use the return portal, or open MAP [M] to travel to Eryn.'}
 end
 return {objective='Eryn is waiting for your final Deepwood report.',note='Return to Lobby and select Deepwood Story 7 in ADVENTURES to finish your report.'}
end
function Log.tracked(s,selectedChapter,selectedGoal)
 local report=Log.reportGuidance(s)
 local final=Content.byId['DW-07']
 if report and P.available(s,final,P.goal(final,'restoration')) then return {chapter=final,goal=P.goal(final,'restoration')} end
 local c=selectedChapter and Content.byId[selectedChapter]
 local admitted=s.expeditionMission and Content.byId[s.expeditionMission]
 local main=Log.main(s)
 if c and c==main and admitted and admitted.side then
  return {chapter=main,goal=main.goals[1],lobby=true}
 end
 if c and c.side and P.canAccept(s,c) and c.quest.offerPosition then return {chapter=c,goal=c.goals[1],offer=true} end
 if c and c.side and not s.clears[c.id] then local target=Log.target(s,c);if target then return target end end
 -- An isolated optional expedition cannot expose a main-story objective.
 if admitted and admitted.side then return Log.target(s,admitted) end
 return admitted and not admitted.side and Log.target(s,admitted)or Log.target(s,main,main and selectedChapter==main.id and selectedGoal or nil)
end
function Log.tracker(s,target)
 local main=Log.main(s)
 local admitted=s.expeditionMission and Content.byId[s.expeditionMission]
 local chapter=target and target.chapter or admitted or main or Content.mainChapters[Content.mainCount]
 local data={region=Content.epics[chapter.epic or 1].region,note='[J] QUEST'}
 if target and target.lobby then
  data.title='CONTINUE MAIN STORY'
  data.objective='Return to Lobby and select '..Content.epics[chapter.epic or 1].region..' · '..(chapter.quest.title or chapter.title)..' in ADVENTURES.'
  data.note='Side quests are optional. You can return to them later.'
  return data
 end
 local report=Log.reportGuidance(s)
 if report and (not target or target.chapter.id=='DW-07' and target.goal.id=='restoration') then
  data.region=Content.epics[1].region;data.title='MAIN STORY 7 / 7 · REPORT TO ERYN'
  data.objective=report.objective;data.note=report.note
  return data
 end
 if target then
  if chapter.side then data.title=target.offer and 'OPTIONAL REQUEST' or 'SIDE QUEST · '..Log.status(s,chapter)
  else local _,index,total=Log.phase(s,chapter);data.title=string.format('MAIN STORY %d / 7 · PHASE %d / %d',(chapter.number-1)%7+1,index,total) end
 elseif admitted and admitted.side and s.clears[admitted.id] then
  data.title='SIDE QUEST COMPLETE'
  data.objective=main and 'Return to Lobby and select '..Content.epics[main.epic or 1].region..' · '..(main.quest.title or main.title)..' in ADVENTURES.'
   or 'Return to Lobby to choose another adventure.'
  data.note='Open the map menu to return to the lobby.'
 elseif main then
  local nextName=Content.epics[main.epic or 1].region..' · '..(main.quest.title or main.title)
  data.title='CONTINUE YOUR JOURNEY'
  data.objective='Return to Lobby and select '..nextName..' in ADVENTURES.'
  data.note='Open the map menu to return to the lobby.'
 else
  data.title='EPIC '..#Content.epics..' COMPLETE'
  data.objective='Explore optional requests or return to the lobby.'
 end
 return data
end
function Log.status(s,c)
 if s.clears[c.id] then return 'Completed' end
 if not c.side then return P.eligible(s,c)and 'In progress'or 'Locked' end
 if not Content.accessible(s,c.minMain,c.legacyMinMain)then return 'Locked' end
 if not P.accepted(s,c) then return 'Available' end
 local report=P.goal(c,c.quest.turnIn)
 local ready=true;for _,g in ipairs(c.goals) do if P.required(s,g) and g~=report and not s.flags[c.id..':'..g.id] then ready=false end end
 if ready and not Content.accessible(s,report.minMain or 0,report.legacyMinMain)then return 'Waiting for story '..report.minMain end
 return P.available(s,c,report) and 'Ready to report' or 'In progress'
end
function Log.phase(s,c)
 if c.side then return Log.status(s,c) end
 for i,phase in ipairs(c.quest.phases) do
  for _,id in ipairs(phase.goals) do if P.required(s,P.goal(c,id)) and not s.flags[c.id..':'..id] then return phase.title,i,#c.quest.phases end end
 end
 return 'Completed',#c.quest.phases,#c.quest.phases
end
function Log.reward(c)
 if c.reward.xp==0 and c.reward.coins==0 then return 'No fixed XP or Gold. Combat rewards are earned separately.' end
 local materials={}
 if c.reward.ore then table.insert(materials,string.format('%d Iron Ore',c.reward.ore))end
 if c.reward.gems then table.insert(materials,string.format('%d Enhancement Gem(s)',c.reward.gems))end
 return string.format('On quest completion: %d XP · %d Gold%s. Items go to your bag or unclaimed rewards.',c.reward.xp,c.reward.coins,#materials>0 and ' · '..table.concat(materials,' · ')or '')
end
function Log.choices(s,c)
 local rows={}
 for _,g in ipairs(c.goals) do for _,step in ipairs(g.activity and g.activity.steps or {}) do
  local picked=(s.decisions or {})[c.id..':'..g.id..':'..step.id]
  for _,answer in ipairs(step.choices or {}) do if answer.id==picked then table.insert(rows,answer.title) end end
 end end
 if c.id=='DW-07' and s.choice~='' then table.insert(rows,s.choice=='sanctuary' and 'Help the forest camp first' or 'Deliver village supplies first') end
 return rows
end
return Log
