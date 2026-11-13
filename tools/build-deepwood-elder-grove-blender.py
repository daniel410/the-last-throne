"""Blender MCP 직접 조형: DW-03 콘셉트의 거목 중심 장면. 기존 씬은 보존한다."""
import bpy, bmesh, math, random, json
from mathutils import Vector
rng=random.Random(611203)
s=bpy.data.scenes.new('TLT_Deepwood_ElderGrove_v1');bpy.context.window.scene=s
s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False;s.display_settings.display_device='sRGB'
try:s.render.engine='BLENDER_EEVEE'
except TypeError:s.render.engine='CYCLES';s.cycles.samples=24
s.render.resolution_x=1800;s.render.resolution_y=1200;s.render.resolution_percentage=100
w=bpy.data.worlds.new('ElderGroveWorld');w.use_nodes=True;s.world=w
bg=next(n for n in w.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.23,.30,.37,1);bg.inputs['Strength'].default_value=.5
palette=[(126,83,40),(151,105,55),(180,174,126),(39,82,151),(54,91,44),(95,134,49),(168,173,56),(80,111,49),(171,139,83),(210,184,124),(225,172,57),(63,70,65),(128,51,38),(134,87,155),(255,194,70),(101,128,57)]
image=bpy.data.images.new('ElderGroveAtlas',width=1024,height=1024,alpha=False)
pixels=[]
for y in range(1024):
 v=(y%256)/255;ty=y//256
 for x in range(1024):
  u=(x%256)/255;tile=ty*4+x//256;base=palette[tile]
  n=math.sin(x*12.9898+y*78.233)*43758.5453;n=(n-math.floor(n))-.5
  wave=math.sin(u*math.tau*7+math.sin(v*13)*.65)
  shade=.94+.08*math.sin(v*math.pi)+n*.015
  if tile in [0,1]:
   shade+=.10*wave+.04*math.sin(u*math.tau*19+math.sin(v*21));shade-=.22*max(0,wave-.70)
   if tile==0:shade+=.04*math.cos(v*15+u*2)
  elif tile==2:shade+=.08*math.sin(u*9+v*4)+.04*math.cos(v*18+u*2)
  elif tile in [4,5,6,7,15]:shade+=.16*v-.10*abs(u-.5)+.035*math.sin((u+v)*17)
  elif tile==3:shade+=.09*math.sin(u*19)*math.sin(v*math.pi)
  elif tile==8:shade+=.05*math.sin(u*21+v*14)
  for c in base:pixels.append(max(0,min(1,c/255*shade)))
  pixels.append(1)
image.pixels.foreach_set(pixels);image.update();image.filepath_raw='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/models/deepwood-elder-grove-v1/grove-atlas.png';image.file_format='PNG';image.save();image.pack()
mat=bpy.data.materials.new('ElderGrovePaintedAtlas');mat.use_nodes=True
bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');bsdf.inputs['Roughness'].default_value=.88
tex=mat.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image;mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
buffers={};colliders=[]
def group(name):
 if name not in buffers:buffers[name]={'v':[],'f':[],'uv':[],'smooth':[]}
 return buffers[name]
def face(name,points,tile=0,uv=None,smooth=False):
 b=group(name);start=len(b['v']);b['v']+=list(points);b['f'].append(tuple(range(start,start+len(points))));b['smooth'].append(smooth)
 coords=uv or ([(0,0),(1,0),(1,1),(0,1)]if len(points)==4 else [(0,0),(1,0),(.5,1)])
 b['uv'].append([((tile%4+(a*.92+.04))/4,(tile//4+(c*.92+.04))/4)for a,c in coords])
def tube(name,points,radii,tile=0,sides=14):
 pts=[Vector(p)for p in points];rings=[]
 for i,p in enumerate(pts):
  direction=(pts[min(i+1,len(pts)-1)]-pts[max(i-1,0)]).normalized();up=Vector((0,0,1))
  if abs(direction.dot(up))>.94:up=Vector((1,0,0))
  x=direction.cross(up).normalized();y=direction.cross(x).normalized();ring=[]
  for j in range(sides):
   a=j*math.tau/sides;r=radii[i]*(1+.075*math.sin(j*3.8+i*.7));ring.append(p+(x*math.cos(a)+y*math.sin(a))*r)
  rings.append(ring)
 for i in range(len(rings)-1):
  for j in range(sides):face(name,[rings[i][j],rings[i][(j+1)%sides],rings[i+1][(j+1)%sides],rings[i+1][j]],tile,[(j/sides,i/(len(rings)-1)),((j+1)/sides,i/(len(rings)-1)),((j+1)/sides,(i+1)/(len(rings)-1)),(j/sides,(i+1)/(len(rings)-1))],True)
 face(name,list(reversed(rings[0])),tile,[(.5+.45*math.cos(j*math.tau/sides),.5+.45*math.sin(j*math.tau/sides))for j in range(sides)])
 face(name,rings[-1],tile,[(.5+.45*math.cos(j*math.tau/sides),.5+.45*math.sin(j*math.tau/sides))for j in range(sides)])
def box(name,pos,size,tile=1,angle=0):
 x,y,z=pos;a,b,c=[t/2 for t in size];verts=[]
 for px,py,pz in [(-a,-b,-c),(a,-b,-c),(a,b,-c),(-a,b,-c),(-a,-b,c),(a,-b,c),(a,b,c),(-a,b,c)]:verts.append((x+px*math.cos(angle)-py*math.sin(angle),y+px*math.sin(angle)+py*math.cos(angle),z+pz))
 for inds in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:face(name,[verts[i]for i in inds],tile)
def beam(name,a,b,width,tile=1):tube(name,[a,b],[width/2,width/2],tile,6)
def leaf(name,p,size,tile):
 p=Vector(p);a=rng.random()*math.tau;d=Vector((math.cos(a),math.sin(a),rng.uniform(-.6,.6)))*size;e=Vector((-math.sin(a),math.cos(a),rng.uniform(-.3,.3)))*size*.46
 face(name,[p-d,p-e,p+d,p+e],tile)
def crown(name,center,size,count):
 cx,cy,cz=center;sx,sy,sz=size
 # Solid overlapping leaf masses, with painted leaf surfaces at their silhouette.
 for j in range(count):
  a=rng.random()*math.tau;v=rng.uniform(-1,1);r=math.sqrt(1-v*v)
  p=(cx+math.cos(a)*r*sx,cy+math.sin(a)*r*sy,cz+v*sz)
  leaf(name,p,rng.uniform(min(sx,sy)*.10,min(sx,sy)*.19),rng.choices([4,5,6],[2,6,3])[0])
 rings=[]
 for j in range(1,8):
  latitude=-math.pi/2+j*math.pi/8;r=math.cos(latitude)
  rings.append([(cx+math.cos(i*math.tau/18)*sx*r,cy+math.sin(i*math.tau/18)*sy*r,cz+math.sin(latitude)*sz)for i in range(18)])
 for j in range(len(rings)-1):
  for i in range(18):face(name,[rings[j][i],rings[j][(i+1)%18],rings[j+1][(i+1)%18],rings[j+1][i]],4,[(i/18,j/6),((i+1)/18,j/6),((i+1)/18,(j+1)/6),(i/18,(j+1)/6)],smooth=True)
 for i in range(18):
  face(name,[(cx,cy,cz-sz),rings[0][(i+1)%18],rings[0][i]],4,[(.5,.2)]*3,smooth=True)
  face(name,[rings[-1][i],rings[-1][(i+1)%18],(cx,cy,cz+sz)],5,[(.5,.8)]*3,smooth=True)
def rock(name,p,size,tile=2):
 x,y,z=p;sx,sy,sz=size;n=7;low=[];high=[]
 for j in range(n):
  a=j*math.tau/n;f=rng.uniform(.85,1.15);low.append((x+math.cos(a)*sx*f,y+math.sin(a)*sy*f,z));high.append((x+math.cos(a)*sx*.72*f,y+math.sin(a)*sy*.72*f,z+sz*rng.uniform(.7,1)))
 for j in range(n):face(name,[low[j],low[(j+1)%n],high[(j+1)%n],high[j]],tile)
 face(name,high,tile,[(.5+.45*math.cos(j*math.tau/n),.5+.45*math.sin(j*math.tau/n))for j in range(n)])
def banner(name,x,y,z=0):
 beam(name,(x,y,z),(x,y,z+23),.65);beam(name,(x-3.5,y,z+22),(x+3.5,y,z+22),.55)
 for i in range(5):
  a=i/5;b=(i+1)/5;xa=x-3.2+a*6.4;xb=x-3.2+b*6.4
  face(name,[(xa,y+.25*math.sin(a*8),z+21),(xb,y+.25*math.sin(b*8),z+21),(xb,y+.25*math.sin(b*8),z+8+abs(b-.5)*3),(xa,y+.25*math.sin(a*8),z+8+abs(a-.5)*3)],3)
 box(name,(x,y-.18,z+14),(3.8,.25,.65),10)
 for dx,h in [(-1.5,1.4),(0,2.3),(1.5,1.4)]:box(name,(x+dx,y-.19,z+15),( .65,.25,h),10)
def barrel(name,x,y,z=0):
 tube(name,[(x,y,z),(x,y,z+1),(x,y,z+5),(x,y,z+6)],[2.5,3,3,2.5],1,12)
 for h in [1.1,4.9]:tube(name,[(x,y,z+h),(x,y,z+h+.3)],[3.08,3.08],11,12)
def crate(name,x,y,z=0):
 box(name,(x,y,z+2.6),(6,5,5.2));box(name,(x,y,z+5.3),(6.2,5.2,.4))
 for dx in [-2,2]:box(name,(x+dx,y-2.55,z+2.6),(.5,.2,5.3),0)
 beam(name,(x-2.4,y-2.7,z+.4),(x+2.4,y-2.7,z+4.8),.45,9)
# Main tree: authored winding trunk, branches, asymmetrical root fan.
tube('ElderTrunk',[(0,0,0),(-6,2,17),(-9,1,38),(-3,5,61),(4,9,81),(0,10,101)],[20,17,13,10,7,2],0,22)
colliders.append({'name':'Trunk','a':[0,0,0],'b':[-8,1,37],'radius':12})
for i in range(10):
 a=i*math.tau/10+.18
 if i==6:a-=.35
 if i==7:a-=.95
 if i==8:a+=.50
 front=math.sin(a)<-.15;length=40 if front else rng.uniform(55,85);end=(math.cos(a)*length,math.sin(a)*length,.7)
 points=[];radii=[]
 for j in range(9):
  t=j/8;angle=a+math.sin(t*math.pi)*(.23 if i%2 else -.27)
  points.append((math.cos(angle)*length*t-4*(1-t),math.sin(angle)*length*t,10*(1-t)**2+.6))
  radii.append(8*(1-t)**1.2+.5)
 tube('ElderRoot'+str(i).zfill(2),points,radii,0,14)
 colliders.append({'name':'Root'+str(i),'points':[list(p)for p in points],'radii':[r*.65 for r in radii]})
for i in range(9):
 a=i*2.399;start=(-5,4,48+i%3*10);end=(math.cos(a)*rng.uniform(48,76),math.sin(a)*rng.uniform(38,65),90+rng.uniform(-3,21))
 mid=(end[0]*.5,end[1]*.5,65+i%3*9);tube('ElderBranches',[start,mid,end],[7,5,1.5],0,12)
 crown('ElderCrown'+str(i%3),end,(29+rng.random()*11,26+rng.random()*8,16+rng.random()*8),900)
crown('ElderCrown3',(-2,12,111),(38,33,22),1200)
# Blue/gold shelter nestled in front of the trunk; open central access.
for x in [-26,14]:
 for y in [-27,-54]:
  box('RootOutpost',(x,y,1),(4.5,4.5,2),2);beam('RootOutpost',(x,y,2),(x,y,21),1.4,0)
  beam('RootOutpost',(x,y,15),(x+(-4 if x>0 else 4),y,21),1.1)
for j in range(9):box('RootOutpost',(-6+(j-4)*5.2,-40,.38),(5,30,.7))
for j in range(10):
 xa=-30+j*4.8;xb=xa+4.8
 za=21+3*math.sin(j/10*math.pi);zb=21+3*math.sin((j+1)/10*math.pi)
 face('OutpostCanopy',[(xa,-24,za+3),(xb,-24,zb+3),(xb,-57,zb-3),(xa,-57,za-3)],3)
 face('OutpostCanopy',[(xa,-57,za-3),(xb,-57,zb-3),(xb,-57,zb-5.5),(xa,-57,za-5.5)],3)
 beam('OutpostCanopy',(xa,-57,za-3),(xb,-57,zb-3),.4,10)
box('OutpostCanopy',(-6,-57.2,19),(8,.28,.8),10)
for x,h in [(-9,2),(-6,3.2),(-3,2)]:box('OutpostCanopy',(x,-57.2,20.4),(1,.28,h),10)
beam('RootOutpost',(-30,-24,24),(18,-24,24),1.2)
for x,y in [(-19,-33),(-11,-32),(3,-31),(8,-41),(-20,-44)]:crate('SupplyProps',x,y)
for x,y in [(-29,-29),(-34,-32),(-35,-39)]:barrel('SupplyProps',x,y)
# Map table and garden/supply scene arranged around the open court.
box('MapTable',(70,-100,4.3),(13,8,.9));box('MapTable',(70,-100,4.84),(10.8,6.6,.15),9)
for x in [65,75]:
 for y in [-102.5,-97.5]:box('MapTable',(x,y,2),(1,1,4))
for x,y in [(-43,-61),(23,-52),(88,-67),(-61,-164)]:banner('Standards',x,y)
# Gate side piers and arch blocks frame the approach at Selene's side.
for x in [-100,-68]:
 for j in range(5):box('Gateway',(x,-152,j*3+1.5),(5.5,6,2.85),2)
 for y in [-158,-145]:rock('GardenStone',(x,y,0),(3.3,3.2,3.3))
for i in range(11):
 a=math.pi-i*math.pi/10;center=(-84+16*math.cos(a),-152,14+16*math.sin(a))
 # Curved voussoirs with radial seams, not a rectangular lintel.
 aa=a-.15;bb=a+.15;r1=13;r2=18
 points=[]
 for y in [-155,-149]:
  for r,a2 in [(r1,aa),(r2,aa),(r2,bb),(r1,bb)]:points.append((-84+r*math.cos(a2),y,14+r*math.sin(a2)))
 for inds in [(0,1,2,3),(7,6,5,4),(0,4,5,1),(1,5,6,2),(2,6,7,3),(3,7,4,0)]:face('Gateway',[points[k]for k in inds],2)
# Irregular moss/grass skin: thin presentation over the retained walkable floor.
for i in range(64):
 a=i*math.tau/64;b=(i+1)*math.tau/64;r=155+7*math.sin(a*7)
 face('GroveGround',[(8,-45,.015),(8+math.cos(a)*r,-45+math.sin(a)*r*1.06,.015),(8+math.cos(b)*r,-45+math.sin(b)*r*1.06,.015)],7,[(.5,.5),(.5+.46*math.cos(a),.5+.46*math.sin(a)),(.5+.46*math.cos(b),.5+.46*math.sin(b))])
# Main curved path and court are thin visual surfaces above the retained floor.
path=[(-82,-198),(-84,-160),(-67,-130),(-29,-110),(17,-98),(40,-80),(64,-67),(95,-57),(124,-50),(156,-29)]
for i in range(len(path)-1):
 ax,ay=path[i];bx,by=path[i+1];dx=bx-ax;dy=by-ay;l=math.hypot(dx,dy);nx=-dy/l;ny=dx/l
 face('CourtGround',[(ax+nx*10,ay+ny*10,.04),(ax-nx*10,ay-ny*10,.04),(bx-nx*10,by-ny*10,.04),(bx+nx*10,by+ny*10,.04)],8)
 steps=max(1,int(l/5))
 for j in range(steps):
  t=(j+.5)/steps
  for side in [-1,0,1]:
   x=ax+dx*t+nx*(side*5+rng.uniform(-.7,.7));y=ay+dy*t+ny*(side*5+rng.uniform(-.7,.7))
   rock('CourtPavers',(x,y,.045),(rng.uniform(1.8,2.5),rng.uniform(1.7,2.6),.12),2)
for i in range(24):
 a=i*math.tau/24;face('CourtGround',[(27,-83,.035),(27+math.cos(a)*40,-83+math.sin(a)*28,.035),(27+math.cos(a+math.tau/24)*40,-83+math.sin(a+math.tau/24)*28,.035)],8)
# Nested vegetation clusters and stone shoulders; focal area is kept open.
for i in range(42):
 a=i*2.399;r=rng.uniform(100,145);x=math.cos(a)*r;y=math.sin(a)*r-32
 if y<-100 and -115<x<75:continue
 if x>65 and -100<y<30:continue
 rock('GardenStone',(x,y,0),(rng.uniform(2,6),rng.uniform(2,5),rng.uniform(2,5)))
 for j in range(16):leaf('GroundCover',(x+rng.uniform(-6,6),y+rng.uniform(-6,6),rng.uniform(.4,2)),rng.uniform(1,2.4),rng.choice([7,15]))
for x,y in [(-100,-65),(-86,-105),(-55,-143),(72,-126),(106,-102),(110,22),(-111,14)]:
 tube('GroveSaplings',[(x,y,0),(x-2,y+1,15),(x+1,y,27)],[2.3,1.8,.5],0,9)
 crown('GroveSaplings',(x,y,27),(13,12,9),350)
for x,y in [(-40,-45),(20,-48),(-72,-151),(82,-64)]:
 beam('Lanterns',(x,y,0),(x,y,12),.6,0);beam('Lanterns',(x,y,12),(x-2,y,12),.5,0)
 box('Lanterns',(x-2,y,9.6),(2.1,2.1,3.1),14)
 for dx in [-1.15,1.15]:beam('Lanterns',(x-2+dx,y-1.1,8),(x-2+dx,y-1.1,11.5),.18,11)
# Bushes, ferns, flowers and a lived-in supply corner frame the court.
for i,(x,y) in enumerate([(-119,-144),(-117,-128),(-106,-108),(-92,-94),(-70,-70),(-58,-61),(-45,-72),(-36,-103),(-27,-124),(13,-123),(40,-119),(90,-109),(112,-92),(120,-75),(138,-59),(129,-9),(94,19),(-90,20),(-118,-18),(-100,-40)]):
 crown('GardenShrubs'+str(i%2),(x,y,3.2),(5.2,4.6,3.2),160)
 for j in range(5):
  xx=x+rng.uniform(-5,5);yy=y+rng.uniform(-5,5)
  for k in range(5):
   a=k*math.tau/5;leaf('Wildflowers',(xx+math.cos(a)*.5,yy+math.sin(a)*.5,1.1),.55,13 if j%2 else 9)
for x,y in [(-53,-81),(-65,-92),(14,-75),(84,-108),(118,-79)]:
 for j in range(9):
  a=j*math.tau/9;end=(x+math.cos(a)*5,y+math.sin(a)*5,.6)
  beam('Ferns',(x,y,.4),(x+math.cos(a)*3,y+math.sin(a)*3,2.4),.18,15)
  for k in range(1,5):
   t=k/5;leaf('Ferns',(x+math.cos(a)*5*t,y+math.sin(a)*5*t,math.sin(t*math.pi)*2.3),1.1*(1-t*.6),15)
# A small wagon and stacked provision barrels, away from the approach.
box('SupplyCart',(-64,-66,4),(15,8,1.4))
for x in [-71,-57]:
 for y in [-70,-62]:tube('SupplyCart',[(x,y,0),(x,y,8)],[.5,.5],0,6)
for x in [-71,-57]:
 for j in range(3):box('SupplyCart',(x,-66,4.8+j*1.1),(.8,9,.8))
for y in [-70.5,-61.5]:
 # Vertical wheels around the cart's cross-axis.
 pts=[]
 for j in range(16):
  a=j*math.tau/16;pts.append((-64+math.cos(a)*3.2,y,3.3+math.sin(a)*3.2))
 for j in range(16):beam('SupplyCart',pts[j],pts[(j+1)%16],.65,0)
 for j in range(4):beam('SupplyCart',(-64,y,3.3),pts[j*4],.35,1)
for x,y in [(-67,-65),(-62,-65)]:barrel('SupplyCart',x,y,5)
# Texture/UV meshes grouped into compact reusable logical chunks.
metadata={}
for name,b in buffers.items():
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(b['v'],[],b['f']);mesh.update();uv=mesh.uv_layers.new(name='AtlasUV')
 for poly,coords,smooth in zip(mesh.polygons,b['uv'],b['smooth']):
  poly.use_smooth=smooth
  for li,coord in zip(poly.loop_indices,coords):uv.data[li].uv=coord
 bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free();mesh.update()
 o=bpy.data.objects.new(name,mesh);s.collection.objects.link(o);o.data.materials.append(mat)
 o['TLTComponent']=name
 metadata[name]={'objectName':o.name,'vertices':len(mesh.vertices),'triangles':sum(len(p.vertices)-2 for p in mesh.polygons),'min':[min(v[i]for v in b['v'])for i in range(3)],'max':[max(v[i]for v in b['v'])for i in range(3)]}
s['ElderGroveManifest']=json.dumps({'version':1,'originRoblox':[-280,18.08,-1728],'axis':'Blender x,y,z -> Roblox x,z,-y','meshes':metadata,'colliders':colliders,'atlas':'grove-atlas.png','colorManagement':'Standard/sRGB/None/Exposure0/Gamma1/CurvesOff'})
sun_data=bpy.data.lights.new('GroveSun','SUN');sun_data.energy=2.6;sun_data.angle=.22
sun=bpy.data.objects.new('GroveSun',sun_data);s.collection.objects.link(sun);sun.rotation_euler=(.40,-.53,-.45)
fill_data=bpy.data.lights.new('GroveFill','AREA');fill_data.energy=4200;fill_data.size=180
fill=bpy.data.objects.new('GroveFill',fill_data);s.collection.objects.link(fill);fill.location=(90,-160,130)
cam_data=bpy.data.cameras.new('GroveConceptCamera');cam=bpy.data.objects.new('GroveConceptCamera',cam_data);s.collection.objects.link(cam)
cam.location=(205,-335,235);target=Vector((8,-58,40));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();cam_data.type='ORTHO';cam_data.ortho_scale=415;s.camera=cam
s.render.filepath='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/models/deepwood-elder-grove-v1/grove-preview.png'
print(json.dumps({'scene':s.name,'meshes':len(metadata),'triangles':sum(v['triangles']for v in metadata.values()),'maximumMeshTriangles':max(v['triangles']for v in metadata.values())}))
