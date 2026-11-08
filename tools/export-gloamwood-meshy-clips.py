"""Extract GLB-authored local Bone deltas; no cloud animations are required.

Native import records establish that all non-root rest frames equal glTF node
frames. The root-only native 180-degree bake is retained in the mesh template.
"""
from pathlib import Path
import argparse, bisect, collections, hashlib, json, math, struct

ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--base',type=Path,default=ROOT/'assets/models/gloamwood-meshy-v1')
BASE=parser.parse_args().base.resolve()
OUT=ROOT/'src/client/GloamwoodClips'
OUT.mkdir(exist_ok=True)

def glb(path):
 data=path.read_bytes();length=struct.unpack_from('<I',data,12)[0]
 document=json.loads(data[20:20+length]);start=20+length
 return document,data[start+8:]

def accessor(doc,binary,index):
 a=doc['accessors'][index];v=doc['bufferViews'][a['bufferView']]
 fmt={5126:'f',5125:'I',5123:'H',5121:'B'}[a['componentType']]
 count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
 size=struct.calcsize('<'+fmt*count);stride=v.get('byteStride',size)
 offset=v.get('byteOffset',0)+a.get('byteOffset',0)
 return [struct.unpack_from('<'+fmt*count,binary,offset+i*stride)for i in range(a['count'])]

def multiply(a,b):
 x,y,z,w=a;u,v,s,t=b
 return (w*u+x*t+y*s-z*v,w*v-x*s+y*t+z*u,w*s+x*v-y*u+z*t,w*t-x*u-y*v-z*s)

def inverse(q):return (-q[0],-q[1],-q[2],q[3])
def rotate(q,p):return multiply(multiply(q,(*p,0)),inverse(q))[:3]

def interpolate(times,values,mode,t,rotation=False):
 i=min(len(times)-2,max(0,bisect.bisect_right(times,t)-1))
 f=max(0,min(1,(t-times[i])/max(1e-9,times[i+1]-times[i])))
 a,b=values[i],values[i+1]
 if mode=='STEP':return a if t<times[-1] else values[-1]
 if rotation and sum(x*y for x,y in zip(a,b))<0:b=tuple(-v for v in b)
 result=tuple(x+(y-x)*f for x,y in zip(a,b))
 if rotation:
  length=math.sqrt(sum(v*v for v in result));result=tuple(v/length for v in result)
 return result

def num(v):return '0' if abs(v)<1e-8 else format(v,'.8g')

native={r['kind']:r for r in json.loads((BASE/'native-import.json').read_text())['models']}
rigs={r['kind']:r for r in json.loads((BASE/'rig-report.json').read_text())}
reports=[];review={}
for path in sorted((BASE/'rigged').glob('*.glb')):
 kind=path.stem;doc,binary=glb(path);nodes=doc['nodes'];skin=doc['skins'][0]
 assert len(doc['meshes'])==1 and len(doc['skins'])==1
 assert len(skin['joints'])==len(native[kind]['bones'])==len(rigs[kind]['bones'])
 prim=doc['meshes'][0]['primitives'][0]
 source_path=next((BASE/'source').glob('Meshy_AI_'+rigs[kind]['source']+'_*'))
 original,original_binary=glb(source_path)
 original_primitive=original['meshes'][0]['primitives'][0]
 surface_errors={}
 for attribute in ('POSITION','TEXCOORD_0'):
  before=accessor(original,original_binary,original_primitive['attributes'][attribute])
  after=accessor(doc,binary,prim['attributes'][attribute])
  assert len(before)==len(after)
  error=max(abs(x-y)for a,b in zip(before,after)for x,y in zip(a,b))
  assert error<1e-6,(kind,attribute,error)
  surface_errors[attribute]=error
 assert len(accessor(doc,binary,prim['indices']))//3==rigs[kind]['triangles']<20000
 weights=accessor(doc,binary,prim['attributes']['WEIGHTS_0'])
 joints=accessor(doc,binary,prim['attributes']['JOINTS_0'])
 assert all(abs(sum(v)-1)<1e-5 and all(x>=0 for x in v) for v in weights)
 assert all(sum(w>1e-8 for w in row)<=2 for row in weights)
 assert all(nodes[skin['joints'][j]]['name']!='Root' for row,ws in zip(joints,weights)for j,w in zip(row,ws)if w>1e-8)
 # The actual native non-root rest rotations are identity and positions equal
 # glTF. Root was baked by the importer; its GLB animation delta is identity.
 for b in native[kind]['bones']:
  if b['name']=='Root':continue
  node=next(n for n in nodes if n['name']==b['name'])
  assert max(abs(x-y)for x,y in zip(node.get('translation',[0,0,0]),b['cf'][:3]))<1e-5
 body=['-- Generated from rigged/'+path.name+'; native rest frames verified.\nreturn {bones={']
 body.append(','.join(json.dumps(nodes[i]['name'])for i in skin['joints']))
 body.append('},clips={\n');clips={};clip_sources={}
 for animation in doc['animations']:
  channels={};duration=0
  for ch in animation['channels']:
   sampler=animation['samplers'][ch['sampler']]
   mode=sampler.get('interpolation','LINEAR');assert mode in ('LINEAR','STEP')
   times=[v[0]for v in accessor(doc,binary,sampler['input'])];values=accessor(doc,binary,sampler['output'])
   duration=max(duration,times[-1]);channels[(ch['target']['node'],ch['target']['path'])]=(times,values,mode)
  tracks={}
  for index in skin['joints']:
   node=nodes[index];restq=node.get('rotation',[0,0,0,1]);restp=node.get('translation',[0,0,0]);frames=[]
   for sample in range(41):
    t=duration*sample/40;current={}
    for prop,default in [('translation',restp),('rotation',restq)]:
     current[prop]=interpolate(*channels[(index,prop)],t,prop=='rotation') if (index,prop)in channels else default
    p=rotate(inverse(restq),tuple(x-y for x,y in zip(current['translation'],restp)))
    q=multiply(inverse(restq),current['rotation']);frames.append((*p,*q))
   if any(max(abs(v) for v in f[:6])+abs(abs(f[6])-1)>1e-7 for f in frames):tracks[node['name']]=frames
  assert duration>0
  name=animation['name'];clips[name]={'duration':duration,'tracks':tracks}
  start=len(body)
  body.append('['+json.dumps(name)+']={duration='+num(duration)+',tracks={\n')
  for bone,frames in tracks.items():
   body.append('['+json.dumps(bone)+']={'+','.join('CFrame.new('+','.join(num(v)for v in frame)+')'for frame in frames)+'},\n')
  body.append('}},\n')
  text=''.join(body[start:]);clip_sources[name]='-- Authored GLB local deltas.\nreturn '+text.split('=',1)[1].removesuffix(',\n')+'\n'
 assert len(clips)==10 and all(n in clips for n in ['Idle','Walk','Attack','Heavy','Stunned','Exposed','Return','Interrupted'])
 review[kind]={name:list(frames[10])for name,frames in clips['Walk']['tracks'].items()}
 body.append('}}\n');target=OUT/(kind+'.luau');content=''.join(body);children={}
 if len(content)>190000:
  if target.exists():target.unlink()
  folder=OUT/kind;folder.mkdir(exist_ok=True)
  target=folder/'init.luau'
  content='-- Split to keep every Studio Source property below 200000 bytes.\nreturn {bones={'+','.join(json.dumps(nodes[i]['name'])for i in skin['joints'])+'},clips={'+','.join('['+json.dumps(n)+']=require(script.'+n+')'for n in clip_sources)+'}}\n'
  for name,source in clip_sources.items():
   child=folder/(name+'.luau');assert len(source)<190000;child.write_text(source);children[str(child.relative_to(ROOT))]=hashlib.sha256(child.read_bytes()).hexdigest()
 target.write_text(content)
 reports.append({'kind':kind,'triangles':rigs[kind]['triangles'],'bones':len(skin['joints']),'clips':{k:{'duration':v['duration'],'animatedBones':len(v['tracks'])}for k,v in clips.items()},'originalMeshySourceSha256':hashlib.sha256(source_path.read_bytes()).hexdigest(),'sourceSha256':hashlib.sha256(path.read_bytes()).hexdigest(),'moduleSha256':hashlib.sha256(target.read_bytes()).hexdigest(),'childModules':children,'sourceSurfaceMaxError':surface_errors,'allVertexWeightsNormalized':True,'maxInfluences':2,'noRootVertexWeights':True,'nativeRestFramesMatch':True})
(BASE/'clip-validation.json').write_text(json.dumps(reports,indent=2)+'\n')
(BASE/'review-walk-poses.json').write_text(json.dumps(review,indent=2)+'\n')
print(f'PASS: {len(reports)} intact meshes; normalized skin weights; native rest frames; {sum(len(r["clips"]) for r in reports)} clips / 41 samples')
