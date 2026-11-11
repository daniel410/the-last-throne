"""Extract TD Arcanist/Elf hair for hats, hoods and helmets; preserve TD files."""
from pathlib import Path
import bpy, json, hashlib, subprocess, sys
from mathutils import Vector, Matrix
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/headgear-hair-td-v1'
SHORT='--short' in sys.argv
HELMET='--helmet' in sys.argv
OUT=BASE/('short' if SHORT else 'helmet' if HELMET else 'mage');OUT.mkdir(exist_ok=True)
TD=ROOT.parent/'throne-defense'
SOURCE=TD/('assets/models/towers-elves-design-v1/archer/archer-rigged.glb' if SHORT else 'assets/models/towers-mages-design-v1/arcanist/arcanist-rigged.glb')
bpy.ops.wm.read_factory_settings(use_empty=True)
s=bpy.context.scene
s.display_settings.display_device='sRGB';s.view_settings.view_transform='Standard';s.view_settings.look='None'
s.view_settings.exposure=0;s.view_settings.gamma=1;s.view_settings.use_curve_mapping=False
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
hair=[o for o in s.objects if o.type=='MESH' and ('hair' in o.name.lower() if SHORT else o.name.startswith('Body_hair_') and (not HELMET or 'forelock' not in o.name))]
assert len(hair)==(3 if SHORT or HELMET else 5)
extra_source=None
if SHORT:
 extra_source=TD/'assets/models/towers-mages-design-v1/arcanist/arcanist-rigged.glb'
 before=set(bpy.data.objects)
 bpy.ops.import_scene.gltf(filepath=str(extra_source))
 extra=[o for o in bpy.data.objects if o not in before and o.type=='MESH' and 'hair_side_swept_forelock' in o.name]
 assert len(extra)==2
 hair+=extra
source_names=[o.name for o in hair]
for o in s.objects:o.select_set(False)
for o in hair:o.select_set(True)
bpy.context.view_layer.objects.active=hair[0]
bpy.ops.export_scene.gltf(filepath=str(OUT/'source-hair.glb'),export_format='GLB',use_selection=True,export_animations=False)
# Bake the authored rest shape, retaining all triangles and the five source locks.
deps=bpy.context.evaluated_depsgraph_get();copies=[]
for o in hair:
 mesh=bpy.data.meshes.new_from_object(o.evaluated_get(deps));n=bpy.data.objects.new('HairPiece',mesh);s.collection.objects.link(n)
 for v in mesh.vertices:
  p=o.matrix_world@v.co
  if 'forelock' in o.name:p.z+=.025
  reference_z=2.3 if SHORT and 'forelock' not in o.name else 2.405
  native=Vector((p.x*1.159/.9,(p.z-reference_z)*1.182/.75+1.586,-p.y*1.161/.64))
  if HELMET and native.y<1.586:native.y=1.586+(native.y-1.586)*1.5
  v.co=Vector((native.x,-native.z,native.y))
 n.matrix_world=Matrix.Identity(4);copies.append(n)
for o in s.objects:o.select_set(False)
for o in copies:o.select_set(True)
bpy.context.view_layer.objects.active=copies[0];bpy.ops.object.join();obj=bpy.context.object;obj.name='Hair';obj.data.name='Hair'
obj.data.materials.clear();mat=bpy.data.materials.new('TintableHair');mat.use_nodes=True
mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(1,1,1,1)
mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.85
obj.data.materials.append(mat)
for polygon in obj.data.polygons:polygon.material_index=0
for o in list(s.objects):
 if o!=obj:bpy.data.objects.remove(o,do_unlink=True)
bpy.context.view_layer.objects.active=obj;obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT/'prepared-hair.glb'),export_format='GLB',use_selection=True,export_animations=False)
pts=[Vector((v.co.x,v.co.z,-v.co.y))for v in obj.data.vertices]
lo=Vector([min(p[i]for p in pts)for i in range(3)]);hi=Vector([max(p[i]for p in pts)for i in range(3)])
triangles=sum(len(p.vertices)-2 for p in obj.data.polygons);assert triangles<20000
record=dict(sourceRepository=str(TD),sourceCommit=subprocess.check_output(['git','-C',str(TD),'rev-parse','HEAD']).decode().strip(),sourcePath=str(SOURCE.relative_to(TD)),sourceSha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),sourceNodes=source_names,sourceHairSha256=hashlib.sha256((OUT/'source-hair.glb').read_bytes()).hexdigest(),preparedSha256=hashlib.sha256((OUT/'prepared-hair.glb').read_bytes()).hexdigest(),triangles=triangles,size=list(hi-lo),center=list((lo+hi)/2),referenceAnchor=[0,1.586,0],samples=[list(pts[i])for i in range(0,len(pts),max(1,len(pts)//48))][:48],front=[0,0,-1],viewTransform='Standard',display='sRGB',look='None',exposure=0,gamma=1,useCurves=False,texturePolicy='No texture; white source material, explicit sRGB family tint at runtime',derivation='Existing TD hair pieces only; head-size normalization, forelock clearance or helmet nape extension. No face, head, hat, weapon or rig included.')
if extra_source:record['additionalForelockSource']={'path':str(extra_source.relative_to(TD)),'sha256':hashlib.sha256(extra_source.read_bytes()).hexdigest()}
(OUT/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'mage-hat-hair.blend'),compress=True)
print('HAIR',triangles,'triangles',list(hi-lo))
