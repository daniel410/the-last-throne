# Inputs: REVIEW dict for one native-captured monster, SOURCE absolute GLB, REVIEW_STAGE and REVIEW_OUT.
# Uses actual native rig matrices and current per-model hand/weapon overrides.
import bpy, math
from mathutils import Vector,Matrix
previous_scene=bpy.context.window.scene
kind=REVIEW['kind'];stage=REVIEW_STAGE
clip_order=['Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned']
scene=bpy.data.scenes.new('TLT_Individual_'+kind+'_'+stage);bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
bpy.ops.import_scene.gltf(filepath=SOURCE)
meshes=[o for o in scene.objects if o.type=='MESH'];parts={}
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def cf(v):
 r=Matrix((v[3:6],v[6:9],v[9:12]));m=(B@r@B.transposed()).to_4x4();m.translation=B@Vector(v[:3]);return m
floor=min(p['rest'][1]-p['size'][1]/2 for p in REVIEW['parts'].values())
for obj in meshes:
 name=obj.name.split('.')[0].split('__')[-1]
 if name not in REVIEW['parts']:continue
 spec=REVIEW['parts'][name];points=[obj.matrix_world@v.co for v in obj.data.vertices]
 lo=Vector([min(v[i]for v in points)for i in range(3)]);hi=Vector([max(v[i]for v in points)for i in range(3)]);center=(lo+hi)/2;size=hi-lo
 native=spec['size']
 for v,p in zip(obj.data.vertices,points):
  d=p-center;v.co=Vector((-d.x/size.x*native[0],-d.y/size.y*native[2],d.z/size.z*native[1]))
 obj.parent=None;obj.rotation_mode='XYZ';obj.matrix_world=Matrix.Identity(4);parts[name]=obj
 obj.name=kind+'_'+stage+'_'+name
 obj['NativePart']=name
 for mat in obj.data.materials:
  if mat and mat.use_nodes:
   textures=[n for n in mat.node_tree.nodes if n.type=='TEX_IMAGE']
   if textures:mat.node_tree.nodes.active=textures[0]
 # Full seven-clip key-pose reel, with 120 frames per clip and a 20-frame gap.
 for index,clip in enumerate(clip_order):
  frames=REVIEW['clips'][clip]
  for f in frames:
   pose=f['parts'][name];m=cf(pose['cf']);m.translation.z-=floor
   obj.matrix_world=m;obj.scale=Vector((pose['size'][0]/native[0],pose['size'][2]/native[2],pose['size'][1]/native[1]))
   frame=index*140+f['phase']*120
   obj.keyframe_insert(data_path='location',frame=frame);obj.keyframe_insert(data_path='rotation_euler',frame=frame);obj.keyframe_insert(data_path='scale',frame=frame)
scene.frame_start=0;scene.frame_end=960;scene.render.fps=60
camera=bpy.data.cameras.new(kind+'ReviewCamera');cam=bpy.data.objects.new(kind+'ReviewCamera',camera);scene.collection.objects.link(cam);scene.camera=cam
height=REVIEW['height'];target=Vector((0,0,height*.46));cam.location=target+Vector((height*.95,height*1.8,height*.65));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();camera.type='ORTHO';camera.ortho_scale=max(height*1.75,max(max(p['size'][0],p['size'][2])for p in REVIEW['parts'].values())*1.5)
scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='TEXTURE';scene.display.shading.show_cavity=True;scene.display.shading.show_shadows=True
scene.display.shading.background_type='WORLD';scene.world=bpy.data.worlds.new(kind+'ReviewWorld');scene.world.color=(.16,.19,.22)
scene.render.resolution_x=500;scene.render.resolution_y=500;scene.render.resolution_percentage=100
for clip,phase in [('Walk',0),('Walk',.25),('Walk',.5),('Walk',.75),('Attack',.4),('Attack',.62),('Attack',.78)]:
 index=clip_order.index(clip);frame=index*140+phase*120;scene.frame_set(int(frame),subframe=frame-int(frame))
 scene.render.filepath=REVIEW_OUT+'/'+stage+'-'+clip+'-'+str(phase)+'.png';bpy.ops.render.render(write_still=True)
scene['NativeCaptureStage']=stage;scene['NativeKind']=kind
scene.frame_set(354,subframe=.4)
bpy.context.window.scene=previous_scene
print(kind,stage,'7 key-pose renders; native override',len(parts),'mesh parts')
