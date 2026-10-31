"""Validate Blender MCP exports and generate both sides of the rig contract."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
folder = root / 'assets/animations/deepwood-monsters-v2'
raw = (folder / 'clips.json').read_bytes()
data = json.loads(raw)
sockets = json.loads((folder / 'weapon-sockets.json').read_text())

def lua(value):
    if isinstance(value, dict):
        return '{' + ','.join('[' + json.dumps(k) + ']=' + lua(v) for k,v in value.items()) + '}'
    if isinstance(value, list):
        return '{' + ','.join(lua(v) for v in value) + '}'
    return json.dumps(value, allow_nan=False, separators=(',', ':'))

assert data['samples'] == 201 and data['impactPhase'] == .62
for kind,model in data['models'].items():
    assert set(model['clips']) == {'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned'}
    for clip,channels in model['clips'].items():
        assert set(channels) == set(data['channels'])
        for channel, samples in channels.items():
            assert len(samples) == data['samples']
            assert all(len(sample) == (9 if channel == 'body' else 3) for sample in samples)
            if clip in ('Idle','Walk','Stunned'):
                assert max(abs(a-b) for a,b in zip(samples[0],samples[-1])) < .00001
    if kind in sockets:
        assert all(abs(v) <= .501 for v in sockets[kind]['tip'] + sockets[kind]['base'])
    model.pop('controllers')
data['sourceSha256'] = hashlib.sha256(raw).hexdigest()
(root / 'src/client/K0EnemyClips.luau').write_text('-- Exported from Blender MCP v2. Edit the .blend/source, then re-export.\nreturn ' + lua(data) + '\n')
rig = {kind:{'shoulders':model['shoulders'],**sockets[kind]} for kind,model in data['models'].items() if kind in sockets}
(root / 'src/shared/EnemyRigSockets.luau').write_text('-- Blender MCP anatomical pivots and mesh-normalized weapon sockets.\n-- Source: assets/animations/deepwood-monsters-v2\nreturn ' + lua(rig) + '\n')
print(json.dumps({'species':len(data['models']), 'clips':sum(len(m['clips']) for m in data['models'].values()), 'sourceSha256':data['sourceSha256']}))
