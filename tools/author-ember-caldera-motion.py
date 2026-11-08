"""Execute via Blender MCP. INPUT is the pinned manifest supplied by the caller.

Native custom-property F-curves are evaluated to export, with matching Z-up previews.
The source scene is preserved; the new scene and .blend are separate artifacts.
"""
import bpy,math,json
from mathutils import Matrix,Vector
old_scene=bpy.context.scene
scene=bpy.data.scenes.new('TLT_EmberCaldera_Monsters_v1');bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
if old_scene.name.startswith('TLT_EmberCaldera_Monsters_v1'):
 for o in list(old_scene.objects):bpy.data.objects.remove(o,do_unlink=True)
 bpy.data.scenes.remove(old_scene)
 scene.name='TLT_EmberCaldera_Monsters_v1'
channels=['body','weapon','off','rightLeg','leftLeg'];clips=['Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned']
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
result={'version':1,'samples':201,'fps':120,'impactPhase':.62,'channels':channels,'models':{}}
sockets={};actions={}

def body(y=0,pitch=0,yaw=0,roll=0,z=0):return [0,y,z,pitch,yaw,roll,1,1,1]
def pose(b=None,w=None,o=None,r=None,l=None):return {'body':b or body(),'weapon':w or [0,0,0],'off':o or [0,0,0],'rightLeg':r or [0,0,0],'leftLeg':l or [0,0,0]}
def curves(a):return [f for layer in a.layers for strip in layer.strips for bag in strip.channelbags for f in bag.fcurves]
for idx,(kind,spec) in enumerate(INPUT['models'].items()):
 before=set(scene.objects)
 bpy.ops.import_scene.gltf(filepath=ROOT+'/assets/shared/td-ember-caldera/source/'+spec['template']+'/textured-review.glb')
 meshes={o.name.split('.')[0]:o for o in set(scene.objects)-before if o.type=='MESH'}
 quad='LegFL' in meshes;caster=kind in ['VolcanoShaman','KingVolcanoShaman'];heavy=kind in ['Golem','MagmaGolem','CalderaTitan','InfernoOverlord']
 root=bpy.data.objects.new(kind+'_Root',None);scene.collection.objects.link(root)
 ctrl={};pivots={k:list(v) for k,v in spec['pivots'].items()}
 if caster:pivots['ArmR'][1]=.70
 if kind=='InfernoOverlord':pivots['ArmR']=[.25,.72,-.04];pivots['ArmL']=[-.34,.72,-.04]
 mapping={'weapon':'LegFR' if quad else 'ArmR','off':'LegFL' if quad else 'ArmL','rightLeg':'LegBL' if quad else 'LegL','leftLeg':'LegBR' if quad else 'LegR'}
 for ch in channels:
  c=bpy.data.objects.new(kind+'_'+ch,None);scene.collection.objects.link(c);ctrl[ch]=c;c.parent=root if ch=='body' else ctrl['body']
  c.rotation_mode='XYZ';c.empty_display_type='PLAIN_AXES';c.empty_display_size=.08
  if ch!='body' and mapping[ch] in pivots:c.location=B@Vector(pivots[mapping[ch]])
 bpy.context.view_layer.update()
 for name,m in meshes.items():
  original=m.matrix_world.copy();ch=next((c for c,n in mapping.items() if n==name),'body');m.parent=ctrl[ch];m.matrix_world=original;m.name=kind+'_'+name
 bpy.context.view_layer.update()
 if 'ArmR' in meshes:
  m=meshes['ArmR'];pts=[v.co.copy() for v in m.data.vertices];mins=Vector([min(v[i] for v in pts) for i in range(3)]);maxs=Vector([max(v[i] for v in pts) for i in range(3)]);extent=maxs-mins;center=(maxs+mins)*.5
  # Select the actual distal weapon/focus vertices, rather than the arm bounds.
  def weapon_height(p):return (m.matrix_world@p).z
  ranked=sorted(pts,key=weapon_height,reverse=True);tip=sum(ranked[:max(6,len(ranked)//40)],Vector())/max(6,len(ranked)//40)
  local=tip-center;normal=[-local.x/max(.001,extent.x),local.z/max(.001,extent.z),local.y/max(.001,extent.y)];base=list(normal);base[1]=max(-.5,base[1]-.18)
  sockets[kind]={'shoulders':{'weapon':pivots['ArmR'],'off':pivots['ArmL']},'tip':normal,'base':base,'caster':caster}
  marker=bpy.data.objects.new(kind+'_WeaponTip',None);scene.collection.objects.link(marker);marker.parent=m;marker.location=tip;marker.empty_display_type='SPHERE';marker.empty_display_size=.025
 rest={c:ctrl[c].location.copy() for c in channels}
 result['models'][kind]={'hasLegs':any(n.startswith('Leg') for n in meshes),'quadruped':quad,'stride':.64 if quad else .44 if caster else .50,'breathSeconds':2.8 if heavy else 2.1,'clips':{},'pivots':pivots,'squash':kind=='LavaSlime','lift':kind=='MagmaWorm'}
 guard=pose(w=[-8,0,-5],o=[-4,0,5]) if caster else pose()
 for clip in clips:
  keys=[]
  if clip in ['Idle','Walk','Stunned']:
   for i in range(9):
    t=i/8;sn=math.sin(t*math.tau);cs=math.cos(t*math.tau)
    if clip=='Idle':p=pose(body(.002*sn,0,0,.6*sn),[-8+sn,0,-5] if caster else [sn,0,0],[-4-sn,0,5] if caster else [-sn,0,0])
    elif clip=='Stunned':p=pose(body(-.025,8,2*sn,3*cs),[8+3*sn,0,-9],[8-3*sn,0,9],[0,0,2],[0,0,-2])
    elif quad:p=pose(body(.009*(1-math.cos(t*math.tau*2)),2*sn,0,1.5*sn),[24*sn,0,0],[-24*sn,0,0],[24*sn,0,0],[-24*sn,0,0])
    else:
     amp=15 if heavy else 24;p=pose(body(.006*(1-math.cos(t*math.tau*2)),1.5*sn,2*sn,1.5*sn),[-8+7*sn,0,-5] if caster else [-amp*.6*sn,0,0],[-4-7*sn,0,5] if caster else [amp*.6*sn,0,0],[amp*sn,0,0],[-amp*sn,0,0])
    if kind=='LavaSlime':
     p=pose(body(.012*(1-cs),0,0,2*sn));p['body'][6:9]=[1+.055*sn,1-.07*sn,1+.035*sn]
    elif kind=='MagmaWorm':p=pose(body(.015*(1-cs),3*sn,4*sn,2*sn,z=.015*sn))
    keys.append((t,p))
  else:
   strong=clip.startswith('Heavy');alternate=clip.endswith('Alt');side=-1 if alternate else 1
   if quad:
    ready=pose(body(-.035,-9,side*7,0,.025),[-10,0,-5],[12,0,5],[9,0,0],[-9,0,0]);contact=pose(body(-.01,16 if strong else 10,-side*9,0,-.065),[45 if strong else 24,0,-8],[-16,0,8],[-12,0,0],[12,0,0]);follow=pose(body(-.03,19,-side*11,0,-.075),[55,0,-9],[-20,0,9],[-14,0,0],[14,0,0])
   elif caster:
    ready=pose(body(-.012,-6,-side*10),[28,-side*20,-12],[-32,side*10,22],[4,0,0],[-4,0,0]);contact=pose(body(-.008,5,side*10),[-34,side*15,8],[-45,-side*15,12],[-5,0,0],[5,0,0]);follow=pose(body(-.012,8,side*14),[-45,side*18,10],[-28,0,14])
   else:
    ready=pose(body(-.018,-10,-side*12),[108 if strong else 85,-side*20,-19],[-55 if strong else -18,side*10,12],[8,0,0],[-8,0,0]);contact=pose(body(-.025,14,side*15),[-64,side*20,14],[-55 if strong else 12,-side*12,-8],[-9,0,0],[9,0,0]);follow=pose(body(-.035,19,side*20),[-88,side*29,20],[-68 if strong else 18,-side*15,-10])
   if kind=='LavaSlime':
    ready=pose(body());ready['body'][6:9]=[1.12,.78,1.12]
    contact=pose(body(.08,9,0,0,z=-.07));contact['body'][6:9]=[.9,1.12,.9]
    follow=pose(body(0,0,0,0,z=-.04));follow['body'][6:9]=[1.16,.78,1.16]
   elif kind=='MagmaWorm':
    ready=pose(body(.02,-12,-side*10));contact=pose(body(.08,23,side*10,z=-.07));follow=pose(body(0,30,side*15,z=-.09))
   elif kind=='InfernoOverlord' and strong:
    ready=pose(body(-.025,-12),[78,-12,-12],[32,12,12]);contact=pose(body(-.035,15),[-38,12,10],[-22,-12,-10]);follow=pose(body(-.04,20),[-58,18,16],[-35,-18,-16])
   keys=[(0,guard),(.24,ready),(.45,ready),(.54,ready),(.62,contact),(.72,follow),(.85,follow),(1,guard)]
  result['models'][kind]['clips'][clip]={};actions[kind+'|'+clip]={}
  for ch,c in ctrl.items():
   c.animation_data_create();a=bpy.data.actions.new(kind+'_'+clip+'_'+ch);a.use_fake_user=True;c.animation_data.action=a
   for t,p in keys:
    for i,value in enumerate(p[ch]):c['native'+str(i)]=float(value);c.keyframe_insert(data_path='["native'+str(i)+'"]',frame=t*120)
   native={int(f.data_path.split('native')[1].split('"')[0]):f for f in curves(a)}
   for f in native.values():
    for point in f.keyframe_points:point.interpolation='BEZIER';point.handle_left_type='AUTO_CLAMPED';point.handle_right_type='AUTO_CLAMPED'
   samples=[[round(native[i].evaluate(t*.6),7) for i in range(len(keys[0][1][ch]))] for t in range(201)];result['models'][kind]['clips'][clip][ch]=samples
   for t,values in enumerate(samples):
    angles=values[3:6] if ch=='body' else values;R=Matrix.Rotation(math.radians(angles[0]),3,'X')@Matrix.Rotation(math.radians(angles[1]),3,'Y')@Matrix.Rotation(math.radians(angles[2]),3,'Z');c.rotation_euler=(B@R@B.transposed()).to_euler('XYZ');c.keyframe_insert(data_path='rotation_euler',frame=t*.6)
    if ch=='body':
     c.location=B@Vector(values[:3]);c.keyframe_insert(data_path='location',frame=t*.6)
     c.scale=(values[6],values[8],values[7]);c.keyframe_insert(data_path='scale',frame=t*.6)
   for f in curves(a):
    if not f.data_path.startswith('["native'):
     for point in f.keyframe_points:point.interpolation='LINEAR'
   actions[kind+'|'+clip][ch]=a.name
 # One seven-clip review reel per species.
 for ch,c in ctrl.items():
  c.animation_data.action=None;track=c.animation_data.nla_tracks.new();track.name='Ember Caldera v1'
  for i,clip in enumerate(clips):track.strips.new(clip,i*140,bpy.data.actions[actions[kind+'|'+clip][ch]])
 root.location=((idx%5)*2.5,-(idx//5)*2.6,0)
 for o in [root]+list(root.children_recursive):o.hide_set(kind!='InfernoOverlord')
scene.render.fps=120
scene.frame_start=0;scene.frame_end=960
for i,clip in enumerate(clips):scene.timeline_markers.new(clip,frame=i*140)
scene.frame_set(354)
scene['ember_export']=json.dumps(result,separators=(',',':'));scene['ember_sockets']=json.dumps(sockets,separators=(',',':'))
bpy.ops.export_scene.gltf(filepath=ROOT+'/assets/animations/ember-caldera-v1/ember-caldera-motion.glb',use_active_scene=True,export_animations=True,export_extras=True,export_animation_mode='SCENE')
print('AUTHORED 10 species, 70 logical clips, 350 Actions, anatomical pivots, slime squash, worm lunges and weapon sockets')
