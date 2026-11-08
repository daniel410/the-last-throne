# Run via Blender MCP after repair-deepwood-caster-seams.py. Preserve other scenes.
import bpy,bmesh
BASE='/Users/daniel/Workspace/project/roblox/the-last-throne/assets/animations/deepwood-monsters-v3/mesh-repairs/'
previous=bpy.context.window.scene
for kind in ['Shaman','GoblinKing','KingOgre','KingShaman']:
 scene=bpy.data.scenes.new('TLT_Repaired_Source_'+kind);bpy.context.window.scene=scene
 # TLT concept-color contract: explicit settings for every authoring/review scene.
 scene.display_settings.display_device = 'sRGB'
 scene.view_settings.view_transform = 'Standard'
 scene.view_settings.look = 'None'
 scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
 scene.view_settings.use_curve_mapping = False
 bpy.ops.import_scene.gltf(filepath=BASE+kind+'-review.glb')
 for obj in list(scene.objects):
  if obj.type!='MESH':continue
  part=obj.name.split('.')[0].split('__')[-1];obj.name=kind+'__'+part;obj['StoryPart']=part
  bm=bmesh.new();bm.from_mesh(obj.data);bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
  boundaries=[e for e in bm.edges if e.is_boundary]
  if boundaries:bmesh.ops.holes_fill(bm,edges=boundaries,sides=0)
  bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bmesh.ops.triangulate(bm,faces=list(bm.faces));bm.to_mesh(obj.data);bm.free();obj.data.update()
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.export_scene.gltf(filepath=BASE+kind+'-review.glb',export_format='GLB',use_selection=True,use_active_scene=True)
 bpy.ops.object.select_all(action='DESELECT')
 for obj in scene.objects:
  if obj.type=='MESH'and obj['StoryPart']in ['Body','ArmR']:obj.select_set(True)
 bpy.ops.export_scene.gltf(filepath=BASE+kind+'-import.glb',export_format='GLB',use_selection=True,use_active_scene=True)
 print(kind,'closed; two changed meshes in import candidate')
bpy.context.window.scene=previous
