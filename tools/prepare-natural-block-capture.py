"""격리 Studio의 고정 원본/현재 방어 자세를 비교하는 네이티브 캡처를 준비한다."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASELINE = 'eda125e7b447502422a5b552df8d666fa2e280dc'
parser = argparse.ArgumentParser()
parser.add_argument('--baseline-only', action='store_true')
parser.add_argument('--fixed', action='store_true')
parser.add_argument('--module', action='append', default=[])
parser.add_argument('--class-id', choices=['elf', 'dwarf', 'mage'])
parser.add_argument('--rig', choices=['R6', 'R15'], default='R15')
parser.add_argument('--width', type=int, default=1280)
parser.add_argument('--output', type=Path, default=Path('/tmp/tlt-natural-block-capture.luau'))
args = parser.parse_args()

code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated empty host only')\n"
code += "for _,root in {game.ServerScriptService,game.StarterPlayer,game.ReplicatedFirst}do for _,n in root:GetDescendants()do if n:IsA('Script')or n:IsA('LocalScript')then n.Disabled=true end end end\n"
visual_path = 'src/client/K0SwordVisual.luau'
baseline = subprocess.check_output(['git', 'show', f'{BASELINE}:{visual_path}'], cwd=ROOT).decode()
code += 'do local m=Instance.new("ModuleScript");m.Name="NaturalBlockBaselineVisual";m.Source='+json.dumps(baseline, ensure_ascii=False)+';m.Parent=game.StarterPlayer.StarterPlayerScripts.Client end\n'
inputs = {}
paths = [] if args.baseline_only else [ROOT/visual_path, *sorted((ROOT/'src/client').glob('K0Block*.luau'))]
paths += [ROOT/path for path in args.module]
for path in dict.fromkeys(paths):
    text = path.read_text()
    inputs[str(path.relative_to(ROOT))] = hashlib.sha256(text.encode()).hexdigest()
    source = json.dumps(text, ensure_ascii=False)
    if args.fixed:
        code += f'assert(game.StarterPlayer.StarterPlayerScripts.Client.{path.stem}.Source=={source},"fixed source mismatch {path.stem}")\n'
    else:
        code += f'do local p=game.StarterPlayer.StarterPlayerScripts.Client;local m=p:FindFirstChild("{path.stem}")or Instance.new("ModuleScript");m.Name="{path.stem}";m.Source={source};m.Parent=p end\n'
code += '_G.NaturalBlockBaselineOnly='+str(args.baseline_only).lower()+'\n'
code += '_G.NaturalBlockCaptureRig='+json.dumps(args.rig)+'\n'
code += '_G.NaturalBlockCaptureWidth='+str(args.width)+'\n'
if args.class_id:
    code += '_G.NaturalBlockCaptureClass='+json.dumps(args.class_id)+'\n'
capture = ROOT/'tools/capture-natural-block.luau'
code += capture.read_text()
args.output.write_text(code)
inputs[str(capture.relative_to(ROOT))] = hashlib.sha256(capture.read_bytes()).hexdigest()
args.output.with_suffix('.inputs.json').write_text(json.dumps({
    'baselineCommit': BASELINE, 'baselineVisualSha256': hashlib.sha256(baseline.encode()).hexdigest(),
    'baselineOnly': args.baseline_only, 'fixed': args.fixed, 'rig': args.rig, 'inputs': inputs,
}, indent=2)+'\n')
print(args.output)
