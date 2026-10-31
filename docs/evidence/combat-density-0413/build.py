"""Build only the pinned Git input; never include other working-tree edits."""
import hashlib,io,json,subprocess,tarfile,tempfile
from pathlib import Path
REPO=Path(__file__).resolve().parents[3]
EVIDENCE=Path(__file__).resolve().parent
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip()
version=subprocess.check_output(['git','show',commit+':VERSION'],cwd=REPO,text=True).strip()
assert version=='0.41.3', 'This evidence builder is reserved for 0.41.3'
projects=['default.project.json','battle.project.json']
inputs={'src','VERSION',*projects}
def collect(value):
 if isinstance(value,dict):
  if '$path' in value:inputs.add(value['$path'])
  for item in value.values():collect(item)
for project in projects:
 collect(json.loads(subprocess.check_output(['git','show',commit+':'+project],cwd=REPO)))
# src is already included as a whole; avoid duplicate tar entries.
inputs={p for p in inputs if not p.startswith('src/')}
archive=subprocess.check_output(['git','archive',commit,*sorted(inputs)],cwd=REPO)
stage=Path(tempfile.mkdtemp(prefix='tlt-0413-pinned-',dir='/private/tmp'))
with tarfile.open(fileobj=io.BytesIO(archive)) as bundle:bundle.extractall(stage,filter='data')
materialized=[]
for path in stage.rglob('*'):
 if not path.is_file():continue
 data=path.read_bytes()
 if data.startswith(b'version https://git-lfs.github.com/spec/v1\n'):
  fields=dict(line.split(' ',1) for line in data.decode().splitlines())
  relative=path.relative_to(stage);actual=(REPO/relative).read_bytes()
  assert hashlib.sha256(actual).hexdigest()==fields['oid'].removeprefix('sha256:'),str(relative)+' differs from pinned LFS input'
  assert len(actual)==int(fields['size']),str(relative)+' LFS size mismatch'
  path.write_bytes(actual);materialized.append(str(relative))
output=REPO/'builds'/version
output.mkdir(parents=True,exist_ok=False)
report={'version':version,'source_commit':commit,'tool':subprocess.check_output(['rojo','--version'],text=True).strip(),'stage':str(stage),'lfs_materialized':materialized,'artifacts':[],'published':False,'release_tag':None}
try:
 for role,project in zip(['Lobby','Battle'],projects):
  target=output/f'TheLastThrone-{role}-{version}.rbxlx'
  command=['rojo','build',project,'--output',str(target)]
  result=subprocess.run(command,cwd=stage,text=True,capture_output=True)
  (EVIDENCE/f'{role.lower()}-build.log').write_text(result.stdout+result.stderr)
  assert result.returncode==0,result.stderr
  data=target.read_bytes()
  report['artifacts'].append({'role':role,'path':str(target.relative_to(REPO)),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'command':command,'result':'success'})
 report['status']='local-build-success-unpublished'
finally:
 if 'status' not in report:report['status']='failed'
 (EVIDENCE/'build.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
