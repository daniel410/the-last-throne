"""Author layered closed hair locks; isolated Blender process, native head coordinates."""
import bpy, math, json, hashlib
from pathlib import Path
from mathutils import Vector, Matrix
R=Path(__file__).resolve().parents[1]; OUT=R/'assets/models/headgear-hair-concept-v2'; EV=R/'docs/evidence/headgear-hair-concept-20261111'
bpy.ops.wm.read_factory_settings(use_empty=True)
def standard(s):
 s.display_settings.display_device='sRGB';s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False
standard(bpy.context.scene)
def mat(name,rgb):
 m=bpy.data.materials.new(name);m.use_nodes=True;n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=tuple((v/255/12.92 if v/255<=.04045 else ((v/255+.055)/1.055)**2.4) for v in rgb)+(1,);n.inputs['Roughness'].default_value=.76;return m
white=mat('TintableHair',(255,255,255));colors={'elf':(100,57,29),'mage':(96,63,40),'knight':(60,43,30),'dwarf':(174,65,23)}
def lock(name,pts,width,depth):
 # Smooth cubic centerline, sculpted elliptical rings with longitudinal ridges.
 p=[Vector(q) for q in pts];verts=[];faces=[];N=10;S=6
 for j in range(N):
  t=j/(N-1);c=(1-t)**3*p[0]+3*(1-t)**2*t*p[1]+3*(1-t)*t*t*p[2]+t**3*p[3]
  tangent=(3*(1-t)**2*(p[1]-p[0])+6*(1-t)*t*(p[2]-p[1])+3*t*t*(p[3]-p[2])).normalized()
  axis=tangent.cross(Vector((0,1,0))).normalized();normal=axis.cross(tangent).normalized()
  profile=max(.004,(1-t)**.8)
  for u,w in [(-1,0),(-.45,.72),(0,1),(.48,.62),(1,0),(0,-.28)]:
   v=c+profile*(axis*u*width+normal*w*depth);v.z+=1.586;verts.append(v)

 for j in range(N-1):
  for k in range(S):
   a=j*S+k;b=j*S+(k+1)%S;faces.extend([(a,b,b+S),(a,b+S,a+S)])
 faces.append(tuple(reversed(range(S))));faces.append(tuple((N-1)*S+k for k in range(S)))
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);bpy.context.scene.collection.objects.link(o)
 for f in mesh.polygons:f.use_smooth=False
 return o
def scalp(style):
 # Complete closed cap: crown, back, temples and short front hairline.
 verts=[];faces=[];n=64;rings=10
 for inner in range(2):
  for row in range(rings):
   t=.006+.994*row/(rings-1);radius=min(1,t/.60)
   for i in range(n):
    a=2*math.pi*i/n;front=max(0,math.sin(a));back=max(0,-math.sin(a))
    hem=-.18+.64*front-.22*back
    z=.64+(.0 if not inner else -.035)+(hem-.64)*max(0,(t-.60)/.40)
    rx=.65-inner*.035;ry=.65-inner*.035
    x=math.copysign(abs(math.cos(a))**.25,math.cos(a))*rx*radius
    y=math.copysign(abs(math.sin(a))**.25,math.sin(a))*ry*radius
    verts.append((x,y,z+1.586))
 layer=n*rings
 for inner in range(2):
  off=inner*layer
  for row in range(rings-1):
   for i in range(n):
    a=off+row*n+i;b=off+row*n+(i+1)%n;faces.append((a,b,b+n,a+n))
 for row in (rings-1,):
  for i in range(n):
   a=row*n+i;b=row*n+(i+1)%n;faces.append((a,b,b+layer,a+layer))
 faces.append(tuple(reversed(range(n))));faces.append(tuple(layer+i for i in range(n)))
 mesh=bpy.data.meshes.new('CompleteCrownAndBack');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('CompleteCrownAndBack',mesh);bpy.context.scene.collection.objects.link(o)
 for f in mesh.polygons:f.use_smooth=True
 return o
records=[]
for style in colors:
 s=bpy.data.scenes.new(style);bpy.context.window.scene=s;standard(s);pieces=[scalp(style)]
 # Exposure follows the concept: broad swept Elf fringe; enclosed Mage/Knight.
 if style in ('knight','mage','elf'):
  # Only a narrow nape beneath headwear; no invented long bob or fringe.
  for i in range(7):
   x=(i-3)*.15
   pieces.append(lock('HiddenNape',[(x,-.59,.08),(x,-.61,-.12),(x+.025,-.61,-.29),(x+.04,-.59,-.37)],.115,.025))
 if style=='elf':
  # Hand-authored root-to-tip sweeps match the side-parted concept silhouette.
  sweeps=[(.18,-.46,.13,.19),(.20,-.24,.36,.18),(.21,.015,.37,.16),
          (.24,.39,.38,.13),(.35,.53,.18,.105),(.44,.58,.04,.09)]
  for i,(root,tip,z,w) in enumerate(sweeps):
   pieces.append(lock('SweptFringe',[(root,.43,.64),(root-.06,.61,.56),
    (tip-.025,.68,z+.10),(tip,.65,z)],w,.045))
 if style=='dwarf':
  for row in range(2):
   for i in range(9):
    a=math.pi*(.04+.92*i/8);x=.62*math.cos(a);y=-.63*math.sin(a)**.45
    top=-.02-row*.16;end=-.43-row*.18-(.08 if i%2 else 0)
    pieces.append(lock('NapeFan',[(x,y,top),(x*1.06,y*1.06,top-.12),
     (x*1.19,y*1.09,end+.12),(x*1.15,y*1.02,end)],.19,.035))
 if style=='elf':
  for piece in pieces:
   if not piece.name.startswith('SweptFringe'):continue
   for vertex in piece.data.vertices:
    z=vertex.co.z-1.586
    vertex.co.z=min(1.586+.60,vertex.co.z+.13*max(0,min(1,(.58-z)/.28)))
    if piece.name.startswith('SweptFringe') and z>.48:vertex.co.y=min(vertex.co.y,.46)
 bpy.ops.object.select_all(action='DESELECT')
 for p in pieces:p.select_set(True)
 bpy.context.view_layer.objects.active=pieces[0];bpy.ops.object.join();obj=bpy.context.object;obj.name=style.title()+'Hair';obj.data.materials.append(white)
 # Recalculate outward normals for closed locks.
 bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.mesh.normals_make_consistent(inside=False);bpy.ops.object.mode_set(mode='OBJECT')
 path=OUT/(style+'.glb');bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',use_selection=True,export_animations=False)
 pts=[Vector((v.co.x,v.co.z,-v.co.y)) for v in obj.data.vertices];lo=Vector([min(p[i] for p in pts) for i in range(3)]);hi=Vector([max(p[i] for p in pts) for i in range(3)])
 records.append(dict(style=style,template=obj.name,preparedSha256=hashlib.sha256(path.read_bytes()).hexdigest(),triangles=sum(len(f.vertices)-2 for f in obj.data.polygons),size=list(hi-lo),center=list((hi+lo)/2),referenceAnchor=[0,1.586,0],samples=[list(pts[i]) for i in range(0,len(pts),max(1,len(pts)//48))][:48],color=colors[style]))
 obj.data.materials.clear();obj.data.materials.append(mat(style+'HairColor',colors[style]))
 # Preview existing production armor, preserving source materials and original files.
 for category in (('hat','robe') if style=='mage' else ('hood','coat') if style=='elf' else ('helmet','coat')):
  before=set(s.objects);bpy.ops.import_scene.gltf(filepath=str(R/'assets/models/four-family-armor-meshy-v1/prepared'/('traveler_'+category+'.glb')))
  for o in set(s.objects)-before:
   if o.type=='MESH':
    o['ReviewArmorCategory']=category
    for v in o.data.vertices:v.co=o.matrix_world@v.co
    o.matrix_world=Matrix.Identity(4)
    if category=='hat':o.location.z-=.25
    if category=='helmet':o.location.z+=.32
    if category=='robe':o.scale.y*=1.85
 # Rounded block head, exact R15 reference bounds.
 skin=mat('Skin_'+style,(239,190,98))
 bpy.ops.mesh.primitive_cube_add(size=1,location=(0,0,1.586));head=bpy.context.object;head.name='ReferenceHead';head.dimensions=(1.159,1.161,1.182);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);head.data.materials.append(skin)
 bevel=head.modifiers.new('RoundedHead','BEVEL');bevel.width=.18;bevel.segments=5;head.modifiers.new('HeadNormals','WEIGHTED_NORMAL')
 black=mat('Face_'+style,(20,15,10))
 for x in (-.21,.21):
  bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=8,radius=1,location=(x,.584,1.75));o=bpy.context.object;o.scale=(.055,.018,.10);o.data.materials.append(black)
 s.world=bpy.data.worlds.new('NeutralWorld_'+style);s.world.use_nodes=True;next(n for n in s.world.node_tree.nodes if n.type=='BACKGROUND').inputs[0].default_value=(.22,.25,.30,1);next(n for n in s.world.node_tree.nodes if n.type=='BACKGROUND').inputs[1].default_value=.45
 for loc,power,size in [((3,5,7),750,5),((-4,1,4),500,4),((1,-4,5),650,3)]:
  bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.shape='DISK';o.data.size=size;o.rotation_euler=(Vector((0,0,1.5))-o.location).to_track_quat('-Z','Y').to_euler()
 bpy.ops.object.camera_add();cam=bpy.context.object;s.camera=cam;cam.data.type='ORTHO';cam.data.ortho_scale=4.5 if style=='mage' else 3.9
 s.render.engine='CYCLES';s.cycles.samples=24;s.render.resolution_x=900;s.render.resolution_y=1000;s.render.resolution_percentage=100
 for view,pos in [('front',(0,9,3.5)),('three-quarter',(5,8,3.7)),('back',(3,-8,3.5))]:
  cam.location=pos;cam.rotation_euler=(Vector((0,0,1.9))-cam.location).to_track_quat('-Z','Y').to_euler();s.render.filepath=str(EV/(style+'-'+view+'.png'));standard(s);bpy.ops.render.render(write_still=True)
 # Also inspect the complete hair without enclosing headwear.
 armor=[o for o in s.objects if o.get('ReviewArmorCategory')]
 for o in armor:o.hide_render=True
 cam.data.ortho_scale=2.7;cam.location=(4,7,5.3);cam.rotation_euler=(Vector((0,0,1.65))-cam.location).to_track_quat('-Z','Y').to_euler()
 s.render.filepath=str(EV/(style+'-hair-only.png'));bpy.ops.render.render(write_still=True)
 for o in armor:o.hide_render=False
(OUT/'manifest.json').write_text(json.dumps({'version':3,'derivation':'Complete crown and back for every hero, flattened swept locks, no facial hair; based on approved TD hero concepts, fitted to unchanged TD-derived armor reference frame. No TD originals modified.','viewTransform':'Standard','display':'sRGB','look':'None','records':records},indent=2)+'\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'headgear-hair-review.blend'),compress=True)
