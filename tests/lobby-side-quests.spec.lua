-- Player outcomes: eligibility, discovery, personal markers, report receipts and recovery.
local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local S=dofile('src/shared/LobbySideQuests.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end;for k,v in pairs(a)do if not equal(v,b[k])then return false end end;for k in pairs(b)do if a[k]==nil then return false end end;return true end
local function snap(p,id,ready)return {ready=ready~=false,heroId=id or 'hero',heroes=p.heroes}end
local p=assert(R.addHero(R.new(928),'hero','knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
local original=R.copy(p)
check(S.project(snap(p)).symbol=='','new hero has no false requests')
local prefixes={[0]=R.copy(p)}
for _,c in ipairs(C.mainChapters)do
 for _,g in ipairs(c.goals)do if not g.optional then for _,s in ipairs(g.activity and g.activity.steps or {false})do
  p=assert(R.story(p,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',Items,s and s.id or nil))
 end end end
 prefixes[c.number]=R.copy(p)
end
local function field(p,c,run,mode,version)
 if run then p=assert(A.begin(p,'hero',c.id,mode or 'Easy',run,p.revision,R,Items,version))else p=assert(R.acceptQuest(p,'hero',c.id,c.quest.discoveryOnly==true))end
 for _,g in ipairs(c.goals)do if not g.optional and g.id~=c.quest.turnIn then
  for _,s in ipairs(g.activity and g.activity.steps or {false})do
   local choice=s and s.choices and s.choices[1].id or g.choice and 'shared'
   if run then p=assert(A.event(p,'hero',c.id,g.id,choice,s and s.id or nil,R,Items,run))else p=assert(R.story(p,'hero',c.id,g.id,choice,Items,s and s.id or nil))end
  end
 end end
 return p
end
local total=0
check(S.command({action='Report',heroId='hero',questId='DW-Q1',runId='run',requestId='req'}),'valid report command')
for _,cmd in ipairs({{action='Report',heroId='hero',questId='DW-01',runId='run',requestId='req'},{action='Report',heroId='hero',questId='DW-Q1',runId={},requestId='req'},{action='Report',heroId='hero',questId='DW-Q1',runId='run',requestId='req',gold=999},{action='Notice',heroId='hero',questId='DW-Q1',noticeState=2,noticeKey={},requestId='req'}})do check(not S.command(cmd),'reject malformed/forged command')end
for _,c in ipairs(C.chapters)do if c.side then
 total=total+1;local base=prefixes[D.requiredMain(c)];local state=S.project(snap(base))
 local found;for _,row in ipairs(state.rows)do if row.id==c.id then found=row end end
 check(found and found.phase=='available','eligible request offered '..c.id)
 check(not P.accepted(base.heroes.hero.deepwood,c),'view does not accept '..c.id)
 if D.requiredMain(c)>0 then local locked=S.project(snap(prefixes[D.requiredMain(c)-1]));local absent=true;for _,row in ipairs(locked.rows)do if row.id==c.id then absent=false end end;check(absent,'no premature unlock '..c.id)end
 for _,run in ipairs({false,'guide-'..c.id})do
  local before=R.copy(base)
  local blocked,why=S.apply(before,{action='Report',heroId='hero',questId=c.id,runId=run or 'campaign'},R,Items)
  check(not blocked,'no unearned report '..c.id)
  local ready=field(before,c,run)
  local h=ready.heroes.hero;local current=S.project(snap(ready))
  check(current.symbol=='?'and current.recommended.id==c.id,'ready marker and priority '..c.id)
  local cmd={action='Report',heroId='hero',questId=c.id,runId=run or 'campaign'}
  local done=assert(S.apply(ready,cmd,R,Items));check(R.validate(done,Items),'valid account '..c.id)
  local expected=run and assert(A.event(ready,'hero',c.id,c.quest.turnIn,nil,nil,R,Items,run))or assert(R.story(ready,'hero',c.id,c.quest.turnIn,nil,Items))
  check(equal(done,expected),'same report and rewards as field '..c.id)
  check(S.settled(snap(done),cmd),'committed snapshot settles lost report response '..c.id)
  check(not S.settled(snap(ready),cmd),'unfinished report cannot settle '..c.id)
  check(equal(assert(S.apply(done,cmd,R,Items)),done),'retry cannot double pay '..c.id)
  check(done.heroes.hero.deepwood.clears[c.id],'durable completion '..c.id)
  check(done.heroes.hero.deepwood.main==ready.heroes.hero.deepwood.main,'main continuation preserved '..c.id)
  local after=S.project(snap(done));for _,row in ipairs(after.rows)do check(row.id~=c.id,'completed disappears '..c.id)end
  if run then
   check(done.heroes.hero.expeditions.active.completed,'run settled '..c.id)
   local replay=assert(A.begin(done,'hero',c.id,'Easy',run..'-repeat',done.revision,R,Items))
   replay=field(replay,c,run..'-repeat')
   local repeatCmd={action='Report',heroId='hero',questId=c.id,runId=run..'-repeat'}
   local repeatDone=assert(S.apply(replay,repeatCmd,R,Items))
   local repeatExpected=assert(A.event(replay,'hero',c.id,c.quest.turnIn,nil,nil,R,Items,run..'-repeat'))
   check(equal(repeatDone,repeatExpected),'repeat uses pinned rewards '..c.id)
   check(not S.apply(replay,cmd,R,Items),'stale run cannot report new attempt '..c.id)
   if D.combat(c)then
    local higher=done
    for _,mode in ipairs({'Hard','Insane','Hell'})do
     local highRun=run..'-'..mode
     local work=field(higher,c,highRun,mode,1)
     local highState=S.project(snap(work));check(highState.recommended.difficultyId==mode,'retain active difficulty '..mode)
     local highCommand={action='Report',heroId='hero',questId=c.id,runId=highRun}
     higher=assert(S.apply(work,highCommand,R,Items))
     local expectedHigh=assert(A.event(work,'hero',c.id,c.quest.turnIn,nil,nil,R,Items,highRun))
     check(equal(higher,expectedHigh),'pinned legacy mode rewards '..c.id..mode)
     check(equal(assert(S.apply(higher,highCommand,R,Items)),higher),'higher mode duplicate safe '..mode)
    end
   end
  end
 end
end end
check(total==12,'all report adapters covered')
local state=S.project(snap(p));check(state.symbol=='!'and state.count==12,'all available requests count')
local notice={action='Notice',heroId='hero',questId=state.notice.id,noticeState=state.notice.noticeState,noticeKey=state.noticeKey}
local ack=assert(S.apply(p,notice,R,Items));check(S.project(snap(ack)).notice==nil,'group notice is durably acknowledged')
check(S.settled(snap(ack),notice),'snapshot settles lost notice response')
check(not S.settled(snap(p),notice),'uncommitted notice remains pending')
check(S.project(snap(ack)).symbol=='!','reading does not hide available marker')
check(equal(assert(S.apply(ack,notice,R,Items)),ack),'ack idempotent across reconnect')
check(equal(assert(S.apply(p,{action='Notice',heroId='hero',questId=state.notice.id,noticeState=1,noticeKey='stale'},R,Items)),p),'stale notice cannot dismiss new group')
local ready=field(ack,C.byId['DW-Q1'],false)
check(S.project(snap(ready)).notice.noticeState==2,'ready state alerts after available was read')
check(S.project(snap(p,nil,false)).symbol=='','failed load hides markers')
check(S.project({ready=true,heroes={}}).symbol=='','no selected hero hides markers')
local two=assert(R.addHero(p,'elf','elf',Items));two.heroes.elf.level=80;two.heroes.elf.progression=G.new(80)
check(#S.project(snap(two,'elf')).rows==0,'other hero never copies progress')
local bad=R.copy(p);bad.heroes.hero.sideQuestNotices={['DW-01']=1};check(not R.validate(bad,Items),'notice schema rejects main/unknown IDs')
-- UpdateAsync callback replay and a committed write whose response was lost.
local saved,lose=R.copy(ready),false
saved.lease=nil
local adapter={UpdateAsync=function(_,key,fn)local first=fn(R.copy(saved));local second=fn(R.copy(saved));check(equal(first,second),'callback replay deterministic');saved=second or saved;if lose then error('lost response')end;return R.copy(saved)end}
local now=1000;local store=Store.new(adapter,R,Items,function()return now end,function()end,'guide-test')
check(store:open(928)~=nil,'store opened')
local cmd={action='Report',heroId='hero',questId='DW-Q1',runId='campaign'}
lose=true;local failed,why=store:transact(928,function(current)return S.apply(current,cmd,R,Items)end)
check(failed==nil and why=='SaveUnknown','unknown response remains unknown')
local committed=R.copy(saved);lose=false
local recovered=assert(store:transact(928,function(current)return S.apply(current,cmd,R,Items)end))
check(recovered.wallet.gold==committed.wallet.gold and equal(recovered.items,committed.items),'recovery cannot duplicate rewards')
check(recovered.heroes.hero.deepwood.clears['DW-Q1'],'recovery keeps completion')
check(original.heroes.hero.deepwood==nil or equal(original.heroes.hero.deepwood,P.new()),'fixture initial state unchanged')
print('LOBBY_SIDE_QUESTS '..n..' checks passed')
