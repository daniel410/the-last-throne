"""Build the committed 0.43.1 tree, materializing only pinned runtime LFS assets."""
from pathlib import Path
import hashlib
import io
import json
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[3]
VERSION = '0.43.1'
assert (ROOT/'VERSION').read_text().strip() == VERSION
commit = subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
stage = Path(tempfile.mkdtemp(prefix='tlt-selene-0431-pinned-'))
data = subprocess.check_output(['git','archive',commit],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(data)) as archive:
    archive.extractall(stage,filter='data')
assert (stage/'VERSION').read_text().strip() == VERSION
record = dict(version=VERSION,source_commit=commit,tool='Rojo 7.7.1',artifacts=[],published=False,release_tag=None)
try:
    project = json.loads((stage/'default.project.json').read_text())
    for name, mount in project['tree']['ServerStorage'].items():
        if '$path' not in mount:
            continue
        path = stage/mount['$path']
        pointer = path.read_bytes()
        if pointer.startswith(b'version https://git-lfs.github.com/spec/v1'):
            content = subprocess.check_output(['git','lfs','smudge'],input=pointer,cwd=ROOT)
            oid = pointer.decode().split('oid sha256:')[1].splitlines()[0]
            assert hashlib.sha256(content).hexdigest() == oid, name
            path.write_bytes(content)
    out = ROOT/'builds'/VERSION
    out.mkdir(parents=True,exist_ok=True)
    for role, project in [('Lobby','default.project.json'),('Battle','battle.project.json')]:
        path = out/f'TheLastThrone-{role}-{VERSION}.rbxlx'
        assert not path.exists(), f'Refuse to overwrite {path}'
        command = ['rojo','build',project,'--output',str(path)]
        result = subprocess.run(command,cwd=stage,capture_output=True,text=True)
        row = dict(role=role,path=str(path.relative_to(ROOT)),command=command,exit_code=result.returncode)
        record['artifacts'].append(row)
        assert result.returncode == 0, result.stderr
        row.update(bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),result='success')
    record['success'] = True
finally:
    record.setdefault('success',False)
    (Path(__file__).parent/'build.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record,indent=2))
