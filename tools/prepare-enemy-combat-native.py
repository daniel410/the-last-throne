"""계정·시작 스크립트 없는 몬스터 전투 엔진 fixture를 만든다. 게시하지 않는다."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--asset-root', type=Path, default=root)
args = parser.parse_args()
asset_root = args.asset_root.resolve()
out = Path('/tmp/tlt-enemy-combat-20261115')
out.mkdir(exist_ok=True)

def modules(folder):
    if (folder / 'init.luau').exists():
        return {'$path': str(folder)}
    node = {'$className': 'Folder'}
    for path in sorted(folder.iterdir()):
        if path.is_dir():
            node[path.name] = modules(path)
        elif path.suffix == '.luau' and not path.name.endswith(('.server.luau', '.client.luau')):
            node[path.stem] = {'$path': str(path)}
    return node

project = {'name': 'EnemyCombatQA', 'tree': {'$className': 'DataModel',
    'ReplicatedStorage': {'Shared': modules(root / 'src/shared')},
    'ServerScriptService': {'Server': modules(root / 'src/server')},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': modules(root / 'src/client')}}}}
# 기존 실제 스킨을 포함해 모델·모션 회귀를 함께 검사한다.
project['tree']['ServerStorage'] = {'GloamwoodMeshyModels': {'$path': str(asset_root / 'assets/models/venomcoil-king-v2/runtime.rbxm')}}
(out / 'qa.project.json').write_text(json.dumps(project, indent=2) + '\n')
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
tests = ['tests/enemy-combat-native.luau', 'tests/enemy-combat-presentation-native.luau', 'tests/enemy-combat-movement-cases.luau']
for tool in ['assemble-enemy-pattern-test.py', 'assemble-enemy-pattern-service-test.py']:
    subprocess.run(['python3', str(root / 'tools' / tool)], cwd=root, check=True)
parts = [Path('/tmp/tlt-enemy-patterns-native.luau').read_text(),
         (root / tests[0]).read_text(), (root / tests[1]).read_text(),
         Path('/tmp/tlt-enemy-pattern-service-native.luau').read_text()]
(out / 'all-native.luau').write_text('\n'.join('do\n' + code + '\nend' for code in parts) + "\nprint('ENEMY_COMBAT_ALL_PASS')\n")
paths = list((root / 'src').rglob('*.luau')) + [root / name for name in tests]
asset = asset_root / 'assets/models/venomcoil-king-v2/runtime.rbxm'
manifest = {'sources': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
            'assets': {str(asset.relative_to(asset_root)): hashlib.sha256(asset.read_bytes()).hexdigest()},
            'fixtureSha256': hashlib.sha256((out / 'qa.rbxlx').read_bytes()).hexdigest(),
            'probeSha256': hashlib.sha256((out / 'all-native.luau').read_bytes()).hexdigest()}
(out / 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
print('run-in-roblox --place', out / 'qa.rbxlx', '--script', out / 'all-native.luau')
