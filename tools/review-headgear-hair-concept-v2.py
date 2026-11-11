"""Validate exported hairstyles and render unchanged four-family headwear fits."""
import bpy,bmesh,json,hashlib
from pathlib import Path
from mathutils import Vector,Matrix
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];O=R/'assets/models/headgear-hair-concept-v2';E=R/'docs/evidence/headgear-hair-concept-20261111'
bpy.ops.wm.open_mainfile(filepath=str(O/'headgear-hair-review.blend'))
m=json.loads((O/'manifest.json').read_text());report={'kind':'Blender geometry and fitting only','styles':[],'fits':[],'runtimeVerified':False}
for row in m['records']:
 style=row['style'];s=bpy.data.scenes[style];bpy.context.window.scene=s;hair=s.objects[row['template']]
 bm=bmesh.new();bm.from_mesh(hair.data);boundary=sum(not e.is_manifold for e in bm.edges);bm.free();assert boundary==0
 tree=BVHTree.FromPolygons([v.co for v in hair.data.vertices],[list(p.vertices)for p in hair.data.polygons])
 blocked=0
 for sign in (-1,1):
  for y in (.18,.23,.28):
   for dx in (-.025,0,.025):
    origin=Vector((sign*(.18+dx)*1.159,3,1.586+y*1.182));hit=tree.ray_cast(origin,Vector((0,-1,0)),3-.5805)
    blocked+=hit[0] is not None
 assert blocked==0,(style,blocked)
 assert row['triangles']<20000
 assert hashlib.sha256((O/(style+'.glb')).read_bytes()).hexdigest()==row['preparedSha256']
 ref=R/'assets/concepts/2026-10-27-shared-ui-v2/heroes'/('hero-'+style+'.png');row['conceptPath']=str(ref.relative_to(R));row['conceptSha256']=hashlib.sha256(ref.read_bytes()).hexdigest()
 report['styles'].append({'style':style,'triangles':row['triangles'],'nonManifoldEdges':boundary,'eyeRays':18,'eyeHits':blocked})
 category='hat'if style=='mage'else'hood'if style=='elf'else'helmet'
 for o in list(s.objects):
  if o.get('ReviewArmorCategory'):bpy.data.objects.remove(o,do_unlink=True)
 s.render.resolution_x=640;s.render.resolution_y=720;s.cycles.samples=16
 s.camera.data.ortho_scale=3.6 if style=='mage'else 2.7;s.camera.location=(0,9,3.1);s.camera.rotation_euler=(Vector((0,0,2.2 if style=='mage'else 1.7))-s.camera.location).to_track_quat('-Z','Y').to_euler()
 for family in ('traveler','tempered','veteran','sentinel'):
  before=set(s.objects);p=R/'assets/models/four-family-armor-meshy-v1/prepared'/(family+'_'+category+'.glb');bpy.ops.import_scene.gltf(filepath=str(p));added=set(s.objects)-before
  for o in added:
   if o.type=='MESH':
    for v in o.data.vertices:v.co=o.matrix_world@v.co
    o.matrix_world=Matrix.Identity(4);o.location.z+=-.25 if category=='hat'else .32 if category=='helmet'else 0
  s.render.filepath=str(E/(style+'-'+family+'.png'));bpy.ops.render.render(write_still=True)
  report['fits'].append({'style':style,'family':family,'headgearSha256':hashlib.sha256(p.read_bytes()).hexdigest(),'render':style+'-'+family+'.png'})
  for o in added:bpy.data.objects.remove(o,do_unlink=True)
(O/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');(E/'geometry-validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('VERIFIED',sum(x['triangles'] for x in report['styles']),'triangles; 72 clear eye rays; 16 headwear renders')
