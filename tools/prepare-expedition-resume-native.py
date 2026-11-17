"""원정 재개 회귀를 빈 로컬 Studio에서 실행할 격리 Luau 스크립트 생성."""
from pathlib import Path
import json
import re

sources = {}
def add(path):
    if path in sources:
        return
    source = Path(path).read_text().replace('{__index=_G}', '{__index=getfenv()}')
    sources[path] = source
    for dep in re.findall(r"dofile\(['\"]([^'\"]+)['\"]\)", source):
        add(dep)
    for name in re.findall(r"load\(['\"]([^'\"]+)['\"]\)", source):
        add('src/shared/' + name + '.luau')

suites = ['expedition-backend', 'expedition-resume-rules', 'expedition-departure', 'expedition-store', 'adventure-starting', 'expedition-request']
for suite in suites:
    add('tests/' + suite + '.spec.lua')
add('src/server/Network/ExpeditionService.luau')
add('src/client/ExpeditionView.luau')
code = 'local sources=' + '{\n' + ''.join(
    '[' + json.dumps(k) + ']=' + json.dumps(v, ensure_ascii=False) + ',\n'
    for k, v in sources.items()) + '}\n'
code += '''
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')
local compiled=0
for path,source in pairs(sources)do assert(loadstring(source,'@'..path));compiled+=1 end
local cache={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn=assert(loadstring(assert(sources[path],path),'@'..path))
 local env=setmetatable({game=false,dofile=pure,
  io={open=function(path)return {read=function()return assert(sources[path])end,close=function()end}end},
  load=function(code,name,mode,env)local fn,err=loadstring(code,name);if fn then setfenv(fn,env)end;return fn,err end
 },{__index=getfenv()})
 setfenv(fn,env);local value=fn();cache[path]=value or true;return value
end
'''
for suite in suites:
    code += "pure('tests/" + suite + ".spec.lua')\n"
code += "print('EXPEDITION_RESUME_NATIVE_PASS compiled='..compiled)\n"
target = Path('/tmp/tlt-expedition-resume-native.luau')
target.write_text(code)
print(target)
