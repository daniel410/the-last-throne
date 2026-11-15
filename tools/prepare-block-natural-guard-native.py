"""격리 후보/고정 빌드의 자연스러운 양손 방어와 기존 전투 회귀를 준비한다."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
BASELINE_COMMIT = 'eda125e7b447502422a5b552df8d666fa2e280dc'
parser = argparse.ArgumentParser()
parser.add_argument('--fixed', action='store_true')
args = parser.parse_args()
paths = ['src/client/K0BlockMotion.luau', 'src/client/K0SwordVisual.luau']
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated unpublished host only')\n"
for path in paths:
    source = json.dumps((ROOT / path).read_text(), ensure_ascii=False)
    name = Path(path).stem
    parent = 'game.StarterPlayer.StarterPlayerScripts.Client'
    if args.fixed:
        code += f'assert({parent}.{name}.Source=={source},"source mismatch {name}")\n'
    else:
        code += f'do local p={parent};local m=p:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={source};m.Parent=p end\n'

# 기존 기사/드워프 곡선·서버 예산 전체 회귀를 원문 그대로 실행한다.
command = [sys.executable, str(ROOT / 'tools/prepare-knight-wide-combo-native.py')]
if args.fixed:
    command.append('--fixed')
subprocess.run(command, cwd=ROOT, check=True)
previous = Path('/tmp/tlt-knight-wide-combo-native.luau')
code += previous.read_text()
baseline = subprocess.check_output(['git', 'show', f'{BASELINE_COMMIT}:src/client/K0SwordVisual.luau'], cwd=ROOT).decode()
code += '\ndo local p=game.StarterPlayer.StarterPlayerScripts.Client;local m=Instance.new("ModuleScript");m.Name="BlockNaturalBaselineVisual";m.Source='+json.dumps(baseline, ensure_ascii=False)+';m.Parent=p end\n'
code += 'local blockNaturalBaselineCommit='+json.dumps(BASELINE_COMMIT)+'\n'
immutable = ['src/shared/K0Config.luau', 'src/server/Combat/CombatService.luau', 'src/server/Cosmetics/WeaponAppearance.luau']
for path in immutable:
    original = subprocess.check_output(['git', 'show', f'{BASELINE_COMMIT}:{path}'], cwd=ROOT).decode()
    assert (ROOT / path).read_text() == original, f'guard presentation cannot change {path}'
    if path.startswith('src/shared/'):
        location = 'game.ReplicatedStorage.Shared.'+Path(path).stem
    elif 'Cosmetics' in path:
        location = 'game.ServerScriptService.Server.Cosmetics.'+Path(path).stem
    else:
        location = 'game.ServerScriptService.Server.Combat.'+Path(path).stem
    code += f'assert({location}.Source=={json.dumps(original, ensure_ascii=False)},"immutable guard source {Path(path).stem}")\n'
suite = 'tests/block-natural-guard-native.luau'
code += 'do\n'+(ROOT / suite).read_text()+'\nend\n'
runtime_suite = 'tests/block-natural-runtime-native.luau'
code += 'do\n'+(ROOT / runtime_suite).read_text()+'\nend\n'
code += "print('BLOCK_NATURAL_GUARD_ALL_PASS')\n"
out = Path('/tmp/tlt-block-natural-guard-native.luau')
out.write_text(code)
inputs = json.loads(previous.with_suffix('.inputs.json').read_text())
inputs['blockNaturalGuard'] = {
    'baselineCommit': BASELINE_COMMIT,
    'baselineVisualSha256': hashlib.sha256(baseline.encode()).hexdigest(),
    'sources': {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest()
                for path in paths+immutable+[suite, runtime_suite, 'tools/prepare-block-natural-guard-native.py']},
}
out.with_suffix('.inputs.json').write_text(json.dumps(inputs, indent=2)+'\n')
print(out)
