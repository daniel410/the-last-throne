"""승인된 NPC 표면을 보존하고 호위용 최소 하체 리그를 별도 GLB로 만든다.

격리 Blender --background --factory-startup에서 실행한다. Selene는 제외한다.
"""
import hashlib
import json
import math
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/models/npc-meshy-5k-v1'
OUT = BASE / 'skinned'
OUT.mkdir(exist_ok=True)
manifest = json.loads((BASE / 'manifest.json').read_text())
catalog = {a['id']: a for a in json.loads((ROOT / 'assets/npcs/cast-v1/catalog.json').read_text())['characters']}
records = []

def smooth(a, b, value):
    t = max(0, min(1, (value-a)/(b-a)))
    return t*t*(3-2*t)

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for entry in manifest['assets']:
    cid = entry['id']
    assert cid != 'selene'
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    scene = bpy.context.scene
    scene.view_settings.view_transform = 'Standard'
    scene.view_settings.look = 'None'
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1
    scene.view_settings.use_curve_mapping = False
    scene.display_settings.display_device = 'sRGB'
    source = BASE / entry['candidateGlb']
    bpy.ops.import_scene.gltf(filepath=str(source))
    meshes = [o for o in scene.objects if o.type == 'MESH']
    assert len(meshes) == 1
    mesh = meshes[0]
    # 월드 좌표를 정점에 적용하고 승인된 형상·UV·면 수를 보존한다.
    matrix = mesh.matrix_world.copy()
    mesh.parent = None
    for vertex in mesh.data.vertices:
        vertex.co = matrix @ vertex.co
    mesh.matrix_world = Matrix.Identity(4)
    mesh.name = 'NPC_' + cid
    mesh.data.name = cid + '_Surface'
    vertices = [v.co.copy() for v in mesh.data.vertices]
    low = Vector([min(v[i] for v in vertices) for i in range(3)])
    high = Vector([max(v[i] for v in vertices) for i in range(3)])
    height = high.z-low.z
    assert abs(height-2) < .001
    # 발 영역에서 몸 중심을 구한다. 높은 도구는 몸 중심 계산에서 제외한다.
    feet = [v for v in vertices if v.z < low.z + height*.12]
    center = (min(v.x for v in feet)+max(v.x for v in feet))/2
    half_width = max(abs(v.x-center) for v in feet)
    depth_low, depth_high = min(v.y for v in feet), max(v.y for v in feet)
    leg_top = height*(.31 if catalog[cid]['race'] == 'dwarf' else .37)
    ankle = height*.095
    rig_data = bpy.data.armatures.new(cid+'_Skeleton')
    rig = bpy.data.objects.new(cid+'_Rig', rig_data)
    scene.collection.objects.link(rig)
    bpy.ops.object.select_all(action='DESELECT')
    rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='EDIT')
    specs = [('Body', (center,0,leg_top), (center,0,leg_top+.2), '')]
    for side, sign in [('L',-1), ('R',1)]:
        x = center+sign*half_width*.48
        specs += [('Leg'+side,(x,0,leg_top),(x,0,ankle),'Body'),
                  ('Foot'+side,(x,0,ankle),(x,-.14,ankle),'Leg'+side)]
    for name, head, tail, parent in specs:
        bone = rig_data.edit_bones.new(name)
        bone.head, bone.tail = head, tail
        if parent:
            bone.parent = rig_data.edit_bones[parent]
    bpy.ops.object.mode_set(mode='OBJECT')
    groups = {name: mesh.vertex_groups.new(name=name) for name,_,_,_ in specs}
    counts = {name: 0 for name in groups}
    for vertex in mesh.data.vertices:
        x,y,z = vertex.co
        # 손에 든 도구와 옆 가방을 다리 스키닝에서 제외한다.
        footprint = abs(x-center) <= half_width*1.04 and depth_low-.08 <= y <= depth_high+.08
        leg = (1-smooth(leg_top*.62,leg_top,z)) if footprint else 0
        foot = 1-smooth(ankle*.8,ankle*1.7,z)
        side = 'L' if x < center else 'R'
        weights = {'Body':1-leg,'Leg'+side:leg*(1-foot),'Foot'+side:leg*foot}
        assert abs(sum(weights.values())-1) < 1e-6
        for name, weight in weights.items():
            if weight > 0:
                groups[name].add([vertex.index],weight,'REPLACE')
                counts[name] += 1
    assert all(n > 0 for n in counts.values()), (cid,counts)
    mesh.parent = rig
    modifier = mesh.modifiers.new('NPCContinuousSkin','ARMATURE')
    modifier.object = rig
    mesh.data.calc_loop_triangles()
    triangles = len(mesh.data.loop_triangles)
    assert triangles == entry['candidateTriangles'] <= 5000
    # Body 호흡 동작은 손과 소품을 같은 강체로 움직인다.
    bpy.ops.object.select_all(action='DESELECT')
    rig.select_set(True)
    mesh.select_set(True)
    target = OUT / f'{cid}.glb'
    bpy.ops.export_scene.gltf(filepath=str(target), export_format='GLB', use_selection=True,
        export_animations=False, export_rest_position_armature=True)
    samples = [vertices[round(i*(len(vertices)-1)/47)] for i in range(48)]
    records.append({'id':cid,'source':str(source.relative_to(ROOT)),'sourceSha256':digest(source),
        'file':str(target.relative_to(ROOT)),'sha256':digest(target),'triangles':triangles,
        'bones':[s[0] for s in specs], 'weightedVertices':counts,
        'size':[high.x-low.x, height, high.y-low.y],
        'center':[(low.x+high.x)/2,(low.z+high.z)/2,-(low.y+high.y)/2],
        'samples':[[v.x,v.z,-v.y] for v in samples],
        'bodyCenterX':center,'sourceHeight':height,'legTop':leg_top,
        'restGeometryUnchanged':True,'embeddedTextures':True})
    print('NPC_SKIN',cid,triangles,flush=True)

(BASE/'skin-manifest.json').write_text(json.dumps({'taskId':'NPC-APPLY-20261117',
    'userApprovedSource':True,'excluded':['selene'],'runtimeMode':'lower-body escort gait; rigid upper body and held props',
    'colorManagement':'Standard / sRGB / None / 0 / 1 / Curves Off','assets':records},indent=2)+'\n')
