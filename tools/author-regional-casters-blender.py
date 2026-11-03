"""MR-01 local skinned source candidates. Execute through Blender MCP; no upload.

Run prepare-regional-caster-meshes.py first. Pinned original GLBs are in inputs.
Uses only
Blender APIs and pure Python; preserves the user's other scenes and active scene.
"""
import bpy, math, json
from mathutils import Vector, Quaternion, Matrix
BASE='/Users/daniel/Workspace/project/roblox/the-last-throne/'
OUT=BASE+'assets/animations/regional-casters-v1/'
REVIEW=BASE+'docs/evidence/regional-casters-mr01-20261103/'
SPECS={'VolcanoShaman': {'R': [(0.2, 0.015, 0.7), (0.27, 0.005, 0.57), (0.3, -0.105, 0.525)], 'L': [(-0.2, 0.01, 0.69), (-0.28, 0.015, 0.56), (-0.33, -0.14, 0.54)]}, 'QueenIceElf': {'R': [(0.16, 0.015, 0.7), (0.23, -0.055, 0.61), (0.267, -0.14, 0.58)], 'L': [(-0.17, 0.01, 0.7), (-0.245, -0.02, 0.59), (-0.3, -0.14, 0.49)]}, 'KingVolcanoShaman': {'R': [(0.2, 0.015, 0.68), (0.275, -0.02, 0.56), (0.325, -0.14, 0.51)], 'L': [(-0.2, 0.01, 0.68), (-0.28, 0.01, 0.54), (-0.34, -0.12, 0.48)]}}
CLIPS=['Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned','Exposed','Return','Interrupted']
previous_name=bpy.context.window.scene.name
results={}

def clamp(x):return max(0,min(1,x))
def smooth(x):
 x=clamp(x);return x*x*(3-2*x)

def weights(p,spec):
 # The complete source has no artificial rigid shoulder/elbow cuts. A continuous
 # deterministic field assigns identical weights to all coincident UV vertices.
 side='R' if p.x>0 else 'L';shoulder,elbow,wrist=map(Vector,spec[side])
 influence=smooth((abs(p.x)-.15)/.115)*smooth((p.z-.27)/.09)*(1-smooth((p.z-.70)/.07))
 if influence<1e-7:return {'Torso':1.0}
 chain=[shoulder,elbow,wrist];best=None
 for i in range(2):
  delta=chain[i+1]-chain[i];t=clamp((p-chain[i]).dot(delta)/delta.length_squared)
  distance=(p-chain[i]-t*delta).length
  candidate=(distance,i+t)
  if best is None or distance<best[0]:best=candidate
 along=best[1]
 elbowMix=smooth((along-.65)/.65);handMix=smooth((along-1.55)/.4)
 return {'Torso':1-influence,'Upper'+side:influence*(1-elbowMix),
         'Forearm'+side:influence*elbowMix*(1-handMix),'Hand'+side:influence*elbowMix*handMix}

def world_rotation(bone,rx=0,rz=0):
 rest=bone.bone.matrix_local.to_quaternion()
 q=Quaternion((0,0,1),math.radians(rz))@Quaternion((1,0,0),math.radians(rx))
 bone.rotation_mode='QUATERNION';bone.rotation_quaternion=rest.inverted()@q@rest

def pose(rig,clip,phase):
 for bone in rig.pose.bones:bone.location=(0,0,0);bone.scale=(1,1,1);world_rotation(bone)
 if clip in ['Attack','AttackAlt','Heavy','HeavyAlt']:
  alt=clip.endswith('Alt');heavy=clip.startswith('Heavy')
  phases=[0,.4,.62,.78,1];intensity=[0,1,-.45,-.17,0];i=phases.index(phase);v=intensity[i]
  world_rotation(rig.pose.bones['UpperR'],(-24 if heavy else -16)*v,(-7 if alt else 5)*v)
  world_rotation(rig.pose.bones['ForearmR'],(-31 if heavy else -22)*v,(4 if alt else -3)*v)
  world_rotation(rig.pose.bones['HandR'],7*v,(-5 if alt else 3)*v)
  world_rotation(rig.pose.bones['UpperL'],-13*v,(8 if alt else -5)*v)
  world_rotation(rig.pose.bones['ForearmL'],-18*v)
  world_rotation(rig.pose.bones['HandL'],6*v)
 elif clip=='Walk':
  v=math.sin(phase*2*math.pi);world_rotation(rig.pose.bones['UpperR'],3*v);world_rotation(rig.pose.bones['UpperL'],-3*v)
 elif clip=='Idle':
  v=math.sin(phase*2*math.pi);world_rotation(rig.pose.bones['ForearmL'],1.5*v)
 elif clip=='Stunned':
  v=1+.06*math.sin(phase*2*math.pi);world_rotation(rig.pose.bones['UpperR'],8*v,4*v);world_rotation(rig.pose.bones['UpperL'],9*v,-4*v)
 elif clip=='Exposed':
  world_rotation(rig.pose.bones['UpperR'],6,7);world_rotation(rig.pose.bones['UpperL'],7,-7)
 elif clip in ['Return','Interrupted']:
  v=1-smooth(phase);world_rotation(rig.pose.bones['UpperR'],-16*v,5*v);world_rotation(rig.pose.bones['ForearmR'],-22*v);world_rotation(rig.pose.bones['HandR'],7*v)
  world_rotation(rig.pose.bones['UpperL'],-13*v,-5*v);world_rotation(rig.pose.bones['ForearmL'],-18*v)

try:
 for kind,spec in SPECS.items():
  old=bpy.data.scenes.get('TLT_MR01_'+kind)
  if old:
   # Only replace this tool's named candidate scene, never an unrelated scene.
   for item in list(old.objects):
    data=item.data;kind_of_data=item.type;bpy.data.objects.remove(item,do_unlink=True)
    if data and data.users==0:
     if kind_of_data=='MESH':bpy.data.meshes.remove(data)
     elif kind_of_data=='ARMATURE':bpy.data.armatures.remove(data)
     elif kind_of_data=='CAMERA':bpy.data.cameras.remove(data)
   bpy.data.scenes.remove(old)
  for clip in CLIPS:
   old_action=bpy.data.actions.get(kind+'__'+clip)
   if old_action and old_action.users<=1:bpy.data.actions.remove(old_action)
  scene=bpy.data.scenes.new('TLT_MR01_'+kind);scene['MR01Generated']=True;bpy.context.window.scene=scene
  bpy.ops.import_scene.gltf(filepath=OUT+kind+'-partitioned.glb')
  obj=next(o for o in scene.objects if o.type=='MESH' and o.name.split('.')[0]=='Skin')
  weapon=next(o for o in scene.objects if o.type=='MESH' and o.name.split('.')[0]=='Staff')
  obj.name=kind+'__Skin';weapon.name=kind+'__Staff'
  obj.data.name=kind+'__SkinGeometry';weapon.data.name=kind+'__StaffGeometry'
  for target in [obj,weapon]:
   for v in target.data.vertices:v.co=target.matrix_world@v.co
   target.matrix_world=Matrix.Identity(4)
  def coordinate(p):return tuple(round(x,5)for x in p)
  owned={coordinate(v.co)for v in weapon.data.vertices}
  boundary={coordinate(v.co)for v in obj.data.vertices}&owned
  source_count={'QueenIceElf':3140,'VolcanoShaman':3194,'KingVolcanoShaman':3178}[kind]
  rigdata=bpy.data.armatures.new(kind+'__Skeleton');rig=bpy.data.objects.new(kind+'__Rig',rigdata);scene.collection.objects.link(rig)
  bpy.context.view_layer.objects.active=rig;rig.select_set(True);obj.select_set(False)
  bpy.ops.object.mode_set(mode='EDIT')
  def bone(name,head,tail,parent=None,deform=True):
   b=rigdata.edit_bones.new(name);b.head=head;b.tail=tail;b.use_deform=deform
   if parent:b.parent=rigdata.edit_bones[parent]
   return b
  bone('Root',(0,0,0),(0,0,.12),deform=False);bone('Torso',(0,0,.4),(0,0,.70),'Root')
  for side in ['R','L']:
   shoulder,elbow,wrist=map(Vector,spec[side]);bone('Upper'+side,shoulder,elbow,'Torso');bone('Forearm'+side,elbow,wrist,'Upper'+side)
   bone('Hand'+side,wrist,wrist+Vector((0,-.065,-.015)),'Forearm'+side)
  wrist=Vector(spec['R'][2]);bone('Staff',wrist,wrist+Vector((0,0,.23)),'HandR')
  bpy.ops.object.mode_set(mode='OBJECT')
  import bmesh
  for target,is_weapon in [(obj,False),(weapon,True)]:
   groups={name:target.vertex_groups.new(name=name)for name in ['Torso','UpperR','ForearmR','HandR','UpperL','ForearmL','HandL','Staff']}
   for v in target.data.vertices:
    grip=abs(v.co.z-spec['R'][2][2])<.055 and coordinate(v.co)in boundary
    w={'Staff':1}if is_weapon else {'HandR':1}if grip else weights(v.co,spec)
    for name,value in w.items():
     if value>1e-8:groups[name].add([v.index],value,'REPLACE')
   bm=bmesh.new();bm.from_mesh(target.data)
   bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
   edges=[e for e in bm.edges if e.is_boundary]
   if edges:bmesh.ops.holes_fill(bm,edges=edges,sides=0)
   bmesh.ops.triangulate(bm,faces=list(bm.faces))
   bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
   bm.to_mesh(target.data);bm.free()
   target.data.validate(clean_customdata=True);target.data.update()
   target.parent=rig;mod=target.modifiers.new('TLT_Skin','ARMATURE');mod.object=rig
   target['SourceKind']=kind;target['MR01Candidate']=True
  # Staff and HandR are coincident in rest space. No independent Staff animation:
  # grip boundary matrices remain identical through every shoulder/elbow/wrist pose.
  rig.animation_data_create();actions={}
  for clip in CLIPS:
   action=bpy.data.actions.new(kind+'__'+clip);rig.animation_data.action=action
   phases=[0,.25,.5,.75,1]if clip in ['Idle','Walk','Stunned','Exposed','Return','Interrupted']else[0,.4,.62,.78,1]
   for phase in phases:
    pose(rig,clip,phase)
    for b in rig.pose.bones:b.keyframe_insert(data_path='rotation_quaternion',frame=phase*100,group=b.name)
   action.use_fake_user=True;actions[clip]=action
  rig.animation_data.action=None
  for clip,action in actions.items():
   track=rig.animation_data.nla_tracks.new();track.name=clip;strip=track.strips.new(clip,0,action);track.mute=False
  rig.animation_data.action=None;scene.frame_start=0;scene.frame_end=100;scene.render.fps=60;scene.frame_set(0)
  bpy.ops.object.select_all(action='DESELECT')
  for o in [obj,weapon,rig]:o.select_set(True)
  bpy.context.view_layer.objects.active=rig
  # Discover the exporter enum rather than relying on an undocumented identifier.
  prop=bpy.ops.export_scene.gltf.get_rna_type().properties['export_animation_mode']
  modes=[i.identifier for i in prop.enum_items]
  assert 'NLA_TRACKS' in modes
  animation_mode='NLA_TRACKS'
  bpy.ops.export_scene.gltf(filepath=OUT+kind+'-rigged.glb',export_format='GLB',use_selection=True,use_active_scene=True,export_animation_mode=animation_mode,export_animations=True,export_rest_position_armature=True,export_anim_single_armature=False)
  for track in rig.animation_data.nla_tracks:track.mute=True
  camera=bpy.data.cameras.new(kind+'__Camera');cam=bpy.data.objects.new(kind+'__Camera',camera);scene.collection.objects.link(cam);scene.camera=cam
  camera.type='ORTHO';camera.ortho_scale=1.55
  scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='TEXTURE';scene.display.shading.show_shadows=True
  scene.world=bpy.data.worlds.new(kind+'__World');scene.world.color=(.12,.14,.18);scene.display.shading.background_type='WORLD'
  scene.render.resolution_x=440;scene.render.resolution_y=480;scene.render.resolution_percentage=100
  renders=[]
  for clip in CLIPS:
   rig.animation_data.action=actions[clip]
   phases=[.4,.62,.78]if clip in ['Attack','AttackAlt','Heavy','HeavyAlt']else[0,1]if clip in ['Return','Interrupted']else[.25]
   for phase in phases:
    frame=phase*100;scene.frame_set(int(frame))
    for view,location in [('front',(0,-2.5,.67)),('side',(2.5,-.25,.67))]:
     target=Vector((0,0,.5));cam.location=Vector(location);cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler()
     path=REVIEW+kind+'-'+clip+'-'+str(phase)+'-'+view+'.png';scene.render.filepath=path;bpy.ops.render.render(write_still=True);renders.append(path)
  rig.animation_data.action=actions['Attack'];scene.frame_set(62)
  # The skinned GLB plus this reproducible script is the editable source package.
  # Do not save the user's unrelated live Blender scenes into this repository.
  results[kind]={'sourceFaces':source_count,'skinFaces':len(obj.data.polygons),'staffFaces':len(weapon.data.polygons),'sharedGripVertices':len(boundary),'bones':list(rig.pose.bones.keys()),'actions':list(actions),'renders':len(renders),'scene':scene.name}
finally:
 bpy.context.window.scene=bpy.data.scenes.get(previous_name) or bpy.data.scenes[0]
print('MR01_AUTHORING '+json.dumps(results))
