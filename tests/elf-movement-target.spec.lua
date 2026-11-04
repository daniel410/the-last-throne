-- Exercise the actual client cancellation function with character/input doubles.
local file=assert(io.open('src/client/BattleController.luau'));local source=file:read('*a');file:close()
local body=assert(source:match('local function clearMovingElfTarget%(%)\n(.-)\nend\n'))
local checks=0
local function check(ok,message) checks=checks+1;assert(ok,message) end
local fixture=assert(load([[
return function(body)
 local selectedEnemy,clears,notices={},0,0
 local humanoid={MoveDirection={Magnitude=0}}
 local character={classId='elf'}
 function character:GetAttribute()return self.classId end
 function character:FindFirstChildOfClass()return humanoid end
 local player={Character=character}
 local function clearTarget() selectedEnemy=nil;clears=clears+1 end
 local Text={TargetCleared='Target cleared.'}
 local hud={showFeedback=function(message)assert(message==Text.TargetCleared);notices=notices+1 end}
 local update=assert(load('return function() '..body..' end','cancel','t',setmetatable({player=player,clearTarget=clearTarget,hud=hud,Text=Text},{__index=function(_,key)if key=='selectedEnemy'then return selectedEnemy end end})))()
 return {update=update,player=player,character=character,humanoid=humanoid,select=function()selectedEnemy={}end,target=function()return selectedEnemy end,counts=function()return clears,notices end}
end
]]))()(body)
local f=fixture
f.update();check(f.target()~=nil,'stationary elf retains selected enemy')
for _,classId in ipairs({'knight','dwarf','mage'})do
 f.character.classId=classId;f.humanoid.MoveDirection.Magnitude=1;f.update()
 check(f.target()~=nil,classId..' keeps target during movement')
end
f.character.classId='elf'
f.humanoid.MoveDirection.Magnitude=0.01;f.update();check(f.target()~=nil,'ignore near-zero input')
f.humanoid.MoveDirection.Magnitude=0.02;f.update();check(f.target()==nil,'analog movement clears elf target')
local clears,notices=f.counts();check(clears==1 and notices==1,'clear highlight/connections and show existing feedback once')
f.update();clears,notices=f.counts();check(clears==1 and notices==1,'held movement does not repeat feedback')
f.select();f.humanoid.MoveDirection.Magnitude=1;f.update();check(f.target()==nil,'selection while already moving is cleared')
f.select();f.humanoid.MoveDirection.Magnitude=0;f.update();check(f.target()~=nil,'can reselect after stopping')
f.player.Character=nil;f.update();check(f.target()~=nil,'character removal race is safe')
f.player.Character=f.character
f.character.FindFirstChildOfClass=function()return nil end;f.update();check(f.target()~=nil,'missing humanoid is safe')
check(source:find('GetPropertyChangedSignal("MoveDirection"):Connect(clearMovingElfTarget)',1,true)~=nil,'all movement devices use humanoid intent signal')
check(source:find('local function sendAction%(action, direction%)\n\t%-%-[^\n]*\n\tclearMovingElfTarget%(%)')~=nil,'dispatch clears target before reading target or turning')
check(source:find('\tclearMovingElfTarget()\n\treturn true',1,true)~=nil,'selection while moving cannot retain lock')
print('PASS elf movement target: '..checks..' checks')
