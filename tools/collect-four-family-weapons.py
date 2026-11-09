"""Preserve exact GLBs downloaded via Meshy's UI; whitelist latest task IDs."""
from pathlib import Path
import hashlib
import json
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/models/four-family-weapons-meshy-v1'
ROWS=[
 ('sentinel','dwarf','axe','Sapphire Citadel Axe','01a1c253-d853-737e-bfb4-3a5380953770','17:00'),
 ('sentinel','elf','bow','Azure Oathbow','01a1c253-cb81-75a2-9005-137d1449ebdf','17:00'),
 ('sentinel','mage','staff','Sapphire Citadel Scepter','01a1c253-744d-751d-8ba0-4f6154536b38','17:00'),
 ('sentinel','knight','sword','Azure Oathblade','01a1c253-2615-74aa-8274-15fa0ce80d33','16:59'),
 ('veteran','dwarf','axe','Mountainsteel Axe','01a1c253-24a1-743d-a014-9a151fb1bddb','16:59'),
 ('veteran','elf','bow','Verdant Sentinel Bow','01a1c252-8936-7610-b2bf-0705dbd59338','16:59'),
 ('veteran','mage','staff','Stormforged Scepter','01a1c252-1e74-7339-8084-708248f1f133','16:58'),
 ('veteran','knight','sword','Emerald Oathblade','01a1c251-cd3c-7601-88dd-e8f5648378b8','16:58'),
 ('tempered','dwarf','axe','Ironfang Hatchet','01a1c251-7b2c-764c-9c3a-4fe47adab9fa','16:58'),
 ('tempered','elf','bow','Moonfang Bow','01a1c251-551e-73dc-a8cc-8fa05097872d','16:57'),
 ('tempered','mage','staff','Ironbound Scepter','01a1c250-f13c-7762-9489-06076e0c7dc6','16:57'),
 ('tempered','knight','sword','Oathbreaker','01a1c250-12c0-7078-9a40-eca7bb3bc3cf','16:56'),
 ('traveler','dwarf','axe','Ironwood War Axe','01a1c24f-c03a-768b-b594-09a675c9ba49','16:56'),
 ('traveler','elf','bow','Emberwood Bow','01a1c24f-90f0-75c9-a002-ebc8fb3999c7','16:55'),
 ('traveler','mage','staff',"Shepherd's Crook Staff",'01a1c250-7faa-70a8-88fe-c8aaa3ed90b3','16:56'),
 ('traveler','knight','sword','Dawnsteel Blade','01a1c24f-2cc3-70e5-99f5-a4b76a623e00','16:55'),
]
ARCHIVES=[Path('/Users/daniel/Downloads/Meshy_AI_assets_20261109_221756.zip'),Path('/Users/daniel/Downloads/Meshy_AI_assets_20261109_221943.zip')]
records=[]
for tier,hero,kind,name,task,time in ROWS:
 matches=[]
 for archive in ARCHIVES:
  with zipfile.ZipFile(archive) as z:
   assert z.testzip() is None
   for entry in z.namelist():
    if entry.endswith('/Meshy_AI_model.glb') and task[-8:] in entry:matches.append((archive,entry,z.read(entry)))
 assert len(matches)==1,(task,matches)
 archive,entry,data=matches[0]
 assert data[:4]==b'glTF'
 size,typ=struct.unpack_from('<II',data,12);doc=json.loads(data[20:20+size])
 assert typ==0x4E4F534A
 triangles=sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives'])
 assert triangles<20000 and doc.get('images') and doc.get('textures')
 key=tier+'_'+kind;file='source/'+key+'.glb';(BASE/file).write_bytes(data)
 records.append(dict(id=key,tierId=tier,rarity={'traveler':'Common','tempered':'Common','veteran':'Uncommon','sentinel':'Rare'}[tier],classId=hero,category=kind,definitionId=hero+'_weapon_'+('fine' if tier=='tempered' else tier),meshyName=name,meshyTaskId=task,createdAt='2026-11-09T'+time+':00-05:00',createdAtPrecision='minute from Meshy visible UI',source=file,sourceSha256=hashlib.sha256(data).hexdigest(),bytes=len(data),archive=archive.name,archiveMember=entry,triangles=triangles,sourceMeshCount=len(doc['meshes']),sourceMaterials=len(doc.get('materials',[])),sourceImages=len(doc['images'])))
assert len(records)==len({r['sourceSha256'] for r in records})==16
manifest=dict(date='2026-11-09',status='downloaded-pending-integration',source='https://www.meshy.ai/workspace',selection='Latest textured cohort 2026-11-09 16:55–17:00 America/Toronto; exact task whitelist and visual match to four-family PNGs; no prior Rare/Epic, no untextured task, no shield',records=records)
(BASE/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print('Preserved 16 exact textured GLBs:',sum(r['triangles'] for r in records),'triangles total')
