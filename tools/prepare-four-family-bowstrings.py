"""Replace only Meshy's baked bowstring strip with runtime beam attachment data."""
import bpy,bmesh,json,shutil
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/four-family-weapons-meshy-v1'
rows=json.loads((BASE/'geometry-report.json').read_text())
(BASE/'normalized').mkdir(exist_ok=True)
for row in rows:
 if row['category']!='bow':continue
 bpy.ops.wm.read_factory_settings(use_empty=True);scene=bpy.context.scene
 scene.display_settings.display_device='sRGB';scene.view_settings.view_transform='Standard';scene.view_settings.look='None';scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.view_settings.use_curve_mapping=False
 file=BASE/row['prepared'];intact=BASE/'normalized'/(row['id']+'-intact.glb')
 if not intact.exists():shutil.copyfile(file,intact)
 bpy.ops.import_scene.gltf(filepath=str(intact));obj=next(o for o in scene.objects if o.type=='MESH')
 pts=[v.co.copy() for v in obj.data.vertices];height=row['targetHeight']
 candidates=[]
 for edge in obj.data.edges:
  a,b=[pts[i] for i in edge.vertices]
  if a.z*b.z<=0 and abs(a.z-b.z)>height*.08:
   mid=a+(b-a)*(-a.z/(b.z-a.z))
   if mid.y<-height*.08:candidates.extend([a,b])
 assert candidates,(row['id'],'No explicit string edge across center')
 meanZ=sum(p.z for p in candidates)/len(candidates)
 def fit(axis):
  mean=sum(p[axis] for p in candidates)/len(candidates)
  slope=sum((p.z-meanZ)*(p[axis]-mean) for p in candidates)/sum((p.z-meanZ)**2 for p in candidates)
  return lambda z:mean+slope*(z-meanZ)
 fx,fy=fit(0),fit(1)
 def line(z):return Vector((fx(z),fy(z),z))
 removed=[]
 for poly in obj.data.polygons:
  vertices=[pts[i] for i in poly.vertices];middle=sum((p for p in vertices),Vector())/len(vertices)
  if abs(middle.z)<height*.45 and all((p-line(p.z)).length<height*.026 for p in vertices):removed.append(poly.index)
 assert 8<len(removed)<row['triangles']*.25,(row['id'],len(removed))
 removedPts=[pts[i] for index in removed for i in obj.data.polygons[index].vertices]
 lowerZ=min(p.z for p in removedPts);upperZ=max(p.z for p in removedPts)
 bm=bmesh.new();bm.from_mesh(obj.data);bm.faces.ensure_lookup_table()
 bmesh.ops.delete(bm,geom=[bm.faces[i] for i in removed],context='FACES');bm.to_mesh(obj.data);bm.free();obj.data.update()
 bpy.context.view_layer.objects.active=obj;obj.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(file),export_format='GLB',use_selection=True,use_active_scene=True,export_animations=False,export_yup=True)
 def roblox(p):return [p.x,p.z,-p.y]
 row['bowGeometry']=dict(upper=roblox(line(upperZ)),lower=roblox(line(lowerZ)),nock=roblox(line(.37656283)),bakedStringFacesRemoved=len(removed),intactNormalized=str(intact.relative_to(BASE)),rationale='Only narrow baked string faces replaced by the existing two moving beams; original GLB and complete icon render retained')
 row['runtimeTriangles']=sum(len(p.vertices)-2 for p in obj.data.polygons)
 print(row['id'],row['bowGeometry'])
(BASE/'geometry-report.json').write_text(json.dumps(rows,indent=2)+'\n')
