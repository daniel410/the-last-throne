"""Blender background: extract actual Mixamo FBX rotations into TLT torso axes.

Run with --source-dir /path/to/downloads. Source FBXs remain local; their hashes
and download settings are recorded. No network, physics-root translation, or rig
replacement. R6 deliberately retains its previously reviewed rigid-arm curves.
"""
import argparse
import hashlib
import json
import math
import pathlib
import sys
import bpy
from mathutils import Matrix, Euler

parser = argparse.ArgumentParser()
parser.add_argument('--source-dir', required=True)
parser.add_argument('--profile', choices=['dwarf','knight','elf'], default='dwarf')
args = parser.parse_args(sys.argv[sys.argv.index('--')+1:])
ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / ('assets/animations/mixamo-'+args.profile+'-v1')
OUT.mkdir(parents=True, exist_ok=True)
scene = bpy.context.scene
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0
scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False

# Blender Z-up / Mixamo forward -Y -> Roblox Y-up / forward -Z.
B = Matrix(((-1,0,0),(0,0,1),(0,1,0)))
mapping = {
 'torso': ('Spine2', None, 0), 'neck': ('Head', 'torso', 0),
 'right': ('RightArm', 'torso', 90), 'elbow': ('RightForeArm', 'right', 90),
 'wrist': ('RightHand', 'elbow', 90),
 'left': ('LeftArm', 'torso', -90), 'leftElbow': ('LeftForeArm', 'left', -90),
 'rightHip': ('RightUpLeg', None, 0), 'rightKnee': ('RightLeg', 'rightHip', 0),
 'leftHip': ('LeftUpLeg', None, 0), 'leftKnee': ('LeftLeg', 'leftHip', 0),
}
names = ['Standing Melee Attack Horizontal', 'Standing Melee Attack Downward',
         'Standing Melee Attack Backhand', 'Standing Melee Attack 360 Low',
         'Standing Melee Run Jump Attack', 'Standing Melee Combo Attack Ver. 1']
if args.profile=='knight':
    names=sorted(p.stem for p in pathlib.Path(args.source_dir).glob('*.fbx')
                 if p.stem.startswith(('sword and shield slash','sword and shield attack','sword and shield block')))
elif args.profile=='elf':
    names=['Standing Draw Arrow']
result = {'schemaVersion':1, 'download':{'format':'FBX Binary','skin':'With Skin',
 'fps':60,'keyframeReduction':'none','overdrive':50,'armSpace':50,'mirror':False,'trim':[0,100],
 'profile':args.profile,'packPose':'T-pose' if args.profile=='knight' else None},
 'color':{'display':'sRGB','view':'Standard','look':'None','exposure':0,'gamma':1,'curves':False},
 'mapping':mapping, 'clips':{}}
for name in names:
    path = pathlib.Path(args.source_dir) / (name+'.fbx')
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.fbx(filepath=str(path))
    arm = next(o for o in scene.objects if o.type=='ARMATURE')
    action = arm.animation_data.action
    start,end = [float(x) for x in action.frame_range]
    fps = scene.render.fps / scene.render.fps_base
    # Bind-pose offsets explicitly account for Mixamo T-pose versus R15 arms-down.
    offsets = {}
    for channel,(bone,parent,tpose) in mapping.items():
        rest = B @ (arm.matrix_world @ arm.data.bones['mixamorig:'+bone].matrix_local).to_quaternion().to_matrix()
        offsets[channel] = rest.inverted() @ Matrix.Rotation(math.radians(tpose),3,'Z')
    frames=[]
    previous={}
    for i in range(round(end-start)+1):
        scene.frame_set(round(start+i))
        world={}
        for channel,(bone,parent,tpose) in mapping.items():
            world[channel] = B @ (arm.matrix_world @ arm.pose.bones['mixamorig:'+bone].matrix).to_quaternion().to_matrix() @ offsets[channel]
        # Remove locomotion heading before fitting an in-place attack. Whole-body
        # spin is a separate presentation operation, never a 360-degree waist.
        hips = B @ (arm.matrix_world @ arm.pose.bones['mixamorig:Hips'].matrix).to_quaternion().to_matrix()
        hips_rest = B @ (arm.matrix_world @ arm.data.bones['mixamorig:Hips'].matrix_local).to_quaternion().to_matrix()
        hips_delta=hips @ hips_rest.inverted()
        heading=math.atan2(hips_delta[0][2],hips_delta[2][2])
        unheading=Matrix.Rotation(-heading,3,'Y')
        for channel in world: world[channel]=unheading @ world[channel]
        angles={}
        for channel,(bone,parent,tpose) in mapping.items():
            local = world[parent].inverted() @ world[channel] if parent else world[channel]
            # CFrame.Angles(x,y,z) is Rx*Ry*Rz, i.e. Blender's ZYX Euler order.
            e=local.to_euler('ZYX',previous[channel]) if channel in previous else local.to_euler('ZYX')
            previous[channel]=e.copy()
            angles[channel]=[math.degrees(v) for v in e]
        hand=B @ (arm.matrix_world @ arm.pose.bones['mixamorig:RightHand'].matrix).translation
        hips_position=B @ (arm.matrix_world @ arm.pose.bones['mixamorig:Hips'].matrix).translation
        frames.append({'time':i/fps,'angles':angles,'hand':list(hand),'hips':list(hips_position),'heading':math.degrees(heading)})
    result['clips'][name]={'sourceSha256':hashlib.sha256(path.read_bytes()).hexdigest(),
       'sourceBytes':path.stat().st_size,'frames':frames,'fps':fps,'duration':(end-start)/fps}
    print('RETARGET',name,'fps',fps,'frames',len(frames))
(OUT/'retargeted.json').write_text(json.dumps(result,separators=(',',':'))+'\n')
print('MIXAMO_RETARGETED',OUT/'retargeted.json')
