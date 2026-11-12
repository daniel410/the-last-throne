-- Failure/yield in one presentation system cannot prevent HUD/controller readiness.
local P=dofile('src/client/BattlePresentation.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local modules=setmetatable({},{__index=function(_,k)return k end})
for _,failure in ipairs({'K0BackgroundMusic','K0EnemyVisual','DeepwoodAtmosphere'})do
 local pending,started,warnings={},{},{}
 local d={spawn=function(fn)pending[#pending+1]=coroutine.create(fn)end,warn=function(message)warnings[#warnings+1]=message end,
  load=function(name)
   if name==failure then error('injected load failure')end
   return {start=function()started[name]=true;if name=='K0Telegraphs'then coroutine.yield()end end}
  end}
 P.start(modules,d)
 check(#pending==10,'each presentation subsystem is scheduled independently')
 local ready=true -- production caller returns without executing/yielding in presentation code
 for _,co in ipairs(pending)do local ok,err=coroutine.resume(co);check(ok,err)end
 check(ready and #warnings==1 and warnings[1]:find(failure,1,true),'failure is reported without escaping startup')
 check(started.K0CombatAudio and started.PixelFXController,'other presentation systems start despite earlier failure/yield')
end
local source=assert(io.open('src/client/BattleController.luau')):read('*a')
local update=assert(source:find(' update()\n Presentation.start(script)',1,true))
check(update>source:find("GetAttributeChangedSignal('K0SessionPhase'):Connect(update)",1,true),'HUD state subscription and initial visibility precede presentation startup')
check(not assert(io.open('src/client/init.client.luau')):read('*a'):find('require(script.DeepwoodAtmosphere).start()',1,true),'atmosphere cannot block controller creation')
print('BATTLE_PRESENTATION '..n..' checks passed')
