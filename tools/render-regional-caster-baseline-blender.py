"""SNAPSHOT, SOURCE and REVIEW_OUT are supplied by the caller from saved 0.62.7 capture."""
import bpy,math
from mathutils import Vector,Matrix
previous_name=bpy.context.window.scene.name
kind=SNAPSHOT['kind'];scene=bpy.data.scenes.new('TLT_MR01_Baseline_'+kind);bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
try:
 bpy.ops.import_scene.gltf(filepath=SOURCE)
 B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
 def cf(v):
  r=Matrix((v[3:6],v[6:9],v[9:12]));m=(B@r@B.transposed()).to_4x4();m.translation=B@Vector(v[:3]);return m
 floor=min(p['rest'][1]-p['size'][1]/2 for p in SNAPSHOT['parts'].values());height=SNAPSHOT['height'];objects={}
 for obj in scene.objects:
  if obj.type!='MESH':continue
  name=obj.name.split('.')[0].split('__')[-1];spec=SNAPSHOT['parts'][name]
  points=[obj.matrix_world@v.co for v in obj.data.vertices];lo=Vector([min(v[i]for v in points)for i in range(3)]);hi=Vector([max(v[i]for v in points)for i in range(3)]);center=(lo+hi)/2;size=hi-lo;native=spec['size']
  for v,p in zip(obj.data.vertices,points):
   d=p-center;v.co=Vector((-d.x/size.x*native[0],-d.y/size.y*native[2],d.z/size.z*native[1]))
  obj.parent=None;obj.matrix_world=Matrix.Identity(4);objects[name]=obj
 camera=bpy.data.cameras.new(kind+'BaselineCamera');cam=bpy.data.objects.new(kind+'BaselineCamera',camera);scene.collection.objects.link(cam);scene.camera=cam;camera.type='ORTHO';camera.ortho_scale=height*1.55
 scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='TEXTURE';scene.display.shading.show_shadows=True
 scene.world=bpy.data.worlds.new(kind+'BaselineWorld');scene.world.color=(.12,.14,.18);scene.display.shading.background_type='WORLD'
 scene.render.resolution_x=440;scene.render.resolution_y=480;scene.render.resolution_percentage=100
 for clip in ['Attack','AttackAlt','Heavy','HeavyAlt']:
  for phase in [.4,.62,.78]:
   frame=next(f for f in SNAPSHOT['clips'][clip]if abs(f['phase']-phase)<.001)
   for name,obj in objects.items():
    pose=frame['parts'][name];native=SNAPSHOT['parts'][name]['size'];m=cf(pose['cf']);m.translation.z-=floor;obj.matrix_world=Matrix.Rotation(math.pi,4,'Z')@m
    obj.scale=Vector((pose['size'][0]/native[0],pose['size'][2]/native[2],pose['size'][1]/native[1]))
   for view,location in [('front',(0,-2.5,.67)),('side',(2.5,-.25,.67))]:
    target=Vector((0,0,height*.5));cam.location=Vector(location)*height;cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=REVIEW_OUT+'/'+kind+'-baseline-'+clip+'-'+str(phase)+'-'+view+'.png';bpy.ops.render.render(write_still=True)
finally:
 bpy.context.window.scene=bpy.data.scenes.get(previous_name)or bpy.data.scenes[0]
print('MR01_BASELINE',kind,'24 native-capture pose renders')
