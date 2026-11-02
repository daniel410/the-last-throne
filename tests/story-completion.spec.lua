local M=dofile('src/shared/StoryCompletion.luau')
local C=dofile('src/shared/CampaignContent.luau');local P=dofile('src/shared/DeepwoodProgress.luau')
local count=0;local function check(v,m)count=count+1;assert(v,m)end
for i,c in ipairs(C.mainChapters)do
 local s=P.new();s.main=i;s.clears[c.id]=true
 local value={heroId='hero',journal=s,completion={id=c.id,title=c.quest.title,xp=123,coins=45,outcome=c.quest.outcome}}
 local before={heroId='hero',supporter={pass={story=i,active=true}}}
 local a=M.project(value,before)
 check(a and a.title==c.quest.title and a.reward:find('123',1,true)and a.reward:find('45',1,true),'use confirmed title/reward')
 check(a.heading==(i%7==0 and M.text.epic or M.text.story),'epic boundaries get a distinct completion heading')
 check(a.support==M.text.support,'end active Selene story support explicitly')
 if i<C.mainCount then
  local next=C.mainChapters[i+1]
  check(a.nextId==next.id and a.nextTitle:find(next.quest.title,1,true),'next story follows saved main progress')
  check(a.objective~='' and a.region:find(C.epics[next.epic or 1].region,1,true),'next objective and destination are concrete')
  if i%7==0 then check(a.guidance:find(C.epics[next.epic or 1].region,1,true),'region handoff names the next region')end
 else check(a.nextId==nil and a.guidance==M.text.endBody and a.action==M.text.review,'final implemented story does not promise an unavailable next epic')end
 check(s.main==i and s.clears[c.id],'projection never changes saved progress')
 value.expedition={completed=true,runId='run1'}
 local run=M.project(value,before)
 if i<C.mainCount then check(run.nextId==nil and run.guidance:find('Return to Lobby',1,true),'completed mission explains map entry rather than tracking a locked mission')end
 value.expedition.runId='run2';check(M.project(value).key~=run.key,'new repeated mission gets its own presentation key')
 check(not M.project(value,{heroId='other',supporter=before.supporter}).support,'another hero cannot trigger a false supporter expiry')
 value.training=true;check(M.project(value)==nil,'training cannot show story completion')
end
local c;for _,v in ipairs(C.chapters)do if v.side then c=v;break end end
local s=P.new();s.main=4;s.clears[c.id]=true
local value={heroId='hero',journal=s,completion={id=c.id,xp=0,coins=0}}
local a=M.project(value,{heroId='hero',supporter={pass={story=4,active=true}}})
check(a.heading==M.text.side and not a.support and a.nextId==C.mainChapters[5].id,'side quest preserves main guidance and paid story support')
value.completion.kind='Accepted';check(M.project(value)==nil,'acceptance is not completion')
value.completion.kind=nil;s.clears[c.id]=nil;check(M.project(value)==nil,'unconfirmed clear cannot display success')
check(M.project({journal=s})==nil,'ordinary snapshots do not replay completion')
print('Story completion: '..count..' checks passed')
