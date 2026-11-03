from pathlib import Path
import json, hashlib, xml.etree.ElementTree as E
root=Path(__file__).resolve().parents[1];base=root/'assets/shared/td-haunted-graveyard'
m=json.loads((base/'manifest.json').read_text());data=(base/'runtime.rbxmx').read_bytes()
assert hashlib.sha256(data).hexdigest()==m['runtimeSha256']
r=E.fromstring(data);models={x.find('./Properties/string[@name="Name"]').text:x for x in r.findall('./Item/Item')}
assert len(models)==10 and len(m['models'])==11
for kind,spec in m['models'].items():
 model=models[spec['template']]
 assert not any(x.attrib.get('class') in ['Script','LocalScript','ModuleScript'] for x in model.iter('Item'))
 parts=[x for x in model.findall('./Item')if x.attrib['class']=='MeshPart']
 assert set(x.find('./Properties/string[@name="Name"]').text for x in parts)==set(spec['parts'])
 assert all(x.find('./Properties/Content[@name="MeshId"]/url').text for x in parts)
assert m['models']['Veyr']['template']==m['models']['DreadCommander']['template']=='dread_commander'
print('HAUNTED_TD_ASSETS: 10 original TD templates / 11 stable enemy kinds PASS')
