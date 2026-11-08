"""Run through Blender MCP. Preserve the user's scenes; write only repair scene."""
import bpy,bmesh,math,json
from mathutils import Vector,Matrix
BASE='/Users/daniel/Workspace/project/roblox/the-last-throne/'
scene=bpy.data.scenes.get('TLT_Deepwood_Weapon_Repair_Final')
if scene is None:scene=bpy.data.scenes.new('TLT_Deepwood_Weapon_Repair_Final')
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
for old in list(scene.objects):bpy.data.objects.remove(old,do_unlink=True)
bpy.context.window.scene=scene
records={}
for kind in ['ogre','warlord']:
 before=set(scene.objects)
 bpy.ops.import_scene.gltf(filepath=BASE+'assets/shared/deepwood-weapon-repair/'+kind+'-prepared.glb')
 objects=list(set(scene.objects)-before)
 for o in objects:
  o.name=kind+'__'+o.name.split('.')[0]
  bm=bmesh.new();bm.from_mesh(o.data)
  bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000002)
  # Close only newly exposed boundaries, preserving source UV loop layers.
  edges=[e for e in bm.edges if e.is_boundary]
  if edges:bmesh.ops.holes_fill(bm,edges=edges,sides=0)
  bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(o.data);bm.free();o.data.update()
 if kind=='ogre':
  weapon=next(o for o in objects if o.name.endswith('__Weapon'))
  # Complete the wood shaft through the closed fist; both visible ends are
  # the original source. The shaft intersects each end inside the grip.
  a=Vector((.455,-.165,.365));b=Vector((.405,-.165,.62));v=b-a
  bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=.026,depth=v.length,location=(a+b)*.5)
  shaft=bpy.context.object;shaft.rotation_euler=v.to_track_quat('Z','Y').to_euler();shaft.data.materials.append(weapon.data.materials[0])
  # Reuse a wood texel from the source head near its lower edge.
  uv=weapon.data.uv_layers.active
  def height(p):return (weapon.matrix_world@p.center).z
  polys=sorted(weapon.data.polygons,key=height)
  wood=tuple(uv.data[polys[min(8,len(polys)-1)].loop_start].uv)
  for q in shaft.data.uv_layers.active.data:q.uv=wood
  bpy.ops.object.select_all(action='DESELECT');weapon.select_set(True);shaft.select_set(True);bpy.context.view_layer.objects.active=weapon;bpy.ops.object.join()
 for o in objects:
  if o.name not in scene.objects:continue
  bm=bmesh.new();bm.from_mesh(o.data)
  bmesh.ops.triangulate(bm,faces=list(bm.faces))
  flat=[f for f in bm.faces if f.calc_area()<1e-9]
  if flat:bmesh.ops.delete(bm,geom=flat,context='FACES_ONLY')
  bm.to_mesh(o.data);bm.free();o.data.update();o.data.name=o.name
  # Mesh tessellation refresh can reveal collinear triangles hidden by a
  # cached pre-triangulation face normal; remove them after that refresh.
  bad=[p.index for p in o.data.polygons if p.area<1e-10]
  if bad:
   bm=bmesh.new();bm.from_mesh(o.data);bm.faces.ensure_lookup_table()
   bmesh.ops.delete(bm,geom=[bm.faces[i]for i in bad],context='FACES_ONLY')
   bm.to_mesh(o.data);bm.free();o.data.update()
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:
  if o.name in scene.objects:o.select_set(True)
 bpy.ops.export_scene.gltf(filepath=BASE+'assets/shared/deepwood-weapon-repair/'+kind+'-repaired.glb',use_selection=True,use_active_scene=True,export_format='GLB')
 records[kind]=[{'name':o.name,'vertices':len(o.data.vertices),'faces':len(o.data.polygons)}for o in objects if o.name in scene.objects]
# Review animation: source templates +Z becomes runtime -Z by 180 degree yaw.
for kind,arm,px in [('ogre','ArmR',.39),('warlord','ArmL',-.4)]:
 root=bpy.data.objects.new(kind+'_ReviewRoot',None);scene.collection.objects.link(root)
 pivot=bpy.data.objects.new(kind+'_WeaponShoulder',None);scene.collection.objects.link(pivot);pivot.parent=root;pivot.location=(px,0,.68 if kind=='ogre'else .7)
 bpy.context.view_layer.update()
 for o in [o for o in scene.objects if o.name.startswith(kind+'__')]:
  world=o.matrix_world.copy();o.parent=pivot if o.name.endswith('__'+arm)or o.name.endswith('__Weapon')else root;o.matrix_world=world
 pivot.rotation_mode='XYZ'
 for frame,angle in [(1,0),(20,-95),(36,60),(48,85),(72,0)]:
  pivot.rotation_euler=(math.radians(angle),0,0);pivot.keyframe_insert(data_path='rotation_euler',frame=frame)
 root.location.x=-.9 if kind=='ogre'else .9
scene.frame_start=1;scene.frame_end=72;scene.frame_set(36)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=BASE+'assets/shared/deepwood-weapon-repair/weapon-repair-review.glb',use_selection=True,use_active_scene=True,export_format='GLB')
print(json.dumps(records))
