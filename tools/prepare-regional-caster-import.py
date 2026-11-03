"""Make a separate Roblox import revision; reject meaningful scale animation."""
from pathlib import Path
import json,struct,hashlib
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'assets/animations/regional-casters-v1'
OUT=ROOT/'assets/animations/regional-casters-v2'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):
 raw=path.read_bytes();n=struct.unpack_from('<I',raw,12)[0];return json.loads(raw[20:20+n]),raw[28+n:]
def access(d,b,index):
 a=d['accessors'][index];v=d['bufferViews'][a['bufferView']];assert a['componentType']==5126
 width={'VEC3':3,'VEC4':4,'SCALAR':1}[a['type']]
 return [struct.unpack_from('<'+'f'*width,b,v.get('byteOffset',0)+a.get('byteOffset',0)+i*v.get('byteStride',4*width))for i in range(a['count'])]
manifest={'schemaVersion':2,'workId':'MR-01','status':'Roblox importer revision; no upload performed by this script','uploaded':False,'models':{}}
for kind in ['QueenIceElf','VolcanoShaman','KingVolcanoShaman']:
 path=SOURCE/(kind+'-rigged.glb');d,b=read(path);removed=0
 for anim in d['animations']:
  retained=[]
  for channel in anim['channels']:
   if channel['target']['path']=='scale':
    values=access(d,b,anim['samplers'][channel['sampler']]['output'])
    assert all(abs(v-1)<1e-5 for row in values for v in row),(kind,'meaningful scale must be authored, not discarded')
    removed+=1
   else:
    assert channel['target']['path']!='weights',kind+' unsupported morph animation'
    retained.append(channel)
  samplers=[];mapping={}
  for channel in retained:
   old=channel['sampler']
   if old not in mapping:mapping[old]=len(samplers);samplers.append(anim['samplers'][old])
   channel['sampler']=mapping[old]
  anim['channels']=retained;anim['samplers']=samplers
 d['asset']['generator']='TLT MR-01 importer revision 2; constant unit-scale tracks removed'
 js=json.dumps(d,separators=(',',':')).encode();js+=b' '*(-len(js)%4)
 output=OUT/path.name;output.write_bytes(struct.pack('<4sII',b'glTF',2,28+len(js)+len(b))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(b),0x004e4942)+b)
 manifest['models'][kind]={'source':str(path.relative_to(ROOT)),'sourceSha256':sha(path),'file':output.name,'sha256':sha(output),'removedConstantScaleTracks':removed,'geometryAndSkinBinaryUnchanged':True}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({k:v['removedConstantScaleTracks']for k,v in manifest['models'].items()}))
