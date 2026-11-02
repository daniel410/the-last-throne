"""Normalize audited native import; build a separate two-model override folder."""
from pathlib import Path
import json,struct,hashlib,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/shared/deepwood-weapon-repair'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def bounds(kind):
 b=(OUT/(kind+'-repaired.glb')).read_bytes();n=struct.unpack_from('<I',b,12)[0];d=json.loads(b[20:20+n]);binary=b[28+n:];result={}
 for node in d['nodes']:
  if 'mesh'not in node:continue
  assert not any(k in node for k in ('rotation','scale','matrix'))
  mesh=d['meshes'][node['mesh']];a=d['accessors'][mesh['primitives'][0]['attributes']['POSITION']];view=d['bufferViews'][a['bufferView']];off=view.get('byteOffset',0)+a.get('byteOffset',0)
  points=[struct.unpack_from('<fff',binary,off+i*view.get('byteStride',12))for i in range(a['count'])];points=[[v[i]+node.get('translation',[0,0,0])[i]for i in range(3)]for v in points]
  lo=[min(v[i]for v in points)for i in range(3)];hi=[max(v[i]for v in points)for i in range(3)]
  result[node['name'].split('__')[1]]={'center':[(a+b)/2 for a,b in zip(lo,hi)],'size':[b-a for a,b in zip(lo,hi)],'points':points}
 return result

def item(parent,cls,name):
 node=E.SubElement(parent,'Item',{'class':cls});props=E.SubElement(node,'Properties');E.SubElement(props,'string',name='Name').text=name;return node,props
root=E.Element('roblox',version='4');folder,_=item(root,'Folder','DeepwoodWeaponRepairModels');models={}
for raw in json.loads((OUT/'native-import.json').read_text()):
 kind='ogre'if len(raw['parts'])==6 else'warlord';geometry=bounds(kind);model,_=item(folder,'Model',kind);parts=[];translations=[]
 assert len(geometry)==len(raw['parts'])
 for p in raw['parts']:
  name=p['name'].split('__')[-1].split('.')[0];g=geometry[name];assert max(abs(a-b)for a,b in zip(p['size'],g['size']))<.00001,(kind,name,'size')
  center=g['center'];translations.append([p['cf'][0]+center[0],p['cf'][1]-center[1],p['cf'][2]+center[2]])
  node,props=item(model,'MeshPart',name)
  for key,value in [('MeshId',p['mesh']),('TextureID',p['texture'])]:E.SubElement(E.SubElement(props,'Content',name=key),'url').text=value
  for key in ['size','InitialSize']:
   vector=E.SubElement(props,'Vector3',name=key)
   for axis,value in zip('XYZ',p['size']):E.SubElement(vector,axis).text=str(value)
  cf=E.SubElement(props,'CoordinateFrame',name='CFrame')
  for tag,value in zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],center+[-1,0,0,0,1,0,0,0,-1]):E.SubElement(cf,tag).text=str(value)
  for key,value in [('Anchored','true'),('CanCollide','false'),('DoubleSided','true')]:E.SubElement(props,'bool',name=key).text=value
  E.SubElement(props,'Color3uint8',name='Color3uint8').text='16777215';E.SubElement(props,'token',name='Material').text='272'
  parts.append({'name':name,'mesh':p['mesh'],'texture':p['texture'],'center':center,'size':p['size']})
 assert max(abs(a-b)for row in translations for a,b in zip(row,translations[0]))<.00001,(kind,translations)
 legacy=E.parse(ROOT/'assets/shared/td-monsters/runtime.rbxmx')
 original=next(m for m in legacy.findall('./Item/Item')if m.findtext('./Properties/string[@name="Name"]')==kind)
 height=original.findtext('./Item[@class="NumberValue"]/Properties/double[@name="Value"]')
 h,_=item(model,'NumberValue','TargetHeight');E.SubElement(h.find('Properties'),'double',name='Value').text=height
 socketName='Weapon'if kind=='ogre'else'ArmL';g=geometry[socketName];axis=1 if kind=='ogre'else 2
 points=sorted(g['points'],key=lambda v:v[axis],reverse=kind=='ogre')[:20];tip=[sum(p[i]for p in points)/len(points)for i in range(3)]
 normal=[(tip[i]-g['center'][i])/g['size'][i]*(-1 if i in [0,2]else 1)for i in range(3)];base=normal[:];base[1]+=-.16 if kind=='ogre'else .16
 models[kind]={'parts':parts,'sourceGlbSha256':sha(OUT/(kind+'-repaired.glb')),'nativeImportTranslation':translations[0],'socketPart':socketName,'tip':normal,'base':base}
E.indent(root);E.ElementTree(root).write(OUT/'runtime.rbxmx',encoding='utf-8',xml_declaration=True)
# Keep the existing TD source templates completely unchanged.
result={'schemaVersion':1,'scope':'Ogre and DW-05 Warlord only; local RPG override','models':models,'runtimeSha256':sha(OUT/'runtime.rbxmx'),'uploaded':True,'published':False}
(OUT/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
for project in ['default.project.json','battle.project.json']:
 p=ROOT/project;d=json.loads(p.read_text());d['tree']['ServerStorage']['DeepwoodWeaponRepairModels']={'$path':'assets/shared/deepwood-weapon-repair/runtime.rbxmx'};p.write_text(json.dumps(d,indent=2)+'\n')
print(json.dumps({k:{'parts':len(v['parts']),'tip':v['tip']}for k,v in models.items()}))
