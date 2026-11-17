"""승인 표면과 리그 파생본의 정점·UV를 비교하고 걷기 극단 자세를 렌더한다."""
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector
from mathutils.kdtree import KDTree

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/npc-meshy-5k-v1'
OUT=ROOT/'docs/evidence/npc-apply-20261117'
OUT.mkdir(exist_ok=True)
manifest=json.loads((BASE/'skin-manifest.json').read_text())
reports=[]

def signature(objects):
    result=[]
    for obj in objects:
        uv=obj.data.uv_layers.active.data
        for loop in obj.data.loops:
            p=obj.matrix_world@obj.data.vertices[loop.vertex_index].co
            result.append(tuple((*p,*uv[loop.index].uv)))
    return result

def same_surface(before,after):
    if len(before)!=len(after):
        return False
    tree=KDTree(len(after))
    for i,p in enumerate(after):tree.insert(p[:3],i)
    tree.balance()
    # glTF float32 왕복 오차만 허용하고 UV 이음매도 함께 비교한다.
    for p in before:
        matches=tree.find_range(p[:3],.000003)
        if not any(max(abs(p[j]-after[i][j]) for j in (3,4))<.000003 for _,i,_ in matches):
            return False
    return True

for entry in manifest['assets']:
    cid=entry['id']
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(ROOT/entry['source']))
    original=signature([o for o in bpy.context.scene.objects if o.type=='MESH'])
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(ROOT/entry['file']))
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH' and o.name.startswith('NPC_'+cid)]
    # glTF 가져오기가 만든 본 표시용 Icosphere는 실제 GLB 메시가 아니다.
    for helper in list(bpy.context.scene.objects):
        if helper.type=='MESH' and helper not in meshes:
            bpy.data.objects.remove(helper,do_unlink=True)
    assert same_surface(original,signature(meshes)), cid+': changed approved rest surface or UV'
    rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE')
    assert set(b.name for b in rig.data.bones)==set(entry['bones'])
    for side,sign in [('L',1),('R',-1)]:
        bone=rig.pose.bones['Leg'+side]
        bone.location=bone.bone.matrix_local.to_3x3().inverted()@Vector((0,-sign*.09,max(0,sign)*.05))
    bpy.context.view_layer.update()
    depsgraph=bpy.context.evaluated_depsgraph_get()
    points=[]
    max_displacement=0
    for mesh in meshes:
        evaluated=mesh.evaluated_get(depsgraph)
        for v,rest in zip(evaluated.data.vertices,mesh.data.vertices):
            point=mesh.matrix_world@v.co;points.append(point)
            max_displacement=max(max_displacement,(point-mesh.matrix_world@rest.co).length)
    assert all(math.isfinite(c) for p in points for c in p)
    assert min(p.z for p in points)>=-.002,(cid,'floor penetration')
    assert max_displacement<=.105,(cid,'unbounded skinning')
    scene=bpy.context.scene
    scene.view_settings.view_transform='Standard';scene.view_settings.look='None'
    scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.view_settings.use_curve_mapping=False
    scene.display_settings.display_device='sRGB'
    scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
    scene.render.resolution_x=420;scene.render.resolution_y=560;scene.render.resolution_percentage=100
    scene.world.use_nodes=True
    bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND')
    bg.inputs['Color'].default_value=(.55,.55,.55,1);bg.inputs['Strength'].default_value=.65
    for location,power in [((-3,-4,5),220),((4,-2,3),100),((1,3,4),150)]:
        bpy.ops.object.light_add(type='AREA',location=location)
        light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=4
        light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
    bpy.ops.object.camera_add(location=(2,-6,1.45))
    cam=bpy.context.object;cam.data.type='ORTHO';cam.data.ortho_scale=2.5
    cam.rotation_euler=(Vector((0,0,1))-cam.location).to_track_quat('-Z','Y').to_euler();scene.camera=cam
    scene.render.filepath=str(OUT/f'{cid}-walk.png');bpy.ops.render.render(write_still=True)
    reports.append({'id':cid,'restSurfaceAndUVPreserved':True,'float32Tolerance':.000003,'bones':len(rig.data.bones),
        'triangles':entry['triangles'],'minimumPosedZ':min(p.z for p in points),
        'maxVertexDisplacement':max_displacement,'render':f'{cid}-walk.png'})
    print('SKIN_REVIEW',cid,flush=True)
(OUT/'skin-validation.json').write_text(json.dumps(reports,indent=2)+'\n')
