"""Generate fixed-build Luau checks with isolated profiles; no live DataStore."""
import json
from pathlib import Path
sources = {str(p): p.read_text() for root in ['src/shared', 'src/server/Inventory']
           for p in Path(root).rglob('*.luau')}
tests = ['tests/all-epic-diamonds.spec.lua', 'tests/economy.spec.lua',
         'tests/gold-diamond-tuning.spec.lua', 'tests/quest-completion-rewards.spec.lua']
for test in tests:
    sources[test] = Path(test).read_text()
code = 'local sources={' + ','.join('[' + json.dumps(k) + ']=' + json.dumps(v, ensure_ascii=False)
                                  for k, v in sources.items()) + '}\n'
code += "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')\n"
for target, names, root in [
    ('game.ReplicatedStorage.Shared', ['EconomyCatalog', 'EconomyRules', 'LobbyText', 'DeepwoodQuestLog'], 'src/shared'),
    ('game.ServerScriptService.Server.Inventory', ['InventoryRules'], 'src/server/Inventory')]:
    for name in names:
        code += f"assert({target}.{name}.Source==sources['{root}/{name}.luau'],'fixed source mismatch: {name}')\n"
code += """local cache={}
local function pure(path)
 if cache[path]then return cache[path]end
 local fn,why=loadstring(assert(sources[path],path),'@'..path);assert(fn,why)
 setfenv(fn,setmetatable({game=false,dofile=pure},{__index=getfenv()}))
 local value=fn();cache[path]=value or true;return value
end
"""
for test in tests:
    code += 'pure(' + json.dumps(test) + ')\n'
code += "print('ALL_EPIC_DIAMONDS_NATIVE_PASS');return {status='PASS',scope='isolated profiles; no live DataStore'}\n"
output = Path('/tmp/tlt-all-epic-diamonds-native.luau')
output.write_text(code)
print(output)
