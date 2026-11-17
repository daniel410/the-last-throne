"""NPC-5K-20261117: 격리 Blender 프로세스에서 5k 후보와 검토 렌더를 만든다."""
import argparse
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/models/npc-meshy-5k-v1'
REVIEW = ROOT / 'docs/evidence/npc-meshy-5k-20261117'
parser = argparse.ArgumentParser()
parser.add_argument('--ids', nargs='+')
parser.add_argument('--bundle-name')
args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else [])
manifest = json.loads((ROOT / 'assets/concepts/2026-11-17-npc-blocky-5k-v1/manifest.json').read_text())
cast = [a for a in manifest['assets'] if not args.ids or a['id'] in args.ids]
REVIEW.mkdir(parents=True, exist_ok=True)
(ASSETS / 'candidates').mkdir(exist_ok=True)

# 이 스크립트는 --background --factory-startup으로만 실행한다.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
scene = bpy.context.scene
scene.name = 'TLT_NPC_5K_Review'
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.cycles.use_denoising = True
scene.render.resolution_x = 560
scene.render.resolution_y = 700
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = 'PNG'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0
scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
scene.display_settings.display_device = 'sRGB'
scene.world.use_nodes = True
background = next(n for n in scene.world.node_tree.nodes if n.type == 'BACKGROUND')
background.inputs['Color'].default_value = (0.55, 0.55, 0.55, 1)
background.inputs['Strength'].default_value = 0.65

def aim(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat('-Z', 'Y').to_euler()

bpy.ops.object.camera_add(location=(0, -6, 1.35))
camera = bpy.context.object
camera.name = 'NPCReviewCamera'
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 2.5
scene.camera = camera
for name, location, power, size in [
    ('ReviewKey', (-3, -4, 5), 220, 4),
    ('ReviewFill', (4, -2, 3), 100, 4),
    ('ReviewRim', (1, 3, 4), 150, 3),
]:
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.object
    light.name = name
    light.data.energy = power
    light.data.shape = 'DISK'
    light.data.size = size
    aim(light, (0, 0, 1))

def triangles(objects):
    for obj in objects:
        obj.data.calc_loop_triangles()
    return sum(len(obj.data.loop_triangles) for obj in objects)

def bounds(objects):
    points = [obj.matrix_world @ Vector(c) for obj in objects for c in obj.bound_box]
    return Vector([min(v[i] for v in points) for i in range(3)]), Vector([max(v[i] for v in points) for i in range(3)])

reports = []
models = []
for entry in cast:
    cid = entry['id']
    source = ASSETS / f'{cid}.glb'
    if not source.exists():
        raise FileNotFoundError(source)
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(source))
    imported = [o for o in bpy.data.objects if o not in before]
    meshes = [o for o in imported if o.type == 'MESH']
    original_triangles = triangles(meshes)
    collection = bpy.data.collections.new(f'NPC_{cid}')
    scene.collection.children.link(collection)
    for index, obj in enumerate(imported):
        for old_collection in list(obj.users_collection):
            old_collection.objects.unlink(obj)
        collection.objects.link(obj)
        obj.name = f'{cid}_{index:02d}'
    # 월드 변환을 보존하며 계층을 해제하고 검토용 크기만 표준화한다.
    for obj in meshes:
        matrix = obj.matrix_world.copy()
        obj.parent = None
        obj.matrix_world = matrix
    low, high = bounds(meshes)
    factor = 2.0 / (high.z - low.z)
    center = Vector(((low.x + high.x) / 2, (low.y + high.y) / 2, low.z))
    for obj in meshes:
        obj.location = (obj.location - center) * factor
        obj.scale *= factor
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if original_triangles > 5000:
        for obj in meshes:
            bpy.context.view_layer.objects.active = obj
            modifier = obj.modifiers.new('PreviewTriangleBudget', 'DECIMATE')
            modifier.ratio = 4995 / original_triangles
            modifier.use_collapse_triangulate = True
            bpy.ops.object.modifier_apply(modifier=modifier.name)
    final_triangles = triangles(meshes)
    assert 0 < final_triangles <= 5000, (cid, final_triangles)
    assert all(math.isfinite(c) for obj in meshes for v in obj.data.vertices for c in v.co)
    assert all(len(obj.data.uv_layers) for obj in meshes), f'{cid}: missing UVs'
    bpy.ops.object.select_all(action='DESELECT')
    for obj in meshes:
        obj.select_set(True)
    candidate = ASSETS / 'candidates' / f'{cid}-5k.glb'
    bpy.ops.export_scene.gltf(filepath=str(candidate), export_format='GLB', use_selection=True)
    report = {'id':cid, 'region':entry['region'], 'sourceTriangles':original_triangles,
              'candidateTriangles':final_triangles, 'meshCount':len(meshes),
              'uvPresent':True, 'finiteCoordinates':True, 'rigged':False,
              'source':str(source.relative_to(ROOT)), 'candidate':str(candidate.relative_to(ROOT)),
              'blenderVersion':bpy.app.version_string, 'colorManagement':'Standard / sRGB / None / 0 / 1 / Curves Off',
              'renders':[]}
    for view, position in [('front',(0,-6,1.25)), ('three-quarter',(3,-6,1.65)), ('back',(0,6,1.25))]:
        camera.location = position
        aim(camera, (0,0,1))
        image_path = REVIEW / f'{cid}-{view}.png'
        scene.render.filepath = str(image_path)
        bpy.ops.render.render(write_still=True)
        report['renders'].append(str(image_path.relative_to(ROOT)))
    (REVIEW / f'{cid}-geometry.json').write_text(json.dumps(report, indent=2)+'\n')
    reports.append(report)
    models.append((collection, meshes))
    collection.hide_render = True
    print('NPC_REVIEW ' + json.dumps(report), flush=True)

# 후보들을 겹치지 않는 격자로 보존한다. 개별 GLB는 원점 기준이다.
for index, (collection, meshes) in enumerate(models):
    collection.hide_render = False
    for obj in meshes:
        obj.location.x += (index % 6) * 2.6
        obj.location.y += (index // 6) * 3.0
scene.render.filepath = ''
bpy.ops.file.pack_all()
suffix = args.bundle_name or ('-'.join(args.ids) if args.ids else 'all')
bpy.ops.wm.save_as_mainfile(filepath=str(ASSETS / f'npc-5k-review-{suffix}.blend'))
(REVIEW / f'geometry-{suffix}.json').write_text(json.dumps(reports, indent=2)+'\n')
