from pathlib import Path
import json,hashlib,math
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'assets/animations/haunted-graveyard-v1'
manifest=json.load(open(folder/'manifest.json'));clips=json.load(open(folder/'clips.json'));rigs=json.load(open(folder/'rigs.json'));source=json.load(open(ROOT/'assets/shared/td-haunted-graveyard/manifest.json'))
assert manifest['logicalClips']==77 and manifest['actions']==385 and manifest['species']==10 and manifest['runtimeKinds']==11
for f,sha in manifest['files'].items():assert hashlib.sha256((folder/f).read_bytes()).hexdigest()==sha
for f,sha in manifest['modules'].items():assert hashlib.sha256((ROOT/f).read_bytes()).hexdigest()==sha;assert (ROOT/f).stat().st_size<200000
assert set(clips['models'])==set(source['models'])==set(rigs)
checks=0
for kind,m in clips['models'].items():
 assert set(m['pivots'])==set(source['models'][kind]['pivots'])
 assert rigs[kind]['parts']==source['models'][kind]['parts']and rigs[kind]['template']==source['models'][kind]['template']
 assert m['hasLegs']==('LegL'in rigs[kind]['parts']or'LegBL'in rigs[kind]['parts'])
 for clip,channels in m['clips'].items():
  for ch,rows in channels.items():
   assert len(rows)==201
   assert all(math.isfinite(x)for row in rows for x in row)
   if clip in ['Idle','Walk','Stunned']:assert max(abs(a-b)for a,b in zip(rows[0],rows[-1]))<1e-5
   checks+=1
 if m['rigidArms']:assert all(x==0 for clip in m['clips'].values()for ch in ['weapon','off']for row in clip[ch]for x in row)
 if not m['hasLegs']:assert 3<=len(m['groundPoints'])<=64 and all(abs(x)<=.500001 for row in m['groundPoints']for x in row)
 if kind in ['Skeleton','SkeletonKnight','Lich','LichSovereign']:assert rigs[kind]['weaponArm']=='ArmL'and 'socket'in rigs[kind]
assert clips['models']['Veyr']['clips']['Attack']['body']!=clips['models']['DreadCommander']['clips']['Attack']['body']
print('HAUNTED_MOTION_ASSETS',checks,'sampled channels / 11 stable kinds / unchanged TD identities PASS')
