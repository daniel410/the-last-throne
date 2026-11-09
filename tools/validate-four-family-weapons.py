"""Validate exact Meshy source provenance and native-rendered transparent UI assets."""
import ast,hashlib,json,struct,sys
from pathlib import Path
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from validate_weapon_cutout_pngs import alpha_stats
base=ROOT/'assets/models/four-family-weapons-meshy-v1'
icons=ROOT/'assets/ui/four-family-weapon-icons-v1'
manifest=json.loads((base/'manifest.json').read_text())
tree=ast.parse((ROOT/'tools/collect-four-family-weapons.py').read_text())
whitelist=ast.literal_eval(next(n.value for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name)and t.id=='ROWS' for t in n.targets)))
expected={row[0]+'_'+row[2]:row[4] for row in whitelist}
records=manifest['records']; uploads=json.loads((base/'uploaded.json').read_text());native=json.loads((base/'native-import.json').read_text())
assert {r['id']:r['meshyTaskId'] for r in records}==expected
assert hashlib.sha256((base/'runtime.rbxm').read_bytes()).hexdigest()==manifest['runtimeSha256']
assert len(records)==16 and len({r['meshyTaskId'] for r in records})==16
assert Counter(r['rarity'] for r in records)=={'Common':8,'Uncommon':4,'Rare':4}
assert Counter(r['classId'] for r in records)=={'knight':4,'elf':4,'dwarf':4,'mage':4}
assert len(uploads)==32 and all(u['operation']['done'] and u['operation']['response']['moderationResult']['moderationState']=='Approved' for u in uploads)
assert len(native)==16 and sum(r['matchedSourceSamples'] for r in native)==768
assert (base/'runtime.rbxm').stat().st_size>100000
report=[]
for r in records:
 data=(base/r['source']).read_bytes();assert hashlib.sha256(data).hexdigest()==r['sourceSha256']
 assert data[:4]==b'glTF' and struct.unpack_from('<I',data,8)[0]==len(data)
 assert 0<r['triangles']<20000
 assert hashlib.sha256((base/r['prepared']).read_bytes()).hexdigest()==r['preparedSha256']
 assert any(n['definitionId']==r['definitionId'] and n['matchedSourceSamples']==48 for n in native)
 for size,directory in [(1024,'icons'),(64,'64'),(48,'48')]:
  path=icons/directory/(r['id']+'.png');stats=alpha_stats(path)
  assert stats['size']==[size,size] and stats['minAlpha']==0 and stats['maxAlpha']>=250 and stats['edgeNonzero']==0,(path,stats)
  report.append({'file':str(path.relative_to(icons)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),**stats})
for project in ['default.project.json','battle.project.json']:
 assert 'assets/models/four-family-weapons-meshy-v1/runtime.rbxm' in (ROOT/project).read_text()
for r in records:
 upload=next(u for u in uploads if u['id']==r['id'] and u['kind']=='icon')
 asset=upload['operation']['response']['assetId']
 assert f'["{r["definitionId"]}"] = "rbxassetid://{asset}"' in (ROOT/'src/shared/ItemSpriteAtlas.luau').read_text()
assert len({x['sha256'] for x in report if x['file'].startswith('icons/')})==16
(icons/'alpha-report.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: exact 16 Meshy tasks; 32 approved uploads; 768 matching native samples; 48 distinct-sized RGBA images, zero nontransparent edge pixels; exact per-definition UI binding.')
