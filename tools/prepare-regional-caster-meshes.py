"""MR-01: clip fused staff surfaces precisely; preserve authored UVs/surface area."""
from pathlib import Path
import importlib.util, struct, json, hashlib, math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/animations/regional-casters-v1'
spec=importlib.util.spec_from_file_location('mesh',ROOT/'tools/repair-deepwood-weapons.py')
mesh=importlib.util.module_from_spec(spec);spec.loader.exec_module(mesh)
CONFIG={
 'QueenIceElf':('frozen-vale','queen_ice_elf',(.18,.17,-.375,.36,.021,.70,.23,.025)),
 'VolcanoShaman':('ember-caldera','volcano_shaman',(.293,.035,-.09,-.10,.033,.66,.25,-.055)),
 'KingVolcanoShaman':('ember-caldera','king_volcano_shaman',(.30,.035,-.13,-.04,.032,.68,.25,-.055)),
}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def parse(path):
 b=path.read_bytes();n=struct.unpack_from('<I',b,12)[0];d=json.loads(b[20:20+n]);return d,b[28+n:]
def write_jpeg(path,parts,texture):
 records=mesh.write(path,parts,texture)
 d,b=parse(path);d['images'][0]['mimeType']='image/jpeg'
 js=json.dumps(d,separators=(',',':')).encode();js+=b' '*(-len(js)%4)
 path.write_bytes(struct.pack('<4sII',b'glTF',2,28+len(js)+len(b))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(b),0x004e4942)+b)
 return records
report={}
for kind,(region,key,staff)in CONFIG.items():
 geometry=ROOT/f'assets/shared/td-{region}/source/{key}/geometry.json'
 meta=json.loads(geometry.read_text());source=OUT/'inputs'/(kind+'.glb')
 assert sha(source)==meta['sourceSha256'],kind
 d,b=parse(source)
 def acc(index):
  a=d['accessors'][index];v=d['bufferViews'][a['bufferView']]
  fmt={5126:'f',5123:'H',5125:'I'}[a['componentType']];width={'VEC3':3,'VEC2':2,'SCALAR':1}[a['type']];size=struct.calcsize(fmt)*width
  return [struct.unpack_from('<'+fmt*width,b,v.get('byteOffset',0)+a.get('byteOffset',0)+i*v.get('byteStride',size))for i in range(a['count'])]
 node=d['nodes'][0];assert node.get('matrix')==[1.,0.,0.,0.,0.,1.,0.,0.,0.,0.,1.,0.,0.,0.,0.,1.]
 primitive=d['meshes'][0]['primitives'][0];attrs=primitive['attributes'];positions=acc(attrs['POSITION']);normals=acc(attrs['NORMAL']);uvs=acc(attrs['TEXCOORD_0']);indices=acc(primitive['indices'])
 origin=meta['normalization']['sourceFeetOrigin'];height=meta['normalization']['sourceHeight']
 points=[tuple((p[i]-origin[i])/height for i in range(3))for p in positions]
 faces=[]
 for i in range(0,len(indices),3):
  verts=[]
  for (j,)in indices[i:i+3]:
   normal=normals[j];length=math.sqrt(sum(x*x for x in normal));normal=tuple(x/length for x in normal)if length>1e-12 else(0,1,0)
   verts.append((points[j],normal,uvs[j]))
  if mesh.area(tuple(verts))>1e-13:faces.append(tuple(verts))
 x,dx,y,dy,r,headZ,headX,headY=staff
 shaft,skin=mesh.extract(faces,[((0,-1,0),-headZ),((1,-dx,0),x-r),((-1,dx,0),-x-r),((0,dy,1),-y-r),((0,-dy,-1),y-r)])
 head,skin=mesh.extract(skin,[((0,1,0),headZ),((1,0,0),headX),((0,0,1),-headY)])
 staff_faces=shaft+head
 before=sum(mesh.area(f)for f in faces);after=sum(mesh.area(f)for f in skin+staff_faces)
 assert abs(before-after)<1e-7 and len(staff_faces)>100,kind
 material=d['materials'][primitive.get('material',0)];texture_index=material['pbrMetallicRoughness']['baseColorTexture']['index'];image=d['images'][d['textures'][texture_index]['source']];assert image['mimeType']=='image/jpeg'
 view=d['bufferViews'][image['bufferView']];texture=b[view.get('byteOffset',0):view.get('byteOffset',0)+view['byteLength']]
 output=OUT/(kind+'-partitioned.glb');parts=write_jpeg(output,{'Skin':skin,'Staff':staff_faces},texture)
 report[kind]={'source':str(source.relative_to(ROOT)),'sourceSha256':sha(source),'normalization':meta['normalization'],'sourceTriangles':len(faces),'partitioned':parts,'surfaceAreaError':abs(before-after),'partitionedSha256':sha(output),'staffPrism':staff}
(OUT/'partition.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:{'skin':v['partitioned'][0]['triangles'],'staff':v['partitioned'][1]['triangles'],'areaError':v['surfaceAreaError']}for k,v in report.items()}))
