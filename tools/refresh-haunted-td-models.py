"""Sync only Zombie/Ghoul from the explicitly pinned TD refresh; never write TD."""
from pathlib import Path
import copy
import hashlib
import json
import math
import subprocess
import xml.etree.ElementTree as E

ROOT = Path(__file__).resolve().parents[1]
TD = ROOT.parent / 'throne-defense'
BASE = ROOT / 'assets/shared/td-haunted-graveyard'
MOTION = ROOT / 'assets/animations/haunted-graveyard-v1'
SOURCE = TD / 'assets/models/zombie-ghoul-refresh-20261115'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def write(path, data):
    path.write_text(json.dumps(data, indent=2) + '\n')

def name(item):
    return item.find('./Properties/string[@name="Name"]').text

raw = (SOURCE / 'runtime-v2.rbxmx').read_bytes()
assert sha(raw) == 'f9b388b08b5654593dd71ed19a47d46b0c364a3fd72305a54fee403fdad4b31f'
tree = E.parse(BASE / 'runtime.rbxmx')
folder = tree.find('./Item')
incoming = {name(m): m for m in E.fromstring(raw).findall('./Item/Item')}
manifest = json.loads((BASE / 'manifest.json').read_text())
rigs = json.loads((MOTION / 'rigs.json').read_text())
clips = json.loads((MOTION / 'clips.json').read_text())
keys = json.loads((MOTION / 'authoring-keys.json').read_text())
provenance = json.loads((MOTION / 'source-models.json').read_text())
td_commit = subprocess.check_output(['git', '-C', str(TD), 'rev-parse', 'HEAD'], text=True).strip()

for kind in ['Zombie', 'Ghoul']:
    template = kind.lower()
    model = incoming[template]
    assert not any(i.get('class') in ['Script', 'LocalScript', 'ModuleScript'] for i in model.iter('Item'))
    previous = next(m for m in folder.findall('Item') if name(m) == template)
    folder.insert(list(folder).index(previous), copy.deepcopy(model))
    folder.remove(previous)
    geometry_path = SOURCE / 'runtime-r3' / template / 'geometry.json'
    geometry = json.loads(geometry_path.read_text())
    parts = [name(p) for p in model.findall('./Item[@class="MeshPart"]')]
    pivots = {p['name']: p['pivot'] for p in geometry['parts']}
    assert set(parts) == set(pivots) == {'Body', 'ArmL', 'ArmR', 'LegL', 'LegR'}
    spec = manifest['models'][kind]
    spec.update(parts=parts, pivots=pivots, triangles=geometry['triangles'],
                geometrySha256=sha(geometry_path.read_bytes()), role='TD 2026-11-15 refreshed undead model',
                sourcePath=str((SOURCE / 'runtime-v2.rbxmx').relative_to(TD)),
                sourceSha256=sha(raw), tdCommit=td_commit,
                permission='2026-11-15 user requested TD Zombie/Ghoul reuse; published RPG access not yet tested.')
    target = BASE / 'refresh-20261115' / template
    target.mkdir(parents=True, exist_ok=True)
    (target / 'geometry.json').write_bytes(geometry_path.read_bytes())
    spec['geometryPath'] = str((target / 'geometry.json').relative_to(ROOT))
    rigs[kind].update(parts=parts, pivots=pivots)
    provenance[kind] = {'tdPath': str((SOURCE / 'runtime-r3' / template / 'mesh-only.glb').relative_to(TD)),
                        'sha256': sha((SOURCE / 'runtime-r3' / template / 'mesh-only.glb').read_bytes()),
                        'tdCommit': td_commit, 'runtimeSha256': sha(raw)}
    # A source resync must not replace subsequently reviewed individual motion.
    if all(data['models'][kind].get('motionRevision') == 'undead-individual-v2' for data in [clips, keys]):
        for data in [clips, keys]:
            assert data['models'][kind]['pivots'] == pivots
        continue
    # Retain server timing and the existing RPG whole-body attacks. New legs use
    # the established Zombie support gait; no new animation assets are uploaded.
    for data in [clips, keys]:
        profile = data['models'][kind]
        profile.update(hasLegs=True, pivots=pivots)
        profile.pop('groundPoints', None)
        lever = (pivots['LegL'][1] + pivots['LegR'][1]) / 2
        profile['stride'] = round(2 * lever * math.sin(math.radians(16)) / .6, 6)
    if kind == 'Zombie':
        # TD's refreshed shoulder seams were approved only for small arm swings.
        limit = math.degrees(.1)
        for channels in clips['models'][kind]['clips'].values():
            for ch in ['weapon', 'off']:
                for row in channels[ch]:
                    row[:] = [max(-limit, min(limit, x)) for x in row]
        for rows in keys['models'][kind]['clips'].values():
            for _, pose in rows:
                for ch in ['weapon', 'off']:
                    pose[ch] = [max(-limit, min(limit, x)) for x in pose[ch]]
    else:
        for ch in ['rightLeg', 'leftLeg']:
            clips['models'][kind]['clips']['Walk'][ch] = copy.deepcopy(clips['models']['Zombie']['clips']['Walk'][ch])
        for phase, pose in keys['models'][kind]['clips']['Walk']:
            for ch, offset in [('rightLeg', 0), ('leftLeg', .5)]:
                t = (phase + offset) % 1
                angle = 16 * (1 - 2*t/.6) if t < .6 else -16 * math.cos(math.pi*(t-.6)/.4)
                pose[ch] = [angle, 0, 0]

E.indent(tree, space='  ')
tree.write(BASE / 'runtime.rbxmx', encoding='utf-8', xml_declaration=True)
manifest['runtimeSha256'] = sha((BASE / 'runtime.rbxmx').read_bytes())
manifest['refresh'] = {'date': '2026-11-15', 'kinds': ['Zombie', 'Ghoul'], 'tdCommit': td_commit,
                       'sourceSha256': sha(raw), 'tool': 'tools/refresh-haunted-td-models.py'}
write(BASE / 'manifest.json', manifest)
for path, data in [('rigs.json', rigs), ('source-models.json', provenance)]:
    write(MOTION / path, data)
for path, data in [('clips.json', clips), ('authoring-keys.json', keys)]:
    (MOTION / path).write_text(json.dumps(data, separators=(',', ':')) + '\n')
subprocess.run(['python3', str(ROOT / 'tools/export-haunted-motion.py')], check=True)
# Describe the derivative honestly: existing Blender samples adapted to new pivots.
motion_manifest = json.loads((MOTION / 'manifest.json').read_text())
if not motion_manifest.get('individualRevisions'):
    motion_manifest['refresh20261115'] = {'kinds': ['Zombie', 'Ghoul'], 'authoring': 'Existing Blender samples adapted to refreshed TD pivots; Ghoul uses Zombie leg gait; Zombie arm axes limited to 0.1 radians. Ghoul retains rigid-arm whole-body attacks.', 'newBlenderEvaluation': False}
write(MOTION / 'manifest.json', motion_manifest)
print('Refreshed only Zombie/Ghoul; TD runtime and other HG species preserved.')
