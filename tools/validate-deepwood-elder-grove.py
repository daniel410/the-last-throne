"""로컬 GLB 기하·UV·내장 이미지와 Blender 산출물 검증. 엔진 수용과 구별한다."""
from pathlib import Path
import hashlib,json,struct,math
root=Path(__file__).resolve().parents[1]
base=root/'assets/models/deepwood-elder-grove-v1'
raw=(base/'elder-grove.glb').read_bytes()
magic,version,total=struct.unpack_from('<III',raw);assert magic==0x46546c67 and version==2 and total==len(raw)
offset=12;chunks={}
while offset<len(raw):
 size,kind=struct.unpack_from('<II',raw,offset);chunks[kind]=raw[offset+8:offset+8+size];offset+=8+size
scene=json.loads(chunks[0x4e4f534a]);binary=chunks[0x004e4942]
manifest=json.loads((base/'geometry.json').read_text())
assert all('uri'not in b for b in scene.get('buffers',[]))
assert len(scene['images'])==1 and 'bufferView'in scene['images'][0]
assert len(scene['materials'])==1 and 'baseColorTexture'in scene['materials'][0]['pbrMetallicRoughness']
assert len(scene['meshes'])==len(manifest['meshes'])==34
assert not scene.get('animations')and not scene.get('skins')and not scene.get('cameras')
formats={5121:'B',5123:'H',5125:'I',5126:'f'};components={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}
def values(index):
 a=scene['accessors'][index];b=scene['bufferViews'][a['bufferView']];fmt='<'+formats[a['componentType']]*components[a['type']];stride=b.get('byteStride',struct.calcsize(fmt));start=b.get('byteOffset',0)+a.get('byteOffset',0)
 return [struct.unpack_from(fmt,binary,start+i*stride)for i in range(a['count'])]
triangles=0;degenerate=0;uv_count=0;mesh_counts={}
for mesh in scene['meshes']:
 n=0
 for p in mesh['primitives']:
  assert p.get('mode',4)==4
  pos=values(p['attributes']['POSITION']);uv=values(p['attributes']['TEXCOORD_0']);norm=values(p['attributes']['NORMAL']);indices=[x[0]for x in values(p['indices'])]
  assert len(pos)==len(uv)==len(norm)and len(indices)%3==0
  assert all(0<=i<len(pos)for i in indices)
  assert all(all(math.isfinite(v)for v in point)for point in pos)
  assert all(0<=a<=1 and 0<=b<=1 for a,b in uv)
  uv_count+=len(uv)
  for i in range(0,len(indices),3):
   a,b,c=[pos[j]for j in indices[i:i+3]];u=[b[j]-a[j]for j in range(3)];v=[c[j]-a[j]for j in range(3)]
   cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
   if sum(x*x for x in cross)<1e-14:degenerate+=1
  n+=len(indices)//3
 triangles+=n;mesh_counts[mesh['name']]=n
assert degenerate==0,degenerate
assert triangles==sum(m['triangles']for m in manifest['meshes'].values()),triangles
assert max(mesh_counts.values())<10000
report={'scope':'Local GLB structure only; see separate engine evidence for import and world acceptance','meshes':len(mesh_counts),'triangles':triangles,'maximumMeshTriangles':max(mesh_counts.values()),'uvVertices':uv_count,'materials':len(scene['materials']),'embeddedImages':len(scene['images']),'externalURIs':0,'degenerateTriangles':degenerate,'meshesByName':mesh_counts,'sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(base.iterdir())if p.suffix in ['.glb','.png','.json']and p.name!='validation.json'}}
(base/'validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items()if k not in ['sha256','meshesByName']}))
