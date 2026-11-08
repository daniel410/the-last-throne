"""Render native FK samples as explicitly labelled geometry proxies, Standard/sRGB."""
import bpy
import json
import math
import pathlib
from mathutils import Matrix, Vector

root=pathlib.Path(__file__).resolve().parents[1]
out=root/'docs/evidence/mixamo-dwarf-20261108'
data=json.loads((out/'native-poses.json').read_text())
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
s=bpy.context.scene
s.display_settings.display_device='sRGB';s.view_settings.view_transform='Standard'
s.view_settings.look='None';s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False
s.render.engine='CYCLES';s.cycles.samples=12
s.render.resolution_x=1200;s.render.resolution_y=330;s.render.resolution_percentage=100
s.world.color=(.32,.32,.32)
def material(name,color):
    m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
    p=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Roughness'].default_value=.65
    return m
body=material('Body proxy',(.08,.24,.30));skin=material('Head and hands',(.55,.34,.17))
steel=material('Axe geometry proxy',(.4,.48,.55));ground=material('Ground',(.11,.14,.17))
font=material('Labels',(.8,.87,.94))
C=Matrix(((1,0,0),(0,0,-1),(0,1,0))).to_4x4()
bpy.ops.object.light_add(type='AREA',location=(0,-8,15));bpy.context.object.data.energy=2300;bpy.context.object.data.shape='DISK';bpy.context.object.data.size=15
bpy.ops.object.camera_add(location=(8,-28,14));cam=bpy.context.object
cam.rotation_euler=(Vector((0,0,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=31;s.camera=cam
static=set(bpy.data.objects)
for key,rows in data['clips'].items():
    for o in list(bpy.data.objects):
        if o not in static:bpy.data.objects.remove(o,do_unlink=True)
    for col,index in enumerate([0,6,12,17,24]):
        row=rows[index];offset=Vector(((col-2)*6,0,0))
        for name,p in row['parts'].items():
            f=p['cf'];m=Matrix((f[3:6],f[6:9],f[9:12])).to_4x4();m.translation=Vector(f[:3]);m=C @ m @ C.inverted();m.translation+=offset
            bpy.ops.mesh.primitive_cube_add();obj=bpy.context.object;obj.name=name
            obj.matrix_world=m;obj.scale=Vector((p['size'][0],p['size'][2],p['size'][1]))/2
            obj.data.materials.append(steel if name=='Weapon' else skin if name in ['Head','LeftHand','RightHand']else body)
        bpy.ops.mesh.primitive_plane_add(size=5,location=offset+Vector((0,0,-3.2)));bpy.context.object.data.materials.append(ground)
        bpy.ops.object.text_add(location=offset+Vector((-1.6,-1.4,-3.18)),rotation=(0,0,0))
        text=bpy.context.object;text.data.body=f"{row['age']:.2f}s";text.data.size=.6;text.data.materials.append(font)
    # Contract is reapplied immediately before every render.
    s.view_settings.view_transform='Standard'
    s.render.filepath=str(out/(key.replace('.','-')+'.png'))
    bpy.ops.render.render(write_still=True)
print('RENDERED_MIXAMO_NATIVE_PROXIES',len(data['clips']))
