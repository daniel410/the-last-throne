-- Execute the production sprint lifecycle and priority binding with engine stubs.
local file=assert(io.open('src/client/BattleController.luau'))
local source=file:read('*a');file:close()
local checks=0
local function check(v,label)checks=checks+1;assert(v,label)end
local function section(first,last)
 local a=assert(source:find(first,1,true),first)
 local b=assert(source:find(last,a+1,true),last)
 return source:sub(a,b-1)
end
local lifecycle=section('local function startSprint()', 'local function clearCharacterConnections()')
lifecycle=lifecycle:gsub('([%w_]+) %+= ([^\n]+)','%1 = %1 + %2')
local binding=section('ContextActionService:BindActionAtPriority("K0Sprint"', '-- Keep the standard Space jump')
local Enum={UserInputState={Begin='Begin',End='End',Cancel='Cancel',Change='Change'},
 ContextActionResult={Pass='Pass',Sink='Sink'},ContextActionPriority={High={Value=3000}},
 KeyCode={E='E',ButtonL3='ButtonL3'}}
local allowed=true
local calls,tasks={},{}
local callback
local env=setmetatable({Enum=Enum,heldSprint=false,sprintGeneration=0,
 combatInputAllowed=function()return allowed end,
 sendAction=function(action)table.insert(calls,action)end,
 task={spawn=function(fn)table.insert(tasks,coroutine.create(fn))end,wait=function()coroutine.yield()end},
 ContextActionService={BindActionAtPriority=function(_,name,fn,touch,priority,...)
  check(name=='K0Sprint' and priority==3000,'sprint receives high priority')
  local keys={...};check(not touch and keys[1]=='E' and keys[2]=='ButtonL3' and #keys==2,'only sprint keys are bound; movement and touch remain independent')
  callback=fn
 end}}, {__index=_G})
assert(load(lifecycle..binding,'production sprint','t',env))()
-- A processed keyboard chord reaches the priority action even though the old
-- InputBegan handler would return immediately. Movement keys never enter it.
for _,chord in ipairs({'W+A','W+D','S+A','S+D','Up+Left','Up+Right','Down+Left','Down+Right'})do
 calls={};tasks={};allowed=true
 check(callback('K0Sprint','Begin')=='Sink',chord..' consumes sprint intent')
 check(env.heldSprint and #calls==1 and calls[1]=='SprintStart',chord..' starts sprint')
 callback('K0Sprint','Begin');check(#calls==1 and #tasks==1,'repeated Begin does not create another retry loop')
 local thread=tasks[1];assert(coroutine.resume(thread));assert(coroutine.resume(thread))
 check(#calls==2 and calls[2]=='SprintStart','hold refreshes server sprint lease')
 check(callback('K0Sprint','End')=='Pass','release allows other bindings')
 check(not env.heldSprint and calls[#calls]=='SprintEnd','release stops sprint')
 local count=#calls;assert(coroutine.resume(thread));check(#calls==count,'release cancels old retry loop')
end
for _,reason in ipairs({'menu','chat','inventory','travel','dead','inactive','unfocused'})do
 allowed=false;calls={}
 check(callback('K0Sprint','Begin')=='Pass' and #calls==0 and not env.heldSprint,reason..' blocks start through shared combat gate')
end
allowed=true;calls={};callback('K0Sprint','Begin');allowed=false
callback('K0Sprint','Cancel')
check(not env.heldSprint and calls[#calls]=='SprintEnd','Cancel releases even after combat gate closes')
local count=#calls;callback('K0Sprint','End');check(#calls==count,'duplicate release is harmless')
print('Sprint input: '..checks..' checks passed')
