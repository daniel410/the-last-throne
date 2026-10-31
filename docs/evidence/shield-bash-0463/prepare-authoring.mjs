import fs from 'node:fs';
const folder='assets/animations/shield-bash-v1';fs.mkdirSync(folder,{recursive:true});
const poses=[
 [0,{},-25],
 [.065,{left:[0,.08,.08,65,-65,5],right:[0,0,.12,-5,20,-12],leftElbow:[0,0,0,20,0,0],torso:[0,0,.05,6,-8,0]},10],
 [.145,{left:[0,.08,-.12,88,-80,0],right:[0,0,.20,-12,30,-18],leftElbow:[0,0,0,12,0,0],torso:[0,0,0,0,2,0]},30],
 [.20,{left:[0,.05,-.45,90,-80,0],right:[0,0,.20,-12,30,-18],leftElbow:[0,0,0,0,0,0],elbow:[0,0,0,15,0,0],torso:[0,0,-.2,-8,12,0],leftHip:[0,0,0,-8,0,0],rightHip:[0,0,0,8,0,0]},30],
 [.30,{left:[0,.05,-.45,90,-80,0],right:[0,0,.20,-12,30,-18],leftElbow:[0,0,0,0,0,0],elbow:[0,0,0,15,0,0],torso:[0,0,-.2,-8,12,0],leftHip:[0,0,0,-8,0,0],rightHip:[0,0,0,8,0,0]},30],
 [.46,{left:[0,.05,-.10,80,-70,3],right:[0,0,.12,-8,20,-12],leftElbow:[0,0,0,18,0,0],torso:[0,0,-.05,-3,4,0]},10],
 [.70,{},-25]
];
const code=`import bpy,json,math
from mathutils import Matrix,Vector,Euler
data=json.loads(${JSON.stringify(JSON.stringify(poses))})
s=bpy.data.scenes.new('TLT_Shield_Bash_Leading');bpy.context.window.scene=s;s.render.fps=120;s.frame_start=0;s.frame_end=84
original=bpy.data.objects['knight_Rig'];rig=original.copy();rig.data=original.data.copy();rig.animation_data_clear();s.collection.objects.link(rig);rig.name='Knight_ShieldBash_Rig';rig.location=(0,0,0)
for o in list(original.children):
 c=o.copy();s.collection.objects.link(c);c.parent=rig;c.name='ShieldBash_'+o.name
 for mod in c.modifiers:
  if mod.type=='ARMATURE' and mod.object==original:mod.object=rig
for pb in rig.pose.bones:pb.rotation_mode='XYZ';pb.rotation_euler=(0,0,0);pb.location=(0,0,0)
mapping={'right':'RightShoulder','left':'LeftShoulder','elbow':'RightElbow','leftElbow':'LeftElbow','wrist':'RightWrist','torso':'Waist','rightHip':'RightHip','leftHip':'LeftHip','weapon':'WeaponSocket'}
action=bpy.data.actions.new('Knight_ShieldBash_Leading');action.use_fake_user=True;rig.animation_data_create();rig.animation_data.action=action
slot=action.slots.new('OBJECT',rig.name);rig.animation_data.action_slot=slot
bag=action.layers.new('Native pose').strips.new(type='KEYFRAME').channelbag(slot,ensure=True)
curves={}
for channel in mapping:
 curves[channel]=[]
 for i in range(6):
  prop=channel+str(i);rig[prop]=0.0;f=bag.fcurves.new(data_path='["'+prop+'"]',index=0,group_name=channel)
  for t,pose,weapon in data:
   v=pose.get(channel,[0,0,0,0,0,0])[i]
   if channel=='weapon' and i==3:v=weapon
   k=f.keyframe_points.insert(t*120,v);k.interpolation='BEZIER';k.handle_left_type='AUTO_CLAMPED';k.handle_right_type='AUTO_CLAMPED'
  curves[channel].append(f)
out={'fps':120,'duration':.7,'windup':.2,'active':.1,'recovery':.4,'order':'Yaw * Pitch * Roll','channels':list(mapping),'samples':[]}
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
for frame in range(85):
 sample={ch:[round(f.evaluate(frame),7) for f in curves[ch]] for ch in mapping};out['samples'].append(sample)
 for ch,bone in mapping.items():
  v=sample[ch];pb=rig.pose.bones[bone]
  native=Matrix.Rotation(math.radians(v[4]),3,'Y')@Matrix.Rotation(math.radians(v[3]),3,'X')@Matrix.Rotation(math.radians(v[5]),3,'Z')
  pb.rotation_euler=(B@native@B.inverted()).to_euler();pb.location=B@Vector(v[:3]);pb.keyframe_insert(data_path='rotation_euler',frame=frame,group=ch);pb.keyframe_insert(data_path='location',frame=frame,group=ch)
action['contact_frame']=24;action['purpose']='Shield leads real sword bounds; retracted sword, native torso-space axes'
s.frame_set(24)
bpy.ops.wm.save_as_mainfile(filepath='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/animations/shield-bash-v1/shield-bash.blend',compress=True)
print('TLT_SHIELD_EXPORT '+json.dumps(out,separators=(',',':')))
`;
fs.writeFileSync('docs/evidence/shield-bash-0463/01-author.mcp.json',JSON.stringify({name:'execute_blender_code',arguments:{user_prompt:'기사 쉴드 배시 스킬은 방패가 칼보다 더 앞으로 나오도록 Blender MCP 내부 API로 개선해줘',code}},null,2)+'\n');
