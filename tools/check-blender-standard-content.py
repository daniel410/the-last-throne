"""Compare saved review mesh topology, UVs and material input colors with sources."""
import bpy,json,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1]
rows=json.loads((root/'docs/evidence/standard-color-20261108/blend-files.json').read_text())
def snapshot():
 objects={o.name:o for s in bpy.data.scenes for o in s.objects}
 meshes={o.data.name:o.data for o in objects.values()if o.type=='MESH'}
 materials={m.name:m for mesh in meshes.values()for m in mesh.materials if m}
 result={}
 for name,mesh in sorted(meshes.items()):
  h=hashlib.sha256()
  for v in mesh.vertices:h.update(repr(tuple(v.co)).encode())
  for p in mesh.polygons:h.update(repr((tuple(p.vertices),p.material_index)).encode())
  for uv in mesh.uv_layers:
   for value in uv.data:h.update(repr(tuple(value.uv)).encode())
  result['mesh:'+name]=h.hexdigest()
 for name,mat in sorted(materials.items()):
  values=[tuple(mat.diffuse_color)]
  if mat.use_nodes:
   for n in sorted(mat.node_tree.nodes,key=lambda n:n.name):
    for i in n.inputs:
     if hasattr(i,'default_value'):
      v=i.default_value
      if isinstance(v,(float,int,str,bool)):values.append((n.name,i.identifier,v))
      elif hasattr(v,'__len__'):values.append((n.name,i.identifier,tuple(v)))
  result['material:'+name]=hashlib.sha256(repr(values).encode()).hexdigest()
 return result
out=[]
for row in rows:
 bpy.ops.wm.open_mainfile(filepath=row['source']);a=snapshot()
 bpy.ops.wm.open_mainfile(filepath=row['output']);b=snapshot()
 diff=[k for k in sorted(set(a)|set(b))if a.get(k)!=b.get(k)]
 out.append(dict(source=row['source'],output=row['output'],meshesAndMaterials=len(a),differences=diff,passed=not diff))
 (root/'docs/evidence/standard-color-20261108/content-audit.json').write_text(json.dumps(out,indent=2)+'\n')
 print('CONTENT_AUDIT',Path(row['source']).name,len(a),len(diff),flush=True)
assert all(x['passed']for x in out)
