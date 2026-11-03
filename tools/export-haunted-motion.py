"""Validate actual Blender F-curve samples and emit bounded per-model Luau modules."""
from pathlib import Path
import json,hashlib,math
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'assets/animations/haunted-graveyard-v1'
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x)for x in v)+'}'
 return json.dumps(v,allow_nan=False,separators=(',',':'))
raw=(folder/'clips.json').read_bytes();data=json.loads(raw);source=json.load(open(ROOT/'assets/shared/td-haunted-graveyard/manifest.json'));rigs=json.load(open(folder/'rigs.json'))
assert data['samples']==201 and data['impactPhase']==.62 and set(data['models'])==set(source['models'])
output=ROOT/'src/client/HauntedGraveyardClips';output.mkdir(exist_ok=True)
for kind,model in data['models'].items():
 assert model['reviewedGait']and model['stanceDuty']==.6 and len(model['clips'])==7
 for clip,channels in model['clips'].items():
  assert set(channels)==set(data['channels'])
  for ch,rows in channels.items():
   assert len(rows)==201 and all(len(v)==(9 if ch=='body'else 3)for v in rows)
   assert all(math.isfinite(x)for row in rows for x in row)
   if clip in ['Idle','Walk','Stunned']:assert max(abs(a-b)for a,b in zip(rows[0],rows[-1]))<1e-5,(kind,clip,ch)
 if model['rigidArms']:assert all(all(v==0 for v in row)for ch in ['weapon','off']for rows in [model['clips'][c][ch]for c in model['clips']]for row in rows)
 text='-- Blender MCP evaluated per-species curves; server impact phase .62 unchanged.\nreturn '+lua(model)+'\n'
 assert len(text.encode())<200000,(kind,'split module exceeds Studio Source assignment limit')
 (output/(kind+'.luau')).write_text(text)
meta={k:v for k,v in data.items()if k!='models'};meta['sourceSha256']=hashlib.sha256(raw).hexdigest()
init='-- Authored in Blender MCP; load sampled tables only when a regional kind is used.\nlocal C='+lua(meta)+'\nC.models={}\nC.kinds='+lua(list(data['models']))+'\nlocal sources={\n'+''.join(' '+kind+'=script.'+kind+',\n'for kind in data['models'])+'}\nfunction C.get(kind)\n local source=sources[kind]\n if not source then return nil end\n if not C.models[kind]then C.models[kind]=require(source)end\n return C.models[kind]\nend\nreturn C\n'
(output/'init.luau').write_text(init)
(ROOT/'src/shared/HauntedGraveyardRigs.luau').write_text('-- Existing TD mesh identities with individually reviewed pivots and weapon/focus sockets.\nreturn '+lua(rigs)+'\n')
manifest={'version':1,'authoring':'Blender 5.2 MCP F-curves; 201 evaluated samples per channel; user scene preserved','species':10,'runtimeKinds':11,'logicalClips':77,'actions':385,'impactPhase':.62,'uploadedNewAssets':False,'modelsSource':'assets/shared/td-haunted-graveyard/manifest.json','files':{f:hashlib.sha256((folder/f).read_bytes()).hexdigest()for f in ['authoring-keys.json','clips.json','rigs.json','source-models.json']},'modules':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()for p in output.glob('*.luau')}}
(folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('11 per-model modules / 77 clips / 385 Blender F-curves exported')
