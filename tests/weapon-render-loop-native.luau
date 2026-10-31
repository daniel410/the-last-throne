-- Exercise start() callbacks, which direct pose sampling does not cover.
local parent=game.StarterPlayer.StarterPlayerScripts.Client
local copy=parent.K0SwordVisual:Clone();copy.Name='WeaponFrameLoopQA'
local source=copy.Source
local count
source,count=source:gsub('local RunService = game:GetService%("RunService"%)',[[local qaFrames,qaConnections={},0
local RunService={PreSimulation={Connect=function(_,fn)qaFrames.pre=fn;qaConnections+=1 end},RenderStepped={Connect=function(_,fn)qaFrames.render=fn;qaConnections+=1 end}}]])
assert(count==1)
source,count=source:gsub('\nreturn Visual%s*$',[[
function Visual.qaStep(dt)qaFrames.pre(dt);qaFrames.render(dt);return qaConnections end
return Visual]])
assert(count==1);copy.Source=source;copy.Parent=parent
local checks=0
local ok,err=xpcall(function()
 local visual=require(copy);visual.start();visual.start()
 for _=1,3 do assert(visual.qaStep(1/60)==2,'start binds exactly one frame loop');checks+=1 end
end,debug.traceback)
copy:Destroy()
print('WEAPON_RENDER_LOOP_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,error=ok and '' or tostring(err),coverage='Production start PreSimulation/RenderStepped callbacks in native engine with controlled frame signals'}))
assert(ok,err)
