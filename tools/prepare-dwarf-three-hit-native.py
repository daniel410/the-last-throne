"""격리된 기존 빌드에 드워프3타 후보를 주입하고 원천/시험 해시를 고정한다."""
from pathlib import Path
import argparse
import hashlib
import json

parser = argparse.ArgumentParser()
parser.add_argument('--fixed', action='store_true')
args = parser.parse_args()
paths = ['src/shared/K0Config.luau', 'src/client/K0MeleeMotion.luau', 'src/client/K0DwarfMixamoClips.luau']
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated host only')\n"
for path in paths:
    p = Path(path)
    root = 'game.ReplicatedStorage.Shared' if p.parts[1] == 'shared' else 'game.StarterPlayer.StarterPlayerScripts.Client'
    source = json.dumps(p.read_text(), ensure_ascii=False)
    code += f'assert({root}.{p.stem}.Source=={source},"source mismatch {p.stem}")\n' if args.fixed else f'{root}.{p.stem}.Source={source}\n'
code += """for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end
end
print('DWARF_THREE_HIT_COMPILE_PASS')
"""
suites = ['tests/dwarf-basic-tempo-native.luau', 'tests/k0-basic-attacks-native.luau',
          'tests/k0-melee-curves-native.luau', 'tests/dwarf-recovery-native.luau', 'tests/dwarf-axe-throw-native.luau']
for path in suites:
    suite = Path(path).read_text()
    if 'k0-basic-attacks' in path:
        marker = 'local function case(name, body)\n'
        assert suite.count(marker) == 1
        suite = suite.replace(marker, marker + " if not(name:match('^dwarf')or name:match('^targeted%-dwarf')or name:match('^knight%-reach')or name=='targeted-knight-turns-and-hits-selected')then return end\n")
    code += 'do\n' + suite + '\nend\n'
code += "print('DWARF_THREE_HIT_ALL_PASS')\n"
out = Path('/tmp/tlt-dwarf-three-hit-native.luau')
out.write_text(code)
inputs = paths + suites + ['src/server/Combat/CombatService.luau', 'src/client/K0DwarfMixamoBasic.luau',
                         'src/client/K0DwarfMixamoSkills.luau', 'tools/prepare-dwarf-three-hit-native.py']
out.with_suffix('.inputs.json').write_text(json.dumps({p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in inputs}, indent=2) + '\n')
print(out)
