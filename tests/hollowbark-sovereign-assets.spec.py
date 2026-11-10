from pathlib import Path
import json, hashlib, xml.etree.ElementTree as ET, struct
base=Path('assets/models/hollowbark-sovereign-td-v1')
m=json.loads((base/'manifest.json').read_text())
for f in m['files']:
 data=(base/f['path']).read_bytes();assert hashlib.sha256(data).hexdigest()==f['sha256'];assert len(data)==f['bytes']
root=ET.parse(base/'runtime.rbxmx').getroot();model=root.find('Item');assert model.attrib['class']=='Model'
body=next(i for i in model.findall('Item') if i.find("Properties/string[@name='Name']").text=='Body')
assert body.find("Properties/bool[@name='HasSkinnedMesh']").text=='true'
bones=[b.find("Properties/string[@name='Name']").text for b in body.iter('Item') if b.attrib['class']=='Bone'];assert len(bones)==10 and len(set(bones))==10
assert model.find("Item/Properties/string[.='TargetHeight']/../double[@name='Value']").text=='14'
for f in ['default.project.json','battle.project.json']:
 project=json.loads(Path(f).read_text());assert project['tree']['ServerStorage']['HollowbarkSovereignTemplate']['$path']==str(base/'runtime.rbxmx')
data=(base/'rigged/HollowbarkSovereign.glb').read_bytes();length=struct.unpack_from('<I',data,12)[0];doc=json.loads(data[20:20+length])
assert len(doc['skins'])==1 and len(doc['skins'][0]['joints'])==10 and len(doc['meshes'])==1
assert {a['name'] for a in doc['animations']}=={'Idle','Walk'}
assert doc['accessors'][doc['meshes'][0]['primitives'][0]['indices']]['count']//3==2484
print('SOVEREIGN_ASSETS PASS: exact source hashes, skin flag, ten bones, 2484 triangles, 14stud, both project bindings')
