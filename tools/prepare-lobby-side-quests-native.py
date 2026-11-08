"""Create an isolated fixed-source engine test; never touches a live account."""
from pathlib import Path
import json
paths=list(Path('src/shared').rglob('*.luau'))+list(Path('src/server/Inventory').rglob('*.luau'))
paths+=list(Path('src/client').glob('*.luau'))+[Path('src/server/Lobby/NPCService.luau'),Path('src/server/World/LobbyResidents.luau')]
sources={str(p):p.read_text() for p in paths}
code='local sources={'+','.join('['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False) for k,v in sources.items())+'}\n'
code+="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')\n"
code+="for path,source in pairs(sources)do local fn,why=loadstring(source,'@'..path);assert(fn,why)end\n"
for prefix,names,target in [('src/shared',['LobbySideQuestText','LobbySideQuests'],'game.ReplicatedStorage.Shared'),('src/client',['LobbySideQuestGuide','LobbyCommerce','LobbyNavigation','NPCDialogue'],'game.StarterPlayer.StarterPlayerScripts.Client'),('src/server/Inventory',['InventoryRules','InventoryService'],'game.ServerScriptService.Server.Inventory'),('src/server/Lobby',['NPCService'],'game.ServerScriptService.Server.Lobby'),('src/server/World',['LobbyResidents'],'game.ServerScriptService.Server.World')]:
 for name in names:code+=f"assert({target}.{name}.Source==sources[{json.dumps(prefix+'/'+name+'.luau')}],'source mismatch {name}')\n"
code+=Path('tests/lobby-side-quests-native.luau').read_text().replace("print('LOBBY_SIDE_QUESTS_NATIVE '",Path('tests/lobby-side-quest-remote-native.luau').read_text()+"\nprint('LOBBY_SIDE_QUESTS_NATIVE '")
out=Path('/tmp/tlt-lobby-side-quests-native.luau');out.write_text(code);print(out)
