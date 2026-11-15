"""Pin the reference-only knight combo and native QA to an isolated host."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--fixed', action='store_true')
args = parser.parse_args()
paths = ['src/client/K0MeleeMotion.luau'] + [str(p) for p in sorted(Path('src/client').glob('K0KnightReference*.luau'))]
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated host only')\n"
for path in paths:
    p = Path(path)
    source = json.dumps(p.read_text(), ensure_ascii=False)
    parent = 'game.StarterPlayer.StarterPlayerScripts.Client'
    if args.fixed:
        code += f'assert({parent}.{p.stem}.Source=={source},"source mismatch {p.stem}")\n'
    else:
        code += f'do local p={parent};local m=p:FindFirstChild("{p.stem}")or Instance.new("ModuleScript");m.Name="{p.stem}";m.Source={source};m.Parent=p end\n'
code += """for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end
end
print('KNIGHT_REFERENCE_COMPILE_PASS')
"""
previous = subprocess.check_output(['git', 'show', '845dd234:src/client/K0MeleeMotion.luau']).decode()
code += 'local previousKnightMotionSource='+json.dumps(previous, ensure_ascii=False)+'\n'
suites = ['tests/knight-reference-combo-native.luau', 'tests/k0-melee-curves-native.luau',
          'tests/dwarf-basic-tempo-native.luau', 'tests/dwarf-recovery-native.luau', 'tests/mixamo-knight-native.luau']

def lua(value):
    if isinstance(value, dict): return '{'+','.join('['+json.dumps(k)+']='+lua(v) for k, v in value.items())+'}'
    if isinstance(value, list): return '{'+','.join(map(lua, value))+'}'
    return json.dumps(value)

for path in suites:
    prefix = ''
    if 'mixamo-knight' in path:
        prefix = 'local knightGolden='+lua(json.loads(Path('assets/animations/mixamo-knight-v1/blender-golden.json').read_text()))+'\n'
    code += 'do\n'+prefix+Path(path).read_text()+'\nend\n'
code += "print('KNIGHT_REFERENCE_ALL_PASS')\n"
out = Path('/tmp/tlt-knight-reference-combo-native.luau')
out.write_text(code)
inputs = paths+suites+['src/shared/K0Config.luau', 'src/server/Combat/CombatService.luau', 'assets/animations/knight-reference-combo-v1/sweep-poses.json', 'tools/author-knight-reference-combo.py', 'tools/solve-knight-sweep-native.luau', 'tools/prepare-knight-reference-combo-native.py']
out.with_suffix('.inputs.json').write_text(json.dumps({p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in inputs}, indent=2)+'\n')
print(out)
