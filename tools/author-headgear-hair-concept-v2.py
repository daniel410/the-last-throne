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
 p=[Vector(q) for q in pts];verts=[];faces=[];N=12;S=12
 for j in range(N):
  t=j/(N-1);c=(1-t)**3*p[0]+3*(1-t)**2*t*p[1]+3*(1-t)*t*t*p[2]+t**3*p[3]
  tangent=(3*(1-t)**2*(p[1]-p[0])+6*(1-t)*t*(p[2]-p[1])+3*t*t*(p[3]-p[2])).normalized()
  axis=tangent.cross(Vector((0,1,0))).normalized();normal=axis.cross(tangent).normalized()
  profile=.025+.94*math.sin(math.pi*t)**.8*(1-.60*t)
  for k in range(S):
   a=2*math.pi*k/S;ridge=1+.20*math.cos(3*a+1.7*t)
   v=c+profile*ridge*(axis*math.cos(a)*width+normal*math.sin(a)*depth);v.z+=1.586;verts.append(v)
 for j in range(N-1):
  for k in range(S):
   a=j*S+k;b=j*S+(k+1)%S;faces.extend([(a,b,b+S),(a,b+S,a+S)])
 faces.append(tuple(reversed(range(S))));faces.append(tuple((N-1)*S+k for k in range(S)))
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);bpy.context.scene.collection.objects.link(o)
 for f in mesh.polygons:f.use_smooth=True
 return o
def scalp(style):
 # Closed fitted rear/temple foundation; exposed clumps overlap its scalloped hem.
 verts=[];faces=[];n=40
 bottom={'knight':-.39,'elf':-.30,'mage':-.46,'dwarf':-.51}[style]
 for inner in range(2):
  for row in range(2):
   for i in range(n+1):
    a=-.20*math.pi+1.40*math.pi*i/n
    x=math.copysign(abs(math.cos(a))**.45,math.cos(a))*(.61-inner*.045)
    y=-math.copysign(abs(math.sin(a))**.45,math.sin(a))*(.615-inner*.045)
    z=.48 if row==0 else bottom+.035*math.cos(i*math.pi/2)
    verts.append((x,y,z+1.586))
 stride=n+1
 for inner in range(2):
  off=inner*2*stride
  for i in range(n):faces.append((off+i,off+i+1,off+stride+i+1,off+stride+i))
 for row in range(2):
  for i in range(n):
   a=row*stride+i;faces.append((a,a+1,a+1+2*stride,a+2*stride))
 for i in (0,n):faces.append((i,i+stride,i+3*stride,i+2*stride))
 mesh=bpy.data.meshes.new('FittedScalp');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('FittedScalp',mesh);bpy.context.scene.collection.objects.link(o)
 for f in mesh.polygons:f.use_smooth=True
 return o
records=[]
for style in colors:
 s=bpy.data.scenes.new(style);bpy.context.window.scene=s;standard(s);pieces=[] if style=='elf' else [scalp(style)]
 # Short overlapping rear locks stay below the enclosing headwear, not a single curtain.
 for row in range(0 if style=='elf' else 1 if style=='knight' else 2):
  for i in range(9):
   angle=math.pi*(.02+.96*i/8);x=.63*math.copysign(abs(math.cos(angle))**.45,math.cos(angle));y=-.635*math.sin(angle)**.45
   length={'knight':.40,'elf':.32,'mage':.52,'dwarf':.68}[style]
   top=(-.06 if style in ('knight','dwarf') else .18)-row*.20;end=top-length-(.08 if i%2 else 0)
   pieces.append(lock('Nape',[(x,y,top),(x*1.04,y*1.04,top-.16),(x*1.15,y*1.12,end+.10),(x*.94,y*1.05,end)],.18 if style!='dwarf' else .21,.065))
 if style in ('elf','mage'):
  # Asymmetrical side sweep: roots inside the hat; pointed tips above eye samples.
  for i in range(7):
   x=-.42+i*.14;z=[.16,.36,.34,.25,.36,.36,.18][i]
   shift=.045 if i<4 else -.035
   pieces.append(lock('Fringe',[(x-.06,.28,.51),(x-.025,.55,.47),(x+shift,.64,.40),(x+shift,.63,z)],.125,.045))
  for side in (-1,1):
   for j in range(3):
    end=-.26-j*.07 if style=='mage' else .05-j*.06
    pieces.append(lock('Temple',[(side*.43,.26-j*.15,.43),(side*.57,.47-j*.13,.30),(side*.60,.48-j*.12,end+.13),(side*(.55+j*.035),.40-j*.12,end)],.12,.055))
 if style=='dwarf':
  for side in (-1,1):
   for j in range(3):
    pieces.append(lock('Sideburn',[(side*.51,.36,.08),(side*.64,.46,-.19),(side*.72,.49,-.40-j*.09),(side*(.62+j*.08),.42,-.54-j*.08)],.18,.09))
   for j in range(3):
    pieces.append(lock('Mustache',[(side*.005,.64,-.18-j*.035),(side*.22,.80,-.12-j*.05),(side*.44,.78,-.27-j*.07),(side*.61,.66,-.39-j*.06)],.095,.065))
  for row in range(2):
   for i in range(7):
    x=(i-3)*.145;end=-.85-(.28*(1-abs(i-3)/3))-row*.14+(.06 if i%2 else 0)
    pieces.append(lock('Beard',[(x,.52+row*.12,-.35-row*.15),(x*1.12,.75+row*.08,-.55),(x*.82,.81,end+.16),(x*.68,.64,end)],.16,.09))
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
(OUT/'manifest.json').write_text(json.dumps({'version':2,'derivation':'New layered closed locks based on approved TD hero concepts, fitted to unchanged TD-derived armor reference frame. No TD originals modified.','viewTransform':'Standard','display':'sRGB','look':'None','records':records},indent=2)+'\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'headgear-hair-review.blend'),compress=True)
