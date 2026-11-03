"""Validate exported MR-01 GLBs independently of Blender's live scene.

No third-party dependencies. Tests asset structure and exported skinning matrices;
it does not prove Roblox import, runtime animation wiring or art acceptance.
"""
from pathlib import Path
import argparse,bisect,json,math,struct,hashlib
ROOT=Path(__file__).resolve().parents[1]
ASSETS=ROOT/'assets/animations/regional-casters-v1'
CLIPS={'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned','Exposed','Return','Interrupted'}
checks=0
NATIVE={}
def check(value,label):
 global checks
 checks+=1
 assert value,label

def identity():return [[float(i==j)for j in range(4)]for i in range(4)]
def mul(a,b):return [[sum(a[i][k]*b[k][j]for k in range(4))for j in range(4)]for i in range(4)]
def inverse_rigid(m):
 r=identity()
 for i in range(3):
  for j in range(3):r[i][j]=m[j][i]
  r[i][3]=-sum(m[j][i]*m[j][3]for j in range(3))
 return r

def point(m,p):return tuple(sum(m[i][j]*p[j]for j in range(3))+m[i][3]for i in range(3))
def mat(values):return [[values[j*4+i]for j in range(4)]for i in range(4)]
def trs(t,q,s):
 x,y,z,w=q;length=math.sqrt(sum(v*v for v in q));x,y,z,w=[v/length for v in q]
 r=[[1-2*y*y-2*z*z,2*x*y-2*z*w,2*x*z+2*y*w,t[0]],
    [2*x*y+2*z*w,1-2*x*x-2*z*z,2*y*z-2*x*w,t[1]],
    [2*x*z-2*y*w,2*y*z+2*x*w,1-2*x*x-2*y*y,t[2]], [0,0,0,1]]
 for i in range(3):
  for j in range(3):r[i][j]*=s[j]
 return r

def distance(a,b):return math.sqrt(sum((x-y)**2 for x,y in zip(a,b)))
def slerp(a,b,t):
 dot=sum(x*y for x,y in zip(a,b))
 if dot<0:b=[-x for x in b];dot=-dot
 if dot>.9995:
  q=[x+(y-x)*t for x,y in zip(a,b)];length=math.sqrt(sum(x*x for x in q));return [x/length for x in q]
 angle=math.acos(max(-1,min(1,dot)));a_weight=math.sin((1-t)*angle)/math.sin(angle);b_weight=math.sin(t*angle)/math.sin(angle)
 return [x*a_weight+y*b_weight for x,y in zip(a,b)]

def load(path):
 b=path.read_bytes();n=struct.unpack_from('<I',b,12)[0];return json.loads(b[20:20+n]),b[28+n:]

def validate(kind):
 start=checks;path=ASSETS/(kind+'-rigged.glb');doc,binary=load(path)
 accessors={}
 def acc(index):
  if index in accessors:return accessors[index]
  a=doc['accessors'][index];v=doc['bufferViews'][a['bufferView']];fmt={5126:'f',5125:'I',5123:'H',5121:'B'}[a['componentType']];width={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']];size=struct.calcsize(fmt)*width
  accessors[index]=[struct.unpack_from('<'+fmt*width,binary,v.get('byteOffset',0)+a.get('byteOffset',0)+i*v.get('byteStride',size))for i in range(a['count'])]
  return accessors[index]
 names={n.get('name'):i for i,n in enumerate(doc['nodes'])};skin=doc['skins'][0];joints=skin['joints'];bind=[mat(row)for row in acc(skin['inverseBindMatrices'])]
 parents={j:i for i,n in enumerate(doc['nodes'])for j in n.get('children',[])}
 for side in ['R','L']:
  check(parents[names['Forearm'+side]]==names['Upper'+side],kind+' independent elbow '+side)
  check(parents[names['Hand'+side]]==names['Forearm'+side],kind+' independent wrist '+side)
 check(parents[names['Staff']]==names['HandR'],kind+' staff wrist ownership')
 animations={a['name']:a for a in doc.get('animations',[])}
 check(set(animations)==CLIPS,kind+' exactly ten intended clips, no unrelated user actions')
 objects={}
 for node in doc['nodes']:
  if 'mesh'not in node:continue
  p=doc['meshes'][node['mesh']]['primitives'][0];a=p['attributes'];vertices=acc(a['POSITION']);weights=acc(a['WEIGHTS_0']);indices=acc(a['JOINTS_0'])
  check(all(all(math.isfinite(x)for x in row)for row in vertices),kind+' finite positions')
  for row in weights:check(abs(sum(row)-1)<1e-5 and min(row)>=0,kind+' normalized skin weights')
  check(all(all(i<len(joints)for i in row)for row in indices),kind+' joint indices')
  role='Staff' if node['name'].endswith('__Staff')else'Skin';objects[role]=(vertices,indices,weights)
  if role=='Staff':
   for js,ws in zip(indices,weights):check(all(joints[j]==names['Staff']for j,w in zip(js,ws)if w>1e-6),kind+' entire staff assembly has one owner')
 check(set(objects)=={'Skin','Staff'},kind+' two explicit meshes')
 def world(animation=None,time=0):
  changed={}
  if animation:
   for ch in animation['channels']:
    sampler=animation['samplers'][ch['sampler']];times=acc(sampler['input']);values=acc(sampler['output']);assert sampler.get('interpolation','LINEAR')in ['LINEAR','STEP'],kind+' supported glTF interpolation'
    i=max(0,min(len(times)-2,bisect.bisect_right([x[0]for x in times],time)-1));t=max(0,min(1,(time-times[i][0])/(times[i+1][0]-times[i][0])))
    if sampler.get('interpolation')=='STEP':t=0
    field=ch['target']['path'];value=slerp(values[i],values[i+1],t)if field=='rotation'else[x+(y-x)*t for x,y in zip(values[i],values[i+1])]
    changed.setdefault(ch['target']['node'],{})[field]=value
  cache={}
  def get(i):
   if i in cache:return cache[i]
   n=doc['nodes'][i];c=changed.get(i,{})
   local=mat(n['matrix'])if'matrix'in n else trs(c.get('translation',n.get('translation',[0,0,0])),c.get('rotation',n.get('rotation',[0,0,0,1])),c.get('scale',n.get('scale',[1,1,1])))
   cache[i]=mul(get(parents[i]),local)if i in parents else local
   return cache[i]
  return [get(i)for i in joints]
 def deform(role,index,matrices):
  vs,js,ws=objects[role];out=[0,0,0]
  for j,w in zip(js[index],ws[index]):
   if w:
    p=point(matrices[j],vs[index]);out=[x+w*y for x,y in zip(out,p)]
  return out
 rest_m=[mul(m,ib)for m,ib in zip(world(),bind)]
 rest={role:[deform(role,i,rest_m)for i in range(len(obj[0]))]for role,obj in objects.items()}
 staffBy={tuple(round(x,5)for x in p):i for i,p in enumerate(rest['Staff'])}
 grip=[];feet=[]
 wrist_height={'QueenIceElf':.58,'VolcanoShaman':.525,'KingVolcanoShaman':.51}[kind]
 for i,p in enumerate(rest['Skin']):
  key=tuple(round(x,5)for x in p)
  if key in staffBy and abs(p[1]-wrist_height)<.054:grip.append((i,staffBy[key]))
  if p[1]<.20:feet.append(i)
 check(len(grip)>3,kind+' measurable shared grip seam')
 max_gap=0;max_foot=0;max_rigidity=0
 staff_indices=[min(range(len(rest['Staff'])),key=lambda i:rest['Staff'][i][1]),max(range(len(rest['Staff'])),key=lambda i:rest['Staff'][i][1])]
 original_length=distance(*(rest['Staff'][i]for i in staff_indices))
 for clip,animation in animations.items():
  duration=max(acc(s['input'])[-1][0]for s in animation['samplers'])
  for hz in [30,60,144]:
   for step in range(hz+1):
    matrices=[mul(m,ib)for m,ib in zip(world(animation,duration*step/hz),bind)]
    gap=max(distance(deform('Skin',a,matrices),deform('Staff',b,matrices))for a,b in grip)
    foot=max(distance(deform('Skin',i,matrices),rest['Skin'][i])for i in feet[::max(1,len(feet)//10)])
    rigid=abs(distance(*(deform('Staff',i,matrices)for i in staff_indices))-original_length)
    max_gap=max(max_gap,gap);max_foot=max(max_foot,foot);max_rigidity=max(max_rigidity,rigid)
    check(gap<.0001,kind+' '+clip+' grip seam at '+str(hz)+'Hz')
    check(foot<.0001,kind+' '+clip+' fixed robe feet')
    check(rigid<.0001,kind+' '+clip+' rigid staff head-to-shaft')
  if clip in ['Attack','AttackAlt','Heavy','HeavyAlt']:
   for bone in ['UpperR','ForearmR','HandR']:
    i=joints.index(names[bone]);a=world(animation,duration*.4)[i];c=world(animation,duration*.62)[i]
    check(max(abs(a[r][col]-c[r][col])for r in range(3)for col in range(3))>.01,kind+' '+clip+' articulated '+bone)
 rest_world=world();joint_lookup={index:i for i,index in enumerate(joints)}
 fixture={'bones':[],'poses':[]}
 for i,index in enumerate(joints):
  parent=parents.get(index);pi=joint_lookup.get(parent)
  fixture['bones'].append({'name':doc['nodes'][index]['name'],'parent':doc['nodes'][parent]['name']if pi is not None else '',
                           'rest':rest_world[i],'bind':bind[i]})
 for clip,animation in animations.items():
  duration=max(acc(s['input'])[-1][0]for s in animation['samplers'])
  for phase in ([.4,.62,.78]if clip in ['Attack','AttackAlt','Heavy','HeavyAlt']else[0,.5,1]):
   fixture['poses'].append({'clip':clip,'phase':phase,'world':world(animation,duration*phase)})
 NATIVE[kind]=fixture
 return {'checks':checks-start,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'gripPairs':len(grip),'maxGripGap':max_gap,'maxFootMotion':max_foot,'maxStaffLengthError':max_rigidity,'triangles':sum(len(acc(doc['meshes'][n['mesh']]['primitives'][0]['indices']))//3 for n in doc['nodes']if'mesh'in n),'clips':sorted(animations)}

if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path);parser.add_argument('--native-fixture',type=Path);args=parser.parse_args()
 models={kind:validate(kind)for kind in ['QueenIceElf','VolcanoShaman','KingVolcanoShaman']}
 report={'workId':'MR-01','scope':'exported GLB CPU skinning, not Roblox runtime','checks':checks,'pass':True,'models':models}
 if args.native_fixture:args.native_fixture.write_text(json.dumps(NATIVE,separators=(',',':'))+'\n')
 if args.output:args.output.write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(report))
