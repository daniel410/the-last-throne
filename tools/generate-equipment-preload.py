"""Pin client preload descriptors to the approved runtime import evidence."""
import json
from pathlib import Path
r=Path(__file__).resolve().parents[1];base=r/'assets/models'
load=lambda p:json.loads((base/p/'native-import.json').read_text())
rows={}
for x in load(Path('four-family-armor-meshy-v1')):rows[x['id']]=[[p['meshId'],p['textureId']]for p in x['parts']]
for x in load(Path('four-family-weapons-meshy-v1')):rows[x['definitionId']]=[[x['meshId'],x['textureId']]]
for x in load(Path('four-family-shields-meshy-v1'))['models']:rows[x['definitionId']]=[[x['meshId'],x['textureId']]]
for x in load(Path('headgear-hair-td-v1')):rows[x['template']]=[[x['meshId'],x['textureId']]]
lines=['-- Generated from approved native imports. tools/generate-equipment-preload.py','return {']
for k,entries in sorted(rows.items()):lines.append(' ['+json.dumps(k)+']={'+','.join('{'+','.join(json.dumps(v)for v in pair)+'}'for pair in entries)+'},')
lines.append('}');(r/'src/shared/EquipmentPreloadManifest.luau').write_text('\n'.join(lines)+'\n')
