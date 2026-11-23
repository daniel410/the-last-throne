-- Execute the production request/render closures with a deterministic scheduler.
local f=assert(io.open('src/client/ExpeditionView.luau'));local source=f:read('*a');f:close()
local first=assert(source:find(' local function recover',1,true))
local last=assert(source:find(' local function button',first,true))
local renderFirst=assert(source:find(' render=function(s,message)',1,true))
local renderLast=assert(source:find(" panel:GetPropertyChangedSignal('Visible')",renderFirst,true))
local code='local current,pending,latestRequestId,feedback;local render\n'..source:sub(first,last-1)..source:sub(renderFirst,renderLast-1)..'\nreturn {request=request,render=render,pending=function()return pending end}'
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function fixture()
 local now,seq=0,0;local jobs,sent,drawn,spawned={},{},{},{}
 local panel={Parent=true};local scroll={CanvasPosition=0}
 local env=setmetatable({panel=panel,scroll=scroll,createPassword={Text=''},
  game={GetService=function()return {GenerateGUID=function()seq=seq+1;return 'request'..seq end}end},
  task={delay=function(t,fn)table.insert(jobs,{at=now+t,fn=fn})end,spawn=function(fn)table.insert(spawned,fn)end},
  Text={Applying='applying',Refreshing='refreshing'},Starting={setPending=function()end},
  draw=function(m)table.insert(drawn,m or '')end,send=function(c)table.insert(sent,c)end},{__index=_G})
 local view=assert(load(code,'expedition requests','t',env))()
 local function tick(t)
  now=now+t
  local due={};for i=#jobs,1,-1 do if jobs[i].at<=now then table.insert(due,table.remove(jobs,i))end end
  for _,job in ipairs(due)do job.fn()end
 end
 return view,sent,drawn,tick,panel,spawned
end
for _,action in ipairs({'Ready','Launch','Create','Join','KickMember','SetPassword'})do
 local v,sent,drawn,tick,panel,spawned=fixture()
 local command={action=action,target=3};v.request(command)
 local id=command.requestId
 v.render({ackOnly=true,requestId=id,error='Busy',retryAfter=.4})
 v.render({ackOnly=true,requestId=id,error='Busy',retryAfter=.4})
 v.render({party={}}) -- An unrelated periodic snapshot cannot acknowledge Launch.
 check(v.pending()~=nil,'periodic state retains pending '..action)
 tick(.39);check(#sent==1,'cooldown respected '..action)
 tick(.02);check(#sent==2 and sent[2]==command and sent[2].requestId==id,'exact rejected command retried once '..action)
 check(#spawned==0,'Busy does not enter status-only recovery '..action)
 v.render({requestId=id,travelling=action=='Launch'})
 tick(9);check(not v.pending()and #sent==2 and #spawned==0,'acknowledgement stops retry and recovery '..action)
end
do
 local v,sent,drawn,tick=fixture();v.request({action='Launch'});local id=sent[1].requestId
 v.render({ackOnly=true,requestId=id,retryAfter=.4});v.render({requestId=id},'Party cannot enter.')
 tick(.5);check(#sent==1,'late scheduled retry canceled by actual response')
 v.render({});check(drawn[#drawn]=='Party cannot enter.','background snapshot preserves departure error')
 v.request({action='GetState'});v.render({requestId=sent[2].requestId})
 check(drawn[#drawn]=='','explicit successful refresh clears prior error')
 v.render({ackOnly=true,requestId=id});tick(.5);check(#sent==2,'stale Busy cannot retry prior Launch')
end
do
 local v,sent,_,tick,panel=fixture();v.request({action='Launch'})
 v.render({ackOnly=true,requestId=sent[1].requestId});panel.Parent=nil;tick(.5)
 check(#sent==1,'destroyed view cannot retry')
end
do
 local v,sent,_,tick,_,spawned=fixture();v.request({action='Launch'});tick(8)
 check(#spawned==1 and #sent==1,'unknown execution result only polls; never resends Launch')
end
do
 local file=assert(io.open('src/server/Network/ExpeditionService.luau'));local server=file:read('*a');file:close()
 local a=assert(server:find('local function handle(p,c,...)',1,true))
 local b=assert(server:find(" if c.action=='Solo'",a,true))
 local now=0;local ack,executed,published={},{},{}
 local env=setmetatable({last={},lastRead={},os={clock=function()return now end},
  remote={FireClient=function(_,p,s)table.insert(ack,s)end},
  publish=function(p,e,id)table.insert(published,id)end,
  dispatch=function(p,c)table.insert(executed,c.action)end},{__index=_G})
 local handle=assert(load(server:sub(a,b-1)..' dispatch(p,c) end\nreturn handle','server request gate','t',env))()
 local p={};handle(p,{action='Ready',requestId='ready'})
 now=.1;handle(p,{action='GetState',requestId='poll'})
 now=.2;handle(p,{action='Launch',requestId='launch'})
 check(#executed==1 and ack[1].ackOnly and ack[1].requestId=='launch','fast Ready then Launch produces retryable pre-execution rejection')
 now=.61;handle(p,{action='Launch',requestId='launch'})
 check(#executed==2 and executed[2]=='Launch','same Launch dispatches after cooldown')
 now=1;handle(p,{action='GetState',requestId='poll2'})
 now=1.01;handle(p,{action='Launch',requestId='launch2'})
 check(#executed==3 and executed[3]=='Launch','poll immediately before Launch cannot suppress action')
 now=1.02;handle(p,{action='GetState',requestId='poll3'})
 check(#published==2 and published[1]=='poll' and published[2]=='poll2','poll requests keep their own throttle and response IDs')
end
print('Expedition request: '..checks..' checks passed')
