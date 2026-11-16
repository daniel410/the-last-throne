"""격리 Studio 검증 또는 자세 캡처 스크립트를 만든다."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--capture', choices=['motion','catalog'])
parser.add_argument('--ranged', action='store_true', help='엘프와 마법사 검토')
args = parser.parse_args()
if args.capture:
    helper = (root / 'tools/review-hero-skills-studio.luau').read_text()
    script = ('do local m=Instance.new("ModuleScript");m.Name="HeroReviewRigs";m.Source='
              + json.dumps(helper, ensure_ascii=False) + ';m.Parent=game.ServerStorage end\n')
    if args.ranged:
        script += '_G.RangedActions=true\n'
    if args.capture == 'catalog':
        script += '_G.MeleeCatalog=true\n'
    script += (root / 'tools/capture-melee-actions.luau').read_text()
    target = Path('/tmp/tlt-melee-actions-capture.luau')
elif args.ranged:
    script = 'assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n'
    for name in ['RangedActionPoses', 'K0BowMotion', 'K0MageMotion', 'K0SwordVisual']:
        source = (root / 'src/client' / (name+'.luau')).read_text()
        script += f'assert(game.StarterPlayer.StarterPlayerScripts.Client.{name}.Source=={json.dumps(source)})\n'
    fixtures = {}
    for suite, binding, asset in [('k0-elf-bow-native', 'BowGolden', 'elf-bow-golden'),
                                  ('k0-mage-staff-native', 'MageGolden', 'mage-staff-golden')]:
        golden = (root/'tests'/(asset+'.luau')).read_text()
        fixtures[suite] = f'local {binding} = (function()\n{golden}\nend)()\n'
    golden = (root/'assets/animations/mixamo-elf-v1/blender-golden.json').read_text()
    fixtures['mixamo-elf-native'] = 'local elfGolden=game.HttpService:JSONDecode([==['+golden+']==])\n'
    suites = [*fixtures, 'elf-confirmed-release-native', 'elf-quiver-native', 'elf-basic-tempo-native',
              'elf-straight-shot-native', 'magic-shot-direction-native', 'ranged-action-poses-native', 'hero-skills-native']
    for suite in suites:
        source = (root/'tests'/(suite+'.luau')).read_text()
        script += 'do local function run()\n'+fixtures.get(suite, '')+source+'\nend\nlocal r=run();assert(not r or r.pass) end\n'
    script += 'print("RANGED_ACTIONS_ALL_PASS")\n'
    target = Path('/tmp/tlt-ranged-native.luau')
else:
    subprocess.run([sys.executable, 'tools/prepare-knight-wide-combo-native.py', '--fixed'], cwd=root, check=True)
    script = Path('/tmp/tlt-knight-wide-combo-native.luau').read_text()
    for name in ['AdvancedSkillMotion', 'AdvancedSkillVisual', 'K0KnightSkillThrust', 'K0SwordVisual', 'MeleeWeightShift']:
        source = (root / 'src/client' / (name+'.luau')).read_text()
        script += f'\nassert(game.StarterPlayer.StarterPlayerScripts.Client.{name}.Source=={json.dumps(source, ensure_ascii=False)})\n'
    suites = ['melee-action-beats-native', 'hero-skill-sockets-native', 'shield-bash-leading-native', 'hero-skills-native']
    for suite in suites:
        source = (root / 'tests' / (suite+'.luau')).read_text()
        script += '\ndo local function run()\n'+source+'\nend\nlocal result=run();assert(not result or result.pass) end\n'
    script += 'print("MELEE_ACTIONS_ALL_PASS")\n'
    target = Path('/tmp/tlt-melee-actions-native.luau')
target.write_text(script)
print(target)
