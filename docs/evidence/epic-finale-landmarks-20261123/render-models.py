"""Render the exported Roblox part transforms in Blender for a close geometry review."""
from math import cos, sin, tau
import json
from pathlib import Path
import sys

import bpy
from mathutils import Matrix, Vector

source, output = map(Path, sys.argv[sys.argv.index('--') + 1:])
data = json.loads(source.read_text())
output.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 8
scene.cycles.use_denoising = True
scene.render.resolution_x = 460
scene.render.resolution_y = 235
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0
scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
scene.display_settings.display_device = 'sRGB'
scene.world.use_nodes = True
scene.world.node_tree.nodes['Background'].inputs['Color'].default_value = (.24, .28, .35, 1)
scene.world.node_tree.nodes['Background'].inputs['Strength'].default_value = .42
scene.render.image_settings.file_format = 'PNG'

def aim(obj, point):
    obj.rotation_euler = (Vector(point) - obj.location).to_track_quat('-Z', 'Y').to_euler()

def light(name, point, power, size):
    lamp = bpy.data.lights.new(name, 'AREA')
    lamp.energy, lamp.shape, lamp.size = power, 'DISK', size
    obj = bpy.data.objects.new(name, lamp)
    scene.collection.objects.link(obj)
    obj.location = point
    aim(obj, (0, 0, 0))

def linear(value):
    return value / 12.92 if value <= .04045 else ((value + .055) / 1.055) ** 2.4

def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    shader = mat.node_tree.nodes['Principled BSDF']
    shader.inputs['Base Color'].default_value = (*map(linear, color), 1)
    shader.inputs['Roughness'].default_value = .8
    shader.inputs['Metallic'].default_value = .3 if name in {'Metal', 'CorrodedMetal'} else 0
    return mat

def part(row):
    x, y, z = [value / 2 for value in row['size']]
    if row['shape'] == 'Cylinder':
        ring = [(y*cos(tau*n/32), z*sin(tau*n/32)) for n in range(32)]
        vertices = [(end, a, b) for end in (-x, x) for a, b in ring]
        faces = [(n,(n+1)%32,(n+1)%32+32,n+32) for n in range(32)]
        faces += [tuple(reversed(range(32))), tuple(range(32,64))]
    else:
        vertices = [(-x,-y,-z),(x,-y,-z),(x,-y,z),(-x,-y,z),
                    (-x,y,z),(x,y,z)]
        faces = [(0,3,2,1),(3,4,5,2),(0,1,5,4),(0,4,3),(1,2,5)]
        if row['shape'] == 'Block':
            vertices += [(-x,y,-z),(x,y,-z)]
            faces = [(0,3,2,1),(3,4,5,2),(6,7,5,4),(0,6,4,3),(1,2,5,7),(0,1,7,6)]
        else:
            assert row['shape'] == 'Wedge', row
        faces = [tuple(reversed(face)) for face in faces]
    mesh = bpy.data.meshes.new(row['name'])
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(row['name'], mesh)
    scene.collection.objects.link(obj)
    a, b, c, r00, r01, r02, r10, r11, r12, r20, r21, r22 = row['transform']
    rotation = Matrix(((r00,r01,r02,a),(r10,r11,r12,b),(r20,r21,r22,c),(0,0,0,1)))
    # Roblox +Y up, +Z back. Blender +Z up, +Y forward.
    obj.matrix_world = Matrix(((1,0,0,0),(0,0,-1,0),(0,1,0,0),(0,0,0,1))) @ rotation
    obj.data.materials.append(material(row['material'], row['color']))
    return obj

light('Front', (-7, 9, 13), 1900, 13)
light('Return', (7, -9, 12), 1900, 13)
bpy.ops.mesh.primitive_plane_add(size=200, location=(0,0,-.12))
bpy.context.object.data.materials.append(material('Backdrop', (.285,.30,.325)))
camera_data = bpy.data.cameras.new('Matched camera')
camera_data.type = 'ORTHO'
camera_data.ortho_scale = 20.5
camera = bpy.data.objects.new('Matched camera', camera_data)
scene.collection.objects.link(camera)
scene.camera = camera

for stage, models in data.items():
    for story, rows in models.items():
        objects = [part(row) for row in rows]
        for view, position in [('approach', (-9,23,11)), ('return', (13,-22,10))]:
            camera.location = position
            aim(camera, (0,0,1.15))
            scene.render.filepath = str(output / f'{story}-{stage}-{view}.png')
            bpy.ops.render.render(write_still=True)
        for obj in objects:
            bpy.data.objects.remove(obj, do_unlink=True)
