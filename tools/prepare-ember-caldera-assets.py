"""Pin the ten selected current TD volcano templates, preserving asset IDs and bytes."""
from pathlib import Path
import xml.etree.ElementTree as E
import json,hashlib,shutil,subprocess
root=Path(__file__).resolve().parents[1];td=root.parent/'throne-defense';out=root/'assets/shared/td-ember-caldera';out.mkdir(parents=True,exist_ok=True)
names={'Imp':'imp','LavaSlime':'lava_slime','Golem':'golem','MagmaWorm':'magma_worm','VolcanoShaman':'volcano_shaman','MagmaImp':'magma_imp','MagmaGolem':'magma_golem','InfernoOverlord':'inferno_overlord','CalderaTitan':'caldera_titan','KingVolcanoShaman':'king_volcano_shaman'}
source=td/'assets/models/meshy-deepwood-slime-v1/runtime.rbxmx';raw=source.read_bytes();original=E.fromstring(raw);folder=E.Element('Item',{'class':'Folder','referent':'EmberCalderaModels'});props=E.SubElement(folder,'Properties');E.SubElement(props,'string',{'name':'Name'}).text='EmberCalderaModels'
manifest={'version':1,'tdCommit':subprocess.check_output(['git','-C',str(td),'rev-parse','HEAD'],text=True).strip(),'sourcePath':str(source.relative_to(td)),'sourceSha256':hashlib.sha256(raw).hexdigest(),'permission':'User-requested reuse from the shared TD repository. Published RPG asset permissions require separate verification.','models':{}}
for kind,name in names.items():
 model=next(m for m in original.findall('./Item/Item')if m.find('./Properties/string[@name="Name"]').text==name)
 assert not any(x.attrib.get('class') in ['Script','LocalScript','ModuleScript'] for x in model.iter('Item'))
 folder.append(model);dest=out/'source'/name;dest.mkdir(parents=True,exist_ok=True)
 files={}
 for file in ['textured-review.glb','geometry.json']:
  p=td/'assets/models/meshy-blocky-monsters-v1/runtime'/name/file;shutil.copyfile(p,dest/file);files[file]={'tdPath':str(p.relative_to(td)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
 geom=json.loads((dest/'geometry.json').read_text())
 parts=[m.find('./Properties/string[@name="Name"]').text for m in model.findall('./Item')if m.attrib['class']=='MeshPart']
 assert set(parts)==set(p['name'] for p in geom['parts'])
 manifest['models'][kind]={'template':name,'parts':parts,'files':files,'triangles':geom['triangles'],'pivots':{p['name']:p['pivot'] for p in geom['parts']},'targetHeight':float(model.find('./Item[@class="NumberValue"]/Properties/double[@name="Value"]').text)}
x=E.Element('roblox',{'version':'4'});x.append(folder);E.ElementTree(x).write(out/'runtime.rbxmx',encoding='utf-8',xml_declaration=True)
manifest['runtimeSha256']=hashlib.sha256((out/'runtime.rbxmx').read_bytes()).hexdigest();(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
for project in ['default.project.json','battle.project.json']:
 p=root/project;d=json.loads(p.read_text());d['tree']['ServerStorage']['EmberCalderaModels']={'$path':'assets/shared/td-ember-caldera/runtime.rbxmx'};p.write_text(json.dumps(d,indent=2)+'\n')
print('Pinned',len(names),'TD models')
