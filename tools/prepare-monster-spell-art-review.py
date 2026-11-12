"""기존 고정 빌드의 별도 Studio 사본에서 최신 VFX를 검토할 스크립트를 만든다."""
from pathlib import Path
import argparse,json,subprocess
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--kind',default='VolcanoShaman');p.add_argument('--attack',type=int,default=1);p.add_argument('--baseline',action='store_true');p.add_argument('--record',action='store_true');p.add_argument('--output',type=Path,default=Path('/tmp/tlt-spell-art-review'));a=p.parse_args()
out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for name,folder in [('EnemySpellProfiles','game.ReplicatedStorage.Shared'),('EnemySpellArt','game.StarterPlayer.StarterPlayerScripts.Client'),('EnemySpellVFX','game.StarterPlayer.StarterPlayerScripts.Client')]:
 source=(root/('src/shared/'if name=='EnemySpellProfiles'else'src/client/')/(name+'.luau')).read_text()
 if a.baseline and name=='EnemySpellVFX':source=subprocess.check_output(['git','show','866be804:src/client/EnemySpellVFX.luau'],cwd=root,text=True)
 code+=f'do local parent={folder};local m=parent:FindFirstChild({json.dumps(name)})or Instance.new("ModuleScript");m.Name={json.dumps(name)};m.Source={json.dumps(source,ensure_ascii=False)};m.Parent=parent end\n'
code+=f'_G.SpellArtKind={json.dumps(a.kind)};_G.SpellArtAttack={a.attack};_G.SpellArtBaseline={str(a.baseline).lower()}\n'
if a.record:code+='_G.SpellArtHold=22\n'
code+=(root/'tools/capture-monster-spell-art.luau').read_text()
name=a.kind+('-before'if a.baseline else'-after')
(out/(name+'.luau')).write_text(code)
print(out/(name+'.luau'))
