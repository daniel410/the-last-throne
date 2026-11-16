"""고정 커밋과 VFX 후보만으로 전수 검사/동일 조건 전후 비교 장소를 만든다."""
from pathlib import Path
import argparse, hashlib, io, json, subprocess, tarfile

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', default='HEAD')
p.add_argument('--output', type=Path, required=True)
p.add_argument('--capture', type=Path)
p.add_argument('--candidate', action='store_true', help='명시된 런타임 VFX 변경만 덮는다')
a = p.parse_args()
out = a.output.resolve(); out.mkdir(parents=True, exist_ok=True)
source = out / 'source'; source.mkdir(exist_ok=True)
commit = subprocess.check_output(['git', 'rev-parse', a.source], cwd=ROOT, text=True).strip()
project = json.loads(subprocess.check_output(['git', 'show', commit + ':default.project.json'], cwd=ROOT))
assets = project['tree']['ServerStorage']
paths = ['src', 'default.project.json'] + [v['$path'] for v in assets.values()]
with tarfile.open(fileobj=io.BytesIO(subprocess.check_output(['git', 'archive', commit, '--', *paths], cwd=ROOT))) as stream:
    stream.extractall(source, filter='data')
for file in source.rglob('*'):
    if file.is_file() and file.read_bytes().startswith(b'version https://git-lfs.github.com/spec/v1\n'):
        file.write_bytes(subprocess.check_output(['git', 'lfs', 'smudge'], input=file.read_bytes(), cwd=ROOT))
overlays = ['CombatVFXStyle', 'HeroVFX', 'HeroVFXArt', 'HeroVFXPolish', 'HeroVFXSurfaces', 'PixelFX', 'WindLanceVisual', 'K0SwordVisual', 'K0EnemyWeaponMotion',
            'EnemySpellArt', 'EnemySpellVFX', 'SelenePresentation', 'K0MageFocus']
frozen = [name for name in overlays + ['AdvancedSkillVisual',
          'SkillIconVFX', 'SkillVFXProfiles'] if (source / f'src/client/{name}.luau').exists()]
for name in frozen:
    data = (source / f'src/client/{name}.luau').read_text()
    for dependency in frozen:
        data = data.replace(f'script.Parent.{dependency})', f'script.Parent.{dependency}Before)')
    (source / f'src/client/{name}Before.luau').write_text(data)
if a.candidate:
    for name in overlays:
        (source / f'src/client/{name}.luau').write_bytes((ROOT / f'src/client/{name}.luau').read_bytes())
for row in assets.values(): row['$path'] = str(source / row['$path'])
fixture = {'name': 'RobloxVFXPolishQA', 'tree': {'$className': 'DataModel',
    'ReplicatedStorage': {'Shared': {'$path': str(source / 'src/shared')}},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': {'$path': str(source / 'src/client')}}},
    'Players': {'$properties': {'CharacterAutoLoads': False}},
    'ServerScriptService': {'Server': {'$path': str(source / 'src/server')},
        'HeroLevelUpEffect': {'$path': str(source / 'src/server/Combat/HeroLevelUpEffect.luau')}},
    'ServerStorage': assets}}
(out / 'qa.project.json').write_text(json.dumps(fixture, indent=2)+'\n')
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
names = ['rpg-vfx-gap', 'roblox-vfx-polish', 'skill-vfx-art', 'skill-icon-vfx', 'vfx-art-hero-fixes',
         'vfx-art-enemy-fixes', 'vfx-art-support-fixes', 'vfx-art-palette', 'vfx-review-followup',
         'arcade-impact-vfx', 'rpg-element-motion', 'rpg-vfx-motion', 'element-vfx', 'wow-vfx',
         'vfx-style-fit', 'curated-vfx', 'pixelfx', 'hero-vfx', 'wind-lance-visual',
         'skill-vfx-individual', 'hero-vfx-flourish', 'k0-hit-effects', 'monster-spell-vfx']
suites = [a.capture.resolve()] if a.capture else [ROOT / f'tests/{name}-native.luau' for name in names]
prefix = "assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')\nfor _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end\n"
probe = prefix + '\n'.join('local function review()\n'+f.read_text()+'\nend\nreview()' for f in suites)
(out / 'probe.luau').write_text(probe)
inputs = {str(f.relative_to(source)): hashlib.sha256(f.read_bytes()).hexdigest()
          for f in (source / 'src').rglob('*.luau')}
(out / 'provenance.json').write_text(json.dumps({'sourceCommit': commit, 'candidateOverlays': overlays if a.candidate else [],
    'frozenModules': frozen, 'inputs': inputs,
    'tests': {str(f): hashlib.sha256(f.read_bytes()).hexdigest() for f in suites},
    'probeSha256': hashlib.sha256(probe.encode()).hexdigest(),
    'fixtureSha256': hashlib.sha256((out / 'qa.rbxlx').read_bytes()).hexdigest()}, indent=2)+'\n')
print(f'run-in-roblox --place {out / "qa.rbxlx"} --script {out / "probe.luau"}')
