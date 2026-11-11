"""Validate provenance, source preservation, native geometry and build wiring."""
from pathlib import Path
import hashlib, json, struct
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/four-family-armor-meshy-v1'
m=json.loads((BASE/'manifest.json').read_text())
g={r['id']:r for r in json.loads((BASE/'geometry-report.json').read_text())}
n={r['id']:r for r in json.loads((BASE/'native-import.json').read_text())}
u={r['id']:r for r in json.loads((BASE/'uploaded.json').read_text())}
assert len(m['records'])==len(g)==len(n)==len(u)==28
assert len({r['sourceSha256']for r in m['records']})==28
assert {(r['family'],r['category'])for r in m['records']}=={
 (f,k)for f in ['traveler','tempered','veteran','sentinel']
 for k in ['hood','helmet','hat','coat','robe','gloves','boots']}
panels=samples=triangles=0
for r in m['records']:
 for file,key in [('source','sourceSha256'),('prepared','preparedSha256')]:
  data=(BASE/r[file]).read_bytes();assert hashlib.sha256(data).hexdigest()==r[key]
  size,kind=struct.unpack_from('<II',data,12);doc=json.loads(data[20:20+size]);assert kind==0x4e4f534a
  for mesh in doc['meshes']:
   assert sum(doc['accessors'][p['indices']]['count']//3 for p in mesh['primitives'])<20000
 assert (ROOT/r['reference']).is_file(),r['reference']
 a=g[r['id']];b=n[r['id']];c=u[r['id']]['response']
 assert r['meshyTaskId']==a['meshyTaskId']==b['meshyTaskId']
 assert r['modelAssetId']==c['assetId'] and c['moderationResult']['moderationState']=='Approved'
 assert len(a['parts'])==len(b['parts'])
 assert sum(p['triangles']for p in a['parts'])==a['sourceFaces']
 assert (a['viewTransform'],a['display'],a['look'],a['exposure'],a['gamma'],a['useCurves'])==('Standard','sRGB','None',0,1,False)
 for p,q in zip(a['parts'],b['parts']):
  assert p['name']==q['name'] and len(p['samples'])==q['matchedSourceSamples']==24
  assert q['rotationToSource']in(0,90,180,270)
  assert q['meshId'].startswith('rbxassetid://')and q['textureId'].startswith('rbxassetid://')
  panels+=1;samples+=q['matchedSourceSamples']
 triangles+=r['triangles']
assert panels==92 and samples==2208
assert hashlib.sha256((BASE/m['runtime']).read_bytes()).hexdigest()==m['runtimeSha256']
for p in ['default.project.json','battle.project.json']:
 project=json.loads((ROOT/p).read_text())
 assert project['tree']['ServerStorage']['FourFamilyArmorModels']['$path']==str((BASE/'runtime.rbxm').relative_to(ROOT))
print(f'Armor provenance: 28 unique sources, {triangles} triangles, {panels} native panels, {samples} matching samples, 28 approved assets; both projects wired')
