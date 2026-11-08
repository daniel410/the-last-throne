"""TLT-065 Venomcoil King v2: execute through Blender MCP; modifies only the dedicated new scene.

Original Meshy vertices, polygons, UVs and materials remain intact. Skin weights
are assigned consistently to coincident vertices to avoid UV-seam tearing.
"""
import bpy, math, json
from mathutils import Vector, Quaternion

BASE = '/Users/daniel/Workspace/project/roblox/the-last-throne/assets/models/venomcoil-king-v2/'
SPECS = {'VenomcoilKing': ('Crimson_Carapace_Colo', 'centipede')}
CLIPS = {'Idle':2.4,'Walk':1.0,'Attack':1.2,'AttackAlt':1.2,'Heavy':1.7,'HeavyAlt':1.7,'Stunned':.7,'Exposed':1.0,'Return':.5,'Interrupted':.45}

def segment_distance(p,a,b):
 d=b-a;t=max(0,min(1,(p-a).dot(d)/max(d.length_squared,1e-9)))
 return (p-a-d*t).length,t

def animate(rig, shape, clip, phase):
 attack=clip in ('Attack','AttackAlt','Heavy','HeavyAlt')
 # Contact is at normalized .62, matching the existing enemy presentation clock.
 keys=[(0,0),(.4,1),(.62,-.6),(.8,-.15),(1,0)]
 strength=0
 if attack:
  for (a,x),(b,y) in zip(keys,keys[1:]):
   if a<=phase<=b:strength=x+(y-x)*(phase-a)/(b-a);break
  strength*=1.35 if clip.startswith('Heavy') else 1
 for bone in rig.pose.bones:
  bone.location=(0,0,0);bone.rotation_mode='QUATERNION';bone.rotation_quaternion=Quaternion()
  name=bone.name;rx=ry=rz=0
  if name=='Body':
   if clip=='Idle':bone.location.z=.002*math.sin(phase*2*math.pi)
   if attack:rx=-.10*strength;bone.location.y=.016*strength
   if clip=='Stunned':rz=.045*math.sin(phase*6*math.pi)
   if clip=='Exposed':rx=.08
  if name.startswith('Segment'):
   number=int(name[7:]);rz=.035*math.sin(phase*2*math.pi-number*.6) if clip=='Walk' else .005*math.sin(phase*2*math.pi-number*.4)
   if attack:rx=.06*strength*max(0,1-number/7)
  # All edit bones use the same vertical rest axis. Conjugation keeps changes
  # in Blender world axes regardless of the bone's local roll.
  q=Quaternion((0,0,1),rz)@Quaternion((0,1,0),ry)@Quaternion((1,0,0),rx)
  rest=bone.bone.matrix_local.to_quaternion();bone.rotation_quaternion=rest.inverted()@q@rest

previous=bpy.context.window.scene
scene=bpy.data.scenes['TLT_VenomcoilKing_v2'];bpy.context.window.scene=scene
scene.render.fps=40
results=[]
for kind,(original,shape) in SPECS.items():
 source=next(o for o in scene.objects if o.type=='MESH' and o.name in ('geometry_0',original));source.name=original
 obj=source.copy();obj.data=source.data.copy();scene.collection.objects.link(obj)
 obj.name=kind+'_Body';obj.location=(0,0,0)
 arm=bpy.data.armatures.new(kind+'_Skeleton');rig=bpy.data.objects.new(kind+'_Rig',arm);scene.collection.objects.link(rig)
 bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
 definitions=[];chains=[]
 def bone(name,head,parent='Body',role='body'):
  b=arm.edit_bones.new(name);b.head=head;b.tail=Vector(head)+Vector((0,0,.04))
  if parent:b.parent=arm.edit_bones[parent]
  definitions.append({'name':name,'head':list(head),'parent':parent,'role':role});return name
 bone('Root',(0,0,0),None);bone('Body',(0,0,0),'Root')
 centers=[(-.027,-.36),(.01,-.28),(.069,-.20),(.083,-.12),(.064,-.04),(.011,.04),(.01,.12),(.071,.20),(.102,.28),(.072,.36),(-.046,.42),(-.058,.46)]
 for i,(x,y) in enumerate(centers):
  z=(-.02 if kind=='VenomcoilCentipede' else (.03 if i==0 else -.05 if i==1 else -.10))
  name=bone('Segment'+str(i),(x,y,z),role='segment');chains.append((name,Vector((x,y,z)),Vector((x,y+.035,z))))
 bpy.ops.object.mode_set(mode='OBJECT')
 groups={d['name']:obj.vertex_groups.new(name=d['name'])for d in definitions}
 for v in obj.data.vertices:
  p=v.co;eligible=True
  weights={'Body':1}
  if eligible:
   nearest=sorted((segment_distance(p,a,b)[0],name)for name,a,b in chains)
   if nearest:
    d,name=nearest[0];weights={name:1}
    # Blend only near anatomical joints; same computation for coincident verts.
    if len(nearest)>1 and nearest[1][0]-d<.025:
     other=nearest[1][1];w=.5+.5*(nearest[1][0]-d)/.025;weights={name:w,other:1-w}
  for name,w in weights.items():groups[name].add([v.index],w,'REPLACE')
 mod=obj.modifiers.new('GloamwoodSkin','ARMATURE');mod.object=rig;obj.parent=rig
 rig['GloamwoodKind']=kind;rig['GloamwoodShape']=shape;rig['RigSchema']=1
 rig.animation_data_create()
 for clip,duration in CLIPS.items():
  action=bpy.data.actions.new(kind+'_'+clip);rig.animation_data.action=action
  for frame in range(41):
   phase=frame/40;animate(rig,shape,clip,phase)
   for b in rig.pose.bones:b.keyframe_insert('rotation_quaternion',frame=frame);b.keyframe_insert('location',frame=frame)
  track=rig.animation_data.nla_tracks.new();track.name=clip
  strip=track.strips.new(clip,0,action);strip.scale=duration
  track.mute=True
 rig.animation_data.action=None
 for track in rig.animation_data.nla_tracks:track.mute=False
 for b in rig.pose.bones:b.location=(0,0,0);b.rotation_quaternion=Quaternion()
 bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);rig.select_set(True);bpy.context.view_layer.objects.active=rig
 bpy.ops.export_scene.gltf(filepath=BASE+'rigged/'+kind+'.glb',export_format='GLB',use_selection=True,use_active_scene=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_skins=True,export_force_sampling=True,export_frame_range=False,export_yup=True)
 for track in rig.animation_data.nla_tracks:track.mute=True
 results.append({'kind':kind,'shape':shape,'bones':definitions,'triangles':sum(len(f.vertices)-2 for f in obj.data.polygons),'vertices':len(obj.data.vertices),'clips':list(CLIPS),'source':original})
 # Keep each authoring rig near its original in the review scene.
 rig.location=source.location
 source.hide_set(True)
bpy.context.window.scene=previous
print('GLOAMWOOD_RIG_REPORT='+json.dumps(results))
