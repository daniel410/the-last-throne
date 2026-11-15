local A=dofile('src/server/Combat/EnemyAfflictions.luau')
local R=dofile('src/shared/EnemyAfflictionRules.luau')
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local function model()
 local m={Parent={},attributes={}}
 function m:SetAttribute(name,value)self.attributes[name]=value end
 function m:GetAttribute(name)return self.attributes[name]end
 return m
end
local id=0
local function actors()
 id=id+1
 local enemy={model=model(),root={Parent={},Position={}},humanoid={Health=1000,Parent={}},attackSeq=4,run='A',registered=true}
 local state={character=model(),root={Parent={},Position={}},humanoid={Health=1000,Parent={}},heroId='Hero'..id,run='A',mode='Idle',registered=true}
 state.player={Character=state.character};enemy.attack={started=0}
 return enemy,state
end
local function attack(element,amount)
 return {pattern={id='Shaman.1',element=element},definition={damage=amount or 100,blockable=true},
  origin={source=true},direction={forward=true},sequence=4,pulse=1}
end
local function land(enemy,state,element,current,receipt)
 local a=attack(element)
 local direct,reservation=A.split(a,a.definition.damage,state,current)
 local applied=A.afterHit(enemy,state,a,current,reservation,receipt or {applied=direct,result='Hit',absorbed=0})
 return direct,applied,a
end
local hits={}
local ctx={valid=function(enemy,state)return enemy.registered and state.registered and enemy.run==state.run end,
 hit=function(enemy,state,a,current)
  check(a.afflictionTick and a.geometryChecked and a.definition.blockable,'tick reuses authoritative defense path without another geometry claim')
  check(not select(2,A.split(a,a.definition.damage,state,current)),'tick cannot reserve another status')
  check(not A.afterHit(enemy,state,a,current,{rule=R.get('fire'),element='fire',amounts={1,1}},{applied=1,result='Hit'}),'tick cannot recursively apply status')
  state.humanoid.Health=state.humanoid.Health-a.definition.damage
  hits[#hits+1]={source=enemy,target=state,amount=a.definition.damage,sequence=a.sequence,pulse=a.pulse}
 end}
local enemy,state=actors()
local direct,applied=land(enemy,state,'fire',0)
check(direct==75 and applied and A.count()==1,'fire reserves part of one damage budget')
check(state.character:GetAttribute('K0EnemyBurnUntil')==1.35,'burn publishes a server deadline')
enemy.attack=nil;enemy.attackSeq=5
A.step(.6,ctx);A.step(1.2,ctx)
check(#hits==2 and hits[1].amount+hits[2].amount+direct==100,'normal attack completion preserves exactly the remaining original raw budget')
check(hits[1].source==enemy and hits[1].sequence==4,'delayed damage preserves its actual source actor and cast')
check(A.count()==0 and state.character:GetAttribute('K0EnemyBurnUntil')==nil,'last finite tick clears its status')

for _,receipt in ipairs({{applied=0,result='Hit'}, {applied=3,result='Blocked'}, {applied=0,result='Dodged'},
 {applied=0,result='PerfectBlock'}, {applied=0,result='Absorbed'}, {applied=3,result='Hit',absorbed=2}})do
 enemy,state=actors();local _,ok=land(enemy,state,'fire',0,receipt)
 check(not ok and A.count()==0,'blocked/absorbed/avoided/prevented contact schedules no damage')
end

enemy,state=actors();land(enemy,state,'venom',0)
local repeated,reservation=A.split(attack('venom'),100,state,.2)
check(repeated==100 and reservation==nil,'active poison never stacks or steals another hit budget')
local _,duplicate=land(enemy,state,'venom',.2)
check(not duplicate and A.count()==1 and state.character:GetAttribute('K0EnemyVenomUntil')==1.35,'same-kind poison cannot refresh its duration')
A.clearAll(0)

enemy,state=actors();land(enemy,state,'frost',0);land(enemy,state,'web',0);land(enemy,state,'shadow',0);land(enemy,state,'soul',0)
check(A.movementMultiplier(state,.1)==.75,'web and chill choose the stronger slow instead of multiplying')
check(A.outgoingMultiplier(state,.1)==.85,'soul and shadow choose one weakness instead of multiplying')
check(state.character:GetAttribute('K0EnemySlowMultiplier')==.75 and state.character:GetAttribute('K0EnemyOutgoingMultiplier')==.85,'published multipliers match actual effect')
A.step(1.25,ctx)
check(A.movementMultiplier(state,1.25)==.8,'short web ends while chill remains')
A.step(1.51,ctx)
check(A.movementMultiplier(state,1.51)==1 and A.outgoingMultiplier(state,1.51)==1 and A.count()==0,'all control expires without permanent movement or damage changes')

local mutations={
 {'source cancellation',function(e,s)A.cancelSource(e,.2)end},
 {'source death',function(e,s)e.humanoid.Health=0 end},
 {'source humanoid removal',function(e,s)e.humanoid.Parent=nil end},
 {'source removal',function(e,s)e.model.Parent=nil end},
 {'source root removal',function(e,s)e.root.Parent=nil end},
 {'target death',function(e,s)s.humanoid.Health=0 end},
 {'target humanoid removal',function(e,s)s.humanoid.Parent=nil end},
 {'target character replacement',function(e,s)s.character=model()end},
 {'target humanoid replacement',function(e,s)s.humanoid={Health=1000}end},
 {'target respawn beginning',function(e,s)s.player.Character=nil end},
 {'target player respawn',function(e,s)s.player.Character=model()end},
 {'target hero replacement',function(e,s)s.heroId='OtherHero'end},
 {'other expedition',function(e,s)s.run='B'end},
 {'source encounter replacement',function(e,s)e.model:SetAttribute('DeepwoodEncounter','OtherRun')end},
 {'source no longer registered',function(e,s)e.registered=false end},
 {'target no longer registered',function(e,s)s.registered=false end},
 {'story pause',function(e,s)e.model:SetAttribute('StoryPauseUntil',1)end},
 {'nonlethal pacification',function(e,s)e.model:SetAttribute('StoryPacified',true)end},
}
for _,fixture in ipairs(mutations)do
 A.clearAll(0);hits={};enemy,state=actors();land(enemy,state,'fire',0)
 fixture[2](enemy,state);A.step(.6,ctx);A.step(1.2,ctx)
 check(#hits==0 and A.count()==0,'no late damage after '..fixture[1])
end

A.clearAll(0);hits={};enemy,state=actors();land(enemy,state,'fire',0)
A.step(.4,ctx);A.step(.95,ctx);A.step(2,ctx)
check(#hits==0 and A.count()==0,'server stalls never replay overdue ticks')

A.clearAll(0);hits={};enemy,state=actors();land(enemy,state,'fire',0)
A.step(.6,ctx);A.cancelSource(enemy,.7);A.step(1.2,ctx)
check(#hits==1 and A.count()==0,'interrupt after the first tick cancels the remaining escrow')

A.clearAll(0);enemy,state=actors();land(enemy,state,'frost',0);land(enemy,state,'shadow',0)
A.clearTarget(state,.2)
check(A.count()==0 and A.movementMultiplier(state,.2)==1 and A.outgoingMultiplier(state,.2)==1,'target cleanup restores all multipliers')
for _,name in ipairs(R.attributes())do check(state.character:GetAttribute(name)==nil,'target cleanup clears '..name)end

A.clearAll(0);hits={}
for index=1,R.maxRecords+1 do
 local e,s=actors();local _,ok=land(e,s,'fire',0)
 check(ok==(index<=R.maxRecords),'bounded queue admission')
end
check(A.count()==R.maxRecords,'queue cannot exceed record limit')
local calls=A.step(.6,ctx)
check(calls==R.maxTicksPerStep and #hits==calls,'one step has a bounded authoritative hit cost')
A.step(.6,ctx)
check(#hits==calls,'same timestamp cannot replay an already consumed tick')
A.clearAll(1)

hits={};enemy,state=actors()
for index=1,8 do local _,s=actors();land(enemy,s,'fire',0)end
local cancelCtx={valid=ctx.valid,hit=function(e,s,a,t)hits[#hits+1]=a;A.cancelSource(e,t)end}
local ok,err=pcall(A.step,.6,cancelCtx)
check(ok and #hits==1 and A.count()==0,'synchronous source cancellation is safe while iterating the queue: '..tostring(err))
print('enemy-afflictions: '..checks..' checks PASS; source/target lifetime, defenses, raw budget, finite non-stacking effects and bounded ticks')
