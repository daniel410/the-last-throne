"""Verify release confirmation with actual shot and authored bow regressions."""
from pathlib import Path
import argparse,json
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');a=p.parse_args()
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for path,node in [('src/server/Combat/CombatService.luau','game.ServerScriptService.Server.Combat.CombatService'),('src/client/K0BowMotion.luau','game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion')]:
 source=json.dumps(Path(path).read_text(),ensure_ascii=False)
 code+=f'{node}.Source={source}\n'if a.preview else f'assert({node}.Source=={source},"source mismatch {path}")\n'
code+="for _,r in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,s in ipairs(r:GetDescendants())do if s:IsA('LuaSourceContainer')then assert(loadstring(s.Source,s:GetFullName()))end end end\n"
for name in ['elf-confirmed-release-native','elf-straight-shot-native','k0-elf-bow-native','elf-basic-tempo-native']:
 source=Path('tests/'+name+'.luau').read_text()
 if name=='k0-elf-bow-native':source='local BowGolden=(function()\n'+Path('tests/elf-bow-golden.luau').read_text()+'\nend)()\n'+source
 code+='assert(loadstring('+json.dumps(source,ensure_ascii=False)+'))()\n'
code+="print('ELF_CONFIRMED_RELEASE_ALL_PASS')\n"
Path('/tmp/tlt-elf-confirmed-release-native.luau').write_text(code)
