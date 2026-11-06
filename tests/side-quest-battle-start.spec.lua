-- Execute the production proximity heartbeat with canonical campaign eligibility.
local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local file=assert(io.open('src/server/Story/DeepwoodService.luau'));local source=file:read('*a');file:close()
local first=assert(source:find(' local activityElapsed=0',1,true))
local last=assert(source:find(' local elapsed=0',first,true))
local body=source:sub(first,last-1):gsub('activityElapsed%+=dt','activityElapsed=activityElapsed+dt')
local n,sideBattles,mainBattles=0,0,0
local function check(v,m)n=n+1;assert(v,m)end
local player={};local journal,hero,ctx,root,run,callback,started
local encounters,nodes={},{}
local env=setmetatable({Content=C,Progress=P,encounters=encounters,
 Players={GetPlayers=function()return {player}end},
 RunService={Heartbeat={Connect=function(_,f)callback=f end}},
 companion={stepMotion=function()end,update=function()end},access={update=function()end},
 partyStory={replay=function()end},activities={update=function()end},
 active=function()return hero end,context=function()return ctx,root end,state=function()return journal end,
 options={world={nodes=nodes},inventory={expedition=function()return run end}},
 begin=function(p,node,automatic)check(p==player and automatic,'server automatic entry');started[#started+1]=node end,
},{__index=_G})
local function reset(c,g)
 journal=P.new();journal.main=c.side and c.minMain or c.number-1;journal.accepted[c.id]=true
 journal.expeditionMission=c.id
 for _,id in ipairs(g.requires)do journal.flags[c.id..':'..id]=true end
 hero={heroId='hero'};ctx={heroId='hero'};run={runId='side-qa'}
 root={Position=setmetatable({},{__sub=function()return {Magnitude=4}end})}
 for k in pairs(nodes)do nodes[k]=nil end;for k in pairs(encounters)do encounters[k]=nil end
 nodes[c.id..':'..g.id]={chapter=c,goal=g,part={Position={}}}
 started={};assert(load(body,'production proximity heartbeat','t',env))()
end
local function tick(expected,message)started={};callback(.2);check(#started==expected,message)end
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
 if g.activity and g.activity.mode=='battle' then
  reset(c,g);tick(1,c.id..':'..g.id..' eligible battle starts at 4 studs')
  if c.side then
   sideBattles=sideBattles+1
   journal.accepted={};journal.flags={};tick(0,'unaccepted quest cannot start')
   reset(c,g);journal.clears[c.id]=true;tick(0,'cleared quest cannot restart')
   reset(c,g);journal.main=c.minMain-1;tick(0,'story gate retained')
  else mainBattles=mainBattles+1 end
  reset(c,g);journal.expeditionMission='different-run';tick(0,'other mission cannot start')
  reset(c,g);journal.flags[c.id..':'..g.id]=true;tick(0,'completed objective cannot restart')
  for _,required in ipairs(g.requires)do
   reset(c,g);journal.flags[c.id..':'..required]=nil;tick(0,'prerequisite retained: '..required)
  end
  reset(c,g);encounters[c.id..':'..g.id..':side-qa']={};tick(0,'existing run encounter is not duplicated')
  reset(c,g);encounters[c.id..':'..g.id..':other-run']={};tick(1,'another run does not block this run')
  reset(c,g);hero.training=true;tick(0,'training cannot start story encounter')
  reset(c,g);ctx=nil;tick(0,'missing or dead combat context cannot start')
  reset(c,g);root.Position=setmetatable({},{__sub=function()return {Magnitude=33}end});tick(0,'outside radius cannot start')
  reset(c,g);callback(.1);check(#started==0,'scan waits for cadence');callback(.1);check(#started==1,'scan resumes at 0.2 seconds')
 end
end end
check(sideBattles>0 and mainBattles>0,'both optional and main campaign paths covered')
print(string.format('Side quest battle entry: %d checks passed (%d side, %d main battle goals)',n,sideBattles,mainBattles))
