"""Validate immutable Meshy sources, exact whitelist, uploads and build wiring."""
from pathlib import Path
import hashlib,json,struct
ROOT=Path(__file__).resolve().parents[1];base=ROOT/'assets/models/four-family-shields-meshy-v1'
m=json.loads((base/'manifest.json').read_text());uploads=json.loads((base/'uploaded.json').read_text());native=json.loads((base/'native-import.json').read_text())['models']
assert len(m['records'])==len(uploads)==len(native)==4
assert len({r['meshyTaskId']for r in m['records']})==4
assert {r['definitionId']for r in m['records']}=={'knight_shield','knight_shield_fine','veteran_tier_shield','sentinel_tier_shield'}
for r in m['records']:
 for key in ['source','prepared']:
  data=(base/r[key]).read_bytes();assert hashlib.sha256(data).hexdigest()==r[key+'Sha256'];assert data[:4]==b'glTF'
  size=struct.unpack_from('<I',data,12)[0];d=json.loads(data[20:20+size]);assert len(d['meshes'])==1 and len(d['images'])==1
  tris=sum(d['accessors'][p['indices']]['count']//3 for mesh in d['meshes']for p in mesh['primitives']);assert tris==r['triangles']and tris<20000
 u=next(u['operation']for u in uploads if u['id']==r['id']);assert u['done']and u['response']['moderationResult']['moderationState']=='Approved'and u['response']['state']=='Active'
 n=next(n for n in native if n['id']==r['id']);assert n['matchedSourceSamples']==48 and abs(n['size'][1]-1.88)<.0001
 assert n['modelAssetId']==u['response']['assetId']
 registry=(ROOT/'src/shared/FourFamilyShieldVisuals.luau').read_text()
 for value in [r['definitionId'],r['meshyTaskId'],n['meshId'],n['textureId']]:assert value in registry
assert hashlib.sha256((base/'runtime.rbxm').read_bytes()).hexdigest()==m['runtimeSha256']
projects=[json.loads((ROOT/f).read_text())for f in ['default.project.json','battle.project.json']];assert projects[0]==projects[1]
assert projects[0]['tree']['ServerStorage']['FourFamilyShieldModels']['$path']=='assets/models/four-family-shields-meshy-v1/runtime.rbxm'
print('PASS: 4 exact shields; original/prepared hashes, triangles, 4 Approved uploads, 192 native samples, script registry, frozen runtime hash, project mounts')
