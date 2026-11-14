"""커밋 기반 VFX 격리 장소를 준비한다. --candidate는 작업 VFX 두 모듈만 덮는다."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--candidate', action='store_true')
parser.add_argument('--capture', type=Path)
args = parser.parse_args()
output = args.output.resolve()
command = ['python3', str(ROOT / 'tools/prepare-vfx-art-improvements.py'),
           '--source', args.source, '--output', str(output)]
if args.capture:
    command += ['--capture', str(args.capture.resolve())]
subprocess.run(command, cwd=ROOT, check=True)
provenance = json.loads((output / 'provenance.json').read_text())
source = Path(provenance['sourceRoot'])
overlays = {}
if args.candidate:
    for relative in ['src/client/HeroVFX.luau', 'src/client/EnemyPatternEffects.luau',
                     'tests/vfx-review-followup-native.luau']:
        data = (ROOT / relative).read_bytes()
        (source / relative).write_bytes(data)
        overlays[relative] = hashlib.sha256(data).hexdigest()
    subprocess.run(['rojo', 'build', str(output / 'qa.project.json'),
                    '-o', str(output / 'qa.rbxlx')], check=True)
if not args.capture:
    followup = (source / 'tests/vfx-review-followup-native.luau').read_text()
    probe = output / 'probe.luau'
    probe.write_text(probe.read_text() + '\nlocal function followup()\n' + followup + '\nend\nfollowup()\n')
inputs = json.loads((output / 'inputs.json').read_text())
for relative in ['src/client/HeroVFX.luau', 'src/client/EnemyPatternEffects.luau',
                 'tests/vfx-review-followup-native.luau']:
    if (source / relative).exists():
        inputs[relative] = hashlib.sha256((source / relative).read_bytes()).hexdigest()
(output / 'inputs.json').write_text(json.dumps(inputs, indent=2) + '\n')
provenance.update(candidateOverlays=overlays,
                  probeSha256=hashlib.sha256((output / 'probe.luau').read_bytes()).hexdigest(),
                  placeSha256=hashlib.sha256((output / 'qa.rbxlx').read_bytes()).hexdigest())
(output / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
