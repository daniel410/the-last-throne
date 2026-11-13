"""Blender MCP 전용: 기존 장면을 보존하고 Deepwood 건축10종을 직접 조형한다."""
import bpy, math, json, random
from mathutils import Vector, Matrix

previous_scene=bpy.context.scene
scene=bpy.data.scenes.new('TLT_Deepwood_Architecture_20261112')
bpy.context.window.scene=scene
scene.view_settings.view_transform='Standard'
scene.view_settings.look='None'
scene.view_settings.exposure=0
scene.view_settings.gamma=1
scene.view_settings.use_curve_mapping=False
scene.display_settings.display_device='sRGB'
try: scene.render.engine='BLENDER_EEVEE'
except TypeError: scene.render.engine='CYCLES';scene.cycles.samples=24
scene.render.resolution_x=1800;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
world=bpy.data.worlds.new('DeepwoodArchitectureWorld');world.use_nodes=True;scene.world=world
next(n for n in world.node_tree.nodes if n.type=='BACKGROUND').inputs['Color'].default_value=(.20,.23,.19,1)
next(n for n in world.node_tree.nodes if n.type=='BACKGROUND').inputs['Strength'].default_value=.6
P={'stone':(143,147,118),'light':(190,181,143),'moss':(77,116,57),'wood':(118,80,43),
 'dark':(70,47,27),'blue':(36,78,147),'gold':(226,179,70),'red':(127,52,40),'cloth':(196,175,128),
 'iron':(65,77,71),'root':(79,63,41),'warm':(235,191,109)}
models={};materials={};state={};rng=random.Random(112061)
S=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def linear(n):
 v=n/255
 return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
def material(color,kind):
 key=(color,kind)
 if key not in materials:
  m=bpy.data.materials.new('DW_'+kind+'_'+str(color));m.use_nodes=True
  shader=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
  rgba=tuple(linear(n)for n in color)+(1,)
  shader.inputs['Base Color'].default_value=rgba;shader.inputs['Roughness'].default_value=.78
  m.diffuse_color=rgba;materials[key]=m
 return materials[key]
def begin(name,index):
 state['name']=name;state['offset']=Vector(((index%5)*65,-(index//5)*75,0))
 collection=bpy.data.collections.new('DW_'+name);scene.collection.children.link(collection)
 state['collection']=collection;models[name]=[]
def part(name,pos,size,key='wood',kind='Wood',shape='Block',rotation=(0,0,0),soft=False,matrix=None):
 color=P[key]if isinstance(key,str)else key
 if shape=='Wedge':
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
  faces=[(0,1,3,2),(2,3,5,4),(0,2,4),(1,5,3),(0,4,5,1)]
 elif shape=='Cylinder':
  verts=[]
  for x in [-.5,.5]:
   for i in range(24):verts.append((x,math.cos(i*math.tau/24)*.5,math.sin(i*math.tau/24)*.5))
  faces=[tuple(reversed(range(24))),tuple(range(24,48))]+[(i,(i+1)%24,(i+1)%24+24,i+24)for i in range(24)]
 elif shape=='Ball':
  verts=[]
  for j in range(7):
   a=math.pi*j/6
   for i in range(12):verts.append((math.sin(a)*math.cos(i*math.tau/12)*.5,math.cos(a)*.5,math.sin(a)*math.sin(i*math.tau/12)*.5))
  faces=[(j*12+i,j*12+(i+1)%12,(j+1)*12+(i+1)%12,(j+1)*12+i)for j in range(6)for i in range(12)]
 else:
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,.5,-.5),(-.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(.5,.5,.5),(-.5,.5,.5)]
  faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)]
 mesh=bpy.data.meshes.new('DW_'+name);mesh.from_pydata([S@Vector(v)for v in verts],[],faces);mesh.update()
 o=bpy.data.objects.new(state['name']+'_'+name,mesh);state['collection'].objects.link(o)
 rx,ry,rz=rotation
 R=matrix if matrix is not None else Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z')
 o.matrix_world=Matrix.Translation(state['offset']+S@Vector(pos))@(S@R@S.inverted()).to_4x4()
 o.scale=(size[0],size[2],size[1]);o.data.materials.append(material(color,kind))
 row={'name':name,'shape':shape,'material':kind,'size':list(size),'color':list(color),
      'cf':list(pos)+[R[i][j]for i in range(3)for j in range(3)],'solid':not soft}
 o['DeepwoodPart']=json.dumps(row);models[state['name']].append(row)
 return o
def beam(name,a,b,width,key='wood',soft=False):
 a,b=Vector(a),Vector(b);z=(b-a).normalized();up=Vector((0,1,0))
 if abs(z.dot(up))>.99:up=Vector((1,0,0))
 x=up.cross(z).normalized();y=z.cross(x).normalized();R=Matrix((x,y,z)).transposed()
 return part(name,(a+b)/2,(width,width,(b-a).length),key,soft=soft,matrix=R)
def crate(x,z,y=0):
 part('Chest',(x,y+2,z),(4.8,4,4),'wood','WoodPlanks')
 for side in [-1,1]:
  part('ChestBand',(x+side*1.6,y+2,z),(.3,4.2,4.15),'dark')
 beam('ChestDiagonal',(x-2,y+.4,z+2.05),(x+2,y+3.6,z+2.05),.35,'light')
def banner(x,z,y=0,hostile=False,broken=False):
 h=8 if broken else 14
 part('StandardPost',(x,y+h/2,z),(.55,h,.55),'dark')
 beam('StandardArm',(x-2.4,y+h-.5,z),(x+2.4,y+h-.5,z),.5)
 part('BannerCloth',(x,y+h-3.7,z),(4.4,6,.12),'red'if hostile else'blue','Fabric',soft=True)
 if not hostile:
  part('CrownBand',(x,y+h-4,z+.09),(2,.45,.1),'gold','Metal',soft=True)
  for i in [-1,0,1]:part('CrownPoint',(x+i*.65,y+h-3.35,z+.09),(.4,1,.12),'gold','Metal',soft=True)
 part('BannerFinial',(x,y+h+.5,z),(1.2,1.6,1.2),'gold','Metal','Wedge',soft=True)
def wall(x,z,w,h,yaw=0,broken=False):
 origin=Matrix.Rotation(yaw,3,'Y');rows=math.ceil(h/3);cols=math.ceil(w/6)
 for j in range(rows):
  for i in range(cols):
   if broken and j==rows-1 and i%3==0:continue
   local=origin@Vector(((i+.5)*w/cols-w/2,(j+.5)*h/rows,0))
   color=tuple(max(0,min(255,c+rng.randrange(-7,8)))for c in P['stone'])
   part('LimestoneCourse',(x+local.x,local.y,z+local.z),(w/cols-.13,h/rows-.12,3.1),color,'Brick',rotation=(0,yaw,0))
 for i in range(cols):
  local=origin@Vector(((i+.5)*w/cols-w/2,h+.08,0))
  part('MossCoping',(x+local.x,local.y,z+local.z),(w/cols-.2,.25,3.2),'moss','Grass',rotation=(0,yaw,0),soft=True)
def timber_shelter(width=24,depth=20,closed=False,red=False):
 # Tapered roof planes, individual eaves, knee braces and a planked open porch.
 for i in range(7):part('PorchPlank',((i-3)*width/7,.55,2),(width/7-.12,1.1,depth+5),'wood','WoodPlanks')
 for x in [-width/2+1,width/2-1]:
  for z in [-depth/2+1,depth/2-1]:
   part('StonePostFoot',(x,1,z),(3,2,3),'stone','Slate')
   part('CarvedTimberPost',(x,8,z),(1.3,14,1.3),'dark')
   beam('KneeBrace',(x,10,z),(x-math.copysign(3,x),14,z),.8)
  beam('EaveBeam',(x,14,-depth/2),(x,14,depth/2),1.3)
 for z in [-depth/2,depth/2]:
  beam('TieBeam',(-width/2,14,z),(width/2,14,z),1.2)
  for side in [-1,1]:beam('GableRafter',(0,22,z),(side*(width/2+2),14,z),1.3,'dark')
 beam('RoofRidge',(0,22,-depth/2-2),(0,22,depth/2+2),1.4,'light')
 slope=math.atan2(8,width/2+2);length=math.hypot(width/2+2,8)
 for side in [-1,1]:
  for i in range(7):
   part('RoofShingle',(side*(width/4+1),18,(i-3)*(depth+5)/7),(length,1,(depth+5)/7+.35),
        'red'if red else ('wood'if i%2 else'dark'),'WoodPlanks',rotation=(0,0,-side*slope))
 if closed:
  for i in range(7):part('RearPlank',((i-3)*(width-3)/7,7.3,-depth/2+1),((width-3)/7-.1,11,.65),'wood','WoodPlanks')
  for side in [-1,1]:
   part('SideHalfWall',(side*(width/2-1),4.1,0),(.65,5.5,depth-3),'wood','WoodPlanks')
   beam('HalfTimberDiagonal',(side*(width/2-1),1.5,-depth/2+2),(side*(width/2-1),7,depth/2-2),.6,'dark')
def table(x,z):
 for side in [-1,1]:part('TableLeg',(x+side*3,2.1,z),(1,3.4,4))
 part('TableTop',(x,4,z),(10,.6,5),'wood','WoodPlanks')
def window(x,y,z):
 part('WindowShadow',(x,y,z),(.5,5,4),'dark')
 part('AmberPane',(x+.28,y,z),(.15,3.8,2.8),'warm','Glass',soft=True)
 for dz in [-1.8,1.8]:part('WindowFrame',(x+.5,y,z+dz),(.5,5,.5),'light')
 part('WindowSill',(x+.5,y-2.5,z),(.8,.7,5),'light')
def root_fan(x,z,height=10):
 for i in range(4):
  a=i*1.25;dx,dz=math.cos(a),math.sin(a)
  beam('RootHaunch',(x,height,z),(x+dx*7,3,z+dz*7),3,'root')
  beam('RootTaper',(x+dx*7,3,z+dz*7),(x+dx*14,.6,z+dz*14),1.7,'root')

begin('Waystation',0)
wall(-8,-5,16,9,broken=True);wall(10,-10,10,5,broken=True)
for x,h in [(-13,15),(4,11)]:
 for j in range(math.ceil(h/3)):part('ArchPier',(x,(j+.5)*3,1),(4.5,2.9,5),'light'if j%3==0 else'stone','Brick')
beam('FallenArchSpring',(-13,14,1),(-5,17,1),3,'stone')
banner(-16,7);crate(10,3);table(0,-4)

begin('Shelter',1)
timber_shelter(24,18);wall(0,-12,27,5)
for i in range(3):
 part('RestBench',((i-1)*6,1.4,2),(4.8,1.5,9),'wood')
 part('RestBlanket',((i-1)*6,2.2,2),(4.5,.25,8),'cloth','Fabric',soft=True)
crate(11,12);banner(-16,3)

begin('Outpost',2)
timber_shelter(30,22,True)
table(-5,3);part('UnletteredMap',(-5,4.35,3),(8,.08,4),'cloth','Fabric',soft=True)
for z in [-5,5]:window(-14.6,10,z)
for x in [-19,19]:banner(x,9)
crate(10,-4);crate(10,3)
for x in [-12,12]:part('PorchSeat',(x,2,14),(5,3,4),'wood','WoodPlanks')
beam('SupplyRack',(-19,3,-10),(-19,11,-10),.9)
beam('SupplyRack',(-19,11,-10),(-19,11,0),.9)
part('BluePorchValance',(0,13.5,12.7),(31,2,.16),'blue','Fabric',soft=True)
part('GoldPorchHem',(0,12.5,12.8),(31,.28,.2),'gold','Fabric',soft=True)

begin('Watchtower',3)
for side in [-1,1]:wall(side*9,0,20,30,math.pi/2)
wall(0,-9,15,30)
for side in [-1,1]:
 wall(side*7,9,5,20)
 for y in [2,8,14,20,26]:part('TowerQuoin',(side*9,y,9),(4,2.2,4),'light','Slate')
 for i in range(3):
  a=(i+.5)*math.pi/6
  part('ArchVoussoir',(side*(5*math.cos(a)),19+5*math.sin(a),9),(3,3,3.5),'light','Slate',rotation=(0,0,side*a))
for z in [-11,11]:
 part('TowerCornice',(0,31,z),(25,2.5,4),'light','Slate')
 for x in [-9,0,9]:part('TowerMerlon',(x,34.5,z),(4.5,5,4.5),'stone','Brick')
for x in [-11,11]:part('TowerCornice',(x,31,0),(4,2.5,23),'light','Slate')
for y in [10,23]:part('ArrowSlit',(9.1,y,0),(.12,4,1),'dark','Slate',soft=True)
banner(0,11,11)
for i in range(9):part('IvyLeaf',(-9.3,3+i*2.2,-6+math.sin(i)*2),(.25,2.5,2.4),'moss','Grass','Wedge',rotation=(0,.3,i*.2),soft=True)

begin('Barracks',4)
wall(0,-16,36,13,broken=True);wall(-18,-5,22,11,math.pi/2,True);wall(18,-10,12,8,math.pi/2,True)
for side in [-1,1]:
 part('BarrackPost',(side*10,8,-2),(1.5,16,1.5),'dark')
 beam('BarrackRafter',(side*11,15,-10),(0,20,-10),1.4)
 for i in range(4):part('DamagedRoof',(side*5.5,17,(i-1.5)*4),(13,1,4.5),'dark','WoodPlanks',rotation=(0,0,-side*.42))
banner(-17,7,hostile=True);banner(16,-9,hostile=True);table(0,0);crate(10,4)

begin('Rootwood',5)
root_fan(-10,-4,12);root_fan(10,-8,9)
for side in [-1,1]:
 part('RefugePost',(side*9,5,10),(1,10,1),'wood')
 beam('RefugeRafter',(side*10,10,10),(0,14,10),1)
 part('RefugeRoof',(side*5,12,10),(12,.8,13),'wood','WoodPlanks',rotation=(0,0,-side*.38))
crate(-6,10);part('CivilianBench',(5,1.4,11),(8,2.8,4),'wood');banner(-17,10,broken=True)

begin('AltarRuins',6)
for side in [-1,1]:
 for j in range(4):part('BrokenAltarPier',(side*13,1.6+j*3.1,-8),(5.5,3,5.5),'stone','Slate',rotation=(0,side*j*.03,0))
 part('PierMoss',(side*13,13,-8),(6,.25,6),'moss','Grass',soft=True)
 root_fan(side*13,-10,10)
wall(0,-17,22,7,broken=True)
for i in range(6):part('FallenPrecinctStone',(-12+i*4,1.2,8+math.sin(i)*2),(3.6,2.4,4.5),'light','Slate',rotation=(0,i*.3,.12))

begin('Storehouse',7)
timber_shelter(24,20,True,True)
for x,z in [(-7,-4),(0,-4),(7,-4),(-6,4),(1,4)]:crate(x,z)
for x in [-9,8]:
 part('ProvisionBarrel',(x,3,11),(5,4,4),'wood','WoodPlanks','Cylinder',rotation=(0,0,math.pi/2))
 for y in [1.5,4]:part('BarrelHoop',(x,y,11),(.25,4.2,4.2),'iron','Metal','Cylinder',rotation=(0,0,math.pi/2))
banner(-16,7,hostile=True)

begin('Quarry',8)
for side in [-1,1]:
 part('GantryFoot',(side*11,1,-3),(5,2,7),'stone','Slate')
 part('GantryPost',(side*11,13,-3),(2,24,2),'dark')
 beam('GantryBrace',(side*11,4,-3),(side*5,20,-3),1.3)
beam('GantryTop',(-14,25,-3),(14,25,-3),2.2)
part('WinchDrum',(0,11,-3),(12,5,5),'wood','WoodPlanks','Cylinder')
for x in [-7,7]:part('DrumFlange',(x,11,-3),(.8,7,7),'iron','Metal','Cylinder')
beam('HaulingRope',(0,25,-3),(0,4,6),.23,'cloth',True)
part('SuspendedStone',(0,3,6),(6,5,6),'light','Slate')
for i in range(5):part('CutStoneBlock',((i%3-1)*7,2,10+int(i/3)*7),(6,4,5.5),'stone'if i%2 else'light','Slate')
table(-6,-11);banner(16,-10)

begin('Battlefield',9)
wall(0,-3,14,4,broken=True);banner(-5,4,hostile=True,broken=True)
for i in range(4):beam('BrokenPalisade',(-6+i*3,.8,0),(-4+i*3,1.7,6),1.1,'dark')
part('BrokenShield',(4,1,3),(3,1.2,3),'red','Wood','Ball')
beam('SnappedBrace',(-6,2,-4),(5,1,-3),.8)

scene['DeepwoodKitJSON']=json.dumps({'version':1,'axis':'Roblox Y-up; exact part CFrames','colorManagement':'Standard / sRGB / None / Exposure0 / Gamma1 / CurvesOff','models':models})
scene['PreservedPreviousScene']=previous_scene.name
scene['DeepwoodKitPartCount']=sum(len(v)for v in models.values())
sun_data=bpy.data.lights.new('DeepwoodArchitectureSun','SUN');sun_data.energy=2.3;sun_data.angle=.18
sun=bpy.data.objects.new('DeepwoodArchitectureSun',sun_data);scene.collection.objects.link(sun);sun.rotation_euler=(.45,-.5,-.45)
area_data=bpy.data.lights.new('DeepwoodArchitectureFill','AREA');area_data.energy=2600;area_data.shape='DISK';area_data.size=100
area=bpy.data.objects.new('DeepwoodArchitectureFill',area_data);scene.collection.objects.link(area);area.location=(90,-30,100)
camera_data=bpy.data.cameras.new('DeepwoodArchitectureCamera');camera=bpy.data.objects.new('DeepwoodArchitectureCamera',camera_data);scene.collection.objects.link(camera)
camera.location=(150,-210,180);target=Vector((130,-35,7));camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
camera_data.type='ORTHO';camera_data.ortho_scale=315;scene.camera=camera
print(json.dumps({'scene':scene.name,'previousPreserved':previous_scene.name,'models':{k:len(v)for k,v in models.items()},'parts':scene['DeepwoodKitPartCount'],'color':scene.view_settings.view_transform,'engine':scene.render.engine}))
