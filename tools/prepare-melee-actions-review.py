"""격리 Studio 검증 또는 자세 캡처 스크립트를 만든다."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--capture', choices=['motion','catalog'])
args = parser.parse_args()
if args.capture:
    helper = (root / 'tools/review-hero-skills-studio.luau').read_text()
    script = ('do local m=Instance.new("ModuleScript");m.Name="HeroReviewRigs";m.Source='
              + json.dumps(helper, ensure_ascii=False) + ';m.Parent=game.ServerStorage end\n')
    if args.capture == 'catalog':
        script += '_G.MeleeCatalog=true\n'
    script += (root / 'tools/capture-melee-actions.luau').read_text()
    target = Path('/tmp/tlt-melee-actions-capture.luau')
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
