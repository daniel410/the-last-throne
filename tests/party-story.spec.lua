local Party=dofile('src/server/Story/PartyStory.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local players={1,2,3,4,5};local journals,runs,events={},{},{}
for _,p in ipairs(players)do journals[p]=P.new();runs[p]={runId=p==5 and 'other' or 'party'}end
local fail=false
local reads=0
local party=Party.create({players=function()return players end,active=function(p)return {heroId=tostring(p)}end,
 run=function(p)return runs[p]end,state=function(p)reads=reads+1;return journals[p]end,available=P.available,canAccept=P.canAccept,collected=P.collected,
 enqueue=function(p,h,c,g,choice,step)
  if p==2 and fail then return end
  local nextState,err=P.apply(journals[p],c.id,g.id,choice,step);assert(nextState,err)
  journals[p]=nextState;events[p]=(events[p]or 0)+1
 end})
local c=C.byId['DW-01']
for _,g in ipairs(c.goals)do if not g.optional then
 local steps=g.activity and g.activity.steps
 if steps then for _,step in ipairs(steps)do
  party.enqueue(1,'1',c,g,step.choices and step.choices[1].id,step.id)
  local before=events[1];party.replay();check(events[1]==before,'saved substep is not queued again while later steps are pending')
 end
 else party.enqueue(1,'1',c,g)end
end end
for p=1,4 do check(journals[p].clears[c.id],'one player completes entire story for all four members')end
check(not journals[5].clears[c.id] and not next(journals[5].flags),'other run never receives progress')
local paid=events[1];party.replay();check(events[1]==paid,'replay never repeats completed steps or rewards')
reads=0;party.replay();check(reads==0,'confirmed logs require no further journal snapshots')
party.remove(2);journals[2]=P.new();fail=true;party.replay();check(journals[2].main==0,'failed save stays pending')
fail=false
for _=1,50 do
 reads=0;party.replay()
 check(reads<=1,'catch-up reads at most one journal per pending member and tick')
 if journals[2].clears[c.id] then break end
end
check(journals[2].clears[c.id],'late/rejoined member catches up in event order')
runs[2]={runId='different'};journals[2]=P.new();party.replay();check(journals[2].main==0,'changed run cannot consume old events')
-- A completed 100-event history takes one initial snapshot per member and none on idle ticks.
local roster={}
local saved=P.new()
local snapshots=0
local archived=Party.create({players=function()return roster end,active=function()return {heroId='hero'}end,
 run=function()return {runId='history'}end,state=function()snapshots=snapshots+1;return saved end,
 enqueue=function()error('saved event enqueued twice')end})
for i=1,100 do
 local goal={id='step'..i}
 saved.flags[c.id..':'..goal.id]=true
 archived.enqueue(1,'hero',c,goal)
end
roster={1,2,3,4};archived.replay();check(snapshots==4,'four players and 100 saved events project four journals')
archived.replay();check(snapshots==4,'idle 100-event history projects no journals')
for _,chapter in ipairs(C.chapters)do for _,g in ipairs(chapter.goals)do
 local previous=0
 for size=1,4 do
  local waves=B.encounterWaves(chapter,g,size);local total,xp,gold,bosses=0,0,0,0
  for n,batch in ipairs(waves)do
   check(#batch<=B.packCapacity(chapter,g,size),'bounded live population')
   for _,spec in ipairs(batch)do
    if B.isBoss(spec.kind)then bosses=bosses+1;check(n==#waves and #batch>1,'boss joins guards in final spawn')end
    local x,y=B.rewards(spec,'Easy',2);xp=xp+x;gold=gold+y;total=total+1
   end
  end
  if size==1 then g._soloXP=xp;g._soloGold=gold end
  check(xp==g._soloXP and gold==g._soloGold,'larger party preserves personal kill reward budget')
  check(total>=previous,'party population increases monotonically');previous=total
  if bosses>0 then check(bosses==1,'one unique boss per encounter')end
 end
end end
print('Party story and final boss: '..checks..' checks passed')
