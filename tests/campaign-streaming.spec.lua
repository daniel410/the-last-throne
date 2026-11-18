-- Real approach policy, deterministic task scheduling; no live data writes.
local C=dofile('src/shared/CampaignContent.luau')
local A=dofile('src/shared/CampaignAccess.luau')
local B=dofile('src/shared/CampaignBounds.luau')
local count=0
local function check(v,m)count=count+1;assert(v,m)end
local queued,clock={},10
local env=setmetatable({game={GetService=function()return {Shared={CampaignContent=C,CampaignAccess=A,CampaignBounds=B}}end},
 require=function(x)return x end,workspace={StreamingTargetRadius=384},
 task={spawn=function(fn)queued[#queued+1]=fn end},os={clock=function()return clock end},warn=function()end},{__index=_G})
local Streaming=assert(loadfile('src/server/Story/CampaignStreaming.luau','t',env))()
local function point(a)return {X=a[1],Y=a[2]+4,Z=a[3]}end
for _,edge in ipairs(C.overlandLinks)do for side=1,2 do
 queued={}
 local source,target=edge[side],edge[3-side]
 local epic=C.zones[target].epic
 local w={loadedEpics={[C.zones[source].epic]=true}}
 local calls=0
 local player,hero={Character={}},{heroId='qa'}
 local update=Streaming.create({world=w,prepareStory=function(id)calls=calls+1;check(id==target,'correct adjacent chapter');w.loadedEpics[epic]=true end})
 local a,b=B.ends(edge);local mouth=side==1 and a or b
 local center=C.zones[source].center
 local dx,dz=center[1]-mouth[1],center[3]-mouth[3];local length=math.sqrt(dx*dx+dz*dz)
 mouth={mouth[1]+dx/length*100,mouth[2],mouth[3]+dz/length*100}
 local journal={main=35,flags={},clears={}}
 update(player,hero,journal,{X=1e6,Y=4,Z=1e6});check(#queued==0,'distant player does not construct regions')
 update(player,hero,{main=0,flags={},clears={}},point(mouth));check(#queued==0,'locked progression does not request regions')
 local start={X=mouth[1]+dx/length*50,Y=4,Z=mouth[3]+dz/length*50}
 update(player,hero,journal,start);update(player,hero,journal,start);check(#queued==0,'stationary or departing player does not preload')
 update(player,hero,journal,point(mouth));check(#queued==1,'unlocked approach schedules adjacent epic')
 for i=1,4 do update(player,hero,journal,point(mouth))end
 check(#queued==1 and calls==0,'pending requests deduplicated before yielding work')
 queued[1]();check(calls==1 and w.loadedEpics[epic],'region becomes reusable')
 update(player,hero,journal,point(mouth));check(#queued==1,'loaded region never rebuilt')
end end
queued={}
local edge=C.overlandLinks[4];local _,mouth=B.ends(edge)
local attempts=0
local player,hero={Character={}},{heroId='qa'}
local update=Streaming.create({world={loadedEpics={[5]=true}},prepareStory=function()attempts=attempts+1;error('injected')end})
local journal={main=35,flags={},clears={}}
local center=C.zones[edge[2]].center
local dx,dz=center[1]-mouth[1],center[3]-mouth[3];local length=math.sqrt(dx*dx+dz*dz)
local start={X=mouth[1]+dx/length*50,Y=4,Z=mouth[3]+dz/length*50}
update(player,hero,journal,start);update(player,hero,journal,point(mouth));check(#queued==1,'failure attempt scheduled');queued[1]()
update(player,hero,journal,start);update(player,hero,journal,point(mouth));check(#queued==1,'failed preparation is throttled')
clock=16;update(player,hero,journal,start);update(player,hero,journal,point(mouth));check(#queued==2 and attempts==1,'bounded retry after failure')
print('campaign-streaming: '..count..' checks PASS')
