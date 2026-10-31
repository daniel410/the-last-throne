// Send Blender scene/curve authoring through MCP, never launch a Python script.
import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
const dir='docs/evidence/deepwood-motion-0450';
const sources=JSON.parse(fs.readFileSync('assets/animations/deepwood-monsters-v1/sources.json'));
const models=Object.fromEntries(Object.entries(sources).map(([kind,v])=>{
 const file=path.resolve(v.path);if(crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')!==v.sha256)throw Error('TD source changed: '+v.path);
 return [kind,{...v,path:file}];
}));
const code=`import bpy,json,math
from mathutils import Matrix,Vector,Euler
models=json.loads(${JSON.stringify(JSON.stringify(models))})
s=bpy.data.scenes.get('TLT_Monster_Motion_Authoring');bpy.context.window.scene=s;s.render.fps=60
for o in list(s.objects):bpy.data.objects.remove(o,do_unlink=True)
# The authoring scene belongs to this task.
collection=bpy.data.collections.new('Deepwood_Motion_v1');s.collection.children.link(collection)
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)));Y=Matrix.Rotation(math.pi,3,'Y');basis=B@Y
out={'version':1,'fps':60,'impactPhase':.62,'samples':61,'channels':['body','weapon','off','rightLeg','leftLeg'],'models':{}}
def empty(name,pos,parent=None):
 o=bpy.data.objects.new(name,None);collection.objects.link(o);o.empty_display_type='ARROWS';o.empty_display_size=.08;o.parent=parent;o.location=pos;return o
def curve(action,obj,path,index,values):
 slot=action.slots[0] if len(action.slots)>0 else None
 if slot is None:slot=action.slots.new('OBJECT',obj.name)
 if len(action.layers)==0:action.layers.new('Motion').strips.new(type='KEYFRAME')
 bag=action.layers[0].strips[0].channelbag(slot,ensure=True)
 f=bag.fcurves.new(data_path=path,index=index,group_name=obj.name)
 for frame,value in values:
  k=f.keyframe_points.insert(frame,value);k.interpolation='BEZIER';k.handle_left_type='AUTO_CLAMPED';k.handle_right_type='AUTO_CLAMPED'
 return f
for n,(kind,spec) in enumerate(models.items()):
 before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=spec['path']);meshes=[o for o in set(bpy.data.objects)-before if o.type=='MESH']
 # Runtime rotates the TD +Z source 180 degrees into Roblox -Z.
 center=Vector(((n%5)*1.8,0,(n//5)*1.8));world=B@center
 rig=empty(kind+'_Root',world+B@Vector((0,.5,0)))
 body=empty(kind+'_Body',Vector((0,0,0)),rig)
 pivots={p['name']:basis@Vector(p['pivot'])-B@Vector((0,.5,0)) for p in spec['parts']}
 controls={'body':body}
 for ch,part in [('weapon','ArmR'),('off','ArmL'),('rightLeg','LegL'),('leftLeg','LegR')]:controls[ch]=empty(kind+'_'+ch,pivots.get(part,Vector()),body)
 for o in meshes:
  part=o.name.split('.')[0];o.name=kind+'_'+part;o.matrix_world=Matrix.Translation(world)@basis.to_4x4()@B.inverted().to_4x4()@o.matrix_world
  parent=controls.get({'ArmR':'weapon','ArmL':'off','LegL':'rightLeg','LegR':'leftLeg'}.get(part,'body'),body)
  mat=o.matrix_world.copy();bpy.context.view_layer.update();o.parent=parent;o.matrix_parent_inverse=Matrix.Identity(4);o.matrix_basis=parent.matrix_world.inverted()@mat
  for c in list(o.users_collection):c.objects.unlink(o)
  collection.objects.link(o)
 heavy=kind in ['Ogre','Warlord','KingOgre','EnragedWarlord'];caster=kind in ['Shaman','KingShaman'];slime=kind=='Slime';legs='LegL' in pivots
 profile={'stride':.48 if not heavy else .55,'breathSeconds':2.7 if heavy else 2.1,'hasLegs':legs,'sourceSha256':spec['sha256'],'clips':{}}
 for clip in ['Idle','Walk','Attack','Heavy','Stunned']:
  curves={};actions=[]
  phases=[0,.125,.25,.375,.5,.625,.75,.875,1] if clip in ['Idle','Walk','Stunned'] else [0,.18,.40,.50,.62,.78,1]
  values={ch:[[] for i in range(9 if ch=='body' else 3)] for ch in controls}
  for p in phases:
   wave=math.sin(p*math.tau);cos=math.cos(p*math.tau);v={ch:[0,0,0] for ch in controls};v['body']=[0,0,0,0,0,0,1,1,1]
   if clip=='Idle':
    v['body']=[0,.0025*wave,0,1*wave,0,.6*wave,1,1,1];v['weapon']=[1.5*wave,0,0];v['off']=[-wave,0,0]
   elif clip=='Walk':
    v['body']=[.008*wave,.006*(1-math.cos(p*math.tau*2)),0,3 if not heavy else 5,2*wave,2.5*wave,1,1,1]
    v['rightLeg']=[34*cos,0,0];v['leftLeg']=[-34*cos,0,0];v['weapon']=[-12*cos,0,-2];v['off']=[14*cos,0,2]
    if caster:v['weapon']=[-4*cos,0,0];v['body'][1]*=.4
    if slime:
     hop=max(0,math.sin(p*math.pi));squash=1-.16*math.cos(p*math.tau)
     v['body']=[0,.10*hop,0,5*wave,0,2*wave,1/math.sqrt(squash),squash,1/math.sqrt(squash)]
   elif clip in ['Attack','Heavy']:
    i=phases.index(p);load=[0,.35,.9,1,.28,.04,0][i];strike=[0,0,0,.04,1,.55,0][i];power=1.2 if clip=='Heavy' else 1
    v['body']=[.008*load,-.015*load, -.025*strike,-7*load+12*strike,-15*load+18*strike,-3*load+5*strike,1,1,1]
    v['weapon']=[(125*load+55*strike)*power,12*load-12*strike,-12*load+7*strike]
    v['off']=[(110 if clip=='Heavy' else 25)*load+25*strike,-5*load,12*load]
    v['rightLeg']=[-5*load+4*strike,0,0];v['leftLeg']=[5*load-4*strike,0,0]
    if caster:v['weapon']=[65*load+95*strike,28*load-18*strike,-12*load];v['off']=[55*load+70*strike,0,22*load]
    if slime:
     sy=1-.25*load+.16*strike;v['body']=[0,.06*strike, -.045*strike,10*strike,0,0,1/math.sqrt(sy),sy,1/math.sqrt(sy)]
   else:
    v['body']=[.002*wave,-.012,0,9+1.5*wave,2*wave,4+1.2*cos,1,1,1];v['weapon']=[22+3*wave,0,-8];v['off']=[16-3*wave,0,9]
    if slime:v['body']=[.003*wave,0,0,1*wave,0,2*wave,1.1,.82,1.1]
   for ch,vs in v.items():
    for i,value in enumerate(vs):values[ch][i].append((p*60,value))
  for ch,obj in controls.items():
   action=bpy.data.actions.new(kind+'_'+clip+'_'+ch);action.use_fake_user=True;actions.append(action)
   # Native channel properties on real rigid controllers are the export contract.
   fs=[]
   for i,keys in enumerate(values[ch]):
    prop='native'+str(i);obj[prop]=keys[0][1];fs.append(curve(action,obj,'["'+prop+'"]',0,keys))
   curves[ch]=fs
  profile['clips'][clip]={ch:[[round(f.evaluate(frame),6) for f in fs] for frame in range(61)] for ch,fs in curves.items()}
  # Bake actual transforms too, for editable Blender timeline preview.
  for ch,obj in controls.items():
   obj.animation_data_create();obj.animation_data.action=actions[list(controls).index(ch)]
   base=obj.location.copy()
   for frame in range(61):
    vals=profile['clips'][clip][ch][frame];angles=vals[3:6] if ch=='body' else vals[:3]
    rot=B@Euler(tuple(math.radians(a) for a in angles),'XYZ').to_matrix()@B.inverted();obj.rotation_euler=rot.to_euler()
    if ch=='body':obj.location=base+B@Vector(vals[:3]);obj.scale=(vals[6],vals[8],vals[7])
    obj.keyframe_insert(data_path='rotation_euler',frame=frame)
    if ch=='body':obj.keyframe_insert(data_path='location',frame=frame);obj.keyframe_insert(data_path='scale',frame=frame)
   obj.location=base
  # All channels are separate actions on their actual controllers.
 profile['controllers']={ch:obj.name for ch,obj in controls.items()};out['models'][kind]=profile
 s.frame_set(0)
s.frame_start=0;s.frame_end=60
bpy.ops.wm.save_as_mainfile(filepath='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/animations/deepwood-monsters-v1/deepwood-motion.blend')
print('TLT_MONSTER_EXPORT '+json.dumps(out,separators=(',',':')))
`;
fs.mkdirSync('assets/animations/deepwood-monsters-v1',{recursive:true});
fs.writeFileSync(dir+'/02-author.mcp.json',JSON.stringify({name:'execute_blender_code',arguments:{user_prompt:'deepwood 몬스터들의 걷기와 공격 움직임을 Blender MCP 내부 API로 자연스럽게 개선해줘',code}},null,2)+'\n');
console.log('Prepared Blender MCP request: 10 textured rigid rigs, 50 multi-controller clips');
