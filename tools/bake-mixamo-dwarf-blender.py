"""Bake export curves to editable Blender Actions and independently evaluate them."""
import bpy
import json
import math
import pathlib
import sys

root=pathlib.Path(__file__).resolve().parents[1]
profile=sys.argv[sys.argv.index('--')+1] if '--'in sys.argv else 'dwarf'
folder=root/('assets/animations/mixamo-'+profile+'-v1')
clips=json.loads((folder/'clips.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
s=bpy.context.scene
s.name='TLT_'+profile+'_Mixamo_Channels'
s.display_settings.display_device='sRGB';s.view_settings.view_transform='Standard'
s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False
s.render.fps=60
golden={}
for index,(name,clip) in enumerate(clips.items()):
    data=bpy.data.armatures.new(name+'_channels')
    obj=bpy.data.objects.new(profile+'_'+name,data);s.collection.objects.link(obj)
    bpy.context.view_layer.objects.active=obj;obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT')
    for i,ch in enumerate(clip['curves']):
        b=data.edit_bones.new(ch);b.head=(index*4,i*.2,0);b.tail=(index*4,i*.2,1)
    bpy.ops.object.mode_set(mode='OBJECT')
    curves={}
    for ch,axes in clip['curves'].items():
        p=obj.pose.bones[ch];p.rotation_mode='ZYX'
        for axis,keys in enumerate([axes]if ch=='draw'else axes):
            for t,v,m in keys:
                p.rotation_euler[axis]=math.radians(v)
                p.keyframe_insert(data_path='rotation_euler',index=axis,frame=t*60,group=ch)
            action=obj.animation_data.action
            bag=action.layers[0].strips[0].channelbag(obj.animation_data.action_slot)
            f=next(f for f in bag.fcurves if f.data_path==p.path_from_id('rotation_euler')and f.array_index==axis)
            for i,(key,(t,v,m)) in enumerate(zip(f.keyframe_points,keys)):
                l=(t-keys[i-1][0])/3 if i else (keys[1][0]-t)/3
                r=(keys[i+1][0]-t)/3 if i<len(keys)-1 else l
                key.interpolation='BEZIER';key.handle_left_type='FREE';key.handle_right_type='FREE'
                key.handle_left=(60*(t-l),math.radians(v-m*l))
                key.handle_right=(60*(t+r),math.radians(v+m*r))
            f.update();curves[(ch,axis)]=f
    obj.animation_data.action.name='Mixamo_'+profile+'_'+name
    obj.animation_data.action.use_fake_user=True
    golden[name]=[]
    for i in range(101):
        t=clip['duration']*i/100
        a={ch:[math.degrees(curves[(ch,axis)].evaluate(t*60)) for axis in range(3)]for ch in clip['curves']if ch!='draw'}
        row={'age':t,'angles':a}
        if 'draw'in clip['curves']:row['draw']=math.degrees(curves[('draw',0)].evaluate(t*60))
        golden[name].append(row)
    obj.select_set(False)
(folder/'blender-golden.json').write_text(json.dumps(golden,separators=(',',':'))+'\n')
s['source']='Downloaded Mixamo FBXs -> rest-pose retarget -> native FK grip fitting'
s['scope']='Editable rotation-channel rigs; final character skin is not replaced.'
bpy.ops.wm.save_as_mainfile(filepath=str(folder/(profile+'-mixamo-v1.blend')))
print('BAKED_MIXAMO_DWARF',len(golden),'actions')
