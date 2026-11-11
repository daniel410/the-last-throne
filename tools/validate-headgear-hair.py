"""Verify the pinned TD hair derivatives and native import evidence."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[1]
p=root/'assets/models/headgear-hair-td-v1'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
total=0
for style in ('mage','short','helmet'):
 m=json.loads((p/style/'manifest.json').read_text())
 assert sha(p/style/'source-hair.glb')==m['sourceHairSha256']
 assert sha(p/style/'prepared-hair.glb')==m['preparedSha256']
 source=Path(m['sourceRepository'])/m['sourcePath']
 assert sha(source)==m['sourceSha256']
 assert len(m['samples'])==48
 total+=m['triangles']
native=json.loads((p/'native-import.json').read_text())
assert len(native)==3 and sum(x['matchedSourceSamples']for x in native)==144
assert {x['template']for x in native}=={'MageHair','ShortHair','HelmetHair'}
assert all(x['textureId']=='' and x['rotationToSource']==180 for x in native)
assert all(x['moderationResult']['moderationState']=='Approved'for x in json.loads((p/'uploaded.json').read_text()))
assert sha(p/'runtime.rbxm')=='04706dfdb908e61b18aed2ed882707232b8134ea33bfea20456745ac234ef678'
for project in ('default.project.json','battle.project.json'):
 assert json.loads((root/project).read_text())['tree']['ServerStorage']['HeadgearHairModels']['$path']=='assets/models/headgear-hair-td-v1/runtime.rbxm'
print(json.dumps({'styles':3,'triangles':total,'matchedNativeSamples':144,'pass':True}))
