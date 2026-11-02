"""Prepare TD-derived rigid parts without cutting a weapon between moving anchors.

Only Python stdlib. Inputs are pinned existing RPG/TD packages; original files stay
unchanged. Run Blender authoring companion through MCP to close and review cuts.
"""
from pathlib import Path
import struct,json,math,hashlib
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/shared/deepwood-weapon-repair'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def area(f):
 a,b=sub(f[1][0],f[0][0]),sub(f[2][0],f[0][0]);return math.sqrt(sum(v*v for v in (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])))/2

def read(p):
 raw=p.read_bytes();n=struct.unpack_from('<I',raw,12)[0];doc=json.loads(raw[20:20+n]);binary=raw[28+n:]
 def acc(i):
  a=doc['accessors'][i];v=doc['bufferViews'][a['bufferView']];fmt={5126:'f',5125:'I',5123:'H'}[a['componentType']];width={'VEC3':3,'VEC2':2,'SCALAR':1}[a['type']];size=struct.calcsize(fmt)*width
  return [struct.unpack_from('<'+fmt*width,binary,v.get('byteOffset',0)+a.get('byteOffset',0)+j*v.get('byteStride',size))for j in range(a['count'])]
 parts={}
 for node in doc['nodes']:
  if 'mesh' not in node:continue
  assert not any(k in node for k in ('matrix','rotation','scale'))
  mesh=doc['meshes'][node['mesh']];p=mesh['primitives'][0];a=p['attributes'];pos,norm,uv=map(acc,[a['POSITION'],a['NORMAL'],a['TEXCOORD_0']]);ind=acc(p['indices']);offset=node.get('translation',[0,0,0]);faces=[]
  for i in range(0,len(ind),3):faces.append(tuple((tuple(pos[j][c]+offset[c]for c in range(3)),norm[j],uv[j])for (j,)in ind[i:i+3]))
  parts[node['name']]=faces
 return parts

def lerp(a,b,t):
 out=[tuple(x+(y-x)*t for x,y in zip(aa,bb))for aa,bb in zip(a,b)];n=math.sqrt(dot(out[1],out[1]));out[1]=tuple(v/n for v in out[1]);return tuple(out)
def clip(f,normal,offset):
 out=[]
 for a,b in zip(f,f[1:]+f[:1]):
  da,db=dot(a[0],normal)-offset,dot(b[0],normal)-offset
  if da>=0:out.append(a)
  if (da>0 and db<0)or(da<0 and db>0):out.append(lerp(a,b,da/(da-db)))
 return [tuple((out[0],out[i],out[i+1]))for i in range(1,len(out)-1)if area((out[0],out[i],out[i+1]))>1e-13]
def extract(faces,planes):
 candidate=faces;rest=[]
 for normal,offset in planes:
  inside=[]
  for f in candidate:
   inside.extend(clip(f,normal,offset));rest.extend(clip(f,tuple(-x for x in normal),-offset))
  candidate=inside
 return candidate,rest

def groups(faces):
 parents=list(range(len(faces)));by={}
 def find(i):
  while parents[i]!=i:parents[i]=parents[parents[i]];i=parents[i]
  return i
 for i,f in enumerate(faces):
  for v in f:
   k=tuple(round(x,6)for x in v[0])
   if k in by:parents[find(i)]=find(by[k])
   else:by[k]=i
 result={}
 for i,f in enumerate(faces):result.setdefault(find(i),[]).append(f)
 return list(result.values())

def write(path,parts,texture=None):
 binary=bytearray();views=[];accessors=[];nodes=[];meshes=[];records=[]
 def view(data):
  while len(binary)%4:binary.append(0)
  i=len(views);views.append({'buffer':0,'byteOffset':len(binary),'byteLength':len(data)});binary.extend(data);return i
 def access(rows,typ,fmt,ctype):
  v=view(b''.join(struct.pack('<'+fmt*len(r),*r)for r in rows));a={'bufferView':v,'componentType':ctype,'count':len(rows),'type':typ}
  if typ=='VEC3':a.update(min=[min(r[i]for r in rows)for i in range(3)],max=[max(r[i]for r in rows)for i in range(3)])
  accessors.append(a);return len(accessors)-1
 for name,faces in parts.items():
  verts=[v for f in faces for v in f];low=[min(v[0][i]for v in verts)for i in range(3)];high=[max(v[0][i]for v in verts)for i in range(3)];center=[(a+b)/2 for a,b in zip(low,high)]
  attrs={'POSITION':access([sub(v[0],center)for v in verts],'VEC3','f',5126),'NORMAL':access([v[1]for v in verts],'VEC3','f',5126),'TEXCOORD_0':access([v[2]for v in verts],'VEC2','f',5126)}
  idx=access([(i,)for i in range(len(verts))],'SCALAR','I',5125);meshes.append({'name':name,'primitives':[{'attributes':attrs,'indices':idx,'material':0}]});nodes.append({'name':name,'mesh':len(meshes)-1,'translation':center})
  records.append({'name':name,'center':center,'size':[b-a for a,b in zip(low,high)],'triangles':len(faces)})
 mat={'name':'OriginalTDColor','pbrMetallicRoughness':{'baseColorFactor':[1,1,1,1],'metallicFactor':0,'roughnessFactor':1}}
 d={'asset':{'version':'2.0','generator':'TLT weapon ownership repair'},'scene':0,'scenes':[{'nodes':list(range(len(nodes)))}],'nodes':nodes,'meshes':meshes,'materials':[mat],'accessors':accessors,'bufferViews':views}
 if texture:d.update(images=[{'bufferView':view(texture),'mimeType':'image/png'}],textures=[{'source':0}]);mat['pbrMetallicRoughness']['baseColorTexture']={'index':0}
 d['buffers']=[{'byteLength':len(binary)}];js=json.dumps(d,separators=(',',':')).encode();js+=b' '*(-len(js)%4);binary+=b'\0'*(-len(binary)%4)
 path.write_bytes(struct.pack('<4sII',b'glTF',2,28+len(js)+len(binary))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(binary),0x004e4942)+binary)
 return records

def main():
 result={'version':1,'status':'geometry candidate; native import pending','models':{}}
 for kind in ['ogre','warlord']:
  inp=OUT/'inputs'/(kind+'.glb');parts=read(inp);before=sum(area(f)for faces in parts.values()for f in faces);selected=[];owners={}
  planes=([((0,1,0),.595),((0,0,1),-.055),((1,0,0),.19)]if kind=='ogre'else[((0,0,-1),.015),((0,-1,0),-.47),((-1,.5,0),.46)])
  for name,faces in list(parts.items()):
   taken,parts[name]=extract(faces,planes);selected.extend(taken)
   for f in taken:owners[id(f)]=name
  if kind=='ogre':
   clusters=groups(selected);weapon=max(clusters,key=lambda g:sum(area(f)for f in g))
   for cluster in clusters:
    if cluster is not weapon:
     for f in cluster:parts[owners[id(f)]].append(f)
   # The exposed lower grip is fused to the hand in the source. Preserve the
   # closed hand; Blender adds a brown shaft through it to the original head.
   # Collect the original exposed butt below the fingers into the same mesh.
   lower=[];lowerOwners={}
   for name,faces in list(parts.items()):
    taken,parts[name]=extract(faces,[((0,-1,0),-.385),((1,0,0),.44),((0,0,1),.08)])
    lower.extend(taken)
    for f in taken:lowerOwners[id(f)]=name
   if lower:
    clusters=groups(lower);stub=max(clusters,key=lambda g:sum(area(f)for f in g))
    weapon.extend(stub)
    for cluster in clusters:
     if cluster is not stub:
      for f in cluster:parts[lowerOwners[id(f)]].append(f)
   parts['Weapon']=weapon
  else:parts['ArmL'].extend(selected)
  after=sum(area(f)for faces in parts.values()for f in faces);assert abs(after-before)<1e-7,(kind,before,after)
  records=write(OUT/(kind+'-prepared.glb'),parts,(OUT/'inputs'/(kind+'.png')).read_bytes())
  result['models'][kind]={'source':str(inp.relative_to(ROOT)),'sourceSha256':sha(inp),'textureSha256':sha(OUT/'inputs'/(kind+'.png')),'planes':planes,'originalSurfaceArea':before,'preparedSurfaceArea':after,'maxTotalAreaError':abs(after-before),'parts':records,'weaponArm':'ArmR'if kind=='ogre'else'ArmL','shoulder':'Left Shoulder'if kind=='ogre'else'Right Shoulder'}
 (OUT/'geometry.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:{'parts':len(v['parts']),'areaError':v['maxTotalAreaError']}for k,v in result['models'].items()}))
if __name__=='__main__':main()
