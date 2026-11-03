"""Check local authored GLBs against the runtime source; optionally refresh asset provenance."""
import argparse,hashlib,json,struct
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('--write-manifest',action='store_true');args=parser.parse_args()
root=Path(__file__).resolve().parents[1];folder=root/'assets/models/story-props-v1'
data=json.loads((folder/'geometry.json').read_text());manifest=json.loads((folder/'manifest.json').read_text());models=[]
for key,spec in data['models'].items():
 path=folder/(key+'.glb');blob=path.read_bytes();magic,version,total=struct.unpack_from('<III',blob)
 assert magic==0x46546c67 and version==2 and total==len(blob),key
 length=struct.unpack_from('<I',blob,12)[0];glb=json.loads(blob[20:20+length]);assert len(glb['nodes'])==len(spec['parts']),key
 assert 5<=len(spec['parts'])<=130,key
 for part in spec['parts']:
  assert all(n>0 for n in part['size']),part['name']
  assert part['shape'] in ['Block','Cylinder','Wedge'],part['name']
 assert all('uri' not in image for image in glb.get('images',[])),key+' cannot load remote textures'
 models.append(dict(id=key,status='New',purpose=spec['purpose'],nativeParts=len(spec['parts']),glb=str(path.relative_to(root)),bytes=len(blob),sha256=hashlib.sha256(blob).hexdigest()))
if args.write_manifest:
 manifest['models']=models;(folder/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
else:assert manifest['models']==models,'Manifest does not match exported geometry'
print(json.dumps({'pass':True,'models':len(models),'sourceParts':sum(m['nativeParts']for m in models),'GLBNodeCountsMatch':True,'noRemoteTextures':True}))
