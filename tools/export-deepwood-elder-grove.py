"""실제 GLB의 연결된 바위 덩어리와 작은 나무의 단순 충돌 데이터를 추출한다."""
from pathlib import Path
import json,struct
root=Path(__file__).resolve().parents[1];base=root/'assets/models/deepwood-elder-grove-v1'
raw=(base/'elder-grove.glb').read_bytes();n=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+n]);binary=raw[28+n:]
formats={5123:'H',5125:'I',5126:'f'};components={'SCALAR':1,'VEC3':3}
def read(index):
 a=g['accessors'][index];b=g['bufferViews'][a['bufferView']];f='<'+formats[a['componentType']]*components[a['type']];stride=b.get('byteStride',struct.calcsize(f));start=b.get('byteOffset',0)+a.get('byteOffset',0)
 return [struct.unpack_from(f,binary,start+i*stride)for i in range(a['count'])]
mesh=next(m for m in g['meshes']if m['name'].split('.')[0]=='GardenStone');p=mesh['primitives'][0];pos=read(p['attributes']['POSITION']);indices=[x[0]for x in read(p['indices'])];parents=list(range(len(pos)));by={}
def find(i):
 while parents[i]!=i:parents[i]=parents[parents[i]];i=parents[i]
 return i
def join(a,b):parents[find(a)]=find(b)
for i,v in enumerate(pos):
 key=tuple(round(x,4)for x in v)
 if key in by:join(i,by[key])
 else:by[key]=i
for i in range(0,len(indices),3):join(indices[i],indices[i+1]);join(indices[i],indices[i+2])
groups={}
for i,v in enumerate(pos):groups.setdefault(find(i),[]).append(v)
rocks=[]
for vs in groups.values():
 lo=[min(v[j]for v in vs)for j in range(3)];hi=[max(v[j]for v in vs)for j in range(3)];size=[hi[j]-lo[j]for j in range(3)]
 if size[1]<1.5:continue
 rocks.append({'position':[(lo[0]+hi[0])/2,lo[1]+size[1]*.34,(lo[2]+hi[2])/2],'size':[size[0]*.5,size[1]*.65,size[2]*.5]})
def literal(v):
 if isinstance(v,list):return '{'+','.join(map(literal,v))+'}'
 if isinstance(v,float):return format(v,'.9g')
 return json.dumps(v)
lines=['-- Generated from GLB connected components; source unit = one stud.','return {rocks={']
for r in rocks:lines.append(' {position='+literal(r['position'])+',size='+literal(r['size'])+'},')
lines+=['},saplings={']
for x,y in [(-100,-65),(-86,-105),(-55,-143),(72,-126),(106,-102),(110,22),(-111,14)]:lines.append(' '+literal([x,0,-y])+',')
lines+=['}}']
(root/'src/server/World/DeepwoodElderGroveGeometry.luau').write_text('\n'.join(lines)+'\n');print(json.dumps({'rockBodies':len(rocks),'saplings':7}))
