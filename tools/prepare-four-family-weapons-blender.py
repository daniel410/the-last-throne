"""Run in a separate background Blender. Preserve Meshy originals and render actual-model icons."""
from pathlib import Path
import bpy
import json
import math
from mathutils import Vector, Matrix

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/four-family-weapons-meshy-v1'
ICONS=ROOT/'assets/ui/four-family-weapon-icons-v1'
manifest=json.loads((BASE/'manifest.json').read_text())
report=[]
bpy.ops.wm.read_factory_settings(use_empty=True)

def standard(scene):
 scene.display_settings.display_device='sRGB'
 scene.view_settings.view_transform='Standard'
 scene.view_settings.look='None'
 scene.view_settings.exposure=0
 scene.view_settings.gamma=1
 scene.view_settings.use_curve_mapping=False

for row in manifest['records']:
 scene=bpy.data.scenes.new(row['id']);bpy.context.window.scene=scene;standard(scene)
 bpy.ops.import_scene.gltf(filepath=str(BASE/row['source']))
 meshes=[o for o in scene.objects if o.type=='MESH']
 assert len(meshes)==1,(row['id'],len(meshes))
 obj=meshes[0];obj.name=row['id']
 bpy.context.view_layer.update()
 for v in obj.data.vertices:v.co=obj.matrix_world@v.co
 obj.matrix_world=Matrix.Identity(4)
 points=[v.co.copy() for v in obj.data.vertices]
 low=Vector([min(v[i] for v in points) for i in range(3)]);high=Vector([max(v[i] for v in points) for i in range(3)])
 extent=high-low;assert extent.z>max(extent.x,extent.y)*1.8
 center=(low+high)/2
 # Source swords point down; flip rigidly so the runtime blade points +Y.
 flip=Matrix.Rotation(math.pi,3,'Y') if row['category']=='sword' else Matrix.Identity(3)
 height={'sword':3.45,'axe':3.2,'bow':3.625,'staff':4.0}[row['category']]
 scale=height/extent.z
 transformed=[flip@(p-center)*scale for p in points]
 lo=Vector([min(p[i] for p in transformed) for i in range(3)]);hi=Vector([max(p[i] for p in transformed) for i in range(3)])
 # Use the shaft center in the grip band rather than the offset head's bounds.
 gripFraction={'sword':.13,'axe':.23,'bow':.50,'staff':.42}[row['category']]
 gripZ=lo.z+height*gripFraction
 band=[p for p in transformed if abs(p.z-gripZ)<height*.025]
 for edge in obj.data.edges:
  a,b=[transformed[i] for i in edge.vertices]
  if (a.z-gripZ)*(b.z-gripZ)<0:
   band.append(a+(b-a)*((gripZ-a.z)/(b.z-a.z)))
 assert band
 if row['category']=='bow':
  cutoff=(min(p.x for p in band)+max(p.x for p in band))/2
  band=[p for p in band if p.x<cutoff] # Hold the bow riser, not the midpoint of riser and string.
 grip=Vector(((min(p.x for p in band)+max(p.x for p in band))/2,(min(p.y for p in band)+max(p.y for p in band))/2,gripZ))
 # Match current combat frame: bow lies in Y/Z, front is -Z for sword/staff.
 yaw={'sword':math.pi,'axe':-3*math.pi/4,'bow':-math.pi/2,'staff':math.pi}[row['category']]
 rotation=Matrix.Rotation(yaw,3,'Z')
 for v,p in zip(obj.data.vertices,transformed):v.co=rotation@(p-grip)
 obj.data.update()
 for mat in obj.data.materials:
  if mat and mat.use_nodes:
   for node in mat.node_tree.nodes:
    if node.type=='TEX_IMAGE' and node.image:
     # glTF importer assigns sRGB to base color and Non-Color to data maps.
     assert node.image.colorspace_settings.name in ('sRGB','Non-Color','Linear Rec.709')
 bpy.context.view_layer.update()
 points=[v.co.copy() for v in obj.data.vertices]
 lo=Vector([min(p[i] for p in points) for i in range(3)]);hi=Vector([max(p[i] for p in points) for i in range(3)])
 top=max(points,key=lambda p:p.z)
 row['prepared']='prepared/'+row['id']+'.glb'
 bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
 standard(scene)
 bpy.ops.export_scene.gltf(filepath=str(BASE/row['prepared']),export_format='GLB',use_selection=True,use_active_scene=True,export_animations=False,export_yup=True)
 info=dict(id=row['id'],definitionId=row['definitionId'],classId=row['classId'],category=row['category'],prepared=row['prepared'],targetHeight=height,grip=[0,0,0],boundsBlender=[list(lo),list(hi)],boundsRoblox=[[lo.x,lo.z,-hi.y],[hi.x,hi.z,-lo.y]],tipRoblox=[top.x,top.z,-top.y],triangles=sum(len(p.vertices)-2 for p in obj.data.polygons),vertices=len(obj.data.vertices),sourceToStudScale=scale,sourceGripBandFraction=gripFraction,viewTransform='Standard',display='sRGB',look='None',exposure=0,gamma=1,useCurves=False)
 # Render the real surface from the source-facing side. No generative redraw.
 obj.matrix_world=rotation.inverted().to_4x4()
 if row['category']=='sword':obj.matrix_world=Matrix.Rotation(math.pi,4,'Z')@obj.matrix_world
 renderPoints=[obj.matrix_world@v.co for v in obj.data.vertices]
 center=Vector([(min(p[i] for p in renderPoints)+max(p[i] for p in renderPoints))/2 for i in range(3)])
 obj.matrix_world=Matrix.Translation(-center)@obj.matrix_world
 # A small in-plane tilt uses more square-icon area while retaining full length.
 obj.matrix_world=Matrix.Rotation(math.radians(-25),4,'Y')@obj.matrix_world
 pts=[obj.matrix_world@v.co for v in obj.data.vertices]
 radius=max(max(p.x for p in pts)-min(p.x for p in pts),max(p.z for p in pts)-min(p.z for p in pts))/.76
 world=bpy.data.worlds.new('Neutral_'+row['id']);world.use_nodes=True
 world.node_tree.nodes['Background'].inputs[0].default_value=(.22,.22,.22,1)
 world.node_tree.nodes['Background'].inputs[1].default_value=.65;scene.world=world
 camera=bpy.data.objects.new('IconCamera',bpy.data.cameras.new('IconCamera'));scene.collection.objects.link(camera)
 camera.location=(0,-height*4,0);camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=radius;scene.camera=camera
 for name,pos,energy in [('Key',(-height,-height*2,height*2),height*height*45),('Fill',(height,-height,height*.3),height*height*20)]:
  light=bpy.data.objects.new(name,bpy.data.lights.new(name,'AREA'));scene.collection.objects.link(light);light.location=pos;light.rotation_euler=(-light.location).to_track_quat('-Z','Y').to_euler();light.data.energy=energy;light.data.size=height*2
 scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
 scene.render.film_transparent=True;scene.render.resolution_percentage=100
 scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
 for size,folder in [(1024,'icons'),(64,'64'),(48,'48')]:
  (ICONS/folder).mkdir(parents=True,exist_ok=True)
  scene.render.resolution_x=size;scene.render.resolution_y=size
  scene.render.filepath=str(ICONS/folder/(row['id']+'.png'));standard(scene);bpy.ops.render.render(write_still=True)
 info['icon']='icons/'+row['id']+'.png';report.append(info)
 (BASE/'geometry-report.json').write_text(json.dumps(report,indent=2)+'\n')
 print('PREPARED_WEAPON',row['id'],flush=True)
bpy.ops.wm.save_as_mainfile(filepath=str(BASE/'four-family-weapons-review.blend'),compress=True)
(BASE/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print('COMPLETE: 16 exact-source prepared models / 16 icon masters / 32 small previews',flush=True)
