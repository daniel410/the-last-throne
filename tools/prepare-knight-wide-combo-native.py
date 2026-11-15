"""기존 전체 기사 회귀와 고정 원본 대비 실제 검끝/몸통 확대 검사를 준비한다."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys


BASELINE_COMMIT = '6bd625ce6f69339726194e26143458c9e13ed536'
ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--fixed', action='store_true')
parser.add_argument('--measure-only', action='store_true', help='확대 수용 검사 없이 원본/후보 계측만 기록한다')
args = parser.parse_args()

# 기존 suite와 판정 상한은 변경하지 않는다. --fixed는 후보 주입을 금지한다.
prepare = [sys.executable, str(ROOT / 'tools/prepare-knight-reference-combo-native.py')]
if args.fixed:
    prepare.append('--fixed')
subprocess.run(prepare, cwd=ROOT, check=True)
previous = Path('/tmp/tlt-knight-reference-combo-native.luau')
code = previous.read_text()
inputs = json.loads(previous.with_suffix('.inputs.json').read_text())

names = {
    'K0Config': 'KnightWideBaselineConfig',
    'K0KnightReferenceDowncut': 'KnightWideBaselineDowncut',
    'K0KnightReferenceRisingCut': 'KnightWideBaselineRisingCut',
    'K0KnightReferenceSweep': 'KnightWideBaselineSweep',
    'K0KnightReferenceCombo': 'KnightWideBaselineCombo',
    'K0MeleeMotion': 'KnightWideBaselineMotion',
    'K0SwordVisual': 'KnightWideBaselineVisual',
}
baseline_hashes = {}
code += '\ndo\nlocal p=game.StarterPlayer.StarterPlayerScripts.Client\n'
for original, name in names.items():
    path = f'src/{"shared" if original == "K0Config" else "client"}/{original}.luau'
    source = subprocess.check_output(['git', 'show', f'{BASELINE_COMMIT}:{path}'], cwd=ROOT).decode()
    baseline_hashes[path] = hashlib.sha256(source.encode()).hexdigest()
    if original == 'K0KnightReferenceCombo':
        for child in ['Downcut', 'RisingCut', 'Sweep']:
            source = source.replace(f'script.Parent.K0KnightReference{child}', f'script.Parent.{names["K0KnightReference" + child]}')
    if original == 'K0MeleeMotion':
        source = source.replace('script.Parent.K0KnightReferenceCombo', f'script.Parent.{names["K0KnightReferenceCombo"]}')
    if original in ['K0MeleeMotion', 'K0SwordVisual']:
        source = source.replace('game:GetService("ReplicatedStorage").Shared.K0Config', f'script.Parent.{names["K0Config"]}')
    if original == 'K0SwordVisual':
        source = source.replace('script.Parent.K0MeleeMotion', f'script.Parent.{names["K0MeleeMotion"]}')
    code += f'do local m=Instance.new("ModuleScript");m.Name={json.dumps(name)};m.Source={json.dumps(source, ensure_ascii=False)};m.Parent=p end\n'
code += 'end\n'
code += f'local knightWideBaselineCommit={json.dumps(BASELINE_COMMIT)}\n'
code += f'local knightWideMeasurementOnly={str(args.measure_only).lower()}\n'
suite = 'tests/knight-wide-combo-native.luau'
code += 'do\n' + (ROOT / suite).read_text() + '\nend\n'
code += "print('KNIGHT_WIDE_COMBO_ALL_PASS')\n"
out = Path('/tmp/tlt-knight-wide-combo-native.luau')
out.write_text(code)
for path in [suite, 'tools/prepare-knight-wide-combo-native.py', 'src/client/K0SwordVisual.luau']:
    inputs[path] = hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
out.with_suffix('.inputs.json').write_text(json.dumps({
    'candidate': inputs, 'baselineCommit': BASELINE_COMMIT,
    'baseline': baseline_hashes, 'measurementOnly': args.measure_only,
}, indent=2) + '\n')
print(out)
