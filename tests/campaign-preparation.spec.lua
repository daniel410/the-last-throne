local C=dofile('src/shared/CampaignContent.luau')
local f=assert(io.open('src/server/init.server.luau'));local s=f:read('*a');f:close()
local a=assert(s:find('local building=false',1,true));local b=assert(s:find('local function trainingDestination',a,true))
local w={loadedEpics={},readyEpics={},folder={SetAttribute=function()end}}
local calls,fail,yielding={},nil,nil
local env=setmetatable({Content=C,script={World={CampaignPreparation=true}},workspace={SetAttribute=function()end},world={enemies={}},
 task={wait=coroutine.yield},story={start=function()end,refreshWorld=function()end},startCombat=function()end,addRegionalStorage=function()end,print=function()end,
 require=function()return {new=function()return w end,prepare=function(id)
  calls[id]=(calls[id]or 0)+1
  if fail==id then error('transient failure')end
  if yielding==id then coroutine.yield()end
  w.loadedEpics[id]=true
 end}end},{__index=_G})
local prepare=assert(load(s:sub(a,b-1)..'\nreturn previewWorld','actual-preview','t',env))()
local n=0;local function check(v,m)n=n+1;assert(v,m)end
prepare('HG-01');check(w.readyEpics[5]and calls[5]==1,'destination ready')
fail=4;check(not pcall(prepare,'EC-01'),'failure reported')
check(pcall(prepare,'HG-01')and calls[5]==1,'failure does not poison existing region')
fail=nil;yielding=4
local first=coroutine.create(function()prepare('EC-01')end);check(coroutine.resume(first),'start retry')
check(pcall(prepare,'HG-01'),'ready epic never waits behind background construction')
local second=coroutine.create(function()prepare('EC-01')end);check(coroutine.resume(second),'duplicate joins wait')
check(coroutine.resume(first)and coroutine.status(first)=='dead','retry finishes')
check(coroutine.resume(second)and coroutine.status(second)=='dead','duplicate reuses result')
check(w.readyEpics[4]and calls[4]==2,'one failed attempt plus one successful retry')
print('campaign-preparation: '..n..' checks PASS')
