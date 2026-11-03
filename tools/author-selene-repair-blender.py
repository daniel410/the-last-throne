"""Run in a dedicated Blender scene; preserve the pinned TD nun surface and UVs."""
import bpy,bmesh,math
from mathutils import Vector,Quaternion,Matrix
ROOT='/Users/daniel/Workspace/project/roblox/the-last-throne/'
OUT=ROOT+'assets/animations/selene-repair-v1/'
assert 'TLT_Selene_Repair_v1' not in bpy.data.scenes, 'Keep the existing review scene; use a clean Blender file to reproduce'
scene=bpy.data.scenes.new('TLT_Selene_Repair_v1')
bpy.context.window.scene=scene
bpy.ops.import_scene.gltf(filepath=OUT+'source-rest.glb')
objects=[o for o in scene.objects if o.type=='MESH']
assert len(objects)==3
for obj in objects:
 for v in obj.data.vertices:v.co=obj.matrix_world@v.co
 obj.matrix_world=Matrix.Identity(4)
 obj['TDPart']=obj.name.split('.')[0]
 bm=bmesh.new();bm.from_mesh(obj.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001);bm.to_mesh(obj.data);bm.free()
rigdata=bpy.data.armatures.new('SeleneRepairSkeleton');rig=bpy.data.objects.new('SeleneRepairRig',rigdata);scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True)
for obj in objects:obj.select_set(False)
bpy.ops.object.mode_set(mode='EDIT')
specs=[('Root',(0,0,0),(0,0,.18),''),('Pelvis',(0,0,.33),(0,0,.53),'Root'),('Spine',(0,0,.53),(0,0,.76),'Pelvis'),('Head',(0,0,.76),(0,0,.99),'Spine'),
('UpperR',(-.19,0,.70),(-.30,-.015,.60),'Spine'),('ForearmR',(-.30,-.015,.60),(-.34,-.10,.55),'UpperR'),('HandR',(-.34,-.10,.55),(-.34,-.17,.53),'ForearmR'),('Lantern',(-.34,-.17,.51),(-.34,-.17,.28),'HandR'),
('UpperL',(.19,0,.70),(.29,.015,.59),'Spine'),('ForearmL',(.29,.015,.59),(.34,-.01,.44),'UpperL'),('HandL',(.34,-.01,.44),(.36,-.03,.38),'ForearmL'),
('LegL',(.13,0,.28),(.13,0,.07),'Pelvis'),('FootL',(.13,0,.07),(.13,-.11,.04),'LegL'),('LegR',(-.13,0,.28),(-.13,0,.07),'Pelvis'),('FootR',(-.13,0,.07),(-.13,-.11,.04),'LegR')]
for name,head,tail,parent in specs:
 b=rigdata.edit_bones.new(name);b.head=head;b.tail=tail
 if parent:b.parent=rigdata.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')
def smooth(a,b,x):
 t=max(0,min(1,(x-a)/(b-a)));return t*t*(3-2*t)
for obj in objects:
 role=obj['TDPart'];groups={name:obj.vertex_groups.new(name=name)for name,_,_,_ in specs}
 for v in obj.data.vertices:
  x,y,z=v.co;weights={}
  if role in ('ArmR','ArmL'):
   side=role[-1];shoulder=smooth(.62,.71,z)
   if side=='R' and z<.49 and y<-.07:weights={'Lantern':1}
   else:
    upper=smooth(.50 if side=='R' else .43,.63,z)
    hand=1-smooth(.52 if side=='R' else .37,.57 if side=='R' else .47,z)
    weights={'Spine':shoulder,'Upper'+side:(1-shoulder)*upper,'Forearm'+side:(1-shoulder)*(1-upper)*(1-hand),'Hand'+side:(1-shoulder)*(1-upper)*hand}
  elif z<.26 and abs(x)>.065 and abs(x)<.245:
   leg=1-smooth(.12,.26,z);side='L' if x>0 else 'R';foot=1-smooth(.06,.13,z)
   weights={'Pelvis':1-leg,'Leg'+side:leg*(1-foot),'Foot'+side:leg*foot}
  else:
   head=smooth(.73,.82,z);spine=smooth(.44,.61,z)
   weights={'Head':head,'Spine':(1-head)*spine,'Pelvis':(1-head)*(1-spine)}
  total=sum(weights.values())
  for name,value in weights.items():
   if value>0:groups[name].add([v.index],value/total,'REPLACE')
 obj.parent=rig;mod=obj.modifiers.new('ContinuousSkin','ARMATURE');mod.object=rig
 obj.name='SeleneRepair_'+role
rig.rotation_mode='QUATERNION'
for p in rig.pose.bones:p.rotation_mode='QUATERNION'
def rotate(name,x=0,y=0,z=0):
 b=rig.pose.bones[name];rest=b.bone.matrix_local.to_quaternion();q=Quaternion((1,0,0),x)@Quaternion((0,1,0),y)@Quaternion((0,0,1),z);b.rotation_quaternion=rest.inverted()@q@rest
def move(name,v):
 b=rig.pose.bones[name];b.location=b.bone.matrix_local.to_3x3().inverted()@Vector(v)
clips=['Idle','Walk','Heal','Protect','Cleanse','Return']
actions={}
for clip in clips:
 action=bpy.data.actions.new('SeleneRepair_'+clip);rig.animation_data_create();rig.animation_data.action=action;actions[clip]=action
 for i in range(41):
  t=i/40;wave=math.sin(t*math.pi*2)
  for b in rig.pose.bones:b.location=(0,0,0);b.rotation_quaternion=Quaternion()
  if clip=='Idle':rotate('Head',0,0,.02*wave);move('Spine',(0,0,.0015*wave))
  elif clip=='Walk':
   for side,phase in [('L',t),('R',(t+.5)%1)]:
    s=math.sin(phase*math.pi*2);move('Leg'+side,(0,-s*.045,max(0,s)*.022));rotate('Foot'+side,-max(0,s)*.08)
   rotate('UpperL',-.12*wave);rotate('UpperR',.055*wave);rotate('Lantern',.025*wave);rotate('Spine',0,.012*wave,0)
  else:
   envelope=math.sin(math.pi*t)**2 if clip!='Return' else (1-smooth(0,1,t))
   rotate('UpperL',-.42*envelope,0,-.08*envelope);rotate('ForearmL',-.27*envelope);rotate('HandL',.08*envelope)
   rotate('UpperR',-.045*envelope);rotate('Head',.035*envelope);rotate('Spine',-.02*envelope)
  for b in rig.pose.bones:
   b.keyframe_insert(data_path='location',frame=i);b.keyframe_insert(data_path='rotation_quaternion',frame=i)
 for curve in action.layers[0].strips[0].channelbags[0].fcurves:
  for key in curve.keyframe_points:key.interpolation='LINEAR'
rig.animation_data.action=None
for obj in scene.objects:obj.select_set(False)
rig.select_set(True)
for obj in objects:obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT+'Selene-repaired.glb',export_format='GLB',use_selection=True,use_active_scene=True,export_animations=False,export_rest_position_armature=True)
scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='TEXTURE';scene.display.shading.show_shadows=True
scene.world=bpy.data.worlds.new('SeleneRepairWorld');scene.world.color=(.14,.16,.20);scene.display.shading.background_type='WORLD'
camera=bpy.data.cameras.new('SeleneRepairCamera');cam=bpy.data.objects.new('SeleneRepairCamera',camera);scene.collection.objects.link(cam);scene.camera=cam;camera.type='ORTHO';camera.ortho_scale=1.35
scene.render.resolution_x=600;scene.render.resolution_y=700;scene.render.resolution_percentage=100
for clip in clips:
 rig.animation_data.action=actions[clip]
 for phase in ([.25,.75]if clip=='Walk'else[.5]):
  scene.frame_set(round(phase*40))
  for view,position in [('front',(0,-2.5,.6)),('side',(2.5,-.3,.6))]:
   cam.location=Vector(position);cam.rotation_euler=(Vector((0,0,.5))-cam.location).to_track_quat('-Z','Y').to_euler()
   scene.render.filepath=OUT+clip+'-'+str(phase)+'-'+view+'.png';bpy.ops.render.render(write_still=True)
rig.animation_data.action=actions['Idle'];scene.frame_set(0)
print('SELENE_REPAIR',len(rigdata.bones),sum(len(o.data.polygons)for o in objects),'triangles; original surface/UV preserved; no AI mesh segmentation')
