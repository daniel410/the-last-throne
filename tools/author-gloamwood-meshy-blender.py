"""TLT-065: execute through Blender MCP; modifies only the dedicated new scene.

Original Meshy vertices, polygons, UVs and materials remain intact. Skin weights
are assigned consistently to coincident vertices to avoid UV-seam tearing.
"""
import bpy, math, json
from mathutils import Vector, Quaternion

BASE = '/Users/daniel/Workspace/project/roblox/the-last-throne/assets/models/gloamwood-meshy-v1/'
SPECS = {
 'Webling': ('Amethyst_Arachnid', 'spider'),
 'Silkweaver': ('Amethyst_Bone_Spider', 'spider'),
 'Barkstalker': ('Mossfang_Arachnid', 'spider'),
 'WidowQueen': ('Amethyst_Skullspider', 'spider'),
 'Gloambat': ('Amethyst_Nightfang', 'bat'),
 'VenomcoilCentipede': ('Crimson_Centipede', 'centipede'),
 'VenomcoilKing': ('Crimson_Crystal_Scorpion', 'centipede'),
 'AncientHollowbark': ('Ancient_Forest_Golem', 'ent'),
}
PATHS = {
 'Webling': [((.10,-.12,.02),(.22,-.23,.05),(.25,-.36,-.18)),((.10,-.04,.03),(.29,-.08,.10),(.37,-.20,-.17)),((.12,.05,.04),(.32,.05,.13),(.40,.00,-.13)),((.14,.13,.06),(.34,.17,.17),(.47,.19,-.03))],
 'Silkweaver': [((.08,-.14,.01),(.21,-.19,.06),(.24,-.38,-.18)),((.08,-.06,.02),(.29,-.10,.11),(.38,-.31,-.18)),((.09,.02,.03),(.35,.04,.14),(.47,-.25,-.15)),((.10,.08,.04),(.34,.21,.17),(.45,-.02,.08))],
 'Barkstalker': [((.09,-.12,-.02),(.23,-.21,.01),(.30,-.37,-.16)),((.11,-.01,.00),(.32,-.10,.05),(.40,-.23,-.15)),((.14,.12,.02),(.38,.12,.10),(.47,.05,-.15)),((.15,.22,.03),(.39,.29,.13),(.47,.30,-.02))],
 'WidowQueen': [((.12,-.13,.00),(.23,-.21,.07),(.26,-.41,-.15)),((.13,-.02,.00),(.31,-.08,.07),(.38,-.22,-.15)),((.16,.10,.00),(.36,.10,.07),(.43,.02,-.15)),((.17,.23,.00),(.40,.29,.08),(.47,.24,-.14))],
}
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
  if name.startswith('Leg'):
   side=-1 if '_L' in name else 1
   number=int(name.split('_')[-1]);wave=math.sin(phase*2*math.pi+(number%2)*math.pi+(0 if side==1 else math.pi))
   if clip=='Walk':
    rz=.11*wave;rx=side*.08*max(0,wave) if 'Upper' in name else -side*.13*max(0,wave)
   if attack and number<=2:rx=side*.19*strength
  if name.startswith('Wing'):
   side=-1 if '_L' in name else 1
   ry=side*(.32*math.sin(phase*2*math.pi) if clip in ('Walk','Idle') else .25*strength)
   if 'Tip' in name:ry*=-.45
  if name.startswith('Segment'):
   number=int(name[7:]);rz=.035*math.sin(phase*2*math.pi-number*.6) if clip=='Walk' else .005*math.sin(phase*2*math.pi-number*.4)
   if attack:rx=.06*strength*max(0,1-number/7)
  if name.startswith(('Arm','Forearm','Thigh','Shin')):
   side=-1 if name.endswith('L') else 1
   if clip=='Walk':rx=(.13 if name.startswith(('Thigh','Shin')) else -.10)*math.sin(phase*2*math.pi+side*math.pi/2)
   if attack and name.startswith(('Arm','Forearm')):rx=(-.5 if name.startswith('Arm') else -.3)*strength
  # All edit bones use the same vertical rest axis. Conjugation keeps changes
  # in Blender world axes regardless of the bone's local roll.
  q=Quaternion((0,0,1),rz)@Quaternion((0,1,0),ry)@Quaternion((1,0,0),rx)
  rest=bone.bone.matrix_local.to_quaternion();bone.rotation_quaternion=rest.inverted()@q@rest

previous=bpy.context.window.scene
scene=bpy.data.scenes['TLT_Gloamwood_Meshy_v1'];bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
scene.render.fps=40
results=[]
for kind,(original,shape) in SPECS.items():
 source=bpy.data.objects[original]
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
 if shape=='spider':
  for side,label in [(-1,'L'),(1,'R')]:
   for i,path in enumerate(PATHS[kind],1):
    a,b,c=[Vector((v[0]*side,v[1],v[2]))for v in path]
    upper=bone('LegUpper_'+label+'_'+str(i),a,role='leg');lower=bone('LegLower_'+label+'_'+str(i),b,upper,'leg')
    chains.extend([(upper,a,b),(lower,b,c)])
 elif shape=='bat':
  for side,label in [(-1,'L'),(1,'R')]:
   upper=bone('Wing_'+label,(side*.055,-.02,.02),role='wing');tip=bone('WingTip_'+label,(side*.25,.01,.06),upper,'wing')
   chains.extend([(upper,Vector((side*.055,-.02,.02)),Vector((side*.25,.01,.06))),(tip,Vector((side*.25,.01,.06)),Vector((side*.47,.02,.03)))])
 elif shape=='ent':
  for side,label in [(-1,'L'),(1,'R')]:
   for prefix,a,b,c in [('Arm',(.18,0,.16),(.33,-.01,-.05),(.40,-.04,-.23)),('Thigh',(.13,.02,-.11),(.15,.02,-.25),(.17,-.02,-.40))]:
    va,vb,vc=[Vector((p[0]*side,p[1],p[2]))for p in (a,b,c)]
    first=bone(prefix+label,va,role='limb');second=bone(('Forearm' if prefix=='Arm' else 'Shin')+label,vb,first,'limb');chains.extend([(first,va,vb),(second,vb,vc)])
 else:
  centers=[(.17,-.34),(.15,-.25),(.17,-.15),(.18,-.05),(.19,.05),(.18,.15),(.14,.24),(.08,.31),(-.02,.36),(-.12,.39),(-.21,.42),(-.28,.43)]
  if kind=='VenomcoilKing':centers=[(-.08,-.32),(-.06,-.24),(-.02,-.15),(.04,-.06),(.10,.04),(.15,.14),(.17,.24),(.12,.32),(.04,.39),(-.05,.43),(-.14,.45),(-.23,.46)]
  for i,(x,y) in enumerate(centers):
   z=(-.02 if kind=='VenomcoilCentipede' else max(-.19,.06-i*.045))
   name=bone('Segment'+str(i),(x,y,z),role='segment');chains.append((name,Vector((x,y,z)),Vector((x,y+.035,z))))
 bpy.ops.object.mode_set(mode='OBJECT')
 groups={d['name']:obj.vertex_groups.new(name=d['name'])for d in definitions}
 for v in obj.data.vertices:
  p=v.co;eligible=True
  if shape=='spider':eligible=abs(p.x)>.13 and not (p.y>0 and abs(p.x)<.19)
  if shape=='bat':eligible=abs(p.x)>.085
  if shape=='ent':eligible=abs(p.x)>.21 or (p.z<-.15 and abs(p.x)>.065)
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
