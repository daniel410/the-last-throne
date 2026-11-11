"""Run through Blender MCP. Export the authored scene as identical Roblox primitives."""
import bpy, math, json, random
from mathutils import Vector, Matrix
scene=bpy.data.scenes.new('TLT_EpicEnvironment_20261111')
bpy.context.window.scene=scene
scene.view_settings.view_transform='Standard'
scene.view_settings.look='None'
scene.view_settings.exposure=0
scene.view_settings.gamma=1
scene.view_settings.use_curve_mapping=False
scene.display_settings.display_device='sRGB'
scene.render.engine='CYCLES'
scene.cycles.samples=24
scene.render.resolution_x=1600
scene.render.resolution_y=1000
scene.render.resolution_percentage=100
world=bpy.data.worlds.new('EpicKitWorld');world.use_nodes=True;scene.world=world
next(n for n in world.node_tree.nodes if n.type=='BACKGROUND').inputs['Color'].default_value=(.12,.16,.22,1)
models={};materials={};state={'offset':Vector((0,0,0)),'current':''}
def linear(v):
 v=v/255
 return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
def part(name,pos,size,color,material='Slate',shape='Block',rot=(0,0,0)):
 # Author in Roblox axes; Blender Z-up conversion preserves exact geometry.
 p=Vector(pos);s=Vector(size)
 if shape=='Cylinder':
  bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=1,depth=2)
  o=bpy.context.object;o.scale=(s.z/2,s.x/2,s.y/2)
 elif shape=='Ball':
  bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=1)
  o=bpy.context.object;o.scale=(s.x/2,s.z/2,s.y/2)
 elif shape=='Wedge':
  # Roblox +Z is Blender -Y; the high edge faces local +Z.
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,.5,-.5),(.5,.5,-.5),(-.5,.5,.5),(.5,.5,.5)]
  verts=[(x,-y,z) for x,y,z in verts]
  mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],[(2,3,1,0),(4,5,3,2),(4,2,0),(3,5,1),(1,5,4,0)]);mesh.update()
  o=bpy.data.objects.new(name,mesh);scene.collection.objects.link(o);o.scale=(s.x,s.z,s.y)
 else:
  bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.scale=(s.x,s.z,s.y)
 # Yaw only for exported primitives, plus a lean around Roblox Z.
 yaw,lean=rot[1],rot[2]
 o.rotation_euler=(0,lean,-yaw);o.location=state['offset']+Vector((p.x,-p.z,p.y));o.name=state['current']+'_'+name
 key=(color,material)
 if key not in materials:
  mat=bpy.data.materials.new(material+'_'+str(color));mat.use_nodes=True
  shader=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
  rgba=tuple(linear(v) for v in color)+(1,);shader.inputs['Base Color'].default_value=rgba;mat.diffuse_color=rgba
  shader.inputs['Roughness'].default_value=.8
  if material=='Neon':shader.inputs['Emission Color'].default_value=rgba;shader.inputs['Emission Strength'].default_value=.8
  materials[key]=mat
 o.data.materials.append(materials[key])
 models[state['current']].append(dict(name=name,position=list(pos),size=list(size),color=list(color),material=material,shape=shape,yaw=yaw,lean=lean))
 return o
def start(name,index):
 state['current']=name;state['offset']=Vector(((index%5)*48,(index//5)*-50,0));models[name]=[]
def stone(pos,size,color,yaw=0):part('WeatheredStone',pos,size,color,shape='Wedge',rot=(0,yaw,0))
def fern(x,z,scale=1,dark=False):
 for i in range(5):
  a=i*math.tau/5
  part('FernFrond',(x+math.cos(a)*scale,scale*.75,z+math.sin(a)*scale),(.35*scale,.35*scale,3*scale),(53,89,65) if dark else (77,111,54),'Grass','Wedge',(0,-a+math.pi/2,0))
rock=(100,111,103);trim=(157,166,139);wood=(80,59,41)
start('DeepwoodRelic',0)
for i in range(5):
 stone((-9+i*4,1.2,1.4*math.sin(i)),(6,3,6),rock,i*.8)
for x,h in [(-8,15),(8,10)]:
 part('RelicFoot',(x,1,0),(6,2,6),trim)
 for j in range(int(h/3)):part('RelicCourse',(x,3+j*3,0),(3.8,2.8,3.8),rock,rot=(0,(j%2)*.04,0))
 part('RelicCapital',(x,h+1,0),(5,1,5),trim)
for i in range(5):
 part('FallenMasonry',(-5+i*2.3,1.1,5),(2,2,4),trim,rot=(0,i*.3,.1))
for x,z in [(-11,5),(7,-4),(0,6)]:fern(x,z,1.8)
part('OldLintel',(-2,13.5,0),(10,2,4),rock,rot=(0,0,-.16))
start('GloamwoodRoots',1)
for side in [-1,1]:
 for j in range(5):
  x=side*(12-j*1.4);y=2+j*5.2
  part('RootColumn',(x,y,0),(6-j*.65,6.5,5-j*.5),(63+j*3,57+j*2,51+j),'Wood','Cylinder',(0,0,side*.22))
 for j in range(3):part('RootButtress',(side*(11+j*3),2.2-j*.6,2+j),(4,5-j,7),wood,'Wood','Wedge',(0,side*.6,0))
for j in range(5):
 part('SilkSpan',(-9+j*4.5,18-3*math.sin(j*.8),.5),(.09,.09,16),(167,186,183),'Fabric','Block',(0,.8,0))
for j in range(4):
 part('SilkCocoon',(-6+j*4,15-j%2*3,1.5),(1.5,3.8,1.5),(164,181,168),'Fabric','Ball')
for x,z in [(-13,4),(9,5),(0,2)]:fern(x,z,1.7,True)
start('FrozenValeShards',2)
for i,(x,z,h) in enumerate([(-9,0,14),(-4,2,27),(2,0,34),(8,3,19),(4,-5,11)]):
 part('GlacierColumn',(x,h*.36,z),(5,h*.72,6),(91+i*8,150+i*5,178+i*6),'Glacier',rot=(0,i*.71,(-1)**i*.13))
 part('GlacierCrown',(x,h*.83,z),(5,h*.3,6),(151,203,219),'Ice','Wedge',(0,i*.71,(-1)**i*.13))
 part('SnowCollar',(x,1,z),(8,2,9),(216,228,229),'Snow','Ball')
for j in range(8):stone((-12+j*3,.5,7+math.sin(j)),(4,1.3,3),(132,178,190),j)
start('EmberCalderaColumns',3)
for i,(x,z,h) in enumerate([(-10,0,11),(-6,2,22),(-1,0,29),(4,1,25),(9,0,15),(4,-4,12)]):
 part('BasaltColumn',(x,h/2,z),(5,h,5),(53+i*2,49+i,51+i),'Basalt','Cylinder')
 for y in range(3,h,5):part('BasaltSeam',(x,y,z),(5.08,.18,5.08),(81,65,57),'Slate','Cylinder')
 part('CooledCrown',(x,h+.2,z),(5.2,.5,5.2),(102,77,63),'Slate','Cylinder')
for i in range(5):
 stone((-10+i*5,1,6),(7,2.8,5),(66,57,56),i)
 part('EmberCrevice',(-8+i*4,.28,6.4),(2.5,.12,.3),(225,114,43),'Neon',rot=(0,i*.6,0))
start('HauntedMemorial',4)
rock=(87,96,113);trim=(150,159,166)
for y,w in [(.6,20),(1.6,18)]:part('MemorialPlinth',(0,y,0),(w,1,9),rock)
for x in [-7,7]:
 part('MemorialPier',(x,8,0),(3,13,4),rock)
 for y in [3,12,15]:part('MemorialMoulding',(x,y,0),(4.1,.65,5),trim)
 part('MemorialPinnacle',(x,18,0),(3,6,4),rock,shape='Wedge')
for side in [-1,1]:
 for j in range(4):part('PointedArch',(side*(5.8-j*1.5),14+j*1.1,0),(2.15,1.3,3),trim,rot=(0,0,-side*.63))
part('TombChest',(0,3,1),(8,2,4.8),rock)
part('TombCover',(0,4.2,1),(9,.5,5.8),trim)
for x in [-3,0,3]:part('MemorialRelief',(x,3,3.45),(.45,1.25,.12),trim)
for x,z in [(-10,4),(10,3),(5,-5)]:fern(x,z,1.2,True)
# Small ground cover, distinct and quiet, scaled separately from the silhouette pieces.
for index,theme in enumerate(['Deepwood','Gloamwood','FrozenVale','EmberCaldera','HauntedGraveyard']):
 start(theme+'Groundcover',index+5)
 if index<2:
  for x,z,s in [(-2,0,1.4),(2,1,.9),(0,-2,1.1)]:fern(x,z,s,index==1)
  for j in range(3):
   part('MushroomStem',(j*1.4-2,.7,2),(.22,1.4,.22),(150,141,113),'Wood','Cylinder')
   part('MushroomCap',(j*1.4-2,1.4,2),(.9,.4,.9),(151,122,81) if index==0 else (116,160,147),'SmoothPlastic','Ball')
 elif index==2:
  for j in range(5):stone((j*1.6-3,1.2+j%2,math.sin(j)*2),(2.5,3+j%3,2.6),(131,182,201),j*.7)
 elif index==3:
  for j in range(5):stone((j*1.6-3,.6,math.sin(j)*2),(3,1.7+j%2,3),(78,65,59),j*.7)
 else:
  for j in range(4):part('FallenGraveTile',(j*1.8-3,.35,math.sin(j)*2),(2.5,.6,2),(111,119,121),rot=(0,j*.5,0))
  fern(1,2,.9,True)
# Separate scene only: preserve the user's existing monster/animation scenes.
for name,loc,power,size in [('Key',(20,-30,70),60000,55),('Fill',(130,-10,55),40000,65)]:
 data=bpy.data.lights.new('EpicKit'+name,'AREA');data.energy=power;data.shape='DISK';data.size=size
 o=bpy.data.objects.new(data.name,data);scene.collection.objects.link(o);o.location=loc
camdata=bpy.data.cameras.new('EpicKitCamera');cam=bpy.data.objects.new('EpicKitCamera',camdata);scene.collection.objects.link(cam)
cam.location=(125,-170,150);target=Vector((96,-20,10));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=245;scene.camera=cam

bpy.ops.export_scene.gltf(filepath='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/models/epic-environment-v1/epic-environment.glb', use_active_scene=True)
print(json.dumps({'schema':1,'source':'Blender MCP authored primitives','colorSpace':'sRGB','models':models}))
