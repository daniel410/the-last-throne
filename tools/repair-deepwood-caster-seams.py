"""Preserve UVs and surface area; transfer mispartitioned weapon fragments to the owning arm."""
import importlib.util,json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/animations/deepwood-monsters-v3/mesh-repairs';OUT.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('mesh',ROOT/'tools/repair-deepwood-weapons.py');mesh=importlib.util.module_from_spec(s);s.loader.exec_module(mesh)
sources=json.loads((ROOT/'assets/animations/deepwood-monsters-v1/sources.json').read_text())
# Source coordinates are normalized Y-up. ROI excludes heads/crowns and opposite arm.
regions={
 'Shaman':[((1,0,0),.265),((0,0,1),.025)],
 'GoblinKing':[((1,0,0),.235)],
 'KingOgre':[((1,0,0),.20),((0,1,0),.68)],
 'KingShaman':[((1,0,0),.20),((0,0,1),.145)],
}
report={}
for kind,planes in regions.items():
 source=ROOT/sources[kind]['path'];parts=mesh.read(source);total=sum(mesh.area(f)for group in parts.values()for f in group)
 take,rest=mesh.extract(parts['Body'],planes);assert len(take)>0,kind
 parts['Body']=rest;parts['ArmR'].extend(take)
 if kind=='GoblinKing':
  # The staff tapers inward at the foot; it is a disconnected island below the robe.
  kept=[]
  for cluster in mesh.groups(parts['Body']):
   pts=[v[0]for f in cluster for v in f]
   if min(p[0]for p in pts)>.13 and min(p[2]for p in pts)>.045 and max(p[1]for p in pts)<.43:
    parts['ArmR'].extend(cluster);take.extend(cluster)
   else:kept.extend(cluster)
  parts['Body']=kept
 if kind in ['Shaman','KingShaman']:
  kept=[]
  for cluster in mesh.groups(parts['Body']):
   pts=[v[0]for f in cluster for v in f]
   if min(p[0]for p in pts)>.17 and min(p[2]for p in pts)>.025:
    parts['ArmR'].extend(cluster);take.extend(cluster)
   else:kept.extend(cluster)
  parts['Body']=kept
 after=sum(mesh.area(f)for group in parts.values()for f in group);assert abs(after-total)<1e-7,kind
 texture=source.parent/'ColorMap.png'
 # Full review retains the unchanged off arm; import candidate only replaces two changed meshes.
 path=OUT/(kind+'-review.glb');records=mesh.write(path,parts,texture.read_bytes())
 mesh.write(OUT/(kind+'-import.glb'),{k:parts[k]for k in ['Body','ArmR']},texture.read_bytes())
 report[kind]={'source':str(source.relative_to(ROOT.parent)),'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'planes':planes,'movedTriangles':len(take),'surfaceAreaError':abs(after-total),'parts':records,'status':'local candidate; Roblox mesh upload pending'}
(OUT/'geometry.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v['movedTriangles']for k,v in report.items()}))
