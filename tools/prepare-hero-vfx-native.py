"""현재 전투 VFX 소스로 저장/네트워크 없는 별도 Studio 검증 Place를 만든다."""
from pathlib import Path
import hashlib
import json
import subprocess
import argparse

root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--output',type=Path,default=Path('/tmp/tlt-hero-vfx'))
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
project={'name':'HeroVFXQA','tree':{'$className':'DataModel',
 'ReplicatedStorage':{'Shared':{'$path':str(root/'src/shared')}},
 'StarterPlayer':{'StarterPlayerScripts':{'Client':{'$path':str(root/'src/client')}}}}}
(out/'qa.project.json').write_text(json.dumps(project,indent=2)+'\n')
subprocess.run(['rojo','build',str(out/'qa.project.json'),'-o',str(out/'qa.rbxlx')],check=True)
suites=['tests/hero-vfx-native.luau','tests/wind-lance-visual-native.luau','tests/k0-hit-effects-native.luau']
(out/'probe.luau').write_text('\n'.join('do\n'+(root/name).read_text()+'\nend'for name in suites))
paths=[p for d in ['src/shared','src/client']for p in(root/d).rglob('*.luau')]+[root/s for s in suites]
(out/'inputs.json').write_text(json.dumps({str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest()for p in paths},indent=2)+'\n')
print('run-in-roblox --place',out/'qa.rbxlx','--script',out/'probe.luau')
