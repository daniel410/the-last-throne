"""Render existing starter weapon source meshes; no model/material edits or uploads."""
import bpy,json
from pathlib import Path
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/evidence/training-delete-common-20261109'
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'assets/reviews/standard-color-v1/assets/shared/td-refined-player-weapons/refined-weapon-review.blend'))
rows=[]
for key,scene_name,prefixes in [
 ('knight','TLT_Refined_Weapon_Source_Review',('Refined_knight_',)),
 ('dwarf','TLT_Refined_Weapon_Source_Review',('Refined_dwarf_',)),
 ('elf','TLT_Elf_Bow_Authoring',('ElfSource_Bow','UpperString','LowerString')),
 ('mage','TLT_Mage_Staff_Authoring',('MageStaff_',))]:
 source=bpy.data.scenes[scene_name];bpy.context.window.scene=source;source.frame_set(1);bpy.context.view_layer.update()
 dg=bpy.context.evaluated_depsgraph_get()
 scene=bpy.data.scenes.new('CommonReview_'+key);copies=[]
 for original in source.objects:
  if original.type!='MESH' or not original.name.startswith(prefixes):continue
  obj=bpy.data.objects.new(original.name+'_review',bpy.data.meshes.new_from_object(original.evaluated_get(dg)))
  scene.collection.objects.link(obj);obj.matrix_world=original.matrix_world.copy();copies.append(obj)
 bpy.context.window.scene=scene;bpy.context.view_layer.update()
 points=[o.matrix_world@Vector(c) for o in copies for c in o.bound_box]
 low=Vector([min(p[i] for p in points) for i in range(3)]);high=Vector([max(p[i] for p in points) for i in range(3)])
 size=high-low;center=(low+high)/2
 major=max(range(3),key=lambda i:size[i]);thin=min(range(3),key=lambda i:size[i]);wide=next(i for i in range(3) if i not in (major,thin))
 # Rigid presentation orientation only. Local source geometry/colors remain unchanged.
 basis=Matrix([[int(j==wide) for j in range(3)],[int(j==thin) for j in range(3)],[int(j==major) for j in range(3)]])
 if basis.determinant()<0: basis[1]=-basis[1]
 for o in copies:o.matrix_world=basis.to_4x4()@Matrix.Translation(-center)@o.matrix_world
 height=size[major];width=size[wide];radius=max(height*.68,width*.95)
 world=bpy.data.worlds.new('Neutral_'+key);world.use_nodes=True;world.node_tree.nodes.get('Background').inputs[0].default_value=(.14,.16,.19,1);world.node_tree.nodes.get('Background').inputs[1].default_value=.7;scene.world=world
 camera=bpy.data.objects.new('ReviewCamera',bpy.data.cameras.new('ReviewCamera'));scene.collection.objects.link(camera)
 camera.location=(0,-height*3,0);camera.rotation_euler=(Vector((0,0,0))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.type='ORTHO';camera.data.ortho_scale=radius*2;scene.camera=camera
 for name,pos,energy in [('Key',(-height,-height*2,height*2),height*height*80),('Fill',(height,-height,height*.3),height*height*35)]:
  lamp=bpy.data.objects.new(name,bpy.data.lights.new(name,'AREA'));scene.collection.objects.link(lamp);lamp.location=pos;lamp.rotation_euler=(-lamp.location).to_track_quat('-Z','Y').to_euler();lamp.data.energy=energy;lamp.data.shape='DISK';lamp.data.size=height*2
 scene.render.engine='CYCLES';scene.cycles.samples=16;scene.render.resolution_x=500;scene.render.resolution_y=700;scene.render.resolution_percentage=100
 scene.display_settings.display_device='sRGB';scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.view_settings.use_curve_mapping=False
 scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/(key+'.png'));bpy.ops.render.render(write_still=True)
 rows.append(dict(classId=key,sourceScene=scene_name,objects=[o.name for o in copies],sourceBounds=list(size),display='sRGB',viewTransform='Standard',look='None',exposure=0,gamma=1,useCurves=False))
(OUT/'render-settings.json').write_text(json.dumps(rows,indent=2)+'\n')
