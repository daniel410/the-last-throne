"""Validate actual Blender v2 F-curve samples; preserve existing mesh IDs and focus sockets."""
from pathlib import Path
import json,hashlib,math,importlib.util
ROOT=Path(__file__).resolve().parents[1]
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x)for x in v)+'}'
 return json.dumps(v,allow_nan=False,separators=(',',':'))
for region,module in [('frozen-vale','FrozenVale'),('ember-caldera','EmberCaldera')]:
 folder=ROOT/f'assets/animations/{region}-v2';raw=(folder/'clips.json').read_bytes();data=json.loads(raw);source=json.loads((ROOT/f'assets/shared/td-{region}/manifest.json').read_text());sockets=json.loads((ROOT/f'assets/animations/{region}-v1/sockets.json').read_text())
 assert data['version']==2 and data['impactPhase']==.62 and data['samples']==201 and set(data['models'])==set(source['models'])
 rigs={}
 for kind,m in data['models'].items():
  assert m['reviewedGait']and len(m['clips'])==7
  for clip,channels in m['clips'].items():
   for ch,samples in channels.items():
    assert len(samples)==201 and all(len(v)==(9 if ch=='body'else 3)for v in samples)
    assert all(math.isfinite(v)for row in samples for v in row)
    if clip in ['Idle','Walk','Stunned']:assert max(abs(a-b)for a,b in zip(samples[0],samples[-1]))<1e-5,(kind,clip,ch)
  rigs[kind]={**source['models'][kind],'folder':module+'Models','pivots':m['pivots']}
  for key in ['files','triangles','targetHeight']:rigs[kind].pop(key)
  if kind in sockets:
   rigs[kind]['socket']=sockets[kind]
   rigs[kind]['socket']['shoulders']={'weapon':m['pivots']['ArmR'],'off':m['pivots']['ArmL']}
  if kind=='IceTrollKing':
   rigs[kind].update(weaponArm='ArmL',reverseWeaponSwing=True)
   loader=importlib.util.spec_from_file_location('mesh',ROOT/'tools/repair-deepwood-weapons.py');mesh=importlib.util.module_from_spec(loader);loader.loader.exec_module(mesh)
   faces=mesh.read(ROOT/'assets/shared/td-frozen-vale/source/ice_troll_king/textured-review.glb')['ArmL'];pts=[v[0]for f in faces for v in f]
   lo=[min(v[i]for v in pts)for i in range(3)];hi=[max(v[i]for v in pts)for i in range(3)];center=[(a+b)/2 for a,b in zip(lo,hi)];size=[b-a for a,b in zip(lo,hi)]
   tip=sorted(pts,key=lambda v:v[2],reverse=True)[:max(6,len(pts)//40)];tip=[sum(v[i]for v in tip)/len(tip)for i in range(3)];normal=[-(tip[0]-center[0])/size[0],(tip[1]-center[1])/size[1],-(tip[2]-center[2])/size[2]]
   socket=rigs[kind]['socket'];socket['shoulders']={'weapon':m['pivots']['ArmL'],'off':m['pivots']['ArmR']};socket['tip']=normal;socket['base']=[normal[0],normal[1],min(.5,normal[2]+.18)]
 data['sourceSha256']=hashlib.sha256(raw).hexdigest()
 (ROOT/f'src/client/{module}Clips.luau').write_text('-- Blender MCP F-curve export: assets/animations/'+region+'-v2/clips.json\nreturn '+lua(data)+'\n')
 (ROOT/f'src/shared/{module}Rigs.luau').write_text('-- Pinned TD mesh identities; reviewed anatomical pivots, existing focus sockets.\nreturn '+lua(rigs)+'\n')
 manifest={'version':2,'authoring':'Blender 5.2 native custom-property F-curves; isolated scenes; 201 evaluated samples','species':10,'logicalClips':70,'actions':350,'sourceManifest':f'assets/shared/td-{region}/manifest.json','uploadedNewAssets':False,'files':{f:hashlib.sha256((folder/f).read_bytes()).hexdigest()for f in ['authoring-keys.json','clips.json']}}
 (folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(region,70,'clips verified')
