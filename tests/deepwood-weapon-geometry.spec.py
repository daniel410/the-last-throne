"""Check pinned source coverage, exported model scope and native normalization."""
from pathlib import Path
import importlib.util,json,xml.etree.ElementTree as E,hashlib,math
ROOT=Path(__file__).resolve().parents[1]
s=importlib.util.spec_from_file_location('repair',ROOT/'tools/repair-deepwood-weapons.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
d=json.loads((m.OUT/'geometry.json').read_text());manifest=json.loads((m.OUT/'manifest.json').read_text());doc=E.parse(m.OUT/'runtime.rbxmx');checks=0

def check(v,message):
 global checks
 checks+=1;assert v,message
for kind in ['ogre','warlord']:
 source=m.read(m.OUT/'inputs'/(kind+'.glb'));prepared=m.read(m.OUT/(kind+'-prepared.glb'));final=m.read(m.OUT/(kind+'-repaired.glb'))
 check(d['models'][kind]['sourceSha256']==m.sha(m.OUT/'inputs'/(kind+'.glb')),kind+' pinned input')
 check(abs(sum(m.area(f)for part in source.values()for f in part)-sum(m.area(f)for part in prepared.values()for f in part))<1e-7,kind+' original surfaces preserved exactly once')
 expected={'Body','ArmL','ArmR','LegL','LegR'}|({'Weapon'}if kind=='ogre'else set())
 check(set(final)=={kind+'__'+p for p in expected},kind+' export contains only intended meshes')
 for part in final.values():
  check(all(math.isfinite(x)for f in part for v in f for row in v for x in row),kind+' finite geometry')
  check(all(m.area(f)>1e-15 for f in part),kind+' nondegenerate triangles')
 model=next(o for o in doc.findall('./Item/Item')if o.findtext('./Properties/string[@name="Name"]')==kind)
 check(len(model.findall('./Item[@class="MeshPart"]'))==len(expected),kind+' native part count')
 for p in manifest['models'][kind]['parts']:
  node=next(o for o in model.findall('./Item[@class="MeshPart"]')if o.findtext('./Properties/string[@name="Name"]')==p['name'])
  check(node.findtext('./Properties/Content[@name="MeshId"]/url')==p['mesh'],kind+' exact uploaded mesh ID')
  check(node.findtext('./Properties/CoordinateFrame[@name="CFrame"]/R00')=='-1',kind+' native Y180 convention')
 check(manifest['models'][kind]['sourceGlbSha256']==m.sha(m.OUT/(kind+'-repaired.glb')),kind+' import tied to exported source')
check(manifest['runtimeSha256']==m.sha(m.OUT/'runtime.rbxmx'),'native runtime hash')
check(not any(n.attrib.get('class')in ['Script','ModuleScript','LocalScript']for n in doc.iter('Item')),'templates contain no code')
print(json.dumps({'kind':'DEEPWOOD_WEAPON_GEOMETRY_STATIC','checks':checks,'pass':True,'runtimeSha256':manifest['runtimeSha256']}))
