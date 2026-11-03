"""Build both local Places from a committed tree, verifying every referenced LFS input."""
from pathlib import Path
import argparse,hashlib,io,json,re,subprocess,tarfile,tempfile
ROOT=Path(__file__).resolve().parents[1]
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT)
def sha(data):return hashlib.sha256(data).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--source',default='HEAD');p.add_argument('--record',type=Path,required=True);args=p.parse_args()
commit=git('rev-parse',args.source).decode().strip();version=git('show',commit+':VERSION').decode().strip()
assert re.fullmatch(r'\d+\.\d+\.\d+',version)
projects={role:json.loads(git('show',commit+':'+name))for role,name in [('Lobby','default.project.json'),('Battle','battle.project.json')]}
inputs={'VERSION','default.project.json','battle.project.json'}
def collect(value):
 if isinstance(value,dict):
  for k,v in value.items():
   if k=='$path':inputs.add(v)
   else:collect(v)
 elif isinstance(value,list):
  for v in value:collect(v)
for value in projects.values():collect(value)
freeze=Path(tempfile.mkdtemp(prefix='tlt-mr01-freeze-'+commit[:8]+'-'))
archive=git('archive',commit,'--',*sorted(inputs))
with tarfile.open(fileobj=io.BytesIO(archive))as tar:tar.extractall(freeze,filter='data')
lfs=[]
for path in freeze.rglob('*'):
 if not path.is_file():continue
 data=path.read_bytes()
 if data.startswith(b'version https://git-lfs.github.com/spec/v1\n'):
  oid=re.search(rb'oid sha256:([a-f0-9]{64})',data).group(1).decode()
  content=subprocess.check_output(['git','lfs','smudge'],input=data,cwd=ROOT)
  assert sha(content)==oid,str(path)
  path.write_bytes(content);lfs.append({'path':str(path.relative_to(freeze)),'sha256':oid})
out=ROOT/'builds'/version;out.mkdir(parents=True,exist_ok=True)
record={'version':version,'sourceCommit':commit,'freeze':str(freeze),'lfsVerified':lfs,'published':False,'releaseTag':None,'outputs':[]}
for role,project in [('Lobby','default.project.json'),('Battle','battle.project.json')]:
 target=out/f'TheLastThrone-{role}-{version}.rbxlx';assert not target.exists(),'Never overwrite a used build version'
 command=['rojo','build',str(freeze/project),'-o',str(target)]
 result=subprocess.run(command,capture_output=True,text=True)
 row={'role':role,'command':command,'status':'success'if result.returncode==0 else'failed','stdout':result.stdout,'stderr':result.stderr}
 if target.exists():row.update(path=str(target.relative_to(ROOT)),sha256=sha(target.read_bytes()),bytes=target.stat().st_size)
 record['outputs'].append(row);args.record.write_text(json.dumps(record,indent=2)+'\n')
 assert result.returncode==0,result.stderr
print(json.dumps({'version':version,'sourceCommit':commit,'outputs':[r['path']for r in record['outputs']]}))
