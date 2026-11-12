"""몬스터 마법 VFX의 저장/계정 없는 격리 Studio fixture와 입력 해시를 만든다."""
from pathlib import Path
import argparse,hashlib,json,subprocess
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=Path('/tmp/tlt-monster-spell-vfx'));p.add_argument('--capture',action='store_true');a=p.parse_args()
out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
client=['EnemySpellArt','EnemySpellVFX','EnemyPatternEffects','BossHeroImpact','PixelFX']
project={'name':'MonsterSpellVFXQA','tree':{'$className':'DataModel','ReplicatedStorage':{'Shared':{'$path':str(root/'src/shared')}},'StarterPlayer':{'StarterPlayerScripts':{'Client':{'$className':'Folder',**{name:{'$path':str(root/f'src/client/{name}.luau')}for name in client}}}}}}
(out/'qa.project.json').write_text(json.dumps(project,indent=2)+'\n')
subprocess.run(['rojo','build',str(out/'qa.project.json'),'-o',str(out/'qa.rbxlx')],check=True)
suite='tools/capture-monster-spell-vfx.luau'if a.capture else'tests/monster-spell-vfx-native.luau'
(out/'probe.luau').write_text((root/suite).read_text())
paths=list((root/'src/shared').rglob('*.luau'))+[root/f'src/client/{name}.luau'for name in client]+[root/suite]
(out/'inputs.json').write_text(json.dumps({str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest()for p in paths},indent=2)+'\n')
print('run-in-roblox --place',out/'qa.rbxlx','--script',out/'probe.luau')
