from pathlib import Path
import json,re
sources={}
def add(path):
 if path in sources:return
 s=Path(path).read_text();sources[path]=s
 for dep in re.findall(r'dofile\([\'"]([^\'"]+)[\'"]\)',s):add(dep)
 for name in re.findall(r'load\([\'"]([^\'"]+)[\'"]\)',s):add('src/shared/'+name+'.luau')
add('tests/epic-monster-progression.spec.lua')
body=re.search(r'(local function applyBalance.*?)\nlocal spawnWave',Path('src/server/Story/DeepwoodService.luau').read_text(),re.S)[1]
code='local sources='+ '{\n'+''.join('['+json.dumps(k)+']='+json.dumps(v)+',\n'for k,v in sources.items())+'}\n'
code+='''local cache={};local messages={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn=assert(loadstring(assert(sources[path]),'@'..path))
 setfenv(fn,setmetatable({game=false,dofile=pure,print=function(m)table.insert(messages,m)end},{__index=getfenv()}))
 local value=fn();cache[path]=value or true;return value
end
pure('tests/epic-monster-progression.spec.lua')
local B=pure('src/shared/DeepwoodEncounterBalance.luau')
local C=pure('src/shared/CampaignContent.luau')
'''
code+='local apply=assert(loadstring('+json.dumps('return function(Balance)\n'+body+'\nreturn applyBalance end')+'))()(B)\n'
code+='''local model=Instance.new('Model');local checks=0;local units=0
local ok,err=xpcall(function()
 for _,chapter in ipairs(C.chapters)do for _,goal in ipairs(chapter.goals)do
  for _,mode in ipairs({'Easy','Hell'})do for _,party in ipairs({1,4})do
   for _,wave in ipairs(B.encounterWaves(chapter,goal,party))do for index,spec in ipairs(wave)do
    for version=1,4 do
     apply(model,spec,party,mode,version,index)
     local hp,damage,level=B.unitStats(spec,party,mode,version,index)
     assert(model:GetAttribute('StoryHealth')==hp and model:GetAttribute('StoryDamage')==damage and model:GetAttribute('StoryLevel')==level,'authoritative attribute bridge mismatch')
     checks+=3
    end
    units+=1;if units%500==0 then task.wait()end
   end end
  end end
 end end
end,debug.traceback)
model:Destroy();assert(ok,err)
return {messages=messages,bridgeChecks=checks,units=units,placeId=game.PlaceId,players=#game:GetService('Players'):GetPlayers(),scope='isolated current-source Luau and actual applyBalance Model attributes; no live accounts or gameplay'}
'''
Path('/tmp/tlt-epic-monster-native.luau').write_text(code)
print(len(code))
