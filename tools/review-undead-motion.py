"""Prepare Standard-color native-matrix renders and measure actual mesh support."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/evidence/undead-motion-review-20261115'
p = argparse.ArgumentParser()
p.add_argument('--stage', choices=['before', 'after'], required=True)
stage = p.parse_args().stage
records = [json.loads(line.split(' ', 1)[1]) for line in (OUT / (stage+'-native.log')).read_text().splitlines() if line.startswith('HAUNTED_REVIEW ')]
assert {r['kind'] for r in records} == {'Zombie', 'Ghoul'}
(OUT / (stage+'.json')).write_text(json.dumps(records, separators=(',', ':'))+'\n')
spec = importlib.util.spec_from_file_location('mesh', ROOT / 'tools/repair-deepwood-weapons.py')
mesh = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mesh)
script = 'import bpy,json\n'
report = {}
body = (ROOT / 'tools/review-deepwood-model-blender.py').read_text()
body = body.replace("[('Walk',0),('Walk',.25),('Walk',.5),('Walk',.75),('Attack',.4),('Attack',.62),('Attack',.78)]", "[('Walk',0),('Walk',.25),('Walk',.5),('Walk',.75),('Attack',.4),('Attack',.62),('Attack',.78),('Heavy',.4),('Heavy',.62),('Heavy',.78)]")
for record in records:
    kind = record['kind']
    source = ROOT.parent / 'throne-defense/assets/models/zombie-ghoul-refresh-20261115/runtime-r3' / kind.lower() / 'textured-review.glb'
    # Verify the mesh-only companion against the adopted source provenance.
    import hashlib
    provenance = json.loads((ROOT / 'assets/animations/haunted-graveyard-v1/source-models.json').read_text())[kind]
    assert hashlib.sha256(source.with_name('mesh-only.glb').read_bytes()).hexdigest() == provenance['sha256']
    parts = {name.split('.')[0].split('__')[-1]: faces for name, faces in mesh.read(source).items()}
    local = {}
    for name, faces in parts.items():
        points = [v[0] for face in faces for v in face]
        lo = [min(v[i] for v in points) for i in range(3)]
        hi = [max(v[i] for v in points) for i in range(3)]
        # Match the existing renderer's source-to-native X/Z reversal.
        local[name] = [tuple((v[i]-(lo[i]+hi[i])/2)/(hi[i]-lo[i])*(-1 if i != 1 else 1) for i in range(3)) for v in points]
    floor = min(v['rest'][1]-v['size'][1]/2 for v in record['parts'].values())
    row = []
    for clip, frames in record['clips'].items():
        for frame in frames:
            minima = {}
            for name, pose in frame['parts'].items():
                cf, size = pose['cf'], pose['size']
                minima[name] = min(cf[1]+sum(cf[6+i]*v[i]*size[i] for i in range(3)) for v in local[name])-floor
            row.append({'clip': clip, 'phase': frame['phase'], 'minimumHeight': minima})
    report[kind] = row
    dest = OUT / kind
    dest.mkdir(exist_ok=True)
    script += 'REVIEW='+repr(record)+'\nREVIEW_STAGE='+repr(stage)+'\nSOURCE='+repr(str(source))+'\nREVIEW_OUT='+repr(str(dest))+'\n'+body+'\n'
(OUT / (stage+'-surface-support.json')).write_text(json.dumps(report, indent=2)+'\n')
Path('/tmp/tlt-undead-'+stage+'-render.py').write_text(script)
print(json.dumps({k: min(v for row in rows for v in row['minimumHeight'].values()) for k, rows in report.items()}))
