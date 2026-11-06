# Generate an isolated Studio callback fixture from the production regression test.
from pathlib import Path
s=Path('tests/side-quest-battle-start.spec.lua').read_text()
s=s[s.index('local first='):]
s=s.replace("assert(load(body,'production proximity heartbeat','t',env))()", "(function()local fn=assert(loadstring(body,'production proximity heartbeat'));setmetatable(env,{__index=getfenv()});setfenv(fn,env);fn()end)()")
s=s.replace("print(string.format('Side quest battle entry: %d checks passed (%d side, %d main battle goals)',n,sideBattles,mainBattles))", "print('SIDE_BATTLE_RESULT '..game:GetService('HttpService'):JSONEncode({pass=true,checks=n,sideBattles=sideBattles,mainBattles=mainBattles}))")
source=Path('src/server/Story/DeepwoodService.luau').read_text()
prefix="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\nlocal C=require(game.ReplicatedStorage.Shared.CampaignContent)\nlocal P=require(game.ReplicatedStorage.Shared.DeepwoodProgress)\nlocal source=[====["+source+"]====]\n"
Path('/tmp/tlt-side-battle-native.luau').write_text(prefix+s)
