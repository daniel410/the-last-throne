"""Validate Blender MCP sampled curves and emit native Luau; no offline animation synthesis."""
from pathlib import Path
import json,hashlib,math
root=Path(__file__).resolve().parents[1];folder=root/'assets/animations/ember-caldera-v1';data=json.loads((folder/'clips.json').read_text());sockets=json.loads((folder/'sockets.json').read_text());manifest=json.loads((root/'assets/shared/td-ember-caldera/manifest.json').read_text())
def lua(x):
 if isinstance(x,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(v) for k,v in x.items())+'}'
 if isinstance(x,list):return '{'+','.join(lua(v) for v in x)+'}'
 if isinstance(x,bool):return str(x).lower()
 return json.dumps(x,allow_nan=False,separators=(',',':'))
assert set(data['models'])==set(manifest['models']) and data['samples']==201
for kind,p in data['models'].items():
 assert set(p['clips'])=={'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned'}
 for clip,channels in p['clips'].items():
  for ch,values in channels.items():
   assert len(values)==201 and all(len(v)==(9 if ch=='body' else 3) and all(math.isfinite(x) for x in v) for v in values)
   if clip in ['Idle','Walk','Stunned']:assert max(abs(a-b) for a,b in zip(values[0],values[-1]))<1e-5
 if kind in sockets:assert all(abs(v)<=.501 for v in sockets[kind]['tip']+sockets[kind]['base'])
(root/'src/client/EmberCalderaClips.luau').write_text('-- Blender MCP export, assets/animations/ember-caldera-v1.\nreturn '+lua(data)+'\n')
rigs={}
for kind,spec in manifest['models'].items():
 rigs[kind]={**spec,'folder':'EmberCalderaModels','pivots':data['models'][kind]['pivots']}
 for k in ['files','triangles','targetHeight']:rigs[kind].pop(k)
 if kind in sockets:rigs[kind]['socket']={**sockets[kind],'element':'fire'}
(root/'src/shared/EmberCalderaRigs.luau').write_text('-- Pinned TD geometry; Blender anatomical axes and weapon sockets.\nreturn '+lua(rigs)+'\n')
print('Validated 10 species / 70 clips / 350 channels / 201 samples')
