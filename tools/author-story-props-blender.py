# Run in Blender with STORY_GEOMETRY (dict) and STORY_OUTPUT (absolute path) provided.
# Separate scene for every asset; user scenes and source objects are preserved.
import bpy, math
from mathutils import Vector, Matrix, Euler
basis=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
materials={};scenes=[]
for key,spec in STORY_GEOMETRY['models'].items():
 scene=bpy.data.scenes.new('TLT_Story_'+key);bpy.context.window.scene=scene;scenes.append(scene)
 # TLT concept-color contract: explicit settings for every authoring/review scene.
 scene.display_settings.display_device = 'sRGB'
 scene.view_settings.view_transform = 'Standard'
 scene.view_settings.look = 'None'
 scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
 scene.view_settings.use_curve_mapping = False
 for s in spec['parts']:
  size=s['size'];at=Vector(s['position'])
  if s['shape']=='Cylinder':
   bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=1,depth=2)
   obj=bpy.context.object
   # Roblox Cylinder has its symmetry axis along local X.
   for v in obj.data.vertices:v.co=Vector((v.co.z*size[0]/2,v.co.x*size[1]/2,v.co.y*size[2]/2))
  elif s['shape']=='Wedge':
   verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
   mesh=bpy.data.meshes.new(s['name']);mesh.from_pydata([[v[i]*size[i] for i in range(3)]for v in verts],[],[(0,1,3,2),(2,3,5,4),(0,4,5,1),(0,2,4),(1,5,3)])
   obj=bpy.data.objects.new(s['name'],mesh);scene.collection.objects.link(obj)
  else:
   bpy.ops.mesh.primitive_cube_add(size=1);obj=bpy.context.object
   for v in obj.data.vertices:v.co=Vector([v.co[i]*size[i]for i in range(3)])
  obj.name=key+'__'+s['name']
  if 'look' in s:
   direction=Vector(s['look'])-at
   z=-direction.normalized();x=Vector((0,1,0)).cross(z).normalized();y=z.cross(x)
   rotation=Matrix(((x.x,y.x,z.x),(x.y,y.y,z.y),(x.z,y.z,z.z)))
  else:
   r=s['rotation'];rotation=Matrix.Rotation(r[0],3,'X')@Matrix.Rotation(r[1],3,'Y')@Matrix.Rotation(r[2],3,'Z')
  for v in obj.data.vertices:v.co=basis@(rotation@v.co+at)
  matkey=str(s['color'])+s['material']
  if matkey not in materials:
   mat=bpy.data.materials.new('Story_'+s['material']+'_'+str(len(materials)));mat.use_nodes=True
   node=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
   col=tuple((c/255)**2.2 for c in s['color'])+(1,);node.inputs['Base Color'].default_value=col;mat.diffuse_color=tuple(c/255 for c in s['color'])+(1,)
   node.inputs['Roughness'].default_value=.48 if s['material']=='Metal' else .8
   node.inputs['Metallic'].default_value=.65 if s['material']=='Metal' else 0
   materials[matkey]=mat
  obj.data.materials.append(materials[matkey])
  # No extra bevel: GLB mirrors the native runtime's exact geometry and silhouettes.
 bpy.ops.object.select_all(action='SELECT')
 bpy.ops.export_scene.gltf(filepath=STORY_OUTPUT+'/'+key+'.glb',export_format='GLB',use_selection=True,use_active_scene=True)
 print(key,len(scene.objects),'pieces exported')
# Contact-sheet scene contains copies, without changing the individual export pivots.
gallery=bpy.data.scenes.new('TLT_Story_Props_Gallery');bpy.context.window.scene=gallery
# TLT concept-color contract: explicit settings for every authoring/review scene.
gallery.display_settings.display_device = 'sRGB'
gallery.view_settings.view_transform = 'Standard'
gallery.view_settings.look = 'None'
gallery.view_settings.exposure = 0; gallery.view_settings.gamma = 1
gallery.view_settings.use_curve_mapping = False
for i,scene in enumerate(scenes):
 key=list(STORY_GEOMETRY['models'])[i];offset=Vector(((i%4)*18,-(i//4)*19,0))
 for original in scene.objects:
  obj=original.copy();obj.data=original.data;obj.location=offset;gallery.collection.objects.link(obj)
 text=bpy.data.curves.new('Label_'+key,'FONT');text.body=key;text.size=.75;text.align_x='CENTER'
 obj=bpy.data.objects.new('Label_'+key,text);gallery.collection.objects.link(obj);obj.location=offset+Vector((0,-7,.04))
 bpy.ops.mesh.primitive_plane_add(size=1,location=offset+Vector((0,0,-.09)))
 pl=bpy.context.object;pl.scale=(16,17,1)
 mat=bpy.data.materials.get('StoryGalleryBase') or bpy.data.materials.new('StoryGalleryBase');mat.diffuse_color=(.12,.15,.17,1);pl.data.materials.append(mat)
camdata=bpy.data.cameras.new('StoryGalleryCamera');cam=bpy.data.objects.new('StoryGalleryCamera',camdata);gallery.collection.objects.link(cam)
cam.location=(70,-100,95);target=Vector((27,-26,2));cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=120;gallery.camera=cam
try:gallery.render.engine='BLENDER_WORKBENCH'
except TypeError:gallery.render.engine='BLENDER_WORKBENCH_NEXT'
gallery.display.shading.light='STUDIO';gallery.display.shading.color_type='MATERIAL';gallery.display.shading.show_shadows=True;gallery.display.shading.show_cavity=True
gallery.render.resolution_x=1800;gallery.render.resolution_y=1500;gallery.render.resolution_percentage=100
points=[obj.matrix_world@Vector(c) for obj in gallery.objects if obj.type=='MESH' for c in obj.bound_box]
center=(Vector(tuple(min(p[i] for p in points)for i in range(3)))+Vector(tuple(max(p[i] for p in points)for i in range(3))))/2
cam.location=center+Vector((70,-95,110));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler()
inv=cam.rotation_euler.to_matrix().transposed();proj=[inv@(p-center)for p in points]
spanx=max(p.x for p in proj)-min(p.x for p in proj);spany=max(p.y for p in proj)-min(p.y for p in proj)
camdata.ortho_scale=max(spanx,spany*gallery.render.resolution_x/gallery.render.resolution_y)*1.12
gallery.render.filepath=STORY_OUTPUT+'/gallery.png';bpy.ops.render.render(write_still=True)
print('Story gallery rendered; individual user scenes preserved')
