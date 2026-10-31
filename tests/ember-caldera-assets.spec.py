"""Pinned TD import integrity and Blender/runtime export correspondence."""
import json,hashlib,xml.etree.ElementTree as E
from pathlib import Path
root=Path(__file__).resolve().parents[1];out=root/'assets/shared/td-ember-caldera';m=json.loads((out/'manifest.json').read_text());checks=0
def check(v,message):
 global checks
 checks+=1
 assert v,message
check(len(m['models'])==10,'ten selected templates')
raw=(out/'runtime.rbxmx').read_bytes();check(hashlib.sha256(raw).hexdigest()==m['runtimeSha256'],'runtime digest')
r=E.fromstring(raw);original=E.parse(root.parent/'throne-defense'/m['sourcePath']).getroot();check(hashlib.sha256((root.parent/'throne-defense'/m['sourcePath']).read_bytes()).hexdigest()==m['sourceSha256'],'current original pinned')
models=r.findall('./Item/Item');check(len(models)==10,'no unselected runtime models')
for kind,s in m['models'].items():
 model=next(x for x in models if x.find('./Properties/string[@name="Name"]').text==s['template'])
 source=next(x for x in original.findall('./Item/Item') if x.find('./Properties/string[@name="Name"]').text==s['template'])
 check(E.tostring(model)==E.tostring(source),kind+' original MeshPart identities/properties')
 check(not any(x.attrib.get('class') in ['Script','LocalScript','ModuleScript'] for x in model.iter('Item')),kind+' no executable source content')
 for filename,f in s['files'].items():
  actual=out/'source'/s['template']/filename;check(hashlib.sha256(actual.read_bytes()).hexdigest()==f['sha256'],kind+' source digest')
  check(actual.read_bytes()==(root.parent/'throne-defense'/f['tdPath']).read_bytes(),kind+' byte-identical GLB/geometry')
for project in ['default.project.json','battle.project.json']:
 d=json.loads((root/project).read_text());check(d['tree']['ServerStorage']['EmberCalderaModels']['$path']=='assets/shared/td-ember-caldera/runtime.rbxmx','mounted '+project)
a=root/'assets/animations/ember-caldera-v1';manifest=json.loads((a/'manifest.json').read_text());clips=json.loads((a/'clips.json').read_text())
for f,h in manifest['files'].items():check(hashlib.sha256((a/f).read_bytes()).hexdigest()==h,'Blender artifact '+f)
check(set(clips['models'])==set(m['models']),'all imported species animated')
check(sum(len(p['clips']) for p in clips['models'].values())==70,'seventy logical clips')
print('EMBER_CALDERA_ASSETS '+str(checks)+' checks passed')
