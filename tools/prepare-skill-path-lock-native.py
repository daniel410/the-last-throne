"""HEAD와 작업 파일만 동결해 저장/네트워크 없는 UI 검증 Place를 만든다."""
from pathlib import Path
import argparse
import hashlib
import io
import json
import subprocess
import tarfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root).decode().strip()
archive = subprocess.check_output(['git', 'archive', commit, 'src'], cwd=root)
with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
    tar.extractall(out, filter='data')
owned = ['src/client/HeroSkillTree.luau', 'src/client/SkillAdvancementView.luau',
         'src/shared/AdvancementText.luau']
for name in owned:
    (out / name).write_bytes((root / name).read_bytes())
project = {'name': 'PathLockQA', 'tree': {'$className': 'DataModel',
    'ReplicatedStorage': {'Shared': {'$path': 'src/shared'}},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': {'$path': 'src/client'}}}}}
(out / 'qa.project.json').write_text(json.dumps(project))
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
suite = (root / 'tests/skill-advancement-native.luau').read_text()
(out / 'probe.luau').write_text('local result=(function()\n' + suite +
    "\nend)()\nprint(game:GetService('HttpService'):JSONEncode(result))\nassert(result.pass,result.error)\nreturn result\n")
manifest = {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in (out / 'src').rglob('*') if p.is_file()}
(out / 'inputs.json').write_text(json.dumps({'baseline': commit, 'overlay': owned,
    'sha256': manifest, 'probeSha256': hashlib.sha256((out / 'probe.luau').read_bytes()).hexdigest()}, indent=2) + '\n')
print(out)
