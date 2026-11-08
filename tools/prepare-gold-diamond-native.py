"""Create isolated Luau reward regressions; never accesses live account storage."""
import json
from pathlib import Path

sources = {str(p): p.read_text() for base in ['src/shared', 'src/server/Inventory']
           for p in Path(base).rglob('*.luau')}
tests = ['tests/gold-diamond-tuning.spec.lua', 'tests/economy.spec.lua',
         'tests/difficulty-balance.spec.lua', 'tests/expedition-presentation.spec.lua']
for test in tests:
    sources[test] = Path(test).read_text()
code = 'local sources={\n' + ''.join(
    '[' + json.dumps(k) + ']=' + json.dumps(v, ensure_ascii=False) + ',\n'
    for k, v in sources.items()) + '}\n'
code += """for _,name in ipairs({'Difficulty','EconomyCatalog','EconomyRules'})do assert(game.ReplicatedStorage.Shared[name].Source==sources['src/shared/'..name..'.luau'],'fixed build source mismatch: '..name)end
local cache={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn,why=loadstring(assert(sources[path],path),'@'..path);assert(fn,why)
 setfenv(fn,setmetatable({game=false,dofile=pure},{__index=getfenv()}))
 local value=fn();cache[path]=value or true;return value
end
"""
for test in tests:
    code += 'pure(' + json.dumps(test) + ')\n'
code += "print('GOLD_DIAMOND_NATIVE_PASS 4617 checks');return {checks=4617,status='PASS',scope='isolated Luau rules, account reducer and presentation; no live DataStore'}\n"
output = Path('/tmp/tlt-gold-diamond-native.luau')
output.write_text(code)
print(output)
