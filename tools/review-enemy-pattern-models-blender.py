"""Run via Blender MCP. Reconstructs exact native prototype geometry, preserves the user's scene."""
from pathlib import Path
import bpy,json,math
from mathutils import Matrix,Vector
ROOT=Path('/Users/daniel/Workspace/project/roblox/the-last-throne')
data=json.loads((ROOT/'assets/animations/enemy-patterns-v1/native-model-capture.json').read_text())
previous=bpy.context.window.scene
scene=bpy.data.scenes.new('TLT_EnemyPattern_Models_v1');bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
B=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def frame(values):
 r=Matrix((values[3:6],values[6:9],values[9:12]));m=(B@r@B.transposed()).to_4x4();m.translation=B@Vector(values[:3]);return m
materials={}
def material(color):
 key=tuple(round(c,3)for c in color)
 if key not in materials:
  mat=bpy.data.materials.new('TLT_Native_'+str(len(materials)));mat.diffuse_color=(*key,1);mat.use_nodes=True
  shader=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');shader.inputs['Base Color'].default_value=(*key,1);shader.inputs['Roughness'].default_value=.65
  materials[key]=mat
 return materials[key]
# Select four contrasting prototype silhouettes for a readable before/after board.
kinds=['Silkweaver','Gloambat','VenomcoilKing','AncientHollowbark']
for col,kind in enumerate(kinds):
 for row,stage in enumerate(['before','after']):
  model=next(m for m in data['models']if m['kind']==kind and m['stage']==stage)
  scale=5/model['height'];base=Vector((col*9,0,-row*9))
  for part in model['parts']:
   if part['class']=='MeshPart':continue
   shape=part.get('shape');cls=part['class']
   if shape=='Ball':bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=6,radius=.5)
   elif shape=='Cylinder':
    bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=.5,depth=1);obj=bpy.context.object
    # Native cylinder axis is X; after the Roblox-to-Blender basis, mesh local X remains X.
    rotation=Matrix.Rotation(math.pi/2,4,'Y');obj.data.transform(rotation)
   elif cls=='WedgePart':
    mesh=bpy.data.meshes.new('NativeWedge');mesh.from_pydata([(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,.5,-.5),(.5,.5,-.5),(-.5,.5,.5),(.5,.5,.5)],[],[(0,1,3,2),(2,3,5,4),(0,2,4),(1,5,3),(0,4,5,1)]);mesh.update();o=bpy.data.objects.new('NativeWedge',mesh);scene.collection.objects.link(o);bpy.context.view_layer.objects.active=o
   else:bpy.ops.mesh.primitive_cube_add(size=1)
   obj=bpy.context.object;obj.name=kind+'_'+stage+'_'+part['name']
   native=frame(part['cf']);native.translation.z+=3
   native.translation*=scale;native.translation+=base
   obj.matrix_world=native;obj.scale=Vector((part['size'][0],part['size'][2],part['size'][1]))*scale
   obj.data.materials.append(material(part['color']));obj['NativeKind']=kind;obj['NativeStage']=stage;obj['NativePart']=part['name']
  text=bpy.data.curves.new(kind+'_'+stage,'FONT');text.body=kind+' | '+stage.upper();text.size=.45;text.align_x='CENTER'
  label=bpy.data.objects.new(kind+'_'+stage+'_Label',text);scene.collection.objects.link(label);label.location=base+Vector((0,1.5,-.9));label.rotation_euler=(math.pi/2,0,math.pi);label.data.materials.append(material((.9,.9,.85)))
camera=bpy.data.cameras.new('TLT_Enemy_Comparison');cam=bpy.data.objects.new('TLT_Enemy_Comparison',camera);scene.collection.objects.link(cam);scene.camera=cam
center=Vector((13.5,0,-1.5));cam.location=center+Vector((3,58,18));cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();camera.type='ORTHO';camera.ortho_scale=37
scene.render.engine='BLENDER_WORKBENCH';scene.display.shading.light='STUDIO';scene.display.shading.color_type='MATERIAL';scene.display.shading.show_shadows=True;scene.display.shading.show_cavity=True
scene.world=bpy.data.worlds.new('TLT_Enemy_ReviewWorld');scene.world.color=(.045,.058,.075);scene.display.shading.background_type='WORLD'
scene.render.resolution_x=1600;scene.render.resolution_y=940;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'docs/evidence/enemy-patterns-20261106/model-before-after.png')
bpy.ops.render.render(write_still=True)
scene['Source']='Exact Roblox native Part/Shape/Size/CFrame/Color capture; four of eight improved prototype species. Not final mesh acceptance.'
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/animations/enemy-patterns-v1/model-comparison.glb'),export_format='GLB',use_active_scene=True)
bpy.context.window.scene=previous
print('Saved isolated derived scene and native geometry comparison; preserved active user scene:',previous.name)
