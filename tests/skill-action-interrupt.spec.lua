-- Execute actual server functions and remote callback with engine boundaries
-- stubbed. Covers input routing, cancellation, costs and held-input retries.
if game then return {} end
local function read(path)
 local file=assert(io.open(path));local source=file:read('*a');file:close();return source
end
local server=read(os.getenv('TLT_COMBAT_SOURCE') or 'src/server/Combat/CombatService.luau')
local client=read('src/client/init.client.luau')
local Config=dofile('src/shared/K0Config.luau')
local Rules=dofile('src/server/Combat/K0Rules.luau')
local checks=0
local function eq(actual,expected,label)
 checks=checks+1;assert(actual==expected,label..': '..tostring(actual)..' ~= '..tostring(expected))
end
local function transpile(source)
 return (source:gsub('([%w_%.%[%]]+)%s*%+=%s*([^\n]+)','%1 = %1 + %2'):gsub('([%w_%.%[%]]+)%s*%-=%s*([^\n]+)','%1 = %1 - %2'))
end
local function extract(source,name,nextName,env)
 local start=assert(source:find('local function '..name..'(',1,true))
 local stop=assert(source:find('\nlocal function '..nextName..'(',start,true))
 return assert(load(transpile(source:sub(start,stop-1))..'\nreturn '..name,name,'t',env))()
end
local env=setmetatable({Config=Config,Rules=Rules,enemyStates={},playerStates={},
 workspace={GetServerTimeNow=function() return 10 end},
 Vector3={new=function() return {} end},
 horizontalUnit=function(direction) return direction end,
 Advanced={isUltimate=function(_,index)return index==99 end,unlocked=function()return true end,ultimate=function()return 99 end},
 Growth={skill=function(_,_,skill)return skill end},
 alive=function(state)return state.humanoid.Health>0 end,
 readCombatContext=function()return {} end,
 math=setmetatable({clamp=function(x,lo,hi)return math.max(lo,math.min(x,hi))end},{__index=math}),
},{__index=_G})
for _,entry in ipairs({{'updateFeedback','setPlayerState'},{'setPlayerState','releaseDodgeOwnership'},
 {'releaseDodgeOwnership','restoreAutoRotate'},{'restoreAutoRotate','clearAction'},
 {'clearAction','resetCombo'},{'resetCombo','readCombatContext'},
 {'setMana','publishSkills'},{'startSkill','startGuard'}, {'acceptAction','applyPlayerHit'}}) do
 env[entry[1]]=extract(server,entry[1],entry[2],env)
end
local function state(classId,mode)
 local attrs={K0Invulnerable=true}
 local character={SetAttribute=function(_,key,value)attrs[key]=value end,GetAttribute=function(_,key)return attrs[key]end}
 local root={Parent=true,CFrame={LookVector={}},SetNetworkOwnershipAuto=function(self)self.released=true end}
 local s={baseClassId=classId,mode=mode,character=character,root=root,humanoid={Health=100,Parent=true,AutoRotate=false},
  slotCount=5,skillSlots={1,2,3,1,2},skillReadyAt={},attackProfile=Config.BasicAttackProfiles[classId],
  feedbackSeq=0,attackSeq=0,mana=100,maxMana=100,combo=2,player={},
  attack={definition={braced=true}},dodge={},guardStarted=1,dodgeOwned=true,savedAutoRotate=true,
  queued={action='Attack'},sprinting=true}
 return s,attrs
end
for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
 for _,mode in ipairs({'Idle','Attack','Block','Dodge'}) do
  for slot=1,5 do
   local s,a=state(classId,mode);local d=Config.Skills[classId][s.skillSlots[slot]]
   env.acceptAction(s,'Skill'..slot,nil,10)
   eq(s.attack.definition,d,classId..' '..mode..' slot'..slot..' starts immediately')
   eq(s.attack.started,10,'no input buffer wait');eq(s.queued,nil,'old buffer cleared')
   eq(s.dodge,nil,'dodge stopped');eq(s.guardStarted,nil,'guard stopped')
   eq(s.root.released,true,'dodge ownership returned');eq(a.K0Invulnerable,false,'dodge invulnerability ended')
   eq(s.mode,'Attack','skill state');eq(s.humanoid.WalkSpeed,Config.AttackSpeed,'old braced movement reset')
   eq(s.sprinting,false,'sprint stopped');eq(s.skillReadyAt[d.id],10+d.cooldown,'cooldown starts once')
   eq(s.mana,d.magic and 100-d.manaCost or 100,'MP charged once')
   local cast=s.attack;env.acceptAction(s,'Skill'..slot,nil,10)
   eq(s.attack,cast,'cooling skill cannot interrupt');eq(s.mana,d.magic and 100-d.manaCost or 100,'repeat cannot charge MP')
  end
 end
end
-- Ultimate uses the same takeover path, with eligibility already resolved by
-- the trusted growth boundary. Its former MP/cooldown remain spent on cancel.
for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
 local ultimateIndex
 for index,d in pairs(Config.Skills[classId]) do if d.ultimate then ultimateIndex=index;break end end
 assert(ultimateIndex,'ultimate fixture')
 env.Advanced.ultimate=function()return ultimateIndex end
 env.AdvancedCombat={snapshot=function()return {}end}
 env.skillStep=function()end
 for _,mode in ipairs({'Attack','Block','Dodge'}) do
  local s=state(classId,mode);s.growth={}
  env.acceptAction(s,'Ultimate',nil,10)
  local d=Config.Skills[classId][ultimateIndex]
  eq(s.attack.definition,d,'ultimate takes over '..mode)
  eq(s.skillReadyAt[d.id],10+d.cooldown,'ultimate cooldown')
  eq(s.mana,d.magic and 100-d.manaCost or 100,'ultimate cost')
 end
end
local arcane=state('mage','Dodge');env.acceptAction(arcane,'CastArcane',nil,10)
eq(arcane.attack.definition,Config.Skills.mage[1],'legacy arcane route takes over dodge')
for _,failure in ipairs({'cooldown','mana','shield','locked','dead','stunned','inventory'}) do
 local s,a=state(failure=='shield' and 'knight' or 'mage',failure=='stunned' and 'Stunned' or 'Attack')
 local before=s.attack;local queued=s.queued
 if failure=='cooldown' then s.skillReadyAt[Config.Skills.mage[1].id]=20
 elseif failure=='mana' then s.mana=0
 elseif failure=='shield' then s.inventoryManaged=true;s.equipment={weapon=true}
 elseif failure=='locked' then s.slotCount=0
 elseif failure=='dead' then s.humanoid.Health=0
 elseif failure=='inventory' then env.readCombatContext=function()return {inventoryLocked=true}end end
 env.acceptAction(s,'Skill1',nil,10)
 eq(s.attack,before,failure..' preserves current action');eq(s.queued,queued,failure..' preserves buffer')
 eq(s.root.released,nil,failure..' does not release dodge ownership')
 env.readCombatContext=function()return {}end
end
-- The real RemoteEvent callback must not drop a skill when stepPlayer has
-- just consumed a due Attack/Block/Dodge in the same server frame.
local first=assert(server:find('actionRemote.OnServerEvent:Connect(function(',1,true))
local last=assert(server:find('\n\tend)\n\tRunService.Heartbeat',first,true))
local callback=server:sub(first,last-1)..'\nend)'
local routed
local remoteEnv=setmetatable({actionRemote={OnServerEvent={Connect=function(_,fn)routed=fn end}},
 playerStates={},alive=env.alive,validDirection=function()return true end,now=function()return 10 end,
 processCombatSamples=function(_,s)return {[s]=true}end,Rules=Rules,Config=Config,
 stepPlayer=function()return 'Dodge'end,
 acceptAction=function(s,action)s.accepted=action end,
},{__index=_G})
assert(load(transpile(callback),'remote callback','t',remoteEnv))()
for _,action in ipairs({'Skill1','Skill2','Skill3','Skill4','Skill5','Ultimate','CastArcane','Attack'}) do
 local s=state('mage','Attack');s.queued=nil;s.tokens=10;s.lastRefill=10;remoteEnv.playerStates[s.player]=s
 routed(s.player,action,nil,nil)
 eq(s.accepted,action~='Attack' and action or nil,action..' routing after consumed dodge')
end
-- Client dispatch cancels repeat loops without losing release bookkeeping.
local tableMock=setmetatable({clear=function(t)for k in pairs(t)do t[k]=nil end end},{__index=table})
for _,action in ipairs({'Skill1','Skill5','Ultimate','CastArcane','Attack'}) do
 local sent
 local c=setmetatable({table=tableMock,actionRemote={FireServer=function(_,name)sent=name end},
  player={},combatInputAllowed=function()return true end,attackInputs={mouse=true},
  attackGeneration=3,blockGeneration=4,sprintGeneration=5,heldBlock=true,heldSprint=true,
 },{__index=_G})
 local send=extract(client,'sendAction','movementDirection',c);send(action)
 local skill=action~='Attack'
 eq(sent,action,'client sends '..action);eq(c.attackGeneration,skill and 4 or 3,'attack retry generation')
 eq(c.blockGeneration,skill and 5 or 4,'block retry generation');eq(c.sprintGeneration,skill and 6 or 5,'sprint retry generation')
 eq(c.attackInputs.mouse,not skill or nil,'held attack canceled')
 eq(c.heldBlock,true,'block release remains available');eq(c.heldSprint,true,'sprint release remains available')
end
print('Skill action interrupt: '..checks..' checks passed')
