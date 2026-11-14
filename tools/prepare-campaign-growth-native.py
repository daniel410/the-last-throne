"""Prepare an isolated Luau runner; never touches a live account or Studio source."""
from pathlib import Path
import json
import re

sources = {}


def add(path):
    if path in sources:
        return
    source = Path(path).read_text()
    sources[path] = source
    for dependency in re.findall(r'dofile\([\'"]([^\'"]+)[\'"]\)', source):
        add(dependency)
    for name in re.findall(r'load\([\'"]([^\'"]+)[\'"]\)', source):
        add('src/shared/' + name + '.luau')


add('tests/campaign-growth-v16.spec.lua')
add('tests/campaign-xp-requirements.spec.lua')
add('tests/expedition-presentation.spec.lua')
add('tests/hero-progression.spec.lua')
add('tests/difficulty-reward-rates.spec.lua')
sources['src/server/Story/DeepwoodService.luau'] = Path('src/server/Story/DeepwoodService.luau').read_text()
for name in ('CampaignCombatRouteWorld', 'CampaignRouteClearance', 'CampaignSceneryPlacement', 'DeepwoodPlaces', 'EpicWorldArt', 'RegionalConceptArt'):
    path = 'src/server/World/' + name + '.luau'
    sources[path] = Path(path).read_text()
code = 'local sources={\n' + ''.join(
    '[' + json.dumps(path) + ']=' + json.dumps(source, ensure_ascii=False) + ',\n'
    for path, source in sources.items()
) + '}\n'
code += '''
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local cache,output={},{}
local compiled=0
for path,source in pairs(sources)do assert(loadstring(source,'@'..path));compiled+=1 end
local function pure(path)
 if cache[path]then return cache[path]end
 local fn=assert(loadstring(assert(sources[path],path),'@'..path))
 setfenv(fn,setmetatable({game=false,dofile=pure,print=function(...)local words={...};for i,v in ipairs(words)do words[i]=tostring(v)end;output[#output+1]=table.concat(words,' ')end},{__index=getfenv()}))
 cache[path]=fn()or true;return cache[path]
end
pure('tests/campaign-growth-v16.spec.lua')
pure('tests/campaign-xp-requirements.spec.lua')
pure('tests/expedition-presentation.spec.lua')
pure('tests/hero-progression.spec.lua')
pure('tests/difficulty-reward-rates.spec.lua')
local B,D,C=pure('src/shared/DeepwoodEncounterBalance.luau'),pure('src/shared/Difficulty.luau'),pure('src/shared/CampaignContent.luau')
local body=assert(sources['src/server/Story/DeepwoodService.luau']:match('(local function applyBalance.-)\\nlocal spawnWave'))
local fn=assert(loadstring(body..'\\nreturn applyBalance','actual server applyBalance'))
setfenv(fn,setmetatable({Balance=B,Difficulty=D},{__index=getfenv()}))
local applyBalance=fn();local model=Instance.new('Model');local attributes=0
local ok,reason=xpcall(function()
 for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.goals)do for _,mode in ipairs(D.order)do
  for _,version in ipairs({15,16})do for party=1,4 do
   for _,batch in ipairs(B.encounterWaves(c,g,party,mode,version))do
    local spec=batch[1]
    applyBalance(model,spec,party,mode,version,1)
    local hp,damage,level=B.unitStats(spec,party,mode,version,1)
    assert(model:GetAttribute('StoryHealth')==hp and model:GetAttribute('StoryDamage')==damage and model:GetAttribute('StoryLevel')==level,'authoritative model stats')
    attributes+=1
   end
  end end
 end end;task.wait()end
end,debug.traceback)
model:Destroy();assert(ok,reason)
return {kind='CAMPAIGN_GROWTH_FIXED_XP',runtime='Studio Luau',accountAccess=false,compiledSources=compiled,modelAttributeCases=attributes,results=output}
'''
destination = Path('/tmp/tlt-growth16-native')
destination.mkdir(exist_ok=True)
(destination / 'runner.luau').write_text(code)
print(destination / 'runner.luau')
