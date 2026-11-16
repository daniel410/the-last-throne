"""커밋 기반 소스와 이번 VFX 변경만으로 계정/저장 없는 검증 장소를 준비한다."""
from pathlib import Path
import argparse
import hashlib
import io
import json
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--source', default='HEAD')
p.add_argument('--output', type=Path, required=True)
p.add_argument('--capture', type=Path)
a = p.parse_args()
out = a.output.resolve()
out.mkdir(parents=True, exist_ok=True)
commit = subprocess.check_output(['git', 'rev-parse', a.source], cwd=ROOT, text=True).strip()
source = out / 'source'
source.mkdir(exist_ok=True)
archive = subprocess.check_output(['git', 'archive', commit, '--', 'src'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    stream.extractall(source, filter='data')
for name in ['HeroVFX', 'WindLanceVisual', 'AdvancedSkillVisual', 'SkillIconVFX', 'PixelFX', 'HeroVFXSurfaces']:
    data=(source / f'src/client/{name}.luau').read_text()
    if name=='HeroVFX':
        data=data.replace('script.Parent.SkillVFXProfiles)', 'script.Parent.SkillVFXProfilesBefore)').replace('script.Parent.SkillIconVFX)', 'script.Parent.SkillIconVFXBefore)').replace('script.Parent.HeroVFXSurfaces)', 'script.Parent.HeroVFXSurfacesBefore)')
    if name=='WindLanceVisual':
        data=data.replace('script.Parent.HeroVFXSurfaces)', 'script.Parent.HeroVFXSurfacesBefore)')
    if name=='AdvancedSkillVisual':
        data=data.replace('script.Parent.HeroVFX)', 'script.Parent.HeroVFXBefore)').replace('script.Parent.WindLanceVisual)', 'script.Parent.WindLanceVisualBefore)').replace('script.Parent.PixelFX)', 'script.Parent.PixelFXBefore)')
    (source / f'src/client/{name}Before.luau').write_text(data)
(source / 'src/client/SkillVFXProfilesBefore.luau').write_bytes((source / 'src/client/SkillVFXProfiles.luau').read_bytes())
overlays = ['src/client/HeroVFX.luau', 'src/client/WindLanceVisual.luau',
            'src/client/SkillIconVFX.luau', 'src/client/SkillIconVFXProfiles.luau',
            'src/client/SkillVFXProfiles.luau', 'src/client/HeroVFXArt.luau',
            'src/client/HeroVFXSurfaces.luau', 'src/client/AdvancedSkillVisual.luau',
            'src/client/PixelFX.luau']
for relative in overlays:
    (source / relative).write_bytes((ROOT / relative).read_bytes())
project = {'name': 'SkillIconVFXQA', 'tree': {'$className': 'DataModel',
    'ReplicatedStorage': {'Shared': {'$path': str(source / 'src/shared')}},
    'StarterPlayer': {'StarterPlayerScripts': {'Client': {'$path': str(source / 'src/client')}}}}}
(out / 'qa.project.json').write_text(json.dumps(project, indent=2) + '\n')
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
names = ['skill-vfx-art', 'skill-icon-vfx', 'vfx-art-hero-fixes', 'vfx-review-followup', 'arcade-impact-vfx',
         'rpg-element-motion', 'rpg-vfx-motion', 'element-vfx', 'wow-vfx', 'vfx-style-fit',
         'curated-vfx', 'pixelfx', 'hero-vfx', 'wind-lance-visual', 'skill-vfx-individual',
         'hero-vfx-flourish', 'k0-hit-effects']
# Enemy-specific followup needs the full asset fixture and is run separately.
names.remove('vfx-review-followup')
suites = [a.capture.resolve()] if a.capture else [ROOT / f'tests/{name}-native.luau' for name in names]
prefix = "assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')\n"
probe = prefix + '\n'.join('local function review()\n' + f.read_text() + '\nend\nreview()' for f in suites)
(out / 'probe.luau').write_text(probe)
inputs = {str(f.relative_to(source)): hashlib.sha256(f.read_bytes()).hexdigest()
          for f in (source / 'src').rglob('*.luau')}
(out / 'provenance.json').write_text(json.dumps({'sourceCommit': commit, 'candidateOverlays': overlays,
    'inputs': inputs, 'tests': {str(f): hashlib.sha256(f.read_bytes()).hexdigest() for f in suites},
    'probeSha256': hashlib.sha256(probe.encode()).hexdigest(),
    'fixtureSha256': hashlib.sha256((out / 'qa.rbxlx').read_bytes()).hexdigest()}, indent=2) + '\n')
print(f'run-in-roblox --place {out / "qa.rbxlx"} --script {out / "probe.luau"}')
