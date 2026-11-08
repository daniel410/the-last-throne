# Run inside Blender MCP with SOLVED_POSES loaded from dwarf-diagonal-v1/poses.json.
# A new scene/action preserves all existing authoring scenes and source assets.
import bpy, json, math, copy
solved = SOLVED_POSES
src = bpy.data.objects['dwarf_Rig']
s = bpy.data.scenes.new('TLT_Dwarf_DiagonalCut_v1')
# TLT concept-color contract: explicit settings for every authoring/review scene.
s.display_settings.display_device = 'sRGB'
s.view_settings.view_transform = 'Standard'
s.view_settings.look = 'None'
s.view_settings.exposure = 0; s.view_settings.gamma = 1
s.view_settings.use_curve_mapping = False
s.render.fps = 60
s.frame_start, s.frame_end = 0, 26
r = src.copy()
r.data = src.data.copy()
r.name = 'Dwarf_DiagonalRig'
r.animation_data_clear()
s.collection.objects.link(r)
for o in list(bpy.data.objects):
    if o.name.startswith('dwarf_') and o.type == 'MESH':
        n = o.copy()
        n.data = o.data.copy()
        n.name = 'Diagonal_' + o.name
        n.parent = r
        s.collection.objects.link(n)
        for mod in n.modifiers:
            if mod.type == 'ARMATURE':
                mod.object = r
mapping = {'right':'RightShoulder','left':'LeftShoulder','elbow':'RightElbow','leftElbow':'LeftElbow','wrist':'RightWrist','neck':'Neck','torso':'Waist','rightHip':'RightHip','leftHip':'LeftHip','rightKnee':'RightKnee','leftKnee':'LeftKnee','weapon':'WeaponSocket'}
data = json.loads(bpy.data.scenes['TLT_Melee_Authoring']['authored_clips'])
poses = [copy.deepcopy(data['rest']['dwarf'])] + [p['angles'] for p in solved] + [copy.deepcopy(data['guard']['dwarf'])]
poses[1]['right'], poses[1]['weapon'] = [70,-22,-25], [-65,-25,-30]
times = [0,.052,.11,.18,.22,.29,.42]
a = bpy.data.actions.new('Dwarf_RightTemple_To_LeftKnee_v1')
a.use_fake_user = True
r.animation_data_create()
r.animation_data.action = a
clip = {'name':a.name,'classId':'dwarf','combo':1,'windup':.16,'active':.10,'recovery':.16,'hitDelay':.06,'duration':.42,'entryUntil':.072,'curves':{},'golden':[]}
for channel, bone in mapping.items():
    pb = r.pose.bones[bone]
    pb.rotation_mode = 'YZX'
    clip['curves'][channel] = []
    for native, (axis, sign) in enumerate([(0,1),(2,1),(1,-1)]):
        values = [p[channel][native] for p in poses]
        slopes = [0.] * len(times)
        for i in range(1, len(times)-1):
            h0, h1 = times[i]-times[i-1], times[i+1]-times[i]
            v0, v1 = (values[i]-values[i-1])/h0, (values[i+1]-values[i])/h1
            if v0*v1 > 0:
                slopes[i] = 3*(h0+h1)/((2*h1+h0)/v0+(h1+2*h0)/v1)
        for time, value in zip(times, values):
            pb.rotation_euler[axis] = math.radians(value)*sign
            pb.keyframe_insert(data_path='rotation_euler', index=axis, frame=time*60, group=channel)
        curves = a.layers[0].strips[0].channelbag(r.animation_data.action_slot).fcurves
        fc = next(f for f in curves if f.data_path == pb.path_from_id('rotation_euler') and f.array_index == axis)
        for i, key in enumerate(fc.keyframe_points):
            key.interpolation = 'BEZIER'
            key.handle_left_type = key.handle_right_type = 'FREE'
            left = (times[i]-times[i-1])/3 if i else times[1]/3
            right = (times[i+1]-times[i])/3 if i < len(times)-1 else left
            key.handle_left = (key.co.x-left*60, math.radians(values[i]-slopes[i]*left)*sign)
            key.handle_right = (key.co.x+right*60, math.radians(values[i]+slopes[i]*right)*sign)
        fc.update()
        clip['curves'][channel].append([[t,v,m] for t,v,m in zip(times,values,slopes)])
for i in range(43):
    time = .42*i/42
    angles = {}
    for channel, bone in mapping.items():
        values = []
        for axis, sign in [(0,1),(2,1),(1,-1)]:
            fc = next(f for f in curves if f.data_path == r.pose.bones[bone].path_from_id('rotation_euler') and f.array_index == axis)
            values.append(math.degrees(fc.evaluate(time*60))*sign)
        angles[channel] = values
    clip['golden'].append({'age':time,'angles':angles})
s['diagonal_clip'] = json.dumps(clip)
bpy.context.window.scene = s
s.frame_set(7)
print('DIAGONAL_CLIP_JSON ' + json.dumps(clip))
