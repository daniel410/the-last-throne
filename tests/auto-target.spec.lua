-- Run actual client selection against deterministic engine doubles, not copied rules.
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local Assist=dofile('src/shared/TargetAssistRules.luau')
local Config=dofile('src/shared/K0Config.luau')
local vector={}
local mt={}
function vector.new(x,y,z)return setmetatable({X=x,Y=y,Z=z},mt)end
function mt.__sub(a,b)return vector.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__index=function(v,k)
 if k=='Magnitude'then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)end
 if k=='Unit'then local m=v.Magnitude;return vector.new(v.X/m,v.Y/m,v.Z/m)end
 if k=='Dot'then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
local zero=vector.new(0,0,0)
local enemies={children={}}
function enemies:GetChildren()return self.children end
local field={FindFirstChild=function(_,name)if name=='Enemies'then return enemies end end}
local hidden,blocked={},{}
local workspace={CurrentCamera={WorldToViewportPoint=function(_,p)return p,not hidden[p]end}}
function workspace:FindFirstChild(name)if name=='DeepwoodK0'then return field end end
function workspace:Raycast(_,delta)
 if blocked[delta.X..':'..delta.Y..':'..delta.Z]then return {Instance={IsDescendantOf=function()return false end}}end
 return nil
end
local shared={K0Config=Config,TargetAssistRules=Assist}
local env=setmetatable({game={GetService=function(_,name)return name=='Workspace'and workspace or {Shared=shared}end},require=function(m)return m end,Vector3=vector,RaycastParams={new=function()return {}end},Enum={RaycastFilterType={Exclude=1}}},{__index=_G})
local Targeting=assert(loadfile('src/client/K0Targeting.luau','t',env))()
local character={attributes={K0ClassId='knight'},root={Position=zero,CFrame={LookVector=vector.new(0,0,-1)}},humanoid={MoveDirection=zero}}
function character:GetAttribute(key)return self.attributes[key]end
function character:FindFirstChild(name)if name=='HumanoidRootPart'then return self.root end end
function character:FindFirstChildOfClass()return self.humanoid end
local function enemy(name,x,y,z)
 local e={Name=name,Parent=enemies,HumanoidRootPart={Position=vector.new(x,y,z)},humanoid={Health=100}}
 function e:FindFirstChildOfClass()return self.humanoid end
 function e:FindFirstChild(name)if name=='HumanoidRootPart'then return self.HumanoidRootPart end end
 table.insert(enemies.children,e);return e
end
local function reset(class)
 enemies.children={};hidden={};blocked={};character.attributes={K0ClassId=class};character.humanoid.MoveDirection=zero
end
local function resolve(action,preferred,on,wasAuto)return Targeting.resolve(character,action or 'Attack',preferred,on~=false,wasAuto==true)end
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 reset(class)
 local near=enemy('Near',0,0,-3);local far=enemy('Far',1,0,-4);local behind=enemy('Behind',0,0,1)
 check(resolve()==near,class..' attacks nearest forward enemy without a world click')
 check(resolve(nil,far)==far,class..' retains a valid manual choice')
 check(resolve(nil,far,true,true)==far,class..' retains current auto target instead of flickering to nearer enemy')
 check(resolve(nil,nil,false)==nil,class..' OFF never acquires a new target')
 check(resolve(nil,far,false)==far,class..' OFF still accepts manual selection')
 check(resolve(nil,far,false,true)==nil,class..' OFF discards automatic selection')
 character.humanoid.MoveDirection=vector.new(0,0,-1)
 check(resolve(nil,far)==far,class..' moving toward target retains it')
 character.humanoid.MoveDirection=vector.new(0,0,1)
 check(resolve(nil,near,false)==nil,class..' moving away does not aim backward at manual target')
 check(resolve(nil,near)==behind,class..' next attack assists toward escape direction, not old target')
 character.humanoid.MoveDirection=zero
 near.humanoid.Health=0
 check(resolve()==far,class..' next attack replaces defeated target')
 far.Parent=nil;check(resolve()==nil,class..' excludes streamed-out and rear enemies')
 check(resolve(nil,behind,false)==behind,class..' stationary manual choice may turn intentionally')
end
reset('elf')
local far=enemy('Far',0,0,-40)
check(resolve()==far,'elf basic uses bow range')
character.attributes.K0ClassId='mage';check(resolve()==nil,'mage basic keeps staff melee range')
character.attributes.K0EquippedSkill1='mage.common.mana_bolt'
check(resolve('Skill1')==far,'mage ranged spell uses equipped skill range')
check(resolve('CastArcane')==far,'legacy mage cast resolves equipped first slot')
check(resolve('Ultimate')==nil,'locked ultimate does not acquire targets')
character.attributes.K0ClassId='knight';character.attributes.K0EquippedSkill1='knight.common.whirlwind'
check(resolve('Skill1')==nil,'self-centered whirlwind does not turn toward an enemy')
character.attributes.K0EquippedSkill1='knight.steel_knight.twin_cyclone'
check(resolve('Skill1')==nil,'advanced area skill does not select a distant center')
-- Inspect all definitions instead of assuming a particular provisional ultimate ID.
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 for _,d in ipairs(Config.Skills[class])do
  character.attributes.K0ClassId=class;character.attributes.K0EquippedSkill5=d.id
  check((Targeting.definition(character,'Skill5')~=nil)==not not Assist.directional(d),'equipped definition eligibility '..d.id)
 end
end
reset('elf')
local near=enemy('Near',0,0,-3);far=enemy('Far',0,0,-20)
hidden[near.HumanoidRootPart.Position]=true;check(resolve()==far,'off-screen target is excluded')
hidden={};blocked['0:0:-3']=true;check(resolve()==far,'wall blocks nearer candidate')
blocked={};near.HumanoidRootPart=nil;check(resolve()==far,'partial streamed rig is excluded')
far.HumanoidRootPart.Position=vector.new(0,11,-20);check(resolve()==nil,'out-of-height enemy is excluded')
far.HumanoidRootPart.Position=vector.new(0,0,-56);check(resolve()==nil,'outside bow range is excluded')
far.HumanoidRootPart.Position=vector.new(0,10,-55);check(resolve()==nil,'ranged range is measured in 3D')
far.HumanoidRootPart.Position=vector.new(25,0,-1);check(resolve()==nil,'outside forward assist cone is excluded')
check(Targeting.resolve(nil,'Attack',nil,true)==nil,'character swap race is safe')
reset('knight')
local b=enemy('B',1,0,-3);local a=enemy('A',-1,0,-3)
check(resolve()==a,'equal-distance targets have a stable name tie break')
character.attributes.K0EquippedSkill1='unknown.skill'
check(resolve('Skill1')==nil,'unknown equipped skill cannot borrow a different range')
local saved=workspace.FindFirstChild;workspace.FindFirstChild=function()return nil end
check(resolve()==nil,'absent battlefield during lobby transition is safe');workspace.FindFirstChild=saved
check(resolve('Dodge')==nil and resolve('BlockStart')==nil and resolve('SprintStart')==nil,'non-attacks do not select targets')
local camera=workspace.CurrentCamera;workspace.CurrentCamera=nil;check(resolve()==nil,'missing camera is safe');workspace.CurrentCamera=camera
local Settings=dofile('src/client/GameSettings.luau')
local player={attributes={}}
function player:GetAttribute(k)return self.attributes[k]end
function player:SetAttribute(k,v)self.attributes[k]=v end
check(Settings.enabled(player,'autoTarget'),'auto target defaults ON')
Settings.toggle(player,'autoTarget');check(not Settings.enabled(player,'autoTarget'),'toggle immediately switches OFF')
for _,id in ipairs({'attacks','navigation','waypoints'})do check(Settings.enabled(player,id),'toggle preserves '..id)end
local rebuilt=dofile('src/client/GameSettings.luau');check(not rebuilt.enabled(player,'autoTarget'),'menu reconstruction retains local setting')
Settings.toggle(player,'autoTarget');check(Settings.enabled(player,'autoTarget'),'toggle returns ON')
check(not pcall(Settings.set,player,'autoTarget','false'),'setting rejects non-boolean')
local text=dofile('src/shared/SettingsText.luau')
for _,option in ipairs(Settings.options)do check(type(text[option.title])=='string'and type(text[option.hint])=='string','settings label/hint provided: '..option.id)end
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local server=read('src/server/Combat/CombatService.luau')
local body=assert(server:match('local function targetForMovement%(state, targetModel%)\n(.-)\nend'))
local enemyStates={[far]={root=far.HumanoidRootPart}}
local filter=assert(load('return function(state,targetModel) '..body..' end','server movement','t',{enemyStates=enemyStates,horizontal=function(v)return vector.new(v.X,0,v.Z)end,TargetAssistRules=Assist,Config=Config}))()
local state={root={Position=zero,AssemblyLinearVelocity=vector.new(0,0,-16)}}
far.HumanoidRootPart.Position=vector.new(0,0,-3)
check(filter(state,far)==far,'server allows buffered forward target')
state.root.AssemblyLinearVelocity=vector.new(0,0,16)
check(filter(state,far)==nil,'server rejects buffered target behind observed movement')
state.root.AssemblyLinearVelocity=vector.new(0,0,.01)
check(filter(state,far)==far,'server ignores idle drift')
local controller=read('src/client/BattleController.luau')
check(not controller:find('clearMovingElfTarget',1,true),'unconditional elf movement cancellation superseded for all classes')
check(controller:find('Targeting.resolve(character, action',1,true)~=nil,'input dispatch uses tested resolver')
check(controller:find('if targetAutomatic and not Settings.enabled(player, "autoTarget") then clearTarget()',1,true)~=nil,'OFF immediately clears automatic highlight')
check(controller:find('clearAttacks(); clearTarget(); hud.showFeedback(Text.TargetCleared)',1,true)~=nil,'manual clear cancels held repeat before reacquisition')
print('PASS auto target: '..checks..' checks')
