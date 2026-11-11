"""Pin the environment change and run all-map collision/navigation regressions."""
from pathlib import Path
import json,runpy
paths=['src/server/World/EpicBiomeDetail.luau','src/server/World/EpicDetailTemplates.luau','src/server/World/EpicWorldArt.luau','src/server/World/CampaignSceneryCollision.luau','src/server/World/CampaignSceneryPlacement.luau','src/client/DeepwoodAtmosphere.luau']
code="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n"
for path in paths:
 p=path.split('/');prefix='game.ServerScriptService.Server' if p[1]=='server' else 'game.StarterPlayer.StarterPlayerScripts.Client'
 node=prefix+''.join('.'+s for s in p[2:]).removesuffix('.luau')
 code+=f'assert({node}.Source=={json.dumps(Path(path).read_text())},"source mismatch {path}")\n'
code+="for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then local fn,why=loadstring(m.Source,m:GetFullName());assert(fn,why)end end end\nprint('ENVIRONMENT_SOURCE_AND_COMPILE_PASS')\n"
for suite in ['tests/epic-environment-native.luau','tests/scenery-collision-native.luau','tests/td-scenic-composition-native.luau']:
 code+='do local result=(function()\n'+Path(suite).read_text()+'\nend)() end\n'
runpy.run_path('tools/prepare-map-traversal-native.py')
code+='do\n'+Path('/tmp/tlt-map-traversal-native.luau').read_text()+'\nend\n'
code+="print('ENVIRONMENT_REVIEW_READY');for i=1,1800 do if _G.TLTReviewDone then break end task.wait(1) end\n"
Path('/tmp/tlt-epic-environment-native.luau').write_text(code)
print('/tmp/tlt-epic-environment-native.luau')
