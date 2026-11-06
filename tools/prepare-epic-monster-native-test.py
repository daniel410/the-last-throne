from pathlib import Path
import json,re
sources={}
def add(path):
 if path in sources:return
 s=Path(path).read_text();sources[path]=s
 for dep in re.findall(r'dofile\([\'"]([^\'"]+)[\'"]\)',s):add(dep)
 for name in re.findall(r'load\([\'"]([^\'"]+)[\'"]\)',s):add('src/shared/'+name+'.luau')
add('tests/epic-monster-progression.spec.lua')
add('tests/monster-damage-boost.spec.lua')
add('tests/monster-health-boost.spec.lua')
add('tests/boss-combat-tuning.spec.lua')
for name in ['FrozenValeCombat','EmberCalderaCombat','LateEpicCombat']:add('src/shared/'+name+'.luau')
body=re.search(r'(local function applyBalance.*?)\nlocal spawnWave',Path('src/server/Story/DeepwoodService.luau').read_text(),re.S)[1]
code='local sources='+ '{\n'+''.join('['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False)+',\n'for k,v in sources.items())+'}\n'
code+='''local cache={};local messages={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn=assert(loadstring(assert(sources[path]),'@'..path))
 setfenv(fn,setmetatable({game=false,dofile=pure,print=function(m)table.insert(messages,m)end},{__index=getfenv()}))
 local value=fn();cache[path]=value or true;return value
end
pure('tests/epic-monster-progression.spec.lua')
pure('tests/monster-damage-boost.spec.lua')
pure('tests/monster-health-boost.spec.lua')
pure('tests/boss-combat-tuning.spec.lua')
local B=pure('src/shared/DeepwoodEncounterBalance.luau')
local C=pure('src/shared/CampaignContent.luau')
'''
code+='local apply=assert(loadstring('+json.dumps('return function(Balance)\n'+body+'\nreturn applyBalance end')+'))()(B)\n'
code+='''local model=Instance.new('Model');local checks=0;local units=0
local ok,err=xpcall(function()
 for _,chapter in ipairs(C.chapters)do for _,goal in ipairs(chapter.goals)do
  for _,mode in ipairs({'Easy','Hell'})do for _,party in ipairs({1,4})do
   for _,wave in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(wave)do
    for version=1,7 do
     apply(model,spec,party,mode,version,index)
     local hp,damage,level=B.unitStats(spec,party,mode,version,index)
     assert(model:GetAttribute('StoryHealth')==hp and model:GetAttribute('StoryDamage')==damage and model:GetAttribute('StoryLevel')==level,'authoritative attribute bridge mismatch')
     local tempo=B.tempo(spec.kind,version)
     assert(model:GetAttribute('StoryAttackSpeed')==tempo.attackSpeed and model:GetAttribute('StoryMoveSpeed')==tempo.moveSpeed,'tempo attributes mismatch')
     checks+=5
    end
    units+=1;if units%500==0 then task.wait()end
   end end
  end end
 end end
end,debug.traceback)
model:Destroy();assert(ok,err)
return {messages=messages,bridgeChecks=checks,units=units,placeId=game.PlaceId,players=#game:GetService('Players'):GetPlayers(),scope='isolated current-source Luau and actual applyBalance Model attributes; no live accounts or gameplay'}
'''
combat=Path('src/server/Combat/CombatService.luau').read_text()
registration=re.search(r'registerEnemy = function\(model, savedTemplate, savedPivot, savedId, splitGroup\)\n(.*?)\n\tlocal humanoid',combat,re.S)[1]
factory='return function(Config,BossTuning,model)\n'+registration+'\nreturn config end'
extra='local registrationSource='+json.dumps(factory)+'\n'
extra+="""
local shared={FrozenValeCombat='src/shared/FrozenValeCombat.luau',EmberCalderaCombat='src/shared/EmberCalderaCombat.luau',LateEpicCombat='src/shared/LateEpicCombat.luau'}
local fakeGame={ReplicatedStorage={Shared=shared}}
function fakeGame:GetService(name)assert(name=='ReplicatedStorage');return self.ReplicatedStorage end
local fn=assert(loadstring(registrationSource))
setfenv(fn,setmetatable({game=fakeGame,require=pure},{__index=getfenv()}))
local registerConfig=fn()
local base=pure('src/shared/K0Config.luau');local tuning=pure('src/shared/BossCombatTuning.luau')
local registrationChecks=0;local kinds={}
for _,chapter in ipairs(C.chapters)do for _,goal in ipairs(chapter.goals)do
 for _,wave in ipairs(B.encounterWaves(chapter,goal,1))do for index,spec in ipairs(wave)do
  if not kinds[spec.kind]then
   kinds[spec.kind]=true;model:SetAttribute('EnemyKind',spec.kind);model:SetAttribute('DeepwoodEncounter',true)
   apply(model,spec,1,'Easy',6,index);local old=registerConfig(base,tuning,model)
   apply(model,spec,1,'Easy',7,index);local new=registerConfig(base,tuning,model)
   local factor=B.isBoss(spec.kind)and 1.1 or 1
   assert(math.abs(new.walkSpeed/old.walkSpeed-factor)<1e-8,'actual registration movement mismatch')
   registrationChecks+=1
   for i,a in ipairs(new.attacks)do local b=old.attacks[i]
    assert(a.windup==b.windup and a.active==b.active,'registration shortened attack warning')
    assert(math.abs((b.windup+b.active+b.recovery)/(a.windup+a.active+a.recovery)-factor)<1e-8,'actual registration cycle mismatch')
    assert(a.damage==model:GetAttribute('StoryDamage'),'actual attack damage mismatch')
    registrationChecks+=3
   end
  end
 end end
end end
"""
code=code.replace('model:Destroy();assert(ok,err)', 'assert(ok,err)\n'+extra+'\nmodel:Destroy()').replace('bridgeChecks=checks,units=units','bridgeChecks=checks,registrationChecks=registrationChecks,units=units')
Path('/tmp/tlt-epic-monster-native.luau').write_text(code)
print(len(code))
