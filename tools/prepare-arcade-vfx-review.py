"""TLT-033/057: 고정 소스와 두 VFX 후보만으로 격리 엔진·전후 캡처 장소를 만든다."""
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
parser.add_argument('--capture', action='store_true')
args = parser.parse_args()
out = args.output.resolve()
command = ['python3', str(ROOT / 'tools/prepare-vfx-art-improvements.py'),
           '--source', args.source, '--output', str(out)]
if args.capture:
    command += ['--capture', str(ROOT / 'tools/capture-arcade-vfx-review.luau')]
subprocess.run(command, cwd=ROOT, check=True)
provenance = json.loads((out / 'provenance.json').read_text())
source = Path(provenance['sourceRoot'])
# Baseline is taken from the exact source commit, before candidate overlays.
if args.capture:
    (source / 'src/client/HeroVFXBefore.luau').write_bytes((source / 'src/client/HeroVFX.luau').read_bytes())
changed = ['src/client/HeroVFX.luau', 'src/client/K0HitEffects.luau',
           'tests/arcade-impact-vfx-native.luau']
overlays = {}
if args.candidate:
    for relative in changed:
        data = (ROOT / relative).read_bytes()
        (source / relative).write_bytes(data)
        overlays[relative] = hashlib.sha256(data).hexdigest()
if not args.capture:
    probe = out / 'probe.luau'
    probe.write_text(probe.read_text() + '\nlocal function arcade()\n'
                     + (source / changed[-1]).read_text() + '\nend\narcade()\n')
subprocess.run(['rojo', 'build', str(out / 'qa.project.json'), '-o', str(out / 'qa.rbxlx')], check=True)
inputs = json.loads((out / 'inputs.json').read_text())
for relative in changed:
    if (source / relative).exists():
        inputs[relative] = hashlib.sha256((source / relative).read_bytes()).hexdigest()
(out / 'inputs.json').write_text(json.dumps(inputs, indent=2) + '\n')
provenance.update(candidateOverlays=overlays,
                  probeSha256=hashlib.sha256((out / 'probe.luau').read_bytes()).hexdigest(),
                  placeSha256=hashlib.sha256((out / 'qa.rbxlx').read_bytes()).hexdigest())
(out / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
