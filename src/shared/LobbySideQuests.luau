-- Read-only projections and bounded account mutations. No client completion claims.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local Content,P,Log,D,Text=load('CampaignContent'),load('DeepwoodProgress'),load('DeepwoodQuestLog'),load('Difficulty'),load('LobbySideQuestText')
local S={reports={['DW-Q1']='marsh_report',['DW-Q2']='food_report',['DW-Q3']='quarry_report',['DW-Q4']='battlefield_report',
 ['FV-Q1']='report',['FV-Q2']='report',['FV-Q3']='report',['FV-Q4']='report',['EC-Q1']='report',['EC-Q2']='report',['EC-Q3']='report',['EC-Q4']='report'}}
function S.command(c)
 if type(c)~='table'then return false end
 for k in pairs(c)do if k~='action'and k~='heroId'and k~='questId'and k~='runId'and k~='noticeState'and k~='requestId'and k~='noticeKey'then return false end end
 local function id(v)return type(v)=='string'and #v>0 and #v<=64 and v:match('^[%w_-]+$')~=nil end
 if not id(c.requestId)or not id(c.heroId)or not S.reports[c.questId]then return false end
 if c.action=='Notice'then return c.runId==nil and type(c.noticeKey)=='string'and #c.noticeKey<=256 and (c.noticeState==1 or c.noticeState==2)end
 return c.action=='Report'and c.noticeState==nil and c.noticeKey==nil and id(c.runId)
end
function S.validNotices(hero)
 if hero.sideQuestNotices==nil then return true end
 if type(hero.sideQuestNotices)~='table'then return false end
 for id,state in pairs(hero.sideQuestNotices)do if not S.reports[id]or state~=1 and state~=2 then return false end end
 return true
end
local function journal(hero,c)
 local a=hero.expeditions and hero.expeditions.active
 if a and a.missionId==c.id and not a.completed then return a.journal,a.runId,a end
 return hero.deepwood,nil
end
function S.project(snapshot)
 local out={rows={},symbol='',count=0,label=Text.loading}
 local hero=snapshot and snapshot.ready and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
 if not hero or not hero.deepwood then return out end
 out.heroId=snapshot.heroId;out.loaded=true;out.label=Text.empty
 local latest=0
 for _,c in ipairs(Content.mainChapters)do if hero.deepwood.clears[c.id]then latest=math.max(latest,c.epic)end end
 for _,c in ipairs(Content.chapters)do if c.side then
  local j,runId,active=journal(hero,c)
  local replay=runId~=nil
  if j and not j.clears[c.id]and Content.accessible(hero.deepwood,c.minMain,c.legacyMinMain)and D.allowed(hero,c.id,'Easy')then
   local status=Log.status(j,c)
   local report=P.goal(c,c.quest.turnIn)
   local canReport=S.reports[c.id]==c.quest.turnIn and report and not report.activity and not report.choice and not report.optional and status=='Ready to report'
   local accepted=P.accepted(j,c)
   local phase=canReport and 'report'or accepted and 'progress'or 'available'
   local region=Content.epics[c.epic].region
   local hint=canReport and Text.reportHint or status=='Ready to report'and string.format(Text.field,c.quest.giver or 'the quest giver',region)
    or not accepted and c.quest.discoveryOnly and string.format(Text.discovery,region)
    or not accepted and string.format(Text.accept,c.quest.giver or 'the quest giver',region)or string.format(Text.next,region)
   if accepted and not canReport then local target=Log.target(j,c);if target then hint=(target.goal.title or '')..' · '..string.format(Text.next,region)end end
   local reward=Log.reward(c)
   if hero.level>=99 then reward=reward:gsub('^On quest completion: %d+ XP','On quest completion: 0 XP')end
   if active and hero.deepwood.clears[c.id]then local payout=D.completion(c,active.difficultyId,active.balanceVersion or 1);reward=string.format(Text.repeatReward,hero.level>=99 and 0 or payout.xp,payout.gold)end
   local row={id=c.id,title=c.quest.title or c.title,region=region,epic=c.epic,phase=phase,runId=runId or 'campaign',
    difficultyId=active and active.difficultyId or 'Easy',hint=hint,brief=not accepted and c.quest.discoveryOnly and ''or c.quest.brief or '',reward=reward,canReport=canReport,
    action=canReport and Text.report or accepted and Text.continue or c.quest.discoveryOnly and Text.clue or Text.view,
    rank=canReport and 1 or accepted and 2 or c.epic==latest and 3 or 4,
    noticeState=canReport and 2 or 1,replay=replay}
   table.insert(out.rows,row)
  end
 end end
 table.sort(out.rows,function(a,b)if a.rank~=b.rank then return a.rank<b.rank end;if a.epic~=b.epic then return a.epic<b.epic end;return a.id<b.id end)
 out.recommended=out.rows[1]
 local reportCount,availableCount=0,0;local noticeParts={}
 for _,row in ipairs(out.rows)do
  if row.canReport or row.phase=='available'then table.insert(noticeParts,row.id..':'..row.noticeState)end
  if row.canReport then reportCount=reportCount+1 elseif row.phase=='available'then availableCount=availableCount+1 end
  if not out.notice and (row.canReport or row.phase=='available')and ((hero.sideQuestNotices or {})[row.id]or 0)<row.noticeState then out.notice=row end
 end
 out.noticeKey=table.concat(noticeParts,',')
 if reportCount>0 then out.symbol='?';out.count=reportCount;out.label=Text.ready
 elseif availableCount>0 then out.symbol='!';out.count=availableCount;out.label=Text.available
 elseif #out.rows>0 then out.symbol='…';out.count=#out.rows;out.label=Text.progress end
 return out
end
function S.settled(snapshot,command)
 local hero=snapshot and snapshot.ready and snapshot.heroes and snapshot.heroes[command.heroId]
 if not hero then return false end
 if command.action=='Notice'then return ((hero.sideQuestNotices or {})[command.questId]or 0)>=(command.noticeState or 3)end
 local a=hero.expeditions and hero.expeditions.active
 if command.runId=='campaign'then return hero.deepwood and hero.deepwood.clears[command.questId]==true end
 return a~=nil and a.runId==command.runId and a.missionId==command.questId and a.completed==true
end
function S.apply(profile,command,R,C)
 local hero=profile.heroes[command.heroId]
 if not hero then return nil,'NoHero'end
 if command.action=='Notice'then
  local state=S.project({ready=true,heroId=command.heroId,heroes=profile.heroes})
  if not state.notice then return R.copy(profile),nil,true end
  -- Ack exactly what was displayed; never mark a newly unlocked request as read.
  if state.noticeKey~=command.noticeKey or state.notice.id~=command.questId or state.notice.noticeState~=command.noticeState then return R.copy(profile),nil,true end
  local p=R.copy(profile);local h=p.heroes[command.heroId];h.sideQuestNotices=h.sideQuestNotices or {}
  -- One small toast announces this whole currently available group.
  for _,row in ipairs(state.rows)do if row.canReport or row.phase=='available'then h.sideQuestNotices[row.id]=math.max(h.sideQuestNotices[row.id]or 0,row.noticeState)end end
  p.revision=p.revision+1;return p
 end
 if command.action~='Report'or not S.reports[command.questId]then return nil,'InvalidRequest'end
 local c=Content.byId[command.questId];local a=hero.expeditions and hero.expeditions.active
 if command.runId~='campaign'and (not a or a.runId~=command.runId or a.missionId~=c.id)then return nil,'AdventureChanged'end
 if command.runId=='campaign'and a and a.missionId==c.id and not a.completed then return nil,'AdventureChanged'end
 if command.runId~='campaign'and a.completed or command.runId=='campaign'and hero.deepwood.clears[c.id]then return R.copy(profile),nil,true end
 local state=S.project({ready=true,heroId=command.heroId,heroes=profile.heroes});local row
 for _,v in ipairs(state.rows)do if v.id==c.id then row=v;break end end
 if not row or not row.canReport or row.runId~=command.runId then return nil,'StoryLocked'end
 if command.runId=='campaign'then return R.story(profile,command.heroId,c.id,S.reports[c.id],nil,C)end
 return load('AdventureRules').event(profile,command.heroId,c.id,S.reports[c.id],nil,nil,R,C,command.runId)
end
return S
