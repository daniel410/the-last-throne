"""Render matched AgX/Standard comparisons without resaving source materials.

Run through Blender --background --python ... -- <review-root>.
These are neutral-light review renders, not Roblox appearance acceptance.
"""
import bpy
import json
import sys
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/evidence/standard-color-20261108'
ASSETS = ROOT / 'assets/reviews/standard-color-v1'
SOURCES = {
    'map-forest-kit': ASSETS / 'map-forest-kit.blend',
    'melee-heroes': ASSETS / 'assets/animations/melee-blender-v1/melee-attacks.blend',
    'elf-archer': ASSETS / 'assets/animations/elf-bow-v1/elf-bow-refined.blend',
    'mage': ASSETS / 'assets/animations/mage-staff-v1/mage-staff-casting.blend',
    'npc-heads': ASSETS / 'assets/npcs/nia-hair-v5/nia-hair-v5.blend',
    'gloamwood': ASSETS / 'live-character-scenes.blend',
    'selene': ROOT / 'assets/animations/selene-repair-v1/Selene-repaired.glb',
}


def render(key, path):
    if path.suffix == '.glb':
        bpy.ops.wm.read_factory_settings(use_empty=True)
        bpy.ops.import_scene.gltf(filepath=str(path))
        scene = bpy.context.scene
        scene.display_settings.display_device = 'sRGB'
        scene.view_settings.view_transform = 'Standard'
        scene.view_settings.look = 'None'
        scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
        scene.view_settings.use_curve_mapping = False
        bpy.ops.wm.save_as_mainfile(filepath=str(ASSETS / (key + '.blend')))
    else:
        bpy.ops.wm.open_mainfile(filepath=str(path))
    candidates = [s for s in bpy.data.scenes if any(o.type == 'MESH' for o in s.objects)]
    chosen = {'gloamwood': 'TLT_Gloamwood_Meshy_v1',
              'elf-archer': 'TLT_Elf_Bow_Authoring', 'mage': 'TLT_Mage_Staff_Authoring'}
    scene = (bpy.data.scenes[chosen[key]] if key in chosen
             else max(candidates, key=lambda s: sum(o.type == 'MESH' for o in s.objects)))
    bpy.context.window.scene = scene
    bpy.context.view_layer.update()
    meshes = [o for o in scene.objects if o.type == 'MESH' and not o.hide_render]
    points = [o.matrix_world @ Vector(c) for o in meshes for c in o.bound_box]
    low = Vector(tuple(min(p[i] for p in points) for i in range(3)))
    high = Vector(tuple(max(p[i] for p in points) for i in range(3)))
    center = (low + high) / 2
    radius = max((high - low).length / 2, 1)
    # Dedicated review camera/lights leave existing object transforms untouched.
    camera = bpy.data.objects.new('TLT_Standard_Review_Camera', bpy.data.cameras.new('TLT_Standard_Review_Camera'))
    scene.collection.objects.link(camera)
    camera.location = center + Vector((.8, -1.6, .85)).normalized() * radius * 3
    camera.rotation_euler = (center - camera.location).to_track_quat('-Z', 'Y').to_euler()
    camera.data.type = 'ORTHO'
    camera.data.ortho_scale = radius * 2.4
    camera.data.clip_end = radius * 20
    scene.camera = camera
    for obj in scene.objects:
        if obj.type == 'LIGHT':
            obj.hide_render = True
    world = bpy.data.worlds.new('TLT_Standard_Neutral_World')
    world.use_nodes = True
    bg = next(n for n in world.node_tree.nodes if n.type == 'BACKGROUND')
    bg.inputs['Color'].default_value = (.18, .18, .18, 1)
    bg.inputs['Strength'].default_value = .8
    scene.world = world
    light = bpy.data.objects.new('TLT_Standard_Neutral_Sun', bpy.data.lights.new('TLT_Standard_Neutral_Sun', 'SUN'))
    scene.collection.objects.link(light)
    light.rotation_euler = (.45, -.4, -.5)
    light.data.energy = 1.5
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.samples = 8
    scene.render.resolution_x = 800
    scene.render.resolution_y = 600
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = 'PNG'
    scene.render.film_transparent = False
    scene.display_settings.display_device = 'sRGB'
    scene.view_settings.look = 'None'
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1
    scene.view_settings.use_curve_mapping = False
    for transform in ('AgX', 'Standard'):
        scene.view_settings.view_transform = transform
        scene.render.filepath = str(OUT / (key + '-' + transform.lower() + '.png'))
        bpy.ops.render.render(write_still=True)
    return dict(key=key, source=str(path.relative_to(ROOT)), scene=scene.name,
                meshes=len(meshes), engine=scene.render.engine, samples=8,
                note='Same geometry, materials, frame, neutral lights, camera; only view transform differs. Not Roblox render.')


if __name__ == '__main__':
    rows = []
    for key, path in SOURCES.items():
        rows.append(render(key, path))
        (OUT / 'render-settings.json').write_text(json.dumps(rows, indent=2) + '\n')
