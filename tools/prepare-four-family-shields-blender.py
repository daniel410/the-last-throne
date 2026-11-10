"""Prepare exact Meshy shields in a separate background Blender; preserve source GLBs."""
from pathlib import Path
import bpy,json,math,hashlib
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT/'assets/models/four-family-shields-meshy-v1'
m=json.loads((BASE/'manifest.json').read_text());report=[]
bpy.ops.wm.read_factory_settings(use_empty=True)
def standard(s):
 s.display_settings.display_device='sRGB';s.view_settings.view_transform='Standard';s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False
for r in m['records']:
 s=bpy.data.scenes.new(r['id']);bpy.context.window.scene=s;standard(s)
 bpy.ops.import_scene.gltf(filepath=str(BASE/r['source']))
 meshes=[o for o in s.objects if o.type=='MESH'];assert len(meshes)==1
 obj=meshes[0];obj.name=r['id'];bpy.context.view_layer.update()
 points=[obj.matrix_world@v.co for v in obj.data.vertices];lo=Vector([min(p[i]for p in points)for i in range(3)]);hi=Vector([max(p[i]for p in points)for i in range(3)])
 scale=1.88/(hi.z-lo.z);center=(lo+hi)/2
 # Source front is glTF +Z (Blender -Y). Rotate to runtime -Z (Blender +Y).
 rotation=Matrix.Rotation(math.pi,3,'Z');points=[rotation@(p-center)*scale for p in points]
 lo=Vector([min(p[i]for p in points)for i in range(3)]);hi=Vector([max(p[i]for p in points)for i in range(3)])
 socket=Vector((0,lo.y,0));points=[p-socket for p in points]
 for v,p in zip(obj.data.vertices,points):v.co=p
 obj.matrix_world=Matrix.Identity(4)
 for mat in obj.data.materials:
  for n in mat.node_tree.nodes if mat and mat.use_nodes else []:
   if n.type=='TEX_IMAGE'and n.image:assert n.image.colorspace_settings.name in('sRGB','Non-Color','Linear Rec.709')
 bpy.context.view_layer.update();standard(s)
 bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
 r['prepared']='prepared/'+r['id']+'.glb';bpy.ops.export_scene.gltf(filepath=str(BASE/r['prepared']),export_format='GLB',use_selection=True,use_active_scene=True,export_animations=False,export_yup=True)
 r['preparedSha256']=hashlib.sha256((BASE/r['prepared']).read_bytes()).hexdigest()
 native=[Vector((p.x,p.z,-p.y))for p in points];lo=Vector([min(p[i]for p in native)for i in range(3)]);hi=Vector([max(p[i]for p in native)for i in range(3)])
 samples=[list(native[i])for i in range(0,len(native),max(1,len(native)//48))][:48]
 info=dict(id=r['id'],definitionId=r['definitionId'],meshyTaskId=r['meshyTaskId'],prepared=r['prepared'],size=list(hi-lo),center=list((lo+hi)/2),samples=samples,sourceToStudScale=scale,grip=[0,0,0],front=[0,0,-1],viewTransform='Standard',display='sRGB',look='None',exposure=0,gamma=1,useCurves=False)
 report.append(info)
 world=bpy.data.worlds.new('Neutral');world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(.22,.22,.22,1);world.node_tree.nodes['Background'].inputs[1].default_value=.65;s.world=world
 camera=bpy.data.objects.new('FrontCamera',bpy.data.cameras.new('FrontCamera'));s.collection.objects.link(camera);camera.location=(0,8,0);camera.rotation_euler=(-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=2.35;s.camera=camera
 for name,pos,energy in [('Key',( -3,4,4),350),('Fill',(3,3,1),150)]:
  l=bpy.data.objects.new(name,bpy.data.lights.new(name,'AREA'));s.collection.objects.link(l);l.location=pos;l.rotation_euler=(-l.location).to_track_quat('-Z','Y').to_euler();l.data.energy=energy;l.data.size=4
 s.render.engine='CYCLES';s.cycles.samples=16;s.cycles.use_denoising=True;s.render.film_transparent=True;s.render.resolution_x=768;s.render.resolution_y=768;s.render.resolution_percentage=100;s.render.image_settings.file_format='PNG';s.render.image_settings.color_mode='RGBA'
 (BASE/'renders').mkdir(exist_ok=True);s.render.filepath=str(BASE/'renders'/f'{r["id"]}.png');standard(s);bpy.ops.render.render(write_still=True)
 print('PREPARED_SHIELD',r['id'],flush=True)
(BASE/'geometry-report.json').write_text(json.dumps(report,indent=2)+'\n');(BASE/'manifest.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n');bpy.ops.wm.save_as_mainfile(filepath=str(BASE/'four-family-shields-review.blend'),compress=True)
