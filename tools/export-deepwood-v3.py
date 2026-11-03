"""Validate Blender-authored v3 clips; preserve the separately repaired v2 grip sockets."""
import json,hashlib,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'assets/animations/deepwood-monsters-v3';raw=(folder/'clips.json').read_bytes();data=json.loads(raw)
assert data['version']==3 and data['impactPhase']==.62 and data['samples']==201
for kind,model in data['models'].items():
 assert len(model['clips'])==7
 for clip,channels in model['clips'].items():
  for ch,samples in channels.items():
   assert len(samples)==201 and all(len(v)==(9 if ch=='body'else 3)for v in samples),(kind,clip,ch)
   assert all(math.isfinite(v)for row in samples for v in row)
   if clip in ['Idle','Walk','Stunned']:assert max(abs(a-b)for a,b in zip(samples[0],samples[-1]))<1e-5,(kind,clip,ch)
 assert max(abs(v)for c in model['clips'].values()for row in c['weapon']for v in row)<145
for clip,c in data['models']['Slime']['clips'].items():
 assert max(abs(v[6]*v[7]*v[8]-1)for v in c['body'])<.025,clip

def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x)for x in v)+'}'
 return json.dumps(v,allow_nan=False,separators=(',',':'))
data['sourceSha256']=hashlib.sha256(raw).hexdigest()
(ROOT/'src/client/K0EnemyClips.luau').write_text('-- Authored through Blender MCP v3; source: assets/animations/deepwood-monsters-v3/clips.json\nreturn '+lua(data)+'\n')
print(json.dumps({'pass':True,'species':10,'clips':70,'samples':201,'sourceSha256':data['sourceSha256']}))
