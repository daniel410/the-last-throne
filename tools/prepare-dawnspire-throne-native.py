"""Assemble source-pinned native validation; --preview injects into an older isolated host."""
from pathlib import Path
import argparse
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--preview',action='store_true');args=p.parse_args()
paths=['src/shared/DawnspireDesign.luau','src/shared/LobbyFacilities.luau','src/shared/TDLobbyThroneGeometry.luau','src/server/World/DawnspireThrone.luau','src/server/World/LobbyWorld.luau','src/server/World/LobbyResidents.luau','src/client/DawnspireHomecoming.luau','src/client/LobbySideQuestGuide.luau']
prefix={'shared':'game.ReplicatedStorage.Shared','server':'game.ServerScriptService.Server','client':'game.StarterPlayer.StarterPlayerScripts.Client'}
code='assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n'
for path in paths:
 f=Path(path);parent=prefix[f.parts[1]]+''.join('.'+x for x in f.parts[2:-1]);source=(root/f).read_text();assert ']====]' not in source
 if args.preview:
  code+=f'do local p={parent};local m=p:FindFirstChild("{f.stem}") or Instance.new("ModuleScript");m.Name="{f.stem}";m.Source=[====[{source}]====];m.Parent=p end\n'
 else:
  code+=f'assert({parent}.{f.stem}.Source==[====[{source}]====],"fixed source mismatch: {path}")\n'
guide=(root/'tests/lobby-side-quests-native.luau').read_text();assert ']====]' not in guide
code+='assert(loadstring([====['+guide+']====],"lobby-side-quests-native"))()\n'
code+=(root/'tests/dawnspire-throne-native.luau').read_text()
out=Path('/tmp/tlt-dawnspire-throne-native.luau');out.write_text(code);print(out)
