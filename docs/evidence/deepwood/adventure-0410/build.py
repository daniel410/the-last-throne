#!/usr/bin/env python3
"""Build frozen 0.41.0 inputs, recording output hashes. No publish/tag operation."""
from pathlib import Path
import subprocess,hashlib,json
root=Path(__file__).resolve().parents[4]
version=(root/'VERSION').read_text().strip()
assert version=='0.41.0',version
tracked=subprocess.check_output(['git','diff','HEAD','--','src','VERSION','default.project.json','battle.project.json','assets/shared/td-selene'],cwd=root,text=True)
assert not tracked,'Commit build inputs before building'
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
out=root/'builds'/version;out.mkdir(parents=True,exist_ok=True)
record={'version':version,'source_commit':commit,'outputs':[],'published':False,'release_tag':None}
try:
 for role,project in [('Lobby','default.project.json'),('Battle','battle.project.json')]:
  target=out/f'TheLastThrone-{role}-{version}.rbxlx'
  assert not target.exists(),f'Refuse to replace an existing artifact: {target}'
  command=['rojo','build',project,'-o',str(target)]
  result=subprocess.run(command,cwd=root,capture_output=True,text=True)
  row={'role':role,'command':command,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr}
  record['outputs'].append(row)
  assert result.returncode==0,result.stderr
  row.update(path=str(target.relative_to(root)),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),bytes=target.stat().st_size)
 record['success']=True
finally:
 record.setdefault('success',False)
 (Path(__file__).parent/'build.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record,indent=2))
