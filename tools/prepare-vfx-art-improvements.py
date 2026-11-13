"""VFX 후속의 계정/저장 없는 엔진 검사·공유 자산 검토 fixture를 준비한다."""
from pathlib import Path
import argparse, hashlib, io, json, subprocess, tarfile, tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--capture', type=Path)
parser.add_argument('--source', help='검증된 커밋만 고정해 별도 사용자 미커밋 변경을 제외한다')
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
source_root=root
commit=None
if args.source:
    commit=subprocess.check_output(['git','rev-parse',args.source],cwd=root).decode().strip()
    fixed=json.loads(subprocess.check_output(['git','show',commit+':default.project.json'],cwd=root))
    paths=['src','tests','default.project.json']+[row['$path'] for row in fixed['tree']['ServerStorage'].values()]
    archive=subprocess.check_output(['git','archive',commit,'--',*paths],cwd=root)
    source_root=Path(tempfile.mkdtemp(prefix='tlt-vfx-art-fixed-'))
    with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
        stream.extractall(source_root,filter='data')
    for path in source_root.rglob('*'):
        if path.is_file() and path.read_bytes().startswith(b'version https://git-lfs.github.com/spec/v1\n'):
            path.write_bytes(subprocess.check_output(['git','lfs','smudge'],input=path.read_bytes(),cwd=root))
assets = json.loads((source_root / 'default.project.json').read_text())['tree']['ServerStorage']
for entry in assets.values():
    entry['$path'] = str(source_root / entry['$path'])
project = {'name': 'VFXArtImprovementsQA', 'tree': {'$className': 'DataModel',
    'ReplicatedStorage': {'Shared': {'$path': str(source_root / 'src/shared')}},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': {'$path': str(source_root / 'src/client')}}},
    'Players': {'$properties': {'CharacterAutoLoads': False}},
    'ServerScriptService': {'Server': {'$path': str(source_root / 'src/server')},
                           'HeroLevelUpEffect': {'$path': str(source_root / 'src/server/Combat/HeroLevelUpEffect.luau')}},
    'ServerStorage': assets}}
(out / 'qa.project.json').write_text(json.dumps(project, indent=2) + '\n')
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
prefix = "assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\n"
names = ['vfx-art-palette', 'vfx-art-hero-fixes', 'vfx-art-enemy-fixes', 'vfx-art-support-fixes',
         'rpg-element-motion', 'rpg-vfx-motion', 'element-vfx', 'wow-vfx', 'vfx-style-fit',
         'curated-vfx', 'pixelfx', 'hero-vfx', 'wind-lance-visual', 'skill-vfx-individual',
         'hero-vfx-flourish', 'k0-hit-effects', 'monster-spell-vfx']
suites = [source_root / ('tests/' + name + '-native.luau') for name in names]
if args.capture:
    suites = [args.capture.resolve()]
code = prefix + '\n'.join('local function review()\n' + path.read_text() + '\nend\nreview()' for path in suites)
(out / 'probe.luau').write_text(code)
paths = [p for directory in ['src/client', 'src/shared', 'src/server'] for p in (source_root / directory).rglob('*.luau')]
if not args.capture:
    paths += suites
for row in assets.values():
    paths.append(Path(row['$path']))
inputs = {str(p.relative_to(source_root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(out / 'inputs.json').write_text(json.dumps(inputs, indent=2) + '\n')
(out / 'provenance.json').write_text(json.dumps({'sourceCommit':commit,'sourceRoot':str(source_root),
    'captureScript':str(args.capture)if args.capture else None,
    'captureScriptSha256':hashlib.sha256(args.capture.read_bytes()).hexdigest()if args.capture else None,
    'gameplayScriptsDisabled':True},indent=2)+'\n')
print('run-in-roblox --place', out / 'qa.rbxlx', '--script', out / 'probe.luau')
