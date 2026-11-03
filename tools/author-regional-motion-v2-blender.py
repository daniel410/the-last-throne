# Input MOTION_KEYS from prepare-deepwood-motion-v3.py. Native properties are the export authority.
import bpy,json
scene=bpy.data.scenes.new('TLT_Regional_v2_Curves');previous=bpy.context.window.scene;bpy.context.window.scene=scene
result={k:v for k,v in MOTION_KEYS.items()if k!='models'};result['models']={};actions={}
def curves(action):return [f for layer in action.layers for strip in layer.strips for bag in strip.channelbags for f in bag.fcurves]
for kind,model in MOTION_KEYS['models'].items():
 result['models'][kind]={k:v for k,v in model.items()if k!='clips'};result['models'][kind]['clips']={}
 for ch in result['channels']:
  obj=bpy.data.objects.new(kind+'_v3_'+ch,None);scene.collection.objects.link(obj)
  for clip,keys in model['clips'].items():
   obj.animation_data_create();action=bpy.data.actions.new(kind+'_v3_'+clip+'_'+ch);action.use_fake_user=True;obj.animation_data.action=action
   for phase,pose in keys:
    for i,value in enumerate(pose[ch]):
     obj['native'+str(i)]=float(value);obj.keyframe_insert(data_path='["native'+str(i)+'"]',frame=phase*120)
   fc=curves(action)
   for f in fc:
    for p in f.keyframe_points:p.interpolation='BEZIER';p.handle_left_type='AUTO_CLAMPED';p.handle_right_type='AUTO_CLAMPED'
   by={int(f.data_path.split('native')[1].split('"')[0]):f for f in fc}
   values=[[round(by[i].evaluate(t*.6),7)for i in range(len(keys[0][1][ch]))]for t in range(201)]
   result['models'][kind]['clips'].setdefault(clip,{})[ch]=values
   actions[kind+'|'+clip+'|'+ch]=action.name
scene['regional_v2_export']=json.dumps(result,separators=(',',':'));scene['regional_v2_actions']=json.dumps(actions);scene.frame_start=0;scene.frame_end=120;scene.render.fps=120
bpy.context.window.scene=previous
print('AUTHORED',len(actions),'Blender actions from regional individual reviews')
