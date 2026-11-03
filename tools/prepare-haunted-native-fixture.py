"""Patch only disposable Studio fixture modules before any require; never touches a saved Place."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
files=['src/shared/HauntedGraveyardRigs.luau','src/client/K0EnemyWeaponMotion.luau','src/client/K0EnemyMotion.luau']
kinds=['Zombie','Skeleton','Ghoul','Mummy','Hellhound','SkeletonKnight','DeathKnight','Lich','LichSovereign','DreadCommander','Veyr']
code="""assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
game.ServerScriptService.Server.Disabled=true;game.StarterPlayer.StarterPlayerScripts.Client.Disabled=true
local function source(path)return game.HttpService:GetAsync('http://127.0.0.1:18766/'..path)end
local client=game.StarterPlayer.StarterPlayerScripts.Client
"""
code+="game.ReplicatedStorage.Shared.HauntedGraveyardRigs.Source=source('src/shared/HauntedGraveyardRigs.luau')\n"
code+="for _,name in ipairs({'K0EnemyMotion','K0EnemyWeaponMotion'})do client[name].Source=source('src/client/'..name..'.luau')end\n"
code+="local clips=Instance.new('ModuleScript');clips.Name='HauntedGraveyardClips';clips.Source=source('src/client/HauntedGraveyardClips/init.luau');clips.Parent=client\n"
for kind in kinds:code+="do local m=Instance.new('ModuleScript');m.Name='"+kind+"';m.Source=source('src/client/HauntedGraveyardClips/"+kind+".luau');m.Parent=clips end\n"
Path('/tmp/tlt-haunted-candidate-prefix.luau').write_text(code)
Path('/tmp/tlt-haunted-after-capture.luau').write_text(code+(ROOT/'tools/capture-haunted-monster-review.luau').read_text())
print('Prepared candidate fixture module injection before require; base fixed Battle0.65.1')
