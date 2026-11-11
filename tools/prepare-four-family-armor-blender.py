"""Preserve Meshy originals; export articulated rigid clothing panels with UVs.

Run in a separate background Blender. All coordinates in the report use Roblox
axes and the neutral block R15 frame (HumanoidRootPart at the origin).
"""
from pathlib import Path
import bpy, bmesh, json, math, hashlib
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/models/four-family-armor-meshy-v1'
manifest = json.loads((BASE / 'manifest.json').read_text())
ANCHORS = {
    'Head': (0, 1.586, 0), 'UpperTorso': (0, .2, 0), 'LowerTorso': (0, -.8, 0),
    'LeftUpperArm': (-1.5, .369, 0), 'RightUpperArm': (1.5, .369, 0),
    'LeftLowerArm': (-1.5, -.224, 0), 'RightLowerArm': (1.5, -.224, 0),
    'LeftHand': (-1.5, -.85, 0), 'RightHand': (1.5, -.85, 0),
    'LeftUpperLeg': (-.5, -1.421, 0), 'RightUpperLeg': (.5, -1.421, 0),
    'LeftLowerLeg': (-.5, -2.201, 0), 'RightLowerLeg': (.5, -2.201, 0),
    'LeftFoot': (-.5, -2.85, 0), 'RightFoot': (.5, -2.85, 0),
}

def standard(scene):
    scene.display_settings.display_device = 'sRGB'
    scene.view_settings.view_transform = 'Standard'
    scene.view_settings.look = 'None'
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1
    scene.view_settings.use_curve_mapping = False

def bounds(points):
    return (Vector([min(p[i] for p in points) for i in range(3)]),
            Vector([max(p[i] for p in points) for i in range(3)]))

def to_blender(p):
    return Vector((p.x, -p.z, p.y))

bpy.ops.wm.read_factory_settings(use_empty=True)
(BASE / 'prepared').mkdir(exist_ok=True)
reports = []
for row in manifest['records']:
    scene = bpy.data.scenes.new(row['id'])
    bpy.context.window.scene = scene
    standard(scene)
    bpy.ops.import_scene.gltf(filepath=str(BASE / row['source']))
    imported = [o for o in scene.objects if o.type == 'MESH']
    assert len(imported) == 1, row['id']
    obj = imported[0]
    # glTF +Z faces the viewer in Meshy; rotate to Roblox -Z.
    points = [Vector((-p.x, p.z, p.y)) for p in
              (obj.matrix_world @ v.co for v in obj.data.vertices)]
    lo, hi = bounds(points)
    center, extent = (lo + hi) / 2, hi - lo
    kind = row['category']
    components = {}
    if kind in ('hood', 'helmet', 'hat'):
        height = {'hood': 1.9, 'helmet': 1.9, 'hat': 2.05}[kind]
        if kind == 'hat':
            normalized = [(p-center)*(height/extent.y) for p in points]
        else:
            # Fit the hollow shell around the physical Head, rather than
            # scaling its outside height while leaving its cavity too shallow.
            target = Vector((1.9, height, 1.7))
            normalized = [Vector([(p[a]-center[a])*target[a]/extent[a]
                                  for a in range(3)]) for p in points]
        # Hat brim sits just above the eyes; hood opening surrounds the head.
        offset = Vector((0, 1.586 + (1.55 if kind == 'hat' else .1), 0))
        normalized = [p + offset for p in normalized]
        for i, p in enumerate(normalized):
            obj.data.vertices[i].co = to_blender(p)
        components['Head'] = list(range(len(obj.data.polygons)))
    elif kind in ('gloves', 'boots'):
        # Split the paired source across its actual empty center gap.
        side_faces = {'Left': [], 'Right': []}
        for face in obj.data.polygons:
            x = sum(points[i].x for i in face.vertices) / len(face.vertices)
            side_faces['Right' if x > center.x else 'Left'].append(face.index)
        for side, faces in side_faces.items():
            indices = {i for f in faces for i in obj.data.polygons[f].vertices}
            sl, sh = bounds([points[i] for i in indices])
            sc, se = (sl + sh) / 2, sh - sl
            if kind == 'gloves':
                target = Vector((1.12, 1.18, 1.15))
                at = Vector(ANCHORS[side + 'Hand']) + Vector((0, .27, 0))
            else:
                target = Vector((1.14, 1.65, 1.35))
                at = Vector(ANCHORS[side + 'Foot']) + Vector((0, .64, -.12))
            for i in indices:
                p = points[i] - sc
                p = Vector([p[a] * target[a] / se[a] for a in range(3)]) + at
                obj.data.vertices[i].co = to_blender(p)
            for f in faces:
                cy = sum(obj.data.vertices[i].co.z for i in obj.data.polygons[f].vertices) / len(obj.data.polygons[f].vertices)
                anchor = side + (('Hand' if cy < -.64 else 'LowerArm') if kind == 'gloves'
                                 else ('Foot' if cy < -2.62 else 'LowerLeg'))
                components.setdefault(anchor, []).append(f)
    else:
        height = 4.0 if kind == 'robe' else 3.05
        width = 4.15 if kind == 'robe' else 3.05
        depth = 1.35
        normalized = [Vector(((p.x-center.x)*width/extent.x,
                              1.02-(hi.y-p.y)*height/extent.y,
                              (p.z-center.z)*depth/extent.z)) for p in points]
        for i, p in enumerate(normalized):
            obj.data.vertices[i].co = to_blender(p)
        for f in obj.data.polygons:
            p = sum((normalized[i] for i in f.vertices), Vector())/len(f.vertices)
            if kind == 'robe' and abs(p.x) > 1.03 and p.y > -1.45:
                anchor = ('Right' if p.x > 0 else 'Left') + ('UpperArm' if p.y > .05 else 'LowerArm')
            elif p.y < -1.02:
                anchor = ('Right' if p.x > 0 else 'Left') + 'UpperLeg'
            elif p.y < -.55:
                anchor = 'LowerTorso'
            else:
                anchor = 'UpperTorso'
            components.setdefault(anchor, []).append(f.index)
    obj.matrix_world = Matrix.Identity(4)
    source_face_count = len(obj.data.polygons)
    assert sum(map(len, components.values())) == source_face_count
    parts = []
    exports = []
    for anchor, faces in components.items():
        part = obj.copy()
        part.data = obj.data.copy()
        part.name = anchor
        part.data.name = anchor
        scene.collection.objects.link(part)
        bm = bmesh.new(); bm.from_mesh(part.data); bm.faces.ensure_lookup_table()
        keep = set(faces)
        bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.index not in keep], context='FACES')
        bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
        bm.to_mesh(part.data); bm.free(); part.data.update()
        # Assign faces in the original A pose, then straighten every vertex of
        # each sleeve panel together. Per-vertex region tests tear cuff edges.
        if kind == 'robe' and anchor.endswith('Arm'):
            side = 1 if anchor.startswith('Right') else -1
            for vertex in part.data.vertices:
                p = vertex.co
                t = max(0, min(1, (1.02-p.z)/2.2))
                p.x = side*(1.5+(abs(p.x)-(1.0+.8*t)))
                p.z = 1.02-1.95*t
            part.data.update()
        native = [Vector((v.co.x, v.co.z, -v.co.y)) for v in part.data.vertices]
        pl, ph = bounds(native)
        samples = [list(native[i]) for i in range(0,len(native),max(1,len(native)//24))][:24]
        parts.append(dict(name=anchor, anchor=anchor, referenceAnchor=ANCHORS[anchor],
                          size=list(ph-pl), center=list((pl+ph)/2), samples=samples,
                          triangles=len(part.data.polygons)))
        exports.append(part)
    bpy.data.objects.remove(obj, do_unlink=True)
    bpy.ops.object.select_all(action='DESELECT')
    for part in exports: part.select_set(True)
    bpy.context.view_layer.objects.active = exports[0]
    standard(scene)
    row['prepared'] = 'prepared/' + row['id'] + '.glb'
    bpy.ops.export_scene.gltf(filepath=str(BASE/row['prepared']), export_format='GLB',
                             use_selection=True, use_active_scene=True,
                             export_animations=False, export_yup=True)
    row['preparedSha256'] = hashlib.sha256((BASE/row['prepared']).read_bytes()).hexdigest()
    reports.append(dict(id=row['id'], definitionId=row['definitionId'],category=kind,
                        meshyTaskId=row['meshyTaskId'], sourceTriangles=row['triangles'],
                        sourceFaces=source_face_count, parts=parts, front=[0,0,-1],
                        viewTransform='Standard', display='sRGB', look='None',
                        exposure=0, gamma=1, useCurves=False))
    print('PREPARED_ARMOR',row['id'],len(parts),flush=True)
(BASE/'geometry-report.json').write_text(json.dumps(reports,indent=2)+'\n')
(BASE/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
bpy.ops.wm.save_as_mainfile(filepath=str(BASE/'four-family-armor-review.blend'),compress=True)
