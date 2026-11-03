-- Read-only presentation of server-confirmed clears. Never awards or advances progress.
local function load(n)return game and require(script.Parent[n]) or dofile('src/shared/'..n..'.luau')end
local Content=load('CampaignContent');local Log=load('DeepwoodQuestLog')
local M={text={story='STORY COMPLETE',side='SIDE QUEST COMPLETE',epic='EPIC COMPLETE',
 reward='+%d XP  ·  +%d Gold',saved='Rewards saved. Check your bag or unclaimed rewards for items.',
 next='NEXT · %s',region='%s · Story %d / 7',objective='First objective: %s',
 route='Follow the gold waypoint to the next objective. Open QUEST [J] to review the steps.',
 travel='Your journey continues in %s. Follow the gold waypoint to the marked objective.',
 mission='Return to Lobby, choose %s on the adventure map, then start that story. Completing this story does not start the next mission automatically.',
 endTitle='THE CROWNHEART IS HOME',endBody='You saved all five regions with your friends! Return to Lobby to restore the Dawnspire throne and celebrate. You can still explore optional quests and replay adventures.',
 support='SELENE SUPPORT ENDED · Invite her at a safe companion camp to use 1 saved story credit. If none remain, buy more from Selene in the lobby. No automatic renewal.',
 follow='TRACK NEXT STORY',review='REVIEW QUESTS',close='CLOSE'}}
function M.project(value,previous)
 local e=value and value.completion;local s=value and value.journal
 local c=e and Content.byId[e.id]
 if not c or e.kind=='Accepted' or not s or not s.clears[c.id] or value.training then return nil end
 local nextChapter=Log.main(s);local nextTarget=nextChapter and Log.target(s,nextChapter)
 local epic=Content.epics[c.epic or 1]
 local data={id=c.id,heroId=value.heroId,key=tostring(value.heroId)..':'..tostring(value.expedition and value.expedition.runId or 'first')..':'..c.id,
  heading=c.side and M.text.side or c.number%7==0 and M.text.epic or M.text.story,
  title=e.title or c.quest.title or c.title,outcome=e.outcome or c.quest.outcome or '',
  reward=string.format(M.text.reward,e.xp or 0,e.coins or 0),saved=M.text.saved,
  nextId=nextChapter and nextChapter.id or nil,action=nextChapter and M.text.follow or M.text.review,
  nextTitle=nextChapter and string.format(M.text.next,nextChapter.quest.title or nextChapter.title)or M.text.endTitle,
  region=nextChapter and string.format(M.text.region,Content.epics[nextChapter.epic or 1].region,(nextChapter.number-1)%7+1)or epic.region,
  objective=nextTarget and string.format(M.text.objective,nextTarget.goal.title)or '',
  guidance=not nextChapter and M.text.endBody or nextChapter.epic~=c.epic and string.format(M.text.travel,Content.epics[nextChapter.epic or 1].region)or M.text.route}
 if value.expedition and value.expedition.completed and nextChapter then
  data.guidance=string.format(M.text.mission,nextChapter.quest.title or nextChapter.title)
  data.action=M.text.review;data.nextId=nil
 end
 local pass=previous and previous.heroId==value.heroId and previous.supporter and previous.supporter.pass
 if not c.side and pass and pass.active and pass.story==c.number then data.support=M.text.support end
 return data
end
return M
